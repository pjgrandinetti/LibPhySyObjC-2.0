//
//  PSPlot.h
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @enum PSImage2DPlotType
 @constant kPSImagePlotTypeHue Increasing image hue with Response
 @constant kPSImagePlotTypeSaturation Increasing image saturation with Response.
 @constant kPSImagePlotTypeValue Increasing image value with Response.
 @constant kPSImagePlotTypeBicolor Two colors for positive and negative Response.
 */
typedef enum PSImage2DPlotType {
    kPSImagePlotTypeHue = 0,
    kPSImagePlotTypeSaturation = 1,
    kPSImagePlotTypeValue = 2,
    kPSImagePlotTypeBicolor = 3
} PSImage2DPlotType;

/*!
 @enum PSPlotColoring
 @constant kPSPlotColoringHue Increasing hue with response contours.
 @constant kPSPlotColoringMonochrome Identical color for response contours.
 @constant kPSPlotColoringBicolor Two colors for positive and negative response contours.
 */
typedef enum PSPlotColoring {
    kPSPlotColoringHue = 0,
    kPSPlotColoringMonochrome = 1,
    kPSPlotColoringBicolor = 2
} PSPlotColoring;


@class PSDependentVariable;
@interface PSPlot : NSObject
{
    bool                transparent;
    CFMutableArrayRef   xAxes;
    CFMutableArrayRef   prevXAxes;
    CFIndex             dimensionsDisplayedCount;
    bool                plotAll;
    bool                lines;
    bool                showGrid;
    float               fontSize;

    bool                real;
    bool                imag;
    bool                magnitude;
    bool                argument;
    CFMutableArrayRef   componentColors;

    PSAxisRef           responseAxis;
    PSAxisRef           prevResponseAxis;
    
    PSAxisRef           responseArgumentAxis;
    PSAxisRef           prevResponseArgumentAxis;
    

    bool                showImagePlot;
    CFMutableArrayRef   signalImage2DPlotTypes;

    bool                image2DCombineRGB;
    CFIndex             redComponentIndex;
    CFIndex             greenComponentIndex;
    CFIndex             blueComponentIndex;
    
    bool                showContourPlot;
    CFIndex             numberOfContourCuts;
    PSPlotColoring      contourPlotColoring;
    
    bool                showStackPlot;
    bool                hiddenStackPlot;
    PSPlotColoring      stackPlotColoring;

    // ***** End Persistent Attributes
    
    // ***** Transient Attributes
    double      leftMargin;
    double      middleMargin;
    double      rightMargin;
    double      bottomMargin;
    double      topMargin;
	CGRect 		signalRect;
	CGRect 		cursorRect;
	CGRect 		leftSignalRect;
	CGRect 		leftCursorRect;
	CGRect 		rightSignalRect;
	CGRect 		rightCursorRect;
    CGRect      leftAxisRect;
    CGRect      rightRect;
    CGRect      middleRect;
	CGRect 		bottomRect;
	CGRect 		bottomLeftRect;
	CGRect 		bottomRightRect;
	CGRect 		topRect;
	CGRect 		topLeftRect;
	CGRect 		topRightRect;
	CGRect 		topLeftCornerRect;
	CGRect		bottomLeftCornerRect;
	CGRect 		bottomRightCornerRect;
    
    bool        imageViewNeedsRegenerated;
    bool        contourViewNeedsRegenerated;
    bool        stackViewNeedsRegenerated;
    
    PSDependentVariable  *dependentVariable;
}
@end

typedef PSPlot *PSPlotRef;

#define kPSPlotColorBlack       CFSTR("Black")
#define kPSPlotColorBlue        CFSTR("Blue")
#define kPSPlotColorBrown       CFSTR("Brown")
#define kPSPlotColorCyan        CFSTR("Cyan")
#define kPSPlotColorGreen       CFSTR("Green")
#define kPSPlotColorMagenta     CFSTR("Magenta")
#define kPSPlotColorOrange      CFSTR("Orange")
#define kPSPlotColorPurple      CFSTR("Purple")
#define kPSPlotColorRed         CFSTR("Red")
#define kPSPlotColorYellow      CFSTR("Yellow")
#define kPSPlotColorWhite       CFSTR("White")

