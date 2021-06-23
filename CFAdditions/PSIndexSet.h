//
//  PSIndexSet.h
//
//  Created by PhySy Ltd on 5/15/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSIndexSet
 
 PSIndexSet represents an immutable collection of unique signed integers,
 known as indexes because of the way they are used. This collection is
 referred to as an index set.
 
 You use index sets in your code to store indexes into some other data structure.
 For example, given an CFArray object, you could use an index set to identify a
 subset of objects in that array.
 
 An index value can only appear once in the index set.
 
 The mutable type of PSIndexSet is PSMutableIndexSet.
 
 @copyright PhySy Ltd
 @unsorted
 */


@interface PSIndexSet : NSObject
@end


/*!
 @typedef PSIndexSetRef
 This is the type of a reference to PSIndexSet.
 */
typedef const PSIndexSet * PSIndexSetRef;

/*!
 @typedef PSMutableIndexSetRef
 This is the type of a reference to PSMutableIndexSet.
 */
typedef PSIndexSet * PSMutableIndexSetRef;

#pragma mark Creators

/*!
 @functiongroup Creators
 */

/*!
 @function PSIndexSetCreate
 @abstract Creates an empty index set.
 @result PSIndexSet object
 */
PSIndexSetRef PSIndexSetCreate(void);

/*!
 @function PSIndexSetCreateCopy
 @abstract Creates a copy of a indexSet
 @param theIndexSet The index set.
 @result a copy of the index set.
 */
PSIndexSetRef PSIndexSetCreateCopy(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetCreateWithIndex
 @abstract Creates an index set with a single index.
 @param index An index
 @result PSIndexSet object
 */
PSIndexSetRef PSIndexSetCreateWithIndex(CFIndex index);

/*!
 @function PSIndexSetCreateWithIndexesInRange
 @abstract Creates an index set with an index range.
 @param indexRange An index range.
 @result PSIndexSet object
 */
PSIndexSetRef PSIndexSetCreateWithIndexesInRange(CFRange indexRange);

/*!
 @function PSIndexSetCreateMutable
 @abstract Creates an empty index set.
 @result PSMutableIndexSet object with no members.
 */
PSMutableIndexSetRef PSIndexSetCreateMutable(void);

/*!
 @function PSIndexSetCreateMutableCopy
 @abstract Creates a mutable copy of a indexSet
 @param theIndexSet The index set.
 @result a mutable copy of the index set.
 */
PSMutableIndexSetRef PSIndexSetCreateMutableCopy(PSIndexSetRef theIndexSet);

#pragma mark Accessors
/*!
 @functiongroup Accessors
 */

/*
 @function PSIndexSetGetTypeID
 @abstract Returns the type identifier for the PSIndexSet opaque type.
 @result The type identifier for the PSIndexSet opaque type.
 @discussion PSMutableIndexSet objects have the same type identifier as PSIndexSet objects.
 */
CFTypeID PSIndexSetGetTypeID(void);

/*!
 @function PSIndexSetGetIndexes
 @abstract Get the CFData containing the index set
 @param theIndexSet The index set.
 @result the CFData containing the index set.
 */
CFDataRef PSIndexSetGetIndexes(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetGetCount
 @abstract Returns the number of indexes in the index set.
 @param theIndexSet The index set.
 @result Number of indexes in the index set.
 */
CFIndex PSIndexSetGetCount(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetFirstIndex
 @abstract Returns either the first index in the index set or the not-found indicator.
 @param theIndexSet The index set.
 @result First index in the index set or kCFNotFound when the index set is empty.
 */
CFIndex PSIndexSetFirstIndex(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetLastIndex
 @abstract Returns either the last index in the index set or the not-found indicator..
 @param theIndexSet The index set.
 @result Last index in the index set or kCFNotFound when the index set is empty.
 */
CFIndex PSIndexSetLastIndex(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetIndexLessThanIndex
 @abstract Returns either the closest index in the index set that is less than a specific index or the not-found indicator.
 @param theIndexSet Index being inquired about.
 @result Closest index in the index set less than index; kCFNotFound when the index set contains no qualifying index.
 */
CFIndex PSIndexSetIndexLessThanIndex(PSIndexSetRef theIndexSet, CFIndex index);


/*!
 @function PSIndexSetIndexGreaterThanIndex
 @abstract Returns either the closest index in the index set that is greater than a specific index or the not-found indicator.
 @param theIndexSet Index being inquired about.
 @result Closest index in the index set greater than index; kCFNotFound when the index set contains no qualifying index.
 */
CFIndex PSIndexSetIndexGreaterThanIndex(PSIndexSetRef theIndexSet, CFIndex index);

CFIndex *PSIndexSetGetBytePtr(PSIndexSetRef theIndexSet);

#pragma mark Operations
/*!
 @functiongroup Operations
 */

/*!
 @function PSIndexSetAddIndex
 @abstract Adds an index into an index set.
 @param theIndexSet The index set.
 */
bool PSIndexSetAddIndex(PSMutableIndexSetRef theIndexSet, CFIndex index);

#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */

/*!
 @function PSIndexSetCreateCFNumberArray
 @abstract Creates a CFArray of CFNumbers for the index set
 @param theIndexSet The index set.
 @result a CFArray with holding the index set.
 */
CFArrayRef PSIndexSetCreateCFNumberArray(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetCreatePList
 @abstract Creates a property list representation of the index set
 @param theIndexSet The index set.
 @result a CFDictionary with holding the property list.
 */
CFDictionaryRef PSIndexSetCreatePList(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetCreateWithPList
 @abstract Creates an index set obtained with a property list representation of the index set
 @param dictionary the CFDictionary with holding the property list.
 @result the index set.
 */
PSIndexSetRef PSIndexSetCreateWithPList(CFDictionaryRef dictionary);

/*!
 @function PSIndexSetCreateData
 @abstract Creates a CFData encoding of the index set
 @param theIndexSet The index set.
 @result a CFData encoding of theIndexSet.
 */
CFDataRef PSIndexSetCreateData(PSIndexSetRef theIndexSet);

/*!
 @function PSIndexSetCreateWithData
 @abstract Creates a PSScalar from a CFData of the index set
 @param data the CFData with encoded index set.
 @result the index set.
 */
PSIndexSetRef PSIndexSetCreateWithData(CFDataRef data);

#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSIndexSetEqual
 @abstract Determines if the two index sets are equal in every attribute.
 @param input1 The first index set.
 @param input2 The second index set.
 @result true or false.
 */
bool PSIndexSetEqual(PSIndexSetRef input1, PSIndexSetRef input2);

/*!
 @function PSIndexSetContainsIndex
 @abstract Indicates whether the index set contains a specific index.
 @param theIndexSet Index being inquired about.
 @result true when the index set contains index, false otherwise.
 */
bool PSIndexSetContainsIndex(PSIndexSetRef theIndexSet, CFIndex index);

/*!
 @author PhySy
 @copyright PhySy
 */
