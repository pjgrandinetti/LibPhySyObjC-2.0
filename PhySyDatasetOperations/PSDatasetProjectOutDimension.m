//
//  PSDatasetProjectOutDimension.m
//  RMN 2.0
//
//  Created by Philip on 7/4/13.
//  Copyright (c) 2013 PhySy Ltd. All rights reserved.
//


#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetProjectOutDimensionCreateDefaultParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                                  &kCFTypeDictionaryKeyCallBacks,
                                                                  &kCFTypeDictionaryValueCallBacks);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFNumberRef value = PSCFNumberCreateWithCFIndex(horizontalDimensionIndex);
    CFDictionaryAddValue(parameters, kPSDatasetProjectOutDimensionIndex, value);
    CFRelease(value);

    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFMutableArrayRef lowerLimits = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    CFMutableArrayRef upperLimits = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    for(CFIndex dimIndex = 0; dimIndex < dimensionsCount; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        PSUnitRef unit =  PSDimensionGetDisplayedUnit(dimension);
        
        CFIndex lowerIndex = PSDimensionLowestIndex(dimension);
        PSScalarRef lowerLimit = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, lowerIndex);
        PSScalarConvertToUnit((PSMutableScalarRef) lowerLimit, unit, error);
        CFArrayAppendValue(lowerLimits, lowerLimit);
        
        CFIndex upperIndex = PSDimensionHighestIndex(dimension);
        PSScalarRef upperLimit = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, upperIndex);
        PSScalarConvertToUnit((PSMutableScalarRef) upperLimit, unit, error);
        CFArrayAppendValue(upperLimits, upperLimit);
    }

    CFDictionaryAddValue(parameters, kPSDatasetProjectOutLowerLimits, lowerLimits);
    CFDictionaryAddValue(parameters, kPSDatasetProjectOutUpperLimits, upperLimits);
    CFRelease(lowerLimits);
    CFRelease(upperLimits);
    
    return parameters;
}


bool PSDatasetProjectOutDimensionValidateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutDimensionIndex)) return false;
    CFNumberRef value = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutDimensionIndex);
    CFIndex dimensionIndex;
    bool success = CFNumberGetValue(value, kCFNumberCFIndexType, &dimensionIndex);
    if(!success) return false;
    if(dimensionIndex > dimensionsCount-1 || dimensionIndex<0) return false;
    
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutLowerLimits)) return false;
    CFMutableArrayRef values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutLowerLimits);
    CFIndex count = CFArrayGetCount(values);
    if(count != dimensionsCount) return false;
    
    for(CFIndex dimIndex = 0; dimIndex < dimensionsCount; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        PSDimensionalityRef limitDimensionality = PSQuantityGetUnitDimensionality((PSScalarRef) CFArrayGetValueAtIndex(values, dimIndex));
        
        PSDimensionalityRef dimensionDimensionality = PSUnitGetDimensionality(PSDimensionGetDisplayedUnit(dimension));
        if(!PSDimensionalityHasSameReducedDimensionality(limitDimensionality, dimensionDimensionality)) return false;
    }
    
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutUpperLimits)) return false;
    values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutUpperLimits);
    count = CFArrayGetCount(values);
    if(count != dimensionsCount) return false;
    
    for(CFIndex dimIndex = 0; dimIndex < dimensionsCount; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        PSDimensionalityRef limitDimensionality = PSQuantityGetUnitDimensionality((PSScalarRef) CFArrayGetValueAtIndex(values, dimIndex));
        
        PSDimensionalityRef dimensionDimensionality = PSUnitGetDimensionality(PSDimensionGetDisplayedUnit(dimension));
        if(!PSDimensionalityHasSameReducedDimensionality(limitDimensionality, dimensionDimensionality)) return false;
    }
    
    return true;
}

void PSDatasetProjectOutDimensionSetDimensionIndex(CFMutableDictionaryRef parameters, CFIndex dimensionIndex)
{
    CFNumberRef theDimensionIndex = PSCFNumberCreateWithCFIndex(dimensionIndex);
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetProjectOutDimensionIndex)) CFDictionaryReplaceValue(parameters, kPSDatasetProjectOutDimensionIndex, theDimensionIndex);
    else CFDictionaryAddValue(parameters, kPSDatasetProjectOutDimensionIndex, theDimensionIndex);
    CFRelease(theDimensionIndex);
}

CFIndex PSDatasetProjectOutDimensionGetDimensionIndex(CFMutableDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,kCFNotFound);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetShiftValue)) return kCFNotFound;
    
    CFNumberRef theDimensionIndex = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutDimensionIndex);
    CFIndex dimensionIndex;
    CFNumberGetValue(theDimensionIndex, kCFNumberCFIndexType, &dimensionIndex);
    return dimensionIndex;
}

