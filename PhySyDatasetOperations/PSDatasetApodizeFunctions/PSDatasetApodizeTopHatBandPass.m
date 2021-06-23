//
//  PSDatasetApodizeTopHatBandPass.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizeTopHatBandPassMinimumNumberOfDimensions()
{
    return 1;
}

CFMutableDictionaryRef PSDatasetApodizeTopHatBandPassCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);

    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    
    PSScalarRef risingEdge = PSDimensionCreateDisplayedCoordinateFromIndex(horizontalDimension, PSDimensionLowestIndex(horizontalDimension));
    PSScalarRef fallingEdge = PSDimensionCreateDisplayedCoordinateFromIndex(horizontalDimension, PSDimensionHighestIndex(horizontalDimension));
    
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeTopHatBandPassRisingEdge);
    CFArrayAppendValue(parametersValues, risingEdge);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeTopHatBandPassFallingEdge);
    CFArrayAppendValue(parametersValues, fallingEdge);
    CFRelease(risingEdge);
    CFRelease(fallingEdge);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}

bool PSDatasetApodizeTopHatBandPassValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(functionParameters,false);
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    if(CFArrayGetCount(parametersValues) != 2) return false;

    PSScalarRef risingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    PSScalarRef fallingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 1);
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) risingEdge), 
                                                     PSDimensionGetDisplayedUnitDimensionality((PSDatasetHorizontalDimension(theDataset))))) return false;
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) fallingEdge), 
                                                     PSDimensionGetDisplayedUnitDimensionality((PSDatasetHorizontalDimension(theDataset))))) return false;
    return true;
}

CFStringRef PSDatasetApodizeTopHatBandPassGetParameterNameAtIndex(CFIndex index)
{
    if(index==0) return kPSDatasetApodizeTopHatBandPassRisingEdge;
    if(index==1) return kPSDatasetApodizeTopHatBandPassFallingEdge;
    return NULL;
}

static PSDependentVariableRef PSDatasetApodizeTopHatBandPassCreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    PSScalarRef risingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    PSScalarRef fallingEdge = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 1);
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
    vDSP_vclr(function1D, 1, horizontalDimensionNpts);
    float *coordinates = PSDimensionCreateFloatVectorOfDisplayedCoordinates(horizontalDimension);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(horizontalDimensionNpts, queue,
                   ^(size_t coordinateIndex) {
                       if(coordinates[coordinateIndex]>rise && coordinates[coordinateIndex]<fall) function1D[coordinateIndex] = 1.0;
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

PSDatasetRef PSDatasetApodizeTopHatBandPassCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizeTopHatBandPassCreateBlock(theDataset, functionParameters, error);
    if(error) if(*error) {
        if(theBlock) CFRelease(theBlock);
        return NULL;
    }

    if(NULL==theBlock) {
        if(error) {
            CFStringRef desc = CFSTR("Unable to create Top Hat apodization mask.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
        }
        return NULL;
    }
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    if(error) if(*error) {
        if(theBlock) CFRelease(theBlock);
        if(output) CFRelease(output);
        return NULL;
    }

    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<PSDatasetDependentVariablesCount(output); dependentVariableIndex++) {
        PSDependentVariableRef signal = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dependentVariableIndex);
        PSDependentVariableMultiply(signal, theBlock, error);
        if(error) if(*error) {
            if(theBlock) CFRelease(theBlock);
            if(output) CFRelease(output);
            return NULL;
        }

    }

    CFRelease(theBlock);
    return output;
    
}

