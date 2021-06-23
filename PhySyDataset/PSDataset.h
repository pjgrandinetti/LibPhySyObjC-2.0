//
//  PSDataset.h
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSDataset
 PSDataset represents a dataset.
 
 A datset has two essential attributes, an array of PSDependentVariables, each with identical number and type of response values, 
 and an array of PSDimensions, which define each of the dimensions along which the PSDependentVariables are sampled.
 
 @copyright PhySy
 @unsorted
 
 */

@class PSPlot;
@interface PSDataset : NSObject
{
    // CSDM attributes
    CFMutableArrayRef       dimensions;         // array of PSDimensions, each representing a uniformly sampled dimension.
    CFMutableArrayRef       dependentVariables; // Array with dependentVariables. Each element is a PSDependentVariable
    CFMutableArrayRef       tags;
    CFStringRef             description;

    // RMN extra attributes below
    CFStringRef             title;
    PSDatumRef              focus;
    PSDatumRef              previousFocus;
    CFMutableArrayRef       dimensionPrecedence; // ordered array of indexes, representing dimension precedence.
    CFDictionaryRef         metaData;
    CFMutableDictionaryRef  operations;
    // ***** End Persistent Attributes
    
    // ***** Transient Attributes
    PSDataset               *crossSectionAlongHorizontal;
    PSDataset               *crossSectionAlongVertical;
    PSDataset               *crossSectionAlongDepth;
    bool                    base64;
}
@end

/*!
 @typedef PSDatasetRef
 This is the type of a reference to PSDataset.
 */
typedef PSDataset *PSDatasetRef;

#define kPSDatasetSizeFromDimensions -1

#pragma mark Creators
/*!
 @functiongroup Creators
 */

PSDatasetRef PSDatasetCreateDefault(void);
bool PSDatasetSetDimensions(PSDatasetRef theDataset, CFArrayRef dimensions, CFArrayRef dimensionPrecedence);
PSDependentVariableRef PSDatasetAddDefaultDependentVariable(PSDatasetRef theDataset,
                                                          CFStringRef quantityType,
                                                          numberType elementType,
                                                          CFIndex size);
PSDependentVariableRef PSDatasetAddDefaultDependentVariableWithFillConstant(PSDatasetRef theDataset,
                                                                            CFStringRef quantityType,
                                                                            PSScalarRef fillConstant,
                                                                            CFIndex size);

/*
 @function PSDatasetCreate
 @abstract Creates a PSDataset
 @param signals a mutable array of PSDependentVariables, each with identical number and type of response values.
 @param dimensions an array of PSDimensions, each representing a uniformly sampled dimension.
 @param signalCoordinatesQuantities a mutable array of CFStrings with the quantity for each signal
*/
PSDatasetRef PSDatasetCreate(CFArrayRef         dimensions,
                             CFArrayRef         dimensionPrecedence,
                             CFArrayRef         dependentVariables,
                             CFArrayRef         tags,
                             CFStringRef        description,
                             CFStringRef        title,
                             PSDatumRef         focus,
                             PSDatumRef         previousFocus,
                             CFDictionaryRef    operations,
                             CFDictionaryRef    metaData);

/*!
 @function PSDatasetCreateWithDependentVariable
 */
PSDatasetRef PSDatasetCreateWithDependentVariable(CFArrayRef              dimensions,
                                                  CFArrayRef              dimensionPrecedence,
                                                  PSDependentVariableRef  dependentVariable,
                                                  CFArrayRef                tags,
                                                  CFStringRef             description,
                                                  CFStringRef             title,
                                                  PSDatumRef              focus,
                                                  PSDatumRef              previousFocus,
                                                  CFDictionaryRef         operations,
                                                  CFDictionaryRef         metaData);


/*!
 @function PSDatasetCreateCopy
 */
PSDatasetRef PSDatasetCreateCopy(PSDatasetRef theDataset);

/*!
 @function PSDatasetCreateComplexCopy
 */
PSDatasetRef PSDatasetCreateComplexCopy(PSDatasetRef input);

/*!
 @function PSDatasetCreateByConvertingToNumberType
 */
PSDatasetRef PSDatasetCreateByConvertingToNumberType(PSDatasetRef theDataset, numberType elementType);

/*!
 @functiongroup Accessors
 */

#pragma mark Accessors


