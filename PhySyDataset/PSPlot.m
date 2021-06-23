//
//  PSPlot.c
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDataset.h>
#import <CoreText/CoreText.h>
#import <Cocoa/Cocoa.h>

@implementation PSPlot

- (void) dealloc
{
	if(self->responseArgumentAxis) CFRelease(self->responseArgumentAxis);
    self->responseArgumentAxis = NULL;
	if(self->prevResponseArgumentAxis) CFRelease(self->prevResponseArgumentAxis);
    self->prevResponseArgumentAxis = NULL;
	if(self->responseAxis) CFRelease(self->responseAxis);
    self->responseAxis = NULL;
	if(self->prevResponseAxis) CFRelease(self->prevResponseAxis);
    self->prevResponseAxis = NULL;
	if(self->xAxes) CFRelease(self->xAxes);
    self->xAxes = NULL;
	if(self->prevXAxes) CFRelease(self->prevXAxes);
    self->prevXAxes = NULL;
    [super dealloc];
}

/* Designated Creator */
/**************************/

#define TRY do{ jmp_buf ex_buf__; switch( setjmp(ex_buf__) ){ case 0: while(1){
#define CATCH(x) break; case x:
#define FINALLY break; } default:
#define ETRY } }while(0)
#define THROW(x) longjmp(ex_buf__, x)

#define EXCEPTION_1 (1)
#define EXCEPTION_2 (2)
#define EXCEPTION_3 (3)
#define EXCEPTION_4 (4)
#define EXCEPTION_5 (5)
#define EXCEPTION_6 (6)



static PSPlotRef PSPlotCreate(bool              real,
                              bool              imag,
                              bool              magnitude,
                              bool              argument,
                              bool              plotAll,
                              bool              transparent,
                              bool              showGrid,
                              CFArrayRef        signalColors,
                              bool              lines,
                              bool              showImagePlot,
                              CFArrayRef        signalImage2DPlotTypes,
                              bool              image2DCombineRGB,
                              CFIndex           redComponentIndex,
                              CFIndex           greenComponentIndex,
                              CFIndex           blueComponentIndex,
                              bool              showStackPlot,
                              bool              hiddenStackPlot,
                              PSPlotColoring    stackPlotColoring,
                              bool              showContourPlot,
                              CFIndex           numberOfContourCuts,
                              PSPlotColoring    contourPlotColoring,
                              float             fontSize,
                              PSAxisRef         responseAxis,
                              PSAxisRef         prevResponseAxis,
                              CFMutableArrayRef xAxes,
                              CFMutableArrayRef prevXAxes,
                              CFIndex           dimensionsDisplayedCount,
                              PSDependentVariableRef theDependentVariable)
{
    // *** Validate input parameters ***
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);

    CFArrayRef dimensions = PSDatasetGetDimensions(PSDependentVariableGetDataset(theDependentVariable));
    
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex componentsCount = PSDependentVariableComponentsCount(theDependentVariable);
    numberType responseElementType = PSQuantityGetElementType(theDependentVariable);
    PSDimensionalityRef dimensionality = PSQuantityGetUnitDimensionality(theDependentVariable);
    
    // *** Initialize object ***
    
    PSPlotRef newPlot = (PSPlotRef) [PSPlot alloc];

	IF_NO_OBJECT_EXISTS_RETURN(newPlot,NULL);
    
    // *** Setup attributes ***
    newPlot->dependentVariable = theDependentVariable;
    if(dimensionsDisplayedCount > dimensionsCount) dimensionsDisplayedCount = 1;
    newPlot->dimensionsDisplayedCount = dimensionsDisplayedCount;
    newPlot->real = real;
    newPlot->imag = imag;
    newPlot->magnitude = magnitude;
    newPlot->argument = argument;
    
    if(!PSNumberTypeIsComplex(responseElementType)) {
        newPlot->magnitude = false;
        newPlot->argument = false;
        newPlot->imag = false;
    }
    newPlot->plotAll = plotAll;
    newPlot->transparent = transparent;
    newPlot->showGrid = showGrid;
    newPlot->lines = lines;
    newPlot->showImagePlot = showImagePlot;
    newPlot->image2DCombineRGB = image2DCombineRGB;
    newPlot->redComponentIndex = redComponentIndex;
    newPlot->greenComponentIndex = greenComponentIndex;
    newPlot->blueComponentIndex = blueComponentIndex;
    newPlot->showStackPlot = showStackPlot;
    newPlot->hiddenStackPlot = hiddenStackPlot;
    newPlot->stackPlotColoring = stackPlotColoring;
    newPlot->showContourPlot = showContourPlot;
    newPlot->numberOfContourCuts = numberOfContourCuts;
    newPlot->contourPlotColoring = contourPlotColoring;
    newPlot->fontSize = fontSize;
    
    TRY
    {
        if(signalImage2DPlotTypes == NULL) THROW( EXCEPTION_4 );
        if(CFArrayGetCount(signalImage2DPlotTypes)!= componentsCount) THROW( EXCEPTION_4 );
        newPlot->signalImage2DPlotTypes = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
        for(CFIndex dependentVariableIndex=0; dependentVariableIndex<componentsCount; dependentVariableIndex++) {
            CFArrayAppendValue(newPlot->signalImage2DPlotTypes, CFArrayGetValueAtIndex(signalImage2DPlotTypes, dependentVariableIndex));
        }
    }
    CATCH( EXCEPTION_4 )
    {
        newPlot->signalImage2DPlotTypes = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
        for(CFIndex dependentVariableIndex=0; dependentVariableIndex<componentsCount; dependentVariableIndex++) {
            CFArrayAppendValue(newPlot->signalImage2DPlotTypes, (const void *) kPSImagePlotTypeHue);
        }
    }
    FINALLY
    {
        
    }
    ETRY;

    
    TRY {
        if(responseAxis==NULL) THROW( EXCEPTION_5 );
        if(!PSDimensionalityHasSameReducedDimensionality(PSAxisGetDimensionality(responseAxis),dimensionality)) THROW( EXCEPTION_5 );
        newPlot->responseAxis = PSAxisCreateCopyForPlot(responseAxis, newPlot);
    }
    CATCH( EXCEPTION_5 ) {
        PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);
        CFStringRef responseQuantityName = PSDependentVariableGetQuantityName(theDependentVariable);
        newPlot->responseAxis = PSAxisCreateWithIndexAndUnitForPlot(-1, responseQuantityName, responseUnit, newPlot);
    }
    FINALLY { }
    ETRY;
    
    TRY {
        if(prevResponseAxis==NULL) THROW( EXCEPTION_6 );
        if(!PSDimensionalityHasSameReducedDimensionality(PSAxisGetDimensionality(prevResponseAxis),dimensionality)) THROW( EXCEPTION_6 );
        newPlot->prevResponseAxis = PSAxisCreateCopyForPlot(prevResponseAxis, newPlot);
    }
    CATCH( EXCEPTION_6 ) {
        PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);
        CFStringRef responseQuantityName = PSDependentVariableGetQuantityName(theDependentVariable);
        newPlot->prevResponseAxis = PSAxisCreateWithIndexAndUnitForPlot(-1, responseQuantityName, responseUnit, newPlot);
    }
    FINALLY { }
    ETRY;

    TRY
    {
        if(xAxes==NULL) THROW( EXCEPTION_1 );
        CFIndex numberOfXAxes = CFArrayGetCount(xAxes);
        if(numberOfXAxes != dimensionsCount) THROW( EXCEPTION_1 );
        for(CFIndex index = 0; index<dimensionsCount; index++) {
            PSAxisRef axis =(PSAxisRef) CFArrayGetValueAtIndex(xAxes, index);
            PSDimensionRef dimension = CFArrayGetValueAtIndex(dimensions, index);
            PSUnitRef dimensionUnit = PSDimensionGetDisplayedUnit(dimension);
            bool madeDimensionless = PSDimensionGetMadeDimensionless(dimension);
            
            if(!PAxisIsCompatibleWithUnit(axis, dimensionUnit, madeDimensionless)) THROW( EXCEPTION_1 );
        }
        newPlot->xAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<dimensionsCount; index++) {
            PSAxisRef axis = PSAxisCreateCopyForPlot((PSAxisRef) CFArrayGetValueAtIndex(xAxes, index), newPlot);
            PSAxisSetIndex(axis, index);
            CFArrayAppendValue(newPlot->xAxes, axis);
            CFRelease(axis);
        }
    }
    CATCH( EXCEPTION_1 )
    {
        newPlot->xAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<dimensionsCount; index++) {
            PSDimensionRef dimension = CFArrayGetValueAtIndex(dimensions, index);
            PSAxisRef axis = PSAxisCreateWithDimensionForPlot(index, dimension, newPlot);
            if(axis)
            {
                CFArrayAppendValue(newPlot->xAxes, axis);
                CFRelease(axis);
            }
        }
    }
    FINALLY
    {
        
    }
    ETRY;
    
    
    TRY
    {
        if(prevXAxes==NULL) THROW( EXCEPTION_2 );
        CFIndex numberOfXAxes = CFArrayGetCount(prevXAxes);
        if(numberOfXAxes != dimensionsCount) THROW( EXCEPTION_2 );
        for(CFIndex index = 0; index<dimensionsCount; index++) {
            PSAxisRef axis =(PSAxisRef) CFArrayGetValueAtIndex(prevXAxes, index);
            PSDimensionRef dimension = CFArrayGetValueAtIndex(dimensions, index);
            PSUnitRef dimensionUnit = PSDimensionGetDisplayedUnit(dimension);
            bool madeDimensionless = PSDimensionGetMadeDimensionless(dimension);
            if(!PAxisIsCompatibleWithUnit(axis, dimensionUnit,madeDimensionless)) THROW( EXCEPTION_2 );
        }
        newPlot->prevXAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<dimensionsCount; index++) {
            PSAxisRef axis = PSAxisCreateCopyForPlot((PSAxisRef) CFArrayGetValueAtIndex(prevXAxes, index), newPlot);
            PSAxisSetIndex(axis, index);
            CFArrayAppendValue(newPlot->prevXAxes, axis);
            CFRelease(axis);
        }
    }
    CATCH( EXCEPTION_2 )
    {
        newPlot->prevXAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<dimensionsCount; index++) {
            PSDimensionRef dimension = CFArrayGetValueAtIndex(dimensions, index);
            PSAxisRef axis = PSAxisCreateWithDimensionForPlot(index, dimension, newPlot);
            if(axis) {
                CFArrayAppendValue(newPlot->prevXAxes, axis);
                CFRelease(axis);
            }
        }
    }
    FINALLY
    {
    }
    ETRY;
    
    
    TRY
    {
        if(signalColors == NULL) THROW( EXCEPTION_3 );
        if(CFArrayGetCount(signalColors) != componentsCount) THROW( EXCEPTION_3 );
        newPlot->componentColors = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex dependentVariableIndex=0; dependentVariableIndex<CFArrayGetCount(signalColors); dependentVariableIndex++) {
            CFArrayAppendValue(newPlot->componentColors, CFArrayGetValueAtIndex(signalColors, dependentVariableIndex));
        }

    }
    CATCH( EXCEPTION_3 )
    {
        newPlot->componentColors = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex dependentVariableIndex=0; dependentVariableIndex<componentsCount; dependentVariableIndex++) {
            CFArrayAppendValue(newPlot->componentColors,kPSPlotColorBlack);
        }
    }
    FINALLY
    {
    }
    ETRY;
    
    PSPlotSetViewNeedsRegenerated(newPlot, true);
    newPlot->responseArgumentAxis = PSAxisCreateResponseArgumentAxisForPlot(newPlot);
    newPlot->prevResponseArgumentAxis = PSAxisCreateResponseArgumentAxisForPlot(newPlot);
    return (PSPlotRef) newPlot;
}

