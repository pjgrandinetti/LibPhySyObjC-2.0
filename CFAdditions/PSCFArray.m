//
//  PSCFArray.c
//
//  Created by PhySy Ltd on 2/17/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "CFAdditions.h"

void PSCFArrayRemoveObjectsIdenticalToObject(CFMutableArrayRef theArray, void *theObject)
{
    if(theArray==NULL) return;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return;
    
    for(CFIndex index = CFArrayGetCount(theArray)-1; index>=0; index--) {
        const void *object = CFArrayGetValueAtIndex(theArray, index);
        if(object == theObject) CFArrayRemoveValueAtIndex(theArray, index);
    }
}

void PSCFArrayRemoveObjectsIdenticalToObjects(CFMutableArrayRef theArray, CFArrayRef theObjects)
{
    if(theArray==NULL) return;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return;
    
    for(CFIndex index = CFArrayGetCount(theArray)-1; index>=0; index--) {
        const void *object = CFArrayGetValueAtIndex(theArray, index);
        for(CFIndex jndex = 0; jndex<CFArrayGetCount(theObjects); jndex++) {
            const void *anObject = CFArrayGetValueAtIndex(theObjects, jndex);
            if(object == anObject) CFArrayRemoveValueAtIndex(theArray, index);
            
        }
    }
}

void PSCFArrayRemoveObjectsAtIndexes(CFMutableArrayRef theArray, PSIndexSetRef theIndexSet)
{
    if(theArray==NULL) return;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return;
    
    if(theIndexSet==NULL || theArray==NULL) return;
    
    CFIndex count = PSIndexSetGetCount(theIndexSet);
    if(count) {
        CFIndex index = PSIndexSetLastIndex(theIndexSet);
        CFArrayRemoveValueAtIndex(theArray, index);
        for(CFIndex i=0; i<count-1; i++) {
            index = PSIndexSetIndexLessThanIndex(theIndexSet, index);
            if(index==kCFNotFound) return;
            CFArrayRemoveValueAtIndex(theArray, index);
        }
    }
}

CFArrayRef PSCFArrayCreateWithObjectsAtIndexes(CFArrayRef theArray, PSIndexSetRef theIndexSet) 
{
    if(theArray==NULL) return NULL;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return NULL;
    
    CFDataRef indexData = PSIndexSetGetIndexes(theIndexSet);
    CFIndex count = PSIndexSetGetCount(theIndexSet);
    CFIndex *indexes = (CFIndex *) CFDataGetBytePtr(indexData);
    
    CFMutableArrayRef array = CFArrayCreateMutable(CFGetAllocator(theArray), count, &kCFTypeArrayCallBacks);
    for(int32_t i =0 ; i<count; i++) {
        CFArrayAppendValue(array, CFArrayGetValueAtIndex(theArray, indexes[i]));
    }
    return array;
}

CFIndex PSCFArrayIndexOfObject(CFArrayRef theArray, CFTypeRef object)
{
    if(theArray==NULL) return kCFNotFound;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return kCFNotFound;
    
    if(theArray == NULL) return kCFNotFound;
    
    for(CFIndex index = 0; index<CFArrayGetCount(theArray); index++) {
        if(CFEqual(CFArrayGetValueAtIndex(theArray, index), object)) return index;
    }
    return kCFNotFound;
}

CFIndex PSCFArrayIndexOfIdenticalObject(CFArrayRef theArray, CFTypeRef object)
{
    if(theArray==NULL) return kCFNotFound;
    if(CFGetTypeID(theArray) != CFArrayGetTypeID()) return kCFNotFound;
    
    for(CFIndex index = 0; index<CFArrayGetCount(theArray); index++) {
        if(object == CFArrayGetValueAtIndex(theArray, index)) return index;
    }
    return kCFNotFound;
}
