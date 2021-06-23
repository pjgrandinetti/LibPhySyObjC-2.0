//
//  PSQuantity.h
//
//  Created by PhySy Ltd on 10/26/08.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//


#import "PhySyFoundation.h"

@interface PSQuantity : NSObject
{
	PSUnitRef       unit;
	numberType      elementType;
}
@end

/*!
 @header PSQuantity
 PSQuantity represents a physical quantity and has two attributes: a element type and a unit.
 PSQuantity is an abstract type.
 
 @copyright PhySy Ltd
 */

/*!
 @typedef PSQuantity
 This is the type of a reference to immutable PSQuantity.
 */
typedef const PSQuantity *PSQuantityRef;

/*!
 @typedef PSMutableQuantity
 This is the type of a reference to mutable PSQuantity.
 */
typedef PSQuantity *PSMutableQuantityRef;

#pragma mark Accessors
/*!
 @functiongroup Accessors
 */

/*!
 @function PSQuantityGetUnit
 @abstract Returns the quantity's unit.
 @param quantity The quantity.
 @result a PSUnit object
 */
PSUnitRef PSQuantityGetUnit(PSQuantityRef quantity);

/*!
 @function PSQuantitySetUnit
 @abstract Set the quantity's unit.
 @param quantity The quantity.
 @param unit The unit.
 */
void PSQuantitySetUnit(PSMutableQuantityRef quantity, PSUnitRef unit);

/*!
 @function PSQuantityGetUnitDimensionality
 @abstract Returns the quantity's dimensionality.
 @param quantity The quantity.
 @result a PSDimensionality object
 */
PSDimensionalityRef PSQuantityGetUnitDimensionality(PSQuantityRef quantity);

/*!
 @function PSQuantityGetElementType
 @abstract Returns the type used by a quantity to store its values.
 @param quantity The quantity.
 @result the element type.  Possible values are kPSNumberFloat32Type, kPSNumberFloat64Type, kPSNumberFloat32ComplexType, and kPSNumberFloat64ComplexType.
 */
numberType PSQuantityGetElementType(PSQuantityRef quantity);

/*!
 @function PSQuantityElementSize
 @abstract Returns size (in bytes) of a quantity element.
 @param quantity The quantity.
 @result the size
 */
int PSQuantityElementSize(PSQuantityRef quantity);

#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSQuantityHasElementType
 @abstract Tests if quantity has a specific element type.
 @param quantity The quantity.
 @param elementType The element type.
 @result true or false.
 */
bool PSQuantityHasElementType(PSQuantityRef quantity, numberType elementType);

/*!
 @function PSQuantityIsComplexType
 @abstract Tests if quantity has a complex element type.
 @param theQuantity The quantity.
 @result true or false.
 */
bool PSQuantityIsComplexType(PSQuantityRef theQuantity);

/*!
 @function PSQuantityHasDimensionality
 @abstract Tests if quantity has a specific dimensionality.
 @param quantity The quantity.
 @param theDimensionality The dimensionality.
 @result true or false.
 */
bool PSQuantityHasDimensionality(PSQuantityRef quantity, PSDimensionalityRef theDimensionality);

/*!
 @function PSQuantityHasSameDimensionality
 @abstract Determines if two quantities have the same dimensionality exponents, 
 @param input1 The first quantity.
 @param input2 The second quantity.
 @result true or false.
 */
bool PSQuantityHasSameDimensionality(PSQuantityRef input1, PSQuantityRef input2);

/*!
 @function PSQuantityHasSameReducedDimensionality
 @abstract Determines if two quantities have the same reduced dimensionality exponents, 
 @param input1 The first quantity.
 @param input2 The second quantity.
 @result true or false.
 */
bool PSQuantityHasSameReducedDimensionality(PSQuantityRef input1, PSQuantityRef input2);

/*!
 @function PSQuantityComplexElementType
 @abstract Returns corresponding complex element type for the input.
 @param input The input numberType.
 @result the complex numberType
 */
numberType PSQuantityComplexElementType(PSQuantityRef input);

/*!
 @function PSQuantityLargerElementType
 @abstract Returns larger element type for the two input quantities.
 @param input1 The first numberType.
 @param input2 The second numberType.
 @result the larger numberType of the two quantities
 */
numberType PSQuantityLargerElementType(PSQuantityRef input1,PSQuantityRef input2);

/*!
 @function PSQuantitySmallerElementType
 @abstract Returns smaller element type for the two input quantities.
 @param input1 The first numberType.
 @param input2 The second numberType.
 @result the smaller numberType of the two quantities
 */
numberType PSQuantitySmallerElementType(PSQuantityRef input1, PSQuantityRef input2);

/*!
 @function PSQuantityBestElementType
 @abstract Returns the best element type for the two input quantities.
 @param input1 The first numberType.
 @param input2 The second numberType.
 @result the best numberType from the two quantities
 @discussion Returns the best element type for the two input quantities which loses no precision
 when the quantities are combined in any way: add, subtract, multiply, divide.  Input element
 types and outputs are:
 
 (float and float) => float
 
 (float and double) => double
 
 (float and float complex) => float complex
 
 (float and double complex) => double complex
 
 (double and double) => double
 
 (double and float complex) => double complex
 
 (double and double complex) => double complex
 
 (float complex and float complex) => float complex
 
 (float complex and double complex) => double complex
 
 (double complex and double complex) => double complex
 */
numberType PSQuantityBestElementType(PSQuantityRef input1, PSQuantityRef input2);

numberType PSQuantityBestComplexElementType(PSQuantityRef input1, PSQuantityRef input2);
