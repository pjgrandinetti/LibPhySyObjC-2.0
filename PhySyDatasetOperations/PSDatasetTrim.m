//
//  PSDatasetTrim.c
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 11/7/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetTrimCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    int side = kPSDatasetTrimRightSide;
    CFNumberRef theTrimSide = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &side);
    CFDictionaryAddValue(parameters, kPSDatasetTrimSide, theTrimSide);
    CFRelease(theTrimSide);
    
    CFIndex horizontalNpts = PSDimensionGetNpts(PSDatasetHorizontalDimension(theDataset));
    CFIndex trimLengthPerSide = horizontalNpts;
    do {
        trimLengthPerSide--;
    } while(!IsPowerOfTwo(trimLengthPerSide));
    trimLengthPerSide = horizontalNpts - trimLengthPerSide;
    
    CFNumberRef trimLength = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &trimLengthPerSide);
    CFDictionaryAddValue(parameters, kPSDatasetTrimLengthPerSide, trimLength);
    CFRelease(trimLength);
    
    return parameters;
}


CFIndex PSDatasetTrimGetTrimLengthPerSide(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,0);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetTrimLengthPerSide)) return 0;
    CFNumberRef trimLengthPerSide = CFDictionaryGetValue(parameters, kPSDatasetTrimLengthPerSide);
    if(trimLengthPerSide) {
        int trimLength;
        CFNumberGetValue(trimLengthPerSide, kCFNumberNSIntegerType, &trimLength);
        return trimLength;
    }
    return 0;
    
}

bool PSDatasetTrimSetTrimLengthPerSide(CFMutableDictionaryRef parameters, CFIndex trimLengthPerSide, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    if(trimLengthPerSide<0) return false;
    
    CFNumberRef theTrimLength = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &trimLengthPerSide);
    if(theTrimLength) {
        bool containskey = CFDictionaryContainsKey(parameters, kPSDatasetTrimLengthPerSide);
        if(containskey) {
            CFDictionaryReplaceValue(parameters, kPSDatasetTrimLengthPerSide, theTrimLength);
        }
        else CFDictionaryAddValue(parameters, kPSDatasetTrimLengthPerSide, theTrimLength);
        CFRelease(theTrimLength);
        return true;
    }
    return false;
}

trimSide PSDatasetTrimGetSide(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,0);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetTrimSide)) return 0;
    CFNumberRef theTrimSide = CFDictionaryGetValue(parameters, kPSDatasetTrimSide);
    if(theTrimSide) {
        int sideIndex;
        CFNumberGetValue(theTrimSide, kCFNumberIntType, &sideIndex);
        trimSide side = sideIndex;
        return side;
    }
    return 0;
}

bool PSDatasetTrimSetTrimSide(CFMutableDictionaryRef parameters, trimSide side, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    if(side != kPSDatasetTrimBothSides && side != kPSDatasetTrimLeftSide && side != kPSDatasetTrimRightSide) return false;
    
    CFNumberRef theTrimSide = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &side);
    if(theTrimSide) {
        bool containskey = CFDictionaryContainsKey(parameters, kPSDatasetTrimSide);
        if(containskey) {
            CFDictionaryReplaceValue(parameters, kPSDatasetTrimSide, theTrimSide);
        }
        else CFDictionaryAddValue(parameters, kPSDatasetTrimSide, theTrimSide);
        CFRelease(theTrimSide);
        return true;
    }
    return false;
}


bool PSDatasetTrimValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetTrimSide)) return false;
    
    CFNumberRef theTrimSide = CFDictionaryGetValue(parameters, kPSDatasetTrimSide);
    trimSide side;
    CFNumberGetValue(theTrimSide, kCFNumberIntType, &side);
    if(side != kPSDatasetTrimBothSides && side != kPSDatasetTrimLeftSide && side != kPSDatasetTrimRightSide) return false;
    
    return true;
}


PSDatasetRef PSDatasetTrimCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    char trimSide[2];
    switch(PSDatasetTrimGetSide(parameters)) {
        case kPSDatasetTrimLeftSide:
            trimSide[0] = 'l';
            break;
        case kPSDatasetTrimRightSide:
            trimSide[0] = 'r';
            break;
        case kPSDatasetTrimBothSides:
            trimSide[0] = 'b';
            break;
    }
    PSDatasetRef dataset = PSDatasetCreateByTrimingAlongDimension(input,
                                                                   PSDatasetGetHorizontalDimensionIndex(input),
                                                                   trimSide,
                                                                   PSDatasetTrimGetTrimLengthPerSide(parameters));
    return dataset;
}



