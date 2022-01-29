//
//  PSDependentVariable.h
//
//  Created by PhySy Ltd on 3/15/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#define PSDependentVariableElementType2 CFSTR("number_type")
#define PSDependentVariableName2 CFSTR("name")
#define PSDependentVariableUnit2 CFSTR("response_unit")
#define PSDependentVariableFormat2 CFSTR("format")

#define PSDependentVariableElementType CFSTR("elementType")
#define PSDependentVariableName CFSTR("name")
#define PSDependentVariableUnit CFSTR("unit")
#define PSDependentVariableValues CFSTR("values")

#define PSDependentVariableComponentsFileName CFSTR("dependent_variable-%ld.data")
typedef enum formatType {
    kPSDependentVariableText,
    kPSDependentVariableBinary
} formatType;


@class PSDataset;
@interface PSDependentVariable : PSQuantity
{
    CFStringRef         name;
    CFMutableArrayRef   components;
    CFMutableArrayRef   componentLabels;
    CFStringRef         quantityName;
    CFStringRef         quantityType;
    CFStringRef         description;
    
    PSIndexSetRef       sparseDimensionIndexes;
    CFArrayRef          sparseGridVertexes;
    
    // RMN extra attributes below
    PSPlotRef               plot;
    CFMutableDictionaryRef  metaData;
    PSDataset               *dataset;
}
@end

/*!
 @header PSDependentVariable
 PSDependentVariable represents components of physical quantities. It is a concrete subtype of PSQuantity.
 It has three essential attributes: a unit, an elementType, and an array of components of numerical values.
 
 @copyright PhySy
 @unsorted
 
 */

/*!
 @typedef PSDependentVariableRef
 This is the type of a reference to mutable PSDependentVariable.
 */
typedef PSDependentVariable *PSDependentVariableRef;

/*!
 @functiongroup Creators
 */

#pragma mark Creators

/*!
 @function PSDependentVariableCreate
 @abstract Creates a PSDependentVariable
 @param unit The unit.
 @param elementType possible values are kPSNumberFloat32Type, kPSNumberFloat64Type, kPSNumberFloat32ComplexType, and kPSNumberFloat64ComplexType,
 @param components A CFArray holding the components.
 @result a PSDependentVariable.
 @discussion If unit is NULL, then the values in block are set to be dimensionless and underived
 */
PSDependentVariableRef PSDependentVariableCreate(CFStringRef name,
                                                 CFStringRef description,
                                                 PSUnitRef unit,
                                                 CFStringRef quantityName,
                                                 CFStringRef quantityType,
                                                 numberType elementType,
                                                 CFArrayRef labels,
                                                 CFArrayRef components,
                                                 PSPlotRef plot,
                                                 PSDataset *theDataset);

/*!
 @function PSDependentVariableCreateWithComponent
 */
PSDependentVariableRef PSDependentVariableCreateWithComponent(CFStringRef name,
                                                              CFStringRef description,
                                                              PSUnitRef unit,
                                                              CFStringRef quantityName,
                                                              numberType elementType,
                                                              CFArrayRef labels,
                                                              CFDataRef component,
                                                              PSPlotRef plot,
                                                              PSDataset *theDataset);

/*!
 @function PSDependentVariableCreateCopy
 @abstract Creates a copy of a PSDependentVariable
 @param theBlock The PSDependentVariable.
 @result a copy of the PSDependentVariable.
 */
PSDependentVariableRef PSDependentVariableCreateCopy(PSDependentVariableRef theDependentVariable, PSDataset *theDataset);

/*!
 @function PSDependentVariableCreateComplexCopy
 @abstract Creates a complex copy of a PSDependentVariable
 @param theDependentVariable The PSDependentVariable.
 @result a complex copy of the PSDependentVariable.
 */
PSDependentVariableRef PSDependentVariableCreateComplexCopy(PSDependentVariableRef theDependentVariable, PSDataset *theDataset);

/*!
 @function PSDependentVariableCreateWithSize
 @abstract Creates a PSDependentVariable with a given size
 @param elementType The numberType
 @param unit a PSUnit
 @param size the number of elements
 @result a PSDependentVariable.
 */
PSDependentVariableRef PSDependentVariableCreateWithSize(CFStringRef name,
                                                         CFStringRef description,
                                                         PSUnitRef unit,
                                                         CFStringRef quantityName,
                                                         CFStringRef quantityType,
                                                         numberType elementType,
                                                         CFArrayRef componentLabels,
                                                         CFIndex size,
                                                         PSPlotRef plot,
                                                         PSDataset *theDataset);

