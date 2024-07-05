//
//  PSDimension.c
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDataset.h>

@implementation PSCoreDimension
- (void) dealloc
{
    if(self->label) CFRelease(self->label);
    self->label = NULL;
    
    if(self->description) CFRelease(self->description);
    self->description = NULL;

    if(self->metaData) CFRelease(self->metaData);
    self->metaData = NULL;
    
    [super dealloc];
}

PSCoreDimensionRef PSCoreDimensionInitialize(PSCoreDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    theDimension->label = CFSTR("");
    theDimension->description = CFSTR("");
    theDimension->metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return theDimension;
}

PSCoreDimensionRef PSCoreDimensionCreateDefault(void)
{
    PSCoreDimension *theDimension = [PSCoreDimension alloc];
    return PSCoreDimensionInitialize(theDimension);
}

CFStringRef PSCoreDimensionGetLabel(PSCoreDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->label;
}

void PSCoreDimensionSetLabel(PSCoreDimensionRef theDimension, CFStringRef label)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(theDimension->label) CFRelease(theDimension->label);
    if(label) theDimension->label = CFRetain(label);
    else theDimension->label = NULL;
}

CFStringRef PSCoreDimensionGetDescription(PSCoreDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->description;
}

void PSCoreDimensionSetDescription(PSCoreDimensionRef theDimension, CFStringRef description)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(theDimension->description) CFRelease(theDimension->description);
    if(description) theDimension->description = CFRetain(description);
    else theDimension->description = NULL;
}

CFDictionaryRef PSCoreDimensionGetMetaData(PSCoreDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->metaData;
}

void PSCoreDimensionSetMetaData(PSCoreDimensionRef theDimension, CFDictionaryRef metaData)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(metaData == theDimension->metaData) return;
    if(theDimension->metaData) CFRelease(theDimension->metaData);
    if(metaData) theDimension->metaData = CFRetain(metaData);
    else theDimension->metaData = NULL;
}
@end

@implementation PSLabeledDimension

- (void) dealloc
{
    if(self->labels) CFRelease(self->labels);
    self->labels = NULL;
    
    [super dealloc];
}

PSLabeledDimensionRef PSLabeledDimensionCreateDefault(CFArrayRef labels)
{
    // *** Validate input parameters ***
    
    IF_NO_OBJECT_EXISTS_RETURN(labels,NULL);
    CFIndex count = CFArrayGetCount(labels);
    if(count<2) return NULL;
    
    // *** Initialize object ***
    PSLabeledDimension *theDimension = [PSLabeledDimension alloc];
    if(PSCoreDimensionInitialize(theDimension)) {
        theDimension->labels = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, labels);
        return theDimension;
    }
    return NULL;
}

PSLabeledDimensionRef PSLabeledDimensionCreateCopy(PSLabeledDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    // *** Initialize object ***
    PSLabeledDimension *copy = [PSLabeledDimension alloc];
    copy->label = CFStringCreateCopy(kCFAllocatorDefault,theDimension->label);
    copy->description = CFStringCreateCopy(kCFAllocatorDefault,theDimension->description);
    copy->metaData = CFDictionaryCreateCopy(kCFAllocatorDefault, theDimension->metaData);
    copy->labels = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, theDimension->labels);
    return copy;
}

CFIndex PSLabeledDimensionGetCount(PSLabeledDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,0);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->labels,0);
    return CFArrayGetCount(theDimension->labels);
}

CFArrayRef PSLabeledDimensionGetLabels(PSLabeledDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->labels;
}

bool PSLabeledDimensionSetLabels(PSLabeledDimensionRef theDimension, CFArrayRef labels)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(labels,false);
    if(theDimension->labels == labels) return true;
    if(theDimension->labels) CFRelease(theDimension->labels);
    theDimension->labels = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, labels);
    return true;
}

CFStringRef PSLabeledDimensionGetLabelAtIndex(PSLabeledDimensionRef theDimension, CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->labels,NULL);
    if(index<0 || index>=CFArrayGetCount(theDimension->labels)) return NULL;
    return CFArrayGetValueAtIndex(theDimension->labels, index);
}

bool PSLabeledDimensionSetLabelAtIndex(PSLabeledDimensionRef theDimension, CFIndex index, CFStringRef label)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(label,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->labels,false);
    if(index<0 || index>=CFArrayGetCount(theDimension->labels)) return false;
    CFArraySetValueAtIndex(theDimension->labels, index, label);
    return true;
}

@end

@implementation PSQuantitativeDimension
- (void) dealloc
{
    if(self->quantityName) CFRelease(self->quantityName);
    self->quantityName = NULL;
    
    if(self->referenceOffset) CFRelease(self->referenceOffset);
    self->referenceOffset = NULL;
    
    if(self->originOffset) CFRelease(self->originOffset);
    self->originOffset = NULL;
    
    if(self->period) CFRelease(self->period);
    self->period = NULL;
    
    [super dealloc];
}

PSQuantitativeDimensionRef PSQuantitativeDimensionInitialize(PSQuantitativeDimensionRef theDimension,
                                                             CFStringRef quantityName)
{
    if(PSCoreDimensionInitialize(theDimension)) {
        if(NULL==quantityName) {
            CFRelease(theDimension);
            return NULL;
        }
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
        if(NULL==dimensionality) {
            CFRelease(theDimension);
            return NULL;
        }
        theDimension->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
        theDimension->periodic = false;
        theDimension->scaling = kDimensionScalingNone;
        
        CFArrayRef units = PSUnitCreateArrayOfUnitsForQuantityName(quantityName);
        PSUnitRef theUnit = CFArrayGetValueAtIndex(units, 0);
        CFRelease(units);
        
        theDimension->originOffset = PSScalarCreateWithDouble(0.0, theUnit);
        theDimension->referenceOffset = PSScalarCreateWithDouble(0.0, theUnit);
        theDimension->period = NULL;
        return theDimension;
    }
    return NULL;
}

PSQuantitativeDimensionRef PSQuantitativeDimensionCreateDefault(CFStringRef quantityName)
{
    // *** Initialize object ***
    PSQuantitativeDimension *theDimension = [PSQuantitativeDimension alloc];
    return PSQuantitativeDimensionInitialize(theDimension,quantityName);
}

PSQuantitativeDimensionRef PSQuantitativeDimensionCreateCopy(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    // *** Initialize object ***
    PSQuantitativeDimension *copy = [PSQuantitativeDimension alloc];
    copy->label = CFStringCreateCopy(kCFAllocatorDefault,theDimension->label);
    copy->description = CFStringCreateCopy(kCFAllocatorDefault,theDimension->description);
    copy->metaData = CFDictionaryCreateCopy(kCFAllocatorDefault, theDimension->metaData);
    copy->quantityName = CFStringCreateCopy(kCFAllocatorDefault,theDimension->quantityName);
    copy->scaling = theDimension->scaling;
    copy->periodic = theDimension->periodic;
    copy->originOffset = PSScalarCreateCopy(theDimension->originOffset);
    copy->referenceOffset = PSScalarCreateCopy(theDimension->referenceOffset);
    if(theDimension->period) copy->period = PSScalarCreateCopy(theDimension->period);
    else copy->period = NULL;
    return copy;
}


CFStringRef PSQuantitativeDimensionGetQuantityName(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->quantityName;
}

CFStringRef PSQuantitativeDimensionCopyDisplayedQuantityName(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    switch (theDimension->scaling) {
        case kDimensionScalingNone:
            return CFStringCreateCopy(kCFAllocatorDefault, theDimension->quantityName);
        case kDimensionScalingNMR: {
            CFMutableStringRef quantityName = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, theDimension->quantityName);
            CFStringAppend(quantityName, CFSTR(" ratio"));
            PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
            if(dimensionality) return quantityName;
            if(quantityName) CFRelease(quantityName);
            return CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityDimensionless);
        }
    }
}

void PSQuantitativeDimensionSetQuantityName(PSQuantitativeDimensionRef theDimension, CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(quantityName,);
    if(quantityName == theDimension->quantityName) return;
    
    PSDimensionalityRef theDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    CFArrayRef quantityNames = PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality(theDimensionality);
    if(CFArrayContainsValue(quantityNames, CFRangeMake(0,CFArrayGetCount(quantityNames)), quantityName)) {
        if(theDimension->quantityName) CFRelease(theDimension->quantityName);
        theDimension->quantityName = CFRetain(quantityName);
    }
    CFRelease(quantityNames);
}

PSScalarRef PSQuantitativeDimensionGetReferenceOffset(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->referenceOffset;
}

void PSQuantitativeDimensionZeroReferenceOffset(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    PSScalarZeroPart((PSMutableScalarRef) theDimension->referenceOffset, kPSMagnitudePart);
}

bool PSQuantitativeDimensionSetReferenceOffset(PSQuantitativeDimensionRef theDimension, PSScalarRef referenceOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(referenceOffset,false);
    if(PSQuantityIsComplexType(referenceOffset)) return false;
    if(theDimension->referenceOffset == referenceOffset) return true;
    PSDimensionalityRef quanitityDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    if(!PSDimensionalityHasSameReducedDimensionality(quanitityDimensionality, PSQuantityGetUnitDimensionality(referenceOffset))) return false;
    CFRelease(theDimension->referenceOffset);
    theDimension->referenceOffset = PSScalarCreateCopy(referenceOffset);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->referenceOffset, kPSNumberFloat64Type);
    return true;
}

PSScalarRef PSQuantitativeDimensionGetOriginOffset(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->originOffset;
}

bool PSQuantitativeDimensionSetOriginOffset(PSQuantitativeDimensionRef theDimension, PSScalarRef originOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(originOffset,false);
    if(PSQuantityIsComplexType(originOffset)) return false;
    if(theDimension->originOffset == originOffset) return true;
    PSDimensionalityRef quanitityDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    if(!PSDimensionalityHasSameReducedDimensionality(quanitityDimensionality, PSQuantityGetUnitDimensionality(originOffset))) return false;
    CFRelease(theDimension->originOffset);
    theDimension->originOffset = PSScalarCreateCopy(originOffset);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->originOffset, kPSNumberFloat64Type);
    return true;
}

PSScalarRef PSQuantitativeDimensionGetPeriod(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->period;
}

bool PSQuantitativeDimensionSetPeriod(PSQuantitativeDimensionRef theDimension, PSScalarRef period)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(period,false);
    if(PSQuantityIsComplexType(period)) return false;
    if(theDimension->period == period) return true;
    PSDimensionalityRef quanitityDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    if(!PSDimensionalityHasSameReducedDimensionality(quanitityDimensionality, PSQuantityGetUnitDimensionality(period))) return false;
   CFRelease(theDimension->period);
    theDimension->period = PSScalarCreateCopy(period);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->period, kPSNumberFloat64Type);
    return true;
}

bool PSQuantitativeDimensionGetPeriodic(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->periodic;
}

bool PSQuantitativeDimensionSetPeriodic(PSQuantitativeDimensionRef theDimension, bool periodic)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    if(NULL==theDimension->period) return false;
    theDimension->periodic = periodic;
    return true;
}

dimensionScaling PSQuantitativeDimensionGetMadeDimensionless(PSQuantitativeDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->scaling;
}

bool PSQuantitativeDimensionSetScaling(PSQuantitativeDimensionRef theDimension, dimensionScaling scaling)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    if(scaling == theDimension->scaling) return true;
    switch (scaling) {
        case kDimensionScalingNone:
            theDimension->scaling = scaling;
            return true;
        case kDimensionScalingNMR:
            if(PSScalarFloatValue(theDimension->originOffset) == 0.0) return false;
            PSScalarRef totalOffset = PSScalarCreateByAdding(theDimension->originOffset, theDimension->referenceOffset, NULL);
            float offset = PSScalarFloatValue(totalOffset);
            CFRelease(totalOffset);
            if(offset == 0.0) return false;
            theDimension->scaling = scaling;
            return true;
    }
}

#pragma mark PSQuantitativeDimension Operatioms

bool PSQuantitativeDimensionMultiplyByScalar(PSQuantitativeDimensionRef theDimension,
                                             PSScalarRef theScalar,
                                             CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    if(PSScalarDoubleValue(theScalar) == 0.0) return false;
    if(PSQuantityHasDimensionality(theScalar,PSDimensionalityDimensionless())&& PSScalarIsReal(theScalar) && PSScalarDoubleValue(theScalar)==1) return true;
    
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->originOffset, theScalar, error);
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->referenceOffset, theScalar, error);
    if(theDimension->period) PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->period, theScalar, error);
    
    if(theDimension->quantityName) CFRelease(theDimension->quantityName);
    CFStringRef quantityName = PSUnitGuessQuantityName(PSQuantityGetUnit(theDimension->originOffset));
    theDimension->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
    
    return true;
}



@end

@implementation PSMonotonicDimension
- (void) dealloc
{
    if(self->coordinates) CFRelease(self->coordinates);
    self->coordinates = NULL;
    
    if(self->reciprocal) CFRelease(self->reciprocal);
    self->reciprocal = NULL;
    
    [super dealloc];
}

PSMonotonicDimensionRef PSMonotonicDimensionCreateDefault2(CFArrayRef coordinates, CFStringRef quantityName)
{
    // *** Validate input parameters ***
    
    IF_NO_OBJECT_EXISTS_RETURN(coordinates,NULL);
    CFIndex coordinatesCount = CFArrayGetCount(coordinates);
    if(coordinatesCount<2) return NULL;
    
    PSScalarRef firstCoordinate = CFArrayGetValueAtIndex(coordinates, 0);
    if(PSQuantityIsComplexType(firstCoordinate)) return NULL;
    PSDimensionalityRef theDimensionality = PSQuantityGetUnitDimensionality(firstCoordinate);
    PSUnitRef theUnit = PSQuantityGetUnit(firstCoordinate);
    for(CFIndex index = 1; index<coordinatesCount;index++) {
        PSScalarRef coordinate = CFArrayGetValueAtIndex(coordinates, index);
        if(!PSQuantityHasSameReducedDimensionality(firstCoordinate, coordinate)) return NULL;
        if(PSQuantityIsComplexType(coordinate)) return NULL;
    }
    
    if(quantityName) {
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
        if(!PSDimensionalityHasSameReducedDimensionality(dimensionality,theDimensionality)) return NULL;
    }
    if(NULL==quantityName) quantityName = PSUnitGuessQuantityName(theUnit);
    
    // *** Initialize object ***
    PSMonotonicDimension *theDimension = [PSMonotonicDimension alloc];
    if(PSQuantitativeDimensionInitialize(theDimension, quantityName)) {
        theDimension->coordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<coordinatesCount;index++) {
            PSScalarRef coordinate = CFArrayGetValueAtIndex(coordinates, index);
            PSScalarRef coordinateCopy = NULL;
            if(PSDimensionalityEqual(theDimensionality, PSQuantityGetUnitDimensionality(coordinate))) {
                coordinateCopy = PSScalarCreateCopy(coordinate);
            }
            else coordinateCopy = PSScalarCreateByReducingUnit(coordinate);
            CFArrayAppendValue(theDimension->coordinates, coordinateCopy);
            CFRelease(coordinateCopy);
        }
        PSScalarRef lastCoordinate =  CFArrayGetValueAtIndex(coordinates, coordinatesCount-1);
        theDimension->period = PSScalarCreateBySubtracting(lastCoordinate, firstCoordinate, NULL);
        theDimension->periodic = false;
        
        double multiplier = 1;
        PSUnitRef theReciprocalUnit = PSUnitByRaisingToAPower(theUnit, -1, &multiplier, NULL);
        theDimension->reciprocal = PSQuantitativeDimensionCreateDefault(PSUnitGuessQuantityName(theReciprocalUnit));
        return theDimension;
    }
    return NULL;
}

PSMonotonicDimensionRef PSMonotonicDimensionCreateCopy(PSMonotonicDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    PSMonotonicDimension *copy = [PSMonotonicDimension alloc];
    copy->label = CFStringCreateCopy(kCFAllocatorDefault,theDimension->label);
    copy->description = CFStringCreateCopy(kCFAllocatorDefault,theDimension->description);
    copy->metaData = CFDictionaryCreateCopy(kCFAllocatorDefault, theDimension->metaData);
    copy->quantityName = CFStringCreateCopy(kCFAllocatorDefault,theDimension->quantityName);
    copy->scaling = theDimension->scaling;
    copy->periodic = theDimension->periodic;
    copy->originOffset = PSScalarCreateCopy(theDimension->originOffset);
    copy->referenceOffset = PSScalarCreateCopy(theDimension->referenceOffset);
    if(theDimension->period) copy->period = PSScalarCreateCopy(theDimension->period);
    else copy->period = NULL;
    
    CFIndex coordinatesCount = CFArrayGetCount(theDimension->coordinates);
    copy->coordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index = 0; index<coordinatesCount;index++) {
        PSScalarRef coordinateCopy = PSScalarCreateCopy(CFArrayGetValueAtIndex(theDimension->coordinates, index));
        CFArrayAppendValue(theDimension->coordinates, coordinateCopy);
        CFRelease(coordinateCopy);
    }
    return copy;
}

CFIndex PSMonotonicDimensionGetCount(PSMonotonicDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,0);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->coordinates,0);
    return CFArrayGetCount(theDimension->coordinates);
}

CFArrayRef PSMonotonicDimensionGetCoordinates(PSMonotonicDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->coordinates;
}