PSPlotRef PSPlotCreateCopyForDependentVariable(PSPlotRef thePlot,
                                               PSDependentVariableRef theDependentVariable)
{	
	IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    PSPlotRef newPlot = PSPlotCreate(thePlot->real,
                                     thePlot->imag, 
                                     thePlot->magnitude, 
                                     thePlot->argument, 
                                     thePlot->plotAll, 
                                     thePlot->transparent, 
                                     thePlot->showGrid, 
                                     thePlot->componentColors,
                                     thePlot->lines, 
                                     thePlot->showImagePlot,
                                     thePlot->signalImage2DPlotTypes,
                                     thePlot->image2DCombineRGB,
                                     thePlot->redComponentIndex,
                                     thePlot->greenComponentIndex,
                                     thePlot->blueComponentIndex,
                                     thePlot->showStackPlot,
                                     thePlot->hiddenStackPlot,
                                     thePlot->stackPlotColoring,
                                     thePlot->showContourPlot,
                                     thePlot->numberOfContourCuts,
                                     thePlot->contourPlotColoring,
                                     thePlot->fontSize,
                                     thePlot->responseAxis, 
                                     thePlot->prevResponseAxis, 
                                     thePlot->xAxes, 
                                     thePlot->prevXAxes, 
                                     thePlot->dimensionsDisplayedCount,
                                     theDependentVariable);
    return newPlot;
}

PSPlotRef PSPlotCreateWithDependentVariableAndAxes(PSDependentVariableRef theDependentVariable,
                                                   CFMutableArrayRef xAxes)
{
	IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFArrayRef dimensions = PSDatasetGetDimensions(PSDependentVariableGetDataset(theDependentVariable));

    // *** Setup attributes ***
    bool real = true;
    bool imag = false;
    if(PSNumberTypeIsComplex(PSQuantityGetElementType(theDependentVariable))) imag = true;
    bool magnitude = false;
    bool argument = false;
    bool plotAll = false;
    bool showGrid = true;
    bool transparent = false;
    CFMutableArrayRef componentColors = NULL;
    bool lines = true;
    bool showImagePlot = true;
    CFMutableArrayRef signalImage2DPlotTypes = NULL;

    CFIndex componentsCount = 0;
    bool image2DCombineRGB = PSDependentVariableIsPixelType(theDependentVariable, &componentsCount);
    if(componentsCount<3) image2DCombineRGB = false;
    CFIndex redComponentIndex = 0;
    CFIndex greenComponentIndex = 1;
    CFIndex blueComponentIndex = 2;
    bool showStackPlot = false;
    bool hiddenStackPlot = true;
    PSPlotColoring stackPlotColoring = kPSPlotColoringMonochrome;
    bool showContourPlot = false;
    CFIndex numberOfContourCuts = 10;
    PSPlotColoring contourPlotColoring = kPSPlotColoringHue;
    float fontSize = 11;
    PSAxisRef responseAxis = NULL;
    PSAxisRef prevResponseAxis = NULL;
    CFMutableArrayRef prevXAxes = NULL;
    
    CFIndex dimensionsDisplayedCount = CFArrayGetCount(dimensions);
    if(dimensionsDisplayedCount>2) dimensionsDisplayedCount = 2;
    
    PSPlotRef newPlot = PSPlotCreate(real,
                                     imag,
                                     magnitude,
                                     argument, 
                                     plotAll,
                                     transparent,
                                     showGrid,
                                     componentColors,
                                     lines,
                                     showImagePlot,
                                     signalImage2DPlotTypes,
                                     image2DCombineRGB,
                                     redComponentIndex,
                                     greenComponentIndex,
                                     blueComponentIndex,
                                     showStackPlot,
                                     hiddenStackPlot,
                                     stackPlotColoring,
                                     showContourPlot,
                                     numberOfContourCuts,
                                     contourPlotColoring,
                                     fontSize,
                                     responseAxis, 
                                     prevResponseAxis, 
                                     xAxes, 
                                     prevXAxes, 
                                     dimensionsDisplayedCount,
                                     theDependentVariable);
    
    return newPlot;
}

PSPlotRef PSPlotCreateWithDependentVariable(PSDependentVariableRef theDependentVariable)
{
	IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    return PSPlotCreateWithDependentVariableAndAxes(theDependentVariable,
                                                    NULL);
}

bool PSPlotEqual(PSPlotRef input1, PSPlotRef input2)
{
	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
	if(input1->real != input2->real) return false;
	if(input1->imag != input2->imag) return false;
	if(input1->magnitude != input2->magnitude) return false;
	if(input1->argument != input2->argument) return false;
	if(input1->plotAll != input2->plotAll) return false;
	if(input1->showGrid != input2->showGrid) return false;
	if(input1->lines != input2->lines) return false;
	if(input1->showImagePlot != input2->showImagePlot) return false;
	if(input1->image2DCombineRGB != input2->image2DCombineRGB) return false;
	if(input1->redComponentIndex != input2->redComponentIndex) return false;
	if(input1->greenComponentIndex != input2->greenComponentIndex) return false;
	if(input1->blueComponentIndex != input2->blueComponentIndex) return false;
    if(input1->showContourPlot != input2->showContourPlot) return false;
    if(input1->numberOfContourCuts != input2->numberOfContourCuts) return false;
    if(input1->contourPlotColoring != input2->contourPlotColoring) return false;
    if(input1->showStackPlot != input2->showStackPlot) return false;
    if(input1->hiddenStackPlot != input2->hiddenStackPlot) return false;
    if(input1->stackPlotColoring != input2->stackPlotColoring) return false;
	if(input1->fontSize != input2->fontSize) return false;

	if(!PSAxisEqual(input1->responseAxis,input2->responseAxis)) return false;
	if(!PSAxisEqual(input1->prevResponseAxis,input2->prevResponseAxis)) return false;
	return true;
}

PSDataset *PSPlotGetDataset(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    return PSDependentVariableGetDataset(thePlot->dependentVariable);
}

PSDependentVariableRef PSPlotGetDependentVariable(PSPlotRef thePlot)
{   
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    return thePlot->dependentVariable;
}

bool PSPlotSetDependentVariable(PSPlotRef thePlot,
                                PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    CFArrayRef dimensions = PSDatasetGetDimensions(PSDependentVariableGetDataset(theDependentVariable));
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);

    PSDimensionalityRef dimensionality = PSQuantityGetUnitDimensionality(theDependentVariable);
    
    if(!PSDimensionalityEqual(PSAxisGetDimensionality(thePlot->responseAxis),dimensionality)) return false;
    if(!PSDimensionalityEqual(PSAxisGetDimensionality(thePlot->prevResponseAxis),dimensionality)) return false;
    

    // Validate input parameters
    CFIndex xDimensionCount = CFArrayGetCount(thePlot->xAxes);
    CFIndex prevXDimensionCount = CFArrayGetCount(thePlot->prevXAxes);
    if(xDimensionCount != dimensionsCount) return false;
    if(prevXDimensionCount != dimensionsCount) return false;
    
    if(PSDependentVariableComponentsCount(theDependentVariable) != CFArrayGetCount(thePlot->componentColors)) return false;
    
    // Validate axes
    for(CFIndex index = 0; index<dimensionsCount; index++) {
        PSDimensionRef dimension = CFArrayGetValueAtIndex(dimensions, index);
        PSUnitRef unit = PSDimensionGetDisplayedUnit(dimension);
        PSDimensionalityRef dimensionality = PSUnitGetDimensionality(unit);
        
        PSAxisRef xAxis = (PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, index);
        if(!PSDimensionalityEqual(PSAxisGetDimensionality(xAxis),dimensionality)) return false;
        PSAxisRef prevXAxis = (PSAxisRef) CFArrayGetValueAtIndex(thePlot->prevXAxes, index);
        if(!PSDimensionalityEqual(PSAxisGetDimensionality(prevXAxis),dimensionality)) return false;
    }
    
    thePlot->dependentVariable = theDependentVariable;
    return true;
}

bool PSPlotGetReal(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->real;
}

void updateCrossSectionsPlotParameter(PSDatasetRef theDataset,CFIndex dependentVariableIndex, bool value, void func(PSPlotRef thePlot, bool value))
{
    PSDatasetRef crossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
    if(crossSection) {
        PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
        func(PSDependentVariableGetPlot(dependentVariable), value);
    }
    crossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
    if(crossSection) {
        PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
        func(PSDependentVariableGetPlot(dependentVariable), value);
    }
    crossSection = PSDatasetGet1DCrossSectionAlongDepth(theDataset);
    if(crossSection) {
        PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
        func(PSDependentVariableGetPlot(dependentVariable), value);
    }
}


void PSPlotSetReal(PSPlotRef thePlot, bool real)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);
    
    thePlot->real = real;
    if(dimensionsCount>1) updateCrossSectionsPlotParameter(theDataset, dependentVariableIndex, real, PSPlotSetReal);
}

bool PSPlotGetImag(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->imag;
}

void PSPlotSetImag(PSPlotRef thePlot, bool imag)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);

    thePlot->imag = imag;
    if(dimensionsCount>1) updateCrossSectionsPlotParameter(theDataset, dependentVariableIndex, imag, PSPlotSetImag);
}


bool PSPlotGetMagnitude(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->magnitude;
}

