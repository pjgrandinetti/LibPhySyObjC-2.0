//
//  PSDimension.h
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#define kPSDimensionOriginOffset2 CFSTR("origin_offset")
#define kPSDimensioninverseQuantityName2 CFSTR("inverse_quantity")
#define kPSDimensionLabel2 CFSTR("label")


#define kPSDimensionVersion CFSTR("version")
#define kPSDimensionQuantity CFSTR("quantity")
#define kPSDimensionLabel CFSTR("label")
#define kPSDimensionDescription CFSTR("description")
#define kPSDimensioninverseQuantityName CFSTR("inverseQuantityName")
#define kPSDimensionInverseLabel CFSTR("inverseLabel")
#define kPSDimensionInverseDescription CFSTR("inverseDescription")
#define kPSDimensionNpts CFSTR("npts")
#define kPSDimensionIncrement CFSTR("samplingInterval")
#define kPSDimensionOriginOffset CFSTR("originOffset")
#define kPSDimensionMadeDimensionless CFSTR("madeDimensionless")
#define kPSDimensionInverseOriginOffset CFSTR("inverseOriginOffset")
#define kPSDimensionInverseMadeDimensionless CFSTR("inverseMadeDimensionless")
#define kPSDimensionReferenceOffset CFSTR("referenceOffset")
#define kPSDimensionInverseSamplingInterval CFSTR("inverseSamplingInterval")
#define kPSDimensionInverseReferenceOffset CFSTR("inverseReferenceOffset")
#define kPSDimensionNonUniformCoordinates CFSTR("nonUniformCoordinates")
#define kPSDimensionFTFlag CFSTR("ftFlag")
#define kPSDimensionReverse CFSTR("reverse")
#define kPSDimensionPeriodic CFSTR("periodic")
#define kPSDimensionInverseReverse CFSTR("inverseReverse")
#define kPSDimensionInversePeriodic CFSTR("inversePeriodic")
#define kPSDimensionMetaData CFSTR("metaData")

typedef enum dimensionScaling {
    kDimensionScalingNone,
    kDimensionScalingNMR
} dimensionScaling;

@interface PSDimension : NSObject
{
    // Dimension
    CFStringRef quantityName;
    CFStringRef label;
    CFStringRef description;

    bool    fft;
    CFDictionaryRef metaData;

    PSScalarRef period;
    PSScalarRef originOffset;
    PSScalarRef referenceOffset;
    
    bool    periodic;
    bool    madeDimensionless;
    
    // Reciprocal Dimension
    CFStringRef inverseQuantityName;
    CFStringRef inverseLabel;
    CFStringRef inverseDescription;

    PSScalarRef inverseOriginOffset;
    PSScalarRef inverseReferenceOffset;
    PSScalarRef inversePeriod;

    bool    inversePeriodic;
    bool    inverseMadeDimensionless;
    
    CFIndex npts;
    PSScalarRef increment;
    PSScalarRef inverseIncrement;

    CFMutableArrayRef nonUniformCoordinates;
}

@end

/*!
 @typedef PSDimensionRef
 This is the type of a reference to PSDimension.
 */
typedef PSDimension *PSDimensionRef;


@interface PSCoreDimension : NSObject
{
    CFStringRef label;
    CFStringRef description;
    CFDictionaryRef metaData;
}
@end
typedef PSCoreDimension *PSCoreDimensionRef;

@interface PSLabeledDimension : PSCoreDimension
{
    CFMutableArrayRef labels;
}
@end
typedef PSLabeledDimension *PSLabeledDimensionRef;

@interface PSQuantitativeDimension : PSCoreDimension
{
    CFStringRef quantityName;
    PSScalarRef referenceOffset;
    PSScalarRef originOffset;
    PSScalarRef period;

    bool periodic;
    dimensionScaling scaling;
}
@end
typedef PSQuantitativeDimension *PSQuantitativeDimensionRef;

@interface PSMonotonicDimension : PSQuantitativeDimension
{
    CFMutableArrayRef coordinates;
    PSQuantitativeDimensionRef reciprocal;
}
@end
typedef PSMonotonicDimension *PSMonotonicDimensionRef;

@interface PSLinearDimension : PSQuantitativeDimension
{
    CFIndex count;
    PSScalarRef increment;
    PSScalarRef inverseIncrement;
    PSQuantitativeDimensionRef reciprocal;
    bool    fft;
}
@end
typedef PSLinearDimension *PSLinearDimensionRef;