PSDependentVariableRef PSDependentVariableCreateDefault(CFStringRef quantityType,
                                                      numberType elementType,
                                                      CFIndex size,
                                                      PSDataset *theDataset);


/*!
 @functiongroup Accessors
 */

#pragma mark Accessors
CFDictionaryRef PSDependentVariableGetMetaData(PSDependentVariableRef theDependentVariable);

void PSDependentVariableSetMetaData(PSDependentVariableRef theDependentVariable, CFDictionaryRef metaData);

PSDataset *PSDependentVariableGetDataset(PSDependentVariableRef theDependentVariable);

void PSDependentVariableSetDataset(PSDependentVariableRef theDependentVariable, PSDataset *theDataset);

CFStringRef PSDependentVariableGetName(PSDependentVariableRef theDependentVariable);
void PSDependentVariableSetName(PSDependentVariableRef theDependentVariable, CFStringRef name);

CFStringRef PSDependentVariableGetDescription(PSDependentVariableRef theDependentVariable);
void PSDependentVariableSetDescription(PSDependentVariableRef theDependentVariable, CFStringRef description);

CFStringRef PSDependentVariableCreateComponentLabelForIndex(PSDependentVariableRef theDependentVariable, CFIndex componentIndex);


CFStringRef PSDependentVariableGetComponentLabelAtIndex(PSDependentVariableRef theDependentVariable, CFIndex componentIndex);
bool PSDependentVariableSetComponentLabelAtIndex(PSDependentVariableRef theDependentVariable, CFStringRef label, CFIndex componentIndex);

CFStringRef PSDependentVariableGetQuantityType(PSDependentVariableRef theDependentVariable);
bool PSDependentVariableSetQuantityType(PSDependentVariableRef theDependentVariable, CFStringRef quantityType);
CFArrayRef PSDependentVariableCreateArrayOfQuantityTypes(PSDependentVariableRef theDependentVariable);

CFStringRef PSDependentVariableGetQuantityName(PSDependentVariableRef theDependentVariable);
bool PSDependentVariableSetQuantityName(PSDependentVariableRef theDependentVariable, CFStringRef quantityName);


PSPlotRef PSDependentVariableGetPlot(PSDependentVariableRef theDependentVariable);
bool PSDependentVariableSetPlot(PSDependentVariableRef theDependentVariable, PSPlotRef thePlot);

/*!
 @function PSDependentVariableGetElementType
 @abstract returns the type of element
 @param theBlock the block
 @result The numberType.
 */
numberType PSDependentVariableGetElementType(PSDependentVariableRef theBlock);

/*!
 @function PSDependentVariableSetElementType
 @abstract sets the type of element
 @param theBlock the block
 @param elementType the element Type
 @discussion If needed, all values copied into storage as new element type
 */
bool PSDependentVariableSetElementType(PSDependentVariableRef theBlock, numberType elementType);

/*!
 @function PSDependentVariableGetComponentAtIndex
 @abstract returns the mutable CFData holding the block values
 @param theBlock the block
 @result a CFMutableData.
 */
CFMutableDataRef PSDependentVariableGetComponentAtIndex(PSDependentVariableRef theDependentVariable, CFIndex componentIndex);

/*!
 @function PSDependentVariableSetValues
 @abstract sets the CFData holding the block values
 @param theBlock the block
 @param values the block values in a CFData
 */
bool PSDependentVariableSetValues(PSDependentVariableRef theBlock, CFIndex componentIndex, CFDataRef values);

CFMutableArrayRef PSDependentVariableGetComponents(PSDependentVariableRef theDependentVariable);
CFIndex PSDependentVariableComponentsCount(PSDependentVariableRef theDependentVariable);
bool PSDependentVariableInsertComponentAtIndex(PSDependentVariableRef theDependentVariable, CFDataRef component, CFIndex componentIndex);
bool PSDependentVariableRemoveComponentAtIndex(PSDependentVariableRef theDependentVariable, CFIndex componentIndex);
bool PSDependentVariableSetComponentAtIndex(PSDependentVariableRef theDependentVariable,
                                            CFDataRef component,
                                            CFIndex componentIndex);

/*!
 @function PSDependentVariableSize
 @abstract calculates the number of elements in the block
 @param theDependentVariable the block
 @result a CFIndex with the number of elements.
 */
CFIndex PSDependentVariableSize(PSDependentVariableRef theDependentVariable);

/*!
 @function PSDependentVariableSetSize
 @abstract sets the number of elements in the block
 @param theDependentVariable the block
 @param size a CFIndex with the new number of elements.
 */