/*!
 @function PSPlotCreateCopyForDependentVariable
 */
PSPlotRef PSPlotCreateCopyForDependentVariable(PSPlotRef thePlot,
                                               PSDependentVariable *theDependentVariable);

/*!
 @function PSPlotCreateWithDependentVariableAndAxes
 */
PSPlotRef PSPlotCreateWithDependentVariableAndAxes(PSDependentVariable *theDependentVariable,
                                                   CFMutableArrayRef xAxes);

/*!
 @function PSPlotCreateWithDataset
 */
PSPlotRef PSPlotCreateWithDependentVariable(PSDependentVariable *theDependentVariable);

/*!
 @function PSPlotEqual
 */
bool PSPlotEqual(PSPlotRef input1, PSPlotRef input2);

/*!
 @function PSPlotGetDataset
 */
PSDataset *PSPlotGetDataset(PSPlotRef thePlot);

/*!
 @function PSPlotGetDependentVariable
 */
PSDependentVariable *PSPlotGetDependentVariable(PSPlotRef thePlot);


/*!
 @function PSPlotSetDependentVariable
 */
bool PSPlotSetDependentVariable(PSPlotRef thePlot,
                                PSDependentVariable *theDependentVariable);

/*!
 @function PSPlotGetResponseAxis
 */
PSAxisRef PSPlotGetResponseAxis(PSPlotRef thePlot);

/*!
 @function PSPlotGetPreviousResponseAxis
 */
PSAxisRef PSPlotGetPreviousResponseAxis(PSPlotRef thePlot);

/*!
 @function PSPlotGetReal
 */
bool PSPlotGetReal(PSPlotRef thePlot);

/*!
 @function PSPlotSetReal
 */
void PSPlotSetReal(PSPlotRef thePlot, bool real);

/*!
 @function PSPlotGetImag
 */
bool PSPlotGetImag(PSPlotRef thePlot);
/*!
 @function PSPlotSetImag
 */
void PSPlotSetImag(PSPlotRef thePlot, bool imag);

/*!
 @function PSPlotGetMagnitude
 */
bool PSPlotGetMagnitude(PSPlotRef thePlot);
/*!
 @function PSPlotSetMagnitude
 */
void PSPlotSetMagnitude(PSPlotRef thePlot, bool magnitude);

/*!
 @function PSPlotGetArgument
 */
bool PSPlotGetArgument(PSPlotRef thePlot);
/*!
 @function PSPlotSetArgument
 */
void PSPlotSetArgument(PSPlotRef thePlot, bool argument);

/*!
 @function PSPlotGetPlotAll
 */
bool PSPlotGetPlotAll(PSPlotRef thePlot);
/*!
 @function PSPlotSetPlotAll
 */
void PSPlotSetPlotAll(PSPlotRef thePlot, bool plotAll);

/*!
 @function PSPlotGetTransparent
 */
bool PSPlotGetTransparent(PSPlotRef thePlot);
/*!
 @function PSPlotSetTransparent
 */
void PSPlotSetTransparent(PSPlotRef thePlot, bool transparent);

/*!
 @function PSPlotGetShowGrid
 */
bool PSPlotGetShowGrid(PSPlotRef thePlot);
/*!
 @function PSPlotSetShowGrid
 */
void PSPlotSetShowGrid(PSPlotRef thePlot, bool showGrid);

/*!
 @function PSPlotGetImage2DPlotTypeAtComponentIndex
 */
PSImage2DPlotType PSPlotGetImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, CFIndex componentIndex);
/*!
 @function PSPlotSetImage2DPlotTypeAtComponentIndex
 */
void PSPlotSetImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, PSImage2DPlotType plotType, CFIndex componentIndex);
void PSPlotInsertImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, PSImage2DPlotType plotType, CFIndex componentIndex);

/*!
 @function PSPlotSetImage2DPlotTypeAtComponentIndex
 */
bool PSPlotRemoveImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, CFIndex componentIndex);