bool PSDatasetProjectOutDimensionSetLowerLimitForDimension(PSDatasetRef theDataset, CFMutableDictionaryRef parameters, CFIndex dimensionIndex, PSScalarRef lowerLimit)
{
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutLowerLimits)) return false;
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    
    CFMutableArrayRef values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutLowerLimits);
    CFIndex count = CFArrayGetCount(values);
    if(count != dimensionsCount) return false;
    if(dimensionIndex > dimensionsCount) return false;
    
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimensionIndex);
    PSDimensionalityRef limitDimensionality = PSQuantityGetUnitDimensionality(lowerLimit);
    PSDimensionalityRef dimensionDimensionality = PSUnitGetDimensionality(PSDimensionGetDisplayedUnit(dimension));
    if(!PSDimensionalityHasSameReducedDimensionality(limitDimensionality, dimensionDimensionality)) return false;
    CFArraySetValueAtIndex(values, dimensionIndex, lowerLimit);
    return true;
}

PSScalarRef PSDatasetProjectOutDimensionGetLowerLimitForDimension(PSDatasetRef theDataset, CFDictionaryRef parameters, CFIndex dimensionIndex)
{
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutLowerLimits)) return NULL;
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFMutableArrayRef values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutLowerLimits);
    CFIndex count = CFArrayGetCount(values);
    if(count != dimensionsCount) return NULL;
    if(dimensionIndex > dimensionsCount) return NULL;
    return CFArrayGetValueAtIndex(values, dimensionIndex);
}

bool PSDatasetProjectOutDimensionSetUpperLimitForDimension(PSDatasetRef theDataset, CFMutableDictionaryRef parameters, CFIndex dimensionIndex, PSScalarRef upperLimit)
{
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutUpperLimits)) return false;
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    
    CFMutableArrayRef values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutUpperLimits);
    CFIndex count = CFArrayGetCount(values);
    if(count != dimensionsCount) return false;
    if(dimensionIndex > dimensionsCount) return false;
    
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimensionIndex);
    PSDimensionalityRef limitDimensionality = PSQuantityGetUnitDimensionality(upperLimit);
    PSDimensionalityRef dimensionDimensionality = PSUnitGetDimensionality(PSDimensionGetDisplayedUnit(dimension));
    if(!PSDimensionalityHasSameReducedDimensionality(limitDimensionality, dimensionDimensionality)) return false;
    CFArraySetValueAtIndex(values, dimensionIndex, upperLimit);
    return true;
}

PSScalarRef PSDatasetProjectOutDimensionGetUpperLimitForDimension(PSDatasetRef theDataset, CFDictionaryRef parameters, CFIndex dimensionIndex)
{
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutUpperLimits)) return NULL;
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFMutableArrayRef values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutUpperLimits);
    CFIndex count = CFArrayGetCount(values);
    if(count != dimensionsCount) return NULL;
    if(dimensionIndex > dimensionsCount) return NULL;
    return CFArrayGetValueAtIndex(values, dimensionIndex);
}

PSDatasetRef PSDatasetProjectOutDimensionCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutDimensionIndex)) return NULL;
    CFNumberRef value = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutDimensionIndex);
    CFIndex dimensionIndex;
    bool success = CFNumberGetValue(value, kCFNumberCFIndexType, &dimensionIndex);
    if(!success) return NULL;

    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(input, dimensionIndex);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutLowerLimits)) return NULL;
    CFMutableArrayRef values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutLowerLimits);
    PSScalarRef limit = CFArrayGetValueAtIndex(values, dimensionIndex);
    CFIndex lowerIndex = PSDimensionClosestIndexToDisplayedCoordinate(dimension, limit);
//    CFIndex lowerIndex = PSDimensionIndexFromDisplayedCoordinate(dimension, limit, error);

    if(!CFDictionaryContainsKey(parameters, kPSDatasetProjectOutUpperLimits)) return NULL;
    values = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetProjectOutUpperLimits);
    limit = CFArrayGetValueAtIndex(values, dimensionIndex);
    CFIndex upperIndex = PSDimensionClosestIndexToDisplayedCoordinate(dimension, limit);
//    CFIndex upperIndex = PSDimensionIndexFromDisplayedCoordinate(dimension, limit, error);

    if(lowerIndex > upperIndex) {
        CFIndex temp = lowerIndex;
        lowerIndex = upperIndex;
        upperIndex = temp;
    }

    PSDatasetRef dataset = PSDatasetCreateByProjectingOutDimension(input, lowerIndex, upperIndex, dimensionIndex, error);
    return dataset;
}
