//
//  PSDatasetSignalToNoise.c
//  LibPhySy
//
//  Created by Philip J. Grandinetti on 3/5/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetSignalToNoiseCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFMutableArrayRef lowerNoiseLimits = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    CFMutableArrayRef upperNoiseLimits = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    CFMutableArrayRef lowerSignalLimits = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    CFMutableArrayRef upperSignalLimits = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    
    for(CFIndex dimIndex = 0; dimIndex<dimensionsCount; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        
        PSScalarRef lowerNoiseLimit = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
        CFArrayAppendValue(lowerNoiseLimits, lowerNoiseLimit);
        CFRelease(lowerNoiseLimit);
        
        PSScalarRef upperNoiseLimit = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
        CFArrayAppendValue(upperNoiseLimits, upperNoiseLimit);
        CFRelease(upperNoiseLimit);

        PSScalarRef lowerSignalLimit = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
        CFArrayAppendValue(lowerSignalLimits, lowerSignalLimit);
        CFRelease(lowerSignalLimit);

        PSScalarRef upperSignalLimit = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
        CFArrayAppendValue(upperSignalLimits, upperSignalLimit);
        CFRelease(upperSignalLimit);
    }
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryAddValue(parameters, kPSDatasetSignalToNoiseLowerNoiseLimits, lowerNoiseLimits);
    CFDictionaryAddValue(parameters, kPSDatasetSignalToNoiseUpperNoiseLimits, upperNoiseLimits);
    CFDictionaryAddValue(parameters, kPSDatasetSignalToNoiseLowerSignalLimits, lowerSignalLimits);
    CFDictionaryAddValue(parameters, kPSDatasetSignalToNoiseUpperSignalLimits, upperSignalLimits);
    
    CFRelease(lowerNoiseLimits);
    CFRelease(upperNoiseLimits);
    CFRelease(lowerSignalLimits);
    CFRelease(upperSignalLimits);
    
    return parameters;
}

bool PSDatasetSignalToNoiseValidateParametersForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetSignalToNoiseLowerNoiseLimits)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetSignalToNoiseUpperNoiseLimits)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetSignalToNoiseLowerSignalLimits)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetSignalToNoiseUpperSignalLimits)) return false;
    
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFArrayRef lowerNoiseLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseLowerNoiseLimits);
    CFArrayRef upperNoiseLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseUpperNoiseLimits);
    CFArrayRef lowerSignalLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseLowerSignalLimits);
    CFArrayRef upperSignalLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseUpperSignalLimits);

    if(CFArrayGetCount(lowerNoiseLimits)!=dimensionsCount) return false;
    if(CFArrayGetCount(upperNoiseLimits)!=dimensionsCount) return false;
    if(CFArrayGetCount(lowerSignalLimits)!=dimensionsCount) return false;
    if(CFArrayGetCount(upperSignalLimits)!=dimensionsCount) return false;
    
    for(CFIndex dimIndex = 0; dimIndex<dimensionsCount; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        PSDimensionalityRef dimensionality = PSDimensionGetDisplayedUnitDimensionality(dimension);
        
        PSScalarRef lowerNoiseLimit = (PSScalarRef) CFArrayGetValueAtIndex(lowerNoiseLimits, dimIndex);
        if(!PSDimensionalityEqual(PSQuantityGetUnitDimensionality((PSQuantityRef) lowerNoiseLimit), dimensionality)) return false;

        PSScalarRef upperNoiseLimit = (PSScalarRef) CFArrayGetValueAtIndex(upperNoiseLimits, dimIndex);
        if(!PSDimensionalityEqual(PSQuantityGetUnitDimensionality((PSQuantityRef) upperNoiseLimit), dimensionality)) return false;
        
        PSScalarRef lowerSignalLimit = (PSScalarRef) CFArrayGetValueAtIndex(lowerSignalLimits, dimIndex);
        if(!PSDimensionalityEqual(PSQuantityGetUnitDimensionality((PSQuantityRef) lowerSignalLimit), dimensionality)) return false;
        
        PSScalarRef upperSignalLimit = (PSScalarRef) CFArrayGetValueAtIndex(upperSignalLimits, dimIndex);
        if(!PSDimensionalityEqual(PSQuantityGetUnitDimensionality((PSQuantityRef) upperSignalLimit), dimensionality)) return false;
        
    }
    return true;
}

