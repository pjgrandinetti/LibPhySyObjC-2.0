//
//  PSIndexArray.h
//
//  Created by PhySy Ltd on 5/15/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSIndexArray
 
 PSIndexArray represents an immutable collection of unique signed integers,
 known as indexes because of the way they are used. This collection is
 referred to as an index array.
 
 The mutable type of PSIndexArray is PSMutableIndexArray.
 
 @copyright PhySy Ltd
 @unsorted
 */


@interface PSIndexArray : NSObject
@end


/*!
 @typedef PSIndexArrayRef
 This is the type of a reference to PSIndexArray.
 */
typedef const PSIndexArray * PSIndexArrayRef;

/*!
 @typedef PSMutableIndexArrayRef
 This is the type of a reference to PSMutableIndexArray.
 */
typedef PSIndexArray * PSMutableIndexArrayRef;

#pragma mark Creators

/*!
 @functiongroup Creators
 */

/*!
 @function PSIndexArrayCreate
 @abstract Creates an empty index set.
 @result PSIndexArray object
 */
PSIndexArrayRef PSIndexArrayCreate(CFIndex *indexes, CFIndex numValues);

/*!
 @function PSIndexArrayCreateCopy
 @abstract Creates a copy of a IndexArray
 @param theIndexArray The index set.
 @result a copy of the index set.
 */
PSIndexArrayRef PSIndexArrayCreateCopy(PSIndexArrayRef theIndexArray);

/*!
 @function PSIndexArrayCreateMutable
 @abstract Creates an empty index set.
 @result PSMutableIndexArray object with no members.
 */
PSMutableIndexArrayRef PSIndexArrayCreateMutable(CFIndex capacity);

/*!
 @function PSIndexArrayCreateMutableCopy
 @abstract Creates a mutable copy of a IndexArray
 @param theIndexArray The index set.
 @result a mutable copy of the index set.
 */
PSMutableIndexArrayRef PSIndexArrayCreateMutableCopy(PSIndexArrayRef theIndexArray);

#pragma mark Accessors
/*!
 @functiongroup Accessors
 */

/*!
 @function PSIndexArrayGetCount
 @abstract Returns the number of indexes in the index set.
 @param theIndexArray The index set.
 @result Number of indexes in the index set.
 */
CFIndex PSIndexArrayGetCount(PSIndexArrayRef theIndexArray);

CFIndex PSIndexArrayGetValueAtIndex(PSIndexArrayRef theIndexArray, CFIndex index);
bool PSIndexArraySetValueAtIndex(PSMutableIndexArrayRef theIndexArray, CFIndex index, CFIndex value);

bool PSIndexArrayRemoveValueAtIndex(PSMutableIndexArrayRef theIndexArray, CFIndex index);
void PSIndexArrayRemoveValuesAtIndexes(PSMutableIndexArrayRef theIndexArray, PSIndexSetRef theIndexSet);

CFIndex *PSIndexArrayGetMutableBytePtr(PSIndexArrayRef theIndexArray);

#pragma mark Operations
/*!
 @functiongroup Operations
 */

#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */

/*!
 @function PSIndexArrayCreateCFNumberArray
 @abstract Creates a CFArray containing CFNumbers of the index set
 @param theIndexArray The index set.
 @result a CFArray with holding the index set.
 */
CFArrayRef PSIndexArrayCreateCFNumberArray(PSIndexArrayRef theIndexArray);

/*!
 @function PSIndexArrayCreatePList
 @abstract Creates a property list representation of the index set
 @param theIndexArray The index set.
 @result a CFDictionary with holding the property list.
 */
CFDictionaryRef PSIndexArrayCreatePList(PSIndexArrayRef theIndexArray);

/*!
 @function PSIndexArrayCreateWithPList
 @abstract Creates an index set obtained with a property list representation of the index set
 @param dictionary the CFDictionary with holding the property list.
 @result the index set.
 */
PSIndexArrayRef PSIndexArrayCreateWithPList(CFDictionaryRef dictionary);

/*!
 @function PSIndexArrayCreateData
 @abstract Creates a CFData encoding of the index set
 @param theIndexArray The index set.
 @result a CFData encoding of theIndexArray.
 */
CFDataRef PSIndexArrayCreateData(PSIndexArrayRef theIndexArray);

/*!
 @function PSIndexArrayCreateWithData
 @abstract Creates a PSScalar from a CFData of the index set
 @param data the CFData with encoded index set.
 @result the index set.
 */
PSIndexArrayRef PSIndexArrayCreateWithData(CFDataRef data);

#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSIndexArrayEqual
 @abstract Determines if the two index sets are equal in every attribute.
 @param input1 The first index set.
 @param input2 The second index set.
 @result true or false.
 */
bool PSIndexArrayEqual(PSIndexArrayRef input1, PSIndexArrayRef input2);

/*!
 @function PSIndexArrayContainsIndex
 @abstract Indicates whether the index set contains a specific index.
 @param theIndexArray Index being inquired about.
 @result true when the index set contains index, false otherwise.
 */
bool PSIndexArrayContainsIndex(PSIndexArrayRef theIndexArray, CFIndex index);


/*!
 @function PSIndexArrayCreateBase64String
 @abstract Creates a base64 encoding of indexes into string.
 @param theIndexArray the index array.
 @result string contain base64 encoding.
 */
CFStringRef PSIndexArrayCreateBase64String(PSIndexArrayRef theIndexArray, csdmNumericType integerType);

/*!
 @function PSIndexArrayAppendValues
 @abstract Appends an PSIndexArray.
 @param theIndexArray the index array.
 @param arrayToAppend the PSIndexArray to append.
 @result true if successful, false otherwise.
 */
bool PSIndexArrayAppendValues(PSMutableIndexArrayRef theIndexArray, PSIndexArrayRef arrayToAppend);

/*!
 @function PSIndexArrayAppendValue
 @abstract Appends an index.
 @param theIndexArray the index array.
 @param index the index to add.
 @result true if successful, false otherwise.
 */
bool PSIndexArrayAppendValue(PSMutableIndexArrayRef theIndexArray, CFIndex index);

void PSIndexArrayShow(PSIndexArrayRef theIndexArray);

/*!
 @author PhySy
 @copyright PhySy
 */