bool PSMonotonicDimensionSetCoordinates(PSMonotonicDimensionRef theDimension, CFArrayRef coordinates)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(coordinates,false);
    if(theDimension->coordinates == coordinates) return true;
    if(theDimension->coordinates) CFRelease(theDimension->coordinates);
    theDimension->coordinates = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, coordinates);
    return true;
}

CFStringRef PSMonotonicDimensionGetCoordinateAtIndex(PSMonotonicDimensionRef theDimension, CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->coordinates,NULL);
    if(index<0 || index>=CFArrayGetCount(theDimension->coordinates)) return NULL;
    return CFArrayGetValueAtIndex(theDimension->coordinates, index);
}

bool PSMonotonicDimensionSetCoordinateAtIndex(PSMonotonicDimensionRef theDimension, CFIndex index, PSScalarRef coordinate)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(coordinate,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->coordinates,false);
    if(index<0 || index>=CFArrayGetCount(theDimension->coordinates)) return false;
    CFArraySetValueAtIndex(theDimension->coordinates, index, coordinate);
    return true;
}

PSQuantitativeDimensionRef PSMonotonicDimensionGetReciprocal(PSMonotonicDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->reciprocal;
}

#pragma mark PSMonotonicDimension Operatioms

bool PSMonotonicDimensionMultiplyByScalar(PSMonotonicDimensionRef theDimension,
                                          PSScalarRef theScalar,
                                          CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    if(PSScalarDoubleValue(theScalar) == 0.0) return false;
    if(PSQuantityHasDimensionality(theScalar,PSDimensionalityDimensionless())&& PSScalarIsReal(theScalar) && PSScalarDoubleValue(theScalar)==1) return true;
    
    PSUnitRef theUnit = NULL;
    CFIndex count = CFArrayGetCount(theDimension->coordinates);
    for(CFIndex index = 0; index<count;index++) {
        PSScalarRef coordinate = CFArrayGetValueAtIndex(theDimension->coordinates, index);
        PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) coordinate, theScalar, error);
    }
    PSScalarRef coordinate = CFArrayGetValueAtIndex(theDimension->coordinates, 0);
    theUnit = PSQuantityGetUnit(coordinate);

    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->originOffset, theScalar, error);
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->referenceOffset, theScalar, error);
    if(theDimension->period) PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->period, theScalar, error);
    
    if(theDimension->quantityName) CFRelease(theDimension->quantityName);
    CFStringRef quantityName = PSUnitGuessQuantityName(theUnit);
    theDimension->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
    
    PSScalarRef theInverseScalar = PSScalarCreateByRaisingToAPowerWithoutReducingUnit(theScalar, -1, error);
    PSQuantitativeDimensionMultiplyByScalar(theDimension->reciprocal, theInverseScalar, error);
    
    return true;
}

#pragma mark PSMonotonicDimension Coordinates and Indexes Core Mapping

PSUnitRef PSMonotonicDimensionGetUnit(PSMonotonicDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return PSQuantityGetUnit(CFArrayGetValueAtIndex(theDimension->coordinates, 0));
}

PSUnitRef PSMonotonicDimensionGetInverseUnit(PSMonotonicDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return PSUnitByRaisingToAPower(PSQuantityGetUnit(CFArrayGetValueAtIndex(theDimension->coordinates, 0)), -1, NULL, NULL);
}


@end

@implementation PSLinearDimension
- (void) dealloc
{
    if(self->increment) CFRelease(self->increment);
    self->increment = NULL;
    
    if(self->inverseIncrement) CFRelease(self->inverseIncrement);
    self->inverseIncrement = NULL;

    if(self->reciprocal) CFRelease(self->reciprocal);
    self->reciprocal = NULL;
    
    [super dealloc];
}

void PSLinearDimensionMakeNiceUnits(PSLinearDimensionRef theDimension)
{
    if(theDimension->inverseIncrement) {
        PSUnitRef unit = PSQuantityGetUnit(theDimension->inverseIncrement);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inverseIncrement, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->reciprocal->referenceOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->reciprocal->originOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->reciprocal->period, unit);
    }
if(theDimension->increment) {
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->increment, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->referenceOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->originOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->period, unit);
    }
}

PSLinearDimensionRef PSLinearDimensionCreateDefault2(CFIndex count,
                                                     PSScalarRef increment,
                                                     CFStringRef quantityName)
{
    // *** Validate input parameters ***
    IF_NO_OBJECT_EXISTS_RETURN(increment,NULL);
    if(count<2) return NULL;
    if(PSQuantityIsComplexType(increment)) return NULL;
    PSDimensionalityRef theDimensionality = PSQuantityGetUnitDimensionality(increment);
    PSUnitRef theUnit = PSQuantityGetUnit(increment);
    
    if(quantityName) {
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
        if(!PSDimensionalityHasSameReducedDimensionality(dimensionality,theDimensionality)) return NULL;
    }
    if(NULL==quantityName) quantityName = PSUnitGuessQuantityName(theUnit);
    
    // *** Initialize object ***
    PSLinearDimension *theDimension = [PSLinearDimension alloc];
    if(PSQuantitativeDimensionInitialize(theDimension, quantityName)) {
        theDimension->increment = PSScalarCreateCopy(increment);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->increment, theUnit);
        theDimension->count = count;
        theDimension->period = PSScalarCreateByMultiplyingByDimensionlessRealConstant(theDimension->increment, theDimension->count);
        theDimension->periodic = false;
        theDimension->fft = false;
        
        theDimension->inverseIncrement = CreateInverseIncrementFromIncrement(theDimension->increment, theDimension->count);
        PSUnitRef theReciprocalUnit = PSQuantityGetUnit(theDimension->inverseIncrement);
        theDimension->reciprocal = PSQuantitativeDimensionCreateDefault(PSUnitGuessQuantityName(theReciprocalUnit));
        
        PSLinearDimensionMakeNiceUnits(theDimension);
        return theDimension;
    }
    return NULL;
}

PSLinearDimensionRef PSLinearDimensionCreateCopy(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    PSLinearDimension *copy = [PSLinearDimension alloc];
    copy->label = CFStringCreateCopy(kCFAllocatorDefault,theDimension->label);
    copy->description = CFStringCreateCopy(kCFAllocatorDefault,theDimension->description);
    copy->metaData = CFDictionaryCreateCopy(kCFAllocatorDefault, theDimension->metaData);
    copy->quantityName = CFStringCreateCopy(kCFAllocatorDefault,theDimension->quantityName);
    copy->scaling = theDimension->scaling;
    copy->periodic = theDimension->periodic;
    copy->originOffset = PSScalarCreateCopy(theDimension->originOffset);
    copy->referenceOffset = PSScalarCreateCopy(theDimension->referenceOffset);
    if(theDimension->period) copy->period = PSScalarCreateCopy(theDimension->period);
    else copy->period = NULL;
    
    copy->count = theDimension->count;
    copy->increment = PSScalarCreateCopy(theDimension->increment);
    copy->inverseIncrement = PSScalarCreateCopy(theDimension->inverseIncrement);
    copy->reciprocal = PSQuantitativeDimensionCreateCopy(theDimension->reciprocal);
    return copy;
}

bool PSLinearDimensionGetFFT(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->fft;
}

void PSLinearDimensionSetFFT(PSLinearDimensionRef theDimension, bool fft)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    theDimension->fft = fft;
}

void PSLinearDimensionToggleFFT(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    theDimension->fft = !theDimension->fft;
}

CFIndex PSLinearDimensionGetCount(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,kCFNotFound);
    return theDimension->count;
}

bool PSLinearDimensionSetCount(PSLinearDimensionRef theDimension, CFIndex count)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    
    if(theDimension->increment) {
        theDimension->count = count;
        
        theDimension->inverseIncrement = CreateInverseIncrementFromIncrement(theDimension->increment, theDimension->count);
        if(theDimension->reciprocal->quantityName) PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->inverseIncrement, theDimension->reciprocal->quantityName);
        return true;
    }
    return false;
}

PSScalarRef PSLinearDimensionGetIncrement(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return  theDimension->increment;
}

bool PSLinearDimensionSetIncrement(PSLinearDimensionRef theDimension, PSScalarRef increment)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(increment,false);
    if(PSQuantityIsComplexType(increment)) return false;
    if(theDimension->increment == increment) return true;
    PSDimensionalityRef theDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    if(!PSDimensionalityHasSameReducedDimensionality(theDimensionality, PSQuantityGetUnitDimensionality(increment))) return false;
    CFRelease(theDimension->increment);
    theDimension->increment = CFRetain(increment);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->increment, kPSNumberFloat64Type);
    
    PSScalarRef newInverseIncrement = CreateInverseIncrementFromIncrement(theDimension->increment, theDimension->count);
    if(PSScalarCompare(newInverseIncrement, theDimension->inverseIncrement)!=kPSCompareEqualTo) {
        CFRelease(theDimension->inverseIncrement);
        theDimension->inverseIncrement = newInverseIncrement;
        if(theDimension->reciprocal->quantityName) PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->inverseIncrement, theDimension->reciprocal->quantityName);
    }
    else CFRelease(newInverseIncrement);
    return true;
}

bool PSLinearDimensionHasNegativeIncrement(PSLinearDimensionRef theDimension)
{
    if(theDimension->increment) {
        if(PSScalarDoubleValue(theDimension->increment)<0) return true;
    }
    return false;
}

PSScalarRef PSLinearDimensionGetInverseIncrement(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return  theDimension->inverseIncrement;
}

bool PSLinearDimensionSetInverseIncrement(PSLinearDimensionRef theDimension, PSScalarRef inverseIncrement)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(inverseIncrement,false);
    if(PSQuantityIsComplexType(inverseIncrement)) return false;
    if(theDimension->inverseIncrement == inverseIncrement) return true;
    
    if(PSQuantityGetElementType((PSQuantityRef) inverseIncrement)!= kPSNumberFloat64Type) return false;
    
    CFRelease(theDimension->inverseIncrement);
    theDimension->inverseIncrement = CFRetain(inverseIncrement);
    
    PSScalarRef newIncrement = CreateInverseIncrementFromIncrement(theDimension->inverseIncrement, theDimension->count);
    if(PSScalarCompare(newIncrement, theDimension->increment)!=kPSCompareEqualTo) {
        CFRelease(theDimension->increment);
        theDimension->increment = newIncrement;
        if(theDimension->quantityName) PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->increment, theDimension->quantityName);
    }
    else CFRelease(newIncrement);
    return true;
}

#pragma mark PSLinearDimension Operatioms

bool PSLinearDimensionMultiplyByScalar(PSLinearDimensionRef theDimension,
                                       PSScalarRef theScalar,
                                       CFErrorRef *error)
{
    if(PSQuantitativeDimensionMultiplyByScalar(theDimension, theScalar, error)) {
        PSUnitRef theUnit = NULL;
        PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->increment, theScalar, error);
        theUnit = PSQuantityGetUnit(theDimension->increment);
        if(theDimension->quantityName) CFRelease(theDimension->quantityName);
        CFStringRef quantityName = PSUnitGuessQuantityName(theUnit);
        theDimension->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
        
        PSScalarRef theInverseScalar = PSScalarCreateByRaisingToAPowerWithoutReducingUnit(theScalar, -1, error);
        return PSQuantitativeDimensionMultiplyByScalar(theDimension->reciprocal, theInverseScalar, error);
    }
    return false;
}

bool PSLinearDimensionInverse(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->increment,false);
    
    PSScalarRef tempScalar = theDimension->increment;
    theDimension->increment = theDimension->inverseIncrement;
    theDimension->inverseIncrement = tempScalar;
    
    CFStringRef tempString = theDimension->quantityName;
    theDimension->quantityName = theDimension->reciprocal->quantityName;
    theDimension->reciprocal->quantityName = tempString;
    
    tempString = theDimension->label;
    theDimension->label = theDimension->reciprocal->label;
    theDimension->reciprocal->label = tempString;
    
    tempString = theDimension->description;
    theDimension->description = theDimension->reciprocal->description;
    theDimension->reciprocal->description = tempString;
    
    tempScalar = theDimension->originOffset;
    theDimension->originOffset = theDimension->reciprocal->originOffset;
    theDimension->reciprocal->originOffset = tempScalar;
    
    tempScalar = theDimension->referenceOffset;
    theDimension->referenceOffset = theDimension->reciprocal->referenceOffset;
    theDimension->reciprocal->referenceOffset = tempScalar;
    
    tempScalar = theDimension->period;
    theDimension->period = theDimension->reciprocal->period;
    theDimension->reciprocal->period = tempScalar;
    
    bool tempBool = theDimension->periodic;
    theDimension->periodic = theDimension->reciprocal->periodic;
    theDimension->reciprocal->periodic = tempBool;
    
    tempBool = theDimension->scaling;
    theDimension->scaling = theDimension->reciprocal->scaling;
    theDimension->reciprocal->scaling = tempBool;
    
    return true;
}

#pragma mark Coordinates and Indexes Core Mapping

PSUnitRef PSLinearDimensionGetUnit(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return PSQuantityGetUnit((PSQuantityRef) theDimension->increment);
}

PSUnitRef PSLinearDimensionGetInverseUnit(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return PSQuantityGetUnit((PSQuantityRef) theDimension->inverseIncrement);
}

PSUnitRef PSLinearDimensionGetCurrentUnit(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    switch (theDimension->scaling) {
        case kDimensionScalingNone:
            return PSQuantityGetUnit((PSQuantityRef) theDimension->increment);
        case kDimensionScalingNMR: {
            double unit_multiplier = 1;
            return PSUnitByDividingWithoutReducing(PSQuantityGetUnit((PSQuantityRef) theDimension->increment), PSQuantityGetUnit((PSQuantityRef) theDimension->increment), &unit_multiplier);
        }
    }
    
    return NULL;
}

PSDimensionalityRef PSLinearDimensionGetCurrentUnitDimensionality(PSLinearDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    switch (theDimension->scaling) {
        case kDimensionScalingNone:
            return PSQuantityGetUnitDimensionality((PSQuantityRef) theDimension->increment);
        case kDimensionScalingNMR: {
            return PSDimensionalityByDividingWithoutReducing(PSQuantityGetUnitDimensionality((PSQuantityRef) theDimension->increment), PSQuantityGetUnitDimensionality((PSQuantityRef) theDimension->increment));
        }
    }
}

@end

@implementation PSDimension

- (void) dealloc
{
    if(self->increment) CFRelease(self->increment);
    self->increment = NULL;

    if(self->originOffset) CFRelease(self->originOffset);
    self->originOffset = NULL;
    
    if(self->referenceOffset) CFRelease(self->referenceOffset);
    self->referenceOffset = NULL;
    
    if(self->period) CFRelease(self->period);
    self->period = NULL;
    
    if(self->quantityName) CFRelease(self->quantityName);
    self->quantityName = NULL;

    if(self->label) CFRelease(self->label);
    self->label = NULL;

    if(self->description) CFRelease(self->description);
    self->description = NULL;

    if(self->inverseIncrement) CFRelease(self->inverseIncrement);
    self->inverseIncrement = NULL;

    if(self->inverseOriginOffset) CFRelease(self->inverseOriginOffset);
    self->inverseOriginOffset = NULL;

    if(self->inverseReferenceOffset) CFRelease(self->inverseReferenceOffset);
    self->inverseReferenceOffset = NULL;

    if(self->inversePeriod) CFRelease(self->inversePeriod);
    self->inversePeriod = NULL;

    if(self->inverseQuantityName) CFRelease(self->inverseQuantityName);
    self->inverseQuantityName = NULL;

    if(self->inverseLabel) CFRelease(self->inverseLabel);
    self->inverseLabel = NULL;
    
    if(self->inverseDescription) CFRelease(self->inverseDescription);
    self->inverseDescription = NULL;
    
    if(self->nonUniformCoordinates) CFRelease(self->nonUniformCoordinates);
    self->nonUniformCoordinates = NULL;

    
    if(self->metaData) CFRelease(self->metaData);
    self->metaData = NULL;
    
    [super dealloc];
}


bool IsValidDimensionQuantity(PSScalarRef theScalar, PSDimensionalityRef theDimensionality, CFStringRef name, CFErrorRef *error)
{
    if(PSQuantityIsComplexType(theScalar)) return false;
    PSDimensionalityRef dim2 = PSUnitGetDimensionality(PSQuantityGetUnit(theScalar));
    if(!PSDimensionalityHasSameReducedDimensionality(theDimensionality,dim2)) {
        if(error) {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("Encountered an %@ in a dimension with inconsistent dimensionalities"),name);
            *error = PSCFErrorCreate(CFSTR("Invalid value in Dimension"), reason, NULL);
            CFRelease(reason);
        }
        return false;
    }
    return true;
}

PSScalarRef CreateInverseIncrementFromIncrement(PSScalarRef increment, CFIndex numberOfSamples)
{
    IF_NO_OBJECT_EXISTS_RETURN(increment,NULL);
    if(numberOfSamples<1) return NULL;
    
    PSScalarRef temp = PSScalarCreateByRaisingToAPower(increment, -1, NULL);
    if(NULL==temp) return NULL;
    long double scaling = (long double) 1./((long double) numberOfSamples);
    PSScalarRef inverseIncrement = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, (double) scaling);
    CFRelease(temp);
    return inverseIncrement;
}

#pragma mark Creators

/* Designated Creator */
/**************************/

