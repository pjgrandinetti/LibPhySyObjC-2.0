//
//  PSAxis.c
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDataset.h>

@implementation PSAxis

- (void) dealloc
{
    if(self->minimum) CFRelease(self->minimum);
    self->minimum = NULL;
    
    if(self->maximum) CFRelease(self->maximum);
    self->maximum = NULL;
    if(self->majorTicInc) CFRelease(self->majorTicInc);
    self->majorTicInc = NULL;
    [super dealloc];
}

/* Designated Creator */
/**************************/

static bool validateAxis(CFIndex      index,
                         PSScalarRef  minimum,
                         PSScalarRef  maximum,
                         PSScalarRef  majorTicInc,
                         CFIndex      numberOfMinorTics,
                         PSPlotRef    plot)
{
    // *** Validate input parameters ***
    IF_NO_OBJECT_EXISTS_RETURN(minimum,false);
    IF_NO_OBJECT_EXISTS_RETURN(maximum,false);
    IF_NO_OBJECT_EXISTS_RETURN(majorTicInc,false);
    IF_NO_OBJECT_EXISTS_RETURN(plot,false);
    
    if(PSQuantityGetElementType((PSQuantityRef) minimum) != kPSNumberFloat64Type) return false;
    if(PSQuantityGetElementType((PSQuantityRef) maximum) != kPSNumberFloat64Type) return false;
    if(PSQuantityGetElementType((PSQuantityRef) majorTicInc) != kPSNumberFloat64Type) return false;
    
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) minimum, (PSQuantityRef) maximum)) return false;
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) majorTicInc, (PSQuantityRef) maximum)) return false;
    
    PSDependentVariableRef theDependentVariable = PSPlotGetDependentVariable(plot);
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(theDependentVariable);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(index<-1||index>=PSDatasetDimensionsCount(theDataset)) return false;
    
    if(index==-1)   {
        if(!PSQuantityHasSameReducedDimensionality(maximum, theDependentVariable)) return false;
    }
    else {
        PSDimensionRef theDimension = PSDatasetGetDimensionAtIndex(theDataset, index);
        if(!PSUnitHasSameReducedDimensionality(PSQuantityGetUnit(maximum), PSDimensionGetDisplayedUnit(theDimension))) return false;
    }
    return true;
}

static PSAxisRef PSAxisCreate(CFIndex      index,
                              PSScalarRef  minimum,
                              PSScalarRef  maximum,
                              PSScalarRef  majorTicInc,
                              CFIndex      numberOfMinorTics,
                              bool         bipolar,
                              PSPlotRef    plot)
{
    // *** Validate input parameters ***
    if(!validateAxis(index,
                     minimum,
                     maximum,
                     majorTicInc,
                     numberOfMinorTics,
                     plot)) return NULL;
    
    // *** Initialize object ***
    PSAxisRef newAxis = (PSAxisRef) [PSAxis alloc];
    if(newAxis) {
        // *** Setup attributes ***
        newAxis->index = index;
        newAxis->minimum = PSScalarCreateCopy(minimum);
        newAxis->maximum = PSScalarCreateCopy(maximum);
        newAxis->majorTicInc = PSScalarCreateCopy(majorTicInc);
        newAxis->numberOfMinorTics = numberOfMinorTics;
        newAxis->bipolar = bipolar;
        newAxis->plot = plot;           // Reference only, do not retain.
        newAxis->reverse = false;
        return newAxis;
    }
    return NULL;
}
bool PSAxisValidate(PSAxisRef theAxis)
{
    return validateAxis(theAxis->index,
                        theAxis->minimum,
                        theAxis->maximum,
                        theAxis->majorTicInc,
                        theAxis->numberOfMinorTics,
                        theAxis->plot);
}

PSAxisRef PSAxisCreateWithDimensionForPlot(CFIndex index, PSDimensionRef theDimension, PSPlotRef thePlot)
{
    PSScalarRef minimum = PSDimensionCreateDisplayedCoordinateFromIndex(theDimension, PSDimensionLowestIndex(theDimension));
    PSScalarRef maximum = PSDimensionCreateDisplayedCoordinateFromIndex(theDimension, PSDimensionHighestIndex(theDimension));
    CFStringRef quantityName = PSDimensionCopyDisplayedQuantityName(theDimension);
    
    PSAxisRef theAxis = PSAxisCreate(index, minimum, maximum, minimum,5, false,thePlot);
    PSAxisUpdateTics(theAxis, quantityName);
    CFRelease(quantityName);
    CFRelease(minimum);
    CFRelease(maximum);
    return theAxis;
}

PSAxisRef PSAxisCreateResponseArgumentAxisForPlot(PSPlotRef plot)
{
    PSScalarRef minimum = PSScalarCreateWithDouble(-3.5, PSUnitForSymbol(CFSTR("rad")));
    PSScalarRef maximum = PSScalarCreateWithDouble(3.5, PSUnitForSymbol(CFSTR("rad")));
    PSScalarRef majorTicInc = PSScalarCreateWithDouble(0.5, PSUnitForSymbol(CFSTR("rad")));
    PSAxisRef theAxis = PSAxisCreate(-1, minimum, maximum, majorTicInc, 7,true,plot);
    CFRelease(minimum);
    CFRelease(maximum);
    CFRelease(majorTicInc);
    return theAxis;
}

PSAxisRef PSAxisCreateCopyForPlot(PSAxisRef theAxis, PSPlotRef thePlot)
{
    PSAxisRef axis = PSAxisCreate(theAxis->index,
                                  theAxis->minimum,
                                  theAxis->maximum,
                                  theAxis->majorTicInc,
                                  theAxis->numberOfMinorTics,
                                  theAxis->bipolar,
                                  thePlot);
    if(axis) axis->reverse = theAxis->reverse;
    return axis;
}

PSAxisRef PSAxisCreateWithIndexAndUnitForPlot(CFIndex index, CFStringRef quantityName, PSUnitRef unit, void *thePlot)
{
    PSScalarRef temp = PSScalarCreateWithDouble(1.0, unit);
    PSAxisRef theAxis = PSAxisCreate(index,
                                     temp,
                                     temp,
                                     temp,
                                     11,
                                     false,
                                     thePlot);
    
    PSAxisReset(theAxis, quantityName);
    CFRelease(temp);
    return theAxis;
}

bool PSAxisEqual(PSAxisRef input1, PSAxisRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    if(input1->index != input2->index) return false;
    if(PSScalarCompare(input1->minimum, input2->minimum)!=kPSCompareEqualTo) return false;
    if(PSScalarCompare(input1->maximum, input2->maximum)!=kPSCompareEqualTo) return false;
    if(input1->bipolar != input2->bipolar) return false;
    if(PSScalarCompare(input1->majorTicInc, input2->majorTicInc)!=kPSCompareEqualTo) return false;
    return true;
}

bool PSAxisHasSameReducedDimensionality(PSAxisRef input1, PSAxisRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    return PSQuantityHasSameReducedDimensionality((PSQuantityRef) input1->majorTicInc,(PSQuantityRef) input2->majorTicInc);
}

bool PAxisIsCompatibleWithUnit(PSAxisRef theAxis, PSUnitRef theUnit, bool madeDimensionless)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false);
    
    PSDimensionalityRef axisDimensionality = PSAxisGetDimensionality(theAxis);
    if(madeDimensionless && axisDimensionality == PSDimensionalityDimensionless()) return true;
    
    PSDimensionalityRef unitDimensionality = PSUnitGetDimensionality(theUnit);
    return PSDimensionalityHasSameReducedDimensionality(axisDimensionality, unitDimensionality);
}

