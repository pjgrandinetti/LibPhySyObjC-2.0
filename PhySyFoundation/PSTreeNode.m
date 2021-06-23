//
//  PSTreeNode.c
//
//  Created by PhySy Ltd on 2/3/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "PhySyFoundation.h"

typedef CFMutableArrayRef PSTreeNodeInfoRef;

/* Designated Creator */
/**************************/

static PSTreeNodeInfoRef PSTreeNodeInfoAllocate()
{
    return CFArrayCreateMutable(kCFAllocatorDefault, 2, &kCFTypeArrayCallBacks);
}

static CFStringRef PSTreeNodeInfoCopyDescription(const void *info)
{
    PSTreeNodeInfoRef theInfo = (PSTreeNodeInfoRef) info;
    CFTypeRef value = CFArrayGetValueAtIndex(theInfo, 1);
    if(CFGetTypeID(value)==CFStringGetTypeID()) return CFStringCreateCopy(kCFAllocatorDefault, value);
    if(CFGetTypeID(value)==CFNumberGetTypeID()) return PSCFNumberCreateStringValue(value);
    if([(NSObject *) value isKindOfClass:[PSScalar class]]) return PSScalarCreateStringValue(value);
    if(CFGetTypeID(value)==CFBooleanGetTypeID()) {
        if(CFBooleanGetValue(value)) return CFSTR("YES");
        else return CFSTR("NO");
    }
    return NULL;
}

// *************   Begin PSTreeNode functions

#pragma mark Accessors

CFStringRef PSTreeNodeGetKey(CFTreeRef theTree)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theTree,NULL);
    CFTreeContext context;
    CFTreeGetContext(theTree, &context);
    PSTreeNodeInfoRef nodeInfo = (PSTreeNodeInfoRef) context.info;
    if(nodeInfo) return CFArrayGetValueAtIndex(nodeInfo, 0);
    return NULL;
}

CFTypeRef PSTreeNodeGetValue(CFTreeRef theTree)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theTree,NULL);
    CFTreeContext context;
    CFTreeGetContext(theTree, &context);
    PSTreeNodeInfoRef nodeInfo = (PSTreeNodeInfoRef) context.info;
    if(nodeInfo) return CFArrayGetValueAtIndex(nodeInfo, 1);
    return NULL;
}

void PSTreeNodeSetValue(CFTreeRef theTree, CFTypeRef value)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theTree,);
    CFTreeContext context;
    CFTreeGetContext(theTree, &context);
    PSTreeNodeInfoRef nodeInfo = (PSTreeNodeInfoRef) context.info;
    if(CFArrayGetValueAtIndex(nodeInfo, 1) == value) return;
    if(value) CFArraySetValueAtIndex(nodeInfo, 1, value);
    else CFArraySetValueAtIndex(nodeInfo, 1, kCFNull);
}

#pragma mark Create CFTree from CFType or PSScalar

static CFComparisonResult stringSort(const void *val1, const void *val2, void *context)
{
    CFStringRef string1 = (CFStringRef) val1;
    CFStringRef string2 = (CFStringRef) val2;
    return CFStringCompare(string1, string2, kCFCompareCaseInsensitive);
}

CFTreeRef PSTreeNodeCreateWithScalar(PSScalarRef theScalar, CFStringRef key)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(key,NULL);
    // *** Initialize object ***
    PSTreeNodeInfoRef newTreeNodeInfo = PSTreeNodeInfoAllocate();
    if(key) CFArraySetValueAtIndex(newTreeNodeInfo, 0, key);
    if(theScalar) CFArraySetValueAtIndex(newTreeNodeInfo, 1, theScalar);
    CFTreeContext context = {0, (void *) newTreeNodeInfo, CFRetain, CFRelease, PSTreeNodeInfoCopyDescription};
    CFTreeRef theTree = CFTreeCreate(kCFAllocatorDefault,&context);
    CFRelease(newTreeNodeInfo);
    return theTree;
}