void PSPlotSetMagnitude(PSPlotRef thePlot, bool magnitude)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);

    thePlot->magnitude = magnitude;
    if(dimensionsCount>1) updateCrossSectionsPlotParameter(theDataset, dependentVariableIndex, magnitude, PSPlotSetMagnitude);
}

bool PSPlotGetArgument(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->argument;
}

void PSPlotSetArgument(PSPlotRef thePlot, bool argument)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);

    thePlot->argument = argument;
    if(dimensionsCount>1) updateCrossSectionsPlotParameter(theDataset, dependentVariableIndex, argument, PSPlotSetArgument);
}

bool PSPlotGetPlotAll(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->plotAll;
}

void PSPlotSetPlotAll(PSPlotRef thePlot, bool plotAll)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);

    thePlot->plotAll = plotAll;
    if(dimensionsCount>1) updateCrossSectionsPlotParameter(theDataset, dependentVariableIndex, plotAll, PSPlotSetPlotAll);

}

bool PSPlotGetShowGrid(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->showGrid;
}

void PSPlotSetShowGrid(PSPlotRef thePlot, bool showGrid)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    if(showGrid == thePlot->showGrid) return;
    thePlot->showGrid = showGrid;
}

bool PSPlotGetTransparent(PSPlotRef thePlot)
{
    if(NULL==thePlot) return false;
    return thePlot->transparent;
}

void PSPlotSetTransparent(PSPlotRef thePlot, bool transparent)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->transparent = transparent;
}

bool PSPlotGetLines(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->lines;
}

void PSPlotSetLines(PSPlotRef thePlot, bool lines)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);

    if(lines == thePlot->lines) return;
    
    thePlot->lines = lines;
    if(dimensionsCount>1) updateCrossSectionsPlotParameter(theDataset, dependentVariableIndex, lines, PSPlotSetLines);
}

PSImage2DPlotType PSPlotGetImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,kPSImagePlotTypeHue);
    return (PSImage2DPlotType) CFArrayGetValueAtIndex(thePlot->signalImage2DPlotTypes, componentIndex);
}

bool PSPlotRemoveImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, CFIndex componentIndex) {
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    if(componentIndex<0 || componentIndex > CFArrayGetCount(thePlot->signalImage2DPlotTypes)-1) return false;
    CFArrayRemoveValueAtIndex(thePlot->signalImage2DPlotTypes, componentIndex);
    return true;
}

void PSPlotInsertImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, PSImage2DPlotType plotType, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    if(componentIndex<0 || componentIndex > CFArrayGetCount(thePlot->signalImage2DPlotTypes)) return;
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);
    
    CFArrayInsertValueAtIndex(thePlot->signalImage2DPlotTypes, componentIndex, (const void *) plotType);
    
    if(dimensionsCount>1) {
        PSDatasetRef crossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotInsertImage2DPlotTypeAtComponentIndex(PSDependentVariableGetPlot(dependentVariable), plotType,componentIndex);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotInsertImage2DPlotTypeAtComponentIndex(PSDependentVariableGetPlot(dependentVariable), plotType,componentIndex);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongDepth(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotInsertImage2DPlotTypeAtComponentIndex(PSDependentVariableGetPlot(dependentVariable), plotType,componentIndex);
        }
    }
}
void PSPlotSetImage2DPlotTypeAtComponentIndex(PSPlotRef thePlot, PSImage2DPlotType plotType, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    if(componentIndex<0 || componentIndex > CFArrayGetCount(thePlot->signalImage2DPlotTypes)-1) return;
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);

    PSImage2DPlotType oldPlotType = (PSImage2DPlotType) CFArrayGetValueAtIndex(thePlot->signalImage2DPlotTypes, componentIndex);
    if(oldPlotType == plotType) return;
    
    CFArraySetValueAtIndex(thePlot->signalImage2DPlotTypes, componentIndex, (const void *) plotType);

    if(dimensionsCount>1) {
        PSDatasetRef crossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetImage2DPlotTypeAtComponentIndex(PSDependentVariableGetPlot(dependentVariable), plotType,componentIndex);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetImage2DPlotTypeAtComponentIndex(PSDependentVariableGetPlot(dependentVariable), plotType,componentIndex);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongDepth(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetImage2DPlotTypeAtComponentIndex(PSDependentVariableGetPlot(dependentVariable), plotType,componentIndex);
        }
    }
}

void PSPlotGetRGBValuesFromColorName(CFStringRef color, CGFloat *red, CGFloat *green, CGFloat *blue)
{
    if(CFStringCompare(color, kPSPlotColorBlack, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0;
        *green = 0;
        *blue = 0;
    }
    else if(CFStringCompare(color, kPSPlotColorBlue, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0;
        *green = 0;
        *blue = 1;
    }
    else if(CFStringCompare(color, kPSPlotColorBrown, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0.58823529411765;
        *green = 0.29411764705882;
        *blue = 0;
    }
    else if(CFStringCompare(color, kPSPlotColorCyan, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0;
        *green = 1;
        *blue = 1;
    }
    else if(CFStringCompare(color, kPSPlotColorGreen, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 41/360.;
        *green = 171/360.;
        *blue = 135/360.;
    }
    else if(CFStringCompare(color, kPSPlotColorMagenta, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 0;
        *blue = 1;
    }
    else if(CFStringCompare(color, kPSPlotColorOrange, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 0.5;
        *blue = 0;
    }
    else if(CFStringCompare(color, kPSPlotColorPurple, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0.5;
        *green = 0;
        *blue = 0.5;
    }
    else if(CFStringCompare(color, kPSPlotColorRed, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 0;
        *blue = 0;
    }
    else if(CFStringCompare(color, kPSPlotColorYellow, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 1;
        *blue = 0;
    }
    else if(CFStringCompare(color, kPSPlotColorWhite, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 1;
        *blue = 1;
    }
    
    NSAppearance *currentAppearance = [NSAppearance currentAppearance];
    if (@available(*, macOS 10.14)) {
        if([currentAppearance.name isEqualToString: NSAppearanceNameDarkAqua]) {
            *red  = 0.5*(*red)+0.5;
            *green = 0.5*(*green)+0.5;
            *blue  = 0.5*(*blue)+0.5;
        }
    }

}



CFArrayRef PSPlotGetComponentColors(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    return thePlot->componentColors;
}

void PSPlotSetComponentColors(PSPlotRef thePlot, CFArrayRef componentColors)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);
    CFIndex componentsCount = PSDatasetDependentVariablesCount(theDataset);
    
    if(CFArrayGetCount(componentColors)!=componentsCount) return;
    CFArrayRemoveAllValues(thePlot->componentColors);
    for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
        CFArrayAppendValue(thePlot->componentColors, CFArrayGetValueAtIndex(componentColors, componentIndex));
    }
    if(dimensionsCount>1) {
        PSDatasetRef crossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColors(PSDependentVariableGetPlot(dependentVariable), componentColors);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColors(PSDependentVariableGetPlot(dependentVariable), componentColors);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongDepth(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColors(PSDependentVariableGetPlot(dependentVariable), componentColors);
        }
    }

}

CFStringRef PSPlotGetComponentColorAtIndex(PSPlotRef thePlot, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    if(componentIndex<0 || componentIndex > CFArrayGetCount(thePlot->componentColors)-1) return NULL;
    return CFArrayGetValueAtIndex(thePlot->componentColors, componentIndex);
}

bool PSPlotRemoveComponentColorAtIndex(PSPlotRef thePlot, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    if(componentIndex<0 || componentIndex > CFArrayGetCount(thePlot->componentColors)-1) return false;
    CFArrayRemoveValueAtIndex(thePlot->componentColors, componentIndex);
    return true;
}


void PSPlotInsertComponentColorAtIndex(PSPlotRef thePlot, CFIndex componentIndex, CFStringRef componentColor)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    CFIndex componentsCount = CFArrayGetCount(thePlot->componentColors);
    if(componentIndex<0 || componentIndex > componentsCount) return;
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);
    
    CFArrayInsertValueAtIndex(thePlot->componentColors, componentIndex, componentColor);
    if(dimensionsCount>1) {
        PSDatasetRef crossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColorAtIndex(PSDependentVariableGetPlot(dependentVariable), componentIndex,componentColor);
            
        }
        crossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColorAtIndex(PSDependentVariableGetPlot(dependentVariable), componentIndex,componentColor);
            
        }
        crossSection = PSDatasetGet1DCrossSectionAlongDepth(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColorAtIndex(PSDependentVariableGetPlot(dependentVariable), componentIndex,componentColor);
            
        }
    }
}

void PSPlotSetComponentColorAtIndex(PSPlotRef thePlot, CFIndex componentIndex, CFStringRef componentColor)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);
    
    CFArraySetValueAtIndex(thePlot->componentColors, componentIndex, componentColor);
    if(dimensionsCount>1) {
        PSDatasetRef crossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColorAtIndex(PSDependentVariableGetPlot(dependentVariable), componentIndex,componentColor);
            
        }
        crossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColorAtIndex(PSDependentVariableGetPlot(dependentVariable), componentIndex,componentColor);
            
        }
        crossSection = PSDatasetGet1DCrossSectionAlongDepth(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetComponentColorAtIndex(PSDependentVariableGetPlot(dependentVariable), componentIndex,componentColor);
            
        }
    }
}

