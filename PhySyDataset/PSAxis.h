//
//  PSAxis.h
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

@class PSPlot;
@class PSDataset;
@interface PSAxis : NSObject
{
    CFIndex         index;
    PSScalarRef     minimum;
    PSScalarRef     maximum;
    PSScalarRef     majorTicInc;
	CFIndex         numberOfMinorTics;
    bool            bipolar;
    bool            reverse;
    PSPlot          *plot;       // Reference only, not retained.
}

@end

typedef PSAxis *PSAxisRef;

/*!
 @function PSAxisCreateResponseArgumentAxisForPlot
 */
PSAxisRef PSAxisCreateResponseArgumentAxisForPlot(PSPlot *plot);

/*!
 @function PSAxisValidate
 */
bool PSAxisValidate(PSAxisRef theAxis);

/*!
 @function PSAxisCreateWithDimensionForPlot
 */
PSAxisRef PSAxisCreateWithDimensionForPlot(CFIndex index, PSDimensionRef theDimension, PSPlot *thePlot);

/*!
 @function PSAxisCreateCopyForPlot
 */
PSAxisRef PSAxisCreateCopyForPlot(PSAxisRef theAxis, PSPlot *thePlot);

/*!
 @function PSAxisCreateWithIndexAndUnitForPlot
 */
PSAxisRef PSAxisCreateWithIndexAndUnitForPlot(CFIndex index, CFStringRef quantityName, PSUnitRef unit, void *thePlot);

/*!
 @function PSAxisCreateByMultiplyingByScalarForPlot
 */
PSAxisRef PSAxisCreateByMultiplyingByScalarForPlot(PSAxisRef theAxis, PSScalarRef theScalar, PSPlot *thePlot);

/*!
 @function PSAxisEqual
 */
bool PSAxisEqual(PSAxisRef input1, PSAxisRef input2);

/*!
 @function PSAxisHasSameReducedDimensionality
 */
bool PSAxisHasSameReducedDimensionality(PSAxisRef input1, PSAxisRef input2);

/*!
 @function PAxisIsCompatibleWithUnit
 */
bool PAxisIsCompatibleWithUnit(PSAxisRef theAxis, PSUnitRef theUnit, bool madeDimensionless);

/*!
 @function PSAxisGetQuantityName
 */
CFStringRef PSAxisGetQuantityName(PSAxisRef theAxis);

/*!
 @function PSAxisGetUnit
 */
PSUnitRef PSAxisGetUnit(PSAxisRef theAxis);

/*!
 @function PSAxisSetUnit
 */
bool PSAxisSetUnit(PSAxisRef theAxis, PSUnitRef theUnit, CFErrorRef *error);

/*!
 @function PSAxisGetDimensionality
 */
PSDimensionalityRef PSAxisGetDimensionality(PSAxisRef theAxis);

/*!
 @function PSAxisGetPlot
 */
PSPlot *PSAxisGetPlot(PSAxisRef theAxis);

/*!
 @function PSAxisGetIndex
 */
CFIndex PSAxisGetIndex(PSAxisRef theAxis);

/*!
 @function PSAxisSetIndex
 */
void PSAxisSetIndex(PSAxisRef theAxis, CFIndex index);

/*!
 @function PSAxisGetMinimum
 */
PSScalarRef PSAxisGetMinimum(PSAxisRef theAxis);

/*!
 @function PSAxisGetMaximum
 */
PSScalarRef PSAxisGetMaximum(PSAxisRef theAxis);

/*!
 @function PSAxisTakeParametersFromOtherAxis
 */
bool PSAxisTakeParametersFromOtherAxis(PSAxisRef theAxis, PSAxisRef theOtherAxis, CFErrorRef *error);


/*!
 @function PSAxisGetCoordinateIndexClosestToMinimum
 */
CFIndex PSAxisGetCoordinateIndexClosestToMinimum(PSAxisRef theAxis);

/*!
 @function PSAxisGetCoordinateIndexClosestToMaximum
 */
CFIndex PSAxisGetCoordinateIndexClosestToMaximum(PSAxisRef theAxis);

/*!
 @function PSAxisGetBipolar
 */
bool PSAxisGetBipolar(PSAxisRef theAxis);

/*!
 @function PSAxisSetBipolar
 */
void PSAxisSetBipolar(PSAxisRef theAxis, bool bipolar);

bool PSAxisGetReverse(PSAxisRef theAxis);
void PSAxisSetReverse(PSAxisRef theAxis, bool reverse);

/*!
 @function PSAxisToggleBipolar
 */
void PSAxisToggleBipolar(PSAxisRef theAxis);

/*!
 @function PSAxisGetNumberOfMinorTics
 */
CFIndex PSAxisGetNumberOfMinorTics(PSAxisRef theAxis);

/*!
 @function PSAxisSetNumberOfMinorTics
 */
bool PSAxisSetNumberOfMinorTics(PSAxisRef theAxis, CFIndex numberOfMinorTics);

/*!
 @function PSAxisCreateMinorTicIncrement
 */