CFTreeRef PSTreeNodeCreateWithCFString(CFStringRef theString, CFStringRef key)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theString,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(key,NULL);
    // *** Initialize object ***
    PSTreeNodeInfoRef newTreeNodeInfo = PSTreeNodeInfoAllocate();
    if(key) CFArraySetValueAtIndex(newTreeNodeInfo, 0, key);
    if(theString) CFArraySetValueAtIndex(newTreeNodeInfo, 1, theString);
    CFTreeContext context = {0, (void *) newTreeNodeInfo, CFRetain, CFRelease, PSTreeNodeInfoCopyDescription};
    CFTreeRef theTree = CFTreeCreate(kCFAllocatorDefault,&context);
    CFRelease(newTreeNodeInfo);
    return theTree;
}

CFTreeRef PSTreeNodeCreateWithNumber(CFNumberRef theNumber, CFStringRef key)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theNumber,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(key,NULL);
    // *** Initialize object ***
    PSTreeNodeInfoRef newTreeNodeInfo = PSTreeNodeInfoAllocate();
    if(key) CFArraySetValueAtIndex(newTreeNodeInfo, 0, key);
    if(theNumber) CFArraySetValueAtIndex(newTreeNodeInfo, 1, theNumber);
    CFTreeContext context = {0, (void *) newTreeNodeInfo, CFRetain, CFRelease, PSTreeNodeInfoCopyDescription};
    CFTreeRef theTree = CFTreeCreate(kCFAllocatorDefault,&context);
    CFRelease(newTreeNodeInfo);
    return theTree;
}

CFTreeRef PSTreeNodeCreateWithBoolean(CFBooleanRef theBoolean, CFStringRef key)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theBoolean,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(key,NULL);
    // *** Initialize object ***
    PSTreeNodeInfoRef newTreeNodeInfo = PSTreeNodeInfoAllocate();
    if(key) CFArraySetValueAtIndex(newTreeNodeInfo, 0, key);
    if(theBoolean) CFArraySetValueAtIndex(newTreeNodeInfo, 1, theBoolean);
    CFTreeContext context = {0, (void *) newTreeNodeInfo, CFRetain, CFRelease, PSTreeNodeInfoCopyDescription};
    CFTreeRef theTree = CFTreeCreate(kCFAllocatorDefault,&context);
    CFRelease(newTreeNodeInfo);
    return theTree;
}