void PSPlotSetDefaultColorForComponents(PSPlotRef thePlot)
{
    CFIndex componentsCount = CFArrayGetCount(thePlot->componentColors);
    if(componentsCount == 1) PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorBlack);
    if(componentsCount == 2) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorRed);
    }
    if(componentsCount == 3) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
    }
    if(componentsCount == 4) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
    }
    if(componentsCount == 5) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
        PSPlotSetComponentColorAtIndex(thePlot, 4, kPSPlotColorPurple);
    }
    if(componentsCount == 6) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
        PSPlotSetComponentColorAtIndex(thePlot, 4, kPSPlotColorPurple);
        PSPlotSetComponentColorAtIndex(thePlot, 5, kPSPlotColorBrown);
    }
    if(componentsCount == 7) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
        PSPlotSetComponentColorAtIndex(thePlot, 4, kPSPlotColorPurple);
        PSPlotSetComponentColorAtIndex(thePlot, 5, kPSPlotColorBrown);
        PSPlotSetComponentColorAtIndex(thePlot, 6, kPSPlotColorCyan);
    }
    if(componentsCount == 8) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
        PSPlotSetComponentColorAtIndex(thePlot, 4, kPSPlotColorPurple);
        PSPlotSetComponentColorAtIndex(thePlot, 5, kPSPlotColorBrown);
        PSPlotSetComponentColorAtIndex(thePlot, 6, kPSPlotColorCyan);
        PSPlotSetComponentColorAtIndex(thePlot, 7, kPSPlotColorMagenta);
    }
    if(componentsCount == 9) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
        PSPlotSetComponentColorAtIndex(thePlot, 4, kPSPlotColorPurple);
        PSPlotSetComponentColorAtIndex(thePlot, 5, kPSPlotColorBrown);
        PSPlotSetComponentColorAtIndex(thePlot, 6, kPSPlotColorCyan);
        PSPlotSetComponentColorAtIndex(thePlot, 7, kPSPlotColorMagenta);
        PSPlotSetComponentColorAtIndex(thePlot, 8, kPSPlotColorYellow);
    }
    if(componentsCount == 10) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
        PSPlotSetComponentColorAtIndex(thePlot, 4, kPSPlotColorPurple);
        PSPlotSetComponentColorAtIndex(thePlot, 5, kPSPlotColorBrown);
        PSPlotSetComponentColorAtIndex(thePlot, 6, kPSPlotColorCyan);
        PSPlotSetComponentColorAtIndex(thePlot, 7, kPSPlotColorMagenta);
        PSPlotSetComponentColorAtIndex(thePlot, 8, kPSPlotColorYellow);
        PSPlotSetComponentColorAtIndex(thePlot, 9, kPSPlotColorBlack);
    }
    if(componentsCount > 10) {
        PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
        PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
        PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
        PSPlotSetComponentColorAtIndex(thePlot, 3, kPSPlotColorOrange);
        PSPlotSetComponentColorAtIndex(thePlot, 4, kPSPlotColorPurple);
        PSPlotSetComponentColorAtIndex(thePlot, 5, kPSPlotColorBrown);
        PSPlotSetComponentColorAtIndex(thePlot, 6, kPSPlotColorCyan);
        PSPlotSetComponentColorAtIndex(thePlot, 7, kPSPlotColorMagenta);
        PSPlotSetComponentColorAtIndex(thePlot, 8, kPSPlotColorYellow);
        PSPlotSetComponentColorAtIndex(thePlot, 9, kPSPlotColorBlack);
        for(CFIndex index = 10;index<componentsCount; index++) {
            PSPlotSetComponentColorAtIndex(thePlot, index, kPSPlotColorBlack);
        }
    }

}

void PSPlotSetDefaultImage2DPlotTypes(PSPlotRef thePlot)
{
    CFIndex componentsCount = CFArrayGetCount(thePlot->componentColors);
    CFIndex currentNumberPlotTypes = CFArrayGetCount(thePlot->signalImage2DPlotTypes);
    
    if(currentNumberPlotTypes == componentsCount) return;
    if(currentNumberPlotTypes < componentsCount) {
        PSImage2DPlotType lastPlotType = (PSImage2DPlotType) CFArrayGetValueAtIndex(thePlot->signalImage2DPlotTypes, currentNumberPlotTypes-1);
        for(CFIndex index = currentNumberPlotTypes; index<componentsCount; index++) {
            CFArrayAppendValue(thePlot->signalImage2DPlotTypes, (const void *) lastPlotType);
        }
    }
    else {
        while(CFArrayGetCount(thePlot->signalImage2DPlotTypes)>componentsCount) CFArrayRemoveValueAtIndex(thePlot->signalImage2DPlotTypes, CFArrayGetCount(thePlot->signalImage2DPlotTypes)-1);
    }
}

bool PSPlotGetShowImagePlot(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->showImagePlot;
}

void PSPlotSetShowImagePlot(PSPlotRef thePlot, bool showImagePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->showImagePlot = showImagePlot;
}

bool PSPlotGetShowImage2DCombineRGB(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->image2DCombineRGB;
}

void PSPlotSetShowImage2DCombineRGB(PSPlotRef thePlot, bool image2DCombineRGB)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    CFIndex componentCount = PSDependentVariableComponentsCount(thePlot->dependentVariable);
    if(componentCount==3||componentCount==4) {
        thePlot->image2DCombineRGB = image2DCombineRGB;
        return;
    }
    thePlot->image2DCombineRGB = false;
}

CFIndex PSPlotGetNumberOfContourCuts(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->numberOfContourCuts;
}

void PSPlotSetNumberOfContourCuts(PSPlotRef thePlot, CFIndex numberOfCuts)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    if(numberOfCuts == thePlot->numberOfContourCuts) return;
    PSPlotSetContourViewNeedsRegenerated(thePlot, true);
    thePlot->numberOfContourCuts = numberOfCuts;
}

PSPlotColoring PSPlotGetContourPlotColoring(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,kPSPlotColoringHue);
    return thePlot->contourPlotColoring;
}

void PSPlotSetContourPlotColoring(PSPlotRef thePlot, PSPlotColoring coloring)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    if(coloring == thePlot->contourPlotColoring) return;
    PSPlotSetContourViewNeedsRegenerated(thePlot, true);
    thePlot->contourPlotColoring = coloring;
}

PSPlotColoring PSPlotGetStackPlotColoring(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,kPSPlotColoringMonochrome);
    return thePlot->stackPlotColoring;
}

void PSPlotSetStackPlotColoring(PSPlotRef thePlot, PSPlotColoring coloring)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    if(coloring == thePlot->stackPlotColoring) return;
    PSPlotSetStackViewNeedsRegenerated(thePlot, true);
    thePlot->stackPlotColoring = coloring;
}


bool PSPlotGetredComponentIndex(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->redComponentIndex;
}

void PSPlotSetredComponentIndex(PSPlotRef thePlot, CFIndex redComponentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->redComponentIndex = redComponentIndex;
}

bool PSPlotGetgreenComponentIndex(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->greenComponentIndex;
}

void PSPlotSetgreenComponentIndex(PSPlotRef thePlot, CFIndex greenComponentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->greenComponentIndex = greenComponentIndex;
}

bool PSPlotGetblueComponentIndex(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->blueComponentIndex;
}

void PSPlotSetblueComponentIndex(PSPlotRef thePlot, CFIndex blueComponentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->greenComponentIndex = blueComponentIndex;
}

bool PSPlotGetShowContourPlot(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->showContourPlot;
}

void PSPlotSetShowContourPlot(PSPlotRef thePlot, bool showContourPlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->showContourPlot = showContourPlot;
}

bool PSPlotGetShowStackPlot(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->showStackPlot;
}

void PSPlotSetShowStackPlot(PSPlotRef thePlot, bool showStackPlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->showStackPlot = showStackPlot;
}

bool PSPlotGetHiddenStackPlot(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->hiddenStackPlot;
}

void PSPlotSetHiddenStackPlot(PSPlotRef thePlot, bool showStackPlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->hiddenStackPlot = showStackPlot;
}

float PSPlotGetFontSize(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,12);
    return thePlot->fontSize;
}

void PSPlotSetFontSize(PSPlotRef thePlot, float fontSize)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, thePlot->dependentVariable);

    thePlot->fontSize = fontSize;
    if(dimensionsCount>1) {
        PSDatasetRef crossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetFontSize(PSDependentVariableGetPlot(dependentVariable), fontSize);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetFontSize(PSDependentVariableGetPlot(dependentVariable), fontSize);
        }
        crossSection = PSDatasetGet1DCrossSectionAlongDepth(theDataset);
        if(crossSection) {
            PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(crossSection, dependentVariableIndex);
            PSPlotSetFontSize(PSDependentVariableGetPlot(dependentVariable), fontSize);
        }
    }

}

PSAxisRef PSPlotGetResponseAxis(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    if(thePlot->argument) return thePlot->responseArgumentAxis;
    return thePlot->responseAxis;
}

PSAxisRef PSPlotGetPreviousResponseAxis(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    if(thePlot->argument) return thePlot->prevResponseArgumentAxis;
    return thePlot->prevResponseAxis;
}

CFIndex PSPlotGetDimensionsDisplayedCount(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,kCFNotFound);
    return thePlot->dimensionsDisplayedCount;
}

void PSPlotSetDimensionsCountDisplayed(PSPlotRef thePlot, CFIndex dimensionsDisplayedCount)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);

    if(dimensionsDisplayedCount>dimensionsCount  | dimensionsDisplayedCount>2) return;
    if(dimensionsDisplayedCount<1) return;
    thePlot->dimensionsDisplayedCount = dimensionsDisplayedCount;
}

CFIndex PSPlotNumberOfDimensions(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,kCFNotFound);
    return CFArrayGetCount(thePlot->xAxes);
}

PSAxisRef PSPlotHorizontalAxis(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(thePlot->xAxes,NULL);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);

    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    if(horizontalDimensionIndex > CFArrayGetCount(thePlot->xAxes)-1) return NULL;
    return (PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, horizontalDimensionIndex);
}

PSAxisRef PSPlotVerticalAxis(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(thePlot->xAxes,NULL);
    if(thePlot->dimensionsDisplayedCount==1) return thePlot->responseAxis;
    
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);

    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    if(verticalDimensionIndex > CFArrayGetCount(thePlot->xAxes)-1) return NULL;
    return (PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, verticalDimensionIndex);
}

PSAxisRef PSPlotDepthAxis(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(thePlot->xAxes,NULL);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);

    CFIndex depthDimensionIndex = PSDatasetGetDepthDimensionIndex(theDataset);
    if(depthDimensionIndex > CFArrayGetCount(thePlot->xAxes)-1) return NULL;
    return (PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, depthDimensionIndex);
}

CFIndex PSPlotIndexOfAxis(PSPlotRef thePlot, PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,kCFNotFound);
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,kCFNotFound);
    if(theAxis == thePlot->responseAxis) return -1;
    for(CFIndex index = 0; index<CFArrayGetCount(thePlot->xAxes);  index++) {
        PSAxisRef axis = (PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, index);
        if(theAxis == axis) return index;
    }
    return kCFNotFound;
}

PSAxisRef PSPlotPreviousAxisAtIndex(PSPlotRef thePlot,CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
   if(index == -1) return thePlot->prevResponseAxis;
    return (PSAxisRef) CFArrayGetValueAtIndex(thePlot->prevXAxes, index);
}

PSAxisRef PSPlotAxisAtIndex(PSPlotRef thePlot,CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    if(index == -1) return thePlot->responseAxis;
    return (PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, index);
}