PSDimensionRef PSLinearDimensionCreateDefault(CFIndex npts, PSScalarRef increment, CFStringRef quantityName, CFStringRef inverseQuantityName)
{
    // *** Validate input parameters ***
    IF_NO_OBJECT_EXISTS_RETURN(increment,NULL);
    if(npts<2) return NULL;
    if(PSQuantityIsComplexType(increment)) return NULL;
    PSDimensionalityRef theDimensionality = PSQuantityGetUnitDimensionality(increment);
    PSDimensionalityRef theInverseDimensionality = PSDimensionalityByRaisingToAPower(theDimensionality, -1, NULL);
    PSUnitRef theUnit = PSQuantityGetUnit(increment);

    if(quantityName) {
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
        if(!PSDimensionalityHasSameReducedDimensionality(dimensionality,theDimensionality)) return NULL;
    }
    if(NULL==quantityName) quantityName = PSUnitGuessQuantityName(theUnit);
    
    if(inverseQuantityName) {
        PSDimensionalityRef inverseDimensionality = PSDimensionalityForQuantityName(inverseQuantityName);
        if(!PSDimensionalityHasSameReducedDimensionality(inverseDimensionality,theInverseDimensionality)) return NULL;
    }
    PSScalarRef inverseIncrement = CreateInverseIncrementFromIncrement(increment, npts);
    CFArrayRef inverseUnits = PSUnitCreateArrayOfRootUnitsForQuantityName(inverseQuantityName);
    if(inverseUnits && CFArrayGetCount(inverseUnits)!=0) {
        PSUnitRef newInverseUnit = CFArrayGetValueAtIndex(inverseUnits, 0);
        PSScalarConvertToUnit((PSMutableScalarRef) inverseIncrement, newInverseUnit, NULL);
        CFRelease(inverseUnits);
    }
    PSUnitRef inverseUnit = PSQuantityGetUnit(inverseIncrement);

    // *** Initialize object ***
    PSDimension *theDimension = [PSDimension alloc];
    theDimension->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
    theDimension->increment = PSScalarCreateCopy(increment);
    PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->increment, theUnit);

    theDimension->npts = npts;
    theDimension->originOffset = PSScalarCreateWithDouble(0.0, theUnit);
    theDimension->referenceOffset = PSScalarCreateWithDouble(0.0, theUnit);
    theDimension->period = PSScalarCreateByMultiplyingByDimensionlessRealConstant(theDimension->increment, theDimension->npts);
    theDimension->label = CFSTR("");
    theDimension->description = CFSTR("");

    theDimension->fft = false;
    theDimension->periodic = false;
    theDimension->madeDimensionless = false;
    
    theDimension->inversePeriodic = false;
    theDimension->inverseMadeDimensionless = false;
    theDimension->inverseIncrement = inverseIncrement;
    theDimension->inverseOriginOffset = PSScalarCreateWithDouble(0.0, inverseUnit);
    theDimension->inverseReferenceOffset = PSScalarCreateWithDouble(0.0, inverseUnit);
    theDimension->inversePeriod =PSScalarCreateByRaisingToAPower(theDimension->period, -1, NULL);
    PSScalarConvertToUnit((PSMutableScalarRef) theDimension->inversePeriod, inverseUnit, NULL);
    theDimension->metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    theDimension->inverseQuantityName = inverseQuantityName;
    if(NULL==theDimension->inverseQuantityName)
        theDimension->inverseQuantityName = PSUnitGuessQuantityName(inverseUnit);
    theDimension->label = CFSTR("");
    theDimension->description = CFSTR("");
    theDimension->inverseLabel = CFSTR("");
    theDimension->inverseDescription = CFSTR("");
    
    return theDimension;
}

PSDimensionRef PSMonotonicDimensionCreateDefault(CFArrayRef coordinates, CFStringRef quantityName)
{
    // *** Validate input parameters ***

    IF_NO_OBJECT_EXISTS_RETURN(coordinates,NULL);
    CFIndex coordinatesCount = CFArrayGetCount(coordinates);
    if(coordinatesCount<2) return NULL;

    PSScalarRef firstCoordinate = CFArrayGetValueAtIndex(coordinates, 0);
    if(PSQuantityIsComplexType(firstCoordinate)) return NULL;
    PSDimensionalityRef theDimensionality = PSQuantityGetUnitDimensionality(firstCoordinate);
    PSUnitRef theUnit = PSQuantityGetUnit(firstCoordinate);
    for(CFIndex index = 1; index<coordinatesCount;index++) {
        PSScalarRef coordinate = CFArrayGetValueAtIndex(coordinates, index);
        if(!PSQuantityHasSameReducedDimensionality(firstCoordinate, coordinate)) return NULL;
        if(PSQuantityIsComplexType(coordinate)) return NULL;
    }

    if(quantityName) {
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
        if(!PSDimensionalityHasSameReducedDimensionality(dimensionality,theDimensionality)) return NULL;
    }
    if(NULL==quantityName) quantityName = PSUnitGuessQuantityName(theUnit);

    // *** Initialize object ***
    PSDimension *theDimension = [PSDimension alloc];
    theDimension->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
    theDimension->nonUniformCoordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index = 0; index<coordinatesCount;index++) {
        PSScalarRef coordinate = CFArrayGetValueAtIndex(coordinates, index);
        PSScalarRef coordinateCopy = NULL;
        if(PSDimensionalityEqual(theDimensionality, PSQuantityGetUnitDimensionality(coordinate))) {
            coordinateCopy = PSScalarCreateCopy(coordinate);
        }
        else coordinateCopy = PSScalarCreateByReducingUnit(coordinate);
        CFArrayAppendValue(theDimension->nonUniformCoordinates, coordinateCopy);
        CFRelease(coordinateCopy);
    }

    theDimension->increment = NULL;
    theDimension->npts = coordinatesCount;
    theDimension->originOffset = PSScalarCreateWithDouble(0.0, theUnit);
    theDimension->referenceOffset = PSScalarCreateWithDouble(0.0, theUnit);
    PSScalarRef lastCoordinate =  CFArrayGetValueAtIndex(coordinates, coordinatesCount-1);
    theDimension->period = PSScalarCreateBySubtracting(lastCoordinate, firstCoordinate, NULL);

    theDimension->label = CFSTR("");
    theDimension->description = CFSTR("");
    
    theDimension->fft = false;
    theDimension->periodic = false;
    theDimension->madeDimensionless = false;
    
    theDimension->inversePeriodic = false;
    theDimension->inverseMadeDimensionless = false;
    theDimension->inverseIncrement = NULL;
    
    double multiplier = 1;
    PSUnitRef theReciprocalUnit = PSUnitByRaisingToAPower(theUnit, -1, &multiplier, NULL);

    theDimension->inverseOriginOffset = PSScalarCreateWithDouble(0.0, theReciprocalUnit);
    theDimension->inverseReferenceOffset = PSScalarCreateWithDouble(0.0, theReciprocalUnit);
    theDimension->inversePeriod =PSScalarCreateByRaisingToAPower(theDimension->period, -1, NULL);
    PSScalarConvertToUnit((PSMutableScalarRef) theDimension->inversePeriod, theReciprocalUnit, NULL);
    theDimension->metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    theDimension->inverseQuantityName = PSUnitGuessQuantityName(theReciprocalUnit);
    theDimension->label = CFSTR("");
    theDimension->description = CFSTR("");
    theDimension->inverseLabel = CFSTR("");
    theDimension->inverseDescription = CFSTR("");

    return theDimension;
}

PSDimensionRef PSDImensionCreateFull(CFIndex npts,
                                     bool fft,
                                     
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
                                     CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    // *** Validate input parameters ***
    if(npts<2) {
        if(error) {
            CFStringRef desc = CFSTR("Error creating dimension with less than two samples.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return NULL;
    }
    
    // Only increment or nonUniformCoordinates can be NULL.
    if(NULL==increment && NULL==nonUniformCoordinates) return NULL;
    if(NULL!=increment && NULL!=nonUniformCoordinates) return NULL;
    
    PSDimensionalityRef theDimensionality = NULL;
    PSUnitRef theUnit = NULL;
    if(increment) {
        if(PSQuantityIsComplexType(increment)) return NULL;
        theDimensionality = PSQuantityGetUnitDimensionality(increment);
        theUnit = PSQuantityGetUnit(increment);
    }
    else {
        fft = false;
        CFIndex numberOfCoordinates = CFArrayGetCount(nonUniformCoordinates);
        if(npts != numberOfCoordinates) return NULL;
        PSScalarRef coordinate0 = CFArrayGetValueAtIndex(nonUniformCoordinates, 0);
        if(PSQuantityIsComplexType(coordinate0)) return NULL;
        theDimensionality = PSQuantityGetUnitDimensionality(coordinate0);
        theUnit = PSQuantityGetUnit(coordinate0);
        for(CFIndex index = 1; index<npts;index++) {
            PSScalarRef coordinate = CFArrayGetValueAtIndex(nonUniformCoordinates, index);
            if(!PSQuantityHasSameReducedDimensionality(coordinate0, coordinate)) return NULL;
            if(PSQuantityIsComplexType(coordinate)) return NULL;
        }
    }

    if(quantityName) {
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
        if(!PSDimensionalityHasSameReducedDimensionality(dimensionality,theDimensionality)) {
            NSLog(@"Encountered coordinates and quantity with inconsistent dimensionalities.");
            CFRelease(quantityName);
            quantityName = NULL;
        }
    }
    if(NULL==quantityName) quantityName = PSUnitGuessQuantityName(theUnit);

    if(originOffset && !IsValidDimensionQuantity(originOffset, theDimensionality, CFSTR("orign offset"), error)) return NULL;
    if(referenceOffset && !IsValidDimensionQuantity(referenceOffset, theDimensionality, CFSTR("coordinate offset"), error)) return NULL;
    if(period && !IsValidDimensionQuantity(period, theDimensionality, CFSTR("period"), error)) return NULL;

    // Are inverse quanitities consistent?
    if(inverseIncrement&&inverseReferenceOffset&&!PSQuantityHasSameReducedDimensionality(inverseIncrement, inverseReferenceOffset)) return NULL;
    if(inverseIncrement&&inverseOriginOffset&&!PSQuantityHasSameReducedDimensionality(inverseIncrement, inverseOriginOffset)) return NULL;
    if(inverseIncrement&&inversePeriod&&!PSQuantityHasSameReducedDimensionality(inverseIncrement, inversePeriod)) return NULL;
    
    if(inverseOriginOffset&&inverseReferenceOffset&&!PSQuantityHasSameReducedDimensionality(inverseOriginOffset, inverseReferenceOffset)) return NULL;
    if(inverseOriginOffset&&inversePeriod&&!PSQuantityHasSameReducedDimensionality(inverseOriginOffset, inversePeriod)) return NULL;
    
    if(inversePeriod&&inverseReferenceOffset&&!PSQuantityHasSameReducedDimensionality(inversePeriod, inverseReferenceOffset)) return NULL;

    // Inverse quantities, if they exist, are consistent.  If any exist, get the unit.
    PSUnitRef theReciprocalUnit = NULL;
    if(inverseIncrement) theReciprocalUnit = PSQuantityGetUnit(inverseIncrement);
    if(inverseOriginOffset) theReciprocalUnit = PSQuantityGetUnit(inverseOriginOffset);
    if(inverseReferenceOffset) theReciprocalUnit = PSQuantityGetUnit(inverseReferenceOffset);
    if(inversePeriod) theReciprocalUnit = PSQuantityGetUnit(inversePeriod);
    
    // If reciprocal unit exists, see if it's consistent with dimension unit.
    if(theReciprocalUnit) {
        PSDimensionalityRef unitDimensionality = PSUnitGetDimensionality(theReciprocalUnit);
        PSDimensionalityRef reciprocalDimensionality = reciprocalDimensionality = PSDimensionalityByRaisingToAPowerWithoutReducing(theDimensionality, -1, error);
        if(!PSDimensionalityHasSameReducedDimensionality(reciprocalDimensionality,unitDimensionality)) return NULL;
    }
    else {
        // If reciprocal unit doesn't exist, then get it from dimension unit.
        double multiplier = 1;
        theReciprocalUnit = PSUnitByRaisingToAPower(theUnit, -1, &multiplier, error);
    }

    // Not a good solution
    if(NULL==inverseQuantityName) {
        PSUnitRef inverseSeconds = PSUnitForSymbol(CFSTR("(1/s)"));
        PSUnitRef hertz = PSUnitForSymbol(CFSTR("Hz"));
        if(theReciprocalUnit==inverseSeconds) theReciprocalUnit = hertz;
    }

    PSDimensionalityRef theReciprocalDimensionality = PSUnitGetDimensionality(theReciprocalUnit);
    if(inverseQuantityName) {
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(inverseQuantityName);
        if(!PSDimensionalityHasSameReducedDimensionality(dimensionality,theReciprocalDimensionality)) {
            NSLog(@"Encountered coordinates and quantity with inconsistent dimensionalities.");
            quantityName = NULL;
        }
    }
    if(NULL==inverseQuantityName) inverseQuantityName = PSUnitGuessQuantityName(theReciprocalUnit);
    
    
    // *** Initialize object ***
    
    PSDimension *newDimension = [PSDimension alloc];
    
    // *** Setup attributes ***
    newDimension->npts = npts;
    if(increment) {
        PSScalarRef temp = PSScalarCreateCopy(increment);
//        if(PSScalarDoubleValue(temp)<0) {
//            PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) temp, -1);
//            reverse = 1 - reverse;
//        }
        newDimension->increment = temp;
    }
    else {
        newDimension->nonUniformCoordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<npts;index++) {
            PSScalarRef coordinate = CFArrayGetValueAtIndex(nonUniformCoordinates, index);
            PSScalarRef coordinateCopy = NULL;
            if(PSDimensionalityEqual(theDimensionality, PSQuantityGetUnitDimensionality(coordinate))) {
                coordinateCopy = PSScalarCreateCopy(coordinate);
            }
            else coordinateCopy = PSScalarCreateByReducingUnit(coordinate);
            CFArrayAppendValue(newDimension->nonUniformCoordinates, coordinateCopy);
            CFRelease(coordinateCopy);
        }
    }
    
    if(originOffset) newDimension->originOffset = PSScalarCreateCopy(originOffset);
    else newDimension->originOffset = PSScalarCreateWithDouble(0.0, theUnit);

    if(referenceOffset) newDimension->referenceOffset = PSScalarCreateByConvertingToUnit(referenceOffset, theUnit, error);
    else newDimension->referenceOffset = PSScalarCreateWithDouble(0.0, theUnit);
    
    if(period) {
        newDimension->period = PSScalarCreateByConvertingToUnit(period, theUnit, error);
    }
    else {
        if(newDimension->nonUniformCoordinates) {
            PSScalarRef firstCoordinate =  CFArrayGetValueAtIndex(newDimension->nonUniformCoordinates, 0);
            PSScalarRef lastCoordinate =  CFArrayGetValueAtIndex(newDimension->nonUniformCoordinates, newDimension->npts-1);
            newDimension->period = PSScalarCreateBySubtracting(lastCoordinate, firstCoordinate, error);
        }
        else newDimension->period = PSScalarCreateByMultiplyingByDimensionlessRealConstant(newDimension->increment, newDimension->npts);
    }
    
    newDimension->inverseIncrement = NULL;
    if(inverseIncrement) newDimension->inverseIncrement = PSScalarCreateCopy(inverseIncrement);
    if(NULL==newDimension->inverseIncrement && newDimension->nonUniformCoordinates==NULL) {
        newDimension->inverseIncrement = CreateInverseIncrementFromIncrement(newDimension->increment, newDimension->npts);
        PSScalarConvertToUnit((PSMutableScalarRef) newDimension->inverseIncrement, theReciprocalUnit, error);
    }
    
    if(inverseOriginOffset) newDimension->inverseOriginOffset = PSScalarCreateCopy(inverseOriginOffset);
    else newDimension->inverseOriginOffset = PSScalarCreateWithDouble(0.0, theReciprocalUnit);
    
    if(inverseReferenceOffset) newDimension->inverseReferenceOffset = PSScalarCreateCopy(inverseReferenceOffset);
    else newDimension->inverseReferenceOffset = PSScalarCreateWithDouble(0.0, theReciprocalUnit);
    
    if(inversePeriod) {
        newDimension->inversePeriod = PSScalarCreateCopy(inversePeriod);
    }
    else {
        newDimension->inversePeriod =PSScalarCreateByRaisingToAPower(newDimension->period, -1, error);
        PSScalarConvertToUnit((PSMutableScalarRef) newDimension->inversePeriod, theReciprocalUnit, error);
    }
    
    if(quantityName) newDimension->quantityName = CFRetain(quantityName);
    if(inverseQuantityName) newDimension->inverseQuantityName = CFRetain(inverseQuantityName);
    if(label) newDimension->label = CFRetain(label);
    if(description) newDimension->description = CFRetain(description);
    if(inverseLabel) newDimension->inverseLabel = CFRetain(inverseLabel);
    if(inverseDescription) newDimension->inverseDescription = CFRetain(inverseDescription);

    newDimension->fft = fft;

    newDimension->periodic = periodic;
    newDimension->madeDimensionless = madeDimensionless;

    newDimension->inversePeriodic = inversePeriodic;
    newDimension->inverseMadeDimensionless = inverseMadeDimensionless;

    if(metaData) newDimension->metaData = CFDictionaryCreateCopy(kCFAllocatorDefault, metaData);
    else newDimension->metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    return (PSDimensionRef) newDimension;
}


PSDimensionRef PSDimensionCreateCopy(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    
    return PSDImensionCreateFull(theDimension->npts,
                                 theDimension->fft,
                                 
                                 theDimension->quantityName,
                                 theDimension->label,
                                 theDimension->description,
                                 theDimension->increment,
                                 theDimension->originOffset,
                                 theDimension->referenceOffset,
                                 theDimension->period,
                                 theDimension->periodic,
                                 theDimension->madeDimensionless,
                                 
                                 theDimension->inverseQuantityName,
                                 theDimension->inverseLabel,
                                 theDimension->inverseDescription,
                                 theDimension->inverseIncrement,
                                 theDimension->inverseOriginOffset,
                                 theDimension->inverseReferenceOffset,
                                 theDimension->inversePeriod,
                                 theDimension->inversePeriodic,
                                 theDimension->inverseMadeDimensionless,
                                 
                                 theDimension->nonUniformCoordinates,
                                 theDimension->metaData,
                                 NULL);
}

PSDimensionRef PSMonotonicDimensionCreateFromLinear(PSDimensionRef linearDimension)
{
    PSDimensionRef theDimension = PSDimensionCreateCopy(linearDimension);
    
    theDimension->nonUniformCoordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index = 0; index<linearDimension->npts;index++) {
        PSScalarRef coordinate =  PSDimensionCreateRelativeCoordinateFromIndex(linearDimension, index);
        CFArrayAppendValue(theDimension->nonUniformCoordinates, coordinate);
        CFRelease(coordinate);
    }
    CFRelease(theDimension->increment);
    theDimension->increment = NULL;
    CFRelease(theDimension->inverseIncrement);
    theDimension->inverseIncrement = NULL;
    return theDimension;
}


