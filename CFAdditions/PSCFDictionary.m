//
//  PSCFDictionary.c
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "CFAdditions.h"

CFArrayRef PSCFDictionaryCreateArrayWithAllKeys(CFDictionaryRef theDictionary)
{
    if(theDictionary==NULL) return NULL;
    if(CFGetTypeID(theDictionary) != CFDictionaryGetTypeID()) return NULL;
    
    CFIndex count = CFDictionaryGetCount(theDictionary);
    CFTypeRef *keys = CFAllocatorAllocate(kCFAllocatorDefault,count * sizeof(void *),0);
    CFTypeRef *values = CFAllocatorAllocate(kCFAllocatorDefault,count * sizeof(void *),0);
    
    CFDictionaryGetKeysAndValues (theDictionary, (CFTypeRef *) keys,(CFTypeRef *) values);
    
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (CFTypeRef *) keys, count, &kCFTypeArrayCallBacks);
    CFAllocatorDeallocate(kCFAllocatorDefault, values);
    CFAllocatorDeallocate(kCFAllocatorDefault, keys);
    return array;
}

CFArrayRef PSCFDictionaryCreateArrayWithAllValues(CFDictionaryRef theDictionary)
{
    if(theDictionary==NULL) return NULL;
    if(CFGetTypeID(theDictionary) != CFDictionaryGetTypeID()) return NULL;
    
    CFIndex count = CFDictionaryGetCount(theDictionary);
    CFTypeRef *keys = CFAllocatorAllocate(kCFAllocatorDefault,count * sizeof(void *),0);
    CFTypeRef *values = CFAllocatorAllocate(kCFAllocatorDefault,count * sizeof(void *),0);
    
    CFDictionaryGetKeysAndValues (theDictionary, (CFTypeRef *) keys,(CFTypeRef *) values);
    
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (CFTypeRef *) values, count, NULL);
    CFAllocatorDeallocate(kCFAllocatorDefault, values);
    CFAllocatorDeallocate(kCFAllocatorDefault, keys);
    return array;
}