bool PSPlotRemoveAxisAtIndex(PSPlotRef thePlot, CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    if(index == -1) {
        if(thePlot->responseAxis) CFRelease(thePlot->responseAxis);
        if(thePlot->prevResponseAxis) CFRelease(thePlot->prevResponseAxis);
        thePlot->responseAxis = NULL;
        thePlot->prevResponseAxis = NULL;
    }
    CFArrayRemoveValueAtIndex(thePlot->xAxes, index);
    CFArrayRemoveValueAtIndex(thePlot->prevXAxes, index);
    for(CFIndex aIndex=0;aIndex<CFArrayGetCount(thePlot->xAxes);aIndex++) {
        PSAxisSetIndex(CFArrayGetValueAtIndex(thePlot->xAxes, aIndex), aIndex);
        PSAxisSetIndex(CFArrayGetValueAtIndex(thePlot->prevXAxes, aIndex), aIndex);
    }
    CFIndex finalAxesCount = CFArrayGetCount(thePlot->xAxes);
    if(finalAxesCount<2) thePlot->dimensionsDisplayedCount = finalAxesCount;
    return true;
}

void PSPlotRemoveAxesAtIndexes(PSPlotRef thePlot, PSIndexSetRef theIndexSet)
{
    if(thePlot==NULL) return;
    if(theIndexSet==NULL) return;
    
    CFIndex count = PSIndexSetGetCount(theIndexSet);
    if(count) {
        CFIndex index = PSIndexSetLastIndex(theIndexSet);
        PSPlotRemoveAxisAtIndex(thePlot, index);
        for(CFIndex i=0; i<count-1; i++) {
            index = PSIndexSetIndexLessThanIndex(theIndexSet, index);
            if(index==kCFNotFound) return;
            PSPlotRemoveAxisAtIndex(thePlot, index);
        }
    }
}

bool PSPlotResetAxisAtIndex(PSPlotRef thePlot, CFStringRef quantityName, CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    
    if(index == -1) {
        thePlot->prevResponseAxis = thePlot->responseAxis;
        thePlot->responseAxis = PSAxisCreateCopyForPlot(thePlot->responseAxis,thePlot);
        PSAxisReset(thePlot->responseAxis, quantityName);
        return true;
    }

    PSAxisRef xAxis = CFArrayGetValueAtIndex(thePlot->xAxes, index);
    CFArraySetValueAtIndex(thePlot->prevXAxes, index, xAxis);
    xAxis = PSAxisCreateCopyForPlot(xAxis,thePlot);
    CFArraySetValueAtIndex(thePlot->xAxes, index, xAxis);
    PSAxisReset(xAxis, quantityName);
    CFRelease(xAxis);
    return true;
}

void PSPlotReplaceAxisAtIndex(PSPlotRef thePlot, CFIndex index, PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,);

    if(index == -1) {
        if(!PAxisIsCompatibleWithUnit(theAxis,PSQuantityGetUnit(thePlot->dependentVariable),false)) return;
        PSAxisRef oldAxis = PSAxisCreateCopyForPlot(thePlot->responseAxis,thePlot);
        PSAxisRef newAxis = PSAxisCreateCopyForPlot(theAxis,thePlot);
        CFRelease(thePlot->prevResponseAxis);
        CFRelease(thePlot->responseAxis);
        
        thePlot->prevResponseAxis = oldAxis;
        thePlot->responseAxis = newAxis;
        return;
    }
    
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDimensionRef dimension = CFArrayGetValueAtIndex(dimensions, index);
    PSUnitRef dimensionUnit = PSDimensionGetDisplayedUnit(dimension);
    bool madeDimensionless = PSDimensionGetMadeDimensionless(dimension);
    if(!PAxisIsCompatibleWithUnit(theAxis,dimensionUnit,madeDimensionless)) return;
    PSAxisRef oldAxis = PSAxisCreateCopyForPlot((PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, index),
                                                thePlot);
    PSAxisRef newAxis = PSAxisCreateCopyForPlot(theAxis,thePlot);
    
    CFArraySetValueAtIndex(thePlot->prevXAxes, index, oldAxis);
    CFArraySetValueAtIndex(thePlot->xAxes, index, newAxis);
    
    CFRelease(oldAxis);
    CFRelease(newAxis);
}