/*!
 @function PSPlotGetRGBValuesFromColorName
 */
void PSPlotGetRGBValuesFromColorName(CFStringRef color, CGFloat *red, CGFloat *green, CGFloat *blue);

/*!
 @function PSPlotGetComponentColors
 */
CFArrayRef PSPlotGetComponentColors(PSPlotRef thePlot);
/*!
 @function PSPlotSetComponentColors
 */
void PSPlotSetComponentColors(PSPlotRef thePlot, CFArrayRef signalColors);

/*!
 @function PSPlotGetComponentColorAtIndex
 */
CFStringRef PSPlotGetComponentColorAtIndex(PSPlotRef thePlot, CFIndex componentIndex);

/*!
 @function PSPlotRemoveComponentColorAtIndex
 */
bool PSPlotRemoveComponentColorAtIndex(PSPlotRef thePlot, CFIndex componentIndex);

/*!
 @function PSPlotSetComponentColorAtIndex
 */
void PSPlotSetComponentColorAtIndex(PSPlotRef thePlot, CFIndex dependentVariableIndex, CFStringRef signalColor);

void PSPlotInsertComponentColorAtIndex(PSPlotRef thePlot, CFIndex componentIndex, CFStringRef componentColor);

/*!
 @function PSPlotSetDefaultColorForComponents
 */
void PSPlotSetDefaultColorForComponents(PSPlotRef thePlot);

/*!
 @function PSPlotSetDefaultImage2DPlotTypes
 */
void PSPlotSetDefaultImage2DPlotTypes(PSPlotRef thePlot);


/*!
 @function PSPlotGetLines
 */
bool PSPlotGetLines(PSPlotRef thePlot);
/*!
 @function PSPlotSetLines
 */
void PSPlotSetLines(PSPlotRef thePlot, bool lines);

/*!
 @function PSPlotGetShowImagePlot
 */
bool PSPlotGetShowImagePlot(PSPlotRef thePlot);
/*!
 @function PSPlotSetShowImagePlot
 */
void PSPlotSetShowImagePlot(PSPlotRef thePlot, bool showImagePlot);

/*!
 @function PSPlotGetShowImage2DCombineRGB
 */
bool PSPlotGetShowImage2DCombineRGB(PSPlotRef thePlot);
/*!
 @function PSPlotSetShowImage2DCombineRGB
 */
void PSPlotSetShowImage2DCombineRGB(PSPlotRef thePlot, bool image2DCombineRGB);

/*!
 @function PSPlotGetNumberOfContourCuts
 */
CFIndex PSPlotGetNumberOfContourCuts(PSPlotRef thePlot);

/*!
 @function PSPlotSetNumberOfContourCuts
 */
void PSPlotSetNumberOfContourCuts(PSPlotRef thePlot, CFIndex numberOfCuts);

/*!
 @function PSPlotGetContourPlotColoring
 */
PSPlotColoring PSPlotGetContourPlotColoring(PSPlotRef thePlot);

/*!
 @function PSPlotSetContourPlotColoring
 */
void PSPlotSetContourPlotColoring(PSPlotRef thePlot, PSPlotColoring coloring);

/*!
 @function PSPlotGetStackPlotColoring
 */
PSPlotColoring PSPlotGetStackPlotColoring(PSPlotRef thePlot);

/*!
 @function PSPlotSetStackPlotColoring
 */
void PSPlotSetStackPlotColoring(PSPlotRef thePlot, PSPlotColoring coloring);

/*!
 @function PSPlotGetredComponentIndex
 */
bool PSPlotGetredComponentIndex(PSPlotRef thePlot);
/*!
 @function PSPlotSetredComponentIndex
 */
void PSPlotSetredComponentIndex(PSPlotRef thePlot, CFIndex redComponentIndex);
/*!
 @function PSPlotGetgreenComponentIndex
 */
bool PSPlotGetgreenComponentIndex(PSPlotRef thePlot);
/*!
 @function PSPlotSetgreenComponentIndex
 */
void PSPlotSetgreenComponentIndex(PSPlotRef thePlot, CFIndex greenComponentIndex);
/*!
 @function PSPlotGetblueComponentIndex
 */
