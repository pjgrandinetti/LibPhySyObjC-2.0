//
//  PSDatasetApodizeDerivative.c
//  RMN
//
//  Created by philip on 11/3/15.
//  Copyright © 2015 PhySy. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizeDerivativeMinimumNumberOfDimensions(void)
{
    return 1;
}

CFMutableDictionaryRef PSDatasetApodizeDerivativeCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSScalarRef cutoff = PSDimensionCreateDisplayedCoordinateFromIndex(horizontalDimension, PSDimensionHighestIndex(horizontalDimension));
    PSScalarTakeAbsoluteValue((PSMutableScalarRef) cutoff, error);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeDerivativeCutoff);
    CFArrayAppendValue(parametersValues, cutoff);
    CFRelease(cutoff);
    
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}

bool PSDatasetApodizeDerivativeValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(functionParameters,false);
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    if(CFArrayGetCount(parametersValues) != 1) return false;
    
    PSScalarRef cuttoff = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) cuttoff),
                                                     PSDimensionGetDisplayedUnitDimensionality((PSDatasetHorizontalDimension(theDataset))))) return false;
    
    return true;
}

static PSDependentVariableRef PSDatasetApodizeDerivativeCreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    PSScalarRef cutoffScalar = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef unit = PSDimensionGetDisplayedUnit(horizontalDimension);
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) cutoffScalar),
                                                     PSDimensionGetDisplayedUnitDimensionality(horizontalDimension))) return NULL;
    
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    
    double cutoff = PSScalarDoubleValueInUnit(cutoffScalar, unit, NULL);
    
    __block float complex *function1D = malloc(sizeof(float complex)*horizontalDimensionNpts);
    vDSP_vclr((float *) function1D, 1, 2*horizontalDimensionNpts);
    float *coordinates = PSDimensionCreateFloatVectorOfDisplayedCoordinates(horizontalDimension);
    
    float complex constant  = -I*2*M_PI;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(horizontalDimensionNpts, queue,
                   ^(size_t coordinateIndex) {
                       float horizontalCoordinate = fabsf(coordinates[coordinateIndex]);
                       if(fabsf(coordinates[coordinateIndex]) <= fabs(cutoff)) function1D[coordinateIndex] = horizontalCoordinate*constant;
                   });
    

    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    
    PSDependentVariableRef theBlock =  PSDependentVariableCreateWithSize(NULL,NULL,NULL,NULL,CFSTR("scalar"),
                                                                         kPSNumberFloat32ComplexType,
                                                                         NULL,
                                                                         size,
                                                                         NULL,NULL);
    CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theBlock,0);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);

    __block float complex *multipliers = (float complex *) CFDataGetMutableBytePtr(values);
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
    
    free(coordinates);

    return theBlock;
}

PSDatasetRef PSDatasetApodizeDerivativeCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizeDerivativeCreateBlock(theDataset, functionParameters, error);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<PSDatasetDependentVariablesCount(output); dependentVariableIndex++) {
        PSDependentVariableRef signal = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dependentVariableIndex);
        PSDependentVariableMultiply(signal, theBlock, error);
    }
    
    CFRelease(theBlock);
    return output;
    
}
