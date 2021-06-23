//
//  PSDatasetShift.m
//  RMN 2.0
//
//  Created by Philip on 7/1/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetShiftCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFNumberRef shift = PSCFNumberCreateWithCFIndex(1);
    CFDictionaryAddValue(parameters, kPSDatasetShiftValue, shift);
    CFRelease(shift);
    
    PSDimensionRef dimension = PSDatasetHorizontalDimension(theDataset);
    CFBooleanRef wrap = kCFBooleanFalse;
    if(PSDimensionGetFFT(dimension)) wrap = kCFBooleanTrue;
    CFDictionaryAddValue(parameters, kPSDatasetShiftWrap, wrap);
    
    return parameters;
}


bool PSDatasetShiftValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters)
{
    if(!CFDictionaryContainsKey(parameters, kPSDatasetShiftValue)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetShiftWrap)) return false;
    
    CFTypeRef theType = CFDictionaryGetValue(parameters, kPSDatasetShiftValue);
    if(CFGetTypeID(theType) != CFNumberGetTypeID()) return false;
    CFIndex shiftValue;
    CFNumberGetValue(theType, kCFNumberCFIndexType, &shiftValue);
    if(shiftValue<1) return false;
    
    theType = CFDictionaryGetValue(parameters, kPSDatasetShiftWrap);
    if(CFGetTypeID(theType) != CFBooleanGetTypeID()) return false;
    
    return true;
}

CFIndex PSDatasetShiftGetShiftValue(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,0);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetShiftValue)) return 0;
    
    CFNumberRef shift = (CFNumberRef) CFDictionaryGetValue(parameters, kPSDatasetShiftValue);
    CFIndex shiftValue;
    CFNumberGetValue(shift, kCFNumberCFIndexType, &shiftValue);
    return shiftValue;
    
    return 0;
}

void PSDatasetShiftSetToRightShift(CFMutableDictionaryRef parameters)
{
    CFIndex shift = PSDatasetShiftGetShiftValue(parameters);
    if(shift<0) shift = - shift;
    PSDatasetShiftSetShiftValue(parameters, shift);
}

void PSDatasetShiftSetToLeftShift(CFMutableDictionaryRef parameters)
{
    CFIndex shift = PSDatasetShiftGetShiftValue(parameters);
    if(shift>0) shift = - shift;
    PSDatasetShiftSetShiftValue(parameters, shift);
}

void PSDatasetShiftSetShiftValue(CFMutableDictionaryRef parameters, CFIndex shiftValue)
{
    CFNumberRef shift = PSCFNumberCreateWithCFIndex(shiftValue);
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetShiftValue)) CFDictionaryReplaceValue(parameters, kPSDatasetShiftValue, shift);
    else CFDictionaryAddValue(parameters, kPSDatasetShiftValue, shift);
    
    CFRelease(shift);
    
}

void PSDatasetShiftSetWrap(CFMutableDictionaryRef parameters, bool wrap)
{
    CFBooleanRef wrapValue = kCFBooleanFalse;
    if(wrap) wrapValue = kCFBooleanTrue;

    if(CFDictionaryContainsKey(parameters, kPSDatasetShiftWrap)) CFDictionaryReplaceValue(parameters, kPSDatasetShiftWrap, wrapValue);
    else CFDictionaryAddValue(parameters, kPSDatasetShiftWrap, wrapValue);
}

bool PSDatasetShiftGetWrap(CFDictionaryRef parameters) 
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,0);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetShiftWrap)) return NULL;
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetShiftWrap)) {
        CFBooleanRef wrap = (CFBooleanRef) CFDictionaryGetValue(parameters, kPSDatasetShiftWrap);
        if(wrap == kCFBooleanTrue) return true;
        else return false;
    }
    return false;
}

PSDatasetRef PSDatasetShiftCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFIndex level, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    CFIndex shift = PSDatasetShiftGetShiftValue(parameters);
    if(shift==0) return NULL;
    bool wrap = PSDatasetShiftGetWrap(parameters);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(input);
    PSDatasetRef dataset = PSDatasetCreateByShiftingAlongDimension(input,horizontalDimensionIndex, shift, wrap, level, error);
    return dataset;
}
