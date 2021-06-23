  //
//  PSDatasetLinearInverse.m
//  RMN
//
//  Created by philip on 11/25/15.
//  Copyright © 2015 PhySy. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <LibPhySyObjC/PhySyDatasetOperations.h>


CFMutableDictionaryRef PSDatasetLinearInverseCreateDefaultParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(error) if(*error) return NULL;
    
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    int kernel = kPSDatasetInverseLaplace1DExponential;
    CFNumberRef theKernel = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &kernel);
    CFDictionaryAddValue(parameters, kPSDatasetLinearInverseKernelType, theKernel);
    CFRelease(theKernel);
    
    PSUnitRef responseUnit = PSDatasetGetResponseUnit(theDataset);
    PSScalarRef noise = PSScalarCreateWithDouble(1.0, responseUnit);
    CFDictionaryAddValue(parameters, kPSDatasetLinearInverseNoiseStandardDeviation, noise);
    CFRelease(noise);
    
    if(kernel==kPSDatasetInverseLaplace1DExponential) {
        PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
        PSScalarRef samplingInterval = PSDimensionGetSamplingInterval(horizontalDimension);
        
        PSScalarRef minimumCoordinate = PSScalarCreateCopy(samplingInterval);
        PSScalarSetElementType((PSMutableScalarRef) minimumCoordinate, kPSNumberFloat64Type);
        PSScalarRef maximumCoordinate = PSDimensionCreateRelativeCoordinateFromIndex(horizontalDimension, PSDimensionHighestIndex(horizontalDimension));
        PSScalarSetElementType((PSMutableScalarRef) maximumCoordinate, kPSNumberFloat64Type);
        
        PSScalarRef lambda = PSScalarCreateWithDouble(1, PSUnitDimensionlessAndUnderived());
        
        CFStringRef quantityName = PSDimensionGetQuantityName(horizontalDimension);
        CFDictionaryAddValue(parameters, kPSDatasetLinearInverseCoordinateQuantity , quantity);
        
        CFStringRef inverseQuantityName = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("inverse %@"),quantity);
        CFDictionaryAddValue(parameters, kPSDatasetLinearInverseCoordinateinverseQuantityName, inverseQuantityName);
        CFRelease(inverseQuantityName);
        
        CFDictionaryAddValue(parameters, kPSDatasetLinearInverseCoordinateMin, minimumCoordinate);
        CFRelease(minimumCoordinate);
        
        CFDictionaryAddValue(parameters, kPSDatasetLinearInverseCoordinateMax, maximumCoordinate);
        CFRelease(maximumCoordinate);
        
        CFDictionaryAddValue(parameters, kPSDatasetLinearInverseLambda, lambda);
        CFRelease(lambda);
        
        CFNumberRef theNumberOfSample = PSCFNumberCreateWithCFIndex(PSDimensionGetNpts(horizontalDimension)/10);
        CFDictionaryAddValue(parameters, kPSDatasetLinearInverseNumberOfSamples, theNumberOfSample);
        CFRelease(theNumberOfSample);
        
        int coordinateSpacing = kPSDatasetLinearCoordinate;
        CFNumberRef theCoordinateSpacing = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &coordinateSpacing);
        
        CFDictionaryAddValue(parameters, kPSDatasetLinearInverseModelCoordinateSpacing, theCoordinateSpacing);
        CFRelease(theCoordinateSpacing);

    }

    return parameters;
}

linearInverseAlgorithm PSDatasetLinearInverseGetAlgorithm(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,kPSDatasetLinearInverseL2NormRidgeRegression);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseAlgorithm)) return kPSDatasetLinearInverseL2NormRidgeRegression;
    CFNumberRef theAlgorithm = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseAlgorithm);
    
    if(theAlgorithm) {
        int typeIndex;
        CFNumberGetValue(theAlgorithm, kCFNumberIntType, &typeIndex);
        linearInverseAlgorithm type = typeIndex;
        return type;
    }
    return kPSDatasetLinearInverseL2NormRidgeRegression;
}

void PSDatasetLinearInverseSetAlgorithm(CFMutableDictionaryRef parameters, linearInverseAlgorithm algorithm)
{
    CFNumberRef type = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &algorithm);
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseAlgorithm)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseAlgorithm, type);
    else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseAlgorithm, type);
    
    CFRelease(type);
}


linearInverseKernel PSDatasetLinearInverseGetKernelType(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,kPSDatasetInverseLaplace1DExponential);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseKernelType)) return kPSDatasetInverseLaplace1DExponential;
    CFNumberRef theKernel = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseKernelType);
    
    if(theKernel) {
        int typeIndex;
        CFNumberGetValue(theKernel, kCFNumberIntType, &typeIndex);
        linearInverseKernel type = typeIndex;
        return type;
    }
    return kPSDatasetInverseLaplace1DExponential;
}

void PSDatasetLinearInverseSetKernelType(CFMutableDictionaryRef parameters, linearInverseKernel kernel)
{
    CFNumberRef type = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &kernel);
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseKernelType)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseKernelType, type);
    else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseKernelType, type);
    
    CFRelease(type);
}

linearInverseModelCoordinateSpacing PSDatasetLinearInverseGetCoordinateSpacing(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,kPSDatasetLogCoordinate);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseModelCoordinateSpacing)) return kPSDatasetLogCoordinate;
    CFNumberRef theCoordinateType = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseModelCoordinateSpacing);
    
    if(theCoordinateType) {
        int typeIndex;
        CFNumberGetValue(theCoordinateType, kCFNumberIntType, &typeIndex);
        linearInverseModelCoordinateSpacing type = typeIndex;
        return type;
    }
    return kPSDatasetLogCoordinate;
}

void PSDatasetLinearInverseSetCoordinateSpacing(CFMutableDictionaryRef parameters, linearInverseModelCoordinateSpacing coordinateType)
{
    CFNumberRef type = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &coordinateType);
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseModelCoordinateSpacing)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseModelCoordinateSpacing, type);
    else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseModelCoordinateSpacing, type);
    
    CFRelease(type);
}


