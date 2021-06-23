//
//  PSCFSet.m
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "CFAdditions.h"

CFArrayRef PSCFSetCreateArrayWithAllObjects(CFSetRef theSet)
{
    if(theSet==NULL) return NULL;
    if(CFGetTypeID(theSet) != CFSetGetTypeID()) return NULL;
    
    CFIndex count = CFSetGetCount(theSet);
    CFTypeRef *values = CFAllocatorAllocate(kCFAllocatorDefault,count * sizeof(CFTypeRef),0);
    CFSetGetValues (theSet, (CFTypeRef *) values);
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (CFTypeRef *) values, count, &kCFTypeArrayCallBacks);
    CFAllocatorDeallocate(kCFAllocatorDefault, values);
    return array;
}

CFSetRef PSCFSetCreateWithArray(CFArrayRef theArray)
{
    if(theArray==NULL) return NULL;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return NULL;

    CFIndex count = CFArrayGetCount(theArray);
    CFTypeRef *values = CFAllocatorAllocate(kCFAllocatorDefault,count * sizeof(void *),0);
    CFArrayGetValues(theArray, CFRangeMake(0, count), values);
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (CFTypeRef *) values, count, &kCFTypeSetCallBacks);
    CFAllocatorDeallocate(kCFAllocatorDefault, values);
    return set;
}

void PSCFSetAddArray(CFMutableSetRef theSet, CFArrayRef theArray)
{
    if(theArray==NULL) return;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return;
    if(theSet==NULL) return;
    if(CFGetTypeID(theSet) != CFSetGetTypeID()) return;
 
    for(CFIndex index=0;index<CFArrayGetCount(theArray);index++) {
        CFSetAddValue(theSet, CFArrayGetValueAtIndex(theArray, index));
    }
}
