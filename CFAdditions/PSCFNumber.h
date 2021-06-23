//
//  PSCFNumber.h
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSCFNumber
 PSCFNumber extends CFNumber with additional methods.
 
 @copyright PhySy Ltd
 */

/*!
 @function PSCFNumberCreateWithCFIndex
 @abstract Creates a CFNumber from a CFIndex
 @param index The CFIndex.
 */
CFNumberRef PSCFNumberCreateWithCFIndex(CFIndex index);

/*!
 @function PSCFNumberCFIndexValue
 @abstract returns the CFIndex value of a CFNumber
 @param number the CFNumber
 @result The CFIndex value.
 */
CFIndex PSCFNumberCFIndexValue(CFNumberRef number);

/*!
 @function PSCFNumberCreateStringValue
 @abstract Creates a CFString representation of a CFNumber
 @param theNumber the CFNumber
 @result The CFString result.
 */
CFStringRef PSCFNumberCreateStringValue(CFNumberRef theNumber);

void PSCFNumberAddToArrayAsStringValue(CFNumberRef theNumber, CFMutableArrayRef array);