/*!
 @header PSDimension
 PSDimension describes a uniformly sampled coordinate.   Each sampling along the coordinate is
 associated with an integer index value.   This index could be mapped to a number of possible
 coordinate systems:
 
 (1) Index coordinate system
 
 x_index = index
 
 
 (2) Referenced Index coordinate system
 
 x_index = index + referenceOffset/increment
 
 
 (3) Relative Unreferenced Coordinate System, where the mapping is
 
 x_relative_unreferenced = index * increment
 
 
 (4) Relative Referenced Coordinate System, where the mapping is
 
 x_relative = index * increment + referenceOffset
 
 
 (5) Absolute Coordinate System, where the mapping is
 
 x_absolute = index * increment + originOffset
 
 
 (6) Absolute Referenced Coordinate System, where the mapping is
 
 x_absolute_referenced = index * increment + originOffset + referenceOffset
 
 .
 (7) Absolute Dimensionless Coordinate System, where the mapping is
 
 x_dimensionless = (x_absolute - originOffset - referenceOffset)/(originOffset + referenceOffset)
                 = (index * increment  - referenceOffset)/ (originOffset + referenceOffset)

 Of these possibilities, we implement (4) and (7).   If originOffset is zero, then (7) defaults to (2).
 
 An array of PSDimension types is used to describe the multi-dimensional shape of a PSDependentVariable.
 @unsorted
 
 @copyright PhySy Ltd
 */

#pragma mark Creators
/*!
 @functiongroup Creators
 */

PSDimensionRef PSLinearDimensionCreateDefault(CFIndex npts, PSScalarRef increment, CFStringRef quantityName);
PSDimensionRef PSMonotonicDimensionCreateDefault(CFArrayRef coordinates, CFStringRef quantityName);

PSDimensionRef PSDImensionCreateFull(CFIndex npts,
                                     bool ftFlag,
                                     
                                     CFStringRef quantityName,
                                     CFStringRef label,
                                     CFStringRef description,
                                     PSScalarRef increment,
                                     PSScalarRef originOffset,
                                     PSScalarRef referenceOffset,
                                     PSScalarRef period,
                                     bool periodic,
                                     bool madeDimensionless,
                                     
                                     CFStringRef inverseQuantityName,
                                     CFStringRef inverseLabel,
                                     CFStringRef inverseDescription,
                                     PSScalarRef inverseIncrement,
                                     PSScalarRef inverseOriginOffset,
                                     PSScalarRef inverseReferenceOffset,
                                     PSScalarRef inversePeriod,
                                     bool inversePeriodic,
                                     bool inverseMadeDimensionless,
                                     
                                     CFArrayRef nonUniformCoordinates,
                                     CFDictionaryRef metaData,
                                     CFErrorRef *error);


/*!
 @function PSDimensionCreateCopy
 @abstract Creates a copy of a PSDimension
 @param theDimension The dimension.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful.     Can be NULL.
 @result a copy of the dimension.
 */
PSDimensionRef PSDimensionCreateCopy(PSDimensionRef theDimension);

///*!
// @function PSDimensionCreateInverseDimension
// @abstract Creates a new dimension by taking the inverse of a dimension
// @param theDimension The dimension.
// @param error a pointer to a CFError type for reporting errors if method was unsuccessful.     Can be NULL.
// @result the inverse dimension.
// */
//PSDimensionRef PSDimensionCreateInverseDimension(PSDimensionRef theDimension, CFErrorRef *error);

/*!
 @function PSDimensionMultiplyByScalar
 @abstract  multiply a dimension by a scalar
 @param theDimension The dimension.
 @param theScalar The scalar.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful.     Can be NULL.
 @result success.
 */
bool PSDimensionMultiplyByScalar(PSDimensionRef theDimension, PSScalarRef theScalar, CFErrorRef *error);

#pragma mark Accessors
/*!
 @functiongroup Accessors
 */

/*!
 @function PSDimensionGetNpts
 @abstract Returns the number of points for dimension.
 @param theDimension The dimension.
 @result the number of samples.
 */