bool PSDependentVariableSetSize(PSDependentVariableRef theDependentVariable, CFIndex size);

/*!
 @function PSDependentVariableCreateValueFromMemOffset
 @abstract Create a PSScalar with the value at memOffset
 @param theDependentVariable the block
 @param memOffset a CFIndex with the memOffset of the value.
 @result a PSScalar.
 */
PSScalarRef PSDependentVariableCreateValueFromMemOffset(PSDependentVariableRef theDependentVariable,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset);

/*!
 @function PSDependentVariableSetValueAtMemOffset
 @abstract Set the value at memOffset using a PSScalar
 @param theBlock the block
 @param memOffset a CFIndex with the memOffset of the value to set.
 @param value the value to set.
 */
bool PSDependentVariableSetValueAtMemOffset(PSDependentVariableRef theBlock,
                                            CFIndex componentIndex,
                                            CFIndex memOffset,
                                            PSScalarRef value,
                                            CFErrorRef *error);

/*!
 @function PSDependentVariableInt32ValueAtMemOffset
 @abstract Returns a int32_t value.
 @param memOffset The memory offset location.
 @result a int32_t value
 */
int32_t PSDependentVariableInt32ValueAtMemOffset(PSDependentVariableRef theBlock, CFIndex memOffset);

/*!
 @function PSDependentVariableInt64ValueAtMemOffset
 @abstract Returns a int64_t value.
 @param memOffset The memory offset location.
 @result a int64_t value
 */
int64_t PSDependentVariableInt64ValueAtMemOffset(PSDependentVariableRef theBlock, CFIndex memOffset);

/*!
 @function PSDependentVariableFloatValueAtMemOffset
 @abstract Returns a float value.
 @param memOffset The memory offset location.
 @result a float value
 */
float PSDependentVariableFloatValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                               CFIndex componentIndex,
                                               CFIndex memOffset);

/*!
 @function PSDependentVariableDoubleValueAtMemOffset
 @abstract Returns a double value.
 @param memOffset The memory offset location.
 @result a double value
 */
double PSDependentVariableDoubleValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                 CFIndex componentIndex,
                                                 CFIndex memOffset);

/*!
 @function PSDependentVariableFloatComplexValueAtMemOffset
 @abstract Returns a float complex value.
 @param memOffset The memory offset location.
 @result a float complex value
 */
float complex PSDependentVariableFloatComplexValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                              CFIndex componentIndex,
                                                              CFIndex memOffset);

/*!
 @function PSDependentVariableDoubleComplexValueAtMemOffset
 @abstract Returns a double complex value.
 @param memOffset The memory offset location.
 @result a double complex value
 */
double complex PSDependentVariableDoubleComplexValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                                CFIndex componentIndex,
                                                                CFIndex memOffset);


/*!
 @function PSDependentVariableFloatValueAtMemOffsetForPart
 @abstract Returns a float value for the complex part.
 @param memOffset The memory offset location.
 @param part The complex part.
 @result a float argument value
 */
float PSDependentVariableFloatValueAtMemOffsetForPart(PSDependentVariableRef theDependentVariable,
                                                      CFIndex componentIndex,
                                                      CFIndex memOffset,
                                                      complexPart part);

/*!
 @function PSDependentVariableDoubleValueAtMemOffsetForPart
 @abstract Returns a double value for the complex part.
 @param memOffset The memory offset location.
 @param part The complex part.
 @result a double argument value
 */
double PSDependentVariableDoubleValueAtMemOffsetForPart(PSDependentVariableRef theDependentVariable,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset,
                                                        complexPart part);

/*!
 @function PSDependentVariableSetValuesToZero
 @abstract Set all value to zero
 @param theDependentVariable the DependentVariable
 @param componentIndex the component index
 */
bool PSDependentVariableSetValuesToZero(PSDependentVariableRef theDependentVariable,
                                        CFIndex componentIndex);

/*!
 @function PSDependentVariableComponentFindMaximumForPart
 @abstract Finds the maximum value and location in component of DependentVariable for the complex part.
 @param theDependentVariable the DependentVariable
 @param part the complex part
 @param memOffsetMax pointer to a CFIndex with the location of the maximum value.
 @result the maximum value.
 */
double PSDependentVariableComponentFindMaximumForPart(PSDependentVariableRef theDependentVariable,
                                                      CFIndex componentIndex,
                                                      complexPart part,
                                                      CFIndex *memOffsetMax,
                                                      CFErrorRef *error);