CFStringRef PSAxisGetQuantityName(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    
    PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, theAxis->index);
    CFStringRef quantityName = PSDimensionGetQuantityName(theDimension);
    return quantityName;
}

PSUnitRef PSAxisGetUnit(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    return PSQuantityGetUnit(theAxis->majorTicInc);
}

bool PSAxisSetUnit(PSAxisRef theAxis, PSUnitRef theUnit, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false);
    bool success = PSScalarConvertToUnit((PSMutableScalarRef) theAxis->majorTicInc, theUnit, error);
    success *= PSScalarConvertToUnit((PSMutableScalarRef) theAxis->minimum, theUnit, error);
    success *=  PSScalarConvertToUnit((PSMutableScalarRef) theAxis->maximum, theUnit, error);
    return success;
}

PSDimensionalityRef PSAxisGetDimensionality(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    return PSQuantityGetUnitDimensionality((PSQuantityRef) theAxis->majorTicInc);
}

PSPlotRef PSAxisGetPlot(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    return theAxis->plot;
}


void PSAxisAddToArrayAsPList(PSAxisRef theAxis, CFMutableArrayRef array)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis && array,);
    CFDictionaryRef plist = PSAxisCreatePList(theAxis);
    CFArrayAppendValue(array, plist);
    CFRelease(plist);
}

CFDictionaryRef PSAxisCreatePList(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    
    CFNumberRef number = PSCFNumberCreateWithCFIndex(theAxis->index);
    CFDictionarySetValue(dictionary, CFSTR("index"), number);
    CFRelease(number);
    
    if(theAxis->minimum) {
        CFStringRef stringValue = PSScalarCreateStringValue(theAxis->minimum);
        if(stringValue) {
            CFDictionarySetValue( dictionary, CFSTR("minimum"), stringValue);
            CFRelease(stringValue);
        }
    }
    
    if(theAxis->maximum) {
        CFStringRef stringValue = PSScalarCreateStringValue(theAxis->maximum);
        if(stringValue) {
            CFDictionarySetValue( dictionary, CFSTR("maximum"), stringValue);
            CFRelease(stringValue);
        }
    }
    
    if(theAxis->majorTicInc) {
        CFStringRef stringValue = PSScalarCreateStringValue(theAxis->majorTicInc);
        if(stringValue) {
            CFDictionarySetValue( dictionary, CFSTR("majorTicInc"), stringValue);
            CFRelease(stringValue);
        }
    }
    
    number = PSCFNumberCreateWithCFIndex(theAxis->numberOfMinorTics);
    CFDictionarySetValue(dictionary, CFSTR("numberOfMinorTics"), number);
    CFRelease(number);
    
    if(theAxis->bipolar) CFDictionarySetValue(dictionary, CFSTR("bipolar"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("bipolar"), kCFBooleanFalse);
    
    if(theAxis->reverse) CFDictionarySetValue(dictionary, CFSTR("reverse"), kCFBooleanTrue);
    else  CFDictionarySetValue(dictionary, CFSTR("reverse"), kCFBooleanFalse);
    
    return dictionary;
}



PSAxisRef PSAxisCreateWithPList(CFDictionaryRef dictionary, PSPlotRef thePlot, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dictionary,NULL);
    
    PSAxisRef theAxis = (PSAxisRef) [PSAxis alloc];
    theAxis->plot = thePlot;
    
    theAxis->index = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("index")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("index")),kCFNumberCFIndexType,&theAxis->index);
    
    theAxis->numberOfMinorTics = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("numberOfMinorTics")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("numberOfMinorTics")),kCFNumberCFIndexType,&theAxis->numberOfMinorTics);
    
    CFBooleanRef bipolar = kCFBooleanFalse;
    if(CFDictionaryContainsKey(dictionary, CFSTR("bipolar")))
        bipolar = CFDictionaryGetValue(dictionary, CFSTR("bipolar"));
    theAxis->bipolar = CFBooleanGetValue(bipolar);
    
    CFBooleanRef reverse = kCFBooleanFalse;
    if(CFDictionaryContainsKey(dictionary, CFSTR("reverse")))
        reverse = CFDictionaryGetValue(dictionary, CFSTR("reverse"));
    theAxis->reverse = CFBooleanGetValue(reverse);
    
    theAxis->minimum = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("minimum")))
        theAxis->minimum = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("minimum")), error);
    
    if(error) {
        if(*error) {
            if(theAxis->minimum) CFRelease(theAxis->minimum);
            if(theAxis) CFRelease(theAxis);
            return NULL;
        }
    }
    theAxis->maximum = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("maximum")))
        theAxis->maximum = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("maximum")), error);
    if(error) {
        if(*error) {
            if(theAxis->minimum) CFRelease(theAxis->minimum);
            if(theAxis->maximum) CFRelease(theAxis->maximum);
            if(theAxis) CFRelease(theAxis);
            return NULL;
        }
    }
    
    
    theAxis->majorTicInc = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("majorTicInc")))
        theAxis->majorTicInc = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("majorTicInc")), error);
    if(error) {
        if(*error) {
            if(theAxis->majorTicInc) CFRelease(theAxis->majorTicInc);
            if(theAxis->minimum) CFRelease(theAxis->minimum);
            if(theAxis->maximum) CFRelease(theAxis->maximum);
            if(theAxis) CFRelease(theAxis);
            return NULL;
        }
    }
    return theAxis;
}

PSAxisRef PSAxisCreateWithOldDataFormat(CFDataRef data, PSPlotRef thePlot, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(data,NULL);
    
    CFPropertyListFormat format;
    CFDictionaryRef dictionary  = CFPropertyListCreateWithData(kCFAllocatorDefault,data,kCFPropertyListImmutable,&format,error);
    if(dictionary==NULL) return NULL;
    
    PSAxisRef theAxis = (PSAxisRef) [PSAxis alloc];
    theAxis->plot = thePlot;
    
    theAxis->index = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("index")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("index")),kCFNumberCFIndexType,&theAxis->index);
    else {
        if(theAxis) CFRelease(theAxis);
        if(dictionary) CFRelease(dictionary);
        return NULL;}
    
    theAxis->numberOfMinorTics = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("numberOfMinorTics")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("numberOfMinorTics")),kCFNumberCFIndexType,&theAxis->numberOfMinorTics);
    else {
        CFRelease(dictionary);
        return NULL;}
    
    CFBooleanRef bipolar = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("bipolar")))
        bipolar = CFDictionaryGetValue(dictionary, CFSTR("bipolar"));
    if(bipolar==NULL) {CFRelease(dictionary); return NULL;}
    theAxis->bipolar = CFBooleanGetValue(bipolar);
    
    theAxis->minimum = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("minimum")))
        theAxis->minimum = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("minimum")),error);
    
    theAxis->maximum = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("maximum")))
        theAxis->maximum = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("maximum")),error);
    
    theAxis->majorTicInc = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("majorTicInc")))
        theAxis->majorTicInc = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("majorTicInc")),error);
    
    CFRelease(dictionary);
    return theAxis;
}



CFIndex PSAxisGetNumberOfMinorTics(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,kCFNotFound);
    return theAxis->numberOfMinorTics;
}

bool PSAxisSetNumberOfMinorTics(PSAxisRef theAxis, CFIndex numberOfMinorTics)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    if(numberOfMinorTics>0) theAxis->numberOfMinorTics = numberOfMinorTics;
    return true;
}