CFIndex PSDimensionGetNpts(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetNpts
 @abstract Sets the number of points for a dimension.
 @param theDimension The dimension.
 @param npts The new number of points.
 */
bool PSDimensionSetNpts(PSDimensionRef theDimension, CFIndex npts);

PSUnitRef PSDimensionGetRelativeUnit(PSDimensionRef theDimension);
PSUnitRef PSDimensionGetRelativeInverseUnit(PSDimensionRef theDimension);

/*!
 @function PSDimensionGetDisplayedUnit
 @abstract Gets the unit for the dimension
 @param theDimension The dimension.
 @result the unit.
 */
PSUnitRef PSDimensionGetDisplayedUnit(PSDimensionRef theDimension);

/*!
 @function PSDimensionGetDisplayedUnitDimensionality
 @abstract Gets the unit dimensionality for the dimension
 @param theDimension The dimension.
 @result the dimensionality.
 */
PSDimensionalityRef PSDimensionGetDisplayedUnitDimensionality(PSDimensionRef theDimension);

/*!
 @function PSDimensionGetIncrement
 @abstract Gets the increments for the dimension
 @param theDimension The dimension.
 @result returns a PSScalar of the sampling Interval.
 */
PSScalarRef PSDimensionGetIncrement(PSDimensionRef theDimension);

PSScalarRef PSDimensionCreateIncrementInDisplayedCoordinate(PSDimensionRef theDimension);
bool PSDimensionHasNegativeIncrement(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetIncrement
 @abstract Sets the increments for the dimension
 @param theDimension The dimension.
 @param increment the new sampling Interval.
 */
void PSDimensionSetIncrement(PSDimensionRef theDimension, PSScalarRef increment);

/*!
 @function PSDimensionGetInverseIncrement
 @abstract Gets the sampling Intervals for the inverse dimension
 @param theDimension The dimension.
 @result returns a PSScalar of the inverse sampling Interval.
 */
PSScalarRef PSDimensionGetInverseIncrement(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetInverseIncrement
 @abstract Sets the increments for the inverse dimension
 @param theDimension The dimension.
 @param inverseIncrement the new inverse sampling Interval.
 */
void PSDimensionSetInverseIncrement(PSDimensionRef theDimension, PSScalarRef inverseIncrement);


/*!
 @function PSDimensionHasNonUniformGrid
 @abstract Determine whether dimension has a nonuniform grid
 @param theDimension The dimension.
 @result returns a boolean for the FT Flag.
 */
bool PSDimensionHasNonUniformGrid(PSDimensionRef theDimension);


bool PSDimensionGetFFT(PSDimensionRef theDimension);
void PSDimensionSetFFT(PSDimensionRef theDimension, bool fft);
void PSDimensionToggleFFT(PSDimensionRef theDimension);

bool PSDimensionCanBeMadeDimensionless(PSDimensionRef theDimension);
bool PSDimensionInverseCanBeMadeDimensionless(PSDimensionRef theDimension);
bool PSDimensionGetMadeDimensionless(PSDimensionRef theDimension);
bool PSDimensionSetMadeDimensionless(PSDimensionRef theDimension, bool madeDimensionless);

bool PSDimensionGetInverseMadeDimensionless(PSDimensionRef theDimension);
bool PSDimensionSetInverseMadeDimensionless(PSDimensionRef theDimension, bool madeDimensionless);

/*!
 @function PSDimensionGetPeriodic
 @abstract Gets the periodic Flag for the dimension
 @param theDimension The dimension.
 @result returns a boolean for the periodic Flag.
 */
bool PSDimensionGetPeriodic(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetPeriodic
 @abstract Sets the periodic Flag for the dimension
 @param theDimension The dimension.
 @param periodic the new periodic Flag.
 */
void PSDimensionSetPeriodic(PSDimensionRef theDimension, bool periodic);

/*!
 @function PSDimensionGetInversePeriodic
 @abstract Gets the periodic Flag for the inverse dimension
 @param theDimension The dimension.
 @result returns a boolean for the periodic Flag.
 */
bool PSDimensionGetInversePeriodic(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetPeriodic
 @abstract Sets the periodic Flag for the inverse dimension
 @param theDimension The dimension.
 @param periodic the new periodic Flag.
 */
void PSDimensionSetInversePeriodic(PSDimensionRef theDimension, bool periodic);

/*!
 @function PSDimensionGetReferenceOffset
 @abstract Gets the reference offset for the dimension
 @param theDimension The dimension.
 @result returns a PSScalar with the reference offset.
 */
PSScalarRef PSDimensionGetReferenceOffset(PSDimensionRef theDimension);

/*!
 @function PSDimensionZeroReferenceOffset
 @abstract Zero the reference offset for the dimension
 @param theDimension The dimension.
 */
void PSDimensionZeroReferenceOffset(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetReferenceOffset
 @abstract Sets the reference offset for the dimension
 @param theDimension The dimension.
 @param referenceOffset a PSScalar with the new reference offset.
 */
void PSDimensionSetReferenceOffset(PSDimensionRef theDimension, PSScalarRef referenceOffset);


PSScalarRef PSDimensionGetPeriod(PSDimensionRef theDimension);
void PSDimensionSetPeriod(PSDimensionRef theDimension, PSScalarRef period);
PSScalarRef PSDimensionGetInversePeriod(PSDimensionRef theDimension);
void PSDimensionSetInversePeriod(PSDimensionRef theDimension, PSScalarRef period);

/*!
 @function PSDimensionGetOriginOffset
 @abstract Gets the origin offset for the dimension
 @param theDimension The dimension.
 @result returns a PSScalar with the origin offset.
 */
PSScalarRef PSDimensionGetOriginOffset(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetOriginOffset
 @abstract Sets the origin offset for the dimension
 @param theDimension The dimension.
 @param originOffset a PSScalar with the new origin offset.
 */
void PSDimensionSetOriginOffset(PSDimensionRef theDimension, PSScalarRef originOffset);

/*!
 @function PSDimensionGetInverseOriginOffset
 @abstract Gets the inverse dimension offset for the dimension
 @param theDimension The dimension.
 @result returns a PSScalar with the inverse dimension offset.
 */
PSScalarRef PSDimensionGetInverseOriginOffset(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetInverseOriginOffset
 @abstract Sets the inverse dimension origin offset for the dimension
 @param theDimension The dimension.
 @param inverseOriginOffset a PSScalar with the new inverse dimension origin offset.
 */
void PSDimensionSetInverseOriginOffset(PSDimensionRef theDimension, PSScalarRef inverseOriginOffset);

/*!
 @function PSDimensionGetInverseReferenceOffset
 @abstract Gets the inverse dimension reference offset for the dimension
 @param theDimension The dimension.
 @result returns a PSScalar with the inverse dimension reference offset.
 */
PSScalarRef PSDimensionGetInverseReferenceOffset(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetInverseReferenceOffset
 @abstract Sets the reciprocal dimension reference offset for the dimension
 @param theDimension The dimension.
 @param inverseReferenceOffset a PSScalar with the new reciprocal dimension reference offset.
 */
void PSDimensionSetInverseReferenceOffset(PSDimensionRef theDimension, PSScalarRef inverseReferenceOffset);

/*!
 @function PSDimensionGetMetaData
 @abstract Gets the meta data mutable dictionary for the dimension
 @param theDimension The dimension.
 @result returns a CFMutableDictionary with the meta data.
 */
CFDictionaryRef PSDimensionGetMetaData(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetMetaData
 @abstract Sets the meta data mutable dictionary for the dimension
 @param theDimension The dimension.
 @param metaData the new meta data mutable dictionary.
 */
void PSDimensionSetMetaData(PSDimensionRef theDimension, CFDictionaryRef metaData);

/*!
 @function PSDimensionGetQuantityName
 @abstract Gets the quantity for the dimension
 @param theDimension The dimension.
 @result returns a CFString with the dimension quantity.
 */
CFStringRef PSDimensionGetQuantityName(PSDimensionRef theDimension);

/*!
 @function PSDimensionCopyDisplayedQuantityName
 @abstract Gets the displayed quantity for the dimension
 @param theDimension The dimension.
 @result returns a CFString with the dimension quantity.
 */
CFStringRef PSDimensionCopyDisplayedQuantityName(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetQuantityName
 @abstract Sets the quantity for the dimension
 @param theDimension The dimension.
 @param quantityName the new quantity.
 */
void PSDimensionSetQuantityName(PSDimensionRef theDimension, CFStringRef quantityName);

/*!
 @function PSDimensionGetLabel
 @abstract Gets the label for the dimension
 @param theDimension The dimension.
 @result returns a CFString with the dimension label.
 */
CFStringRef PSDimensionGetLabel(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetLabel
 @abstract Sets the label for the dimension
 @param theDimension The dimension.
 @param label the new label.
 */
void PSDimensionSetLabel(PSDimensionRef theDimension, CFStringRef label);

/*!
 @function PSDimensionGetDescription
 @abstract Gets the description for the dimension
 @param theDimension The dimension.
 @result returns a CFString with the dimension description.
 */
CFStringRef PSDimensionGetDescription(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetDescription
 @abstract Sets the description for the dimension
 @param theDimension The dimension.
 @param description the new description.
 */
void PSDimensionSetDescription(PSDimensionRef theDimension, CFStringRef description);

/*!
 @function PSDimensionGetInverseQuantityName
 @abstract Gets the inverse quantity for the dimension
 @param theDimension The dimension.
 @result returns a CFString with the inverse dimension quantity.
 */
CFStringRef PSDimensionGetInverseQuantityName(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetInverseQuantityName
 @abstract Sets the inverse quantity for the dimension
 @param theDimension The dimension.
 @param quantityName the new inverse quantity.
 */
void PSDimensionSetInverseQuantityName(PSDimensionRef theDimension, CFStringRef quantityName);

void PSDimensionMakeNiceUnits(PSDimensionRef theDimension);

/*!
 @function PSDimensionGetInverseLabel
 @abstract Gets the inverse label for the dimension
 @param theDimension The dimension.
 @result returns a CFString with the inverse dimension label.
 */
CFStringRef PSDimensionGetInverseLabel(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetInverseLabel
 @abstract Sets the reciprocal label for the dimension
 @param theDimension The dimension.
 @param label the new reciprocal label.
 */
void PSDimensionSetInverseLabel(PSDimensionRef theDimension, CFStringRef label);


/*!
 @function PSDimensionGetInverseDescription
 @abstract Gets the inverse description for the dimension
 @param theDimension The dimension.
 @result returns a CFString with the inverse dimension description.
 */
CFStringRef PSDimensionGetInverseDescription(PSDimensionRef theDimension);

/*!
 @function PSDimensionSetInverseDescription
 @abstract Sets the inverse description for the dimension
 @param theDimension The dimension.
 @param description the new inverse description.
 */
void PSDimensionSetInverseDescription(PSDimensionRef theDimension, CFStringRef description);


#pragma mark Operatioms
/*!
 @functiongroup Operations
 */

/*!
 @function PSDimensionInverse
 @abstract Inverts the dimensionality of the dimension
 @param theDimension The dimension.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful.     Can be NULL.
 @result returns true if successful, false otherwise.
 */
bool PSDimensionInverse(PSDimensionRef theDimension, CFErrorRef *error);

#pragma mark Coordinates and Indexes Core Mapping
/*!
 @functiongroup Coordinates and Indexes Assessors
 */

/*
 @function PSDimensionAliasIndex
 @abstract Aliases an index back into the bounds of the dimension
 @param theDimension The dimension.
 @result returns a CFIndex with the aliased index.
 */
CFIndex PSDimensionAliasIndex(PSDimensionRef theDimension, CFIndex index);

/*!
 @function PSDimensionCreateDimensionlessCoordinateFromIndex
 @abstract Maps a floating point index to a dimensionless coordinate
 @param theDimension The dimension.
 @result returns a PSScalar with the dimensionless coordinate.
 */
PSScalarRef PSDimensionCreateDimensionlessCoordinateFromIndex(PSDimensionRef theDimension, double index);

/*!
 @function PSDimensionCreateRelativeCoordinateFromIndex
 @abstract Maps a floating point index to a relative coordinate
 @param theDimension The dimension.
 @result returns a PSScalar with the relative coordinate.
 */
PSScalarRef PSDimensionCreateRelativeCoordinateFromIndex(PSDimensionRef theDimension, double index);

/*!
 @function PSDimensionCreateDisplayedCoordinateFromIndex
 @abstract Maps a floating point index to a displayed coordinate
 @param theDimension The dimension.
 @result returns a PSScalar with the displayed coordinate.
 */
PSScalarRef PSDimensionCreateDisplayedCoordinateFromIndex(PSDimensionRef theDimension, double index);

/*!
 @function PSDimensionIndexFromDimensionlessCoordinate
 @abstract Maps a dimensionless coordinate to a floating point index
 @param theDimension The dimension.
 @result returns a double with the index.
 */
double PSDimensionIndexFromDimensionlessCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate);

CFIndex PSDimensionClosestIndexToRelativeCoordinate(PSDimensionRef theDimension,
                                                    PSScalarRef coordinate);
CFIndex PSDimensionClosestIndexToDimensionlessCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate);

/*!
 @function PSDimensionIndexFromRelativeCoordinate
 @abstract Maps a relative coordinate to a floating point index
 @param theDimension The dimension.
 @result returns a double with the index.
 */
double PSDimensionIndexFromRelativeCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate);

CFIndex PSDimensionClosestIndexToDisplayedCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate);

/*!
 @function PSDimensionIndexFromDisplayedCoordinate
 @abstract Maps a displayed coordinate to a floating point index
 @param theDimension The dimension.
 @result returns a double with the index.
 */
double PSDimensionIndexFromDisplayedCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate);

CFIndex PSDimensionCoordinateCountInDisplayedCoordinateRange(PSDimensionRef theDimension, PSScalarRef minimum, PSScalarRef maximum);

#pragma mark Coordinates and Indexes

/*!
 @function PSDimensionLowestIndex
 @abstract Returns the lowest index used in displaying the dimension
 @param theDimension The dimension.
 @result returns a CFIndex with lowest index.
 */
CFIndex PSDimensionLowestIndex(PSDimensionRef theDimension);

/*!
 @function PSDimensionHighestIndex
 @abstract Returns the highest index used in displaying the dimension
 @param theDimension The dimension.
 @result returns a CFIndex with highest index.
 */
CFIndex PSDimensionHighestIndex(PSDimensionRef theDimension);

/*!
 @function PSDimensionCreateMinimumDisplayedCoordinate
 @abstract Returns the displayed coordinate associated with the lowest index
 @param theDimension The dimension.
 @result returns a PSScalar with minimum displayed coordinate.
 */
PSScalarRef PSDimensionCreateMinimumDisplayedCoordinate(PSDimensionRef theDimension);

/*!
 @function PSDimensionCreateMaximumDisplayedCoordinate
 @abstract Returns the displayed coordinate associated with the highest index
 @param theDimension The dimension.
 @result returns a PSScalar with maximum displayed coordinate.
 */
PSScalarRef PSDimensionCreateMaximumDisplayedCoordinate(PSDimensionRef theDimension);

float *PSDimensionCreateFloatVectorOfRelativeCoordinates(PSDimensionRef theDimension);
double *PSDimensionCreateDoubleVectorOfRelativeCoordinates(PSDimensionRef theDimension);
float *PSDimensionCreateFloatVectorOfDimensionlessCoordinates(PSDimensionRef theDimension);
double *PSDimensionCreateDoubleVectorOfDimensionlessCoordinates(PSDimensionRef theDimension);
float *PSDimensionCreateFloatVectorOfDisplayedCoordinates(PSDimensionRef theDimension);
double *PSDimensionCreateDoubleVectorOfDisplayedCoordinates(PSDimensionRef theDimension);

#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSDimensionEqual
 @abstract Tests if two dimension are equal
 @param input1 The first dimension.
 @param input2 The second dimension.
 @result returns true if equal, false otherwise.
 */
bool PSDimensionEqual(PSDimensionRef input1, PSDimensionRef input2);

/*!
 @function PSDimensionOriginOffsetIsZero
 @abstract Tests if originOffset of dimension is zero
 @param theDimension The dimension.
 @result returns true if equal, false otherwise.
 */
bool PSDimensionOriginOffsetIsZero(PSDimensionRef theDimension);


/*!
 @function PSDimensionHasIdenticalSampling
 @abstract Tests if two dimension have identical sampling
 @param input1 The first dimension.
 @param input2 The second dimension.
 @param reason will be replaced with string giving reason if false.
 @result returns true if equal, false otherwise.
 */
bool PSDimensionHasIdenticalSampling(PSDimensionRef input1, PSDimensionRef input2, CFStringRef *reason);

/*!
 @function PSDimensionIsDisplayedCoordinateInRange
 @abstract Tests if a displayed coordinate is inside the range.
 @param theDimension The dimension.
 @param coordinate The coordinate to be tested.
 @param minimum The coordinate for the range minimum.
 @param maximum The coordinate for the range maximum.
 @result returns true if equal, false otherwise.
 */
bool PSDimensionIsDisplayedCoordinateInRange(PSDimensionRef theDimension, PSScalarRef coordinate, PSScalarRef minimum, PSScalarRef maximum, CFErrorRef *error);

/*!
 @function PSDimensionIsRelativeCoordinateInRange
 @abstract Tests if a relative coordinate is inside the range.
 @param theDimension The dimension.
 @param coordinate The coordinate to be tested.
 @param minimum The coordinate for the range minimum.
 @param maximum The coordinate for the range maximum.
 @result returns true if equal, false otherwise.
 */
bool PSDimensionIsRelativeCoordinateInRange(PSDimensionRef theDimension, PSScalarRef coordinate, PSScalarRef minimum, PSScalarRef maximum, CFErrorRef *error);

/*!
 @function PSDimensionHasSameReducedDimensionality
 @abstract Tests if two dimensions have the same reduced dimensionality
 @param input1 The first dimension.
 @param input2 The second dimension.
 @result returns true if equal, false otherwise.
 */
bool PSDimensionHasSameReducedDimensionality(PSDimensionRef input1, PSDimensionRef input2);

#pragma mark Strings and Archiving

CFDictionaryRef PSDimensionCreateCSDMPList(PSDimensionRef theDimension);
PSDimensionRef PSDimensionCreateWithPList(CFDictionaryRef dictionary, CFErrorRef *error);
PSDimensionRef PSDimensionCreateWithCSDMPList(CFDictionaryRef dictionary, CFErrorRef *error);
CFDictionaryRef PSDimensionCreateCSDMPList(PSDimensionRef theDimension);

PSDimensionRef PSDimensionCreateWithData(CFDataRef data, CFErrorRef *error);

CFStringRef PSDimensionCreateStringValue(PSDimensionRef theDimension);

#pragma mark Dimension Arrays
/*!
 @functiongroup Dimension Arrays
 */

/*!
 @function PSDimensionCalculateSizeFromDimensions
 @abstract Calculates the size of a signal from an array of dimensions.
 @param dimensions A CFArray containing the dimensions.
 @result the size.
 */
CFIndex PSDimensionCalculateSizeFromDimensions(CFArrayRef dimensions);

/*!
 @function PSDimensionCalculateSizeFromDimensions
 @abstract Calculates the size of a signal from an array of dimensions.
 @param dimensions A CFArray containing the dimensions.
 @result the size.
 */
CFIndex PSDimensionCalculateSizeFromDimensionsIgnoreDimensions(CFArrayRef dimensions, PSIndexSetRef ignoredDimensions);

/*!
 @function PSDimensionMemOffsetFromCoordinateIndexes
 @abstract calculates the memory Offset in a multi-dimensional signal associated with the array of dimensions.
 @param dimensions A CFArray containing the dimensions.
 @param theIndices a PSIndexArray holding the indices.
 @result the memory offset.
 */
CFIndex PSDimensionMemOffsetFromCoordinateIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes);

/*!
 @function PSDimensionCreateCoordinateIndexesFromMemOffset
 @abstract Creates a PSIndexArray with the indexes in a multi-dimensional signal associated with a memory offset.
 @param memOffset the memory offset.
 @param dimensions A CFArray containing the dimensions.
 @result a PSIndexArray holding the indices
 */
PSMutableIndexArrayRef PSDimensionCreateCoordinateIndexesFromMemOffset(CFArrayRef dimensions, CFIndex memOffset);

CFIndex PSDimensionGetCoordinateIndexFromMemOffset(CFArrayRef dimensions, CFIndex memOffset, CFIndex dimensionIndex);

/*!
 @function PSDimensionCreateDimensionlessCoordinatesFromIndexes
 @abstract Creates a CFArray of PSScalar dimensionless coordinate values associated with an array of indices.
 @param dimensions A CFArray containing the dimensions.
 @param theIndexes a PSIndexArray holding the indices.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result a CFArray of PSScalar dimensionless coordinate values
 */
CFArrayRef PSDimensionCreateDimensionlessCoordinatesFromIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes);

/*!
 @function PSDimensionCreateRelativeCoordinatesFromIndexes
 @abstract Creates a CFArray of PSScalar relative coordinate values associated with an array of indices.
 @param dimensions A CFArray containing the dimensions.
 @param theIndexes a PSIndexArray holding the indices.
 @result a CFArray of PSScalar relative coordinate values
 */
CFArrayRef PSDimensionCreateRelativeCoordinatesFromIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes);

/*!
 @function PSDimensionCreateDisplayedCoordinatesFromIndexes
 @abstract Creates a CFArray of PSScalar displayed coordinate values associated with an array of indices.
 @param dimensions A CFArray containing the dimensions.
 @param theIndexes a PSIndexArray holding the indices.
 @result a CFArray of PSScalar displayed coordinate values
 */
CFMutableArrayRef PSDimensionCreateDisplayedCoordinatesFromIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes);

/*!
 @function PSDimensionCreateIndexesFromDimensionlessCoordinates
 @abstract Creates a PSIndexArray with the indexes from an array of PSScalar dimensionless coordinate values.
 @param dimensions A CFArray containing the dimensions.
 @param theCoordinates A CFArray containing the coordinates.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result a PSIndexArray holding the indices
 */
PSIndexArrayRef PSDimensionCreateIndexesFromDimensionlessCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error);

/*!
 @function PSDimensionCreateIndexesFromRelativeCoordinates
 @abstract Creates a PSIndexArray with the indexes from an array of PSScalar relative coordinate values.
 @param dimensions A CFArray containing the dimensions.
 @param theCoordinates A CFArray containing the coordinates.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result a PSIndexArray holding the indices
 */
PSIndexArrayRef PSDimensionCreateIndexesFromRelativeCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error);

/*!
 @function PSDimensionCreateCoordinateIndexesFromDisplayedCoordinates
 @abstract Creates a PSIndexArray with the indexes from an array of PSScalar displayed coordinate values.
 @param dimensions A CFArray containing the dimensions.
 @param theCoordinates A CFArray containing the coordinates.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result a PSIndexArray holding the indices
 */
PSIndexArrayRef PSDimensionCreateCoordinateIndexesFromDisplayedCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates);

/*!
 @function PSDimensionMemOffsetFromDimensionlessCoordinates
 @abstract Calculates the memory offset from an array of PSScalar dimensionless coordinate values.
 @param dimensions A CFArray containing the dimensions.
 @param theCoordinates A CFArray containing the dimensionless coordinates.
 @result the memory offset
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 */
CFIndex PSDimensionMemOffsetFromDimensionlessCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error);

/*!
 @function PSDimensionMemOffsetFromRelativeCoordinates
 @abstract Calculates the memory offset from an array of PSScalar relative coordinate values.
 @param dimensions A CFArray containing the dimensions.
 @param theCoordinates A CFArray containing the relative coordinates.
 @result the memory offset
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 */
CFIndex PSDimensionMemOffsetFromRelativeCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error);

/*!
 @function PSDimensionMemOffsetFromDisplayedCoordinates
 @abstract Calculates the memory offset from an array of PSScalar displayed coordinate values.
 @param dimensions A CFArray containing the dimensions.
 @param theCoordinates A CFArray containing the displayed coordinates.
 @result the memory offset
 */
CFIndex PSDimensionMemOffsetFromDisplayedCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates);