#pragma mark Accessors

CFIndex PSDimensionGetNpts(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,kCFNotFound);
    return theDimension->npts;    
}

// *******************  Needs Updating for Non-Uniform Coordinates
bool PSDimensionSetNpts(PSDimensionRef theDimension, CFIndex npts)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    
    if(theDimension->increment) {
        theDimension->npts = npts;

        theDimension->inverseIncrement = CreateInverseIncrementFromIncrement(theDimension->increment, theDimension->npts);
        if(theDimension->inverseQuantityName) PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->inverseIncrement, theDimension->inverseQuantityName);
        return true;
    }

    return false;
}

bool PSDimensionHasNegativeIncrement(PSDimensionRef theDimension)
{
    if(theDimension->increment) {
        if(PSScalarDoubleValue(theDimension->increment)<0) return true;
    }
    return false;
}
PSScalarRef PSDimensionGetIncrement(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return  theDimension->increment;
}

PSScalarRef PSDimensionCreateIncrementInDisplayedCoordinate(PSDimensionRef theDimension)
{
    PSScalarRef temp1 = PSDimensionCreateDisplayedCoordinateFromIndex(theDimension, 0);
    PSScalarRef temp2 = PSDimensionCreateDisplayedCoordinateFromIndex(theDimension, 1);
    PSScalarRef result = PSScalarCreateBySubtracting(temp2, temp1, NULL);
    CFRelease(temp1);
    CFRelease(temp2);
    PSScalarTakeAbsoluteValue((PSMutableScalarRef) result, NULL);
    return result;
}

void PSDimensionSetIncrement(PSDimensionRef theDimension, PSScalarRef increment)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->increment,);
    IF_NO_OBJECT_EXISTS_RETURN(increment,);
    if(theDimension->increment == increment || PSQuantityIsComplexType(increment)) return;
    PSDimensionalityRef theDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    if(!PSDimensionalityHasSameReducedDimensionality(theDimensionality, PSQuantityGetUnitDimensionality(increment))) return;
    CFRelease(theDimension->increment);
    theDimension->increment = CFRetain(increment);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->increment, kPSNumberFloat64Type);

    PSScalarRef newInverseIncrement = CreateInverseIncrementFromIncrement(theDimension->increment, theDimension->npts);
    if(PSScalarCompare(newInverseIncrement, theDimension->inverseIncrement)!=kPSCompareEqualTo) {
        CFRelease(theDimension->inverseIncrement);
        theDimension->inverseIncrement = newInverseIncrement;
        if(theDimension->inverseQuantityName) PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->inverseIncrement, theDimension->inverseQuantityName);
    }
    else CFRelease(newInverseIncrement);
    return;
}

PSScalarRef PSDimensionGetInverseIncrement(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return  theDimension->inverseIncrement;
}

void PSDimensionSetInverseIncrement(PSDimensionRef theDimension, PSScalarRef inverseIncrement)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->inverseIncrement,);
    IF_NO_OBJECT_EXISTS_RETURN(inverseIncrement,);
    if(theDimension->inverseIncrement == inverseIncrement) return;
    
    if(PSQuantityGetElementType((PSQuantityRef) inverseIncrement)!= kPSNumberFloat64Type) return;

    CFRelease(theDimension->inverseIncrement);
    theDimension->inverseIncrement = CFRetain(inverseIncrement);
    
    PSScalarRef newIncrement = CreateInverseIncrementFromIncrement(theDimension->inverseIncrement, theDimension->npts);
    if(PSScalarCompare(newIncrement, theDimension->increment)!=kPSCompareEqualTo) {
        CFRelease(theDimension->increment);
        theDimension->increment = newIncrement;
        if(theDimension->quantityName) PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->increment, theDimension->quantityName);
    }
    else CFRelease(newIncrement);
    return;
}

PSScalarRef PSDimensionGetPeriod(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->period;
}

void PSDimensionSetPeriod(PSDimensionRef theDimension, PSScalarRef period)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(period,);
    if(theDimension->period == period || PSQuantityIsComplexType(period)) return;
    PSScalarRef temp = PSScalarCreateByConvertingToUnit(period, PSDimensionGetRelativeUnit(theDimension), NULL);
    if(temp == NULL) return;
    CFRelease(theDimension->period);
    theDimension->period = CFRetain(temp);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->period, kPSNumberFloat64Type);
}

PSScalarRef PSDimensionGetInversePeriod(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->inversePeriod;
}

void PSDimensionSetInversePeriod(PSDimensionRef theDimension, PSScalarRef period)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(period,);
    if(theDimension->inversePeriod == period || PSQuantityIsComplexType(period)) return;
    PSScalarRef temp = PSScalarCreateByConvertingToUnit(period, PSDimensionGetRelativeInverseUnit(theDimension), NULL);
    if(temp == NULL) return;
    CFRelease(theDimension->inversePeriod);
    theDimension->inversePeriod = CFRetain(temp);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->inversePeriod, kPSNumberFloat64Type);
}


PSScalarRef PSDimensionGetOriginOffset(PSDimensionRef theDimension)
{
  	IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->originOffset;
}

void PSDimensionSetOriginOffset(PSDimensionRef theDimension, PSScalarRef originOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(originOffset,);
    if(theDimension->originOffset == originOffset || PSQuantityIsComplexType(originOffset)) return;
    PSScalarRef temp = PSScalarCreateByConvertingToUnit(originOffset, PSDimensionGetRelativeUnit(theDimension), NULL);
    if(temp == NULL) return;
    CFRelease(theDimension->originOffset);
    theDimension->originOffset = CFRetain(temp);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->originOffset, kPSNumberFloat64Type);
}

PSScalarRef PSDimensionGetReferenceOffset(PSDimensionRef theDimension)
{
  	IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->referenceOffset;
}

void PSDimensionZeroReferenceOffset(PSDimensionRef theDimension)
{
  	IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    PSScalarZeroPart((PSMutableScalarRef) theDimension->referenceOffset, kPSMagnitudePart);
}

void PSDimensionSetReferenceOffset(PSDimensionRef theDimension, PSScalarRef referenceOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(referenceOffset,);
    if(theDimension->referenceOffset == referenceOffset || PSQuantityIsComplexType(referenceOffset)) return;
    PSScalarRef temp = PSScalarCreateByConvertingToUnit(referenceOffset, PSDimensionGetRelativeUnit(theDimension), NULL);
    if(temp == NULL) return;
    CFRelease(theDimension->referenceOffset);
    theDimension->referenceOffset = CFRetain(temp);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->referenceOffset, kPSNumberFloat64Type);
}

PSScalarRef PSDimensionGetInverseOriginOffset(PSDimensionRef theDimension)
{
  	IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->inverseOriginOffset;
}

void PSDimensionSetInverseOriginOffset(PSDimensionRef theDimension, PSScalarRef inverseOriginOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(inverseOriginOffset,);
    if(theDimension->inverseOriginOffset == inverseOriginOffset || PSQuantityIsComplexType(inverseOriginOffset)) return;
    PSScalarRef temp = PSScalarCreateByConvertingToUnit(inverseOriginOffset, PSDimensionGetRelativeInverseUnit(theDimension), NULL);
    if(temp == NULL) return;
    CFRelease(theDimension->inverseOriginOffset);
    theDimension->inverseOriginOffset = CFRetain(temp);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->inverseOriginOffset, kPSNumberFloat64Type);
}

PSScalarRef PSDimensionGetInverseReferenceOffset(PSDimensionRef theDimension)
{
  	IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->inverseReferenceOffset;
}

void PSDimensionSetInverseReferenceOffset(PSDimensionRef theDimension, PSScalarRef inverseReferenceOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(inverseReferenceOffset,);
    if(theDimension->inverseReferenceOffset == inverseReferenceOffset || PSQuantityIsComplexType(inverseReferenceOffset)) return;
    PSScalarRef temp = PSScalarCreateByConvertingToUnit(inverseReferenceOffset, PSDimensionGetRelativeInverseUnit(theDimension), NULL);
    if(temp == NULL) return;
    CFRelease(theDimension->inverseReferenceOffset);
    theDimension->inverseReferenceOffset = CFRetain(temp);
    PSScalarSetElementType((PSMutableScalarRef) theDimension->inverseReferenceOffset, kPSNumberFloat64Type);
    if(theDimension->inverseIncrement)
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inverseReferenceOffset, PSQuantityGetUnit(theDimension->inverseIncrement));
}

bool PSDimensionHasNonUniformGrid(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    if(theDimension->increment == NULL) return true;
return false;
}

bool PSDimensionGetFFT(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->fft;
}

void PSDimensionSetFFT(PSDimensionRef theDimension, bool fft)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    theDimension->fft = fft;
}

void PSDimensionToggleFFT(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    theDimension->fft = !theDimension->fft;
}


bool PSDimensionGetPeriodic(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->periodic;
}

void PSDimensionSetPeriodic(PSDimensionRef theDimension, bool periodic)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(NULL==theDimension->period) theDimension->period = PSScalarCreateByMultiplyingByDimensionlessRealConstant(theDimension->increment, theDimension->npts);
    theDimension->periodic = periodic;
}

// *******************  Needs Updating for Non-Uniform Coordinates
bool PSDimensionCanBeMadeDimensionless(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    if(PSScalarFloatValue(theDimension->originOffset) == 0.0) return false;
    CFErrorRef error = NULL;
    PSScalarRef totalOffset = PSScalarCreateByAdding(theDimension->originOffset, theDimension->referenceOffset, &error);
    float offset = PSScalarFloatValue(totalOffset);
    CFRelease(totalOffset);
    if(offset == 0.0) return false;
    
    if(theDimension->increment) {
        if(PSUnitIsDimensionless(PSQuantityGetUnit(theDimension->increment))) return false;
    }
    else {
        if(PSUnitIsDimensionless(PSQuantityGetUnit(CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0)))) return false;
    }

    return true;
}

// *******************  Needs Updating for Non-Uniform Coordinates
bool PSDimensionInverseCanBeMadeDimensionless(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    if(PSScalarFloatValue(theDimension->inverseOriginOffset) == 0.0) return false;
    
    CFErrorRef error = NULL;
    PSScalarRef totalOffset = PSScalarCreateByAdding(theDimension->inverseOriginOffset, theDimension->inverseReferenceOffset, &error);
    float offset = PSScalarFloatValue(totalOffset);
    CFRelease(totalOffset);
    if(offset == 0.0) return false;
    if(theDimension->inverseIncrement) {
        if(PSUnitIsDimensionless(PSQuantityGetUnit(theDimension->inverseIncrement))) return false;
    }
    else {
        if(PSUnitIsDimensionless(PSQuantityGetUnit(CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0)))) return false;
    }
    return true;
}

bool PSDimensionGetMadeDimensionless(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->madeDimensionless;
}

bool PSDimensionSetMadeDimensionless(PSDimensionRef theDimension, bool madeDimensionless)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    if(madeDimensionless == theDimension->madeDimensionless) return true;
    if(madeDimensionless) {
        if(!PSDimensionCanBeMadeDimensionless(theDimension)) return false;
    }
    theDimension->madeDimensionless = madeDimensionless;
    return true;
}

bool PSDimensionGetInverseMadeDimensionless(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->inverseMadeDimensionless;
}

bool PSDimensionSetInverseMadeDimensionless(PSDimensionRef theDimension, bool madeDimensionless)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    if(madeDimensionless == theDimension->inverseMadeDimensionless) return true;
    if(madeDimensionless) {
        if(!PSDimensionInverseCanBeMadeDimensionless(theDimension)) return false;
    }
    theDimension->inverseMadeDimensionless = madeDimensionless;
    return true;
}

bool PSDimensionGetInversePeriodic(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    return theDimension->inversePeriodic;
}

void PSDimensionSetInversePeriodic(PSDimensionRef theDimension, bool periodic)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(NULL==theDimension->inversePeriod) theDimension->inversePeriod = PSScalarCreateByMultiplyingByDimensionlessRealConstant(theDimension->inverseIncrement, theDimension->npts);
    theDimension->inversePeriodic = periodic;
}

CFStringRef PSDimensionGetQuantityName(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->quantityName;
}

CFStringRef PSDimensionCopyDisplayedQuantityName(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    if(theDimension->madeDimensionless) {
        CFMutableStringRef quantityName = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, theDimension->quantityName);
        CFStringAppend(quantityName, CFSTR(" ratio"));
        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
        if(dimensionality) return quantityName;
        if(quantityName) CFRelease(quantityName);
        return CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityDimensionless);
    }
    return CFStringCreateCopy(kCFAllocatorDefault, theDimension->quantityName);
}

void PSDimensionSetQuantityName(PSDimensionRef theDimension, CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(quantityName,);
    if(quantityName == theDimension->quantityName) return;
    
    PSDimensionalityRef theDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    CFArrayRef quantityNames = PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality(theDimensionality);
    if(CFArrayContainsValue(quantityNames, CFRangeMake(0,CFArrayGetCount(quantityNames)), quantityName)) {
        if(theDimension->quantityName) CFRelease(theDimension->quantityName);
        theDimension->quantityName = CFRetain(quantityName);
    }
    CFRelease(quantityNames);
    
    if(theDimension->increment) {
        CFArrayRef quantityUnits = PSUnitCreateArrayForQuantity(theDimension->quantityName);
        if(quantityUnits) {
            PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
            if(!CFArrayContainsValue(quantityUnits, CFRangeMake(0,CFArrayGetCount(quantityUnits)), unit)) {
                PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->increment, theDimension->quantityName);
                PSUnitRef betterUnit = PSQuantityGetUnit(theDimension->increment);
                PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->referenceOffset, betterUnit);
                PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->originOffset, betterUnit);
                PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->period, betterUnit);
            }
            CFRelease(quantityUnits);
        }
    }
}

CFStringRef PSDimensionGetLabel(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->label;
}

void PSDimensionSetLabel(PSDimensionRef theDimension, CFStringRef label)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(theDimension->label) CFRelease(theDimension->label);
    if(label) theDimension->label = CFRetain(label);
    else theDimension->label = NULL;
}

CFStringRef PSDimensionGetDescription(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->description;
}

void PSDimensionSetDescription(PSDimensionRef theDimension, CFStringRef description)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(theDimension->description) CFRelease(theDimension->description);
    if(description) theDimension->description = CFRetain(description);
    else theDimension->description = NULL;
}

CFStringRef PSDimensionGetInverseQuantityName(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->inverseQuantityName;    
}

void PSDimensionMakeNiceUnits(PSDimensionRef theDimension)
{
    if(theDimension->inverseIncrement) {
        PSUnitRef unit = PSQuantityGetUnit(theDimension->inverseIncrement);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inverseIncrement, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inverseReferenceOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inverseOriginOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inversePeriod, unit);
    }
    if(theDimension->increment) {
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->increment, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->referenceOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->originOffset, unit);
        PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->period, unit);
    }
}
void PSDimensionSetInverseQuantityName(PSDimensionRef theDimension, CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    IF_NO_OBJECT_EXISTS_RETURN(quantityName,);
    if(quantityName == theDimension->inverseQuantityName) return;
    
    PSDimensionalityRef theDimensionality = PSDimensionalityForQuantityName(theDimension->quantityName);
    PSDimensionalityRef theInverseDimensionality = PSDimensionalityByRaisingToAPowerWithoutReducing(theDimensionality, -1, NULL);
    CFArrayRef quantityNames = PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality(theInverseDimensionality);
    if(CFArrayContainsValue(quantityNames, CFRangeMake(0,CFArrayGetCount(quantityNames)), quantityName)) {
        if(theDimension->inverseQuantityName) CFRelease(theDimension->inverseQuantityName);
        theDimension->inverseQuantityName = CFRetain(quantityName);
    }
    CFRelease(quantityNames);
    
    if(theDimension->inverseIncrement) {
        CFArrayRef quantityUnits = PSUnitCreateArrayForQuantity(theDimension->inverseQuantityName);
        if(quantityUnits) {
            PSUnitRef inverseUnit = PSQuantityGetUnit(theDimension->inverseIncrement);
            if(!CFArrayContainsValue(quantityUnits, CFRangeMake(0,CFArrayGetCount(quantityUnits)), inverseUnit)) {
                PSScalarBestConversionForQuantityName((PSMutableScalarRef) theDimension->inverseIncrement, theDimension->inverseQuantityName);
                
                PSUnitRef betterUnit = PSQuantityGetUnit(theDimension->inverseIncrement);
                PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inverseReferenceOffset, betterUnit);
                PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inverseOriginOffset, betterUnit);
                PSScalarBestConversionForUnit((PSMutableScalarRef)theDimension->inversePeriod, betterUnit);
            }
            CFRelease(quantityUnits);
        }
    }
}

