//
//  PSUtilities.c
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "CFAdditions.h"

/*
CFTypeID PSFindCFTypeID(CFStringRef typeIDDescription)
{
    for(CFTypeID id=0;id<512;id++) {
        const CFRuntimeClass *class = _CFRuntimeGetClassWithTypeID(id);
        if(class) {
            CFStringRef description = CFCopyTypeIDDescription(id);
            if(description) {
                if(CFStringCompare(typeIDDescription, description, 0) == kCFCompareEqualTo) {
                    CFRelease(description);
                    return id;
                }
                CFRelease(description);
            }
        }
    }
    return _kCFRuntimeNotATypeID;
}

 */
bool PSHaveSameCFTypeID(CFTypeRef input1, CFTypeRef input2)
{
    if(CFGetTypeID(input1) != CFGetTypeID(input2)) return false;
    return true;
}

void KFRuntimeInitStaticInstance(void *ptr, CFTypeID typeID) {
}

CFErrorRef PSCFErrorCreate(CFStringRef description, CFStringRef reason, CFStringRef suggestion)
{
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    if(description) CFDictionaryAddValue(dictionary, kCFErrorDescriptionKey, description);
    if(reason) CFDictionaryAddValue(dictionary, kCFErrorLocalizedFailureReasonKey, reason);
    if(suggestion) CFDictionaryAddValue(dictionary, kCFErrorLocalizedRecoverySuggestionKey, suggestion);

    CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, kPSFoundationErrorDomain, 0, dictionary);
    CFRelease(dictionary);
    return error;
}