/*!
 @function PSDimensionCreateDimensionlessCoordinatesFromMemOffset
 @abstract Creates an array of PSScalar dimensionless coordinate values from the memory offset.
 @param dimensions A CFArray containing the dimensions.
 @param memOffset the memory offset
 @result A CFArray containing the dimensionless coordinates.
 */
CFArrayRef PSDimensionCreateDimensionlessCoordinatesFromMemOffset(CFArrayRef dimensions, CFIndex memOffset);

/*!
 @function PSDimensionCreateRelativeCoordinatesFromMemOffset
 @abstract Creates an array of PSScalar relative coordinate values from the memory offset.
 @param dimensions A CFArray containing the dimensions.
 @param memOffset the memory offset
 @result A CFArray containing the relative coordinates.
 */
CFArrayRef PSDimensionCreateRelativeCoordinatesFromMemOffset(CFArrayRef dimensions, CFIndex memOffset);

/*!
 @function PSDimensionCreateDisplayedCoordinatesFromMemOffset
 @abstract Creates an array of PSScalar displayed coordinate values from the memory offset.
 @param dimensions A CFArray containing the dimensions.
 @param memOffset the memory offset
 @result A CFArray containing the displayed coordinates.
 */
CFMutableArrayRef PSDimensionCreateDisplayedCoordinatesFromMemOffset(CFArrayRef dimensions,
                                                              CFIndex memOffset);