CFIndex PSAxisGetIndex(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,kCFNotFound);
    return theAxis->index;
}

void PSAxisSetIndex(PSAxisRef theAxis, CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,);
    theAxis->index = index;
}

CFIndex PSAxisGetCoordinateIndexClosestToMinimum(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,kCFNotFound);
    PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
    return PSDimensionClosestIndexToDisplayedCoordinate(dimension, theAxis->minimum);
}

CFIndex PSAxisGetCoordinateIndexClosestToMaximum(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,kCFNotFound);
    PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
    return PSDimensionClosestIndexToDisplayedCoordinate(dimension, theAxis->maximum);
}

PSScalarRef PSAxisCreateLowestCoordinate(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    if(theAxis->index<0) return NULL;
    PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
    return PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
}

PSScalarRef PSAxisCreateHighestCoordinate(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    if(theAxis->index<0) return NULL;
    PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
    return PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
}

bool PSAxisTakeParametersFromOtherAxis(PSAxisRef theAxis, PSAxisRef theOtherAxis, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(theOtherAxis,false);
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) theAxis->majorTicInc, (PSQuantityRef) theOtherAxis->majorTicInc)) return false;
    PSAxisSetMinimum(theAxis, theOtherAxis->minimum, true, error);
    PSAxisSetMaximum(theAxis, theOtherAxis->maximum, true, error);
    PSAxisSetMajorTicIncrement(theAxis, theOtherAxis->majorTicInc);
    PSAxisSetBipolar(theAxis, theOtherAxis->bipolar);
    PSAxisSetNumberOfMinorTics(theAxis, theOtherAxis->numberOfMinorTics);
    return true;
}

PSScalarRef PSAxisGetMinimum(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    return theAxis->minimum;
}

PSScalarRef PSAxisGetMaximum(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    return theAxis->maximum;
}

PSScalarRef PSAxisGetMajorTicIncrement(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    return theAxis->majorTicInc;
}

bool PSAxisSetMajorTicIncrement(PSAxisRef theAxis, PSScalarRef value)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(value,false);
    if(PSQuantityGetElementType((PSQuantityRef) value) != kPSNumberFloat64Type) return false;
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) theAxis->majorTicInc, (PSQuantityRef) value)) return false;
    
    if(value == theAxis->majorTicInc) return true;
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = PSScalarCreateCopy(value);
    PSScalarTakeAbsoluteValue((PSMutableScalarRef) theAxis->majorTicInc, NULL);
    return true;
}

PSScalarRef PSAxisCreateMinorTicIncrement(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    return PSScalarCreateByMultiplyingByDimensionlessRealConstant(theAxis->majorTicInc, 1./(double) (theAxis->numberOfMinorTics+1));
}

bool PSAxisGetBipolar(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    return theAxis->bipolar;
}

void PSAxisSetBipolar(PSAxisRef theAxis, bool bipolar)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,);
    theAxis->bipolar = bipolar;
}

void PSAxisToggleBipolar(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,);
    theAxis->bipolar = !theAxis->bipolar;
}

bool PSAxisGetReverse(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    return theAxis->reverse;
}

void PSAxisSetReverse(PSAxisRef theAxis, bool reverse)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,);
    theAxis->reverse = reverse;
}

bool PSAxisSetMinimum(PSAxisRef theAxis, PSScalarRef value, bool ignoreLimits, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis, false);
    IF_NO_OBJECT_EXISTS_RETURN(value, false);
    if(PSQuantityGetElementType((PSQuantityRef) value) != kPSNumberFloat64Type) return false;
    
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) theAxis->majorTicInc, (PSQuantityRef) value)) return false;
    if(value == theAxis->minimum) return true;
    
    
    if(theAxis->index>-1) {
        PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
        CFIndex newMinIndex = PSDimensionClosestIndexToDisplayedCoordinate(dimension, value);
        if(!ignoreLimits) {
            CFIndex maxIndex = PSDimensionClosestIndexToDisplayedCoordinate(dimension, theAxis->maximum);
            if(newMinIndex>=maxIndex) {
                if(error) *error = PSCFErrorCreate(CFSTR("Cannot set axis minimum."), CFSTR("Minimum cannot equal or exceed maximum."), NULL);
                return false;
            }
        }
        
        CFRelease(theAxis->minimum);
        theAxis->minimum = PSScalarCreateCopy(value);
        CFIndex index = PSDimensionClosestIndexToDisplayedCoordinate(dimension, theAxis->minimum);
        PSScalarRef newMinimum = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, index);
        CFRelease(theAxis->minimum);
        theAxis->minimum = newMinimum;
    }
    else {
        if(PSScalarCompare(value, theAxis->maximum)==kPSCompareGreaterThan) {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot set axis minimum."), CFSTR("Minimum cannot exceed maximum."), NULL);
            return false;
        }
        CFRelease(theAxis->minimum);
        theAxis->minimum = PSScalarCreateCopy(value);
    }
    
    PSScalarConvertToUnit((PSMutableScalarRef)theAxis->minimum, PSQuantityGetUnit(theAxis->majorTicInc), error);
    return true;
}

bool PSAxisSetMaximum(PSAxisRef theAxis, PSScalarRef value, bool ignoreLimits, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis, false);
    IF_NO_OBJECT_EXISTS_RETURN(value, false);
    if(PSQuantityGetElementType((PSQuantityRef) value) != kPSNumberFloat64Type) return false;
    
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) theAxis->majorTicInc, (PSQuantityRef) value)) return false;
    if(PSQuantityGetElementType((PSQuantityRef) value) != kPSNumberFloat64Type) return false;
    
    if(value == theAxis->maximum) return true;
    
    if(theAxis->index>-1) {
        CFRelease(theAxis->maximum);
        theAxis->maximum = PSScalarCreateCopy(value);

        PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
        CFIndex newMaxIndex = PSDimensionClosestIndexToDisplayedCoordinate(dimension, value);
        if(!ignoreLimits) {
            CFIndex minIndex = PSDimensionClosestIndexToDisplayedCoordinate(dimension, theAxis->minimum);
            if(newMaxIndex<=minIndex) {
                if(error) *error = PSCFErrorCreate(CFSTR("Cannot set axis maximum."), CFSTR("Minimum cannot equal or exceed maximum."), NULL);
                return false;
            }
        }

        CFIndex index = PSDimensionClosestIndexToDisplayedCoordinate(dimension, theAxis->maximum);
        PSScalarRef newMaximum = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, index);
        CFRelease(theAxis->maximum);
        theAxis->maximum = newMaximum;
    }
    else {
        if(PSScalarCompare(theAxis->minimum,value)==kPSCompareGreaterThan) {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot set axis maximum."), CFSTR("Minimum cannot exceed maximum."), NULL);
            return false;
        }
        CFRelease(theAxis->maximum);
        theAxis->maximum = PSScalarCreateCopy(value);
    }

    
    PSScalarConvertToUnit((PSMutableScalarRef)theAxis->maximum, PSQuantityGetUnit(theAxis->majorTicInc), error);
    return true;
}