CFIndex PSDatasetLinearInverseGetNumberOfSamples(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,0);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseNumberOfSamples)) return 0;
    CFNumberRef theNumberOfSamples = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseNumberOfSamples);
    
    if(theNumberOfSamples) {
        CFIndex numberOfSamples;
        CFNumberGetValue(theNumberOfSamples, kCFNumberCFIndexType, &numberOfSamples);
        return numberOfSamples;
    }
    return 0;
}

bool PSDatasetLinearInverseSetNumberOfSamples(CFMutableDictionaryRef parameters, CFIndex numberOfSamples, PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    CFNumberRef theNumberOfSamples = PSCFNumberCreateWithCFIndex(numberOfSamples);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    CFIndex npts = PSDimensionGetNpts(horizontalDimension);

    if(numberOfSamples<2 || numberOfSamples>npts) {
        CFRelease(theNumberOfSamples);
        return false;}
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseNumberOfSamples)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseNumberOfSamples, theNumberOfSamples);
    else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseNumberOfSamples, theNumberOfSamples);
    CFRelease(theNumberOfSamples);
    return true;
}

PSScalarRef PSDatasetLinearInverseGetNoiseStandardDeviation(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseNoiseStandardDeviation)) return NULL;
    PSScalarRef noise = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseNoiseStandardDeviation);
    return noise;
}

bool PSDatasetLinearInverseSetNoiseStandardDeviation(CFMutableDictionaryRef parameters, PSScalarRef noise)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    IF_NO_OBJECT_EXISTS_RETURN(noise,false);
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseNoiseStandardDeviation)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseNoiseStandardDeviation, noise);
    else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseNoiseStandardDeviation, noise);
    return true;
}

PSScalarRef PSDatasetLinearInverseGetLambda(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseLambda)) return NULL;
    PSScalarRef lambda = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseLambda);
    return lambda;
}

bool PSDatasetLinearInverseSetLambda(CFMutableDictionaryRef parameters, PSScalarRef lambda)
{
   	IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
   	IF_NO_OBJECT_EXISTS_RETURN(lambda,false);
    
    if(PSUnitIsDimensionless(PSQuantityGetUnit(lambda))) {
        if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseLambda)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseLambda, lambda);
        else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseLambda, lambda);
        return true;
    }
    return false;
}

PSScalarRef PSDatasetLinearInverseGetMinimumCoordinate(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateMin)) return NULL;
    PSScalarRef coordinate = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseCoordinateMin);
    return coordinate;
}

bool PSDatasetLinearInverseSetMinimumCoordinate(CFMutableDictionaryRef parameters, PSScalarRef coordinate, PSDatasetRef theDataset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
   	IF_NO_OBJECT_EXISTS_RETURN(coordinate,false);
   	IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    
    PSUnitRef unit = PSDimensionGetRelativeUnit(horizontalDimension);
    
    if(PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(unit), PSQuantityGetUnitDimensionality(coordinate))) {
        
        if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateMin)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseCoordinateMin, coordinate);
        else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseCoordinateMin, coordinate);
        return true;
    }
    return false;
}

PSScalarRef PSDatasetLinearInverseGetMaximumCoordinate(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateMax)) return NULL;
    PSScalarRef coordinate = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseCoordinateMax);
    return coordinate;
}

CFStringRef PSDatasetLinearInverseGetCoordinateQuantity(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateMax)) return NULL;
    CFStringRef quantityName = (CFStringRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseCoordinateMax);
    return quantity;
}

CFStringRef PSDatasetLinearInverseGetCoordinateinverseQuantityName(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateinverseQuantityName)) return NULL;
    CFStringRef quantityName = (CFStringRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseCoordinateinverseQuantityName);
    return quantity;
}

bool PSDatasetLinearInverseSetMaximumCoordinate(CFMutableDictionaryRef parameters, PSScalarRef coordinate, PSDatasetRef theDataset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
   	IF_NO_OBJECT_EXISTS_RETURN(coordinate,false);
   	IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    
    PSUnitRef unit = PSDimensionGetRelativeUnit(horizontalDimension);
    
    if(PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(unit), PSQuantityGetUnitDimensionality(coordinate))) {
        
        if(CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateMax)) CFDictionaryReplaceValue(parameters, kPSDatasetLinearInverseCoordinateMax, coordinate);
        else CFDictionaryAddValue(parameters, kPSDatasetLinearInverseCoordinateMax, coordinate);
        return true;
    }
    return false;
}

bool PSDatasetLinearInverseValidateForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef unit = PSQuantityGetUnit( PSDimensionGetInverseSamplingInterval(horizontalDimension));
    //    PSUnitRef unit = PSDimensionGetRelativeUnit(horizontalDimension);

    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseModelCoordinateSpacing)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateMin)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateMax)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseNumberOfSamples)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateQuantity)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetLinearInverseCoordinateinverseQuantityName)) return false;
    
    PSScalarRef minimumCoordinate = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseCoordinateMin);
    if(!PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(unit), PSQuantityGetUnitDimensionality(minimumCoordinate))) return false;
    
    PSScalarRef maximumCoordinate = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseCoordinateMax);
    if(!PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(unit), PSQuantityGetUnitDimensionality(maximumCoordinate))) return false;
    
    CFNumberRef theNumberOfSamples = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetLinearInverseNumberOfSamples);
    CFIndex numberOfSamples;
    CFNumberGetValue(theNumberOfSamples, kCFNumberCFIndexType, &numberOfSamples);
    CFIndex npts = PSDimensionGetNpts(horizontalDimension);

    if(numberOfSamples<2 || numberOfSamples>npts) return false;

    return true;
}

