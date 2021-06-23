//
//  PSCFSet.h
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSCFSet
 PSCFSet extends CFSet with additional methods.
  
 @copyright PhySy Ltd
 */

/*!
 @function PSCFSetCreateArrayWithAllObjects
 @abstract Returns an array containing the set’s members, or an empty array if the set has no members.
 @param theSet The set.
 @result array with objects
 */
CFArrayRef PSCFSetCreateArrayWithAllObjects(CFSetRef theSet);

/*!
 @function PSCFSetCreateWithArray
 @abstract Creates and returns a set containing a uniqued collection of the objects contained in a given array.
 @param theArray The array.
 */
CFSetRef PSCFSetCreateWithArray(CFArrayRef theArray);

/*!
 @function PSCFSetAddArray
 @abstract Adds values inside an array to a mutable set.
 @param theSet The set in which the values will be added.
 @param theArray The array of values to be added.
 */
void PSCFSetAddArray(CFMutableSetRef theSet, CFArrayRef theArray);