bool PSAxisExpand(PSAxisRef theAxis, PSScalarRef expand, bool ignoreLimits, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(expand,false);
    if(PSQuantityGetElementType((PSQuantityRef) expand) != kPSNumberFloat64Type) return false;
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) theAxis->majorTicInc, (PSQuantityRef) expand)) return false;
    PSUnitRef theUnit = PSAxisGetUnit(theAxis);
    
    if(ignoreLimits||theAxis->index==-1) {
        PSScalarRef newMinimum = PSScalarCreateBySubtracting(theAxis->minimum, expand, error);
        PSScalarRef newMaximum = PSScalarCreateByAdding(theAxis->maximum, expand, error);
        PSAxisSetMinimum(theAxis, newMinimum, false, error);
        PSAxisSetMaximum(theAxis, newMaximum , false, error);
        CFRelease(newMinimum);
        CFRelease(newMaximum);
        
        double majorTicInc;
        DefaultAxisTics(PSScalarDoubleValue(theAxis->minimum), PSScalarDoubleValue(theAxis->maximum),&majorTicInc, &theAxis->numberOfMinorTics);
        PSScalarRef newValue = PSScalarCreateWithDouble(fabs(majorTicInc), theUnit);
        CFRelease(theAxis->majorTicInc);
        theAxis->majorTicInc = newValue;
        return true;
    }
    
    bool success = true;
    PSScalarRef lowerLimit = PSAxisCreateLowestCoordinate(theAxis);
    PSScalarRef upperLimit = PSAxisCreateHighestCoordinate(theAxis);
    double lowerLimitValue = PSScalarDoubleValueInUnit(lowerLimit,theUnit,&success);
    double upperLimitValue = PSScalarDoubleValueInUnit(upperLimit,theUnit,&success);
    double widthLimit = fabs(upperLimitValue -  lowerLimitValue);
    CFRelease(lowerLimit);
    CFRelease(upperLimit);
    
    double oldMin = PSScalarDoubleValueInUnit(theAxis->minimum,theUnit,&success);
    double oldMax = PSScalarDoubleValueInUnit(theAxis->maximum,theUnit,&success);
    double oldWidth = fabs(oldMax - oldMin);

    double widthChange = -PSScalarDoubleValueInUnit(expand, theUnit, &success);
    double newWidth = oldWidth + 2*widthChange;
    double newMin = oldMin;
    double newMax = oldMax;
    if(lowerLimitValue<upperLimitValue) {
        newMin -= widthChange;
        newMax += widthChange;
    }
    else {
        newMin += widthChange;
        newMax -= widthChange;
    }
    if(newWidth>widthLimit) {
        newMin = lowerLimitValue;
        newMax = upperLimitValue;
    }
    if(lowerLimitValue<upperLimitValue) {
        if(newMin<lowerLimitValue) {
            newMin = lowerLimitValue;
            newMax = lowerLimitValue + newWidth;
        }
        if(newMax>upperLimitValue) {
            newMax = upperLimitValue;
            newMin = upperLimitValue - newWidth;
        }
    }
    else {
        if(newMin>lowerLimitValue) {
            newMin = lowerLimitValue;
            newMax = lowerLimitValue - newWidth;
        }
        if(newMax<upperLimitValue) {
            newMax = upperLimitValue;
            newMin = upperLimitValue + newWidth;
        }
    }
    PSScalarRef newMinimum = PSScalarCreateWithDouble(newMin, theUnit);
    PSScalarRef newMaximum = PSScalarCreateWithDouble(newMax, theUnit);

    if(theAxis->index>=0) {
        // Abort if width is too small to display points
        PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
        CFIndex pointsVisible = PSDimensionCoordinateCountInDisplayedCoordinateRange(dimension, newMinimum, newMaximum);
        if(pointsVisible<5) {
            CFRelease(newMinimum);
            CFRelease(newMaximum);
            return false;
        }
    }
    
    PSAxisSetMinimum(theAxis, newMinimum, false, error);
    PSAxisSetMaximum(theAxis, newMaximum , false, error);
    CFRelease(newMinimum);
    CFRelease(newMaximum);
    
    double majorTicInc;
    DefaultAxisTics(newMin, newMax,&majorTicInc, &theAxis->numberOfMinorTics);
    PSScalarRef newValue = PSScalarCreateWithDouble(fabs(majorTicInc), theUnit);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = newValue;
    
    return true;
    
    
}

bool PSAxisShift(PSAxisRef theAxis, PSScalarRef shift, bool ignoreLimits, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(shift,false);
    if(PSQuantityGetElementType((PSQuantityRef) shift) != kPSNumberFloat64Type) return false;
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) theAxis->majorTicInc, (PSQuantityRef) shift)) return false;
    if(ignoreLimits||theAxis->index==-1) {
        PSScalarRef newMinimum = PSScalarCreateByAdding(theAxis->minimum, shift, error);
        PSScalarRef newMaximum = PSScalarCreateByAdding(theAxis->maximum, shift, error);
        PSAxisSetMinimum(theAxis, newMinimum, true, error);
        PSAxisSetMaximum(theAxis, newMaximum, true, error);
        CFRelease(newMinimum);
        CFRelease(newMaximum);
        return true;
    }
    
    PSUnitRef theUnit = PSAxisGetUnit(theAxis);
    bool success = true;
    double shiftValue = PSScalarDoubleValueInUnit(shift, theUnit, &success);
    double oldMin = PSScalarDoubleValueInUnit(theAxis->minimum,theUnit,&success);
    double oldMax = PSScalarDoubleValueInUnit(theAxis->maximum,theUnit,&success);
    double width = fabs(oldMax - oldMin);
    double newMin = oldMin + shiftValue;
    double newMax = oldMax + shiftValue;
    
    PSScalarRef lowerLimit = PSAxisCreateLowestCoordinate(theAxis);
    PSScalarRef upperLimit = PSAxisCreateHighestCoordinate(theAxis);
    double lowerLimitValue = PSScalarDoubleValueInUnit(lowerLimit,theUnit,&success);
    double upperLimitValue = PSScalarDoubleValueInUnit(upperLimit,theUnit,&success);
    CFRelease(lowerLimit);
    CFRelease(upperLimit);
    if(lowerLimitValue<upperLimitValue) {
        if(newMin<lowerLimitValue) {
            newMin = lowerLimitValue;
            newMax = lowerLimitValue + width;
        }
        if(newMax>upperLimitValue) {
            newMax = upperLimitValue;
            newMin = upperLimitValue - width;
        }
    }
    else {
        if(newMin>lowerLimitValue) {
            newMin = lowerLimitValue;
            newMax = lowerLimitValue - width;
        }
        if(newMax<upperLimitValue) {
            newMax = upperLimitValue;
            newMin = upperLimitValue + width;
        }
    }
    
    PSScalarRef newMinimum = PSScalarCreateWithDouble(newMin, theUnit);
    PSScalarRef newMaximum = PSScalarCreateWithDouble(newMax, theUnit);
    PSAxisSetMinimum(theAxis, newMinimum, true, error);
    PSAxisSetMaximum(theAxis, newMaximum , true, error);
    CFRelease(newMinimum);
    CFRelease(newMaximum);
    return true;
}