CFTreeRef PSTreeNodeCreateWithArray(CFArrayRef theArray, CFStringRef key)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theArray,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(key,NULL);
    // *** Initialize object ***
    PSTreeNodeInfoRef newTreeNodeInfo = PSTreeNodeInfoAllocate();
    if(key) CFArraySetValueAtIndex(newTreeNodeInfo, 0, key);
    if(theArray) CFArraySetValueAtIndex(newTreeNodeInfo, 1, theArray);
    CFTreeContext context = {0, (void *) newTreeNodeInfo, CFRetain, CFRelease, PSTreeNodeInfoCopyDescription};
    CFTreeRef theTree = CFTreeCreate (kCFAllocatorDefault,&context);
    
    CFIndex count = CFArrayGetCount(theArray);
    if(count) {
        for(CFIndex index = 0; index<count; index++) {
            CFTypeRef value = CFArrayGetValueAtIndex(theArray, index);
            CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Item %ld"),index);
            CFTypeID typeID = CFGetTypeID(value);
            if(typeID == CFStringGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithCFString((CFStringRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFArrayGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithArray((CFArrayRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFDictionaryGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithDictionary((CFDictionaryRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if([(NSObject *) value isKindOfClass:[PSScalar class]]) {
                CFTreeRef child = PSTreeNodeCreateWithScalar((PSScalarRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFBooleanGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithBoolean((CFBooleanRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFNumberGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithNumber((CFNumberRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            CFRelease(key);
        }
    }
    return theTree;
}

CFTreeRef PSTreeNodeCreateWithDictionary(CFDictionaryRef theDictionary, CFStringRef key)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theDictionary,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(key,NULL);
    // *** Initialize object ***
    PSTreeNodeInfoRef newTreeNodeInfo = PSTreeNodeInfoAllocate();
    if(key) CFArraySetValueAtIndex(newTreeNodeInfo, 0, key);
    if(theDictionary) CFArraySetValueAtIndex(newTreeNodeInfo, 1, theDictionary);
    CFTreeContext context = {0, (void *) newTreeNodeInfo, CFRetain, CFRelease, PSTreeNodeInfoCopyDescription};
    CFTreeRef theTree = CFTreeCreate (kCFAllocatorDefault,&context);

    CFIndex count = CFDictionaryGetCount(theDictionary);
    if(count) {
        CFTypeRef values[count];
        CFStringRef keys[count];
        CFDictionaryGetKeysAndValues(theDictionary, (const void **) keys, (const void **)  values);
        
        CFArrayRef temp = CFArrayCreate(kCFAllocatorDefault, (const void **) keys, count, &kCFTypeArrayCallBacks);
        CFMutableArrayRef sortedKeys = CFArrayCreateMutableCopy(kCFAllocatorDefault, count, temp);
        CFArraySortValues(sortedKeys, CFRangeMake(0, CFArrayGetCount(temp)), stringSort, NULL);
        CFRelease(temp);

        for(CFIndex index = 0; index<count; index++) {
            CFStringRef key = CFArrayGetValueAtIndex(sortedKeys, index);
            CFTypeRef value = CFDictionaryGetValue(theDictionary, key);
            CFTypeID typeID = CFGetTypeID(value);
            if(typeID == CFStringGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithCFString((CFStringRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFDictionaryGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithDictionary((CFDictionaryRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFArrayGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithArray((CFArrayRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if([(NSObject *) value isKindOfClass:[PSScalar class]]) {
                CFTreeRef child = PSTreeNodeCreateWithScalar((PSScalarRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFBooleanGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithBoolean((CFBooleanRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
            else if(typeID == CFNumberGetTypeID()) {
                CFTreeRef child = PSTreeNodeCreateWithNumber((CFNumberRef) value, key);
                CFTreeAppendChild(theTree,child);
                CFRelease(child);
            }
        }
        CFRelease(sortedKeys);
    }
    return theTree;
}

CFMutableArrayRef PSTreeNodeCreateArray(CFTreeRef theTree)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theTree,NULL);
    CFTypeRef value = PSTreeNodeGetValue(theTree);
    CFTypeID typeIdentifier = CFGetTypeID(value);
    if(typeIdentifier == CFArrayGetTypeID()) {
        CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFIndex count = CFTreeGetChildCount(theTree);
        for(CFIndex index=0; index<count; index++) {
            CFTreeRef child = CFTreeGetChildAtIndex(theTree, index);
            CFTypeRef value = PSTreeNodeGetValue(child);
            CFTypeID typeID = CFGetTypeID(value);
            if(typeID == CFDictionaryGetTypeID()) {
                CFMutableDictionaryRef newValue = PSTreeNodeCreateDictionary(child);
                CFArrayAppendValue(array, newValue);
                CFRelease(newValue);
            }
            else if(typeID == CFArrayGetTypeID()) {
                CFArrayRef newValue = PSTreeNodeCreateArray(child);
                CFArrayAppendValue(array, newValue);
                CFRelease(newValue);
            }
            else CFArrayAppendValue(array, value);
        }
        return array;
    }
    return NULL;
}

CFMutableDictionaryRef PSTreeNodeCreateDictionary(CFTreeRef theTree)
{
    if(NULL==theTree) return NULL;
    CFTypeRef value = PSTreeNodeGetValue(theTree);
    CFTypeID typeID = CFGetTypeID(value);
    if(typeID == CFDictionaryGetTypeID()) {
        CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        CFIndex count = CFTreeGetChildCount(theTree);
        for(CFIndex index=0; index<count; index++) {
            CFTreeRef child = CFTreeGetChildAtIndex(theTree, index);
            CFTypeRef value = PSTreeNodeGetValue(child);
            CFStringRef key = PSTreeNodeGetKey(child);
            CFTypeID typeIdentifier = CFGetTypeID(value);
            if(typeIdentifier == CFDictionaryGetTypeID()) {
                CFMutableDictionaryRef newValue = PSTreeNodeCreateDictionary(child);
                CFDictionaryAddValue(dictionary, key, newValue);
                CFRelease(newValue);
            }
            else if(typeIdentifier == CFArrayGetTypeID()) {
                CFArrayRef newValue = PSTreeNodeCreateArray(child);
                CFDictionaryAddValue(dictionary, key, newValue);
                CFRelease(newValue);
            }
            else CFDictionaryAddValue(dictionary, key, value);
        }
        return dictionary;
    }
    return NULL;
}