/*!
 @function PSDimensionCreateDimensionlessCoordinateMinimumForDimensionAtIndex
 @abstract Creates a PSScalar dimensionless coordinate value associated with the lowest index of the dimension.
 @param dimensions A CFArray containing the dimensions.
 @param dimensionIndex a index to the dimension in the dimensions array
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result A PSScalar containing the minimum dimensionless coordinate.
 */
PSScalarRef PSDimensionCreateDimensionlessCoordinateMinimumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex, CFErrorRef *error);

/*!
 @function PSDimensionCreateRelativeCoordinateMinimumForDimensionAtIndex
 @abstract Creates a PSScalar relative coordinate value associated with the lowest index of the dimension.
 @param dimensions A CFArray containing the dimensions.
 @param dimensionIndex a index to the dimension in the dimensions array
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result A PSScalar containing the minimum relative coordinate.
 */
PSScalarRef PSDimensionCreateRelativeCoordinateMinimumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex, CFErrorRef *error);

/*!
 @function PSDimensionCreateDisplayedCoordinateMinimumForDimensionAtIndex
 @abstract Creates a PSScalar displayed coordinate value associated with the lowest index of the dimension.
 @param dimensions A CFArray containing the dimensions.
 @param dimensionIndex a index to the dimension in the dimensions array
 @result A PSScalar containing the minimum displayed coordinate.
 */
