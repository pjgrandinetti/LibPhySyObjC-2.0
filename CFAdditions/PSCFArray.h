//
//  PSCFArray.h
//
//  Created by PhySy Ltd on 2/17/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSCFArray
 PSCFArray extends CFArray with additional methods.
  
 @copyright PhySy Ltd
 */

/*!
 @function PSCFArrayRemoveObjectsIdenticalToObject
 @abstract Removes all occurrences of a given object in the array.
 @param theArray The array.
 @param theObject The object to remove from the array.
 */
void PSCFArrayRemoveObjectsIdenticalToObject(CFMutableArrayRef theArray, void *theObject);

/*!
 @function PSCFArrayRemoveObjectsIdenticalToObjects
 @abstract Removes from the receiving array the objects in another given array.
 @param theArray the receiving array.
 @param theObjects An array containing the objects to be removed from the receiving array.
 */
void PSCFArrayRemoveObjectsIdenticalToObjects(CFMutableArrayRef theArray, CFArrayRef theObjects);

/*!
 @function PSCFArrayRemoveObjectsAtIndexes
 @abstract Removes the objects at the specified indexes from the array.
 @param theArray the receiving array.
 @param theIndexSet the index set.
 @discussion The indexes of the objects to remove from the array. The locations specified by indexes must lie within the bounds of the array.
 */
void PSCFArrayRemoveObjectsAtIndexes(CFMutableArrayRef theArray, PSIndexSetRef theIndexSet);

/*!
 @function PSCFArrayIndexOfObject
 @abstract Returns the lowest index whose corresponding array value is equal to a given object.
 @param theArray the array.
 @param object object.
 @result The lowest index whose corresponding array value is equal to object. If none of the objects in the array is equal to object, returns kCFNotFound.
 */
CFIndex PSCFArrayIndexOfObject(CFArrayRef theArray, CFTypeRef object);

/*!
 @function PSCFArrayIndexOfIdenticalObject
 @abstract Returns the lowest index whose corresponding array value is identical to a given object.
 @param theArray the array.
 @param object object.
 @result The lowest index whose corresponding array value is identical to object. If none of the objects in the array is identical to object, returns kCFNotFound.
 */
CFIndex PSCFArrayIndexOfIdenticalObject(CFArrayRef theArray, CFTypeRef object);

/*!
 @function PSCFArrayCreateWithObjectsAtIndexes
 @abstract Returns an array containing the objects in the array at the indexes specified by a given index set.
 @param theArray the array.
 @param theIndexSet the index set.
 @result An array containing the objects in the array at the indexes specified by indexes.
 @discussion The returned objects are in the ascending order of their indexes in indexes, 
 so that object in returned array with higher index in indexes will follow the object with smaller index in indexes.
 */
CFArrayRef PSCFArrayCreateWithObjectsAtIndexes(CFArrayRef theArray, PSIndexSetRef theIndexSet);