PSDimensionRef PSDatasetLinearInverseCreateModelDimension(CFDictionaryRef parameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    
    PSDimensionRef modelDimension = NULL;
    unsigned int n = (unsigned int) PSDatasetLinearInverseGetNumberOfSamples(parameters);
    PSScalarRef minimum = PSDatasetLinearInverseGetMinimumCoordinate(parameters);
    PSScalarRef maximum = PSDatasetLinearInverseGetMaximumCoordinate(parameters);
    PSUnitRef commonUnit = PSQuantityGetUnit(minimum);
    
    switch(PSDatasetLinearInverseGetKernelType(parameters)) {
        case kPSDatasetInverseLaplace1DExponential: {
            bool success = true;
            double Tstart = PSScalarDoubleValueInUnit(minimum, commonUnit, &success);
            double Tend = PSScalarDoubleValueInUnit(maximum, commonUnit, &success);
            
            switch(PSDatasetLinearInverseGetCoordinateSpacing(parameters)) {
                case kPSDatasetLinearCoordinate: {
                    modelDimension = PSDimensionCreateWithNptsAndLimits(n, minimum, maximum,  error);
                    break;
                }
                case kPSDatasetLogCoordinate: {
                    double logTstart = log10(Tstart);
                    double logTend = log10(Tend);
                    PSScalarRef lowerLimit = PSScalarCreateWithDouble(logTstart, NULL);
                    PSScalarRef upperLimit = PSScalarCreateWithDouble(logTend, NULL);
                    modelDimension = PSDimensionCreateWithNptsAndLimits(n, lowerLimit, upperLimit,  error);
                    CFStringRef unitSymbol = PSUnitCopySymbol(commonUnit);
                    CFStringRef label = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("log(T2/%@)"),unitSymbol);
                    PSDimensionSetLabel(modelDimension, label);
                    CFStringRef inverseLabel = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("log(R2/%@)"),unitSymbol);
                    PSDimensionSetInverseLabel(modelDimension, inverseLabel);
                    CFRelease(lowerLimit);
                    CFRelease(upperLimit);
                    CFRelease(unitSymbol);
                    CFRelease(label);
                    CFRelease(inverseLabel);
                    break;
                }
            }
        }
    }
    return modelDimension;
}

CFArrayRef PSDatasetLinearInverseCreateKernelDimensions(PSDatasetRef theDataset, CFDictionaryRef parameters, CFErrorRef *error)
{
    CFMutableArrayRef kernelDimensions = CFArrayCreateMutable(kCFAllocatorDefault, 2, &kCFTypeArrayCallBacks);
    PSDimensionRef dataDimension = PSDimensionCreateCopy(PSDatasetHorizontalDimension(theDataset), error);
    CFArrayAppendValue(kernelDimensions, dataDimension);
    CFRelease(dataDimension);
    
    PSDimensionRef modelDimension = PSDatasetLinearInverseCreateModelDimension(parameters, error);
    CFArrayInsertValueAtIndex(kernelDimensions, 0, modelDimension);
    CFRelease(modelDimension);
    return kernelDimensions;
}

OCMatrixRef PSDatasetLinearInverseCreateKernelMatrix(numberType type, CFDictionaryRef parameters, CFArrayRef dimensions, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    OCMatrixRef kernelMatrix = NULL;
    
    PSDimensionRef modelDimension = CFArrayGetValueAtIndex(dimensions, 0);
    PSDimensionRef dataDimension = CFArrayGetValueAtIndex(dimensions, 1);
    unsigned int n = (unsigned int) PSDimensionGetNpts(modelDimension);
    unsigned int m = (unsigned int) PSDimensionGetNpts(dataDimension);
    switch(PSDatasetLinearInverseGetKernelType(parameters)) {
        case kPSDatasetInverseLaplace1DExponential: {
            OCMatrixRef T = NULL;
            switch(PSDatasetLinearInverseGetCoordinateSpacing(parameters)) {
                case kPSDatasetLinearCoordinate: {
                    void *_T = PSDimensionCreateVectorOfRelativeCoordinates(type, modelDimension, error);
                    T = OCMatrixCreateWithArray(type,CFSTR("T"), _T, n, 1);
                    break;
                }
                case kPSDatasetLogCoordinate: {
                    double *_logT = PSDimensionCreateVectorOfRelativeCoordinates(kPSNumberFloat64Type, modelDimension, error);
                    T = OCMatrixCreate(type,CFSTR("T"), n, 1);
                    switch(type) {
                        case kPSNumberFloat32Type: {
                            float *_T = OCMatrixGetDataPointer(T);
                            for(int i=0;i<n;i++) _T[i] = powf(10,_logT[i]);
                            break;
                        }
                        case kPSNumberFloat64Type: {
                            double *_T = OCMatrixGetDataPointer(T);
                            for(int i=0;i<n;i++) _T[i] = pow(10,_logT[i]);
                            break;
                        }
                        case kPSNumberFloat32ComplexType: {
                            float complex *_T = OCMatrixGetDataPointer(T);
                            for(int i=0;i<n;i++) _T[i] = powf(10,_logT[i]);
                            break;
                        }
                        case kPSNumberFloat64ComplexType: {
                            double complex *_T = OCMatrixGetDataPointer(T);
                            for(int i=0;i<n;i++) _T[i] = pow(10,_logT[i]);
                            break;
                        }
                    }
                    free(_logT);
                    break;
                }
            }
            
            void *array = PSDimensionCreateVectorOfRelativeCoordinates(type, dataDimension, error);
            OCMatrixRef x = OCMatrixCreateWithArray(type,CFSTR("x"), array, m, 1);
            free(array);
            
            kernelMatrix = OCMatrixCreate(type,CFSTR("kernel matrix"), m, n);
            switch (type) {
                case kPSNumberFloat32Type: {
                    float *_x  = OCMatrixGetDataPointer(x);
                    float *_T = OCMatrixGetDataPointer(T);
                    float (*_A)[n] = (float (*)[n]) OCMatrixGetDataPointer(kernelMatrix);
                    for(unsigned int i=0;i<m;i++) {
                        for(unsigned int j=0;j<n;j++) {
                            _A[i][j] = expf(-_x[i]/_T[j]);
                        }
                    }
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *_x  = OCMatrixGetDataPointer(x);
                    double *_T = OCMatrixGetDataPointer(T);
                    double (*_A)[n] = (double (*)[n]) OCMatrixGetDataPointer(kernelMatrix);
                    for(unsigned int i=0;i<m;i++) {
                        for(unsigned int j=0;j<n;j++) {
                            _A[i][j] = expf(-_x[i]/_T[j]);
                        }
                    }
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *_x  = OCMatrixGetDataPointer(x);
                    float complex *_T = OCMatrixGetDataPointer(T);
                    float complex (*_A)[n] = (float complex (*)[n]) OCMatrixGetDataPointer(kernelMatrix);
                    for(unsigned int i=0;i<m;i++) {
                        for(unsigned int j=0;j<n;j++) {
                            _A[i][j] = expf(-_x[i]/_T[j]);
                        }
                    }
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *_x  = OCMatrixGetDataPointer(x);
                    double complex *_T = OCMatrixGetDataPointer(T);
                    double complex (*_A)[n] = (double complex (*)[n]) OCMatrixGetDataPointer(kernelMatrix);
                    for(unsigned int i=0;i<m;i++) {
                        for(unsigned int j=0;j<n;j++) {
                            _A[i][j] = expf(-_x[i]/_T[j]);
                        }
                    }
                    break;
                }
            }
            CFRelease(x);
        }
    }
    return kernelMatrix;
}