/*!
 @function PSDependentVariableFindMaximumForPart
 @abstract Finds the maximum value and location in DependentVariable for the complex part.
 @param theDependentVariable the DependentVariable
 @param part the complex part
 @param memOffsetMax pointer to a CFIndex with the memOffset for the maximum value.
 @param componentIndexMax pointer to a CFIndex with the componentIndex for the maximum value.
 @result the maximum value.
 */
double PSDependentVariableFindMaximumForPart(PSDependentVariableRef theDependentVariable,
                                             complexPart part,
                                             CFIndex *memOffsetMax,
                                             CFIndex *componentIndexMax,
                                             CFErrorRef *error);

/*!
 @function PSDependentVariableComponentFindMinimumForPart
 @abstract Finds the minimum value and location in DependentVariable for the complex part.
 @param theDependentVariable the DependentVariable
 @param part the complex part
 @param memOffsetMin pointer to a CFIndex with the location of the minimum value.
 @result the minimum value.
 */
double PSDependentVariableComponentFindMinimumForPart(PSDependentVariableRef theDependentVariable,
                                                      CFIndex componentIndex,
                                                      complexPart part,
                                                      CFIndex *memOffsetMin,
                                                      CFErrorRef *error);

/*!
 @function PSDependentVariableFindMinimumForPart
 @abstract Finds the minimum value and location in DependentVariable for the complex part.
 @param theDependentVariable the DependentVariable
 @param part the complex part
 @param memOffsetMin pointer to a CFIndex with the memOffset for the minimum value.
 @param componentIndexMin pointer to a CFIndex with the componentIndex for the minimum value.
 @result the minimum value.
 */
double PSDependentVariableFindMinimumForPart(PSDependentVariableRef theDependentVariable,
                                             complexPart part,
                                             CFIndex *memOffsetMin,
                                             CFIndex *componentIndexMin,
                                             CFErrorRef *error);


/*!
 @function PSDependentVariableComponentCreateArrayWithMinAndMaxForPart
 @abstract Finds the minimum and maximum value and locations in DependentVariable for the complex part.
 @param theDependentVariable the DependentVariable
 @param part the complex part
 @result array containing min and max.
 */
CFArrayRef PSDependentVariableComponentCreateArrayWithMinAndMaxForPart(PSDependentVariableRef theDependentVariable,
                                                                       CFIndex componentIndex,
                                                                       complexPart part);

/*!
 @function PSDependentVariableCreateArrayWithMinAndMaxForPart
 @abstract Finds the minimum and maximum value and locations in DependentVariable for the complex part.
 @param theDependentVariable the DependentVariable
 @param part the complex part
 @result array containing min and max.
 */
CFArrayRef PSDependentVariableCreateArrayWithMinAndMaxForPart(PSDependentVariableRef theDependentVariable,
                                                              complexPart part);

/*!
 @functiongroup Calculation with Block
 */

#pragma mark Calculation with Block

/*!
 @functiongroup Operations on Block
 */

#pragma mark  Operations on Block


/*!
 @function PSDependentVariableTakeAbsoluteValue
 @abstract Replace every element of the block with its absolute value.
 @param theBlock the block
 */
bool PSDependentVariableTakeAbsoluteValue(PSDependentVariableRef theDependentVariable, CFIndex componentIndex);


/*!
 @function PSDependentVariableRaiseValuesToAPower
 @abstract Replace every element of the block with its value raised to a power.
 @param theDependentVariable the dependent variable
 */
bool PSDependentVariableRaiseValuesToAPower(PSDependentVariableRef theDependentVariable, int power, CFErrorRef *error);

/*!
 @function PSDependentVariableConjugate
 @abstract Replace every element of the block with its complex conjugate.
 @param theBlock the block
 */
bool PSDependentVariableConjugate(PSDependentVariableRef theDependentVariable, CFIndex componentIndex);

/*!
 @function PSDependentVariableTakeComplexPart
 @abstract Replace every element of the block with its complex part.
 @param theBlock the block
 @param part is a constant specifying the complex Part: kPSRealPart, kPSImaginaryPart, kPSMagnitudePart, or kPSArgumentPart
 */
bool PSDependentVariableTakeComplexPart(PSDependentVariableRef theDependentVariable, CFIndex componentIndex, complexPart part);

/*!
 @function PSDependentVariableCombineMagnitudeWithArgument
 @abstract Create a new block by combining a magnitude block with an argument block.
 @param magnitude the magnitude block
 @param argument the argument block
 */
bool PSDependentVariableCombineMagnitudeWithArgument(PSDependentVariableRef magnitude, PSDependentVariableRef argument);

