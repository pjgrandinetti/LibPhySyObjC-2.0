//
//  PSDatasetScaleDimension.m
//  RMN 2.0
//
//  Created by Philip on 7/1/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>
#import <LibPhySyObjC/PSCFArray.h>

CFMutableDictionaryRef PSDatasetScaleCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFIndex horizontalNpts = PSDimensionGetNpts(PSDatasetHorizontalDimension(theDataset));
    CFNumberRef finalHorizontalNpts = PSCFNumberCreateWithCFIndex(horizontalNpts);
    CFDictionaryAddValue(parameters, kPSDatasetHorizontalScale, finalHorizontalNpts);
    CFRelease(finalHorizontalNpts);
    
    CFIndex verticalNpts = PSDimensionGetNpts(PSDatasetVerticalDimension(theDataset));
    CFNumberRef finalVerticalNpts = PSCFNumberCreateWithCFIndex(verticalNpts);
    CFDictionaryAddValue(parameters, kPSDatasetVerticalScale, finalVerticalNpts);
    CFRelease(finalVerticalNpts);
    
    return parameters;
}

bool PSDatasetScaleValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    {
        if(!CFDictionaryContainsKey(parameters, kPSDatasetHorizontalScale)) return false;
        CFNumberRef finalNpts = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetHorizontalScale);
        CFIndex newNpts;
        bool success = CFNumberGetValue(finalNpts, kCFNumberCFIndexType, &newNpts);
        if(!success) return false;
        
        CFIndex currentNpts = PSDimensionGetNpts(PSDatasetHorizontalDimension(theDataset));
        if(newNpts> currentNpts) {
            CFNumberRef finalNpts = PSCFNumberCreateWithCFIndex(currentNpts);
            CFDictionaryAddValue(parameters, kPSDatasetHorizontalScale, finalNpts);
            CFRelease(finalNpts);
        }
        else if(newNpts<1) {
            CFNumberRef finalNpts = PSCFNumberCreateWithCFIndex(1);
            CFDictionaryAddValue(parameters, kPSDatasetHorizontalScale, finalNpts);
            CFRelease(finalNpts);
        }
    }

    {
        if(!CFDictionaryContainsKey(parameters, kPSDatasetVerticalScale)) return false;
        CFNumberRef finalNpts = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetVerticalScale);
        CFIndex newNpts;
        bool success = CFNumberGetValue(finalNpts, kCFNumberCFIndexType, &newNpts);
        if(!success) return false;
        
        CFIndex currentNpts = PSDimensionGetNpts(PSDatasetVerticalDimension(theDataset));
        if(newNpts> currentNpts) {
            CFNumberRef finalNpts = PSCFNumberCreateWithCFIndex(currentNpts);
            CFDictionaryAddValue(parameters, kPSDatasetVerticalScale, finalNpts);
            CFRelease(finalNpts);
        }
        else if(newNpts<1) {
            CFNumberRef finalNpts = PSCFNumberCreateWithCFIndex(1);
            CFDictionaryAddValue(parameters, kPSDatasetVerticalScale, finalNpts);
            CFRelease(finalNpts);
        }
    }
return true;
}

PSDatasetRef PSDatasetCreateByScalingDimension(PSDatasetRef input, CFMutableDictionaryRef parameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);

    CFNumberRef finalNpts = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetHorizontalScale);
    CFIndex newHorizontalNpts;
    CFNumberGetValue(finalNpts, kCFNumberCFIndexType, &newHorizontalNpts);
    
    finalNpts = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetVerticalScale);
    CFIndex newVerticalNpts;
    CFNumberGetValue(finalNpts, kCFNumberCFIndexType, &newVerticalNpts);
    
    return PSDatasetCreateByScalingHorizontalAndVerticalDimensions(input,
                                                                   newHorizontalNpts,
                                                                   newVerticalNpts,
                                                                   error);
}

