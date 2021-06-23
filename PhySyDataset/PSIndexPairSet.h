//
//  PSIndexPairSet.h
//
//  Created by PhySy Ltd on 5/15/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSIndexPairSet
 
 PSIndexPairSet represents an immutable collection of unique integer pairs.
 
 The PSIndexPair type is a structure containing two integers: an index and a value;
 The index can only appear once in the index pair set. A value has no such limitation.
 The mutable type of PSIndexPairSet is PSMutableIndexSet.
 
 @copyright PhySy Ltd
 @unsorted
 */

typedef struct PSIndexPair
{
    CFIndex index;
    CFIndex value;
} PSIndexPair;

@interface PSIndexPairSet : NSObject
@end


/*!
 @typedef PSIndexPairSetRef
 This is the type of a reference to PSIndexPairSet.
 */
typedef const PSIndexPairSet * PSIndexPairSetRef;

/*!
 @typedef PSMutableIndexSetRef
 This is the type of a reference to PSMutableIndexSet.
 */
typedef PSIndexPairSet * PSMutableIndexPairSetRef;

#pragma mark Creators

/*!
 @functiongroup Creators
 */

/*!
 @function PSIndexPairSetCreate
 @abstract Creates an empty index set.
 @result PSIndexPairSet object
 */
PSIndexPairSetRef PSIndexPairSetCreate(void);
PSIndexPairSetRef PSIndexPairSetCreateWithIndexPairArray(PSIndexPair *array, int numValues);


/*!
 @function PSIndexPairSetCreateCopy
 @abstract Creates a copy of a indexSet
 @param theIndexSet The index set.
 @result a copy of the index set.
 */
PSIndexPairSetRef PSIndexPairSetCreateCopy(PSIndexPairSetRef theIndexSet);

PSMutableIndexPairSetRef PSIndexPairSetCreateMutableWithIndexArray(PSIndexArrayRef indexArray);

/*!
 @function PSIndexPairSetCreateWithIndex
 @abstract Creates an index set with a single index pair.
 @param index The index
 @param value The value
 @result PSIndexPairSet object
 */
PSIndexPairSetRef PSIndexPairSetCreateWithIndexPair(CFIndex index, CFIndex value);

/*!
 @function PSIndexPairSetCreateWithTwoIndexPairs
 @abstract Creates an index set with a two index pairs.
 @param index1 The first index
 @param value1 The first value
 @param index2 The second index
 @param value2 The second value
@result PSIndexPairSet object
 */
PSIndexPairSetRef PSIndexPairSetCreateWithTwoIndexPairs(CFIndex index1, CFIndex value1, CFIndex index2, CFIndex value2);

/*!
 @function PSIndexPairSetCreateMutable
 @abstract Creates an empty index set.
 @result PSMutableIndexSet object with no members.
 */
PSMutableIndexPairSetRef PSIndexPairSetCreateMutable(void);

/*!
 @function PSIndexPairSetCreateMutableCopy
 @abstract Creates a mutable copy of a indexSet
 @param theIndexSet The index set.
 @result a mutable copy of the index set.
 */
PSMutableIndexPairSetRef PSIndexPairSetCreateMutableCopy(PSIndexPairSetRef theIndexSet);

#pragma mark Accessors
/*!
 @functiongroup Accessors
 */

/*!
 @function PSIndexPairSetGetIndexes
 @abstract Get the CFData containing the index set
 @param theIndexSet The index set.
 @result the CFData containing the index set.
 */
CFDataRef PSIndexPairSetGetIndexPairs(PSIndexPairSetRef theIndexSet);

/*!
 @function PSIndexPairSetGetCount
 @abstract Returns the number of indexes in the index set.
 @param theIndexSet The index set.
 @result Number of indexes in the index set.
 */
CFIndex PSIndexPairSetGetCount(PSIndexPairSetRef theIndexSet);

/*!
 @function PSIndexPairSetFirstIndex
 @abstract Returns either the first index in the index set or the not-found indicator.
 @param theIndexSet The index set.
 @result First index in the index set or kCFNotFound when the index set is empty.
 */