bool PSAxisInverse(PSAxisRef theAxis, PSUnitRef reciprocalUnit, CFStringRef inverseQuantityName, CFErrorRef *error)
{
    if(error) if(*error) return false;
    if(NULL == inverseQuantityName) return false;
    
    PSScalarRef temp = PSScalarCreateByRaisingToAPower(theAxis->maximum, -1, error);
    
    if(reciprocalUnit==NULL) PSScalarBestConversionForQuantityName((PSMutableScalarRef) temp, inverseQuantityName);
    else PSScalarConvertToUnit((PSMutableScalarRef) temp, reciprocalUnit, error);
    CFRelease(theAxis->maximum);
    theAxis->maximum = temp;
    
    temp = PSScalarCreateByRaisingToAPower(theAxis->minimum, -1, error);
    if(reciprocalUnit==NULL) PSScalarBestConversionForQuantityName((PSMutableScalarRef) temp, inverseQuantityName);
    else PSScalarConvertToUnit((PSMutableScalarRef) temp, reciprocalUnit, error);
    CFRelease(theAxis->minimum);
    theAxis->minimum = temp;
    
    temp = PSScalarCreateByRaisingToAPower(theAxis->majorTicInc, -1, error);
    if(reciprocalUnit==NULL) PSScalarBestConversionForQuantityName((PSMutableScalarRef) temp, inverseQuantityName);
    else PSScalarConvertToUnit((PSMutableScalarRef) temp, reciprocalUnit, error);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = temp;
    return true;
}


static void DefaultAxisTics(double initial, double final,double *majorInc, CFIndex *nminor)
{
    if(initial == final) {
        *majorInc = 0;
        *nminor = 4;
        return;
    }
    *nminor = 9;
    int n = (int) nearbyint(log10(fabs(final-initial)));
    *majorInc = pow(10,(double) n) * ((final-initial)/fabs((final-initial)))/10.;
    if(fabs(final-initial)/fabs(*majorInc) >8) {
        *majorInc *= 2.;
        if(fabs(final-initial)/fabs(*majorInc) >8) {
            *majorInc *= 2.;
            *nminor = 4;
        }
        if(fabs(final-initial)/fabs(*majorInc) <3) {
            *majorInc /= 2.;
            *nminor = 4;
        }
    }
    if(fabs(final-initial)/fabs(*majorInc) <3) {
        *majorInc /= 2.;
        if(fabs(final-initial)/fabs(*majorInc) >8) {
            *majorInc *= 2.;
            *nminor = 4;
        }
        if(fabs(final-initial)/fabs(*majorInc) <3) {
            *majorInc /= 2.;
            *nminor = 4;
        }
    }
}

bool PSAxisUpdateTics(PSAxisRef theAxis, CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    if(quantityName == NULL) quantityName = kPSQuantityDimensionless;
    
    PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
    PSScalarRef minimum = PSScalarCreateByConvertingToUnit(theAxis->minimum, unit, NULL);
    PSScalarRef maximum = PSScalarCreateByConvertingToUnit(theAxis->maximum, unit, NULL);
    
    double major;
    DefaultAxisTics(PSScalarDoubleValue(minimum), PSScalarDoubleValue(maximum),&major,&theAxis->numberOfMinorTics);
    
    PSScalarRef newMajorTicInc = PSScalarCreateWithDouble(fabs(major), unit);
    
    //    PSScalarBestConversionForUnit((PSMutableScalarRef) newMajorTicInc, unit);
    PSScalarConvertToUnit((PSMutableScalarRef) theAxis->minimum, PSQuantityGetUnit(newMajorTicInc), NULL);
    PSScalarConvertToUnit((PSMutableScalarRef) theAxis->maximum, PSQuantityGetUnit(newMajorTicInc), NULL);
    
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = newMajorTicInc;
    return true;
}


bool PSAxisDoubleWidth(PSAxisRef theAxis, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    
    PSUnitRef maxUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->maximum);
    PSUnitRef minUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->minimum);
    PSUnitRef axisUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
    
    // Convert all to axis unit and get double values
    bool success = true;
    double minimum = PSScalarDoubleValueInUnit(theAxis->minimum, PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc),&success);
    double maximum = PSScalarDoubleValueInUnit(theAxis->maximum,PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double majorTicInc = PSScalarDoubleValue(theAxis->majorTicInc);
    
    // Update values
    double width = maximum-minimum;
    maximum +=width/2;
    
    if(theAxis->bipolar) {
        minimum -=width/2;
        majorTicInc *=2;
    }
    else DefaultAxisTics(minimum, maximum,&majorTicInc, &theAxis->numberOfMinorTics);
    
    // Convert all back to original units
    PSScalarRef temp = PSScalarCreateWithDouble(minimum, axisUnit);
    PSScalarRef newValue = PSScalarCreateByConvertingToUnit(temp, minUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->minimum);
    theAxis->minimum = newValue;
    
    temp = PSScalarCreateWithDouble(maximum, axisUnit);
    newValue = PSScalarCreateByConvertingToUnit(temp, maxUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->maximum);
    theAxis->maximum = newValue;
    
    newValue = PSScalarCreateWithDouble(fabs(majorTicInc), axisUnit);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = newValue;
    return true;
}

bool PSAxisHalveWidth(PSAxisRef theAxis, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    
    PSUnitRef maxUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->maximum);
    PSUnitRef minUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->minimum);
    PSUnitRef axisUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
    
    // Convert all to axis unit and get double values
    bool success = true;
    double minimum = PSScalarDoubleValueInUnit(theAxis->minimum, PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double maximum = PSScalarDoubleValueInUnit(theAxis->maximum,PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double majorTicInc = PSScalarDoubleValue(theAxis->majorTicInc);
    
    // Update values
    double width = maximum-minimum;
    maximum -=width/4;
    
    if(theAxis->bipolar) {
        minimum +=width/4;
        majorTicInc /=2;
    }
    else DefaultAxisTics(minimum, maximum,&majorTicInc, &theAxis->numberOfMinorTics);
    
    // Convert all back to original units
    PSScalarRef temp = PSScalarCreateWithDouble(minimum, axisUnit);
    PSScalarRef newValue = PSScalarCreateByConvertingToUnit(temp, minUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->minimum);
    theAxis->minimum = newValue;
    
    temp = PSScalarCreateWithDouble(maximum, axisUnit);
    newValue = PSScalarCreateByConvertingToUnit(temp, maxUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->maximum);
    theAxis->maximum = newValue;
    
    newValue = PSScalarCreateWithDouble(fabs(majorTicInc), axisUnit);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = newValue;
    return true;
}

bool PSAxisScaleOutWidth(PSAxisRef theAxis, double scaling, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    
    PSUnitRef maxUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->maximum);
    PSUnitRef minUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->minimum);
    PSUnitRef axisUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
    
    // Convert all to axis unit and get double values
    bool success = true;
    double minimum = PSScalarDoubleValueInUnit(theAxis->minimum, PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc),&success);
    double maximum = PSScalarDoubleValueInUnit(theAxis->maximum,PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double majorTicInc = PSScalarDoubleValue(theAxis->majorTicInc);
    
    // Update values
    double width = maximum-minimum;
    maximum +=width*scaling;
    
    if(theAxis->bipolar) {
        minimum -=width*scaling;
        majorTicInc *=scaling;
    }
    else DefaultAxisTics(minimum, maximum,&majorTicInc, &theAxis->numberOfMinorTics);
    
    // Convert all back to original units
    PSScalarRef temp = PSScalarCreateWithDouble(minimum, axisUnit);
    PSScalarRef newValue = PSScalarCreateByConvertingToUnit(temp, minUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->minimum);
    theAxis->minimum = newValue;
    
    temp = PSScalarCreateWithDouble(maximum, axisUnit);
    newValue = PSScalarCreateByConvertingToUnit(temp, maxUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->maximum);
    theAxis->maximum = newValue;
    
    newValue = PSScalarCreateWithDouble(fabs(majorTicInc), axisUnit);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = newValue;
    return true;
}