CFStringRef PSDimensionGetInverseLabel(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->inverseLabel;
}

void PSDimensionSetInverseLabel(PSDimensionRef theDimension, CFStringRef label)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(label == theDimension->inverseLabel) return;
    if(theDimension->inverseLabel) CFRelease(theDimension->inverseLabel);
    if(label) theDimension->inverseLabel = CFRetain(label);
    else theDimension->inverseLabel = NULL;
}

CFStringRef PSDimensionGetInverseDescription(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->inverseDescription;
}

void PSDimensionSetInverseDescription(PSDimensionRef theDimension, CFStringRef description)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(description == theDimension->inverseDescription) return;
    if(theDimension->inverseDescription) CFRelease(theDimension->inverseDescription);
    if(description) theDimension->inverseDescription = CFRetain(description);
    else theDimension->inverseDescription = NULL;
}

CFDictionaryRef PSDimensionGetMetaData(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    return theDimension->metaData;    
}

void PSDimensionSetMetaData(PSDimensionRef theDimension, CFDictionaryRef metaData)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,);
    if(metaData == theDimension->metaData) return;
    if(theDimension->metaData) CFRelease(theDimension->metaData);
    if(metaData) theDimension->metaData = CFRetain(metaData); 
    else theDimension->metaData = NULL;
}

#pragma mark Operatioms

bool PSDimensionMultiplyByScalar(PSDimensionRef theDimension, PSScalarRef theScalar, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    if(PSScalarDoubleValue(theScalar) == 0.0) return false;
    if(PSQuantityHasDimensionality(theScalar,PSDimensionalityDimensionless())&& PSScalarIsReal(theScalar) && PSScalarDoubleValue(theScalar)==1) return true;
    
    PSUnitRef theUnit = NULL;
    if(theDimension->increment) {
        PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->increment, theScalar, error);
        theUnit = PSQuantityGetUnit(theDimension->increment);
    }
    else {
        for(CFIndex index = 0; index<theDimension->npts;index++) {
            PSScalarRef coordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index);
            PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) coordinate, theScalar, error);
       }
        PSScalarRef coordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0);
        theUnit = PSQuantityGetUnit(coordinate);
    }
    
    if(PSUnitIsDimensionless(PSQuantityGetUnit(theDimension->increment))) {
        theDimension->madeDimensionless = false;
        theDimension->inverseMadeDimensionless = false;
    }
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->originOffset, theScalar, error);
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->referenceOffset, theScalar, error);
    if(theDimension->period) PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->period, theScalar, error);
    
    if(theDimension->quantityName) CFRelease(theDimension->quantityName);
    CFStringRef quantityName = PSUnitGuessQuantityName(theUnit);
    theDimension->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
    
    PSScalarRef theInverseScalar = PSScalarCreateByRaisingToAPowerWithoutReducingUnit(theScalar, -1, error);
    if(theDimension->inverseIncrement)
        PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->inverseIncrement, theInverseScalar, error);
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->inverseOriginOffset, theInverseScalar, error);
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->inverseReferenceOffset, theInverseScalar, error);
    if(theDimension->inversePeriod)
        PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) theDimension->inversePeriod, theInverseScalar, error);
    
    double multiplier = 1;
    PSUnitRef theReciprocalUnit = PSUnitByRaisingToAPowerWithoutReducing(theUnit, -1, &multiplier, NULL);
    if(theDimension->inverseQuantityName) CFRelease(theDimension->inverseQuantityName);
    quantityName = PSUnitGuessQuantityName(theReciprocalUnit);
    theDimension->inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);
    
    return true;
}



bool PSDimensionInverse(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDimension->increment,false);

    PSScalarRef tempScalar = theDimension->increment;
    theDimension->increment = theDimension->inverseIncrement;
    theDimension->inverseIncrement = tempScalar;

    CFStringRef tempString = theDimension->quantityName;
    theDimension->quantityName = theDimension->inverseQuantityName;
    theDimension->inverseQuantityName = tempString;
    
    tempString = theDimension->label;
    theDimension->label = theDimension->inverseLabel;
    theDimension->inverseLabel = tempString;
    
    tempString = theDimension->description;
    theDimension->description = theDimension->inverseDescription;
    theDimension->inverseDescription = tempString;
    
    tempScalar = theDimension->originOffset;
    theDimension->originOffset = theDimension->inverseOriginOffset;
    theDimension->inverseOriginOffset = tempScalar;
    
    tempScalar = theDimension->referenceOffset;
    theDimension->referenceOffset = theDimension->inverseReferenceOffset;
    theDimension->inverseReferenceOffset = tempScalar;
    
    tempScalar = theDimension->period;
    theDimension->period = theDimension->inversePeriod;
    theDimension->inversePeriod = tempScalar;
    
    bool tempBool = theDimension->periodic;
    theDimension->periodic = theDimension->inversePeriodic;
    theDimension->inversePeriodic = tempBool;
    
    tempBool = theDimension->madeDimensionless;
    theDimension->madeDimensionless = theDimension->inverseMadeDimensionless;
    theDimension->inverseMadeDimensionless = tempBool;
    
    return true;
}

#pragma mark Coordinates and Indexes Core Mapping

PSUnitRef PSDimensionGetRelativeUnit(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    if(theDimension->increment) return PSQuantityGetUnit((PSQuantityRef) theDimension->increment);
    return PSQuantityGetUnit(CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0));
}

PSUnitRef PSDimensionGetRelativeInverseUnit(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    if(theDimension->inverseIncrement) return PSQuantityGetUnit((PSQuantityRef) theDimension->inverseIncrement);
    else {
        CFArrayRef units = PSUnitCreateArrayOfRootUnitsForQuantityName(theDimension->inverseQuantityName);
        if(units) {
            PSUnitRef firstUnit = CFArrayGetValueAtIndex(units, 0);
            CFRelease(units);
            return firstUnit;
        }
    }
    return PSUnitByRaisingToAPower(PSQuantityGetUnit(CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0)), -1, NULL, NULL);
}

PSUnitRef PSDimensionGetDisplayedUnit(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    if(theDimension->increment) {
        if(!theDimension->madeDimensionless) return PSQuantityGetUnit((PSQuantityRef) theDimension->increment);
        double unit_multiplier = 1;
        return PSUnitByDividingWithoutReducing(PSQuantityGetUnit((PSQuantityRef) theDimension->increment), PSQuantityGetUnit((PSQuantityRef) theDimension->increment), &unit_multiplier);
    }
    else {
        PSScalarRef firstCoordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0);
        if(!theDimension->madeDimensionless) return PSQuantityGetUnit((PSQuantityRef) firstCoordinate);
        double unit_multiplier = 1;
        return PSUnitByDividingWithoutReducing(PSQuantityGetUnit((PSQuantityRef) firstCoordinate), PSQuantityGetUnit((PSQuantityRef) firstCoordinate), &unit_multiplier);
    }
    return NULL;
}

// *******************  Needs Updating for Non-Uniform Coordinates
PSDimensionalityRef PSDimensionGetDisplayedUnitDimensionality(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    if(!theDimension->madeDimensionless) return PSQuantityGetUnitDimensionality((PSQuantityRef) theDimension->increment);
    return PSDimensionalityByDividingWithoutReducing(PSQuantityGetUnitDimensionality((PSQuantityRef) theDimension->increment), PSQuantityGetUnitDimensionality((PSQuantityRef) theDimension->increment));
}

PSScalarRef PSDimensionCreateRelativeCoordinateFromIndex(PSDimensionRef theDimension, double index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    
    if(theDimension->increment) {
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            index -= T/2;
        }
        long double increment = PSScalarDoubleValue(theDimension->increment);
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        bool success;
        long double offset = PSScalarDoubleValueInUnit(theDimension->referenceOffset, unit, &success);
        long double result = increment*index+offset; // CSDM
        
        return PSScalarCreateWithDouble(result, unit);
    }
    else {
        return PSScalarCreateCopy(CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index));
    }
    return NULL;
}


float *PSDimensionCreateFloatVectorOfRelativeCoordinates(PSDimensionRef theDimension)
{
    __block float *vector = (float *) malloc(sizeof(float)*theDimension->npts);
    if(theDimension->increment) {
        float Z = 0;
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            Z = -T/2;
        }
        float increment = PSScalarFloatValue(theDimension->increment);
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        bool success;
        float offset = PSScalarFloatValueInUnit(theDimension->referenceOffset, unit, &success);
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(theDimension->npts, queue,
                       ^(size_t index) {
                           vector[index] = increment*(index+Z)+offset;
                       });
    }
    else {
        PSUnitRef coordinateUnit = PSDimensionGetRelativeUnit(theDimension);
        for(CFIndex index = 0; index<theDimension->npts; index++) {
            vector[index] = PSScalarFloatValueInUnit(CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index),coordinateUnit, NULL);
        }
    }
    
    return vector;
}

double *PSDimensionCreateDoubleVectorOfRelativeCoordinates(PSDimensionRef theDimension)
{
    double *vector = (double *) malloc(sizeof(double)*theDimension->npts);
    if(theDimension->increment) {
        double Z = 0;
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            Z = -T/2;
        }
        double increment = PSScalarDoubleValue(theDimension->increment);
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        bool success;
        double offset = PSScalarDoubleValueInUnit(theDimension->referenceOffset, unit, &success);
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(theDimension->npts, queue,
                       ^(size_t index) {
                           vector[index] = increment*(index+Z)+offset;
                       });
    }
    else {
        PSUnitRef coordinateUnit = PSDimensionGetRelativeUnit(theDimension);
        for(CFIndex index = 0; index<theDimension->npts; index++) {
            vector[index] = PSScalarDoubleValueInUnit(CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index),coordinateUnit, NULL);
        }
    }
    return vector;
}

float *PSDimensionCreateFloatVectorOfDimensionlessCoordinates(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    float *vector = (float *) malloc(sizeof(float)*theDimension->npts);
    
    if(theDimension->increment) {
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        bool success = true;

        float increment = PSScalarFloatValue(theDimension->increment);
        float origin_offset = 0;
        float reference_offset = 0;
        if(theDimension->originOffset) origin_offset =
            PSScalarFloatValueInUnit(theDimension->originOffset, unit, &success);
        if(theDimension->originOffset) reference_offset =
            PSScalarFloatValueInUnit(theDimension->referenceOffset, unit, &success);
        
        float totalOffset = origin_offset - reference_offset;
        
        float Z = 0;
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            Z = -T/2;
        }
        for(CFIndex index=0;index<theDimension->npts;index++) {
            float dIndex = index + Z;
            if(origin_offset==0.0) vector[index] = dIndex - reference_offset/increment;
            else vector[index] = (dIndex*increment + reference_offset)/totalOffset;
        }
    }
    else {
        PSUnitRef coordinateUnit = PSDimensionGetRelativeUnit(theDimension);
        bool success = true;
        float originOffset = PSScalarFloatValueInUnit(theDimension->originOffset, coordinateUnit, &success);
        float referenceOffset = PSScalarFloatValueInUnit(theDimension->referenceOffset, coordinateUnit, &success);
        
        for(CFIndex index = 0; index<theDimension->npts; index++) {
            PSScalarRef coordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index);
            vector[index] = PSScalarFloatValueInUnit(coordinate, coordinateUnit, &success)/(originOffset - referenceOffset);
        }
    }
    return vector;
}

double *PSDimensionCreateDoubleVectorOfDimensionlessCoordinates(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    double *vector = (double *) malloc(sizeof(double)*theDimension->npts);
    
    if(theDimension->increment) {
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        
        double increment = PSScalarDoubleValue(theDimension->increment);
        double origin_offset = 0;
        double reference_offset = 0;
        bool success = true;
        if(theDimension->originOffset) origin_offset =
            PSScalarDoubleValueInUnit(theDimension->originOffset, unit, &success);
        if(theDimension->originOffset) reference_offset =
            PSScalarDoubleValueInUnit(theDimension->referenceOffset, unit, &success);
        
        double totalOffset = origin_offset - reference_offset;
        
        double Z = 0;
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            Z = -T/2;
        }
        for(CFIndex index=0;index<theDimension->npts;index++) {
            double dIndex = index + Z;
            if(origin_offset==0.0) vector[index] = dIndex - reference_offset/increment;
            else vector[index] = (dIndex*increment + reference_offset)/totalOffset;
        }
    }
    else {
        PSUnitRef coordinateUnit = PSDimensionGetRelativeUnit(theDimension);
        bool success = true;
        double originOffset = PSScalarDoubleValueInUnit(theDimension->originOffset, coordinateUnit, &success);
        double referenceOffset = PSScalarDoubleValueInUnit(theDimension->referenceOffset, coordinateUnit, &success);
        
        for(CFIndex index = 0; index<theDimension->npts; index++) {
            PSScalarRef coordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index);
            vector[index] = PSScalarDoubleValueInUnit(coordinate, coordinateUnit, &success)/(originOffset - referenceOffset);
        }
    }
    return vector;
}

float *PSDimensionCreateFloatVectorOfDisplayedCoordinates(PSDimensionRef theDimension)
{
    if(theDimension->madeDimensionless) return PSDimensionCreateFloatVectorOfDimensionlessCoordinates(theDimension);
    else return PSDimensionCreateFloatVectorOfRelativeCoordinates(theDimension);
}

double *PSDimensionCreateDoubleVectorOfDisplayedCoordinates(PSDimensionRef theDimension)
{
    if(theDimension->madeDimensionless) return PSDimensionCreateDoubleVectorOfDimensionlessCoordinates(theDimension);
    else return PSDimensionCreateDoubleVectorOfRelativeCoordinates(theDimension);
}


// *******************  Needs Updating for Non-Uniform Coordinates
double PSDimensionIndexFromRelativeCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,0.0);
    IF_NO_OBJECT_EXISTS_RETURN(coordinate,0.0);
    
    if(theDimension->increment) {
        //CSDM
        long double coordinateValue = PSScalarDoubleValue(coordinate);
        PSUnitRef unit = PSQuantityGetUnit(coordinate);

        bool success = true;
        long double offset = 0.0;
        if(theDimension->referenceOffset) offset = PSScalarDoubleValueInUnit(theDimension->referenceOffset, unit, &success);
        long double increment = PSScalarDoubleValueInUnit(theDimension->increment, unit, &success);

        long double dIndex = (coordinateValue - offset)/increment; // CSDM
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            dIndex += T/2;
        }
        return dIndex;
    }
    else {
        PSScalarRef theCoordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0);
        PSComparisonResult lastResult = PSScalarCompare(coordinate, theCoordinate);
        if(lastResult==kPSCompareLessThan || lastResult==kPSCompareEqualTo) return 0;
        for(CFIndex index = 1; index<theDimension->npts;index++) {
            PSScalarRef theCoordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index);
            PSComparisonResult result = PSScalarCompare(coordinate, theCoordinate);
            if(result != lastResult) return index;
        }
    }
    return 0;
}

CFIndex PSDimensionClosestIndexToRelativeCoordinate(PSDimensionRef theDimension,
                                                    PSScalarRef coordinate)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,0.0);
    IF_NO_OBJECT_EXISTS_RETURN(coordinate,0.0);
    
    if(theDimension->increment) {
        //CSDM
        long double coordinateValue = PSScalarDoubleValue(coordinate);
        PSUnitRef unit = PSQuantityGetUnit(coordinate);
        
        bool success = true;
        long double offset = 0.0;
        if(theDimension->referenceOffset) offset = PSScalarDoubleValueInUnit(theDimension->referenceOffset, unit, &success);
        long double increment = PSScalarDoubleValueInUnit(theDimension->increment, unit, &success);
        
        long double dIndex = (coordinateValue - offset)/increment; // CSDM
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            dIndex += T/2;
        }

        return nearbyint(dIndex);
    }
    else {
        PSScalarRef theCoordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, 0);
        PSComparisonResult lastComparison = PSScalarCompare(coordinate, theCoordinate);
        PSScalarRef lastValue = theCoordinate;
        if(lastComparison==kPSCompareLessThan || lastComparison==kPSCompareEqualTo) return 0;
        for(CFIndex index = 1; index<theDimension->npts;index++) {
            theCoordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index);
            PSComparisonResult thisComparison = PSScalarCompare(coordinate, theCoordinate);
            PSScalarRef thisValue = theCoordinate;
            if(thisComparison != lastComparison) {
                double value = PSScalarDoubleValue(coordinate);
                double this = PSScalarDoubleValueInUnit(thisValue, PSQuantityGetUnit(coordinate), NULL);
                double last = PSScalarDoubleValueInUnit(lastValue, PSQuantityGetUnit(coordinate), NULL);
                if(fabs(value-this) > fabs(value-last)) return index-1;
                return index;
            }
            lastComparison = thisComparison;
            lastValue = thisValue;
        }
    }
    return 0;
}


