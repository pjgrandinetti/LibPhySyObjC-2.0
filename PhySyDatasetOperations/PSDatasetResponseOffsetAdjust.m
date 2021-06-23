//
//  PSDatasetResponseOffsetAdjust.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 4/2/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetResponseOffsetAdjustCreateDefaultParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    CFIndex numberOfDimensions = PSDatasetDimensionsCount(theDataset);
    CFMutableArrayRef lowerBaselineLimits = CFArrayCreateMutable(kCFAllocatorDefault, numberOfDimensions, &kCFTypeArrayCallBacks);
    CFMutableArrayRef upperBaselineLimits = CFArrayCreateMutable(kCFAllocatorDefault, numberOfDimensions, &kCFTypeArrayCallBacks);
    CFMutableArrayRef activeDimensions = CFArrayCreateMutable(kCFAllocatorDefault, numberOfDimensions, &kCFTypeArrayCallBacks);
    
    for(CFIndex dimIndex = 0; dimIndex<numberOfDimensions; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        
        PSScalarRef lowerBaselineLimit = PSDimensionCreateRelativeCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
        CFArrayAppendValue(lowerBaselineLimits, lowerBaselineLimit);
        CFRelease(lowerBaselineLimit);
        
        PSScalarRef upperBaselineLimit = PSDimensionCreateRelativeCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
        CFArrayAppendValue(upperBaselineLimits, upperBaselineLimit);
        CFRelease(upperBaselineLimit);
        
        CFArrayAppendValue(activeDimensions, kCFBooleanTrue);
    }
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryAddValue(parameters, kPSDatasetResponseOffsetAdjustLowerBaselineLimits, lowerBaselineLimits);
    CFDictionaryAddValue(parameters, kPSDatasetResponseOffsetAdjustUpperBaselineLimits, upperBaselineLimits);
    CFDictionaryAddValue(parameters, kPSDatasetResponseOffsetAdjustActiveDimensions, activeDimensions);
    
    CFRelease(lowerBaselineLimits);
    CFRelease(upperBaselineLimits);
    CFRelease(activeDimensions);
    
    return parameters;
}

bool PSDatasetResponseOffsetAdjustValidateParametersForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetResponseOffsetAdjustLowerBaselineLimits)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetResponseOffsetAdjustUpperBaselineLimits)) return false;
    
    CFIndex numberOfDimensions = PSDatasetDimensionsCount(theDataset);
    CFArrayRef lowerBaselineLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseLowerNoiseLimits);
    CFArrayRef upperBaselineLimits = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetSignalToNoiseUpperNoiseLimits);
    
    if(CFArrayGetCount(lowerBaselineLimits)!=numberOfDimensions) return false;
    if(CFArrayGetCount(upperBaselineLimits)!=numberOfDimensions) return false;
    
    for(CFIndex dimIndex = 0; dimIndex<numberOfDimensions; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        PSDimensionalityRef dimensionality = PSDimensionGetDisplayedUnitDimensionality(dimension);
        
        PSScalarRef lowerNoiseLimit = (PSScalarRef) CFArrayGetValueAtIndex(lowerBaselineLimits, dimIndex);
        if(!PSDimensionalityEqual(PSQuantityGetUnitDimensionality((PSQuantityRef) lowerNoiseLimit), dimensionality)) return false;
        
        PSScalarRef upperNoiseLimit = (PSScalarRef) CFArrayGetValueAtIndex(upperBaselineLimits, dimIndex);
        if(!PSDimensionalityEqual(PSQuantityGetUnitDimensionality((PSQuantityRef) upperNoiseLimit), dimensionality)) return false;
    }
    return true;
}

PSDatasetRef PSDatasetCreateByCorrectingBaseline(CFDictionaryRef parameters, PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    return NULL;
}