PSScalarRef PSDimensionCreateDisplayedCoordinateMinimumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex);

/*!
 @function PSDimensionCreateDimensionlessCoordinateMaximumForDimensionAtIndex
 @abstract Creates a PSScalar dimensionless coordinate value associated with the highest index of the dimension.
 @param dimensions A CFArray containing the dimensions.
 @param dimensionIndex a index to the dimension in the dimensions array
 @result A PSScalar containing the maximum dimensionless coordinate.
 */
PSScalarRef PSDimensionCreateDimensionlessCoordinateMaximumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex);

/*!
 @function PSDimensionCreateRelativeCoordinateMaximumForDimensionAtIndex
 @abstract Creates a PSScalar relative coordinate value associated with the highest index of the dimension.
 @param dimensions A CFArray containing the dimensions.
 @param dimensionIndex a index to the dimension in the dimensions array
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result A PSScalar containing the maximum relative coordinate.
 */
PSScalarRef PSDimensionCreateRelativeCoordinateMaximumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex, CFErrorRef *error);

/*!
 @function PSDimensionCreateDisplayedCoordinateMaximumForDimensionAtIndex
 @abstract Creates a PSScalar displayed coordinate value associated with the highest index of the dimension.
 @param dimensions A CFArray containing the dimensions.
 @param dimensionIndex a index to the dimension in the dimensions array
 @result A PSScalar containing the maximum displayed coordinate.
 */