// index = lrint( (coordinate - referenceOffset)/increment )
// if(reverse) index = -index
PSScalarRef PSDimensionCreateDimensionlessCoordinateFromIndex(PSDimensionRef theDimension, double index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    
    if(theDimension->increment) {
        PSUnitRef unit = PSQuantityGetUnit(theDimension->increment);
        
        long double increment = PSScalarDoubleValue(theDimension->increment);
        long double origin_offset = 0;
        long double reference_offset = 0;
        bool success = true;
        if(theDimension->originOffset) origin_offset =
            PSScalarDoubleValueInUnit(theDimension->originOffset, unit, &success);
        if(theDimension->originOffset) reference_offset =
            PSScalarDoubleValueInUnit(theDimension->referenceOffset, unit, &success);

        long double totalOffset = origin_offset - reference_offset;
        
        long double dIndex = index;
        if(theDimension->fft) {
            CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
            dIndex -= T/2;
        }
        double coordinate = 0;
        if(origin_offset==0.0) coordinate = dIndex - reference_offset/increment;
        else coordinate = (dIndex*increment + reference_offset)/totalOffset;
        return PSScalarCreateMutableWithDouble(coordinate,NULL);
    }
    else {
        PSScalarRef coordinate = CFArrayGetValueAtIndex(theDimension->nonUniformCoordinates, index);
        PSUnitRef unit = PSQuantityGetUnit(coordinate);
        bool success = true;
        double originOffset = PSScalarDoubleValueInUnit(theDimension->originOffset, unit, &success);
        double referenceOffset = PSScalarDoubleValueInUnit(theDimension->referenceOffset, unit, &success);
        double result = PSScalarDoubleValueInUnit(coordinate, unit, &success)/(originOffset - referenceOffset);
        return PSScalarCreateWithDouble(result, NULL);
    }
}



PSScalarRef PSDimensionCreateDisplayedCoordinateFromIndex(PSDimensionRef theDimension, double index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    PSScalarRef result = NULL;
    if(theDimension->madeDimensionless) {
        result = PSDimensionCreateDimensionlessCoordinateFromIndex(theDimension, index);
    }
    else result = PSDimensionCreateRelativeCoordinateFromIndex(theDimension, index);
    return result;
}


// *******************  Needs Updating for Non-Uniform Coordinates
CFIndex PSDimensionClosestIndexToDimensionlessCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,0.0);
    IF_NO_OBJECT_EXISTS_RETURN(coordinate,0.0);
    
    PSUnitRef relativeUnit = PSQuantityGetUnit(theDimension->increment);
    long double increment = PSScalarDoubleValue(theDimension->increment);

    long double origin_offset = 0;
    long double reference_offset = 0;
    bool success = true;
    if(theDimension->originOffset) origin_offset =
        PSScalarDoubleValueInUnit(theDimension->originOffset, relativeUnit, &success);
    if(theDimension->originOffset) reference_offset =
        PSScalarDoubleValueInUnit(theDimension->referenceOffset, relativeUnit, &success);
    long double totalOffset = origin_offset - reference_offset;

    PSUnitRef unit = PSUnitForSymbol(CFSTR(" "));
    long double coordinateValue = PSScalarDoubleValueInUnit(coordinate, unit, &success);
    double dIndex =0;
    if(origin_offset==0.0) dIndex = coordinateValue + reference_offset/increment;
    else dIndex = (coordinateValue*totalOffset - reference_offset)/increment;

    if(theDimension->fft) {
        CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
        dIndex += T/2;
    }

    return nearbyint(dIndex);
}

// *******************  Needs Updating for Non-Uniform Coordinates
double PSDimensionIndexFromDimensionlessCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,0.0);
    IF_NO_OBJECT_EXISTS_RETURN(coordinate,0.0);
    
    PSUnitRef relativeUnit = PSQuantityGetUnit(theDimension->increment);
    long double increment = PSScalarDoubleValue(theDimension->increment);

    long double origin_offset = 0;
    long double reference_offset = 0;
    bool success = true;
    if(theDimension->originOffset) origin_offset =
        PSScalarDoubleValueInUnit(theDimension->originOffset, relativeUnit, &success);
    if(theDimension->originOffset) reference_offset =
        PSScalarDoubleValueInUnit(theDimension->referenceOffset, relativeUnit, &success);
    long double totalOffset = origin_offset - reference_offset;

    PSUnitRef unit = PSUnitForSymbol(CFSTR(" "));
    long double coordinateValue = PSScalarDoubleValueInUnit(coordinate, unit, &success);
    double dIndex =0;
    if(origin_offset==0.0) dIndex = coordinateValue + reference_offset/increment;
    else dIndex = (coordinateValue*totalOffset - reference_offset)/increment;
    if(theDimension->fft) {
        CFIndex T = theDimension->npts*(theDimension->npts%2==0) + (theDimension->npts-1)*(theDimension->npts%2!=0);
        dIndex += T/2;
    }

    return dIndex;
}

CFIndex PSDimensionClosestIndexToDisplayedCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate)
{
    if(theDimension->madeDimensionless) return PSDimensionClosestIndexToDimensionlessCoordinate(theDimension, coordinate);
    else return PSDimensionClosestIndexToRelativeCoordinate(theDimension, coordinate);
}

double PSDimensionIndexFromDisplayedCoordinate(PSDimensionRef theDimension, PSScalarRef coordinate)
{
    if(theDimension->madeDimensionless) return PSDimensionIndexFromDimensionlessCoordinate(theDimension, coordinate);
    else return PSDimensionIndexFromRelativeCoordinate(theDimension, coordinate);
}

CFIndex PSDimensionCoordinateCountInDisplayedCoordinateRange(PSDimensionRef theDimension, PSScalarRef minimum, PSScalarRef maximum)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,kCFNotFound);
    IF_NO_OBJECT_EXISTS_RETURN(minimum,kCFNotFound);
    IF_NO_OBJECT_EXISTS_RETURN(maximum,kCFNotFound);
    if(!PSQuantityHasSameReducedDimensionality(minimum, maximum)) return kCFNotFound;

    PSUnitRef theUnit = PSDimensionGetDisplayedUnit(theDimension);
    if(!PSUnitHasSameReducedDimensionality(theUnit, PSQuantityGetUnit(minimum))) return kCFNotFound;
    if(!PSUnitHasSameReducedDimensionality(theUnit, PSQuantityGetUnit(maximum))) return kCFNotFound;
    CFIndex minimumIndex = PSDimensionClosestIndexToDisplayedCoordinate(theDimension, minimum);
    CFIndex maximumIndex = PSDimensionClosestIndexToDisplayedCoordinate(theDimension, maximum);
    return maximumIndex - minimumIndex+1;
}

#pragma mark Coordinates and Indexes

CFIndex PSDimensionLowestIndex(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,kCFNotFound);
    return 0;
}

CFIndex PSDimensionHighestIndex(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,kCFNotFound);
    return theDimension->npts-1;
}

PSScalarRef PSDimensionCreateMinimumDisplayedCoordinate(PSDimensionRef theDimension)
{
    return PSDimensionCreateDisplayedCoordinateFromIndex(theDimension, 0);
}

PSScalarRef PSDimensionCreateMaximumDisplayedCoordinate(PSDimensionRef theDimension)
{
    return PSDimensionCreateDisplayedCoordinateFromIndex(theDimension, theDimension->npts-1);
}

/*
 @function PSDimensionAliasIndex
 @abstract Aliases an index back into the bounds of the dimension
 @param theDimension The dimension.
 @result returns a CFIndex with the aliased index.
 */
CFIndex PSDimensionAliasIndex(PSDimensionRef theDimension, CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,kCFNotFound);
    index = index%theDimension->npts;
    if(index<0) index += theDimension->npts;
	return index;
}


#pragma mark Tests

// *******************  Needs Updating for Non-Uniform Coordinates
bool PSDimensionEqual(PSDimensionRef input1, PSDimensionRef input2)
{
	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    if(input1 == input2) return true;
    
    if(input1->npts!= input2->npts) return false;
    if(input1->fft!=input2->fft) return false;
    if(input1->periodic != input2->periodic) return false;
    if(input1->madeDimensionless != input2->madeDimensionless) return false;
    if(input1->inversePeriodic != input2->inversePeriodic) return false;
    if(input1->inverseMadeDimensionless != input2->inverseMadeDimensionless) return false;
    
    if(!PSCFStringEqual(input1->quantityName, input2->quantityName)) return false;
    if(!PSCFStringEqual(input1->inverseQuantityName, input2->inverseQuantityName)) return false;
    if(!PSCFStringEqual(input1->label, input2->label)) return false;
    if(!PSCFStringEqual(input1->description, input2->description)) return false;
    if(!PSCFStringEqual(input1->inverseLabel, input2->inverseLabel)) return false;
    if(!PSCFStringEqual(input1->inverseDescription, input2->inverseDescription)) return false;

    
    if(input1->increment==NULL & input2->increment!=NULL) return false;
    if(input1->increment!=NULL & input2->increment==NULL) return false;
    if(input1->increment) {
        if(PSScalarCompare(input1->increment,input2->increment) != kPSCompareEqualTo) return false;
    }
    else {
        for(CFIndex index = 0; index<input1->npts; index++) {
            if(PSScalarCompare(CFArrayGetValueAtIndex(input1->nonUniformCoordinates, index), CFArrayGetValueAtIndex(input2->nonUniformCoordinates, index)) != kPSCompareEqualTo) return false;
        }
    }
    if(PSScalarCompare(input1->originOffset,input2->originOffset) != kPSCompareEqualTo) return false;
    if(PSScalarCompare(input1->referenceOffset,input2->referenceOffset) != kPSCompareEqualTo) return false;
    if(PSScalarCompare(input1->inverseOriginOffset,input2->inverseOriginOffset) != kPSCompareEqualTo) return false;
    if(PSScalarCompare(input1->inverseReferenceOffset,input2->inverseReferenceOffset) != kPSCompareEqualTo) return false;
	return true;
}

// *******************  Needs Updating for Non-Uniform Coordinates
bool PSDimensionHasSameReducedDimensionality(PSDimensionRef input1, PSDimensionRef input2)
{
 	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    if(PSQuantityHasSameReducedDimensionality((PSQuantityRef) input1->increment, (PSQuantityRef) input2->increment)) return true;
    return false;
}

bool PSDimensionOriginOffsetIsZero(PSDimensionRef theDimension)
{
    if(PSScalarDoubleValue(theDimension->originOffset)==0.0) return true;
    return false;
}

bool PSLinearDimensionHasIdenticalIncrement(PSDimensionRef input1, PSDimensionRef input2, CFStringRef *reason)
{
    if(PSScalarCompare(input1->increment, input2->increment)!=kPSCompareEqualTo) {
        if(reason) {
            CFStringRef increment1 = PSScalarCreateStringValue(input1->increment);
            CFStringRef increment2 = PSScalarCreateStringValue(input2->increment);
            *reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Dimension sampling intervals %@ and %@ don't match"),increment1, increment2);
            CFRelease(increment1);
            CFRelease(increment2);
        }
        return false;
    }
    return true;
}

bool PSDimensionHasIdenticalSampling(PSDimensionRef input1, PSDimensionRef input2, CFStringRef *reason)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    if(input1->npts!= input2->npts) {
        if(reason) {
            *reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Dimensions number of points %ld and %ld don't match"),input1->npts, input2->npts);
        }
        return false;
    }
    
    if(PSScalarCompare(input1->increment, input2->increment)!=kPSCompareEqualTo) {
        if(reason) {
            CFStringRef increment1 = PSScalarCreateStringValue(input1->increment);
            CFStringRef increment2 = PSScalarCreateStringValue(input2->increment);
            *reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Dimensions sampling intervals %@ and %@ don't match"),increment1, increment2);
            CFRelease(increment1);
            CFRelease(increment2);
        }
        return false;
    }
    if(PSScalarCompare(input1->referenceOffset, input2->referenceOffset)!=kPSCompareEqualTo) {
        if(reason) {
            CFStringRef offset1 = PSScalarCreateStringValue(input1->referenceOffset);
            CFStringRef offset2 = PSScalarCreateStringValue(input2->referenceOffset);
            *reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Dimensions reference offsets %@ and %@ don't match"),offset1, offset2);
            CFRelease(offset1);
            CFRelease(offset2);
        }
        return false;
    }
    return true;
}

bool PSDimensionIsDisplayedCoordinateInRange(PSDimensionRef theDimension, PSScalarRef coordinate, PSScalarRef minimum, PSScalarRef maximum, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    CFIndex minimumIndex = PSDimensionIndexFromDisplayedCoordinate(theDimension, minimum);
    if(error) if(*error) return false;
    CFIndex maximumIndex = PSDimensionIndexFromDisplayedCoordinate(theDimension, maximum);
    if(error) if(*error) return false;
    CFIndex coordinateIndex = PSDimensionIndexFromDisplayedCoordinate(theDimension, coordinate);
    if(error) if(*error) return false;
    if(coordinateIndex > maximumIndex) return false;
    if(coordinateIndex < minimumIndex) return false;
    return true;
}

bool PSDimensionIsRelativeCoordinateInRange(PSDimensionRef theDimension, PSScalarRef coordinate, PSScalarRef minimum, PSScalarRef maximum, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    CFIndex minimumIndex = PSDimensionClosestIndexToRelativeCoordinate(theDimension, minimum);
    if(error) if(*error) return false;
    CFIndex maximumIndex = PSDimensionClosestIndexToRelativeCoordinate(theDimension, maximum);
    if(error) if(*error) return false;
    CFIndex coordinateIndex = PSDimensionClosestIndexToRelativeCoordinate(theDimension, coordinate);
    if(error) if(*error) return false;
    if(coordinateIndex > maximumIndex) return false;
    if(coordinateIndex < minimumIndex) return false;
    return true;
}

bool PSDimensionIsLinear(PSDimensionRef theDimension)
{
    return theDimension->increment!=NULL;
}

#pragma mark Strings and Archiving

// *******************  Needs Updating for Non-Uniform Coordinates
CFStringRef PSDimensionCreateStringValue(PSDimensionRef theDimension)
{
	IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL)
    
    CFStringRef increment = PSScalarCreateStringValue(theDimension->increment);
    CFStringRef originOffset = PSScalarCreateStringValue(theDimension->originOffset);
    CFStringRef inverseOriginOffset = PSScalarCreateStringValue(theDimension->inverseOriginOffset);
	CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault, NULL,
                                                  CFSTR("(quantity:%@, label:%@, npts:%ld, increment:%@, originOffset:%@, inverseOriginOffset:%@)\n"),
                                                  theDimension->quantityName,
                                                  theDimension->label,
                                                  theDimension->npts,
                                                  increment,
                                                  originOffset,
                                                  inverseOriginOffset);
    CFRelease(increment);
    CFRelease(originOffset);
    CFRelease(inverseOriginOffset);
    return result;
}