PSScalarRef PSAxisCreateMinorTicIncrement(PSAxisRef theAxis);

/*!
 @function PSAxisGetMajorTicIncrement
 */
PSScalarRef PSAxisGetMajorTicIncrement(PSAxisRef theAxis);

/*!
 @function PSAxisSetMajorTicIncrement
 */
bool PSAxisSetMajorTicIncrement(PSAxisRef theAxis, PSScalarRef value);

/*!
 @function PSAxisUpdateTics
 */
bool PSAxisUpdateTics(PSAxisRef theAxis, CFStringRef quantityName);

/*!
 @function PSAxisDoubleWidth
 */
bool PSAxisDoubleWidth(PSAxisRef theAxis, CFErrorRef *error);

/*!
 @function PSAxisHalveWidth
 */
bool PSAxisHalveWidth(PSAxisRef theAxis, CFErrorRef *error);

/*!
 @function PSAxisScaleOutWidth
 */
bool PSAxisScaleOutWidth(PSAxisRef theAxis, double scaling, CFErrorRef *error);

/*!
 @function PSAxisScaleInWidth
 */
bool PSAxisScaleInWidth(PSAxisRef theAxis, double scaling, CFErrorRef *error);
bool PSAxisLowerMinimum(PSAxisRef theAxis, double widthFraction, CFErrorRef *error);

/*!
 @function PSAxisSetMinimum
 */
bool PSAxisSetMinimum(PSAxisRef theAxis, PSScalarRef value, bool ignoreLimits, CFErrorRef *error);

/*!
 @function PSAxisSetMaximum
 */
bool PSAxisSetMaximum(PSAxisRef theAxis, PSScalarRef value, bool ignoreLimits, CFErrorRef *error);

/*!
 @function PSAxisShift
 */
bool PSAxisShift(PSAxisRef theAxis, PSScalarRef shift, bool ignoreLimits, CFErrorRef *error);
bool PSAxisExpand(PSAxisRef theAxis, PSScalarRef expand, bool ignoreLimits, CFErrorRef *error);

/*!
 @function PSAxisInverse
 */
bool PSAxisInverse(PSAxisRef theAxis, PSUnitRef reciprocalUnit, CFStringRef inverseQuantityName, CFErrorRef *error);

void PSAxisAddToArrayAsPList(PSAxisRef theAxis, CFMutableArrayRef array);
CFDictionaryRef PSAxisCreatePList(PSAxisRef theAxis);
PSAxisRef PSAxisCreateWithPList(CFDictionaryRef dictionary, PSPlot *thePlot, CFErrorRef *error);

PSAxisRef PSAxisCreateWithOldDataFormat(CFDataRef data, PSPlot *thePlot, CFErrorRef *error);

/*!
 @function PSAxisCreateStringWithQuantityUnitAndIndex
 */
CFStringRef PSAxisCreateStringWithQuantityUnitAndIndex(PSAxisRef theAxis);

/*!
 @function PSAxisCreateStringWithLabelAndUnit
 */
CFStringRef PSAxisCreateStringWithLabelAndUnit(PSAxisRef theAxis);

/*!
 @function PSAxisUpdate
 */
bool PSAxisUpdate(PSAxisRef theAxis, CFErrorRef *error);

/*!
 @function PSAxisReset
 */
bool PSAxisReset(PSAxisRef theAxis, CFStringRef quantityName);

bool PSAxisResetWithMinAndMax(PSAxisRef theAxis, CFStringRef quantityName, PSScalarRef minimum, PSScalarRef maximum);

/*!
 @function PSAxisCreateHorizontalScaleAndOffsetInRect
 */
PSScalarRef PSAxisCreateHorizontalScaleAndOffsetInRect(PSAxisRef theAxis, CGRect axisRect, double *offset, CFErrorRef *error);

/*!
 @function PSAxisCreateVerticalScaleAndOffsetInRect
 */
PSScalarRef PSAxisCreateVerticalScaleAndOffsetInRect(PSAxisRef theAxis, CGRect axisRect, double *offset, CFErrorRef *error);

/*!
 @function PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect
 */
double PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(PSAxisRef theAxis, PSScalarRef axisCoordinate, CGRect axisRect, CFErrorRef *error);

/*!
 @function PSAxisVerticalViewCoordinateFromAxisCoordinateInRect
 */
double PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(PSAxisRef theAxis, PSScalarRef axisCoordinate, CGRect axisRect, CFErrorRef *error);

/*!
 @function PSAxisCreateCoordinateFromHorizontalViewCoordinate
 */
PSScalarRef PSAxisCreateCoordinateFromHorizontalViewCoordinate(PSAxisRef theAxis, double horizontalViewCoordinate, CGRect axisRect, CFErrorRef *error);

/*!
 @function PSAxisCreateCoordinateFromVerticalViewCoordinate
 */
PSScalarRef PSAxisCreateCoordinateFromVerticalViewCoordinate(PSAxisRef theAxis, double verticalViewCoordinate, CGRect axisRect, CFErrorRef *error);

CFTypeID PSAxisGetTypeID(void);