PSDatasetRef PSDatasetLinearInverseCreateKernelDatasetFromMatrix(OCMatrixRef kernelMatrix, CFArrayRef kernelDimensions, PSDatasetRef theDataset, CFErrorRef *error)
{
    
    CFDataRef kernelData = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) OCMatrixGetDataPointer(kernelMatrix), PSNumberTypeElementSize(OCMatrixGetElementType(kernelMatrix))*OCMatrixGetSize(kernelMatrix));
    PSDependentVariableRef kernelSignal = PSDependentVariableCreate(NULL,
                                              OCMatrixGetElementType(kernelMatrix),
                                              kernelData,
                                              NULL,
                                              NULL,
                                              CFSTR("kernel"));
    CFRelease(kernelData);
    
    bool releaseDimensions = false;
    if(kernelDimensions==NULL) {
        releaseDimensions = true;
        CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 2, &kCFTypeArrayCallBacks);
        PSScalarRef samplingInterval = PSScalarCreateWithDouble(1, NULL);
        PSDimensionRef horizontalDimension = PSDimensionCreateWithNptsAndSamplingInterval(OCMatrixGetNumberOfRows(kernelMatrix),samplingInterval,error);
        CFArrayAppendValue(dimensions, horizontalDimension);
        CFRelease(horizontalDimension);
        PSDimensionRef verticalDimension = PSDimensionCreateWithNptsAndSamplingInterval(OCMatrixGetNumberOfColumns(kernelMatrix),samplingInterval,error);
        CFArrayAppendValue(dimensions, verticalDimension);
        CFRelease(verticalDimension);
        CFRelease(samplingInterval);
        kernelDimensions = (CFArrayRef) dimensions;
    }
    PSDatasetRef kernelDataset = PSDatasetCreateWithSignalNoCopy(kernelSignal,
                                                                 PSDatasetGetSignalCoordinatesQuantities(theDataset),
                                                                 kernelDimensions,
                                                                 NULL,
                                                                 PSDatasetGetresponseQuantityName(theDataset),
                                                                 PSDatasetGetQuantityType(theDataset),
                                                                 PSDatasetGetResponseName(theDataset),
                                                                 CFSTR("Kernel"),
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 error);
    if(releaseDimensions) CFRelease(kernelDimensions);
    
    CFRelease(kernelSignal);
    return kernelDataset;
}

PSDatasetRef PSDatasetLinearInverseCreateSingularValuesDataset(OCMatrixRef singularValues, CFErrorRef *error)
{
    OCMatrixRef copy = OCMatrixCreateCopy(singularValues);
    OCMatrixTakeLog10OfElements(copy);
    void *_singularValues = OCMatrixGetDataPointer(copy);
    CFDataRef singularValuesData = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) _singularValues, PSNumberTypeElementSize(OCMatrixGetElementType(singularValues))*OCMatrixGetSize(singularValues));
    
    PSDependentVariableRef singularValuesSignal = PSDependentVariableCreate(NULL,
                                                      OCMatrixGetElementType(singularValues),
                                                      singularValuesData,
                                                      NULL,
                                                      NULL,
                                                      CFSTR("singular Values"));
    CFRelease(singularValuesData);
    PSScalarRef samplingInterval = PSScalarCreateWithDouble(1, NULL);
    PSDimensionRef singularValueDimension = PSDimensionCreateWithNptsAndSamplingInterval(OCMatrixGetSize(singularValues),samplingInterval,error);
    CFRelease(samplingInterval);
    
    CFMutableArrayRef singularValueDimensions = CFArrayCreateMutable(kCFAllocatorDefault, 1, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(singularValueDimensions, singularValueDimension);
    CFRelease(singularValueDimension);
    
    PSDatasetRef singularValuesDataset = PSDatasetCreateWithSignalNoCopy(singularValuesSignal,
                                                                         NULL,
                                                                         singularValueDimensions,
                                                                         NULL,
                                                                         NULL,
                                                                         CFSTR("scalar"),
                                                                         CFSTR("Log(Singular Values)"),
                                                                         CFSTR("Log(Singular Values)"),
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         error);
    
    CFRelease(singularValuesSignal);
    CFRelease(copy);
    return singularValuesDataset;

}

