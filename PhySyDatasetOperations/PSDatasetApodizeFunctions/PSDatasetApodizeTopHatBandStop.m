//
//  PSDatasetApodizeTopHatBandStop.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizeTopHatBandStopMinimumNumberOfDimensions()
{
    return 1;
}

CFMutableDictionaryRef PSDatasetApodizeTopHatBandStopCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);

    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    
    PSScalarRef fallingEdge = PSDimensionCreateDisplayedCoordinateFromIndex(horizontalDimension, PSDimensionLowestIndex(horizontalDimension));
    PSScalarRef risingEdge = PSDimensionCreateDisplayedCoordinateFromIndex(horizontalDimension, PSDimensionHighestIndex(horizontalDimension));
    
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeTopHatBandStopFallingEdge);
    CFArrayAppendValue(parametersValues, fallingEdge);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeTopHatBandStopRisingEdge);
    CFArrayAppendValue(parametersValues, risingEdge);
    CFRelease(risingEdge);
    CFRelease(fallingEdge);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}


bool PSDatasetApodizeTopHatBandStopValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(functionParameters,false);
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    if(CFArrayGetCount(parametersValues) != 2) return false;
    
    PSScalarRef fallingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);

    PSScalarRef risingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 1);
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) risingEdge),
                                                     PSDimensionGetDisplayedUnitDimensionality((PSDatasetHorizontalDimension(theDataset))))) return false;
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) fallingEdge),
                                                     PSDimensionGetDisplayedUnitDimensionality((PSDatasetHorizontalDimension(theDataset))))) return false;
    return true;
}

CFStringRef PSDatasetApodizeTopHatBandStopGetParameterNameAtIndex(CFIndex index)
{
    if(index==0) return kPSDatasetApodizeTopHatBandStopFallingEdge;
    if(index==1) return kPSDatasetApodizeTopHatBandStopRisingEdge;
    return NULL;
}

static PSDependentVariableRef PSDatasetApodizeTopHatBandStopCreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    PSScalarRef fallingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    PSScalarRef risingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 1);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef unit = PSDimensionGetDisplayedUnit(horizontalDimension);
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) risingEdge), 
                                                     PSDimensionGetDisplayedUnitDimensionality(horizontalDimension))) return NULL;
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) fallingEdge), 
                                                     PSDimensionGetDisplayedUnitDimensionality(horizontalDimension))) return NULL;
    
    double rise = PSScalarDoubleValueInUnit(risingEdge, unit, NULL);
    double fall = PSScalarDoubleValueInUnit(fallingEdge, unit, NULL);
    
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    
    __block float *function1D = malloc(sizeof(float)*horizontalDimensionNpts);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(horizontalDimensionNpts, queue,
                   ^(size_t index) {
                    function1D[index] = 1;
                   }
                   );

    float *coordinates = PSDimensionCreateFloatVectorOfDisplayedCoordinates(horizontalDimension);
    
    dispatch_apply(horizontalDimensionNpts, queue,
                   ^(size_t coordinateIndex) {
                       if(coordinates[coordinateIndex]>=fall && coordinates[coordinateIndex]<=rise) function1D[coordinateIndex] = 0.0;
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

PSDatasetRef PSDatasetApodizeTopHatBandStopCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizeTopHatBandStopCreateBlock(theDataset, functionParameters,error);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<PSDatasetDependentVariablesCount(output); dependentVariableIndex++) {
        PSDependentVariableRef signal = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dependentVariableIndex);
        PSDependentVariableMultiply(signal, theBlock, error);
    }

    CFRelease(theBlock);
    return output;
    
}