/*!
 @function PSDatasetGetDependentVariables
 */
CFMutableArrayRef PSDatasetGetDependentVariables(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetPrecedenceOfDimensionAtIndex
 */
CFIndex PSDatasetGetPrecedenceOfDimensionAtIndex(PSDatasetRef theDataset, CFIndex dimIndex);

/*!
 @function PSDatasetGetDependentVariableAtFocus
 */
PSDependentVariableRef PSDatasetGetDependentVariableAtFocus(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetPlotAtFocus
 */
PSPlotRef PSDatasetGetPlotAtFocus(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetPlotAtFocus
 */
bool PSDatasetSetPlotAtFocus(PSDatasetRef theDataset, PSPlotRef thePlot);

PSDatasetRef PSDatasetCreateHorizontalCrossSectionAtFocus(PSDatasetRef theDataset);
PSDatasetRef PSDatasetCreateVerticalCrossSectionAtFocus(PSDatasetRef theDataset);
PSDatasetRef PSDatasetCreateDepthCrossSectionAtFocus(PSDatasetRef theDataset);

/*!
 @function PSDatasetDimensionsCount
 */
CFIndex PSDatasetDimensionsCount(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetDimensionAtIndex
 */
PSDimensionRef PSDatasetGetDimensionAtIndex(PSDatasetRef theDataset, CFIndex dimIndex);

/*!
 @function PSDatasetDimensionUnitAtIndex
 */
PSUnitRef PSDatasetDimensionUnitAtIndex(PSDatasetRef theDataset, CFIndex dimIndex);

/*!
 @function PSDatasetDimensionQuantityNameAtIndex
 */
CFStringRef PSDatasetDimensionQuantityNameAtIndex(PSDatasetRef theDataset, CFIndex dimIndex);

/*!
 @function PSDatasetDimensionLabelAtIndex
 */
CFStringRef PSDatasetDimensionLabelAtIndex(PSDatasetRef theDataset, CFIndex dimIndex);

/*!
 @function PSDatasetGetHorizontalDimensionIndex
 */
CFIndex PSDatasetGetHorizontalDimensionIndex(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetVerticalDimensionIndex
 */
CFIndex PSDatasetGetVerticalDimensionIndex(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetDepthDimensionIndex
 */
CFIndex PSDatasetGetDepthDimensionIndex(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetHorizontalDimensionIndex
 */
void PSDatasetSetHorizontalDimensionIndex(PSDatasetRef theDataset, CFIndex horizontalDimensionIndex);

/*!
 @function PSDatasetSetVerticalDimensionIndex
 */
void PSDatasetSetVerticalDimensionIndex(PSDatasetRef theDataset, CFIndex verticalDimensionIndex);

/*!
 @function PSDatasetSetDepthDimensionIndex
 */
void PSDatasetSetDepthDimensionIndex(PSDatasetRef theDataset, CFIndex depthDimensionIndex);

/*!
 @function PSDatasetCreateStringWithDimensionQuantityNameUnitAndIndex
 */
CFStringRef PSDatasetCreateStringWithDimensionQuantityNameUnitAndIndex(PSDatasetRef theDataset, CFIndex dimIndex);

/*!
 @function PSDatasetCreateStringWithDimensionLabelUnitAndIndex
 */
CFStringRef PSDatasetCreateStringWithDimensionLabelUnitAndIndex(PSDatasetRef theDataset, CFIndex dimIndex);


/*!
 @function PSDatasetHorizontalDimension
 */
PSDimensionRef PSDatasetHorizontalDimension(PSDatasetRef theDataset);

/*!
 @function PSDatasetVerticalDimension
 */
PSDimensionRef PSDatasetVerticalDimension(PSDatasetRef theDataset);

/*!
 @function PSDatasetDepthDimension
 */
PSDimensionRef PSDatasetDepthDimension(PSDatasetRef theDataset);

/*!
 @function PSDatasetDimensionsMutableCopy
 */
CFMutableArrayRef PSDatasetDimensionsMutableCopy(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetTitle
 */
CFStringRef PSDatasetGetTitle(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetTitle
 */
void PSDatasetSetTitle(PSDatasetRef theDataset, CFStringRef title);


/*!
 @function PSDatasetGetDimensions
 */
CFArrayRef PSDatasetGetDimensions(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetDimensionPrecedence
 */
CFMutableArrayRef PSDatasetGetDimensionPrecedence(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetDescription
 */
CFStringRef PSDatasetGetDescription(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetDescription
 */
void PSDatasetSetDescription(PSDatasetRef theDataset, CFStringRef comments);

/*!
 @function PSDatasetGetTags
 */
CFArrayRef PSDatasetGetTags(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetTags
 */
bool PSDatasetSetTags(PSDatasetRef theDataset, CFArrayRef tags);

/*!
 @function PSDatasetGetOperations
 */
CFMutableDictionaryRef PSDatasetGetOperations(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetMetaData
 */
CFDictionaryRef PSDatasetGetMetaData(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetMetaData
 */
void PSDatasetSetMetaData(PSDatasetRef theDataset, CFDictionaryRef metaData);

/*!
 @function PSDatasetDependentVariablesCount
 */
CFIndex PSDatasetDependentVariablesCount(PSDatasetRef theDataset);


/*!
 @function PSDatasetGetDependentVariableAtIndex
 */
PSDependentVariableRef PSDatasetGetDependentVariableAtIndex(PSDatasetRef theDataset,CFIndex dependentVariableIndex);

/*!
 @function PSDatasetSetDependentVariableAtIndex
 */
bool PSDatasetSetDependentVariableAtIndex(PSDatasetRef theDataset, CFIndex dependentVariableIndex, PSDependentVariableRef theDependentVariable);

/*!
 @function PSDatasetIndexOfDependentVariable
 */
CFIndex PSDatasetIndexOfDependentVariable(PSDatasetRef theDataset, PSDependentVariableRef theDependentVariable);

/*!
 @function PSDatasetRemoveDependentVariableAtIndex
 */
bool PSDatasetRemoveDependentVariableAtIndex(PSDatasetRef theDataset, CFIndex dependentVariableIndex);

/*!
 @function PSDatasetCreateByIncludingDatasetDependentVariables
 */
PSDatasetRef PSDatasetCreateByIncludingDatasetDependentVariables(PSDatasetRef theDataset, PSDatasetRef datasetToAppend, CFErrorRef *error);

/*!
 @function PSDatasetIncludeDatasetDependentVariables
 */
bool PSDatasetIncludeDatasetDependentVariables(PSDatasetRef theDataset, PSDatasetRef datasetToAppend, CFErrorRef *error);

/*!
 @function PSDatasetAppendDependentVariable
 */
bool PSDatasetAppendDependentVariable(PSDatasetRef theDataset, PSDependentVariableRef theDependentVariable, CFErrorRef *error);



#pragma mark Single Response Operations
/*!
 @functiongroup Single Response Operations
 */

/*!
 @function PSDatasetCreateResponseFromMemOffset
 */
PSScalarRef PSDatasetCreateResponseFromMemOffset(PSDatasetRef theDataset,
                                                 CFIndex dependentVariableIndex,
                                                 CFIndex componentIndex,
                                                 CFIndex memOffset);

/*!
 @function PSDatasetCreateResponseFromCoordinateIndexes
 */
PSScalarRef PSDatasetCreateResponseFromCoordinateIndexes(PSDatasetRef theDataset,
                                                         CFIndex dependentVariableIndex,
                                                         CFIndex componentIndex,
                                                         PSIndexArrayRef theIndexes);

/*!
 @function PSDatasetCreateResponseFromDimensionlessCoordinates
 */
PSScalarRef PSDatasetCreateResponseFromDimensionlessCoordinates(PSDatasetRef theDataset,
                                                                CFIndex dependentVariableIndex,
                                                                CFIndex componentIndex,
                                                                CFArrayRef theCoordinates,
                                                                CFErrorRef *error);

/*!
 @function PSDatasetCreateResponseFromRelativeCoordinates
 */
PSScalarRef PSDatasetCreateResponseFromRelativeCoordinates(PSDatasetRef theDataset,
                                                           CFIndex dependentVariableIndex,
                                                           CFIndex componentIndex,
                                                           CFArrayRef theCoordinates,
                                                           CFErrorRef *error);

/*!
 @function PSDatasetCreateResponseFromDisplayedCoordinates
 */
PSScalarRef PSDatasetCreateResponseFromDisplayedCoordinates(PSDatasetRef theDataset,
                                                            CFIndex dependentVariableIndex,
                                                            CFIndex componentIndex,
                                                            CFArrayRef theCoordinates,
                                                            CFErrorRef *error);


/*!
 @function PSDatasetCreateResponseFromMemOffsetForPart
 */
PSScalarRef PSDatasetCreateResponseFromMemOffsetForPart(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset,
                                                        complexPart part);

/*!
 @function PSDatasetCreateResponseFromCoordinateIndexesForPart
 */
PSScalarRef PSDatasetCreateResponseFromCoordinateIndexesForPart(PSDatasetRef theDataset,
                                                                CFIndex dependentVariableIndex,
                                                                CFIndex componentIndex,
                                                                PSIndexArrayRef theIndexes,
                                                                complexPart part);


/*!
 @function PSDatasetCreateResponseFromDimensionlessCoordinatesForPart
 */
PSScalarRef PSDatasetCreateResponseFromDimensionlessCoordinatesForPart(PSDatasetRef theDataset,
                                                                       CFIndex dependentVariableIndex,
                                                                       CFIndex componentIndex,
                                                                       CFArrayRef theCoordinates,
                                                                       complexPart part,
                                                                       CFErrorRef *error);

/*!
 @function PSDatasetCreateResponseFromRelativeCoordinatesForPart
 */
PSScalarRef PSDatasetCreateResponseFromRelativeCoordinatesForPart(PSDatasetRef theDataset,
                                                                  CFIndex dependentVariableIndex,
                                                                  CFIndex componentIndex,
                                                                  CFArrayRef theCoordinates,
                                                                  complexPart part,
                                                                  CFErrorRef *error);
/*!
 @function PSDatasetCreateResponseFromDisplayedCoordinatesForPart
 */
PSScalarRef PSDatasetCreateResponseFromDisplayedCoordinatesForPart(PSDatasetRef theDataset,
                                                                   CFIndex dependentVariableIndex,
                                                                   CFIndex componentIndex,
                                                                   CFArrayRef theCoordinates,
                                                                   complexPart part,
                                                                   CFErrorRef *error);

/*!
 @function PSDatasetResponseDoubleValueWithMemOffsetForPart
 */
double PSDatasetResponseDoubleValueWithMemOffsetForPart(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset,
                                                        complexPart part);



/*!
 @function PSDatasetCreateDatumFromMemOffset
 */
PSDatumRef PSDatasetCreateDatumFromMemOffset(PSDatasetRef theDataset,
                                             CFIndex dependentVariableIndex,
                                             CFIndex componentIndex,
                                             CFIndex memOffset);

/*!
 @function PSDatasetCreateDatumFromCoordinateIndexes
 */
PSDatumRef PSDatasetCreateDatumFromCoordinateIndexes(PSDatasetRef theDataset,
                                                     CFIndex dependentVariableIndex,
                                                     CFIndex componentIndex,
                                                     PSIndexArrayRef theIndexes,
                                                     CFErrorRef *error);

/*!
 @function PSDatasetCreateDatumFromDisplayedCoordinates
 */
PSDatumRef PSDatasetCreateDatumFromDisplayedCoordinates(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFIndex componentIndex,
                                                        CFArrayRef theCoordinates);

/*!
 @function PSDatasetCreateByProjectingOutDimension
 */
PSDatasetRef PSDatasetCreateByProjectingOutDimension(PSDatasetRef theDataset,
                                                     CFIndex lowerIndex,
                                                     CFIndex upperIndex,
                                                     CFIndex dimIndex,
                                                     CFErrorRef *error);

/*!
 @function PSDatasetCreateWithDependentVariable
 */
PSDatasetRef PSDatasetCreateKeepingOneDependentVariable(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFErrorRef *error);

/*!
 @function PSDatasetCreateKeepingOneComponent
 */
PSDatasetRef PSDatasetCreateKeepingOneComponent(PSDatasetRef theDataset,
                                                CFIndex dependentVariableIndex,
                                                CFIndex componentIndex,
                                                CFErrorRef *error);

/*!
 @function PSDatasetCreateCrossSection
 */
PSDatasetRef PSDatasetCreateCrossSection(PSDatasetRef theDataset,
                                         PSIndexPairSetRef indexPairs,
                                         CFErrorRef *error);

/*!
 @function PSDatasetSetCrossSection
 */
bool PSDatasetSetCrossSection(PSDatasetRef theDataset,
                              PSIndexPairSetRef indexPairs,
                              PSDatasetRef crossSection,
                              CFErrorRef *error);

/*!
 @function PSDatasetReplaceDimensionAtIndex
 */
bool PSDatasetReplaceDimensionAtIndex(PSDatasetRef theDataset, CFIndex dimIndex, PSDimensionRef dimension, CFErrorRef *error);

/*!
 @function PSDatasetRemoveDimensionAtIndex
 */
bool PSDatasetRemoveDimensionAtIndex(PSDatasetRef theDataset, CFIndex dimIndex);

/*!
 @function PSDatasetRemoveDimensionsAtIndexes
 */
bool PSDatasetRemoveDimensionsAtIndexes(PSDatasetRef theDataset, PSIndexSetRef dimensionIndexes);

/*!
 @function PSDatasetReplaceHorizontalDimensionWithDimension
 */
bool PSDatasetReplaceHorizontalDimensionWithDimension(PSDatasetRef theDataset, PSDimensionRef theDim, CFErrorRef *error);

/*!
 @function PSDatasetReplaceVerticalDimensionWithDimension
 */
bool PSDatasetReplaceVerticalDimensionWithDimension(PSDatasetRef theDataset, PSDimensionRef theDim, CFErrorRef *error);

/*!
 @function PSDatasetReplaceDepthDimensionWithDimension
 */
bool PSDatasetReplaceDepthDimensionWithDimension(PSDatasetRef theDataset, PSDimensionRef theDim, CFErrorRef *error);

/*!
 @function PSDatasetHasSameCoordinates
 */
bool PSDatasetHasSameCoordinates(PSDatasetRef input1, PSDatasetRef input2);

#pragma mark Signal Calculations
/*!
 @functiongroup Signal Calculations
 */

/*!
 @function PSDatasetCreateCSDMComponentsArray
 */
CFArrayRef PSDatasetCreateCSDMComponentsArray(PSDatasetRef theDataset, bool base64Encoding);

/*!
 @function PSDatasetCreateCSDMPList
 */
CFDictionaryRef PSDatasetCreateCSDMPList(PSDatasetRef theDataset, bool readOnly, bool base64Encoding, bool external, PSScalarRef latitude, PSScalarRef longitude, PSScalarRef altitude);

/*!
 @function PSDatasetCreateCSDMComponentsData
 0
 */
CFArrayRef PSDatasetCreateCSDMComponentsData(PSDatasetRef theDataset);


PSDatasetRef PSDatasetCreateWithCSDMPList(CFDictionaryRef dictionary, CFArrayRef folderContents, bool *readOnly, CFErrorRef *error);

PSDatasetRef PSDatasetCreateWithOldDataFormat(CFDataRef data, CFErrorRef *error);

/*!
 @function PSDatasetCreateData
 */
//CFDataRef PSDatasetCreateData(PSDatasetRef theDataset, CFErrorRef *error);

/*!
 @function PSDatasetCreateWithData
 */
//PSDatasetRef PSDatasetCreateWithData(CFDataRef data, CFErrorRef *error);


/*!
 @functiongroup Operations on Dataset
 */

#pragma mark  Operations on Dataset

/*!
 @function PSSDatasetSwapHorizontalAndVerticalDimensionPrecedence
 */
void PSSDatasetSwapHorizontalAndVerticalDimensionPrecedence(PSDatasetRef theDataset);

/*!
 @function PSSDatasetSwapVerticalAndDepthDimensionPrecedence
 */
void PSSDatasetSwapVerticalAndDepthDimensionPrecedence(PSDatasetRef theDataset);

/*!
 @function PSSDatasetSwapDepthAndHorizontalDimensionPrecedence
 */
void PSSDatasetSwapDepthAndHorizontalDimensionPrecedence(PSDatasetRef theDataset);



/*!
 @function PSDatasetCreateByMultiplyingDependentVariablesByScalar
 */
PSDatasetRef PSDatasetCreateByMultiplyingDependentVariablesByScalar(PSDatasetRef input, PSScalarRef scalar, CFErrorRef *error);

PSDatasetRef PSDatasetCreateByAddingParsedExpression(PSDatasetRef input, CFStringRef expression, CFErrorRef *error);

/*!
 @function PSDatasetCreateByConjugating
 */
PSDatasetRef PSDatasetCreateByConjugating(PSDatasetRef input, CFIndex level, CFErrorRef *error);

/*!
 @function PSDatasetCreateByZeroingPart
 */
PSDatasetRef PSDatasetCreateByZeroingPart(PSDatasetRef input, complexPart part, CFIndex level, CFErrorRef *error);

/*!
 @function PSDatasetCreateByTakingComplexPart
 */
PSDatasetRef PSDatasetCreateByTakingComplexPart(PSDatasetRef input, complexPart part, CFIndex level, CFErrorRef *error);

/*!
 @function PSDatasetCreateByCombiningMagnitudeWithArgument
 */
PSDatasetRef PSDatasetCreateByCombiningMagnitudeWithArgument(PSDatasetRef magnitude, PSDatasetRef argument, CFErrorRef *error);

/*!
 @function PSDatasetCreateByAdding
 */
PSDatasetRef PSDatasetCreateByAdding(PSDatasetRef dataset1, PSDatasetRef dataset2, CFErrorRef *error);

/*!
 @function PSDatasetCreateBySubtracting
 */
PSDatasetRef PSDatasetCreateBySubtracting(PSDatasetRef dataset1, PSDatasetRef dataset2, CFErrorRef *error);

/*!
 @function PSDatasetCreateByMultiplying
 */
PSDatasetRef PSDatasetCreateByMultiplying(PSDatasetRef dataset1, PSDatasetRef dataset2, CFErrorRef *error);

/*!
 @function PSDatasetCreateByTransposingDimensions
 */
PSDatasetRef PSDatasetCreateByTransposingDimensions(PSDatasetRef input, CFIndex dimensionIndex1, CFIndex dimensionIndex2, CFErrorRef *error);

/*!
 @function PSDatasetCreateBySeparatingInterleavedSignalsAlongDimension
 */
CFArrayRef PSDatasetCreateBySeparatingInterleavedSignalsAlongDimension(PSDatasetRef theDataset, CFIndex dimensionIndex, CFErrorRef *error);

/*!
 @function PSDatasetCreateByRepeatingAlongDimension
 */
PSDatasetRef PSDatasetCreateByRepeatingAlongDimension(PSDatasetRef theDataset, CFIndex dimensionIndex, CFErrorRef *error);

/*!
 @function PSDatasetCreateByAppendingValuesAlongVerticalOntoHorizontalDimension
 */
PSDatasetRef PSDatasetCreateByAppendingValuesAlongVerticalOntoHorizontalDimension(PSDatasetRef theDataset, CFStringRef title, CFErrorRef *error);

/*!
 @function PSDatasetCreateBySeparatingAppendedValuesIntoNewDimension
 */
PSDatasetRef PSDatasetCreateBySeparatingAppendedValuesIntoNewDimension(PSDatasetRef theDataset, PSDimensionRef newDimension, CFStringRef title, CFErrorRef *error);


/*!
 @function PSDatasetCreateByTrimingAlongDimension
 */
PSDatasetRef PSDatasetCreateByTrimingAlongDimension(PSDatasetRef theDataset,
                                                    CFIndex dimensionIndex,
                                                    char* trimSide,
                                                    CFIndex lengthPerSide);

/*!
 @function PSDatasetCreateByFillingAlongDimensions
 */
PSDatasetRef PSDatasetCreateByFillingAlongDimensions(PSDatasetRef theDataset,
                                                     CFIndex dimensionIndex,
                                                     CFArrayRef fillConstants,
                                                     char *fillSide,
                                                     CFIndex lengthPerSide);

/*!
 @function PSDatasetCreateByReversingAlongDimension
 */
PSDatasetRef PSDatasetCreateByReversingAlongDimension(PSDatasetRef theDataset,
                                                      CFIndex level,
                                                      CFErrorRef *error);

/*!
 @function PSDatasetCreateByRepeatingIntoNewDimension
 */
PSDatasetRef PSDatasetCreateByRepeatingIntoNewDimension(PSDatasetRef theDataset, PSDimensionRef newDimension, CFErrorRef *error);

/*!
 @function PSDatasetCreateByInterleavingAlongDimension
 */
PSDatasetRef PSDatasetCreateByInterleavingAlongDimension(PSDatasetRef dataset1,
                                                         PSDatasetRef dataset2,
                                                         CFIndex interleavedDimensionIndex,
                                                         CFErrorRef *error);

/*!
 @function PSDatasetCreateByShiftingAlongDimension
 */
PSDatasetRef PSDatasetCreateByShiftingAlongDimension(PSDatasetRef theDataset,
                                                     CFIndex dimensionIndex,
                                                     CFIndex shift,
                                                     bool wrap,
                                                     CFIndex level,
                                                     CFErrorRef *error);

PSDatasetRef PSDatasetCreateByScalingHorizontalAndVerticalDimensions(PSDatasetRef input,
                                                                     CFIndex newHorizontalNpts,
                                                                     CFIndex newVerticalNpts,
                                                                     CFErrorRef *error);


CFArrayRef PSDatasetCreateMomentAnalysis(PSDatasetRef theDataset, CFRange coordinateIndexRange);

/*!
 @function PSDatasetGet1DCrossSectionAlongHorizontal
 */
PSDatasetRef PSDatasetGet1DCrossSectionAlongHorizontal(PSDatasetRef theDataset);

/*!
 @function PSDatasetSet1DCrossSectionAlongHorizontal
 */
void PSDatasetSet1DCrossSectionAlongHorizontal(PSDatasetRef theDataset, PSDatasetRef crossSection);

/*!
 @function PSDatasetGet1DCrossSectionAlongVertical
 */
PSDatasetRef PSDatasetGet1DCrossSectionAlongVertical(PSDatasetRef theDataset);

/*!
 @function PSDatasetGet1DCrossSectionAlongVertical
 */
void PSDatasetSet1DCrossSectionAlongVertical(PSDatasetRef theDataset, PSDatasetRef crossSection);

/*!
 @function PSDatasetGet1DCrossSectionAlongDepth
 */
PSDatasetRef PSDatasetGet1DCrossSectionAlongDepth(PSDatasetRef theDataset);

/*!
 @function PSDatasetSet1DCrossSectionAlongDepth
 */
void PSDatasetSet1DCrossSectionAlongDepth(PSDatasetRef theDataset, PSDatasetRef crossSection);

/*!
 @function PSDatasetReset1DCrossSections
 */
void PSDatasetReset1DCrossSections(PSDatasetRef theDataset);

/*!
 @function PSDatasetResetFocus
 */
bool PSDatasetResetFocus(PSDatasetRef theDataset);

/*!
 @function PSDatasetGetFocus
 */
PSDatumRef PSDatasetGetFocus(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetFocus
 */
bool PSDatasetSetFocus(PSDatasetRef theDataset, PSDatumRef newFocus);

/*!
 @function PSDatasetGetPreviousFocus
 */
PSDatumRef PSDatasetGetPreviousFocus(PSDatasetRef theDataset);

/*!
 @function PSDatasetSetPreviousFocus
 */
bool PSDatasetSetPreviousFocus(PSDatasetRef theDataset, PSDatumRef newFocus);

/*!
 @function PSDatasetSetReferenceOffsetToZeroAtFocus
 */
bool PSDatasetSetReferenceOffsetToZeroAtFocus(PSDatasetRef theDataset, CFErrorRef *error);

/*!
 @function PSDatasetMoveFocusToMaximumMagnitudeResponse
 */
bool PSDatasetMoveFocusToMaximumMagnitudeResponse(PSDatasetRef theDataset, CFErrorRef *error);

/*!
 @function PSDatasetMoveFocusToMinimumMagnitudeResponse
 */
bool PSDatasetMoveFocusToMinimumMagnitudeResponse(PSDatasetRef theDataset, CFErrorRef *error);

/*!
 @function PSDatasetMoveReferenceOffsetsToGiveFocusNewCoordinates
 */
bool PSDatasetMoveReferenceOffsetsToGiveFocusNewCoordinates(PSDatasetRef theDataset, CFArrayRef newFocusCoordinates, CFErrorRef *error);

#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */




/*!
 @functiongroup Tests
 */

#pragma mark Tests

/*!
 @function PSDatasetHasSameReducedDimensionalities
 */
bool PSDatasetHasSameReducedDimensionalities(PSDatasetRef input1, PSDatasetRef input2);


bool PSDatasetGetBase64(PSDatasetRef theDataset);