/*!
 @function PSDependentVariableZeroPartInRange
 @abstract zero the complex part of range of elements in the block.
 @param theDependentVariable the components
 @param range the index of first element whose part is to be zeroed and the length
 @param part is a constant specifying the complex Part: kPSRealPart, kPSImaginaryPart, kPSMagnitudePart, or kPSArgumentPart
 */
bool PSDependentVariableZeroPartInRange(PSDependentVariableRef theDependentVariable,
                                        CFIndex componentIndex,
                                        CFRange range,
                                        complexPart part);


/*!
 @function PSDependentVariableConvertToUnit
 @abstract Creates a block by converting an existing block to a different element type.
 @param theBlock the block
 @param unit the unit
 @result the new block.
 */
bool PSDependentVariableConvertToUnit(PSDependentVariableRef theBlock, PSUnitRef unit, CFErrorRef *error);

/*!
 @functiongroup Block element : Scalar Operations
 */

#pragma mark Block element : Scalar Operations

/*!
 @function PSDependentVariableAddScalarToValueAtMemOffset
 @abstract Add the scalar to the value at memOffset
 @param theDependentVariable the Dependent Variable
 @param memOffset a CFIndex with the index of the value to set.
 @param theScalar the scalar.
 */
bool PSDependentVariableAddScalarToValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                    CFIndex componentIndex,
                                                    CFIndex memOffset,
                                                    PSScalarRef theScalar,
                                                    CFErrorRef *error);

/*!
 @functiongroup Block : Scalar Operations
 */

#pragma mark Block : Scalar Operations

/*!
 @function PSDependentVariableMultiplyValuesByDimensionlessRealConstant
 @abstract Multiply all values in the block by a dimensionless real constant
 @param theBlock the block
 @param constant the dimensionless real constant.
 */
bool PSDependentVariableMultiplyValuesByDimensionlessRealConstant(PSDependentVariableRef theDependentVariable,
                                                                  CFIndex componentIndex,
                                                                  double constant);

/*!
 @function PSDependentVariableMultiplyValuesByDimensionlessComplexConstant
 @abstract Multiply all values in the block by a dimensionless complex constant
 @param theBlock the block
 @param constant the dimensionless complex constant.
 */
bool PSDependentVariableMultiplyValuesByDimensionlessComplexConstant(PSDependentVariableRef theDependentVariable,
                                                                     CFIndex componentIndex,
                                                                     double complex constant);

/*!
 @function PSDependentVariableMultiplyByScalar
 @abstract Multiply every value in the block by a scalar
 @param theBlock the block
 @param theScalar the scalar multiplier
 @param error a pointer to a CFErrorRef (i.e. a pointer to a pointer).  If an error occurs a CFError will be created
 with a description of the error and returned in the error variable.   If NULL is passed then no error description
 will be generated.
 @result a boolean indicating if the operation was successful.   If the operation fails then a CFError will be created
 and returned in the error variable, provided the pointer to the variable is not NULL;
 */
bool PSDependentVariableMultiplyByScalar(PSDependentVariableRef theDependentVariable, PSScalarRef theScalar, CFErrorRef *error);

/*!
 @functiongroup Block : Block Operations
 */

#pragma mark Block : Block Operations


/*!
 @function PSDependentVariableAppend
 @abstract Append  values in the input block to the values in the target block
 @param target the target block
 @param input2 the input block.
 @param error a pointer to a CFErrorRef (i.e. a pointer to a pointer).  If an error occurs a CFError will be created
 with a description of the error and returned in the error variable.   If NULL is passed then no error description
 will be generated.
 @result a boolean indicating if the operation was successful.   If the operation fails then a CFError will be created
 and returned in the error variable, provided the pointer to the variable is not NULL;
 */
bool PSDependentVariableAppend(PSDependentVariableRef target, PSDependentVariableRef input2, CFErrorRef *error);

/*!
 @function PSDependentVariableAdd
 @abstract Add elementwise the values in the input block to the values in the target block
 @param target the target block
 @param input2 the input block.
 @param error a pointer to a CFErrorRef (i.e. a pointer to a pointer).  If an error occurs a CFError will be created
 with a description of the error and returned in the error variable.   If NULL is passed then no error description
 will be generated.
 @result a boolean indicating if the operation was successful.   If the operation fails then a CFError will be created
 and returned in the error variable, provided the pointer to the variable is not NULL;
 */
bool       PSDependentVariableAdd(PSDependentVariableRef target, PSDependentVariableRef input2, CFErrorRef *error);