double realNoiseN;
double imagNoiseN;
double realNoiseMean;
double imagNoiseMean;
double realNoiseM2;
double imagNoiseM2;
double realNoiseM3;
double imagNoiseM3;
double realNoiseM4;
double imagNoiseM4;

static void DoNoiseNestedLoops(PSDatasetRef theDataset,
                               CFIndex *lowerNoiseLimitIndex,
                               CFIndex *upperNoiseLimitIndex,
                               PSMutableIndexArrayRef coordinateIndexValues,
                               CFIndex dependentVariableIndex,
                               CFIndex componentIndex,
                               CFIndex dimIndex)
{
    for(CFIndex index = lowerNoiseLimitIndex[dimIndex]; index<=upperNoiseLimitIndex[dimIndex]; index++) {
        PSIndexArraySetValueAtIndex(coordinateIndexValues, dimIndex, index);
        if(dimIndex>0) DoNoiseNestedLoops(theDataset,lowerNoiseLimitIndex,upperNoiseLimitIndex,coordinateIndexValues,dependentVariableIndex, componentIndex, dimIndex-1);
        else {
            PSScalarRef response = PSDatasetCreateResponseFromCoordinateIndexes(theDataset, dependentVariableIndex, componentIndex, coordinateIndexValues);
            double complex value = PSScalarDoubleComplexValue(response);
            {
                double x = creal(value);
                double n1 = realNoiseN;
                realNoiseN += 1;
                double delta = x - realNoiseMean;
                double delta_n = delta / realNoiseN;
                double delta_n2 = delta_n * delta_n;
                double term1 = delta * delta_n * n1;
                realNoiseMean += delta_n;
                if(n1 > 0) {
                    realNoiseM4 += term1 * delta_n2 * (realNoiseN*realNoiseN - 3*realNoiseN + 3) + 6 * delta_n2 * realNoiseM2 - 4 * delta_n * realNoiseM3;
                    
                    realNoiseM3 += term1 * delta_n * (realNoiseN - 2) - 3 * delta_n * realNoiseM2;
                    realNoiseM2 += term1;
                }
            }
            
            {
                double x = cimag(value);
                double n1 = imagNoiseN;
                imagNoiseN += 1;
                double delta = x - imagNoiseMean;
                double delta_n = delta / imagNoiseN;
                double delta_n2 = delta_n * delta_n;
                double term1 = delta * delta_n * n1;
                imagNoiseMean += delta_n;
                if(n1 > 0) {
                    imagNoiseM4 += term1 * delta_n2 * (imagNoiseN*imagNoiseN - 3*imagNoiseN + 3) + 6 * delta_n2 * imagNoiseM2 - 4 * delta_n * imagNoiseM3;
                    
                    imagNoiseM3 += term1 * delta_n * (imagNoiseN - 2) - 3 * delta_n * imagNoiseM2;
                    imagNoiseM2 += term1;
                }
            }
            CFRelease(response);
        }
    }
}

double realResponseMax;
double imagResponseMax;
double realResponseMin;
double imagResponseMin;

static void DoSignalNestedLoops(PSDatasetRef theDataset,
                                CFIndex *lowerSignalLimitIndex,
                                CFIndex *upperSignalLimitIndex,
                                PSMutableIndexArrayRef coordinateIndexValues,
                                CFIndex dependentVariableIndex,
                                CFIndex componentIndex,
                                CFIndex dimIndex)
{
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    bool isComplex = PSQuantityIsComplexType(theDependentVariable);
    for(CFIndex index = lowerSignalLimitIndex[dimIndex]; index<=upperSignalLimitIndex[dimIndex]; index++) {
        PSIndexArraySetValueAtIndex(coordinateIndexValues, dimIndex, index);
        if(dimIndex>0) DoSignalNestedLoops(theDataset,lowerSignalLimitIndex,upperSignalLimitIndex,coordinateIndexValues,dependentVariableIndex,componentIndex, dimIndex-1);
        else {
            PSScalarRef response = PSDatasetCreateResponseFromCoordinateIndexes(theDataset, dependentVariableIndex, componentIndex, coordinateIndexValues);
            if(isComplex) {
                double complex value = PSScalarDoubleComplexValue(response);
                double real = creal(value);
                double imag = cimag(value);
                if(realResponseMax<real) realResponseMax = real;
                if(imagResponseMax<imag) imagResponseMax = imag;
                if(realResponseMin>real) realResponseMin = real;
                if(imagResponseMin>imag) imagResponseMin = imag;
            }
            else {
                double value = PSScalarDoubleValue(response);
                if(realResponseMax<value) realResponseMax = value;
                if(realResponseMin>value) realResponseMin = value;
            }
            CFRelease(response);
        }
    }
}