PSScalarRef PSDimensionCreateDisplayedCoordinateMaximumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex);

/*
 @function memOffsetFromIndexes
 @abstract calculates the memory Offset in a multi-dimensional signal associated with the indexes array.
 @param indexes A pointer to a C array of CFIndex values specifying the indexes.
 @param numberOfDimensions The number of dimensions.
 @param npts A pointer to a C array of CFIndex values specifying the number of points associated with each dimension.
 @result the memory offset.
 */
CFIndex memOffsetFromIndexes(CFIndex *indexes, const CFIndex dimensionsCount, const CFIndex *npts);

/*
 @function setIndexesForMemOffset
 @abstract calculates the indexes in a multi-dimensional signal associated with a memory offset.
 @param the memory offset.
 @param indexes A pointer to a C array where the CFIndex values of the indexes will be returned.
 @param numberOfDimensions The number of dimensions.
 @param npts A pointer to a C array of CFIndex values specifying the number of points associated with each dimension.
 */
void setIndexesForMemOffset(const CFIndex memOffset, CFIndex indexes[], const CFIndex dimensionsCount, const CFIndex *npts);

/*
 @function strideAlongDimensionIndex
 @abstract calculates the stride along a dimension index.
 @param npts A pointer to a C array of CFIndex values specifying the number of points associated with each dimension.
 @param numberOfDimensions The number of dimensions.
 @param dimensionIndex the dimension index.
 @result the stride
 */
CFIndex strideAlongDimensionIndex(const CFIndex *npts, const CFIndex numberOfDimensions, const CFIndex dimensionIndex);

void setIndexesForReducedMemOffsetIgnoringDimension(const CFIndex memOffset, CFIndex indexes[], const CFIndex dimensionsCount, const CFIndex *npts, const CFIndex ignoredDimension);
void setIndexesForReducedMemOffsetIgnoringDimensions(const CFIndex memOffset, CFIndex indexes[], const CFIndex dimensionsCount, const CFIndex *npts, PSIndexSetRef dimensionIndexSet);
PSScalarRef CreateInverseIncrementFromIncrement(PSScalarRef increment, CFIndex numberOfSamples);