bool PSAxisScaleInWidth(PSAxisRef theAxis, double scaling, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    
    PSUnitRef maxUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->maximum);
    PSUnitRef minUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->minimum);
    PSUnitRef axisUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
    
    // Convert all to axis unit and get double values
    bool success = true;
    double minimum = PSScalarDoubleValueInUnit(theAxis->minimum, PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double maximum = PSScalarDoubleValueInUnit(theAxis->maximum,PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double majorTicInc = PSScalarDoubleValue(theAxis->majorTicInc);
    
    // Update values
    double width = maximum-minimum;
    maximum -=width*scaling;
    
    if(theAxis->bipolar) {
        minimum +=width*scaling;
    }
    DefaultAxisTics(minimum, maximum,&majorTicInc, &theAxis->numberOfMinorTics);
    
    // Convert all back to original units
    PSScalarRef temp = PSScalarCreateWithDouble(minimum, axisUnit);
    PSScalarRef newValue = PSScalarCreateByConvertingToUnit(temp, minUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->minimum);
    theAxis->minimum = newValue;
    
    temp = PSScalarCreateWithDouble(maximum, axisUnit);
    newValue = PSScalarCreateByConvertingToUnit(temp, maxUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->maximum);
    theAxis->maximum = newValue;
    
    newValue = PSScalarCreateWithDouble(fabs(majorTicInc), axisUnit);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = newValue;
    return true;
}

bool PSAxisLowerMinimum(PSAxisRef theAxis, double scaling, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    
    PSUnitRef maxUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->maximum);
    PSUnitRef minUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->minimum);
    PSUnitRef axisUnit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
    
    // Convert all to axis unit and get double values
    bool success = true;
    double minimum = PSScalarDoubleValueInUnit(theAxis->minimum, PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double maximum = PSScalarDoubleValueInUnit(theAxis->maximum,PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc), &success);
    double majorTicInc = PSScalarDoubleValue(theAxis->majorTicInc);

    // Update values
    double width = maximum-minimum;
    minimum -=width*scaling;
    
    DefaultAxisTics(minimum, maximum,&majorTicInc, &theAxis->numberOfMinorTics);
    
    // Convert all back to original units
    PSScalarRef temp = PSScalarCreateWithDouble(minimum, axisUnit);
    PSScalarRef newValue = PSScalarCreateByConvertingToUnit(temp, minUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->minimum);
    theAxis->minimum = newValue;
    
    temp = PSScalarCreateWithDouble(maximum, axisUnit);
    newValue = PSScalarCreateByConvertingToUnit(temp, maxUnit, error);
    CFRelease(temp);
    CFRelease(theAxis->maximum);
    theAxis->maximum = newValue;
    
    newValue = PSScalarCreateWithDouble(fabs(majorTicInc), axisUnit);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = newValue;
    return true;
}

CFStringRef PSAxisCreateStringWithQuantityUnitAndIndex(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    PSDependentVariableRef theDependentVariable = PSPlotGetDependentVariable(theAxis->plot);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(theDependentVariable);
    if(theAxis->index==-1) {
        CFStringRef quantityName = PSDependentVariableGetName(theDependentVariable);
        if(CFStringCompare(kPSQuantityDimensionless, quantityName, kCFCompareCaseInsensitive)==kCFCompareEqualTo) return CFSTR("");
        PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
        if(!PSUnitEqual(unit, PSUnitDimensionlessAndUnderived())) {
            CFStringRef symbol = PSUnitCopySymbol(unit);
            CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                          NULL,
                                                          CFSTR("%@ / %@"),
                                                          quantityName,symbol);
            CFRelease(symbol);
            return result;
        }
        CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                      NULL,
                                                      CFSTR("%@"),
                                                      quantityName);
        return result;
    }
    else {
        CFStringRef quantityName = PSDatasetDimensionQuantityNameAtIndex(theDataset, theAxis->index);
        PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
        if(!PSUnitEqual(unit, PSUnitDimensionlessAndUnderived())) {
            CFStringRef symbol = PSUnitCopySymbol(unit);
            CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                          NULL,
                                                          CFSTR("%@ - %ld / %@"),
                                                          quantityName,
                                                          theAxis->index,symbol);
            CFRelease(symbol);
            return result;
        }
        CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                      NULL,
                                                      CFSTR("%@  - %ld"),
                                                      quantityName,theAxis->index);
        return result;
        
    }
}

CFStringRef PSAxisCreateStringWithLabelAndUnit(PSAxisRef theAxis)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    
    PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    PSDependentVariableRef theDependentVariable = PSPlotGetDependentVariable(theAxis->plot);
    if(theAxis->index==-1) {
        CFStringRef label = PSDependentVariableGetComponentLabelAtIndex(theDependentVariable,componentIndex);
        CFIndex length = 0;
        if(label) length = CFStringGetLength(label);
        if(label && length>0) {
            PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
            if(!PSUnitEqual(unit, PSUnitDimensionlessAndUnderived())) {
                CFStringRef symbol = PSUnitCopySymbol(unit);
                CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                              NULL,
                                                              CFSTR("%@ / %@"),
                                                              label,symbol);
                CFRelease(symbol);
                return result;
            }
            CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                          NULL,
                                                          CFSTR("%@"),
                                                          label);
            return result;
        }
        else return PSAxisCreateStringWithQuantityUnitAndIndex(theAxis);
    }
    else {
        CFStringRef label = PSDatasetDimensionLabelAtIndex(theDataset, theAxis->index);
        CFIndex length = 0;
        if(label) length = CFStringGetLength(label);
        if(label && length>0) {
            PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) theAxis->majorTicInc);
            if(!PSUnitEqual(unit, PSUnitDimensionlessAndUnderived())) {
                CFStringRef symbol = PSUnitCopySymbol(unit);
                CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                              NULL,
                                                              CFSTR("%@ - %ld / %@"),
                                                              label,
                                                              theAxis->index,symbol);
                CFRelease(symbol);
                return result;
            }
            CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                          NULL,
                                                          CFSTR("%@ - %ld"),
                                                          label,theAxis->index);
            return result;
        }
        else  return PSAxisCreateStringWithQuantityUnitAndIndex(theAxis);
    }
}


bool PSAxisUpdate(PSAxisRef theAxis, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    PSDependentVariableRef theDependentVariable = PSPlotGetDependentVariable(theAxis->plot);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(theDependentVariable);
    CFStringRef quantityName = kPSQuantityDimensionless;
    if(theAxis->index > -1) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
        quantityName = PSDimensionCopyDisplayedQuantityName(dimension);
        PSUnitRef unit = PSDimensionGetDisplayedUnit(dimension);
        if(!PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(unit), PSQuantityGetUnitDimensionality((PSQuantityRef) theAxis->majorTicInc))) {
            PSScalarRef newValue = PSScalarCreateByConvertingToUnit(theAxis->minimum, unit, error);
            PSAxisSetMinimum(theAxis, newValue, false, error);
            CFRelease(newValue);
            newValue = PSScalarCreateByConvertingToUnit(theAxis->maximum, unit, error);
            PSAxisSetMaximum(theAxis, newValue,false, error);
            CFRelease(newValue);
            newValue = PSScalarCreateByConvertingToUnit(theAxis->majorTicInc, unit, error);
            PSAxisSetMajorTicIncrement(theAxis, newValue);
            CFRelease(newValue);
        }
        PSAxisUpdateTics(theAxis, quantityName);
        CFRelease(quantityName);
    }
    else {
        PSUnitRef unit = PSQuantityGetUnit(theDependentVariable);
        if(!PSQuantityHasSameReducedDimensionality(theDependentVariable, theAxis->majorTicInc)) {
            PSScalarRef newValue = PSScalarCreateByConvertingToUnit(theAxis->minimum, unit, error);
            PSAxisSetMinimum(theAxis, newValue,false, error);
            CFRelease(newValue);
            newValue = PSScalarCreateByConvertingToUnit(theAxis->maximum, unit, error);
            PSAxisSetMaximum(theAxis, newValue,false, error);
            CFRelease(newValue);
            newValue = PSScalarCreateByConvertingToUnit(theAxis->majorTicInc, unit, error);
            PSAxisSetMajorTicIncrement(theAxis, newValue);
            CFRelease(newValue);
        }
        PSAxisUpdateTics(theAxis, quantityName);
    }
    return false;
}

