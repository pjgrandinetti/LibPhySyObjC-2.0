//
//  PSTreeNode.h
//
//  Created by PhySy Ltd on 2/3/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSTreeNode
 
 @copyright PhySy Ltd
 @unsorted
 */


#pragma mark Accessors

#pragma mark Creators

/*!
 @functiongroup Creators
 */

CFTreeRef PSTreeNodeCreateWithScalar(PSScalarRef theScalar, CFStringRef key);
CFTreeRef PSTreeNodeCreateWithCFString(CFStringRef stringValue, CFStringRef key);
CFTreeRef PSTreeNodeCreateWithNumber(CFNumberRef theNumber, CFStringRef key);
CFTreeRef PSTreeNodeCreateWithBoolean(CFBooleanRef theBoolean, CFStringRef key);

CFTreeRef PSTreeNodeCreateWithArray(CFArrayRef theArray, CFStringRef key);
CFTreeRef PSTreeNodeCreateWithDictionary(CFDictionaryRef theDictionary, CFStringRef key);

#pragma mark Accessors
/*!
 @functiongroup Accessors
 */

CFStringRef PSTreeNodeGetKey(CFTreeRef theTree);
CFTypeRef PSTreeNodeGetValue(CFTreeRef theTree);
void PSTreeNodeSetValue(CFTreeRef theTree, CFTypeRef value);


#pragma mark Operations
/*!
 @functiongroup Operations
 */

CFMutableArrayRef PSTreeNodeCreateArray(CFTreeRef theTree);
CFMutableDictionaryRef PSTreeNodeCreateDictionary(CFTreeRef theTree);