CFDictionaryRef PSDimensionCreateCSDMPList(PSDimensionRef theDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimension,NULL);
    
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
 
    if(theDimension->nonUniformCoordinates) {
        CFDictionarySetValue(dictionary, CFSTR("type"),CFSTR("monotonic"));

        CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFArrayApplyFunction(theDimension->nonUniformCoordinates,
                             CFRangeMake(0,CFArrayGetCount(theDimension->nonUniformCoordinates)),
                             (CFArrayApplierFunction) PSScalarAddToArrayAsStringValue,
                             array);
        CFDictionarySetValue(dictionary, CFSTR("coordinates"),array);
        CFRelease(array);
    }
    else {
        CFDictionarySetValue(dictionary, CFSTR("type"),CFSTR("linear"));
        
        CFNumberRef number = PSCFNumberCreateWithCFIndex(theDimension->npts);
        CFDictionarySetValue(dictionary, CFSTR("count"), number);
        CFRelease(number);

        if(theDimension->increment) {
            CFStringRef stringValue = PSScalarCreateStringValue(theDimension->increment);
            if(stringValue) {
                CFDictionarySetValue( dictionary, CFSTR("increment"), stringValue);
                CFRelease(stringValue);
            }
        }
    }
    
    if(theDimension->label && CFStringGetLength(theDimension->label))
        CFDictionarySetValue(dictionary, CFSTR("label"),theDimension->label);
    
    if(theDimension->description && CFStringGetLength(theDimension->description))
        CFDictionarySetValue(dictionary, CFSTR("description"),theDimension->description);
    


    if(theDimension->referenceOffset && PSScalarDoubleValue(theDimension->referenceOffset)!=0.0) {
        PSScalarRef temp = PSScalarCreateCopy(theDimension->referenceOffset);
        CFStringRef stringValue = PSScalarCreateStringValue(temp);
        CFRelease(temp);
        if(stringValue) {
            CFDictionarySetValue(dictionary, CFSTR("coordinates_offset"), stringValue);
            CFRelease(stringValue);
        }
    }

    if(theDimension->originOffset && PSScalarDoubleValue(theDimension->originOffset)!=0.0) {
        CFStringRef stringValue = PSScalarCreateStringValue(theDimension->originOffset);
        if(stringValue) {
            CFDictionarySetValue(dictionary, CFSTR("origin_offset"), stringValue);
            CFRelease(stringValue);
        }
    }
    
    if(theDimension->quantityName)
        CFDictionarySetValue(dictionary, CFSTR("quantity_name"),theDimension->quantityName);

    if(theDimension->periodic) {
        CFStringRef stringValue = PSScalarCreateStringValue(theDimension->period);
        if(stringValue) {
            CFDictionarySetValue(dictionary, CFSTR("period"), stringValue);
            CFRelease(stringValue);
        }
    }
    
    if(theDimension->fft) CFDictionarySetValue(dictionary, CFSTR("complex_fft"), kCFBooleanTrue);

    CFMutableDictionaryRef reciprocalDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    {
        if(theDimension->inverseLabel && CFStringGetLength(theDimension->inverseLabel))
            CFDictionarySetValue( reciprocalDictionary, CFSTR("label"), theDimension->inverseLabel);
        
        if(theDimension->inverseDescription && CFStringGetLength(theDimension->inverseDescription))
            CFDictionarySetValue( reciprocalDictionary, CFSTR("description"), theDimension->inverseDescription);
        
        if(theDimension->inverseQuantityName)
            CFDictionarySetValue( reciprocalDictionary, CFSTR("quantity_name"), theDimension->inverseQuantityName);
        
        if(theDimension->inversePeriodic) {
            CFStringRef stringValue = PSScalarCreateStringValue(theDimension->inversePeriod);
            if(stringValue) {
                CFDictionarySetValue(reciprocalDictionary, CFSTR("period"), stringValue);
                CFRelease(stringValue);
            }
        }

        if(theDimension->inverseReferenceOffset && PSScalarDoubleValue(theDimension->inverseReferenceOffset)!=0.0) {
            PSScalarRef temp = PSScalarCreateCopy(theDimension->inverseReferenceOffset);
            CFStringRef stringValue = PSScalarCreateStringValue(temp);
            CFRelease(temp);
            if(stringValue) {
                CFDictionarySetValue(reciprocalDictionary, CFSTR("coordinates_offset"), stringValue);
                CFRelease(stringValue);
            }
            
        }
        
        if(theDimension->inverseOriginOffset && PSScalarDoubleValue(theDimension->inverseOriginOffset)!=0.0) {
            CFStringRef stringValue = PSScalarCreateStringValue(theDimension->inverseOriginOffset);
            if(stringValue) {
                CFDictionarySetValue(reciprocalDictionary, CFSTR("origin_offset"), stringValue);
                CFRelease(stringValue);
            }
        }

        {
            CFMutableDictionaryRef application = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
            
            CFMutableDictionaryRef RMNDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            {
                if(theDimension->inverseMadeDimensionless) CFDictionarySetValue(RMNDictionary, kPSDimensionMadeDimensionless, kCFBooleanTrue);
            }
            
            if(CFDictionaryGetCount(RMNDictionary)) {
                CFDictionaryAddValue(application, CFSTR("com.physyapps.rmn"), RMNDictionary);
                CFDictionarySetValue(reciprocalDictionary, CFSTR("application"),application);
            }
            CFRelease(RMNDictionary);
            CFRelease(application);
        }

    }
    if(CFDictionaryGetCount(reciprocalDictionary)) CFDictionarySetValue(dictionary, CFSTR("reciprocal"), reciprocalDictionary);
    CFRelease(reciprocalDictionary);
    
    {
        CFMutableDictionaryRef application = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        
        CFMutableDictionaryRef RMNDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        {
            if(theDimension->madeDimensionless) CFDictionarySetValue(RMNDictionary, kPSDimensionMadeDimensionless, kCFBooleanTrue);
            
            if(theDimension->metaData) {
                if(CFDictionaryGetCount(theDimension->metaData)) {
                    CFDictionaryRef metaDataPropertyList = PSCFDictionaryCreatePListCompatible(theDimension->metaData);
                    CFDictionarySetValue(RMNDictionary, kPSDimensionMetaData,metaDataPropertyList);
                    CFRelease(metaDataPropertyList);
                }
            }
            
        }
        
        if(CFDictionaryGetCount(RMNDictionary)) {
            CFDictionaryAddValue(application, CFSTR("com.physyapps.rmn"), RMNDictionary);
            CFDictionarySetValue(dictionary, CFSTR("application"),application);
        }
        CFRelease(RMNDictionary);
        CFRelease(application);
    }
    
    return dictionary;
}

PSDimensionRef PSDimensionCreateWithCSDMPList(CFDictionaryRef dictionary, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dictionary,NULL);
    CFIndex npts = 0;

    if(!CFDictionaryContainsKey(dictionary, CFSTR("type"))) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read Dimension object."), CFSTR("No type key found."), NULL);
        return NULL;
    }
    CFStringRef type = CFDictionaryGetValue(dictionary, CFSTR("type"));

    CFStringRef quantityName = CFDictionaryGetValue(dictionary, CFSTR("quantity_name"));
    CFMutableArrayRef monotonicCoordinates = NULL;
    PSScalarRef increment = NULL;
    PSDimensionRef theDimension = NULL;
    if(CFStringCompare(type, CFSTR("monotonic"), 0)==kCFCompareEqualTo) {
        if(!CFDictionaryContainsKey(dictionary, CFSTR("coordinates"))) {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot read Dimension object."), CFSTR("No coordinates key found."), NULL);
            return NULL;
        }
        CFArrayRef values = CFDictionaryGetValue(dictionary, CFSTR("coordinates"));
        npts = CFArrayGetCount(values);
        monotonicCoordinates = CFArrayCreateMutable(kCFAllocatorDefault, npts, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<npts; index++) {
            PSScalarRef scalar = PSScalarCreateWithCFString(CFArrayGetValueAtIndex(values, index), error);
            CFArrayAppendValue(monotonicCoordinates, scalar);
            CFRelease(scalar);
        }
        theDimension = PSMonotonicDimensionCreateDefault(monotonicCoordinates, quantityName);
    }
    else if(CFStringCompare(type, CFSTR("linear"), 0)==kCFCompareEqualTo) {
        if(CFDictionaryContainsKey(dictionary, CFSTR("count"))) {
            CFTypeRef value =  CFDictionaryGetValue(dictionary, CFSTR("count"));
            if(CFGetTypeID(value)!=CFNumberGetTypeID()) {
                if(error) *error = PSCFErrorCreate(CFSTR("Cannot read Dimension object."), CFSTR("illegal value for count key."), NULL);
                return NULL;
            }
            CFNumberGetValue((CFNumberRef) value,kCFNumberCFIndexType, &npts);
        }
        
        if(CFDictionaryContainsKey(dictionary, CFSTR("increment")))
            increment = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("increment")),error);
        theDimension = PSLinearDimensionCreateDefault(npts, increment, quantityName,NULL);
    }
    else if(CFStringCompare(type, CFSTR("labeled"), 0)==kCFCompareEqualTo) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read Dimension object."), CFSTR("RMN does not support labeled dimensions."), NULL);
        return NULL;
    }
    else {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read Dimension object."), CFSTR("illegal value for type key."), NULL);
        return NULL;
    }

    CFStringRef label = CFDictionaryGetValue(dictionary, CFSTR("label"));
    if(label) PSDimensionSetLabel(theDimension, label);
    
    CFStringRef description = CFDictionaryGetValue(dictionary, CFSTR("description"));
    if(description) PSDimensionSetDescription(theDimension, description);
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("origin_offset"))) {
        PSScalarRef originOffset = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("origin_offset")),error);
        if(originOffset) PSDimensionSetOriginOffset(theDimension, originOffset);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("coordinates_offset"))) {
        PSScalarRef referenceOffset = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("coordinates_offset")),error);
        if(referenceOffset) PSDimensionSetReferenceOffset(theDimension, referenceOffset);
    }

    if(CFDictionaryContainsKey(dictionary, CFSTR("complex_fft")))
        PSDimensionSetFFT(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("complex_fft"))));

    if(CFDictionaryContainsKey(dictionary, CFSTR("period"))) {
        PSScalarRef period = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("period")),error);
        if(period) PSDimensionSetPeriod(theDimension, period);
        PSDimensionSetPeriodic(theDimension,true);
    }

    CFDictionaryRef application = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("application"))) {
        application = CFDictionaryGetValue(dictionary, CFSTR("application"));
        if(CFDictionaryContainsKey(application, CFSTR("com.physyapps.rmn"))) {
            CFDictionaryRef RMNDictionary = CFDictionaryGetValue(application, CFSTR("com.physyapps.rmn"));
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("madeDimensionless")))
                PSDimensionSetMadeDimensionless(theDimension, CFBooleanGetValue(CFDictionaryGetValue(RMNDictionary, CFSTR("madeDimensionless"))));
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("metaData")))
                PSDimensionSetMetaData(theDimension, CFDictionaryGetValue(RMNDictionary, CFSTR("metaData")));
        }
    }
    
    CFDictionaryRef reciprocal = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocal")))
        reciprocal = CFDictionaryGetValue(dictionary, CFSTR("reciprocal"));
    
    if(reciprocal) {
        if(CFDictionaryContainsKey(reciprocal, CFSTR("quantity_name")))
            PSDimensionSetInverseQuantityName(theDimension, CFDictionaryGetValue(reciprocal, CFSTR("quantity_name")));
        if(CFDictionaryContainsKey(reciprocal, CFSTR("label")))
            PSDimensionSetInverseLabel(theDimension, CFDictionaryGetValue(reciprocal, CFSTR("label")));
        if(CFDictionaryContainsKey(reciprocal, CFSTR("description")))
            PSDimensionSetInverseDescription(theDimension, CFDictionaryGetValue(reciprocal, CFSTR("description")));

        if(CFDictionaryContainsKey(reciprocal, CFSTR("origin_offset"))) {
            PSScalarRef inverseOriginOffset = PSScalarCreateWithCFString(CFDictionaryGetValue(reciprocal, CFSTR("origin_offset")),error);
            if(inverseOriginOffset) PSDimensionSetInverseOriginOffset(theDimension, inverseOriginOffset);
        }

        if(CFDictionaryContainsKey(reciprocal, CFSTR("coordinates_offset"))) {
            PSScalarRef inverseReferenceOffset = PSScalarCreateWithCFString(CFDictionaryGetValue(reciprocal, CFSTR("coordinates_offset")),error);
            if(inverseReferenceOffset) PSDimensionSetInverseReferenceOffset(theDimension, inverseReferenceOffset);
        }
        
        if(CFDictionaryContainsKey(reciprocal, CFSTR("period"))) {
            PSScalarRef inversePeriod = PSScalarCreateWithCFString(CFDictionaryGetValue(reciprocal, CFSTR("period")),error);
            if(inversePeriod) PSDimensionSetInversePeriod(theDimension, inversePeriod);
            PSDimensionSetInversePeriodic(theDimension,true);
        }
        
        CFDictionaryRef application = NULL;
        if(CFDictionaryContainsKey(reciprocal, CFSTR("application"))) {
            application = CFDictionaryGetValue(reciprocal, CFSTR("application"));
            if(CFDictionaryContainsKey(application, CFSTR("com.physyapps.rmn"))) {
                CFDictionaryRef RMNDictionary = CFDictionaryGetValue(application, CFSTR("com.physyapps.rmn"));
                
                if(CFDictionaryContainsKey(RMNDictionary, CFSTR("madeDimensionless")))
                    PSDimensionSetInverseMadeDimensionless(theDimension, CFBooleanGetValue(CFDictionaryGetValue(RMNDictionary, CFSTR("madeDimensionless"))));
            }
        }
        
    }
    return theDimension;
}

PSDimensionRef PSDimensionCreateWithPList(CFDictionaryRef dictionary, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dictionary,NULL);
    
    CFIndex version = 0;
    if(CFDictionaryContainsKey(dictionary, kPSDimensionVersion)) {
        CFNumberRef number =  CFDictionaryGetValue(dictionary, kPSDimensionVersion);
        if(number) CFNumberGetValue(number,kCFNumberCFIndexType, &version);
    }
    
    CFIndex npts = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("npts"))) {
        CFNumberRef number =  CFDictionaryGetValue(dictionary, CFSTR("npts"));
        CFNumberGetValue(number,kCFNumberCFIndexType, &npts);
    }

    CFMutableArrayRef nonUniformCoordinates = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("nonUniformCoordinates"))) {
        CFArrayRef coordinates = CFDictionaryGetValue(dictionary, CFSTR("nonUniformCoordinates"));
        CFIndex numberOfCoordinates = CFArrayGetCount(coordinates);
        nonUniformCoordinates = CFArrayCreateMutable(kCFAllocatorDefault, numberOfCoordinates, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<npts;index++) {
            PSScalarRef value = PSScalarCreateWithCFString(CFArrayGetValueAtIndex(coordinates, index), error);
            CFArrayAppendValue(nonUniformCoordinates, value);
            CFRelease(value);
        }
    }
    
    PSScalarRef increment = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("samplingInterval")))
        increment = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("samplingInterval")),error);
    
    CFStringRef quantityName = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("quantity")))
    quantityName = CFDictionaryGetValue(dictionary, CFSTR("quantity"));
    
    PSDimensionRef theDimension = NULL;
    if(nonUniformCoordinates) {
        theDimension = PSMonotonicDimensionCreateDefault(nonUniformCoordinates, quantityName);
        CFRelease(nonUniformCoordinates);
    }
    else if(increment) {
        theDimension = PSLinearDimensionCreateDefault(npts, increment, quantityName,NULL);
        CFRelease(increment);
    }
    else return NULL;

    if(CFDictionaryContainsKey(dictionary, CFSTR("label")))
        PSDimensionSetLabel(theDimension, CFDictionaryGetValue(dictionary, CFSTR("label")));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("description")))
        PSDimensionSetDescription(theDimension, CFDictionaryGetValue(dictionary, CFSTR("description")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocalDimensionQuantity")))
        PSDimensionSetInverseQuantityName(theDimension, CFDictionaryGetValue(dictionary, CFSTR("reciprocalDimensionQuantity")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseQuantity")))
        PSDimensionSetInverseQuantityName(theDimension, CFDictionaryGetValue(dictionary, CFSTR("inverseQuantity")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocalDimensionLabel")))
        PSDimensionSetInverseLabel(theDimension,CFDictionaryGetValue(dictionary, CFSTR("reciprocalDimensionLabel")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseLabel")))
        PSDimensionSetInverseLabel(theDimension,CFDictionaryGetValue(dictionary, CFSTR("inverseLabel")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseDescription")))
        PSDimensionSetInverseDescription(theDimension, CFSTR("inverseDescription"));

    if(CFDictionaryContainsKey(dictionary, CFSTR("ftFlag")))
        PSDimensionSetFFT(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("ftFlag"))));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("periodic")))
        PSDimensionSetPeriodic(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("periodic"))));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("inversePeriodic")))
        PSDimensionSetInversePeriodic(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("inversePeriodic"))));

    if(CFDictionaryContainsKey(dictionary, CFSTR("madeDimensionless")))
        PSDimensionSetMadeDimensionless(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("madeDimensionless"))));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseMadeDimensionless")))
        PSDimensionSetInverseMadeDimensionless(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("inverseMadeDimensionless"))));
    

    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseSamplingInterval"))) {
        PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("inverseSamplingInterval")),error);
        PSDimensionSetInverseIncrement(theDimension, value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("originOffset"))) {
        PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("originOffset")),error);
        PSDimensionSetOriginOffset(theDimension, value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocalDimensionOriginOffset"))) {
        PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("reciprocalDimensionOriginOffset")),error);
        PSDimensionSetInverseOriginOffset(theDimension, value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseOriginOffset"))) {
        PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("inverseOriginOffset")),error);
        PSDimensionSetInverseOriginOffset(theDimension, value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("referenceOffset"))) {
        PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("referenceOffset")),error);
        if(version<1 && !PSDimensionGetInverseMadeDimensionless(theDimension)) PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) value, -1);
        PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) value, -1);
        PSDimensionSetReferenceOffset(theDimension, value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocalDimensionReferenceOffset"))) {
        PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("reciprocalDimensionReferenceOffset")),error);
        PSDimensionSetInverseReferenceOffset(theDimension, value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseReferenceOffset"))) {
        PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("inverseReferenceOffset")),error);
        if(version<1 && !PSDimensionGetInverseMadeDimensionless(theDimension)) PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) value, -1);
        PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) value, -1);
        PSDimensionSetInverseReferenceOffset(theDimension, value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("metaData"))) {
        CFDictionaryRef metaData = PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryGetValue(dictionary, CFSTR("metaData")),error);
        PSDimensionSetMetaData(theDimension,metaData);
        CFRelease(metaData);
    }
    bool reverse = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("reverse")));
    bool inverseReverse = CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("inverseReverse")));
    PSDimensionMakeNiceUnits(theDimension);

    return theDimension;
}