bool PSAxisResetWithMinAndMax(PSAxisRef theAxis, CFStringRef quantityName, PSScalarRef minimum, PSScalarRef maximum)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) minimum, (PSQuantityRef) maximum)) return false;
    
    PSUnitRef unit = PSQuantityGetUnit(theAxis->majorTicInc);
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) minimum, (PSQuantityRef) theAxis->majorTicInc)) {
        unit = PSQuantityGetUnit(minimum);
    }
    double majorInc = 0;
    DefaultAxisTics(PSScalarDoubleValueInUnit(minimum,unit,NULL), PSScalarDoubleValueInUnit(maximum, unit, NULL),&majorInc, &theAxis->numberOfMinorTics);
    CFRelease(theAxis->majorTicInc);
    theAxis->majorTicInc = PSScalarCreateWithDouble(fabs(majorInc), unit);
    
    PSScalarBestConversionForQuantityName((PSMutableScalarRef) theAxis->majorTicInc, quantityName);
    unit = PSQuantityGetUnit(theAxis->majorTicInc);
    
    CFRelease(theAxis->minimum);
    CFRelease(theAxis->maximum);
    theAxis->minimum = PSScalarCreateByConvertingToUnit(minimum, unit, NULL);
    theAxis->maximum = PSScalarCreateByConvertingToUnit(maximum, unit, NULL);
    
    return true;
}

bool PSAxisReset(PSAxisRef theAxis, CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,false);
    PSDependentVariableRef theDependentVariable = PSPlotGetDependentVariable(theAxis->plot);
    PSDatasetRef theDataset = PSDependentVariableGetDataset(theDependentVariable);
    if(theAxis->index > -1) {
        CFRelease(theAxis->minimum);
        CFRelease(theAxis->maximum);
        
        CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
        theAxis->minimum = PSDimensionCreateDisplayedCoordinateMinimumForDimensionAtIndex(dimensions, theAxis->index);
        theAxis->maximum = PSDimensionCreateDisplayedCoordinateMaximumForDimensionAtIndex(dimensions, theAxis->index);
        
        if(!PSQuantityHasSameDimensionality((PSQuantityRef) theAxis->minimum, (PSQuantityRef) theAxis->majorTicInc)) {
            CFRelease(theAxis->majorTicInc);
            theAxis->majorTicInc = CFRetain(theAxis->maximum);
        }
    }
    else {
        bool real = PSPlotGetReal(theAxis->plot);
        bool imag = PSPlotGetImag(theAxis->plot);
        bool magnitude = PSPlotGetMagnitude(theAxis->plot);
        bool argument = PSPlotGetArgument(theAxis->plot);
        
        CFArrayRef values = NULL;
        if(real&&imag) {
            values = PSDependentVariableCreateArrayWithMinAndMaxForPart(theDependentVariable,
                                                                        kPSRealPart);
            PSScalarRef minimum = CFRetain(CFArrayGetValueAtIndex(values, 0));
            PSScalarRef maximum = CFRetain(CFArrayGetValueAtIndex(values, 1));
            CFRelease(values);
            
            values = PSDependentVariableCreateArrayWithMinAndMaxForPart(theDependentVariable, kPSImaginaryPart);
            if(PSScalarCompare(minimum, CFArrayGetValueAtIndex(values, 0)) == kPSCompareGreaterThan) {
                CFRelease(minimum);
                minimum = CFRetain(CFArrayGetValueAtIndex(values, 0));
            }
            if(PSScalarCompare(maximum, CFArrayGetValueAtIndex(values, 1)) == kPSCompareLessThan) {
                CFRelease(maximum);
                maximum = CFRetain(CFArrayGetValueAtIndex(values, 1));
            }
            CFRelease(values);
            
            CFRelease(theAxis->minimum);
            CFRelease(theAxis->maximum);
            theAxis->minimum = minimum;
            theAxis->maximum = maximum;
        }
        else if(real) {
            values = PSDependentVariableCreateArrayWithMinAndMaxForPart(theDependentVariable, kPSRealPart);
            CFRelease(theAxis->minimum);
            CFRelease(theAxis->maximum);
            theAxis->minimum = CFRetain(CFArrayGetValueAtIndex(values, 0));
            theAxis->maximum = CFRetain(CFArrayGetValueAtIndex(values, 1));
            CFRelease(values);
            
        }
        else if(imag) {
            values = PSDependentVariableCreateArrayWithMinAndMaxForPart(theDependentVariable, kPSImaginaryPart);
            CFRelease(theAxis->minimum);
            CFRelease(theAxis->maximum);
            theAxis->minimum = CFRetain(CFArrayGetValueAtIndex(values, 0));
            theAxis->maximum = CFRetain(CFArrayGetValueAtIndex(values, 1));
            CFRelease(values);
            
        }
        else if(magnitude) {
            values = PSDependentVariableCreateArrayWithMinAndMaxForPart(theDependentVariable, kPSMagnitudePart);
            CFRelease(theAxis->minimum);
            CFRelease(theAxis->maximum);
            theAxis->minimum = CFRetain(CFArrayGetValueAtIndex(values, 0));
            theAxis->maximum = CFRetain(CFArrayGetValueAtIndex(values, 1));
            CFRelease(values);
            
        }
        else if(argument) {
            values = PSDependentVariableCreateArrayWithMinAndMaxForPart(theDependentVariable, kPSArgumentPart);
            CFRelease(theAxis->minimum);
            CFRelease(theAxis->maximum);
            theAxis->minimum = CFRetain(CFArrayGetValueAtIndex(values, 0));
            theAxis->maximum = CFRetain(CFArrayGetValueAtIndex(values, 1));
            CFRelease(values);
            
        }
        
        if(theAxis->bipolar) {
            if(fabs(PSScalarDoubleValue(theAxis->minimum)) > fabs(PSScalarDoubleValue(theAxis->maximum))) {
                CFRelease(theAxis->maximum);
                theAxis->maximum = PSScalarCreateByMultiplyingByDimensionlessRealConstant(theAxis->minimum, -1);
            }
            else {
                CFRelease(theAxis->minimum);
                theAxis->minimum = PSScalarCreateByMultiplyingByDimensionlessRealConstant(theAxis->maximum, -1);
            }
        }
        
        if(PSQuantityHasSameDimensionality((PSQuantityRef) theAxis->maximum, (PSQuantityRef) theAxis->majorTicInc)) {
            PSUnitRef unit = PSQuantityGetUnit(theAxis->majorTicInc);
            theAxis->majorTicInc = PSScalarCreateByConvertingToUnit(theAxis->maximum, unit, NULL);
        }
        else theAxis->majorTicInc = CFRetain(theAxis->maximum);
        
        if(PSScalarCompare(theAxis->minimum, theAxis->maximum) == kPSCompareEqualTo) {
            if(PSScalarMagnitudeValue(theAxis->minimum) == 0.0) {
                PSUnitRef unit = PSQuantityGetUnit(theAxis->minimum);
                numberType type = PSQuantityGetElementType(theAxis->minimum);
                PSScalarRef one = NULL;
                PSScalarRef minusOne = NULL;
                switch (type) {
                    case kPSNumberFloat32Type:
                        one = PSScalarCreateWithFloat(1,unit);
                        minusOne = PSScalarCreateWithFloat(-1,unit);
                        break;
                    case kPSNumberFloat64Type:
                        one = PSScalarCreateWithDouble(1,unit);
                        minusOne = PSScalarCreateWithDouble(-1,unit);
                        break;
                    case kPSNumberFloat32ComplexType:
                        one = PSScalarCreateWithFloatComplex(1+I,unit);
                        minusOne = PSScalarCreateWithFloatComplex(-1-I,unit);
                        break;
                    case kPSNumberFloat64ComplexType:
                        one = PSScalarCreateWithDoubleComplex(1+I,unit);
                        minusOne = PSScalarCreateWithDoubleComplex(-1-I,unit);
                        break;
                }
                if(one && minusOne) {
                    CFRelease(theAxis->minimum);
                    CFRelease(theAxis->maximum);
                    theAxis->minimum = minusOne;
                    theAxis->maximum = one;
                }
                else NSLog(@"Uh oh");
            }
            else{
                PSScalarSetDoubleValue((PSMutableScalarRef) theAxis->minimum, 0);
            }
        }
    }
    
    PSAxisUpdateTics(theAxis, quantityName);
    return true;
}

