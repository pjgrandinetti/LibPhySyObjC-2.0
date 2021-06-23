//
//  PSDatasetApodizeStretchedExponential.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizeStretchedExponentialMinimumNumberOfDimensions(void)
{
    return 1;
}

CFMutableDictionaryRef PSDatasetApodizeStretchedExponentialCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSScalarRef timeConstant = PSScalarCreateWithDouble(0.0, PSDimensionGetDisplayedUnit(PSDatasetHorizontalDimension(theDataset)));
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeStretchedExponentialDecayConstant);
    CFArrayAppendValue(parametersValues, timeConstant);
    CFRelease(timeConstant);
    

    PSScalarRef beta = PSScalarCreateWithDouble(1.0, PSUnitDimensionlessAndUnderived());
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeStretchedExponentialBeta);
    CFArrayAppendValue(parametersValues, beta);
    CFRelease(beta);
    
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}

bool PSDatasetApodizeStretchedExponentialValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(functionParameters,false);
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    if(CFArrayGetCount(parametersValues) != 2) return false;

    PSScalarRef timeConstant = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) timeConstant),
                                                     PSDimensionGetDisplayedUnitDimensionality((PSDatasetHorizontalDimension(theDataset))))) return false;

    PSScalarRef beta = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 1);
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality(beta))) return false;
    
    return true;
}

CFStringRef PSDatasetApodizeStretchedExponentialGetParameterNameAtIndex(CFIndex index)
{
    if(index==0) return kPSDatasetApodizeStretchedExponentialDecayConstant;
    if(index==1) return kPSDatasetApodizeStretchedExponentialBeta;
    return NULL;
}

static PSDependentVariableRef PSDatasetApodizeStretchedExponentialCreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    PSScalarRef decayConstant = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    PSScalarRef beta = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 1);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef unit = PSDimensionGetDisplayedUnit(horizontalDimension);
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) decayConstant),
                                                     PSDimensionGetDisplayedUnitDimensionality(horizontalDimension))) return NULL;
    
    float complex decayConst = PSScalarFloatComplexValueInUnit(decayConstant, unit, NULL);
    float complex betaValue = PSScalarFloatComplexValueInCoherentUnit(beta);
    
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    
    __block float *function1D = malloc(sizeof(float)*horizontalDimensionNpts);
    vDSP_vclr(function1D, 1, horizontalDimensionNpts);
    float *coordinates = PSDimensionCreateFloatVectorOfDisplayedCoordinates(horizontalDimension);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(horizontalDimensionNpts, queue,
                   ^(size_t coordinateIndex) {
                       if(decayConst != 0.0) {
                           float horizontalCoordinate = fabsf(coordinates[coordinateIndex]);
                           float ratio = powf(horizontalCoordinate/decayConst, betaValue);
                           function1D[coordinateIndex] = expf(-ratio);
                       }
                       else function1D[coordinateIndex] = 1.0;
                   });
    free(coordinates);

    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    
    PSDependentVariableRef theBlock =  PSDependentVariableCreateWithSize(NULL,NULL,NULL,NULL,CFSTR("scalar"),
                                                                         kPSNumberFloat32Type,
                                                                         NULL,
                                                                         size,
                                                                         NULL,NULL);
    CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theBlock,0);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);

    __block float *multipliers = (float *) CFDataGetMutableBytePtr(values);
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(size, queue,
                   ^(size_t memOffset) {
                       PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions,  memOffset);
                       CFIndex index = PSIndexArrayGetValueAtIndex(coordinateIndexes, horizontalDimensionIndex);
                       multipliers[memOffset] = function1D[index];
                       CFRelease(coordinateIndexes);
                   }
                   );
    free(function1D);
    return theBlock;
}

PSDatasetRef PSDatasetApodizeStretchedExponentialCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizeStretchedExponentialCreateBlock(theDataset, functionParameters,error);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<PSDatasetDependentVariablesCount(output); dependentVariableIndex++) {
        PSDependentVariableRef signal = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dependentVariableIndex);
        PSDependentVariableMultiply(signal, theBlock, error);
    }
    
    CFRelease(theBlock);
    return output;
    
}