CFDictionaryRef PSPlotCreatePList(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    
    if(thePlot->real) CFDictionarySetValue(dictionary, CFSTR("real"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("real"), kCFBooleanFalse);
    
    if(thePlot->imag) CFDictionarySetValue(dictionary, CFSTR("imag"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("imag"), kCFBooleanFalse);
    
    if(thePlot->magnitude) CFDictionarySetValue(dictionary, CFSTR("magnitude"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("magnitude"), kCFBooleanFalse);
    
    if(thePlot->argument) CFDictionarySetValue(dictionary, CFSTR("argument"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("argument"), kCFBooleanFalse);
    
    if(thePlot->plotAll) CFDictionarySetValue(dictionary, CFSTR("plotAll"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("plotAll"), kCFBooleanFalse);
    
    if(thePlot->transparent) CFDictionarySetValue(dictionary, CFSTR("transparent"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("transparent"), kCFBooleanFalse);
    
    if(thePlot->showGrid) CFDictionarySetValue(dictionary, CFSTR("showGrid"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("showGrid"), kCFBooleanFalse);
    
    if(thePlot->componentColors) CFDictionarySetValue(dictionary, CFSTR("signalColors"), thePlot->componentColors);
    
    if(thePlot->lines) CFDictionarySetValue(dictionary, CFSTR("lines"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("lines"), kCFBooleanFalse);
    
    if(thePlot->showImagePlot) CFDictionarySetValue(dictionary, CFSTR("showImagePlot"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("showImagePlot"), kCFBooleanFalse);
    
    if(thePlot->image2DCombineRGB) CFDictionarySetValue(dictionary, CFSTR("image2DCombineRGB"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("image2DCombineRGB"), kCFBooleanFalse);
    
    if(thePlot->signalImage2DPlotTypes) {
        CFMutableArrayRef signalImage2DPlotTypes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex dependentVariableIndex = 0; dependentVariableIndex<CFArrayGetCount(thePlot->signalImage2DPlotTypes); dependentVariableIndex++) {
            CFNumberRef value = PSCFNumberCreateWithCFIndex((CFIndex) CFArrayGetValueAtIndex(thePlot->signalImage2DPlotTypes, dependentVariableIndex));
            PSCFNumberAddToArrayAsStringValue(value, signalImage2DPlotTypes);
            CFRelease(value);
        }
        CFDictionarySetValue(dictionary, CFSTR("signalImage2DPlotType"), signalImage2DPlotTypes);
        CFRelease(signalImage2DPlotTypes);
    }
    
    CFNumberRef number = PSCFNumberCreateWithCFIndex(thePlot->redComponentIndex);
    CFDictionarySetValue(dictionary, CFSTR("redComponentIndex"), number);
    CFRelease(number);
    
    number = PSCFNumberCreateWithCFIndex(thePlot->greenComponentIndex);
    CFDictionarySetValue(dictionary, CFSTR("greenComponentIndex"), number);
    CFRelease(number);
    
    number = PSCFNumberCreateWithCFIndex(thePlot->blueComponentIndex);
    CFDictionarySetValue(dictionary, CFSTR("blueComponentIndex"), number);
    CFRelease(number);
    
    if(thePlot->showContourPlot) CFDictionarySetValue(dictionary, CFSTR("showContourPlot"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("showContourPlot"), kCFBooleanFalse);
    
    number = PSCFNumberCreateWithCFIndex(thePlot->numberOfContourCuts);
    CFDictionarySetValue(dictionary, CFSTR("numberOfContourCuts"), number);
    CFRelease(number);
    
    number = PSCFNumberCreateWithCFIndex(thePlot->contourPlotColoring);
    CFDictionarySetValue(dictionary, CFSTR("contourPlotColoring"), number);
    CFRelease(number);

    if(thePlot->showStackPlot) CFDictionarySetValue(dictionary, CFSTR("showStackPlot"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("showStackPlot"), kCFBooleanFalse);
    
    if(thePlot->hiddenStackPlot) CFDictionarySetValue(dictionary, CFSTR("hiddenStackPlot"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("hiddenStackPlot"), kCFBooleanFalse);
    
    number = CFNumberCreate(kCFAllocatorDefault,kCFNumberIntType,&thePlot->stackPlotColoring);
    CFDictionarySetValue(dictionary, CFSTR("stackPlotColoring"), number);
    CFRelease(number);

    number = CFNumberCreate(kCFAllocatorDefault,kCFNumberFloatType,&thePlot->fontSize);
    CFDictionarySetValue(dictionary, CFSTR("fontSize"), number);
    CFRelease(number);
    
    number = PSCFNumberCreateWithCFIndex(thePlot->dimensionsDisplayedCount);
    CFDictionarySetValue(dictionary, CFSTR("dimensionsDisplayedCount"), number);
    CFRelease(number);
    
    if(thePlot->responseAxis) {
        CFDictionaryRef plist = PSAxisCreatePList(thePlot->responseAxis);
        if(plist) {
            CFDictionarySetValue(dictionary, CFSTR("responseAxis"), plist);
            CFRelease(plist);
        }
    }
    
    if(thePlot->prevResponseAxis) {
        CFDictionaryRef plist = PSAxisCreatePList(thePlot->prevResponseAxis);
        if(plist) {
            CFDictionarySetValue(dictionary, CFSTR("prevResponseAxis"), plist);
            CFRelease(plist);
        }
    }
    
    if(thePlot->xAxes) {
        CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFArrayApplyFunction(thePlot->xAxes, 
                             CFRangeMake(0,CFArrayGetCount(thePlot->xAxes)), 
                             (CFArrayApplierFunction) PSAxisAddToArrayAsPList, 
                             array);
        CFDictionarySetValue(dictionary, CFSTR("xAxes"),array);
        CFRelease(array);
    }
    
    if(thePlot->prevXAxes) {
        CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFArrayApplyFunction(thePlot->prevXAxes, 
                             CFRangeMake(0,CFArrayGetCount(thePlot->prevXAxes)), 
                             (CFArrayApplierFunction) PSAxisAddToArrayAsPList, 
                             array);
        CFDictionarySetValue(dictionary, CFSTR("prevXAxes"),array);
        CFRelease(array);
    }
    
	return dictionary;
}



PSPlotRef PSPlotCreateWithPList(CFDictionaryRef dictionary, PSDependentVariable *theDependentVariable, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dictionary,NULL);

    if(CFDictionaryGetCount(dictionary)==0) return NULL;
    
    PSPlotRef thePlot = (PSPlotRef) [PSPlot alloc];
    thePlot->dependentVariable = theDependentVariable;
    PSPlotSetViewNeedsRegenerated(thePlot, true);
    thePlot->responseArgumentAxis = PSAxisCreateResponseArgumentAxisForPlot(thePlot);
    thePlot->prevResponseArgumentAxis = PSAxisCreateResponseArgumentAxisForPlot(thePlot);
    
    CFBooleanRef real = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("real")))
        real = CFDictionaryGetValue(dictionary, CFSTR("real"));
    if(real==NULL) real = kCFBooleanTrue;
    thePlot->real = CFBooleanGetValue(real);
    
    CFBooleanRef imag = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("imag")))
        imag = CFDictionaryGetValue(dictionary, CFSTR("imag"));
    if(imag==NULL) imag = kCFBooleanFalse;
    thePlot->imag = CFBooleanGetValue(imag);
    
    CFBooleanRef magnitude = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("magnitude")))
        magnitude = CFDictionaryGetValue(dictionary, CFSTR("magnitude"));
    if(magnitude==NULL)magnitude = kCFBooleanFalse;
    thePlot->magnitude = CFBooleanGetValue(magnitude);

    CFBooleanRef argument = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("argument")))
        argument = CFDictionaryGetValue(dictionary, CFSTR("argument"));
    if(argument==NULL) argument = kCFBooleanFalse;
    thePlot->argument = CFBooleanGetValue(argument);

    CFBooleanRef plotAll = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("plotAll")))
        plotAll = CFDictionaryGetValue(dictionary, CFSTR("plotAll"));
    if(plotAll==NULL) plotAll = kCFBooleanTrue;
    thePlot->plotAll = CFBooleanGetValue(plotAll);
    
    CFBooleanRef transparent = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("transparent")))
        transparent = CFDictionaryGetValue(dictionary, CFSTR("transparent"));
    if(transparent==NULL) transparent = kCFBooleanFalse;
    thePlot->transparent = CFBooleanGetValue(transparent);
    
    CFBooleanRef showGrid = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showGrid")))
        showGrid = CFDictionaryGetValue(dictionary, CFSTR("showGrid"));
    if(showGrid==NULL) showGrid = kCFBooleanTrue;
    thePlot->showGrid = CFBooleanGetValue(showGrid);
    
    thePlot->componentColors = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("signalColors")))
        thePlot->componentColors = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, CFDictionaryGetValue(dictionary, CFSTR("signalColors")));
    else {
        CFIndex componentsCount = PSDependentVariableComponentsCount(theDependentVariable);
        thePlot->componentColors = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex dependentVariableIndex = 0; dependentVariableIndex<componentsCount; dependentVariableIndex++) {
            CFArrayAppendValue(thePlot->componentColors, kPSPlotColorBlack);
        }
    }

    CFBooleanRef image2DCombineRGB = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("image2DCombineRGB")))
        image2DCombineRGB = CFDictionaryGetValue(dictionary, CFSTR("image2DCombineRGB"));
    if(image2DCombineRGB==NULL) {
        if(thePlot->componentColors) CFRelease(thePlot->componentColors);
        if(thePlot) CFRelease(thePlot);
        return NULL;
    }
    thePlot->image2DCombineRGB = CFBooleanGetValue(image2DCombineRGB);

    thePlot->signalImage2DPlotTypes = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    if(CFDictionaryContainsKey(dictionary, CFSTR("signalImage2DPlotTypes"))) {
        CFArrayRef values = CFDictionaryGetValue(dictionary, CFSTR("signalImage2DPlotTypes"));
        for(CFIndex dependentVariableIndex = 0; dependentVariableIndex < CFArrayGetCount(values); dependentVariableIndex++) {
            CFIndex value =  CFStringGetIntValue((CFStringRef) CFArrayGetValueAtIndex(values, dependentVariableIndex));
            CFArrayAppendValue(thePlot->signalImage2DPlotTypes,(const void *) value);
        }
    }
    else {
        CFIndex componentsCount = PSDependentVariableComponentsCount(theDependentVariable);
        for(CFIndex dependentVariableIndex = 0; dependentVariableIndex<componentsCount; dependentVariableIndex++) {
            CFArrayAppendValue(thePlot->signalImage2DPlotTypes, (const void *) kPSImagePlotTypeHue);
        }
    }

    CFBooleanRef lines = kCFBooleanTrue;
    if(CFDictionaryContainsKey(dictionary, CFSTR("lines")))
        lines = CFDictionaryGetValue(dictionary, CFSTR("lines"));
    thePlot->lines = CFBooleanGetValue(lines);

    CFBooleanRef showImagePlot = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showImagePlot")))
        showImagePlot = CFDictionaryGetValue(dictionary, CFSTR("showImagePlot"));
    if(showImagePlot==NULL) {
        if(thePlot->signalImage2DPlotTypes) CFRelease(thePlot->signalImage2DPlotTypes);
        if(thePlot->componentColors) CFRelease(thePlot->componentColors);
        if(thePlot) CFRelease(thePlot);
        return NULL;
    }
    thePlot->showImagePlot = CFBooleanGetValue(showImagePlot);

    CFBooleanRef showContourPlot = kCFBooleanFalse;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showContourPlot")))
        showContourPlot = CFDictionaryGetValue(dictionary, CFSTR("showContourPlot"));
    thePlot->showContourPlot = CFBooleanGetValue(showContourPlot);
    
    thePlot->numberOfContourCuts = 10;
    if(CFDictionaryContainsKey(dictionary, CFSTR("numberOfContourCuts")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("numberOfContourCuts")),kCFNumberCFIndexType,&thePlot->numberOfContourCuts);
    
    thePlot->contourPlotColoring = kPSPlotColoringHue;
    if(CFDictionaryContainsKey(dictionary, CFSTR("contourPlotColoring")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("contourPlotColoring")),kCFNumberIntType,&thePlot->contourPlotColoring);
    
    CFBooleanRef showStackPlot = kCFBooleanFalse;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showStackPlot")))
        showStackPlot = CFDictionaryGetValue(dictionary, CFSTR("showStackPlot"));
    thePlot->showStackPlot = CFBooleanGetValue(showStackPlot);
    
    CFBooleanRef hiddenStackPlot = kCFBooleanTrue;
    if(CFDictionaryContainsKey(dictionary, CFSTR("hiddenStackPlot")))
        hiddenStackPlot = CFDictionaryGetValue(dictionary, CFSTR("hiddenStackPlot"));
    thePlot->hiddenStackPlot = CFBooleanGetValue(hiddenStackPlot);
    
    thePlot->stackPlotColoring = kPSPlotColoringMonochrome;
    if(CFDictionaryContainsKey(dictionary, CFSTR("stackPlotColoring")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("stackPlotColoring")),kCFNumberIntType,&thePlot->stackPlotColoring);

    thePlot->fontSize = 11;
    if(CFDictionaryContainsKey(dictionary, CFSTR("fontSize")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("fontSize")),kCFNumberFloatType,&thePlot->fontSize);
    
    thePlot->dimensionsDisplayedCount = 1;
    if(CFDictionaryContainsKey(dictionary, CFSTR("dimensionsDisplayedCount")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("dimensionsDisplayedCount")),kCFNumberCFIndexType,&thePlot->dimensionsDisplayedCount);
    
    thePlot->responseAxis = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("responseAxis")))
        thePlot->responseAxis = PSAxisCreateWithPList(CFDictionaryGetValue(dictionary, CFSTR("responseAxis")), thePlot, error);
    
    thePlot->prevResponseAxis = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("prevResponseAxis")))
        thePlot->prevResponseAxis = PSAxisCreateWithPList(CFDictionaryGetValue(dictionary, CFSTR("prevResponseAxis")),thePlot, error);
    
    thePlot->xAxes = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("xAxes"))) {
        thePlot->xAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(dictionary, CFSTR("xAxes"));
        CFIndex count = CFArrayGetCount(array);
        for(CFIndex index=0; index<count; index++) {
            PSAxisRef axis = PSAxisCreateWithPList(CFArrayGetValueAtIndex(array, index),thePlot, error);
            CFArrayAppendValue(thePlot->xAxes, axis);
            CFRelease(axis);
        }       
    }
    
    thePlot->prevXAxes = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("prevXAxes"))) {
        thePlot->prevXAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(dictionary, CFSTR("prevXAxes"));
        CFIndex count = CFArrayGetCount(array);
        for(CFIndex index=0; index<count; index++) {
            CFDictionaryRef datumDictionary = CFArrayGetValueAtIndex(array, index);
            PSAxisRef datum = PSAxisCreateWithPList(datumDictionary,thePlot, error);
            CFArrayAppendValue(thePlot->prevXAxes, datum);
            CFRelease(datum);
        }
    }
    return thePlot;
}