CFDictionaryRef PSDatasetSignalToNoiseCreateResultsForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    // Setup Calculations
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);

    bool isComplex = PSQuantityIsComplexType(theDependentVariable);
    
    CFArrayRef lowerNoiseLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseLowerNoiseLimits);
    CFArrayRef upperNoiseLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseUpperNoiseLimits);
    CFArrayRef lowerSignalLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseLowerSignalLimits);
    CFArrayRef upperSignalLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseUpperSignalLimits);
    
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFIndex lowerNoiseLimitIndex[dimensionsCount];
    CFIndex upperNoiseLimitIndex[dimensionsCount];
    CFIndex lowerSignalLimitIndex[dimensionsCount];
    CFIndex upperSignalLimitIndex[dimensionsCount];
    
    for(CFIndex dimIndex=0;dimIndex<dimensionsCount;dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        lowerNoiseLimitIndex[dimIndex] = (CFIndex) PSDimensionClosestIndexToDisplayedCoordinate(dimension, CFArrayGetValueAtIndex(lowerNoiseLimits, dimIndex));
        upperNoiseLimitIndex[dimIndex] = (CFIndex) PSDimensionClosestIndexToDisplayedCoordinate(dimension, CFArrayGetValueAtIndex(upperNoiseLimits, dimIndex));
        lowerSignalLimitIndex[dimIndex] = (CFIndex) PSDimensionClosestIndexToDisplayedCoordinate(dimension, CFArrayGetValueAtIndex(lowerSignalLimits, dimIndex));
        upperSignalLimitIndex[dimIndex] = (CFIndex) PSDimensionClosestIndexToDisplayedCoordinate(dimension, CFArrayGetValueAtIndex(upperSignalLimits, dimIndex));
    }
    
    CFMutableDictionaryRef results = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);

    realNoiseN = 0;
    imagNoiseN = 0;
    realNoiseMean = 0;
    imagNoiseMean = 0;
    realNoiseM2 = 0;
    imagNoiseM2 = 0;
    realNoiseM3 = 0;
    imagNoiseM3 = 0;
    realNoiseM4 = 0;
    imagNoiseM4 = 0;
    
    PSMutableIndexArrayRef coordinateIndexValues = PSIndexArrayCreateMutable(dimensionsCount);
    DoNoiseNestedLoops(theDataset,
                       lowerNoiseLimitIndex,
                       upperNoiseLimitIndex,
                       coordinateIndexValues,
                       dependentVariableIndex,
                       componentIndex,
                       dimensionsCount-1);

    double realStandardDeviation = sqrt(realNoiseM2/(realNoiseN-1));
    double realSkewness = sqrt(realNoiseN) * realNoiseM3/pow(realNoiseM2,1.5);
    double realKurtosis = (realNoiseN*realNoiseM4) / (realNoiseM2*realNoiseM2) - 3;
    
    double imagStandardDeviation = 0;
    double imagSkewness = 0;
    double imagKurtosis = 0;

    if(isComplex) {
        imagStandardDeviation = sqrt(imagNoiseM2/(imagNoiseN-1));
        imagSkewness = sqrt(imagNoiseN) * imagNoiseM3/pow(imagNoiseM2,1.5);
        imagKurtosis = (imagNoiseN*imagNoiseM4) / (imagNoiseM2*imagNoiseM2) - 3;
    }
    
    if(isComplex) {
        PSScalarRef noiseMean = PSScalarCreateWithFloatComplex(realNoiseMean + imagNoiseMean*I, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseMean, noiseMean);
        CFRelease(noiseMean);
        
        PSScalarRef noiseStandardDeviation = PSScalarCreateWithFloatComplex(realStandardDeviation + imagStandardDeviation*I, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseStandardDeviation, noiseStandardDeviation);
        CFRelease(noiseStandardDeviation);
        
        PSScalarRef noiseSkewness = PSScalarCreateWithFloatComplex(realSkewness + imagSkewness*I, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseSkewness, noiseSkewness);
        CFRelease(noiseSkewness);
        
        PSScalarRef noiseKurtosis = PSScalarCreateWithFloatComplex(realKurtosis + imagKurtosis*I, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseKurtosis, noiseKurtosis);
        CFRelease(noiseKurtosis);
    }
    else {
        PSScalarRef noiseMean = PSScalarCreateWithFloat(realNoiseMean, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseMean, noiseMean);
        CFRelease(noiseMean);
        
        PSScalarRef noiseStandardDeviation = PSScalarCreateWithFloat(realStandardDeviation, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseStandardDeviation, noiseStandardDeviation);
        CFRelease(noiseStandardDeviation);
        
        PSScalarRef noiseSkewness = PSScalarCreateWithFloat(realSkewness, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseSkewness, noiseSkewness);
        CFRelease(noiseSkewness);
        
        PSScalarRef noiseKurtosis = PSScalarCreateWithFloat(realKurtosis, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseNoiseKurtosis, noiseKurtosis);
        CFRelease(noiseKurtosis);
    }
    
    
    realResponseMax = -MAXFLOAT;
    imagResponseMax = -MAXFLOAT;
    realResponseMin = MAXFLOAT;
    imagResponseMin = MAXFLOAT;
    DoSignalNestedLoops(theDataset, 
                        lowerSignalLimitIndex,
                        upperSignalLimitIndex,
                        coordinateIndexValues,
                        dependentVariableIndex,
                        componentIndex,
                        dimensionsCount-1);
    
    CFRelease(coordinateIndexValues);
    
    if(isComplex) {
        PSScalarRef responseMin = PSScalarCreateWithFloatComplex(realResponseMin + imagResponseMin*I, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseResponseMin, responseMin);
        CFRelease(responseMin);
        
        PSScalarRef responseMax = PSScalarCreateWithFloatComplex(realResponseMax + imagResponseMax*I, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseResponseMax, responseMax);
        CFRelease(responseMax);
        
        double realSignalMaxToNoise = realResponseMax/realStandardDeviation;
        double imagSignalMaxToNoise = imagResponseMax/imagStandardDeviation;
        PSScalarRef signalMaxToNoise = PSScalarCreateWithFloatComplex(realSignalMaxToNoise + imagSignalMaxToNoise*I, PSUnitDimensionlessAndUnderived());
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseSignalMaxToNoise, signalMaxToNoise);
        CFRelease(signalMaxToNoise);
        
        double realSignalMinToNoise = realResponseMin/realStandardDeviation;
        double imagSignalMinToNoise = imagResponseMin/imagStandardDeviation;
        PSScalarRef signalMinToNoise = PSScalarCreateWithFloatComplex(realSignalMinToNoise + imagSignalMinToNoise*I, PSUnitDimensionlessAndUnderived());
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseSignalMinToNoise, signalMinToNoise);
        CFRelease(signalMinToNoise);
    }
    else {
        PSScalarRef responseMin = PSScalarCreateWithFloat(realResponseMin, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseResponseMin, responseMin);
        CFRelease(responseMin);
        
        PSScalarRef responseMax = PSScalarCreateWithFloat(realResponseMax, responseUnit);
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseResponseMax, responseMax);
        CFRelease(responseMax);
        
        double realSignalMaxToNoise = realResponseMax/realStandardDeviation;
        PSScalarRef signalMaxToNoise = PSScalarCreateWithFloat(realSignalMaxToNoise, PSUnitDimensionlessAndUnderived());
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseSignalMaxToNoise, signalMaxToNoise);
        CFRelease(signalMaxToNoise);
        
        double realSignalMinToNoise = realResponseMin/realStandardDeviation;
        PSScalarRef signalMinToNoise = PSScalarCreateWithFloat(realSignalMinToNoise, PSUnitDimensionlessAndUnderived());
        CFDictionarySetValue(results, kPSDatasetSignalToNoiseSignalMinToNoise, signalMinToNoise);
        CFRelease(signalMinToNoise);
    }
    
    return results;
}