bool PSPlotGetblueComponentIndex(PSPlotRef thePlot);
/*!
 @function PSPlotSetblueComponentIndex
 */
void PSPlotSetblueComponentIndex(PSPlotRef thePlot, CFIndex greenComponentIndex);

/*!
 @function PSPlotGetShowContourPlot
 */
bool PSPlotGetShowContourPlot(PSPlotRef thePlot);
/*!
 @function PSPlotSetShowContourPlot
 */
void PSPlotSetShowContourPlot(PSPlotRef thePlot, bool showContourPlot);

/*!
 @function PSPlotGetShowStackPlot
 */
bool PSPlotGetShowStackPlot(PSPlotRef thePlot);
/*!
 @function PSPlotSetShowStackPlot
 */
void PSPlotSetShowStackPlot(PSPlotRef thePlot, bool showContourPlot);

/*!
 @function PSPlotSetHiddenStackPlot
 */
bool PSPlotGetHiddenStackPlot(PSPlotRef thePlot);

/*!
 @function PSPlotSetHiddenStackPlot
 */
void PSPlotSetHiddenStackPlot(PSPlotRef thePlot, bool showStackPlot);

/*!
 @function PSPlotGetFontSize
 */
float PSPlotGetFontSize(PSPlotRef thePlot);
/*!
 @function PSPlotSetFontSize
 */
void PSPlotSetFontSize(PSPlotRef thePlot, float fontsize);

/*!
 @function PSPlotUpdateDisplayRects
 */
void PSPlotUpdateDisplayRects(PSPlotRef thePlot, CGRect bounds);

/*!
 @function PSPlotGetDimensionsDisplayedCount
 */
CFIndex PSPlotGetDimensionsDisplayedCount(PSPlotRef thePlot);
/*!
 @function PSPlotSetDimensionsCountDisplayed
 */
void PSPlotSetDimensionsCountDisplayed(PSPlotRef thePlot, CFIndex numberOfDimensionsDisplayed);
/*!
 @function PSPlotSwapHorizontalAndVerticalIndexes
 */
void PSPlotSwapHorizontalAndVerticalIndexes(PSPlotRef thePlot);
/*!
 @function PSPlotSwapVerticalAndDepthIndexes
 */
void PSPlotSwapVerticalAndDepthIndexes(PSPlotRef thePlot);
/*!
 @function PSPlotSwapDepthAndHorizontalIndexes
 */
void PSPlotSwapDepthAndHorizontalIndexes(PSPlotRef thePlot);

/*!
 @function PSPlotHorizontalAxis
 */
PSAxisRef PSPlotHorizontalAxis(PSPlotRef thePlot);
/*!
 @function PSPlotVerticalAxis
 */
PSAxisRef PSPlotVerticalAxis(PSPlotRef thePlot);
/*!
 @function PSPlotDepthAxis
 */
PSAxisRef PSPlotDepthAxis(PSPlotRef thePlot);

/*!
 @function PSPlotNumberOfDimensions
 */
CFIndex PSPlotNumberOfDimensions(PSPlotRef thePlot);
/*!
 @function PSPlotIndexOfAxis
 */
CFIndex PSPlotIndexOfAxis(PSPlotRef thePlot, PSAxisRef theAxis);

bool PSPlotRemoveAxisAtIndex(PSPlotRef thePlot, CFIndex index);
void PSPlotRemoveAxesAtIndexes(PSPlotRef thePlot, PSIndexSetRef theIndexSet);

/*!
 @function PSPlotAxisAtIndex
 */
PSAxisRef PSPlotAxisAtIndex(PSPlotRef thePlot,CFIndex index);
/*!
 @function PSPlotPreviousAxisAtIndex
 */
PSAxisRef PSPlotPreviousAxisAtIndex(PSPlotRef thePlot,CFIndex index);
/*!
 @function PSPlotResetAxisAtIndex
 */
bool PSPlotResetAxisAtIndex(PSPlotRef thePlot, CFStringRef quantityName, CFIndex index);
/*!
 @function PSPlotReplaceAxisAtIndex
 */