PSScalarRef PSAxisCreateHorizontalScaleAndOffsetInRect(PSAxisRef theAxis,
                                                       CGRect axisRect,
                                                       double *offset,
                                                       CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    PSMutableScalarRef scale = (PSMutableScalarRef) PSScalarCreateBySubtracting(theAxis->maximum, theAxis->minimum, error);
    PSScalarMultiplyByDimensionlessRealConstant(scale,1./axisRect.size.width);
    PSScalarRaiseToAPower(scale, -1, error);
    *offset = axisRect.origin.x;
    if(theAxis->reverse) {
        *offset = axisRect.origin.x + axisRect.size.width;
        PSScalarMultiplyByDimensionlessRealConstant(scale, -1);
    }
    return scale;
}

PSScalarRef PSAxisCreateVerticalScaleAndOffsetInRect(PSAxisRef theAxis, CGRect axisRect, double *offset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    PSMutableScalarRef scale = (PSMutableScalarRef) PSScalarCreateBySubtracting(theAxis->maximum, theAxis->minimum, error);
    PSScalarMultiplyByDimensionlessRealConstant(scale,1./axisRect.size.height);
    PSScalarRaiseToAPower(scale, -1, error);
    *offset = axisRect.origin.y;
    if(theAxis->reverse) {
        *offset = axisRect.origin.y + axisRect.size.height;
        PSScalarMultiplyByDimensionlessRealConstant(scale, -1);
    }
    return scale;
}

double PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(PSAxisRef theAxis, PSScalarRef axisCoordinate, CGRect axisRect, CFErrorRef *error)
{
    if(error) if(*error) return 0;
    
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,0);
    IF_NO_OBJECT_EXISTS_RETURN(axisCoordinate,0);
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSAxisGetDimensionality(theAxis),
                                                     PSQuantityGetUnitDimensionality((PSQuantityRef) axisCoordinate))) return 0.0;
    
    double coordinate = PSScalarDoubleValue(axisCoordinate);
    PSUnitRef unit = PSQuantityGetUnit(axisCoordinate);
    bool success = true;
    double minimum = PSScalarDoubleValueInUnit(theAxis->minimum, unit, &success);
    double maximum = PSScalarDoubleValueInUnit(theAxis->maximum, unit, &success);
    double horizontalScale = axisRect.size.width/(maximum - minimum);
    if(theAxis->reverse) return axisRect.size.width+ axisRect.origin.x - horizontalScale*(coordinate - minimum);
    return horizontalScale*(coordinate - minimum) + axisRect.origin.x;
}

double PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(PSAxisRef theAxis, PSScalarRef axisCoordinate, CGRect axisRect, CFErrorRef *error)
{
    if(error) if(*error) return 0;
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,0);
    IF_NO_OBJECT_EXISTS_RETURN(axisCoordinate,0);
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSAxisGetDimensionality(theAxis), PSQuantityGetUnitDimensionality((PSQuantityRef) axisCoordinate))) return 0.0;
    
    PSDatasetRef theDataset = PSPlotGetDataset(theAxis->plot);
    if(theAxis->index == -1) {
        double offset;
        PSScalarRef scale = PSAxisCreateVerticalScaleAndOffsetInRect(theAxis, axisRect, &offset, error);
        PSMutableScalarRef diff = (PSMutableScalarRef) PSScalarCreateBySubtracting(axisCoordinate, theAxis->minimum, error);
        PSScalarMultiply(diff, scale, error);
        double result = PSScalarDoubleValueInCoherentUnit(diff) + offset;
        CFRelease(scale);
        CFRelease(diff);
        return result;
    }
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, theAxis->index);
    double dIndex = PSDimensionIndexFromDisplayedCoordinate(dimension, axisCoordinate);
    double vCoordinateIndexMin = PSAxisGetCoordinateIndexClosestToMinimum(theAxis);
    double vCoordinateIndexMax = PSAxisGetCoordinateIndexClosestToMaximum(theAxis);
    double verticalScale = axisRect.size.height/(vCoordinateIndexMax - vCoordinateIndexMin);
    if(theAxis->reverse) return axisRect.size.height+axisRect.origin.y-verticalScale*(dIndex-vCoordinateIndexMin);
    return verticalScale*(dIndex - vCoordinateIndexMin) + axisRect.origin.y;
}

PSScalarRef PSAxisCreateCoordinateFromHorizontalViewCoordinate(PSAxisRef theAxis, double horizontalViewCoordinate, CGRect axisRect, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    double offset;
    PSMutableScalarRef coordinate = (PSMutableScalarRef) PSAxisCreateHorizontalScaleAndOffsetInRect(theAxis, axisRect, &offset, error);
    horizontalViewCoordinate -= offset;
    PSScalarRaiseToAPower(coordinate, -1, error);
    PSScalarMultiplyByDimensionlessRealConstant(coordinate, horizontalViewCoordinate);
    PSScalarAdd(coordinate, theAxis->minimum, error);
    return coordinate;
}

PSScalarRef PSAxisCreateCoordinateFromVerticalViewCoordinate(PSAxisRef theAxis, double verticalViewCoordinate, CGRect axisRect, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theAxis,NULL);
    double offset;
    PSMutableScalarRef coordinate = (PSMutableScalarRef) PSAxisCreateVerticalScaleAndOffsetInRect(theAxis, axisRect, &offset, error);
    verticalViewCoordinate -= offset;
    PSScalarRaiseToAPower(coordinate, -1, error);
    PSScalarMultiplyByDimensionlessRealConstant(coordinate, verticalViewCoordinate);
    PSScalarAdd(coordinate, theAxis->minimum, error);
    return coordinate;
}

@end