// Needs to be updated for all element types
PSDatasetRef PSDatasetLinearInverseCreateCompressedDataset(PSDatasetRef theDataset, OCMatrixRef Ut, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(Ut,NULL);
    
    OCMatrixRef UtCopy = OCMatrixCreateCopy(Ut);
    
    PSScalarRef samplingInterval = PSScalarCreateWithDouble(1, NULL);
    unsigned int compressedNpts = OCMatrixGetNumberOfRows(Ut);
    PSDimensionRef reducedDimension = PSDimensionCreateWithNptsAndSamplingInterval(compressedNpts,samplingInterval,error);
    CFRelease(samplingInterval);
    
    CFIndex numberOfDimensions = PSDatasetDimensionsCount(theDataset);
    unsigned int uncompressedNpts = (unsigned int)PSDimensionGetNpts(PSDatasetHorizontalDimension(theDataset));
    CFIndex dataDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex reducedDimensionIndex = dataDimensionIndex;
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFMutableArrayRef newDimensions = PSDatasetDimensionsMutableCopy(theDataset, error);
    CFArrayRemoveValueAtIndex(newDimensions, dataDimensionIndex);
    CFArrayInsertValueAtIndex(newDimensions, dataDimensionIndex, reducedDimension);
    
    CFIndex *oldNpts = calloc(sizeof(CFIndex), numberOfDimensions);
    for(CFIndex idim = 0; idim<numberOfDimensions; idim++) oldNpts[idim] = PSDimensionGetNpts(CFArrayGetValueAtIndex(dimensions,idim));
    vDSP_Length oldLength = oldNpts[dataDimensionIndex];
    vDSP_Stride oldStride = strideAlongDimensionIndex(oldNpts, numberOfDimensions, dataDimensionIndex);
    
    CFIndex *newNpts = calloc(sizeof(CFIndex), numberOfDimensions);
    for(CFIndex idim = 0; idim<numberOfDimensions; idim++) newNpts[idim] = PSDimensionGetNpts(CFArrayGetValueAtIndex(newDimensions,idim));
    vDSP_Length newLength = newNpts[reducedDimensionIndex];
    vDSP_Stride newStride = strideAlongDimensionIndex(newNpts, numberOfDimensions, reducedDimensionIndex);
    
    CFMutableArrayRef signals = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex< PSDatasetDependentVariablesCount(theDataset); dependentVariableIndex++) {
        PSDependentVariableRef oldSignal = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        CFIndex oldSize = PSDependentVariableSize(oldSignal);
        CFIndex reducedSize = oldSize/uncompressedNpts;
        PSDependentVariableRef newSignal = PSDependentVariableCreateCopy(oldSignal);
        PSDependentVariableSetSize(newSignal, reducedSize*compressedNpts);
        
        float *oldResponses = (float *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(oldSignal));
        float *newResponses = (float *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(newSignal));
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        OCMatrixSetElementType(UtCopy, kPSNumberFloat32Type);
        dispatch_apply(reducedSize, queue,
                       ^(size_t reducedMemOffset) {
                           CFIndex oldIndexes[numberOfDimensions];
                           oldIndexes[dataDimensionIndex] = 0;
                           setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, oldIndexes,numberOfDimensions, oldNpts, dataDimensionIndex);
                           CFIndex oldMemOffset = memOffsetFromIndexes(oldIndexes,numberOfDimensions, oldNpts);
                           
                           CFIndex newIndexes[numberOfDimensions];
                           newIndexes[reducedDimensionIndex] = 0;
                           setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, newIndexes,numberOfDimensions, newNpts, reducedDimensionIndex);
                           CFIndex newMemOffset = memOffsetFromIndexes(newIndexes,numberOfDimensions, newNpts);
                           
                           OCMatrixRef b = OCMatrixCreate(kPSNumberFloat32Type,CFSTR("b"), uncompressedNpts, 1);
                           float *_b = OCMatrixGetDataPointer(b);
                           cblas_scopy((const int) oldLength, &oldResponses[oldMemOffset], (const int) oldStride, _b, 1);
                           OCMatrixRef a = OCMatrixCreateByMultiplying(UtCopy, b);
                           float *_a = OCMatrixGetDataPointer(a);
                           cblas_scopy((const int) newLength, _a, 1,  &newResponses[newMemOffset], (const int) newStride);
                           CFRelease(b);
                           CFRelease(a);
                       }
                       );
        
        CFArrayAppendValue(signals, newSignal);
        CFRelease(newSignal);
    }
    free(newNpts);
    free(oldNpts);
    CFRelease(UtCopy);
    
    PSDatasetRef dataset = PSDatasetCreate(signals,
                                           PSDatasetGetSignalCoordinatesQuantities(theDataset),
                                           newDimensions,
                                           PSDatasetGetDimensionPrecedence(theDataset),
                                           PSDatasetGetresponseQuantityName(theDataset),
                                           PSDatasetGetQuantityType(theDataset),
                                           PSDatasetGetResponseName(theDataset),
                                           CFSTR("Compressed Dataset"),
                                           PSDatasetGetDescription(theDataset),
                                           NULL,
                                           NULL,
                                           PSDatasetGetPlot(theDataset),
                                           NULL,
                                           NULL,
                                           PSDatasetGetOperations(theDataset),
                                           PSDatasetGetMetaData(theDataset),error);
    CFRelease(newDimensions);
    return dataset;
    
}