void PSPlotReplaceAxisAtIndex(PSPlotRef thePlot, CFIndex index, PSAxisRef theAxis);

/*!
 @function PSPlotCreatePList
 */
CFDictionaryRef PSPlotCreatePList(PSPlotRef thePlot);
/*!
 @function PSPlotCreateWithPList
 */
PSPlotRef PSPlotCreateWithPList(CFDictionaryRef dictionary, PSDependentVariable *theDependentVariable, CFErrorRef *error);
PSPlotRef PSPlotCreateWithOldDataFormat(CFDataRef data, CFIndex componentsCount, CFErrorRef *error);

/*!
 @function PSPlotUpdate
 */
bool PSPlotUpdateAxes(PSPlotRef thePlot, CFErrorRef *error);
/*!
 @function PSPlotReset
 */
bool PSPlotReset(PSPlotRef thePlot);

CFTypeID PSPlotGetTypeID(void);

CGRect PSPlotGetCursorRect(PSPlotRef thePlot);
CGRect PSPlotGetLeftCursorRect(PSPlotRef thePlot);
CGRect PSPlotGetRightCursorRect(PSPlotRef thePlot);
CGRect PSPlotGetSignalRect(PSPlotRef thePlot);
CGRect PSPlotGetLeftSignalRect(PSPlotRef thePlot);
CGRect PSPlotGetRightSignalRect(PSPlotRef thePlot);
CGRect PSPlotGetLeftAxisRect(PSPlotRef thePlot);
CGRect PSPlotGetRightRect(PSPlotRef thePlot);
CGRect PSPlotGetMiddleRect(PSPlotRef thePlot);
CGRect PSPlotGetBottomRect(PSPlotRef thePlot);
CGRect PSPlotGetBottomLeftRect(PSPlotRef thePlot);
CGRect PSPlotGetBottomRightRect(PSPlotRef thePlot);
CGRect PSPlotGetTopRect(PSPlotRef thePlot);
CGRect PSPlotGetTopLeftRect(PSPlotRef thePlot);
CGRect PSPlotGetTopRightRect(PSPlotRef thePlot);
CGRect PSPlotGetTopLeftCornerRect(PSPlotRef thePlot);
CGRect PSPlotGetBottomRightCornerRect(PSPlotRef thePlot);
CGRect PSPlotGetBottomLeftCornerRect(PSPlotRef thePlot);

bool PSPlotGetImageViewNeedsRegenerated(PSPlotRef thePlot);
bool PSPlotGetContourViewNeedsRegenerated(PSPlotRef thePlot);
bool PSPlotGetStackViewNeedsRegenerated(PSPlotRef thePlot);
void PSPlotSetImageViewNeedsRegenerated(PSPlotRef thePlot, bool value);
void PSPlotSetContourViewNeedsRegenerated(PSPlotRef thePlot, bool value);
void PSPlotSetStackViewNeedsRegenerated(PSPlotRef thePlot, bool value);
void PSPlotSetViewNeedsRegenerated(PSPlotRef thePlot, bool value);

complexPart PSPlotWhichPartFromViewPoint(PSPlotRef thePlot, CGRect bounds, CGPoint viewPoint);
CGPoint PSPlotViewPointFromHorizontalAndVerticalCoordinatesInPart(PSPlotRef thePlot, 
                                                                  CGRect bounds, 
                                                                  PSScalarRef x0, 
                                                                  PSScalarRef x1, 
                                                                  complexPart part,
                                                                  CFErrorRef *error);

CFArrayRef PSPlotCreateHorizontalAndVerticalCoordinatesFromViewPoint(PSPlotRef thePlot,
                                                               CGRect bounds,
                                                               CGPoint viewPoint,
                                                                     CFErrorRef *error);

PSDatumRef PSPlotCreateClosestDatumAtViewPoint(PSPlotRef thePlot, CGRect bounds, CGPoint viewPoint, CFErrorRef *error);
PSDatumRef PSPlotCreateDatumAtViewPoint(PSPlotRef thePlot, CGRect bounds, CGPoint viewPoint, CFErrorRef *error);
