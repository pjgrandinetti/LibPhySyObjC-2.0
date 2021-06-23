//
//  PSPList.c
//
//  Created by PhySy Ltd on 4/12/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "PhySyFoundation.h"

CFArrayRef PSCFArrayCreatePListCompatibleArray(CFArrayRef theArray)
{
    CFTypeID typeIdentifier = CFGetTypeID(theArray);
    if(typeIdentifier != CFArrayGetTypeID()) return NULL;
    
    CFMutableArrayRef newArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFIndex count = CFArrayGetCount(theArray);
    if(count) {
        for(CFIndex index = 0; index<count; index++) {
            CFTypeRef value = CFArrayGetValueAtIndex(theArray, index);
            CFTypeID typeID = CFGetTypeID(value);
            if(typeID == CFDictionaryGetTypeID()) {
                CFDictionaryRef newValue = PSCFDictionaryCreatePListCompatible(value);
                CFArrayAppendValue(newArray, newValue);
                CFRelease(newValue);
            }
            else if(typeID == CFArrayGetTypeID()) {
                CFArrayRef newValue = PSCFArrayCreatePListCompatibleArray(value);
                CFArrayAppendValue(newArray, newValue);
                CFRelease(newValue);
            }
            else if([(NSObject *) value isKindOfClass:[PSScalar class]]) {
                CFPropertyListRef valuePList = PSScalarCreatePList(value);
                if(valuePList) {
                    CFArrayAppendValue(newArray, valuePList);
                    CFRelease(valuePList);
                }
            }
            else CFArrayAppendValue(newArray, value);
        }
    }
    return newArray;
}

CFMutableArrayRef PSCFArrayCreateWithPListCompatibleArray(CFArrayRef theArray, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    CFTypeID typeIdentifier = CFGetTypeID(theArray);
    if(typeIdentifier != CFArrayGetTypeID()) return NULL;
    
    CFMutableArrayRef newArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFIndex count = CFArrayGetCount(theArray);
    if(count) {
        for(CFIndex index = 0; index<count; index++) {
            CFTypeRef value = CFArrayGetValueAtIndex(theArray, index);
            CFTypeID typeID = CFGetTypeID(value);
            if(typeID == CFDictionaryGetTypeID()) {
                if(CFDictionaryContainsKey(value, CFSTR("TypeIDDescription"))) {
                    CFStringRef typeIDDescription = CFDictionaryGetValue(value, CFSTR("TypeIDDescription"));
                    if(CFStringCompare(typeIDDescription, CFSTR("PSScalar"), 0) == kCFCompareEqualTo) {
                        PSScalarRef newValue = PSScalarCreateWithPList(value,error);
                        if(newValue) {
                            CFArrayAppendValue(newArray,newValue);
                            CFRelease(newValue);
                        }
                    }
                    else {
                        if(error) {
                            CFStringRef desc = CFSTR("An unknown type could not be added to the plist.");
                            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                            kPSFoundationErrorDomain,
                                                                            0,
                                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                            (const void* const*)&desc,
                                                                            1);
                        }
                    }
                }
                else {
                    CFDictionaryRef newValue = PSCFDictionaryCreateWithPListCompatibleDictionary(value, error);
                    if(newValue) {
                        CFArrayAppendValue(newArray,newValue);
                        CFRelease(newValue);
                    }
                }
            }
            else if(typeID == CFArrayGetTypeID()) {
                CFArrayRef newValue = PSCFArrayCreateWithPListCompatibleArray(value, error);
                if(newValue) {
                    CFArrayAppendValue(newArray,newValue);
                    CFRelease(newValue);
                }
            }
            else CFArrayAppendValue(newArray,value);
        }
    }
    return newArray;
}


CFDictionaryRef PSCFDictionaryCreatePListCompatible(CFDictionaryRef theDictionary)
{
    CFTypeID typeIdentifier = CFGetTypeID(theDictionary);
    if(typeIdentifier != CFDictionaryGetTypeID()) return NULL;
    
    CFMutableDictionaryRef newDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFIndex count = CFDictionaryGetCount(theDictionary);
    if(count) {
        CFTypeRef values[count];
        CFStringRef keys[count];
        CFDictionaryGetKeysAndValues(theDictionary, (const void **) keys, (const void **)  values);
        for(CFIndex index = 0; index<count; index++) {
            CFStringRef key = keys[index];
            CFTypeRef value = values[index];
            CFTypeID typeID = CFGetTypeID(value);
            if(typeID == CFDictionaryGetTypeID()) {
                CFDictionaryRef newValue = PSCFDictionaryCreatePListCompatible(value);
                if(newValue) {
                    CFDictionaryAddValue(newDictionary, key,newValue);
                    CFRelease(newValue);
                }
            }
            else if(typeID == CFArrayGetTypeID()) {
                CFArrayRef newValue = PSCFArrayCreatePListCompatibleArray(value);
                if(newValue) {
                    CFDictionaryAddValue(newDictionary, key,newValue);
                    CFRelease(newValue);
                }
            }
            else if([(NSObject *) value isKindOfClass:[PSScalar class]]) {
                CFDictionaryRef newValue = PSScalarCreatePList(value);
                if(newValue) {
                    CFDictionaryAddValue(newDictionary, key, newValue);
                    CFRelease(newValue);
                }
            }
            else CFDictionaryAddValue(newDictionary, key,value);
        }
    }
    return newDictionary;
}

CFMutableDictionaryRef PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryRef theDictionary, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    CFTypeID typeIdentifier = CFGetTypeID(theDictionary);
    if(typeIdentifier != CFDictionaryGetTypeID()) return NULL;
    CFMutableDictionaryRef newDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFIndex count = CFDictionaryGetCount(theDictionary);
    if(count) {
        CFTypeRef values[count];
        CFStringRef keys[count];
        CFDictionaryGetKeysAndValues(theDictionary, (const void **) keys, (const void **)  values);
        for(CFIndex index = 0; index<count; index++) {
            CFStringRef key = keys[index];
            CFTypeRef value = values[index];
            CFTypeID typeID = CFGetTypeID(value);
            if(typeID == CFDictionaryGetTypeID()) {
                if(CFDictionaryContainsKey(value, CFSTR("TypeIDDescription"))) {
                    CFStringRef typeIDDescription = CFDictionaryGetValue(value, CFSTR("TypeIDDescription"));
                    if(CFStringCompare(typeIDDescription, CFSTR("PSScalar"), 0) == kCFCompareEqualTo) {
                        PSScalarRef newValue = PSScalarCreateWithPList(value,error);
                        if(newValue) {
                            CFDictionaryAddValue(newDictionary, key,newValue);
                            CFRelease(newValue);
                        }
                    }
                    else {
                        if(error) {
                            CFStringRef desc = CFSTR("An unknown type was found in the plist.");
                            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                            kPSFoundationErrorDomain,
                                                                            0,
                                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                            (const void* const*)&desc,
                                                                            1);
                        }
                    }
                }
                else {
                    CFDictionaryRef newValue = PSCFDictionaryCreateWithPListCompatibleDictionary(value, error);
                    if(newValue) {
                        CFDictionaryAddValue(newDictionary, key,newValue);
                        CFRelease(newValue);
                    }
                }
            }
            else if(typeID == CFArrayGetTypeID()) {
                CFArrayRef newValue = PSCFArrayCreateWithPListCompatibleArray(value, error);
                if(newValue) {
                    CFDictionaryAddValue(newDictionary, key,newValue);
                    CFRelease(newValue);
                }
            }
            else CFDictionaryAddValue(newDictionary, key,value);
        }
    }
    return newDictionary;
}