// Needs to be updated for all element types
PSDatasetRef PSDatasetLinearInverseCreateUncompressedDataset(PSDatasetRef theDataset, PSDimensionRef uncompressedDimension, OCMatrixRef U, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(U,NULL);
    
    OCMatrixRef UCopy = OCMatrixCreateCopy(U);

    CFIndex numberOfDimensions = PSDatasetDimensionsCount(theDataset);
    unsigned int compressedNpts = (unsigned int)PSDimensionGetNpts(PSDatasetHorizontalDimension(theDataset));
    CFIndex dataDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex reducedDimensionIndex = dataDimensionIndex;
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFMutableArrayRef newDimensions = PSDatasetDimensionsMutableCopy(theDataset, error);
    CFArrayRemoveValueAtIndex(newDimensions, dataDimensionIndex);
    unsigned int uncompressedNpts = (unsigned int) PSDimensionGetNpts(uncompressedDimension);
    PSDimensionRef newDimension = PSDimensionCreateCopy(uncompressedDimension, error);
    CFArrayInsertValueAtIndex(newDimensions, dataDimensionIndex, newDimension);
    
    CFIndex *oldNpts = calloc(sizeof(CFIndex), numberOfDimensions);
    for(CFIndex idim = 0; idim<numberOfDimensions; idim++) oldNpts[idim] = PSDimensionGetNpts(CFArrayGetValueAtIndex(dimensions,idim));
    vDSP_Length oldLength = oldNpts[dataDimensionIndex];
    vDSP_Stride oldStride = strideAlongDimensionIndex(oldNpts, numberOfDimensions, dataDimensionIndex);
    
    CFIndex *newNpts = calloc(sizeof(CFIndex), numberOfDimensions);
    for(CFIndex idim = 0; idim<numberOfDimensions; idim++) newNpts[idim] = PSDimensionGetNpts(CFArrayGetValueAtIndex(newDimensions,idim));
    vDSP_Length newLength = newNpts[reducedDimensionIndex];
    vDSP_Stride newStride = strideAlongDimensionIndex(newNpts, numberOfDimensions, reducedDimensionIndex);
    
    OCMatrixSetElementType(UCopy, kPSNumberFloat32Type);

    CFMutableArrayRef signals = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex< PSDatasetDependentVariablesCount(theDataset); dependentVariableIndex++) {
        PSDependentVariableRef oldSignal = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        CFIndex oldSize = PSDependentVariableSize(oldSignal);
        CFIndex reducedSize = oldSize/compressedNpts;
        PSDependentVariableRef newSignal = PSDependentVariableCreateCopy(oldSignal);
        PSDependentVariableSetSize(newSignal, reducedSize*uncompressedNpts);
        
        float *oldResponses = (float *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(oldSignal));
        float *newResponses = (float *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(newSignal));
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_apply(reducedSize, queue,
                       ^(size_t reducedMemOffset) {
                           CFIndex oldIndexes[numberOfDimensions];
                           oldIndexes[dataDimensionIndex] = 0;
                           setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, oldIndexes,numberOfDimensions, oldNpts, dataDimensionIndex);
                           CFIndex oldMemOffset = memOffsetFromIndexes(oldIndexes,numberOfDimensions, oldNpts);
                           
                           CFIndex newIndexes[numberOfDimensions];
                           newIndexes[reducedDimensionIndex] = 0;
                           setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, newIndexes,numberOfDimensions, newNpts, reducedDimensionIndex);
                           CFIndex newMemOffset = memOffsetFromIndexes(newIndexes,numberOfDimensions, newNpts);
                           
                           OCMatrixRef b = OCMatrixCreate(kPSNumberFloat32Type,CFSTR("b"), compressedNpts, 1);
                           float *_b = OCMatrixGetDataPointer(b);
                           cblas_scopy((const int) oldLength, &oldResponses[oldMemOffset], (const int) oldStride, _b, 1);
                           OCMatrixRef a = OCMatrixCreateByMultiplying(UCopy, b);
                           float *_a = OCMatrixGetDataPointer(a);
                           cblas_scopy((const int) newLength, _a, 1,  &newResponses[newMemOffset], (const int) newStride);
                           CFRelease(b);
                           CFRelease(a);
                       }
                       );
        
        CFArrayAppendValue(signals, newSignal);
        CFRelease(newSignal);
    }
    free(newNpts);
    free(oldNpts);
    CFRelease(UCopy);

    PSDatasetRef dataset = PSDatasetCreate(signals,
                                           PSDatasetGetSignalCoordinatesQuantities(theDataset),
                                           newDimensions,
                                           PSDatasetGetDimensionPrecedence(theDataset),
                                           PSDatasetGetresponseQuantityName(theDataset),
                                           PSDatasetGetQuantityType(theDataset),
                                           PSDatasetGetResponseName(theDataset),
                                           CFSTR("Uncompressed Dataset"),
                                           PSDatasetGetDescription(theDataset),
                                           NULL,
                                           NULL,
                                           PSDatasetGetPlot(theDataset),
                                           NULL,
                                           NULL,
                                           PSDatasetGetOperations(theDataset),
                                           PSDatasetGetMetaData(theDataset),error);
    CFRelease(newDimensions);
    return dataset;
    
}