/*!
 @function PSDependentVariableSubtract
 @abstract Subtract elementwise the values in the input block from the values in the target block
 @param target the target block
 @param input2 the input block.
 @param error a pointer to a CFErrorRef (i.e. a pointer to a pointer).  If an error occurs a CFError will be created
 with a description of the error and returned in the error variable.   If NULL is passed then no error description
 will be generated.
 @result a boolean indicating if the operation was successful.   If the operation fails then a CFError will be created
 and returned in the error variable, provided the pointer to the variable is not NULL;
 */
bool       PSDependentVariableSubtract(PSDependentVariableRef target, PSDependentVariableRef input2, CFErrorRef *error);

/*!
 @function PSDependentVariableMultiply
 @abstract Multiply elementwise the values in the input block by the values in the target block
 @param target the target block
 @param input2 the input block.
 @param error a pointer to a CFErrorRef (i.e. a pointer to a pointer).  If an error occurs a CFError will be created
 with a description of the error and returned in the error variable.   If NULL is passed then no error description
 will be generated.
 @result a boolean indicating if the operation was successful.   If the operation fails then a CFError will be created
 and returned in the error variable, provided the pointer to the variable is not NULL;
 */
bool       PSDependentVariableMultiply(PSDependentVariableRef target, PSDependentVariableRef input2, CFErrorRef *error);

/*!
 @functiongroup Strings and Archiving
 */

#pragma mark Strings and Archiving

#pragma mark Operations requiring array of dimensions
/*!
 @functiongroup Operations requiring array of dimensions
 */

/*!
 @function PSDependentVariableSetValueAtCoordinateIndexes
 @abstract Sets the response at the coordinate indices.
 @param theDependentVariable the signal
 @param dimensions a CFArray containing the dimensions for the signal
 @param theIndexes a PSIndexArray containing indices where the response is to be set.
 @param value the value to set.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result true or false depending on success of operation.
 */
bool PSDependentVariableSetValueAtCoordinateIndexes(PSDependentVariableRef theDependentVariable,
                                                    CFIndex componentIndex,
                                                    CFArrayRef dimensions,
                                                    PSIndexArrayRef theIndexes,
                                                    PSScalarRef value,
                                                    CFErrorRef *error);



#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSDependentVariableEqual
 @abstract Determines if the two blocks are equal in every attribute.
 @param input1 The first block.
 @param input2 The second block.
 @result true or false.
 */
bool PSDependentVariableEqual(PSDependentVariableRef input1, PSDependentVariableRef input2);


#pragma mark Operations requiring array of dimensions
/*!
 @functiongroup Operations requiring array of dimensions
 */

/*!
 @function PSDependentVariableSetValueAtCoordinateIndexes
 @abstract Sets the response at the coordinate indices.
 @param theDependentVariable the signal
 @param dimensions a CFArray containing the dimensions for the signal
 @param theIndexes a PSIndexArray containing indices where the response is to be set.
 @param response the response to set.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result true or false depending on success of operation.
 */
bool PSDependentVariableSetValueAtCoordinateIndexes(PSDependentVariableRef theDependentVariable,
                                                    CFIndex componentIndex,
                                                    CFArrayRef dimensions,
                                                    PSIndexArrayRef theIndexes,
                                                    PSScalarRef value,
                                                    CFErrorRef *error);

/*!
 @function PSDependentVariableCreateCrossSection
 @abstract Creates a copy of the cross section through the specified dimension and coordinate indices.
 @param theDependentVariable the signal from which to extract the cross section
 @param dimensions a CFArray containing the dimensions for the signal
 @param indexPairs the dimension and coordinate index pairs specifying the signal dimensions and coordinates through which the cross section will be taken.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result the cross section.
 @discussion the number of dimensions of the cross-section and its location inside the signal is specified by the values in the PSIndexPairSet indexPairs.   The PSIndexPair type is a structure containing two integers: here they are a dimension index and a coordinate index.  The dimension index can only appear once in the index pair set. A coordinate index has no such limitation.    */
PSDependentVariableRef PSDependentVariableCreateCrossSection(PSDependentVariableRef theDependentVariable,
                                                             CFArrayRef dimensions,
                                                             PSIndexPairSetRef indexPairs,
                                                             CFErrorRef *error);
bool PSDependentVariableCrossSection(PSDependentVariableRef theDependentVariable,
                                     CFArrayRef theDependentVariableDimensions,
                                     PSIndexPairSetRef indexPairs,
                                     CFErrorRef *error);