PSPlotRef PSPlotCreateWithOldDataFormat(CFDataRef data, CFIndex componentsCount, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(data,NULL);
    
    CFPropertyListFormat format;
    CFDictionaryRef dictionary  = CFPropertyListCreateWithData (kCFAllocatorDefault,data,kCFPropertyListImmutable,&format,error);
    if(dictionary==NULL) return NULL;
    
    PSPlotRef thePlot = (PSPlotRef) [PSPlot alloc];
    PSPlotSetViewNeedsRegenerated(thePlot, true);
    thePlot->responseArgumentAxis = PSAxisCreateResponseArgumentAxisForPlot(thePlot);
    thePlot->prevResponseArgumentAxis = PSAxisCreateResponseArgumentAxisForPlot(thePlot);
    
    CFBooleanRef real = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("real")))
        real = CFDictionaryGetValue(dictionary, CFSTR("real"));
    if(real==NULL) {
        CFRelease(thePlot);
        CFRelease(dictionary);
        return NULL;}
    thePlot->real = CFBooleanGetValue(real);
    
    CFBooleanRef imag = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("imag")))
        imag = CFDictionaryGetValue(dictionary, CFSTR("imag"));
    if(imag==NULL) {
        CFRelease(thePlot);
        CFRelease(dictionary);
        return NULL;}
    thePlot->imag = CFBooleanGetValue(imag);
    
    CFBooleanRef magnitude = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("magnitude")))
        magnitude = CFDictionaryGetValue(dictionary, CFSTR("magnitude"));
    if(magnitude==NULL) {
        CFRelease(thePlot);
        CFRelease(dictionary);
        return NULL;}
    thePlot->magnitude = CFBooleanGetValue(magnitude);
    
    CFBooleanRef argument = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("argument")))
        argument = CFDictionaryGetValue(dictionary, CFSTR("argument"));
    if(argument==NULL) {
        CFRelease(thePlot);
        CFRelease(dictionary);
        return NULL;}
    thePlot->argument = CFBooleanGetValue(argument);
    
    CFBooleanRef plotAll = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("plotAll")))
        plotAll = CFDictionaryGetValue(dictionary, CFSTR("plotAll"));
    if(plotAll==NULL) {
        CFRelease(thePlot);
        CFRelease(dictionary);
        return NULL;}
    thePlot->plotAll = CFBooleanGetValue(plotAll);
    
    thePlot->transparent = false;
    if(CFDictionaryContainsKey(dictionary, CFSTR("transparent")))
        thePlot->transparent = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("transparent")));
    
    thePlot->showGrid = false;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showGrid")))
        thePlot->showGrid = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("showGrid")));
    
    thePlot->componentColors = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("signalColors")))
        thePlot->componentColors = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, CFDictionaryGetValue(dictionary, CFSTR("signalColors")));
    else {
        thePlot->componentColors = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex signalIndex = 0; signalIndex<componentsCount; signalIndex++) {
            CFArrayAppendValue(thePlot->componentColors, kPSPlotColorBlack);
        }
    }
    
    thePlot->image2DCombineRGB = false;
    if(CFDictionaryContainsKey(dictionary, CFSTR("image2DCombineRGB")))
        thePlot->image2DCombineRGB = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("image2DCombineRGB")));
    
    thePlot->signalImage2DPlotTypes = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    if(CFDictionaryContainsKey(dictionary, CFSTR("signalImage2DPlotTypes"))) {
        CFArrayRef values = CFDictionaryGetValue(dictionary, CFSTR("signalImage2DPlotTypes"));
        for(CFIndex signalIndex = 0; signalIndex < CFArrayGetCount(values); signalIndex++) {
            CFNumberRef value =  (CFNumberRef) CFArrayGetValueAtIndex(values, signalIndex);
            CFArrayAppendValue(thePlot->signalImage2DPlotTypes,(const void *) PSCFNumberCFIndexValue(value));
        }
    }
    else {
        for(CFIndex signalIndex = 0; signalIndex<componentsCount; signalIndex++) {
            CFArrayAppendValue(thePlot->signalImage2DPlotTypes, (const void *) kPSImagePlotTypeHue);
        }
    }
    
    thePlot->lines = true;
    if(CFDictionaryContainsKey(dictionary, CFSTR("lines")))
        thePlot->lines = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("lines")));
    
    thePlot->showImagePlot = true;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showImagePlot")))
        thePlot->showImagePlot = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("showImagePlot")));
    
    thePlot->showContourPlot = false;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showContourPlot")))
        thePlot->showContourPlot = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("showContourPlot")));
    
    thePlot->numberOfContourCuts = 10;
    if(CFDictionaryContainsKey(dictionary, CFSTR("numberOfContourCuts")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("numberOfContourCuts")),kCFNumberCFIndexType,&thePlot->numberOfContourCuts);
    
    thePlot->contourPlotColoring = kPSPlotColoringHue;
    if(CFDictionaryContainsKey(dictionary, CFSTR("contourPlotColoring")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("contourPlotColoring")),kCFNumberIntType,&thePlot->contourPlotColoring);
    
    thePlot->showStackPlot = false;
    if(CFDictionaryContainsKey(dictionary, CFSTR("showStackPlot")))
        thePlot->showStackPlot = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("showStackPlot")));
    
    thePlot->hiddenStackPlot = true;
    if(CFDictionaryContainsKey(dictionary, CFSTR("hiddenStackPlot")))
        thePlot->hiddenStackPlot = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("hiddenStackPlot")));
    
    thePlot->stackPlotColoring = kPSPlotColoringMonochrome;
    if(CFDictionaryContainsKey(dictionary, CFSTR("stackPlotColoring")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("stackPlotColoring")),kCFNumberIntType,&thePlot->stackPlotColoring);
    
    thePlot->fontSize = 11;
    if(CFDictionaryContainsKey(dictionary, CFSTR("fontSize")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("fontSize")),kCFNumberFloatType,&thePlot->fontSize);
    
    thePlot->dimensionsDisplayedCount = 1;
    if(CFDictionaryContainsKey(dictionary, CFSTR("numberOfDimensionsDisplayed")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("numberOfDimensionsDisplayed")),kCFNumberCFIndexType,&thePlot->dimensionsDisplayedCount);
    
    thePlot->responseAxis = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("responseAxis")))
        thePlot->responseAxis = PSAxisCreateWithOldDataFormat(CFDictionaryGetValue(dictionary, CFSTR("responseAxis")),thePlot, error);
    
    thePlot->prevResponseAxis = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("prevResponseAxis")))
        thePlot->prevResponseAxis = PSAxisCreateWithOldDataFormat(CFDictionaryGetValue(dictionary, CFSTR("prevResponseAxis")),thePlot,error);
    
    thePlot->xAxes = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("xAxes"))) {
        thePlot->xAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(dictionary, CFSTR("xAxes"));
        CFIndex count = CFArrayGetCount(array);
        for(CFIndex index=0; index<count; index++) {
            PSAxisRef xAxis = PSAxisCreateWithOldDataFormat(CFArrayGetValueAtIndex(array, index),thePlot,error);
            CFArrayAppendValue(thePlot->xAxes, xAxis);
            CFRelease(xAxis);
        }
    }
    
    thePlot->prevXAxes = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("prevXAxes"))) {
        thePlot->prevXAxes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(dictionary, CFSTR("prevXAxes"));
        CFIndex count = CFArrayGetCount(array);
        for(CFIndex index=0; index<count; index++) {
            PSAxisRef xAxis = PSAxisCreateWithOldDataFormat(CFArrayGetValueAtIndex(array, index),thePlot,error);
            CFArrayAppendValue(thePlot->prevXAxes, xAxis);
            CFRelease(xAxis);
        }
    }
    
    CFRelease(dictionary);
    return thePlot;
}

bool PSPlotUpdateAxes(PSPlotRef thePlot, CFErrorRef *error)
{
    if(NULL==thePlot) return false;
    if(error) if(*error) return false;
    for(CFIndex index=-1;index<CFArrayGetCount(thePlot->xAxes); index++) {
        PSAxisUpdate(PSPlotAxisAtIndex(thePlot, index), error);
    }
    return true;
}

bool PSPlotReset(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    
    PSAxisRef temp = PSAxisCreateCopyForPlot(thePlot->responseAxis, thePlot);
    CFRelease(thePlot->prevResponseAxis);
    thePlot->prevResponseAxis = temp;
    
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(thePlot->dimensionsDisplayedCount > dimensionsCount) thePlot->dimensionsDisplayedCount = 1;

    PSAxisReset(thePlot->responseAxis, PSDependentVariableGetQuantityName(thePlot->dependentVariable));
    for(CFIndex idim = 0;idim<dimensionsCount; idim++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, idim);
        CFStringRef displayedQuantityName = PSDimensionCopyDisplayedQuantityName(theDimension);
        PSAxisRef axis = (PSAxisRef) CFArrayGetValueAtIndex(thePlot->xAxes, idim);
        PSAxisRef temp = PSAxisCreateCopyForPlot(axis, thePlot);
        if(temp) {
            CFArraySetValueAtIndex (thePlot->prevXAxes,idim,temp);
            CFRelease(temp);
        }
        PSAxisReset(axis, displayedQuantityName);
        CFRelease(displayedQuantityName);
    }
    return true;
}

void PSPlotUpdateDisplayRects(PSPlotRef thePlot, CGRect bounds)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    
    // Default values for 1D plot.
    double leftMargin = 80;
    double rightMargin = 25;
    double middleMargin = 20;
    double topMargin = 15;
    double bottomMargin = 50;
    
    if(thePlot->dimensionsDisplayedCount==2) {
        leftMargin = 80;
        bottomMargin = 50;
        middleMargin = bounds.size.width/7;
        rightMargin = bounds.size.width/7;
        topMargin = bounds.size.height/7;
    }
    
	if(thePlot->fontSize > 20) {thePlot->fontSize = 20;}
    if(thePlot->fontSize < 9) {thePlot->fontSize = 9;}
    
    thePlot->cursorRect = bounds;
    
    thePlot->signalRect = bounds;
    thePlot->signalRect.origin.x		=	leftMargin;
    thePlot->signalRect.size.width      -=	rightMargin+leftMargin;
    thePlot->signalRect.origin.y		=	bottomMargin;
    thePlot->signalRect.size.height 	-=	topMargin+bottomMargin;
    
    thePlot->leftAxisRect = bounds;
    thePlot->leftAxisRect.size.width = leftMargin;
    thePlot->leftAxisRect.size.height = thePlot->signalRect.size.height;
    thePlot->leftAxisRect.origin.y = bottomMargin;
    
    thePlot->rightRect = bounds;
    thePlot->rightRect.size.width = rightMargin;
    thePlot->rightRect.origin.x   = bounds.origin.x + bounds.size.width - rightMargin;
    thePlot->rightRect.origin.y = bottomMargin;
    thePlot->rightRect.size.height = thePlot->signalRect.size.height;
    
    thePlot->leftSignalRect             = thePlot->signalRect;
    thePlot->leftSignalRect.size.width  = (thePlot->signalRect.size.width - middleMargin)/2;
    
    thePlot->leftCursorRect             = thePlot->cursorRect;
    thePlot->leftCursorRect.size.width  = (thePlot->cursorRect.size.width - middleMargin)/2;

    thePlot->rightSignalRect            = thePlot->signalRect;
    thePlot->rightSignalRect.origin.x   = thePlot->leftSignalRect.origin.x + thePlot->leftSignalRect.size.width + middleMargin;
    thePlot->rightSignalRect.size.width = thePlot->leftSignalRect.size.width;
    
    thePlot->rightCursorRect            = thePlot->cursorRect;
    thePlot->rightCursorRect.origin.x   = thePlot->leftCursorRect.origin.x + thePlot->leftCursorRect.size.width + middleMargin;
    thePlot->rightCursorRect.size.width = thePlot->leftCursorRect.size.width;

    thePlot->middleRect = thePlot->signalRect;
    thePlot->middleRect.origin.x = thePlot->leftSignalRect.origin.x+thePlot->leftSignalRect.size.width;
    thePlot->middleRect.size.width = middleMargin;
    
    thePlot->bottomRect             =	bounds;
    thePlot->bottomRect.origin.x    =	thePlot->signalRect.origin.x;
    thePlot->bottomRect.size.width  =	thePlot->signalRect.size.width;
    thePlot->bottomRect.size.height =	thePlot->signalRect.origin.y - bounds.origin.y;
    
    thePlot->bottomLeftRect             =	thePlot->bottomRect;
    thePlot->bottomLeftRect.origin.x    =	thePlot->leftSignalRect.origin.x;
    thePlot->bottomLeftRect.size.width  =	thePlot->leftSignalRect.size.width;
    
    thePlot->bottomRightRect             =	thePlot->bottomRect;
    thePlot->bottomRightRect.origin.x    =	thePlot->rightSignalRect.origin.x;
    thePlot->bottomRightRect.size.width  =	thePlot->rightSignalRect.size.width;
    
    thePlot->topRect                =	bounds;
    thePlot->topRect.origin.x		=	thePlot->signalRect.origin.x;
    thePlot->topRect.origin.y       =	thePlot->signalRect.origin.y + thePlot->signalRect.size.height;
    thePlot->topRect.size.width     =	thePlot->signalRect.size.width;
    thePlot->topRect.size.height	=	bounds.size.height - thePlot->topRect.origin.y;
    
    thePlot->topLeftRect             =	thePlot->topRect;
    thePlot->topLeftRect.origin.x    =	thePlot->leftSignalRect.origin.x;
    thePlot->topLeftRect.size.width  =	thePlot->leftSignalRect.size.width;
    
    thePlot->topRightRect             =	thePlot->topRect;
    thePlot->topRightRect.origin.x    =	thePlot->rightSignalRect.origin.x;
    thePlot->topRightRect.size.width  =	thePlot->rightSignalRect.size.width;
    
    thePlot->topLeftCornerRect                  =	bounds;
    thePlot->topLeftCornerRect.size.width       =	leftMargin;
    thePlot->topLeftCornerRect.origin.y         =	thePlot->signalRect.origin.y + thePlot->signalRect.size.height;
    
    thePlot->bottomLeftCornerRect                =	bounds;
    thePlot->bottomLeftCornerRect.size.width     =	leftMargin;
    thePlot->bottomLeftCornerRect.size.height    =	bottomMargin;
    
    thePlot->bottomRightCornerRect               =	bounds;
    thePlot->bottomRightCornerRect.origin.x      =	thePlot->signalRect.origin.x + thePlot->signalRect.size.width;
    thePlot->bottomLeftCornerRect.size.height    =	thePlot->signalRect.origin.y;
    
}