// Needs to be updated for all element types
CFArrayRef PSDatasetLinearInverseCreateKernelAndSingularValuesDatasets(PSDatasetRef theDataset, CFDictionaryRef parameters,  CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    
    CFMutableArrayRef datasets = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    numberType type = PSDatasetGetElementType(theDataset);
    CFArrayRef kernelDimensions = PSDatasetLinearInverseCreateKernelDimensions(theDataset, parameters,error);
    OCMatrixRef theKernel = PSDatasetLinearInverseCreateKernelMatrix(type,parameters,kernelDimensions,error);
    
    {
        PSDatasetRef kernelDataset = PSDatasetLinearInverseCreateKernelDatasetFromMatrix(theKernel, kernelDimensions, theDataset, error);
        CFArrayAppendValue(datasets, kernelDataset);
        CFRelease(kernelDataset);
    }
    unsigned int m = (unsigned int) OCMatrixGetNumberOfRows(theKernel);
    unsigned int n = (unsigned int) OCMatrixGetNumberOfColumns(theKernel);
    OCMatrixRef U = OCMatrixCreate(kPSNumberFloat64Type, CFSTR("U"), m, m);
    OCMatrixRef Vt = OCMatrixCreate(kPSNumberFloat64Type,CFSTR("U"), n, n);
    OCMatrixRef singularValues = OCMatrixCreateSingularValuesWithSVD(theKernel, U, Vt);
    OCMatrixRef singularMatrix = OCMatrixCreateWithDiagonal(NULL, singularValues, m, n);
    
    {
        PSDatasetRef singularValuesDataset = PSDatasetLinearInverseCreateSingularValuesDataset(singularValues,error);
        CFArrayAppendValue(datasets, singularValuesDataset);
        CFRelease(singularValuesDataset);
    }
    unsigned int r = OCMatrixMaximumEntropySVDTruncationIndex(singularValues, m, n);
    OCMatrixTruncate(U,m,r);
    OCMatrixTruncate(Vt,r,n);
    OCMatrixTruncate(singularMatrix,r,r);
    OCMatrixRef reducedKernel = OCMatrixCreateByMultiplying(singularMatrix,Vt);
    
    {
        PSDatasetRef reducedKernelDataset = PSDatasetLinearInverseCreateKernelDatasetFromMatrix(reducedKernel, NULL, theDataset, error);
        CFArrayAppendValue(datasets, reducedKernelDataset);
        CFRelease(reducedKernelDataset);
    }
    
    OCMatrixRef Ut = OCMatrixCreateByTransposing(U);
    PSDatasetRef compressedDataset = PSDatasetLinearInverseCreateCompressedDataset(theDataset, Ut, error);
    {
        CFArrayAppendValue(datasets, compressedDataset);
        PSDatasetRef uncompressedDataset = PSDatasetLinearInverseCreateUncompressedDataset(compressedDataset, PSDatasetHorizontalDimension(theDataset), U, error);
        CFArrayAppendValue(datasets, uncompressedDataset);
        CFRelease(uncompressedDataset);
    }
    CFRelease(compressedDataset);
    
    {
        CFNumberRef maxEnt = PSCFNumberCreateWithCFIndex(r);
        CFArrayInsertValueAtIndex(datasets,0, maxEnt);
        CFRelease(maxEnt);
    }
    return datasets;
}