/*!
 @function PSDependentVariableSetCrossSection
 @abstract Replaces the cross section through the specified dimension and coordinate indices.
 @param theDependentVariable the signal into which the cross-section will be placed
 @param theDependentVariableDimensions a CFArray containing the dimensions for the signal
 @param indexPairs the dimension and coordinate index pairs specifying the signal dimensions and coordinates where the cross section will be placed.
 @result the cross section.
 @discussion the number of dimensions of the cross-section and its location inside the signal is specified by the values in the PSIndexPairSet indexPairs.   The PSIndexPair type is a structure containing two integers: here they are a dimension index and a coordinate index.  The dimension index can only appear once in the index pair set. A coordinate index has no such limitation.
 */
bool PSDependentVariableSetCrossSection(PSDependentVariableRef theDependentVariable,
                                        CFArrayRef theDependentVariableDimensions,
                                        PSIndexPairSetRef indexPairs,
                                        PSDependentVariableRef theCrossSection,
                                        CFArrayRef theCrossSectionDimensions);


/*!
 @function PSDependentVariableProjectOutDimension
 @abstract Creates a signal by projecting out the dimension specified by dimIndex and coordinate index limits
 @param theDependentVariable the signal from which the projection will be calculated
 @param dimensions a CFArray containing the dimensions for the signal
 @param lowerIndex the lower coordinate index
 @param upperIndex the upper coordinate index
 @param dimIndex the dimension index
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result the projection.
 */
bool PSDependentVariableProjectOutDimension(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFIndex lowerIndex,
                                            CFIndex upperIndex,
                                            CFIndex dimIndex,
                                            CFErrorRef *error);


/*!
 @function PSDependentVariableShiftAlongDimension
 @abstract Creates a signal by shifting the signal along a specific dimension
 @param theDependentVariable the input signal
 @param dimensions a CFArray containing the dimensions for the signal
 @param dimensionIndex the dimension index
 @param shift the integer shift
 @param wrap boolean indicating whether signal is wrapped back.  If false signal shifted past dimension limit is lost.
 @result a new shifted signal.
 */
bool PSDependentVariableShiftAlongDimension(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFIndex dimensionIndex,
                                            CFIndex shift,
                                            bool wrap,
                                            CFIndex level);

/*
 @function PSDependentVariableTransposeDimensions
 */
void PSDependentVariableTransposeDimensions(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFIndex dimensionIndex1,
                                            CFIndex dimensionIndex2);

/*!
 @function PSDependentVariableTrimAlongDimension
 */
bool PSDependentVariableTrimAlongDimension(PSDependentVariableRef theDependentVariable,
                                           CFMutableArrayRef dimensions,
                                           CFIndex dimensionIndex,
                                           char *trimSide,
                                           CFIndex lengthPerSide);

/*!
 @function PSDependentVariableFillAlongDimension
 */
bool PSDependentVariableFillAlongDimension(PSDependentVariableRef theDependentVariable,
                                           CFMutableArrayRef dimensions,
                                           CFIndex dimensionIndex,
                                           PSScalarRef theFillConstant,
                                           char *fillSide,
                                           CFIndex lengthPerSide);

/*!
 @function PSDependentVariableRepeatAlongDimension
 @abstract Repeating the signal along a specific dimension
 @param theDependentVariable the input signal
 @param dimensions a CFArray containing the dimensions for the signal
 @param dimensionIndex the dimension index
 */
void PSDependentVariableRepeatAlongDimension(PSDependentVariableRef theDependentVariable,
                                             CFArrayRef dimensions,
                                             CFIndex dimensionIndex);

/*!
 @function PSDependentVariableCreateByInterleavingAlongDimension
 @abstract Creates a signal by interleaving two signals along a specific dimension
 @param signal1 the first signal
 @param signal2 the second signal
 @param dimensions a CFArray containing the dimensions for the signal
 @param interleavedDimensionIndex the dimension index along which the signals are interleaved.
 @result the new signal.
 */
bool PSDependentVariableInterleaveAlongDimension(PSDependentVariableRef input1,
                                                 PSDependentVariableRef input2,
                                                 CFArrayRef dimensions,
                                                 CFIndex interleavedDimensionIndex,
                                                 CFErrorRef *error);

/*!
 @function PSDependentVariableCreateBySeparatingInterleavedSignalsAlongDimension
 @abstract Returns an array containing two signals created by separating interleaved responses along a specific dimension
 @param input the input signal
 @param dimensions a CFArray containing the dimensions for the signal
 @param dimensionIndex the dimension index along which the signals are interleaved.
 @result a CFArray containing the two separated signals.
 */
bool PSDependentVariableSeparateInterleavedSignalsAlongDimension(PSDependentVariableRef input,
                                                                     CFArrayRef dimensions,
                                                                     CFIndex dimensionIndex,
                                                                     PSDependentVariableRef odd,
                                                                     PSDependentVariableRef even,
                                                                     CFErrorRef *error);