PSDimensionRef PSDimensionCreateWithData(CFDataRef data, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(data,NULL);
    
    CFPropertyListFormat format;
    CFDictionaryRef dictionary  = CFPropertyListCreateWithData (kCFAllocatorDefault,data,kCFPropertyListImmutable,&format,error);
    if(dictionary==NULL) return NULL;
    
    CFIndex version = 0;
    if(CFDictionaryContainsKey(dictionary, kPSDimensionVersion)) {
        CFNumberRef number =  CFDictionaryGetValue(dictionary, kPSDimensionVersion);
        if(number) CFNumberGetValue(number,kCFNumberCFIndexType, &version);
    }

    PSDimensionRef theDimension = NULL;
    
    PSScalarRef increment = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("samplingInterval")))
        increment = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("samplingInterval")),error);
    
    CFIndex npts = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("npts"))) {
        CFNumberRef number =  CFDictionaryGetValue(dictionary, CFSTR("npts"));
        if(number==NULL) {
            CFRelease(dictionary);
            return NULL;
        }
        CFNumberGetValue(number,kCFNumberCFIndexType, &npts);
    }
    
    CFStringRef quantityName = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("quantity")))
        quantityName = CFDictionaryGetValue(dictionary, CFSTR("quantity"));
    
    CFMutableArrayRef nonUniformCoordinates = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("nonUniformCoordinates"))) {
        CFArrayRef coordinates = CFDictionaryGetValue(dictionary, CFSTR("nonUniformCoordinates"));
        CFIndex numberOfCoordinates = CFArrayGetCount(coordinates);
        nonUniformCoordinates = CFArrayCreateMutable(kCFAllocatorDefault, numberOfCoordinates, &kCFTypeArrayCallBacks);
        for(CFIndex index = 0; index<npts;index++) {
            PSScalarRef value = PSScalarCreateWithData(CFArrayGetValueAtIndex(coordinates, index), error);
            CFArrayAppendValue(nonUniformCoordinates, value);
            CFRelease(value);
        }
    }
    
    if(increment) {
        theDimension = PSLinearDimensionCreateDefault(npts, increment, quantityName,NULL);
        CFRelease(increment);
    }
    else if(nonUniformCoordinates) {
        theDimension = PSMonotonicDimensionCreateDefault(nonUniformCoordinates, quantityName);
    }
    else {
        CFRelease(dictionary);
        return NULL;}
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseQuantity")))
        PSDimensionSetInverseQuantityName(theDimension,CFDictionaryGetValue(dictionary, CFSTR("inverseQuantity")));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("label")))
        PSDimensionSetLabel(theDimension,CFDictionaryGetValue(dictionary, CFSTR("label")));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("description")))
        PSDimensionSetDescription(theDimension,CFDictionaryGetValue(dictionary, CFSTR("description")));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocalDimensionQuantity")))
        PSDimensionSetInverseQuantityName(theDimension,CFDictionaryGetValue(dictionary, CFSTR("reciprocalDimensionQuantity")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocalDimensionLabel")))
        PSDimensionSetInverseLabel(theDimension,CFDictionaryGetValue(dictionary, CFSTR("reciprocalDimensionLabel")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseLabel")))
        PSDimensionSetInverseLabel(theDimension,CFDictionaryGetValue(dictionary, CFSTR("inverseLabel")));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("description")))
        PSDimensionSetInverseDescription(theDimension,CFDictionaryGetValue(dictionary, CFSTR("description")));

    if(CFDictionaryContainsKey(dictionary, CFSTR("ftFlag")))
        PSDimensionSetFFT(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("ftFlag"))));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("periodic")))
        PSDimensionSetPeriodic(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("periodic"))));

    if(CFDictionaryContainsKey(dictionary, CFSTR("inversePeriodic")))
        PSDimensionSetInversePeriodic(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("inversePeriodic"))));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("madeDimensionless")))
        PSDimensionSetMadeDimensionless(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("madeDimensionless"))));

    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseMadeDimensionless")))
        PSDimensionSetInverseMadeDimensionless(theDimension, CFBooleanGetValue(CFDictionaryGetValue(dictionary, CFSTR("inverseMadeDimensionless"))));

    if(CFDictionaryContainsKey(dictionary, CFSTR("originOffset"))) {
        PSScalarRef value = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("originOffset")),error);
        PSDimensionSetOriginOffset(theDimension,value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseSamplingInterval"))) {
        PSScalarRef value = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("inverseSamplingInterval")),error);
        PSDimensionSetInverseIncrement(theDimension,value);
        CFRelease(value);
    }

    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseOriginOffset"))) {
        PSScalarRef value = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("inverseOriginOffset")),error);
        PSDimensionSetInverseOriginOffset(theDimension,value);
        CFRelease(value);
    }
    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseOriginOffset"))) {
        PSScalarRef value = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("inverseOriginOffset")),error);
        PSDimensionSetInverseOriginOffset(theDimension,value);
        CFRelease(value);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("referenceOffset"))) {
        PSScalarRef value = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("referenceOffset")),error);
        if(version<1 && !PSDimensionGetMadeDimensionless(theDimension)) PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) value, -1);
        PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) value, -1);
        PSDimensionSetReferenceOffset(theDimension,value);
        CFRelease(value);
   }

    PSScalarRef inverseReferenceOffset = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("reciprocalDimensionReferenceOffset")))
        inverseReferenceOffset = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("reciprocalDimensionReferenceOffset")),error);
    if(CFDictionaryContainsKey(dictionary, CFSTR("inverseReferenceOffset")))
        inverseReferenceOffset = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("inverseReferenceOffset")),error);
    if(version<1 && !PSDimensionGetInverseMadeDimensionless(theDimension)) PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) inverseReferenceOffset, -1);
    PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) inverseReferenceOffset, -1);
    if(inverseReferenceOffset) {
        PSDimensionSetInverseReferenceOffset(theDimension,inverseReferenceOffset);
        CFRelease(inverseReferenceOffset);
}
    if(CFDictionaryContainsKey(dictionary, CFSTR("metaData"))) {
        PSDimensionSetMetaData(theDimension, PSCFDictionaryCreateWithPListCompatibleDictionary((CFDictionaryRef) CFDictionaryGetValue(dictionary, CFSTR("metaData")),error));
    }

    PSDimensionMakeNiceUnits(theDimension);
    CFRelease(dictionary);
    return theDimension;
}


#pragma mark Index Utilities

CFIndex strideAlongDimensionIndex(const CFIndex *npts, const CFIndex dimensionsCount, const CFIndex dimensionIndex)
{
    if(dimensionIndex==0) return 1;
    CFIndex stride = 1;
    for(CFIndex idim = 0; idim<dimensionIndex; idim++) {
        stride *= npts[idim];
    }
    return stride;
}

CFIndex memOffsetFromIndexes(CFIndex *indexes, const CFIndex dimensionsCount, const CFIndex *npts)
{
    // npts is an array containing the total number of samples along each dimension
    
    // First alias all indexes back into valid range.
   for(CFIndex idim = 0;idim<dimensionsCount; idim++) {
        indexes[idim] = indexes[idim]%npts[idim];
        if(indexes[idim] < 0) indexes[idim] += npts[idim];
    }

    CFIndex memOffset = indexes[dimensionsCount-1];
    for(CFIndex idim = dimensionsCount-2;idim >= 0; idim--) {
        memOffset *= npts[idim];
        memOffset += indexes[idim];
    }
    return memOffset;
}

void setIndexesForMemOffset(const CFIndex memOffset, CFIndex indexes[], const CFIndex dimensionsCount, const CFIndex *npts)
{
    CFIndex hyperVolume = 1;
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        indexes[idim] = (memOffset/hyperVolume)%(npts[idim]);
        hyperVolume *= npts[idim];
    }
}

void setIndexesForReducedMemOffsetIgnoringDimension(const CFIndex memOffset, CFIndex indexes[], const CFIndex dimensionsCount, const CFIndex *npts, const CFIndex ignoredDimension)
{
    CFIndex hyperVolume = 1;
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        if(idim!=ignoredDimension) {
            indexes[idim] = (memOffset/hyperVolume)%(npts[idim]);
            hyperVolume *= npts[idim];
        }
    }
}

void setIndexesForReducedMemOffsetIgnoringDimensions(const CFIndex memOffset, CFIndex indexes[], const CFIndex dimensionsCount, const CFIndex *npts, PSIndexSetRef dimensionIndexSet)
{
    CFIndex hyperVolume = 1;
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        if(!PSIndexSetContainsIndex(dimensionIndexSet, idim)) {
            indexes[idim] = (memOffset/hyperVolume)%(npts[idim]);
            hyperVolume *= npts[idim];
        }
    }
}

#pragma mark Dimension Arrays

CFIndex PSDimensionCalculateSizeFromDimensions(CFArrayRef dimensions)
{
    CFIndex size = 1;
    if(dimensions) {
        CFIndex dimensionsCount = CFArrayGetCount(dimensions);
        for(CFIndex index = 0; index<dimensionsCount; index++) {
            PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, index);
            size *= PSDimensionGetNpts(dimension);
        }
    }
    return size;
}

CFIndex PSDimensionCalculateSizeFromDimensionsIgnoreDimensions(CFArrayRef dimensions, PSIndexSetRef ignoredDimensions)
{
    CFIndex size = 1;
    if(dimensions) {
        CFIndex dimensionsCount = CFArrayGetCount(dimensions);
        for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
            if(!PSIndexSetContainsIndex(ignoredDimensions, idim)) {
                PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
                size *= PSDimensionGetNpts(dimension);
            }
        }
    }
    return size;

}


CFIndex PSDimensionMemOffsetFromCoordinateIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,kCFNotFound);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return 0;
    
    PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, dimensionsCount-1);
    CFIndex coordinateIndex = PSIndexArrayGetValueAtIndex(theIndexes, dimensionsCount-1)%theDimension->npts;
    if(coordinateIndex<0) coordinateIndex += theDimension->npts;

    CFIndex memOffset = coordinateIndex;
    for(CFIndex idim = dimensionsCount-2;idim >= 0; idim--) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, idim);
        memOffset *= theDimension->npts;
        CFIndex coordinateIndex = PSIndexArrayGetValueAtIndex(theIndexes, idim)%theDimension->npts;
        if(coordinateIndex<0) coordinateIndex += theDimension->npts;

        memOffset += coordinateIndex;
    }
    return memOffset;
}

CFIndex PSDimensionGetCoordinateIndexFromMemOffset(CFArrayRef dimensions, CFIndex memOffset, CFIndex dimensionIndex)
{
    CFIndex hyperVolume = 1;
    for(CFIndex idim = 0; idim<=dimensionIndex; idim++) {
        PSDimensionRef theDimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        CFIndex coordinateIndex = (memOffset/hyperVolume)%(theDimension->npts);
        if(idim==dimensionIndex) return coordinateIndex;
        hyperVolume *= theDimension->npts;
    }
    return kCFNotFound;
}

PSMutableIndexArrayRef PSDimensionCreateCoordinateIndexesFromMemOffset(CFArrayRef dimensions, CFIndex memOffset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return NULL;
    
    PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutable(dimensionsCount);
    CFIndex hyperVolume = 1;
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef theDimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        CFIndex coordinateIndex = (memOffset/hyperVolume)%(theDimension->npts);
        PSIndexArraySetValueAtIndex(indexValues, idim, coordinateIndex);
        hyperVolume *= theDimension->npts;
    }
    return indexValues;
}

CFArrayRef PSDimensionCreateDimensionlessCoordinatesFromIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return nil;
    
    CFMutableArrayRef coordinateValues = CFArrayCreateMutable(kCFAllocatorDefault, sizeof(PSScalarRef)*dimensionsCount,&kCFTypeArrayCallBacks);
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        PSScalarRef coordinate = PSDimensionCreateDimensionlessCoordinateFromIndex(dimension, PSIndexArrayGetValueAtIndex(theIndexes, idim));
        CFArrayAppendValue(coordinateValues, coordinate);
        CFRelease(coordinate);
    }
    return coordinateValues;
}

CFArrayRef PSDimensionCreateRelativeCoordinatesFromIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes)
{
  	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return nil;
    
    CFMutableArrayRef coordinateValues = CFArrayCreateMutable(kCFAllocatorDefault, sizeof(PSScalarRef)*dimensionsCount,&kCFTypeArrayCallBacks);
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        PSScalarRef coordinate = PSDimensionCreateRelativeCoordinateFromIndex(dimension, PSIndexArrayGetValueAtIndex(theIndexes, idim));
        CFArrayAppendValue(coordinateValues, coordinate);
        CFRelease(coordinate);
    }
    return coordinateValues;
}

CFMutableArrayRef PSDimensionCreateDisplayedCoordinatesFromIndexes(CFArrayRef dimensions, PSIndexArrayRef theIndexes)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return nil;
    
    CFMutableArrayRef coordinateValues = CFArrayCreateMutable(kCFAllocatorDefault, sizeof(PSScalarRef)*dimensionsCount,&kCFTypeArrayCallBacks);
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        PSScalarRef coordinate = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSIndexArrayGetValueAtIndex(theIndexes, idim));
        CFArrayAppendValue(coordinateValues, coordinate);
        CFRelease(coordinate);
    }
    return coordinateValues;
}

PSIndexArrayRef PSDimensionCreateIndexesFromDimensionlessCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(theCoordinates,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return nil;
    
    PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutable(dimensionsCount);
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        PSScalarRef coordinate = (PSScalarRef) CFArrayGetValueAtIndex(theCoordinates, idim);
        PSIndexArraySetValueAtIndex(indexValues, idim, PSDimensionIndexFromDimensionlessCoordinate(dimension, coordinate));
    }
    return indexValues;
}

PSIndexArrayRef PSDimensionCreateIndexesFromRelativeCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(theCoordinates,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return nil;
    
    PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutable(dimensionsCount);
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        PSScalarRef coordinate = (PSScalarRef) CFArrayGetValueAtIndex(theCoordinates, idim);
        PSIndexArraySetValueAtIndex(indexValues, idim, PSDimensionClosestIndexToRelativeCoordinate(dimension, coordinate));
    }
    if(error) if(*error) {
        CFRelease(indexValues);
        return NULL;
    }
    return indexValues;
}

PSIndexArrayRef PSDimensionCreateCoordinateIndexesFromDisplayedCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates)
{
    if(NULL==theCoordinates) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return NULL;
    
    PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutable(dimensionsCount);
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
        PSScalarRef coordinate = (PSScalarRef) CFArrayGetValueAtIndex(theCoordinates, idim);
        CFIndex index = PSDimensionClosestIndexToDisplayedCoordinate(dimension, coordinate);
        PSIndexArraySetValueAtIndex(indexValues, idim, index);
    }
    return indexValues;
}

CFIndex PSDimensionMemOffsetFromDimensionlessCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error)
{
    if(error) if(*error) return kCFNotFound;
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,kCFNotFound);
   	IF_NO_OBJECT_EXISTS_RETURN(theCoordinates,kCFNotFound);
    // WARNING ** ignores signalCoordinates
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return 0;
    
    PSIndexArrayRef theIndexes = PSDimensionCreateIndexesFromDimensionlessCoordinates(dimensions, theCoordinates, error);
    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
    CFRelease(theIndexes);
    return memOffset;
}

CFIndex PSDimensionMemOffsetFromRelativeCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates, CFErrorRef *error)
{
    if(error) if(*error) return kCFNotFound;
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,kCFNotFound);
   	IF_NO_OBJECT_EXISTS_RETURN(theCoordinates,kCFNotFound);
    // WARNING ** ignores signalCoordinates
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return 0;
    
    PSIndexArrayRef theIndexes = PSDimensionCreateIndexesFromRelativeCoordinates(dimensions, theCoordinates, error);
    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
    CFRelease(theIndexes);
    return memOffset;
}

CFIndex PSDimensionMemOffsetFromDisplayedCoordinates(CFArrayRef dimensions, CFArrayRef theCoordinates)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,kCFNotFound);
   	IF_NO_OBJECT_EXISTS_RETURN(theCoordinates,kCFNotFound);
    // WARNING ** ignores signalCoordinates
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return 0;
    
    PSIndexArrayRef theIndexes = PSDimensionCreateCoordinateIndexesFromDisplayedCoordinates(dimensions, theCoordinates);
    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
    CFRelease(theIndexes);
    return memOffset;
}

CFArrayRef PSDimensionCreateDimensionlessCoordinatesFromMemOffset(CFArrayRef dimensions, CFIndex memOffset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return NULL;
    
    PSIndexArrayRef indexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    CFArrayRef array = PSDimensionCreateDimensionlessCoordinatesFromIndexes(dimensions, indexValues);
    CFRelease(indexValues);
    return array;
}

CFArrayRef PSDimensionCreateRelativeCoordinatesFromMemOffset(CFArrayRef dimensions, CFIndex memOffset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return NULL;
    
    PSIndexArrayRef indexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    CFArrayRef array = PSDimensionCreateRelativeCoordinatesFromIndexes(dimensions, indexValues);
    CFRelease(indexValues);
    return array;
}

CFMutableArrayRef PSDimensionCreateDisplayedCoordinatesFromMemOffset(CFArrayRef dimensions,
                                                              CFIndex memOffset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount==0) return NULL;
    
    PSIndexArrayRef indexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    CFMutableArrayRef array = PSDimensionCreateDisplayedCoordinatesFromIndexes(dimensions, indexValues);
    CFRelease(indexValues);
    return array;
}

PSScalarRef PSDimensionCreateDimensionlessCoordinateMinimumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    return PSDimensionCreateDimensionlessCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
}

PSScalarRef PSDimensionCreateRelativeCoordinateMinimumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    return PSDimensionCreateRelativeCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
}

PSScalarRef PSDimensionCreateDisplayedCoordinateMinimumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    return PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
}


PSScalarRef PSDimensionCreateDimensionlessCoordinateMaximumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    return PSDimensionCreateDimensionlessCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
}

PSScalarRef PSDimensionCreateRelativeCoordinateMaximumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    return PSDimensionCreateRelativeCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
}


PSScalarRef PSDimensionCreateDisplayedCoordinateMaximumForDimensionAtIndex(CFArrayRef dimensions, CFIndex dimensionIndex)
{
   	IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    return PSDimensionCreateDisplayedCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
}


@end