CFArrayRef PSDatasetLinearInverseCreateDatasetFromDataset(PSDatasetRef theDataset, CFDictionaryRef parameters,  CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    
    numberType type = PSDatasetGetElementType(theDataset);
    CFArrayRef kernelDimensions = PSDatasetLinearInverseCreateKernelDimensions(theDataset, parameters,error);
    OCMatrixRef theKernel = PSDatasetLinearInverseCreateKernelMatrix(type,parameters,kernelDimensions,error);

    unsigned int m = (unsigned int) OCMatrixGetNumberOfRows(theKernel);
    unsigned int n = (unsigned int) OCMatrixGetNumberOfColumns(theKernel);
    
    double sigma_y = PSScalarDoubleValue(PSDatasetLinearInverseGetNoiseStandardDeviation(parameters));
    float lambda = PSScalarFloatValue(PSDatasetLinearInverseGetLambda(parameters));
    linearInverseAlgorithm algorithm = PSDatasetLinearInverseGetAlgorithm(parameters);
    
    // if necessary move transpose least-squares dimension to be 0th dimension
    PSDatasetRef transposedDataset = NULL;
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    if(horizontalDimensionIndex==0) transposedDataset = theDataset;
    else transposedDataset = PSDatasetCreateByTransposingDimensions(theDataset, horizontalDimensionIndex, 0, error);

    CFMutableArrayRef modelSignals = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef dataSignals = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex< PSDatasetDependentVariablesCount(transposedDataset); dependentVariableIndex++) {
        PSDependentVariableRef signal = PSDatasetGetDependentVariableAtIndex(transposedDataset, dependentVariableIndex);
        CFIndex size = PSDependentVariableSize(signal);
        unsigned int numberOfRightHandSides = (unsigned int) size/m;
        void *responses = CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(signal));
        
        OCMatrixRef y = OCMatrixCreateWithArray(PSQuantityGetElementType(signal), NULL, responses, m, numberOfRightHandSides);
        OCMatrixRef bestFit = OCMatrixCreate(PSQuantityGetElementType(signal), CFSTR("bestFit"), m, numberOfRightHandSides);
        OCMatrixRef residuals = OCMatrixCreate(PSQuantityGetElementType(signal), CFSTR("residuals"), m, numberOfRightHandSides);
        
        OCMatrixRef model = NULL;
        switch(algorithm) {
            case kPSDatasetLinearInverseL2NormRidgeRegression: {
                model = OCMatrixCreateLinearLeastSquaresSolution(theKernel,y,sigma_y,bestFit,residuals, kOCMatrixRegularizationFirstDifference, lambda);
                break;
            }
            case kPSDatasetLinearInverseL2NormFirstDerivative: {
                model = OCMatrixCreateLinearLeastSquaresSolution(theKernel,y,sigma_y,bestFit,residuals, kOCMatrixRegularizationFirstDifference, lambda);
                break;

            }
            case kPSDatasetLinearInverseL2NormSecondDerivative: {
                model = OCMatrixCreateLinearLeastSquaresSolution(theKernel,y,sigma_y,bestFit,residuals, kOCMatrixRegularizationSecondDifference, lambda);
                break;

            }
        }
        

        {
            // Add in actual signal
            CFDataRef actualData = CFDataCreate(kCFAllocatorDefault, OCMatrixGetDataPointer(y), size*PSNumberTypeElementSize(OCMatrixGetElementType(y)));
            PSDependentVariableRef actualSignal = PSDependentVariableCreate(PSQuantityGetUnit(signal),
                                                          type,
                                                          actualData,
                                                          PSDependentVariableGetMetaCoordinates(signal),
                                                          PSDependentVariableGetName(signal));
            CFRelease(actualData);
            
            CFArrayAppendValue(dataSignals, actualSignal);
            CFRelease(actualSignal);
            
            // Add in best fit signal
            CFDataRef bestFitData = CFDataCreate(kCFAllocatorDefault, OCMatrixGetDataPointer(bestFit), size*PSNumberTypeElementSize(OCMatrixGetElementType(bestFit)));
            CFStringRef updatedName = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@--%@"),PSDependentVariableGetName(signal),CFSTR("best fit"));
            PSDependentVariableRef bestFitSignal = PSDependentVariableCreate(PSQuantityGetUnit(signal),
                                                       type,
                                                       bestFitData,
                                                       PSDependentVariableGetMetaCoordinates(signal),
                                                       updatedName);
            CFRelease(bestFitData);
            CFRelease(updatedName);

            CFArrayAppendValue(dataSignals, bestFitSignal);
            CFRelease(bestFitSignal);
            
            // Add in residuals signal
            CFDataRef residualsData = CFDataCreate(kCFAllocatorDefault, OCMatrixGetDataPointer(residuals), size*PSNumberTypeElementSize(OCMatrixGetElementType(residuals)));
            updatedName = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@--%@"),PSDependentVariableGetName(signal),CFSTR("residuals"));
            PSDependentVariableRef residualsSignal = PSDependentVariableCreate(PSQuantityGetUnit(signal),
                                                       type,
                                                       residualsData,
                                                       PSDependentVariableGetMetaCoordinates(signal),
                                                       updatedName);
            CFRelease(residualsData);
            CFRelease(updatedName);
            
            CFArrayAppendValue(dataSignals, residualsSignal);
            CFRelease(residualsSignal);

        }
        {
            CFIndex newSize = numberOfRightHandSides*n;
            CFDataRef modelData = CFDataCreate(kCFAllocatorDefault, OCMatrixGetDataPointer(model), newSize*PSNumberTypeElementSize(OCMatrixGetElementType(model)));
            PSDependentVariableRef modelSignal = PSDependentVariableCreate(PSQuantityGetUnit(signal),
                                                     type,
                                                     modelData,
                                                     PSDependentVariableGetMetaCoordinates(signal),
                                                     PSDependentVariableGetName(signal));
            CFRelease(modelData);
            
            CFArrayAppendValue(modelSignals, modelSignal);
            CFRelease(modelSignal);
        }
        CFRelease(y);
        CFRelease(bestFit);
        CFRelease(residuals);
        CFRelease(model);

    }
    CFRelease(theKernel);
    
    CFMutableArrayRef modelDimensions = PSDatasetDimensionsMutableCopy(transposedDataset, error);
    CFArrayRemoveValueAtIndex(modelDimensions, 0);
    CFArrayInsertValueAtIndex(modelDimensions, 0, CFArrayGetValueAtIndex(kernelDimensions, 0));
    CFRelease(kernelDimensions);
    PSDatasetRef modelDataset = PSDatasetCreate(modelSignals,
                                                PSDatasetGetSignalCoordinatesQuantities(theDataset),
                                                modelDimensions,
                                                PSDatasetGetDimensionPrecedence(theDataset),
                                                PSDatasetGetresponseQuantityName(theDataset),
                                                PSDatasetGetQuantityType(theDataset),
                                                PSDatasetGetResponseName(theDataset),
                                                PSDatasetGetTitle(theDataset),
                                                PSDatasetGetDescription(theDataset),
                                                NULL,
                                                NULL,
                                               PSDatasetGetPlot(theDataset),
                                                NULL,
                                                NULL,
                                                PSDatasetGetOperations(theDataset),
                                                PSDatasetGetMetaData(theDataset),error);
    CFRelease(modelDimensions);
    
    CFMutableArrayRef originalDimensions = PSDatasetDimensionsMutableCopy(theDataset, error);
    if(horizontalDimensionIndex!=0) CFArrayExchangeValuesAtIndices(originalDimensions, horizontalDimensionIndex, 0);

    PSDatasetRef originalDataset = PSDatasetCreate(dataSignals,
                                                   PSDatasetGetSignalCoordinatesQuantities(theDataset),
                                                   originalDimensions,
                                                   PSDatasetGetDimensionPrecedence(theDataset),
                                                   PSDatasetGetresponseQuantityName(theDataset),
                                                   PSDatasetGetQuantityType(theDataset),
                                                   PSDatasetGetResponseName(theDataset),
                                                   PSDatasetGetTitle(theDataset),
                                                   PSDatasetGetDescription(theDataset),
                                                   NULL,
                                                   NULL,
                                                  PSDatasetGetPlot(theDataset),
                                                   NULL,
                                                   NULL,
                                                   PSDatasetGetOperations(theDataset),
                                                   PSDatasetGetMetaData(theDataset),error);
    CFStringRef updatedTitle = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@-Linear Inversion-Lambda=%f"),PSDatasetGetTitle(theDataset),lambda);
    PSDatasetSetTitle(originalDataset,updatedTitle);
    PSDatasetSetTitle(modelDataset,updatedTitle);
    CFRelease(updatedTitle);
    CFRelease(originalDimensions);

    for(CFIndex index=0;index<PSDatasetDependentVariablesCount(originalDataset)/3; index++) {
        PSPlotSetComponentColorAtIndex(PSDatasetGetPlot(originalDataset),index, kPSPlotColorBlack);
        PSPlotSetComponentColorAtIndex(PSDatasetGetPlot(originalDataset),index+1, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(PSDatasetGetPlot(originalDataset),index+2, kPSPlotColorRed);
    }

    if(horizontalDimensionIndex!=0) {
        CFRelease(transposedDataset);
        PSDatasetRef transposedModelDataset = PSDatasetCreateByTransposingDimensions(modelDataset, horizontalDimensionIndex, 0, error);
        CFRelease(modelDataset);
        modelDataset = transposedModelDataset;

        PSDatasetRef transposedOriginalDataset = PSDatasetCreateByTransposingDimensions(originalDataset, horizontalDimensionIndex, 0, error);
        CFRelease(originalDataset);
        originalDataset = transposedOriginalDataset;
    }
    
    PSPlotReset(PSDatasetGetPlot(originalDataset),error);
    PSPlotReset(PSDatasetGetPlot(modelDataset),error);

    PSDatasetRef results[2] = {originalDataset,modelDataset};
    CFArrayRef arrayOfResults = CFArrayCreate(kCFAllocatorDefault, (const void **) results, 2, &kCFTypeArrayCallBacks);
    return arrayOfResults;
}