/*!
 @function PSDependentVariableCreateByRepeatingIntoNewDimension
 @abstract Creates a new signal by repeating the existing signal into a new dimnension
 @param theDependentVariable the input signal
 @param dimensions a CFArray containing the dimensions for the signal
 @param newDimension the new dimension
 @result the new signal.
 */
PSDependentVariableRef PSDependentVariableCreateByRepeatingIntoNewDimension(PSDependentVariableRef theDependentVariable,
                                                                            CFArrayRef dimensions,
                                                                            PSDimensionRef newDimension);

bool PSDependentVariableAddParsedExpression(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFStringRef expression,
                                            CFErrorRef *error);

/*
 @function PSDependentVariableReverseAlongDimension
 */
PSDependentVariableRef PSDependentVariableReverseAlongDimension(PSDependentVariableRef theDependentVariable,
                                                                CFArrayRef dimensions,
                                                                CFIndex dimensionIndex,
                                                                CFIndex level);

/*
 @function PSDependentVariableCreateByReversingAlongDimension
 */
PSDependentVariableRef PSDependentVariableCreateByReversingAlongDimension(PSDependentVariableRef theDependentVariable,
                                                                          CFArrayRef dimensions,
                                                                          CFIndex dimensionIndex,
                                                                          CFIndex level,
                                                                          CFErrorRef *error);


#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */
CFStringRef PSDependentVariableCreateStringWithQuantityNameAndUnit(PSDependentVariableRef theDependentVariable);

void PSDependentVariableAddToArrayAsPList(PSDependentVariableRef theDependentVariable, CFMutableArrayRef array);

void PSDependentVariableAddComponentToArrayAsCSDMBase64(PSDependentVariableRef theDependentVariable, CFIndex componentIndex, CFMutableArrayRef array);
void PSDependentVariableAddComponentToArrayAsCSDMPList(PSDependentVariableRef theDependentVariable, CFMutableArrayRef array);
CFStringRef PSDependentVariableCreateBase64String(PSDependentVariableRef theDependentVariable, CFIndex componentIndex);

CFDataRef PSDependentVariableCreateCSDMComponentsData(PSDependentVariableRef theDependentVariable);

PSDependentVariableRef PSDependentVariableCreateWithCSDMPList(CFDictionaryRef dependentVariableDictionary,
                                                              CFArrayRef dimensions,
                                                              CFArrayRef folderContents,
                                                              PSDataset *theDataset,
                                                              CFErrorRef *error);
CFDictionaryRef PSDependentVariableCreateCSDMPList(PSDependentVariableRef theDependentVariable,
                                                   CFArrayRef dimensions,
                                                   bool external,
                                                   bool base64Encoding);

#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSDependentVariableEqualWithSameReducedDimensionality
 @abstract Compares two signal are equal and have the same reduced dimensionalities.
 @param input1 The first signal.
 @param input2 The second signal.
 @result true or false.
 */
bool PSDependentVariableEqualWithSameReducedDimensionality(PSDependentVariableRef input1, PSDependentVariableRef input2);

/*!
 @function PSDependentVariableEqual
 @abstract Determines if the two signals are equal in every attribute.
 @param input1 The first signal.
 @param input2 The second signal.
 @result true or false.
 */
bool PSDependentVariableEqual(PSDependentVariableRef input1, PSDependentVariableRef input2);

/*!
 @function PSDependentVariableIsSymmetricMatrixType
 */
bool PSDependentVariableIsSymmetricMatrixType(PSDependentVariableRef theDependentVariable, CFIndex *n);

/*!
 @function PSDependentVariableIsMatrixType
 */
bool PSDependentVariableIsMatrixType(PSDependentVariableRef theDependentVariable, CFIndex *m, CFIndex *n);
/*!
 @function PSDependentVariableIsVectorType
 */

bool PSDependentVariableIsVectorType(PSDependentVariableRef theDependentVariable, CFIndex *componentsCount);
/*!
 @function PSDependentVariableIsPixelType
 */
bool PSDependentVariableIsPixelType(PSDependentVariableRef theDependentVariable, CFIndex *componentsCount);
/*!
 @function PSDependentVariableIsScalarType
 */
bool PSDependentVariableIsScalarType(PSDependentVariableRef theDependentVariable);

CFArrayRef PSDependentVariableCreateMomentAnalysis(PSDependentVariableRef theDependentVariable,
                                                   CFArrayRef dimensions,
                                                   CFRange coordinateIndexRange,
                                                   CFIndex componentIndex);


