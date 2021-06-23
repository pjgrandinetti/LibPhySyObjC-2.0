//
//  PSDatasetApodizeSinc.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizeSincMinimumNumberOfDimensions()
{
    return 1;
}

CFMutableDictionaryRef PSDatasetApodizeSincCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSDimensionRef inverseHorizontalDimension = PSDimensionCreateCopy(PSDatasetHorizontalDimension(theDataset));
    PSDimensionInverse(inverseHorizontalDimension,error);
    PSScalarRef bandWidth = PSDimensionCreateRelativeCoordinateFromIndex(inverseHorizontalDimension, PSDimensionHighestIndex(inverseHorizontalDimension));
    CFRelease(inverseHorizontalDimension);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeSincBandWidth);
    CFArrayAppendValue(parametersValues, bandWidth);
    CFRelease(bandWidth);

    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}

bool PSDatasetApodizeSincValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(functionParameters,false);
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    if(CFArrayGetCount(parametersValues) != 1) return false;
    PSScalarRef bandWidth = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef unit = PSQuantityGetUnit(PSDimensionGetInverseIncrement(horizontalDimension));
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) bandWidth),
                                                     PSUnitGetDimensionality(unit))) return false;
    return true;
}

CFStringRef PSDatasetApodizeSincGetParameterNameAtIndex(CFIndex index)
{
    if(index==0) return kPSDatasetApodizeSincBandWidth;
    return NULL;
}

static PSDependentVariableRef PSDatasetApodizeSincCreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    PSScalarRef bandWidth = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef inverseHorizontalDimension = PSDimensionCreateCopy(horizontalDimension);
    PSDimensionInverse(inverseHorizontalDimension,error);
    PSUnitRef unit = PSDimensionGetRelativeUnit(inverseHorizontalDimension);

    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) bandWidth),
                                                     PSUnitGetDimensionality(unit))) return NULL;
    
    
    double bandWidthValue = PSScalarDoubleValueInUnit(bandWidth, unit, NULL);
    
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    
    __block float *function1D = malloc(sizeof(float)*horizontalDimensionNpts);
    vDSP_vclr(function1D, 1, horizontalDimensionNpts);
    float *coordinates = PSDimensionCreateFloatVectorOfDisplayedCoordinates(horizontalDimension);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(horizontalDimensionNpts, queue, 
                   ^(size_t coordinateIndex) {
                       double diff = coordinates[coordinateIndex] * M_PI * bandWidthValue;
                       if(diff!=0.0) function1D[coordinateIndex] = sin(diff)/diff;
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

PSDatasetRef PSDatasetApodizeSincCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizeSincCreateBlock(theDataset, functionParameters,error);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<PSDatasetDependentVariablesCount(output); dependentVariableIndex++) {
        PSDependentVariableRef signal = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dependentVariableIndex);
        PSDependentVariableMultiply(signal, theBlock, error);
    }
    
    CFRelease(theBlock);
    return output;
    
}

