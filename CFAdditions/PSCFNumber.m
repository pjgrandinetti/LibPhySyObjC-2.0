//
//  PSCFNumber.m
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "CFAdditions.h"

CFNumberRef PSCFNumberCreateWithCFIndex(CFIndex index)
{
    return CFNumberCreate(kCFAllocatorDefault, kCFNumberCFIndexType, &index);
}

CFIndex PSCFNumberCFIndexValue(CFNumberRef theNumber)
{
    if(theNumber==NULL) return 0;
    if(CFGetTypeID(theNumber) != CFNumberGetTypeID()) return 0;
    
    CFIndex index;
    CFNumberGetValue(theNumber, kCFNumberCFIndexType, &index);
    return index;
}

CFStringRef PSCFNumberCreateStringValue(CFNumberRef theNumber)
{
    CFNumberType type = CFNumberGetType(theNumber);
    switch (type) {
        case kCFNumberCharType:
        case kCFNumberSInt8Type: {
            SInt8 value = 0;
            CFNumberGetValue(theNumber, type, &value);
            return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%hi"),(SInt16) value);
        }
        case kCFNumberShortType:
        case kCFNumberSInt16Type: {
            SInt16 value = 0;
            CFNumberGetValue(theNumber, type, &value);
            return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%hi"),value);
        }
#ifndef __LP64__
        case kCFNumberLongType:
        case kCFNumberCFIndexType:
        case kCFNumberNSIntegerType:
#endif
        case kCFNumberIntType:
        case kCFNumberSInt32Type: {
            SInt32 value = 0;
            CFNumberGetValue(theNumber, type, &value);
            return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%d"),(int)value);
        }
#if __LP64__
        case kCFNumberLongType:
        case kCFNumberCFIndexType:
        case kCFNumberNSIntegerType:
#endif
        case kCFNumberLongLongType:
        case kCFNumberSInt64Type: {
            SInt64 value = 0;
            CFNumberGetValue(theNumber, type, &value);
            return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%qi"),value);
        }
#ifndef __LP64__
        case kCFNumberCGFloatType:
#endif
        case kCFNumberFloatType:
        case kCFNumberFloat32Type: {
            Float32 value = 0;
            CFNumberGetValue(theNumber, type, &value);
            CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%g"),value);
            CFMutableStringRef mutResult = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(result), result);
            CFRelease(result);
            CFStringFindAndReplace (mutResult,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(mutResult)),0);
            return mutResult;

        }
#if __LP64__
        case kCFNumberCGFloatType:
#endif
        case kCFNumberDoubleType:
        case kCFNumberFloat64Type: {
            Float64 value = 0;
            CFNumberGetValue(theNumber, type, &value);
            CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%lg"),value);
            CFMutableStringRef mutResult = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(result), result);
            CFRelease(result);
            CFStringFindAndReplace (mutResult,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(mutResult)),0);
            return mutResult;
        }
    }
    return NULL;
}


void PSCFNumberAddToArrayAsStringValue(CFNumberRef theNumber, CFMutableArrayRef array)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theNumber,);
   	IF_NO_OBJECT_EXISTS_RETURN(array,);
    CFStringRef stringValue = PSCFNumberCreateStringValue(theNumber);
    CFArrayAppendValue(array, stringValue);
    CFRelease(stringValue);
}

void PSCFNumberAddToArrayAsData(CFNumberRef theNumber, CFMutableArrayRef array)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theNumber,);
   	IF_NO_OBJECT_EXISTS_RETURN(array,);
    CFArrayAppendValue(array, theNumber);
}



