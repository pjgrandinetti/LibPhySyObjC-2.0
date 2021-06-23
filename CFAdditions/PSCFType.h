//
//  PSCFType.h
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//


/*!
 @function PSFindCFTypeID
 @abstract Finds the CFTypeID given a typeIDDescription.
 @param typeIDDescription the typeIDDescription.
 @result the CFType, if it exists.  Otherwise, this function returns _kCFRuntimeNotATypeID
 CFTypeID PSFindCFTypeID(CFStringRef typeIDDescription);
 */

/*!
 @function PSHaveSameCFTypeID
 @abstract Tests whether two CFType sub-types have the same CFTypeID.
 @param input1 the first CFType.
 @param input2 the second CFType.
 */
bool PSHaveSameCFTypeID(CFTypeRef input1, CFTypeRef input2);


void KFRuntimeInitStaticInstance(void *ptr, CFTypeID typeID);
CFErrorRef PSCFErrorCreate(CFStringRef description, CFStringRef reason, CFStringRef suggestion);
