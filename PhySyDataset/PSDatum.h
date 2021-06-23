//
//  PSDatum.h
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

@interface PSDatum : PSScalar
{
    CFIndex             dependentVariableIndex;
    CFIndex             componentIndex;
    CFIndex             memOffset;
    CFArrayRef          coordinates;
}
@end

/*!
 @header PSDatum
 PSDatum represents a physical response in a coordinate space. It is a subtype of PSScalar.
 Like PSScalar, it has three essential attributes: a unit, an elementType, and a numerical value.
 Additionally, a PSDatum, like PSDependentVariable, can have two optional attributes: an array of coordinates,
 and a response uncertainty.
 
 Two optional transient attributes are memOffset and dependentVariableIndex, to indicate the origin for datum derived from a PSDataset
 
 @copyright PhySy
 */

/*!
 @typedef PSDatumRef
 This is the type of a reference to immutable PSDatum.
 */
typedef PSDatum *PSDatumRef;

#pragma mark Creators
/*!
 @functiongroup Creators
 */


/*!
 @function PSDatumCreate
 @abstract Creates a PSDatum
 @param theScalar The response.
 @param coordinates A CFArray holding an array of PSScalar coordinates.
 @param memOffset a transient attribute to indicate original location in PSDataset.
 @param dependentVariableIndex a transient attribute to indicate original location in PSDataset.
 @result a PSDatum.
 */
PSDatumRef PSDatumCreate(PSScalarRef theScalar,
                         CFArrayRef coordinates,
                         CFIndex dependentVariableIndex,
                         CFIndex componentIndex,
                         CFIndex memOffset);

/*!
 @function PSDatumCopy
 @abstract Creates a PSDatum copy
 @param theDatum a PSDatum.
 @result a PSDatum.
 */
PSDatumRef PSDatumCopy(PSDatumRef theDatum);



#pragma mark Accessors
/*!
 @functiongroup Accessors
 */


/*!
 @function PSDatumGetCoordinateAtIndex
 */
PSScalarRef PSDatumGetCoordinateAtIndex(PSDatumRef theDatum, CFIndex index);

/*!
 @function PSDatumCoordinatesCount
 */
CFIndex PSDatumCoordinatesCount(PSDatumRef theDatum);

/*!
 @function PSDatumCreateResponse
 */
PSScalarRef PSDatumCreateResponse(PSDatumRef theDatum);

/*!
 @function PSDatumGetComponentIndex
 */
CFIndex PSDatumGetComponentIndex(PSDatumRef theDatum);

void PSDatumSetComponentIndex(PSDatumRef theDatum, CFIndex componentIndex);

/*!
 @function PSDatumGetDependentVariableIndex
 */
CFIndex PSDatumGetDependentVariableIndex(PSDatumRef theDatum);
void PSDatumSetDependentVariableIndex(PSDatumRef theDatum, CFIndex dependentVariableIndex);

/*!
 @function PSDatumGetMemOffset
 */
CFIndex PSDatumGetMemOffset(PSDatumRef theDatum);
void PSDatumSetMemOffset(PSDatumRef theDatum, CFIndex memOffset);

#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSDatumEqual
 */
bool PSDatumEqual(PSDatumRef input1, PSDatumRef input2);

/*!
 @function PSDatumHasSameReducedDimensionalities
 */
bool PSDatumHasSameReducedDimensionalities(PSDatumRef input1, PSDatumRef input2);


#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */

CFDictionaryRef PSDatumCreatePList(PSDatumRef theDatum);
PSDatumRef PSDatumCreateWithPList(CFDictionaryRef dictionary, CFErrorRef *error);
PSDatumRef PSDatumCreateWithOldDataFormat(CFDataRef data, CFErrorRef *error);