CGRect PSPlotGetCursorRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->cursorRect;
}

CGRect PSPlotGetLeftCursorRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->leftCursorRect;
}

CGRect PSPlotGetRightCursorRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->rightCursorRect;
}

CGRect PSPlotGetSignalRect(PSPlotRef thePlot)
{   
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->signalRect;
}

CGRect PSPlotGetLeftSignalRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->leftSignalRect;
}

CGRect PSPlotGetRightSignalRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->rightSignalRect;
}

CGRect PSPlotGetLeftAxisRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->leftAxisRect;
}

CGRect PSPlotGetRightRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->rightRect;
}

CGRect PSPlotGetMiddleRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->middleRect;
}

CGRect PSPlotGetBottomRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->bottomRect;
}

CGRect PSPlotGetBottomLeftRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->bottomLeftRect;
}

CGRect PSPlotGetBottomRightRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->bottomRightRect;
}

CGRect PSPlotGetTopRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->topRect;
}

CGRect PSPlotGetTopLeftRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->topLeftRect;
}

CGRect PSPlotGetTopRightRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->topRightRect;
}

CGRect PSPlotGetTopLeftCornerRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->topLeftCornerRect;
}

CGRect PSPlotGetBottomRightCornerRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->bottomRightCornerRect;
}

CGRect PSPlotGetBottomLeftCornerRect(PSPlotRef thePlot)
{
    CGRect bad = {kCFNotFound,kCFNotFound};
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,bad);
    return thePlot->bottomLeftCornerRect;
}

bool PSPlotGetImageViewNeedsRegenerated(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->imageViewNeedsRegenerated;
}

bool PSPlotGetContourViewNeedsRegenerated(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->contourViewNeedsRegenerated;
}

bool PSPlotGetStackViewNeedsRegenerated(PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    return thePlot->stackViewNeedsRegenerated;
}

void PSPlotSetImageViewNeedsRegenerated(PSPlotRef thePlot, bool value)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->imageViewNeedsRegenerated = value;
}

void PSPlotSetContourViewNeedsRegenerated(PSPlotRef thePlot, bool value)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->contourViewNeedsRegenerated = value;
}

void PSPlotSetStackViewNeedsRegenerated(PSPlotRef thePlot, bool value)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->stackViewNeedsRegenerated = value;
}

void PSPlotSetViewNeedsRegenerated(PSPlotRef thePlot, bool value)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,);
    thePlot->imageViewNeedsRegenerated = value;
    thePlot->contourViewNeedsRegenerated = value;
    thePlot->stackViewNeedsRegenerated = value;
}

complexPart PSPlotWhichPartFromViewPoint(PSPlotRef thePlot, CGRect bounds, CGPoint viewPoint)
{
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,kCFNotFound);
    PSPlotUpdateDisplayRects(thePlot, bounds);
    
    bool real = thePlot->real;
    bool imag = thePlot->imag;
	complexPart part = kPSRealPart;
	if(real && imag) {
        CGRect signalRect = thePlot->signalRect;
        CGRect leftSignalRect = thePlot->leftSignalRect;
        double vl = leftSignalRect.size.width + thePlot->middleRect.size.width/2;
		if(viewPoint.x > signalRect.origin.x + vl) {
			part = kPSImaginaryPart;
		}
	}
    else {
        if(real) part = kPSRealPart;
        else part = kPSImaginaryPart;
    }
    return part;
}

PSDatumRef PSPlotCreateClosestDatumAtViewPoint(PSPlotRef thePlot, CGRect bounds, CGPoint viewPoint, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    PSPlotUpdateDisplayRects(thePlot, bounds);
    
    CGRect theRect = thePlot->signalRect;
	if(PSPlotGetReal(thePlot)&&PSPlotGetImag(thePlot)) {
		if(viewPoint.x > thePlot->signalRect.origin.x + thePlot->leftSignalRect.size.width) {
            theRect = thePlot->rightSignalRect;
		}
        else theRect = thePlot->leftSignalRect;
	}
    
    PSScalarRef horizontalCoordinate = PSAxisCreateCoordinateFromHorizontalViewCoordinate(PSPlotHorizontalAxis(thePlot), viewPoint.x, theRect, error);

    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSMutableIndexArrayRef indexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);

    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    CFIndex coordinateIndex = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, horizontalCoordinate);
    CFRelease(horizontalCoordinate);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    PSIndexArraySetValueAtIndex(indexes, horizontalDimensionIndex, coordinateIndex);
    
    memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexes);
    PSDatumRef newFocus = PSDatasetCreateDatumFromMemOffset(theDataset, dvIndex, componentIndex, memOffset);
    CFRelease(indexes);
    return newFocus;
}

PSDatumRef PSPlotCreateDatumAtViewPoint(PSPlotRef thePlot, CGRect bounds, CGPoint viewPoint, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(thePlot->dependentVariable);
    PSPlotUpdateDisplayRects(thePlot, bounds);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);

    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    
    CGRect theRect = thePlot->signalRect;
    if(PSPlotGetReal(thePlot)&&PSPlotGetImag(thePlot)) {
        if(viewPoint.x > thePlot->signalRect.origin.x + thePlot->leftSignalRect.size.width) {
            theRect = thePlot->rightSignalRect;
        }
        else theRect = thePlot->leftSignalRect;
    }
    PSScalarRef horizontalCoordinate = PSAxisCreateCoordinateFromHorizontalViewCoordinate(PSPlotHorizontalAxis(thePlot), viewPoint.x, theRect, error);
    CFIndex horizontalCoordinateIndex = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, horizontalCoordinate);
    CFRelease(horizontalCoordinate);
    
    PSScalarRef verticalCoordinate =  PSAxisCreateCoordinateFromVerticalViewCoordinate(verticalAxis, viewPoint.y, thePlot->signalRect, error);
    
    CFIndex verticalCoordinateIndex = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, verticalCoordinate);
    CFRelease(verticalCoordinate);

    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    
    PSMutableIndexArrayRef indexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    PSIndexArraySetValueAtIndex(indexes, horizontalDimensionIndex, horizontalCoordinateIndex);
    PSIndexArraySetValueAtIndex(indexes, verticalDimensionIndex, verticalCoordinateIndex);
    memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexes);
    PSDatumRef newFocus = PSDatasetCreateDatumFromMemOffset(theDataset, dvIndex, componentIndex, memOffset);
    CFRelease(indexes);
    return newFocus;
}


CGPoint PSPlotViewPointFromHorizontalAndVerticalCoordinatesInPart(PSPlotRef thePlot, 
                                                                  CGRect bounds, 
                                                                  PSScalarRef x0, 
                                                                  PSScalarRef x1, 
                                                                  complexPart part,
                                                                  CFErrorRef *error)
{	    
    CGPoint result = {kCFNotFound,kCFNotFound};
    if(error) if(*error) return result;

    IF_NO_OBJECT_EXISTS_RETURN(thePlot,result);
    PSPlotUpdateDisplayRects(thePlot, bounds);
    
    
    CGRect horizontalAxisRect = thePlot->bottomRect;
    if(PSPlotGetReal(thePlot)&&PSPlotGetImag(thePlot)) {
        if(part==kPSRealPart) horizontalAxisRect = thePlot->bottomLeftRect;
        else horizontalAxisRect = thePlot->bottomRightRect;
    }
    
    
    result.x = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(PSPlotHorizontalAxis(thePlot), x0, horizontalAxisRect, error);
    result.y = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(PSPlotVerticalAxis(thePlot), x1, thePlot->leftAxisRect, error);
    return result;
}

CFArrayRef PSPlotCreateHorizontalAndVerticalCoordinatesFromViewPoint(PSPlotRef thePlot,
                                                                     CGRect bounds,
                                                                     CGPoint viewPoint,
                                                                     CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,NULL);
    complexPart part = PSPlotWhichPartFromViewPoint(thePlot, bounds, viewPoint);
    
    CGRect horizontalAxisRect = thePlot->bottomRect;
    if(PSPlotGetReal(thePlot)&&PSPlotGetImag(thePlot)) {
        if(part==kPSRealPart) horizontalAxisRect = thePlot->bottomLeftRect;
        else horizontalAxisRect = thePlot->bottomRightRect;
    }
    
    PSScalarRef x[2];
    
    
    x[0] = PSAxisCreateCoordinateFromHorizontalViewCoordinate(PSPlotHorizontalAxis(thePlot), viewPoint.x, horizontalAxisRect, error);
    x[1] = PSAxisCreateCoordinateFromVerticalViewCoordinate(PSPlotVerticalAxis(thePlot), viewPoint.y, thePlot->leftAxisRect, error);
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault,(const void **) x, 2, &kCFTypeArrayCallBacks);
    CFRelease(x[0]);
    CFRelease(x[1]);
    return array;
}

@end


