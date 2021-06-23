//
//  PSDatasetApodizeTriangle.m
//  RMN
//
//  Created by philip on 12/12/15.
//  Copyright © 2015 PhySy. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizeTriangleMinimumNumberOfDimensions()
{
    return 1;
}

CFMutableDictionaryRef PSDatasetApodizeTriangleCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSScalarRef cutoff = PSDimensionCreateDisplayedCoordinateFromIndex(horizontalDimension, PSDimensionHighestIndex(horizontalDimension));
    PSScalarTakeAbsoluteValue((PSMutableScalarRef) cutoff, error);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeTriangleCutoff);
    CFArrayAppendValue(parametersValues, cutoff);
    CFRelease(cutoff);
    
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}

bool PSDatasetApodizeTriangleValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
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

CFStringRef PSDatasetApodizeTriangleGetParameterNameAtIndex(CFIndex index)
{
    if(index==0) return kPSDatasetApodizeTriangleCutoff;
    return NULL;
}

static PSDependentVariableRef PSDatasetApodizeTriangleCreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    PSScalarRef cutoffScalar = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef unit = PSDimensionGetDisplayedUnit(horizontalDimension);
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) cutoffScalar),
                                                     PSDimensionGetDisplayedUnitDimensionality(horizontalDimension))) return NULL;
    double cutoff = PSScalarDoubleValueInUnit(cutoffScalar, unit, NULL);
    
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);

    __block float *function1D = malloc(sizeof(float)*horizontalDimensionNpts);
    vDSP_vclr(function1D, 1, horizontalDimensionNpts);
    float *coordinates = PSDimensionCreateFloatVectorOfDisplayedCoordinates(horizontalDimension);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(horizontalDimensionNpts, queue,
                   ^(size_t coordinateIndex) {
                       float horizontalCoordinate = fabsf(coordinates[coordinateIndex]);
                       if(horizontalCoordinate <=cutoff) function1D[coordinateIndex] =  1 - horizontalCoordinate/cutoff;
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
                   });
    free(function1D);
    return theBlock;
}

PSDatasetRef PSDatasetApodizeTriangleCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizeTriangleCreateBlock(theDataset, functionParameters,error);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<PSDatasetDependentVariablesCount(output); dependentVariableIndex++) {
        PSDependentVariableRef signal = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dependentVariableIndex);
        PSDependentVariableMultiply(signal, theBlock, error);
    }
    
    CFRelease(theBlock);
    return output;
    
}