PSIndexPair PSIndexPairSetFirstIndex(PSIndexPairSetRef theIndexSet);

/*!
 @function PSIndexPairSetLastIndex
 @abstract Returns either the last index in the index set or the not-found indicator..
 @param theIndexSet The index set.
 @result Last index in the index set or kCFNotFound when the index set is empty.
 */
PSIndexPair PSIndexPairSetLastIndex(PSIndexPairSetRef theIndexSet);

/*!
 @function PSIndexPairSetIndexLessThanIndex
 @abstract Returns either the closest index in the index set that is less than a specific index or the not-found indicator.
 @param theIndexSet Index being inquired about.
 @result Closest index in the index set less than index; kCFNotFound when the index set contains no qualifying index.
 */
PSIndexPair PSIndexPairSetIndexPairLessThanIndexPair(PSIndexPairSetRef theIndexSet, PSIndexPair indexPair);

PSIndexPair *PSIndexPairSetGetBytePtr(PSIndexPairSetRef theIndexSet);
bool PSIndexPairSetRemoveIndexPairWithIndex(PSMutableIndexPairSetRef theIndexSet, CFIndex index);

#pragma mark Operations
/*!
 @functiongroup Operations
 */

/*!
 @function PSIndexPairSetAddIndex
 @abstract Adds an index into an index set.
 @param theIndexSet The index set.
 */
bool PSIndexPairSetAddIndexPair(PSMutableIndexPairSetRef theIndexSet, CFIndex index, CFIndex value);

PSIndexArrayRef PSIndexPairSetCreateIndexArrayOfValues(PSIndexPairSetRef theIndexSet);
bool PSIndexPairSetRemoveIndexPairWithIndex(PSMutableIndexPairSetRef theIndexSet, CFIndex index);

#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */

/*!
 @function PSIndexPairSetCreatePList
 @abstract Creates a property list representation of the index set
 @param theIndexSet The index set.
 @result a CFDictionary with holding the property list.
 */
CFDictionaryRef PSIndexPairSetCreatePList(PSIndexPairSetRef theIndexSet);

/*!
 @function PSIndexPairSetCreateWithPList
 @abstract Creates an index set obtained with a property list representation of the index set
 @param dictionary the CFDictionary with holding the property list.
 @result the index set.
 */
PSIndexPairSetRef PSIndexPairSetCreateWithPList(CFDictionaryRef dictionary);

/*!
 @function PSIndexPairSetCreateData
 @abstract Creates a CFData encoding of the index set
 @param theIndexSet The index set.
 @result a CFData encoding of theIndexSet.
 */
CFDataRef PSIndexPairSetCreateData(PSIndexPairSetRef theIndexSet);

/*!
 @function PSIndexPairSetCreateWithData
 @abstract Creates a PSScalar from a CFData of the index set
 @param data the CFData with encoded index set.
 @result the index set.
 */
PSIndexPairSetRef PSIndexPairSetCreateWithData(CFDataRef data);

#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSIndexPairSetEqual
 @abstract Determines if the two index sets are equal in every attribute.
 @param input1 The first index set.
 @param input2 The second index set.
 @result true or false.
 */
bool PSIndexPairSetEqual(PSIndexPairSetRef input1, PSIndexPairSetRef input2);

/*!
 @function PSIndexPairSetContainsIndex
 @abstract Indicates whether the index set contains a specific index.
 @param theIndexSet Index being inquired about.
 @result true when the index set contains index, false otherwise.
 */
bool PSIndexPairSetContainsIndexPair(PSIndexPairSetRef theIndexSet, PSIndexPair indexPair);
bool PSIndexPairSetContainsIndex(PSIndexPairSetRef theIndexSet, CFIndex index);
CFIndex PSIndexPairSetValueForIndex(PSIndexPairSetRef theIndexSet, CFIndex index);
PSIndexSetRef PSIndexPairSetCreateIndexSetOfIndexes(PSIndexPairSetRef theIndexSet);


void PSIndexPairSetShow(PSIndexPairSetRef theIndexPairSet);

/*!
 @author PhySy
 @copyright PhySy
 */
