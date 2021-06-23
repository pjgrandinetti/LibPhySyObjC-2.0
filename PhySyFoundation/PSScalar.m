//
//  PSScalar.c
//
//  Created by PhySy Ltd on 12/9/09.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "PhySyFoundation.h"

@implementation PSScalar

- (void) dealloc
{
    [super dealloc];
}

#pragma mark Creators

/*
 @function PSScalarCreate
 @abstract Creates a new PSScalar object
 @param unit a PSUnit object 
 @param elementType possible values are kPSNumberSInt32Type, kPSNumberSInt64Type, kPSNumberFloat32Type, kPSNumberFloat64Type, kPSNumberFloat32ComplexType, and kPSNumberFloat64ComplexType,
 @param value a pointer to the numerical value of the scalar
 @result PSScalar object
 */
static PSScalarRef PSScalarCreate(PSUnitRef unit,  numberType elementType, void *value)
{
   	IF_NO_OBJECT_EXISTS_RETURN(value,NULL);
    // Initialize object
    PSScalar *newScalar = [PSScalar alloc];
    //  setup attributes
    newScalar->elementType = elementType;
    switch (elementType) {
        case kPSNumberFloat32Type: {
            float *ptr = (float *) value;
            newScalar->value.floatValue = *ptr;
            break;
        }
        case kPSNumberFloat64Type: {
            double *ptr = (double *) value;
            newScalar->value.doubleValue = *ptr;
            break;
        }
        case kPSNumberFloat32ComplexType: {
            float complex *ptr = (float complex *) value;
            newScalar->value.floatComplexValue = *ptr;
            break;
        }
        case kPSNumberFloat64ComplexType: {
            double complex *ptr = (double complex *) value;
            newScalar->value.doubleComplexValue = *ptr;
            break;
        }
    }
    if(unit) newScalar->unit = unit;
    else newScalar->unit = PSUnitDimensionlessAndUnderived();
    return (PSScalarRef) newScalar;
}

static PSMutableScalarRef PSScalarCreateMutable(PSUnitRef unit,  numberType elementType, void *value)
{
    return (PSMutableScalarRef) PSScalarCreate(unit, elementType, value);
}

/*
 @function PSScalarCreateCopy
 @abstract Creates a copy of a scalar 
 @param theScalar The scalar.
 @result a copy of the scalar.
 */
PSScalarRef PSScalarCreateCopy(PSScalarRef theScalar)
{	
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
	return PSScalarCreate(theScalar->unit, theScalar->elementType, (void *) &theScalar->value);
}

PSMutableScalarRef PSScalarCreateMutableCopy(PSScalarRef theScalar)
{	
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
	return PSScalarCreateMutable(theScalar->unit,theScalar->elementType,(void *) &theScalar->value);
}

PSScalarRef PSScalarCreateWithFloat(float input_value, PSUnitRef unit)
{
    return PSScalarCreate(unit, kPSNumberFloat32Type, &input_value);
}

PSMutableScalarRef PSScalarCreateMutableWithFloat(float input_value, PSUnitRef unit)
{
    return PSScalarCreateMutable(unit, kPSNumberFloat32Type, &input_value);
}

PSScalarRef PSScalarCreateWithDouble(double input_value, PSUnitRef unit)
{
    return PSScalarCreate(unit, kPSNumberFloat64Type, &input_value);
}

PSMutableScalarRef PSScalarCreateMutableWithDouble(double input_value, PSUnitRef unit)
{
    return PSScalarCreateMutable(unit, kPSNumberFloat64Type, &input_value);
}

PSScalarRef PSScalarCreateWithFloatComplex(float complex input_value, PSUnitRef unit)
{
    return PSScalarCreate(unit, kPSNumberFloat32ComplexType, &input_value);
}

PSMutableScalarRef PSScalarCreateMutableWithFloatComplex(float complex input_value, PSUnitRef unit)
{
    return PSScalarCreateMutable(unit, kPSNumberFloat32ComplexType, &input_value);
}

PSScalarRef PSScalarCreateWithDoubleComplex(double complex input_value, PSUnitRef unit)
{
    return PSScalarCreate(unit, kPSNumberFloat64ComplexType, &input_value);
}

PSMutableScalarRef PSScalarCreateMutableWithDoubleComplex(double complex input_value, PSUnitRef unit)
{
    return PSScalarCreateMutable(unit, kPSNumberFloat64ComplexType, &input_value);
}

#pragma mark Accessors

void PSScalarSetElementType(PSMutableScalarRef theScalar, numberType elementType)
{	
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,);
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type:{
            float value = theScalar->value.floatValue;
            theScalar->elementType = elementType;
            switch (elementType) {
                case kPSNumberFloat32Type:
                    theScalar->value.floatValue = value;
                    return;
                case kPSNumberFloat64Type:
                    theScalar->value.doubleValue = value;
                    return;
                case kPSNumberFloat32ComplexType:
                    theScalar->value.floatComplexValue = value;
                    return;
                case kPSNumberFloat64ComplexType:
                    theScalar->value.doubleComplexValue = value;
                    return;
            }
            break;
        }
        case kPSNumberFloat64Type:{
            double value = theScalar->value.doubleValue;
            theScalar->elementType = elementType;
            switch (elementType) {
                case kPSNumberFloat32Type:
                    theScalar->value.floatValue = value;
                    return;
                case kPSNumberFloat64Type:
                    theScalar->value.doubleValue = value;
                    return;
                case kPSNumberFloat32ComplexType:
                    theScalar->value.floatComplexValue = value;
                    return;
                case kPSNumberFloat64ComplexType:
                    theScalar->value.doubleComplexValue = value;
                    return;
            }
            break;
        }
        case kPSNumberFloat32ComplexType:{
            float complex value = theScalar->value.floatComplexValue;
            theScalar->elementType = elementType;
            switch (elementType) {
                case kPSNumberFloat32Type:
                    theScalar->value.floatValue = value;
                    return;
                case kPSNumberFloat64Type:
                    theScalar->value.doubleValue = value;
                    return;
                case kPSNumberFloat32ComplexType:
                    theScalar->value.floatComplexValue = value;
                    return;
                case kPSNumberFloat64ComplexType:
                    theScalar->value.doubleComplexValue = value;
                    return;
            }
            break;
        }
        case kPSNumberFloat64ComplexType:{
            double complex value = theScalar->value.doubleComplexValue;
            theScalar->elementType = elementType;
            switch (elementType) {
                case kPSNumberFloat32Type:
                    theScalar->value.floatValue = value;
                    return;
                case kPSNumberFloat64Type:
                    theScalar->value.doubleValue = value;
                    return;
                case kPSNumberFloat32ComplexType:
                    theScalar->value.floatComplexValue = value;
                    return;
                case kPSNumberFloat64ComplexType:
                    theScalar->value.doubleComplexValue = value;
                    return;
            }
            break;
        }
    }
    
    return;
}

__PSNumber PSScalarGetValue(PSScalarRef theScalar)
{
    return theScalar->value;
}

void PSScalarSetFloatValue(PSMutableScalarRef theScalar, float value)
{
    theScalar->elementType= kPSNumberFloat32Type;
    theScalar->value.floatValue = value;
}

void PSScalarSetDoubleValue(PSMutableScalarRef theScalar, double value)
{
    theScalar->elementType= kPSNumberFloat64Type;
    theScalar->value.doubleValue = value;
}

void PSScalarSetFloatComplexValue(PSMutableScalarRef theScalar, float complex value)
{
    theScalar->elementType= kPSNumberFloat32ComplexType;
    theScalar->value.floatComplexValue = value;
}

void PSScalarSetDoubleComplexValue(PSMutableScalarRef theScalar, double complex value)
{
    theScalar->elementType= kPSNumberFloat64ComplexType;
    theScalar->value.doubleComplexValue = value;
}


float PSScalarFloatValue(PSScalarRef theScalar)
{	
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,0);
	switch (theScalar->elementType) {
		case kPSNumberFloat32Type:
            return (float) theScalar->value.floatValue;
		case kPSNumberFloat64Type: 
            return (float) theScalar->value.doubleValue;
		case kPSNumberFloat32ComplexType: 
            return (float) theScalar->value.floatComplexValue;
		case kPSNumberFloat64ComplexType: 
            return (float) theScalar->value.doubleComplexValue;
	}
	return nan(NULL);
}

double PSScalarDoubleValue(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,0);
	switch (theScalar->elementType) {
		case kPSNumberFloat32Type:
            return (double) theScalar->value.floatValue;
		case kPSNumberFloat64Type: 
            return (double) theScalar->value.doubleValue;
		case kPSNumberFloat32ComplexType: 
            return (double) theScalar->value.floatComplexValue;
		case kPSNumberFloat64ComplexType: 
            return (double) theScalar->value.doubleComplexValue;
	}
	return nan(NULL);
}

float complex PSScalarFloatComplexValue(PSScalarRef theScalar)
{	
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,0);
	switch (theScalar->elementType) {
		case kPSNumberFloat32Type:
            return (float complex) theScalar->value.floatValue;
		case kPSNumberFloat64Type: 
            return (float complex) theScalar->value.doubleValue;
		case kPSNumberFloat32ComplexType:
            return (float complex) theScalar->value.floatComplexValue;
		case kPSNumberFloat64ComplexType: 
            return (float complex) theScalar->value.doubleComplexValue;
	}
	return nan(NULL);
}

double complex PSScalarDoubleComplexValue(PSScalarRef theScalar)
{	
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,0);
	switch (theScalar->elementType) {
		case kPSNumberFloat32Type:
            return (double complex) theScalar->value.floatValue;
		case kPSNumberFloat64Type: 
            return (double complex) theScalar->value.doubleValue;
		case kPSNumberFloat32ComplexType:
            return (double complex) theScalar->value.floatComplexValue;
		case kPSNumberFloat64ComplexType: 
            return (double complex) theScalar->value.doubleComplexValue;
	}
	return nan(NULL);
}

double PSScalarMagnitudeValue(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,0);
    double complex value = PSScalarDoubleComplexValue(theScalar);
    return cabs(value);
}

double PSScalarArgumentValue(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,0);
    double complex value = PSScalarDoubleComplexValue(theScalar);
    return cargument(value);
}

float PSScalarFloatValueInCoherentUnit(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,nan(NULL));
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnitWithDimensionality(PSUnitGetDimensionality(theScalar->unit));
    double conversion = PSUnitConversion(theScalar->unit,coherentUnit);
    
    switch(theScalar->elementType) {
//        case kPSNumberSInt32Type: {
//            return theScalar->value.int32Value*conversion;
//        }
//        case kPSNumberSInt64Type: {
//            return theScalar->value.int64Value*conversion;
//        }
		case kPSNumberFloat32Type: {
            return theScalar->value.floatValue*conversion;
        }
		case kPSNumberFloat64Type: {
            return theScalar->value.doubleValue*conversion;
        }
		case kPSNumberFloat32ComplexType: {
            return theScalar->value.floatComplexValue*conversion;
        }
		case kPSNumberFloat64ComplexType: {
            return theScalar->value.doubleComplexValue*conversion;
        }
	}
}

double PSScalarDoubleValueInCoherentUnit(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,nan(NULL));
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnitWithDimensionality(PSUnitGetDimensionality(theScalar->unit));
    double conversion = PSUnitConversion(theScalar->unit,coherentUnit);

    switch(theScalar->elementType) {
		case kPSNumberFloat32Type: {
            return theScalar->value.floatValue*conversion;
        }
		case kPSNumberFloat64Type: {
            return theScalar->value.doubleValue*conversion;
        }
		case kPSNumberFloat32ComplexType: {
            return theScalar->value.floatComplexValue*conversion;
        }
		case kPSNumberFloat64ComplexType: {
            return theScalar->value.doubleComplexValue*conversion;
        }
	}
}

float complex PSScalarFloatComplexValueInCoherentUnit(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,nan(NULL));
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnitWithDimensionality(PSUnitGetDimensionality(theScalar->unit));
    double conversion = PSUnitConversion(theScalar->unit,coherentUnit);
    
    switch(theScalar->elementType) {
//        case kPSNumberSInt32Type: {
//            return theScalar->value.int32Value*conversion;
//        }
//        case kPSNumberSInt64Type: {
//            return theScalar->value.int64Value*conversion;
//        }
		case kPSNumberFloat32Type: {
            return theScalar->value.floatValue*conversion;
        }
		case kPSNumberFloat64Type: {
            return theScalar->value.doubleValue*conversion;
        }
		case kPSNumberFloat32ComplexType: {
            return theScalar->value.floatComplexValue*conversion;
        }
		case kPSNumberFloat64ComplexType: {
            return theScalar->value.doubleComplexValue*conversion;
        }
	}
}

double complex PSScalarDoubleComplexValueInCoherentUnit(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,nan(NULL));
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnitWithDimensionality(PSUnitGetDimensionality(theScalar->unit));
    double conversion = PSUnitConversion(theScalar->unit,coherentUnit);
    
    switch(theScalar->elementType) {
//        case kPSNumberSInt32Type: {
//            return theScalar->value.int32Value*conversion;
//        }
//        case kPSNumberSInt64Type: {
//            return theScalar->value.int64Value*conversion;
//        }
		case kPSNumberFloat32Type: {
            return theScalar->value.floatValue*conversion;
        }
		case kPSNumberFloat64Type: {
            return theScalar->value.doubleValue*conversion;
        }
		case kPSNumberFloat32ComplexType: {
            return theScalar->value.floatComplexValue*conversion;
        }
		case kPSNumberFloat64ComplexType: {
            return theScalar->value.doubleComplexValue*conversion;
        }
	}
}

float PSScalarFloatValueInUnit(PSScalarRef theScalar, PSUnitRef unit, bool *success)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,nan(NULL));
    if(PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar),PSUnitGetDimensionality(unit))) {
        double conversion = PSUnitConversion(theScalar->unit,unit);
        switch(theScalar->elementType) {
            case kPSNumberFloat32Type: {
                return theScalar->value.floatValue*conversion;
            }
            case kPSNumberFloat64Type: {
                return theScalar->value.doubleValue*conversion;
            }
            case kPSNumberFloat32ComplexType: {
                return theScalar->value.floatComplexValue*conversion;
            }
            case kPSNumberFloat64ComplexType: {
                return theScalar->value.doubleComplexValue*conversion;
            }
        }
    }
    if(success) *success *= false;
    return nan(NULL);
}

double PSScalarDoubleValueInUnit(PSScalarRef theScalar, PSUnitRef unit, bool *success)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,nan(NULL));
    if(PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar),PSUnitGetDimensionality(unit))) {
        double conversion = PSUnitConversion(theScalar->unit,unit);
        switch(theScalar->elementType) {
            case kPSNumberFloat32Type: {
                return theScalar->value.floatValue*conversion;
            }
            case kPSNumberFloat64Type: {
                return theScalar->value.doubleValue*conversion;
            }
            case kPSNumberFloat32ComplexType: {
                return theScalar->value.floatComplexValue*conversion;
            }
            case kPSNumberFloat64ComplexType: {
                return theScalar->value.doubleComplexValue*conversion;
            }
        }
    }
    if(success) *success *= false;
    return nan(NULL);
}

float complex PSScalarFloatComplexValueInUnit(PSScalarRef theScalar, PSUnitRef unit, bool *success)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,nan(NULL));
    if(PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar),PSUnitGetDimensionality(unit))) {
        double conversion = PSUnitConversion(theScalar->unit,unit);
        switch(theScalar->elementType) {
//            case kPSNumberSInt32Type: {
//                return theScalar->value.int32Value*conversion;
//            }
//            case kPSNumberSInt64Type: {
//                return theScalar->value.int64Value*conversion;
//            }
            case kPSNumberFloat32Type: {
                return theScalar->value.floatValue*conversion;
            }
            case kPSNumberFloat64Type: {
                return theScalar->value.doubleValue*conversion;
            }
            case kPSNumberFloat32ComplexType: {
                return theScalar->value.floatComplexValue*conversion;
            }
            case kPSNumberFloat64ComplexType: {
                return theScalar->value.doubleComplexValue*conversion;
            }
        }
    }
    if(success) *success *= false;
    return nan(NULL);
}

double complex PSScalarDoubleComplexValueInUnit(PSScalarRef theScalar, PSUnitRef unit, bool *success)
{
    if(NULL==theScalar) {
        *success = false;
        return nan(NULL);
    }
    if(PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar),PSUnitGetDimensionality(unit))) {
        double conversion = PSUnitConversion(theScalar->unit,unit);
        switch(theScalar->elementType) {
            case kPSNumberFloat32Type: {
                return theScalar->value.floatValue*conversion;
            }
            case kPSNumberFloat64Type: {
                return theScalar->value.doubleValue*conversion;
            }
            case kPSNumberFloat32ComplexType: {
                return theScalar->value.floatComplexValue*conversion;
            }
            case kPSNumberFloat64ComplexType: {
                return theScalar->value.doubleComplexValue*conversion;
            }
        }
    }
    if(success) *success *= false;
    return nan(NULL);
}

#pragma mark Operations

PSScalarRef PSScalarCreateByConvertingToNumberType(PSScalarRef theScalar, numberType elementType)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
	PSScalarRef result = PSScalarCreateCopy(theScalar);
    PSScalarSetElementType((PSMutableScalarRef) result, elementType);
    return result;
}

bool PSScalarTakeComplexPart(PSMutableScalarRef theScalar, complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
	switch (theScalar->elementType) {
		case kPSNumberFloat32Type:{
            if(part == kPSImaginaryPart || part == kPSArgumentPart) {
                theScalar->value.floatValue = 0;
                return true;
            }
            if(part == kPSMagnitudePart) {
                theScalar->value.floatValue = fabsf(theScalar->value.floatValue);
                return true;
            }
            if(part == kPSRealPart) return true;
            break;
        }
		case kPSNumberFloat64Type: {
            if(part == kPSImaginaryPart || part == kPSArgumentPart) {
                theScalar->value.doubleValue = 0;
                return true;
            }
            if(part == kPSMagnitudePart) {
                theScalar->value.doubleValue = fabs(theScalar->value.doubleValue);
                return true;
            }
            if(part == kPSRealPart) return true;
            break;
        }
		case kPSNumberFloat32ComplexType: {
            if(part == kPSRealPart) {
                theScalar->value.floatValue = creal(theScalar->value.floatComplexValue);
                theScalar->elementType = kPSNumberFloat32Type;
                return true;
            }
            if(part == kPSImaginaryPart) {
                theScalar->value.floatValue = cimag(theScalar->value.floatComplexValue);
                theScalar->elementType = kPSNumberFloat32Type;
                return true;
            }
            if(part == kPSArgumentPart) {
                theScalar->value.floatValue = cargument(theScalar->value.floatComplexValue);
                theScalar->elementType = kPSNumberFloat32Type;
                theScalar->unit = PSUnitForSymbol(CFSTR("rad"));
                return true;
            }
            if(part == kPSMagnitudePart) {
                theScalar->value.floatValue = cabs(theScalar->value.floatComplexValue);
                theScalar->elementType = kPSNumberFloat32Type;
                return true;
            }
            break;
        }
		case kPSNumberFloat64ComplexType: {
            if(part == kPSRealPart) {
                theScalar->value.doubleValue = creal(theScalar->value.doubleComplexValue);
                theScalar->elementType = kPSNumberFloat64Type;
                return true;
            }
            if(part == kPSImaginaryPart) {
                theScalar->value.doubleValue = cimag(theScalar->value.doubleComplexValue);
                theScalar->elementType = kPSNumberFloat64Type;
                return true;
            }
            if(part == kPSArgumentPart) {
                theScalar->value.doubleValue = cargument(theScalar->value.doubleComplexValue);
                theScalar->elementType = kPSNumberFloat64Type;
                theScalar->unit = PSUnitForSymbol(CFSTR("rad"));
                return true;
            }
            if(part == kPSMagnitudePart) {
                theScalar->value.doubleValue = cabs(theScalar->value.doubleComplexValue);
                theScalar->elementType = kPSNumberFloat64Type;
                return true;
            }
            break;
        }
	}
    return false;
}

PSScalarRef PSScalarCreateByTakingComplexPart(PSScalarRef theScalar, complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
	PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarTakeComplexPart((PSMutableScalarRef) result, part)) return result;
    CFRelease(result);
    return NULL;
}

bool PSScalarReduceUnit(PSMutableScalarRef theScalar)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type:
        {
            double unit_multiplier = 1.0;
            PSUnitRef reducedUnit = PSUnitByReducing(theScalar->unit,&unit_multiplier);
            theScalar->unit = reducedUnit;
            theScalar->value.floatValue = theScalar->value.floatValue*unit_multiplier;
            return true;
        }
        case kPSNumberFloat64Type:
        {
            double unit_multiplier = 1.0;
            PSUnitRef reducedUnit = PSUnitByReducing(theScalar->unit,&unit_multiplier);
            theScalar->unit = reducedUnit;
            theScalar->value.doubleValue = theScalar->value.doubleValue*unit_multiplier;
            return true;
        }
        case kPSNumberFloat32ComplexType:
        {
            double unit_multiplier = 1.0;
            PSUnitRef reducedUnit = PSUnitByReducing(theScalar->unit,&unit_multiplier);
            theScalar->unit = reducedUnit;
            theScalar->value.floatComplexValue = theScalar->value.floatComplexValue*unit_multiplier;
            return true;
        }
        case kPSNumberFloat64ComplexType:
        {
            double unit_multiplier = 1.0;
            PSUnitRef reducedUnit = PSUnitByReducing(theScalar->unit,&unit_multiplier);
            theScalar->unit = reducedUnit;
            theScalar->value.doubleComplexValue = theScalar->value.doubleComplexValue*unit_multiplier;
            return true;
        }
    }
    return false;
}

PSScalarRef PSScalarCreateByReducingUnit(PSScalarRef theScalar)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarReduceUnit((PSMutableScalarRef) result)) return result;
    if(result) CFRelease(result);
    return NULL;
}

bool PSScalarConvertToUnit(PSMutableScalarRef theScalar, PSUnitRef unit, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    if(!PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(theScalar->unit),PSUnitGetDimensionality(unit))) {
        if(error==NULL) return false;
        CFStringRef desc = CFSTR("Convert Unit, Incompatible Dimensionalities.");
        *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                        kPSFoundationErrorDomain,
                                                        0,
                                                        (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                        (const void* const*)&desc,
                                                        1);
        return false;
    }
    double conversion = PSUnitConversion(theScalar->unit,unit);
    theScalar->unit = unit;
    
    switch(theScalar->elementType) {
		case kPSNumberFloat32Type: {
            theScalar->value.floatValue = theScalar->value.floatValue*conversion;
            return true;
        }
		case kPSNumberFloat64Type: {
            theScalar->value.doubleValue = theScalar->value.doubleValue*conversion;
            return true;
        }
		case kPSNumberFloat32ComplexType: {
            theScalar->value.floatComplexValue = theScalar->value.floatComplexValue*conversion;
            return true;
        }
		case kPSNumberFloat64ComplexType: {
            theScalar->value.doubleComplexValue = theScalar->value.doubleComplexValue*conversion;
            return true;
        }

	}
    return false;
}

PSScalarRef PSScalarCreateByConvertingToUnit(PSScalarRef theScalar, PSUnitRef unit, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarConvertToUnit((PSMutableScalarRef) result, unit, error)) return result;
    if(result) CFRelease(result);
    return NULL;
}

bool PSScalarConvertToCoherentUnit(PSMutableScalarRef theScalar, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnitWithDimensionality(PSUnitGetDimensionality(theScalar->unit));
    return PSScalarConvertToUnit(theScalar, coherentUnit, error);
}

PSScalarRef PSScalarCreateByConvertingToCoherentUnit(PSScalarRef theScalar, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarConvertToCoherentUnit((PSMutableScalarRef) result, error)) return result;
    if(result)  CFRelease(result);
    return NULL;
}

bool PSScalarBestConversionForUnit(PSMutableScalarRef theScalar, PSUnitRef theUnit)
{
    if(!PSScalarConvertToUnit(theScalar, theUnit, NULL)) return false;

    CFArrayRef units = PSUnitCreateArrayOfUnitsWithSameRootSymbol(theUnit);
    if(NULL==units) return true;
    PSMutableScalarRef trialScalar = PSScalarCreateMutableCopy(theScalar);
    
    float originalExp = log10(fabs(PSScalarDoubleValue(theScalar)));
    float originalMagnitude = fabs(originalExp);
    float magnitude = originalMagnitude;
    CFIndex bestPositive = 0;
    CFIndex bestNegative = 0;
    for(CFIndex index=0; index<CFArrayGetCount(units); index++) {
        PSUnitRef unit = CFArrayGetValueAtIndex(units, index);
        if(!PSScalarConvertToUnit(trialScalar, unit, NULL)) {
            CFRelease(trialScalar);
            CFRelease(units);
            return false;
        }
        float trialExp = log10(fabs(PSScalarDoubleValue(trialScalar)));
        float trialMagnitude = fabs(trialExp);
        if(trialMagnitude < magnitude) {
            if(trialExp<0) bestNegative = index;
            else bestPositive = index;
            magnitude = trialMagnitude;
        }
    }
    bool result = true;
    if(fabs(originalMagnitude - magnitude)>2.0) {
        result = PSScalarConvertToUnit(theScalar, CFArrayGetValueAtIndex(units, bestPositive), NULL);
    }
    CFRelease(trialScalar);
    CFRelease(units);
    return result;

}

bool PSScalarBestConversionForQuantityName(PSMutableScalarRef theScalar, CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    IF_NO_OBJECT_EXISTS_RETURN(quantityName,false);
    
    CFMutableStringRef quantityNameMutable = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(quantityName), quantityName);
    CFStringFindAndReplace(quantityNameMutable, CFSTR("Dimensionality: "), CFSTR(""), CFRangeMake(0, CFStringGetLength(quantityNameMutable)), 0);
    
    CFArrayRef unitsImmutable = PSUnitCreateArrayOfUnitsForQuantityName(quantityNameMutable);
    if(unitsImmutable==NULL) {
        PSUnitRef unit = PSUnitFindCoherentSIUnitWithDimensionality(PSDimensionalityForQuantityName(quantityNameMutable));
        unitsImmutable = CFArrayCreate(kCFAllocatorDefault, (const void **) &unit, 1, &kCFTypeArrayCallBacks);
    }
    CFMutableArrayRef units = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(unitsImmutable), unitsImmutable);
    CFRelease(unitsImmutable);
    
    if(CFStringCompare(quantityNameMutable, kPSQuantityDimensionless, 0)==kCFCompareEqualTo) {
        PSUnitRef eulerConstant = PSUnitForSymbol(CFSTR("e"));
        PSCFArrayRemoveObjectsIdenticalToObject(units, eulerConstant);
    }
    CFRelease(quantityNameMutable);

    CFMutableArrayRef underivedUnits = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, units);
    for(CFIndex index =CFArrayGetCount(underivedUnits)-1;index>=0;index--) {
        if(PSUnitHasDerivedSymbol(CFArrayGetValueAtIndex(underivedUnits, index))) {
            CFArrayRemoveValueAtIndex(underivedUnits, index);
        }
    }
    if(CFArrayGetCount(underivedUnits)==0) {
        CFRelease(underivedUnits);
        underivedUnits = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, units);
    }
    CFRelease(units);

    // First convert to an appropriate unit for quantity name.
    PSUnitRef currentUnit = PSQuantityGetUnit(theScalar);
    if(!CFArrayContainsValue(underivedUnits, CFRangeMake(0,CFArrayGetCount(underivedUnits)), currentUnit)) {
        PSUnitRef newUnit = CFArrayGetValueAtIndex(underivedUnits, 0);
        PSScalarConvertToUnit(theScalar, newUnit, NULL);
    }

    PSMutableScalarRef trialScalar = PSScalarCreateMutableCopy(theScalar);
    
    if(!PSScalarConvertToUnit(trialScalar, CFArrayGetValueAtIndex(underivedUnits, 0), NULL)) {
        CFRelease(underivedUnits);
        CFRelease(trialScalar);
        return false;
    }
    float originalExp = log10(fabs(PSScalarDoubleValue(theScalar)));
    float originalMagnitude = fabs(originalExp);
    float magnitude = originalMagnitude;
    CFIndex bestPositive = 0;
    for(CFIndex index=0; index<CFArrayGetCount(underivedUnits); index++) {
        PSUnitRef unit = CFArrayGetValueAtIndex(underivedUnits, index);
        if(!PSScalarConvertToUnit(trialScalar, unit, NULL)) {
            CFRelease(trialScalar);
            CFRelease(underivedUnits);
            return false;
        }
        float trialExp = log10(fabs(PSScalarDoubleValue(trialScalar)));
        float trialMagnitude = fabs(trialExp);
        if(trialMagnitude < magnitude) {
            if(trialExp>=-1E-16) bestPositive = index;
            magnitude = trialMagnitude;
        }
    }
    bool result = true;
    if(fabs(originalMagnitude - magnitude)>1.9) {
        result = PSScalarConvertToUnit(theScalar, CFArrayGetValueAtIndex(underivedUnits, bestPositive), NULL);
    }
    CFRelease(trialScalar);
    CFRelease(underivedUnits);
    return result;
}

bool PSScalarAdd(PSMutableScalarRef target, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(target,false);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
	// Rules for addition and subtraction:
	//	- numbers must have the same dimensionality
	//	- returned PSScalar with have elementType of target argument
	//	- returned PSScalar will have unit of the target argument
	
    if(!PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(target->unit),PSUnitGetDimensionality(input2->unit))) {
        if(error) {
            CFStringRef desc = CFSTR("Add, Incompatible Dimensionalities.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return NULL;
    }
    
	switch(input2->elementType) {
		case kPSNumberFloat32Type: {
            float value = PSScalarFloatValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue + value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue + value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue + value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue + value;
                    return true;
                }
            }
        }
		case kPSNumberFloat64Type: {
            double value = PSScalarDoubleValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue + value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue + value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue + value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue + value;
                    return true;
                }
            }
        }
		case kPSNumberFloat32ComplexType: {
            float complex value = PSScalarFloatComplexValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue + value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue + value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue + value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue + value;
                    return true;
                }
            }
        }
		case kPSNumberFloat64ComplexType: {
            double complex value = PSScalarDoubleComplexValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue + value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue + value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue + value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue + value;
                    return true;
                }
            }
        }
	}
	return false;
}

PSScalarRef PSScalarCreateByAdding(PSScalarRef input1, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(input1,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,NULL);
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(input1, PSQuantityBestElementType((PSQuantityRef) input1, (PSQuantityRef) input2));
    if(PSScalarAdd((PSMutableScalarRef) result, input2, error)) return result;
    CFRelease(result);
    return NULL;
}

bool PSScalarSubtract(PSMutableScalarRef target, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(target,false);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
	// Rules for addition and subtraction:
	//	- numbers must have the same dimensionality
	//	- returned PSScalar with have elementType of target argument
	//	- returned PSScalar will have unit of the target argument
	
    if(!PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(target->unit),PSUnitGetDimensionality(input2->unit))) {
        if(error) {
            CFStringRef desc = CFSTR("Sub, Incompatible Dimensionalities.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return NULL;
    }
    
	switch(input2->elementType) {
		case kPSNumberFloat32Type: {
            float value = PSScalarFloatValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue - value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue - value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue - value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue - value;
                    return true;
                }
            }
        }
		case kPSNumberFloat64Type: {
            double value = PSScalarDoubleValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue - value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue - value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue - value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue - value;
                    return true;
                }
            }
        }
		case kPSNumberFloat32ComplexType: {
            float complex value = PSScalarFloatComplexValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue - value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue - value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue - value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue - value;
                    return true;
                }
            }
        }
		case kPSNumberFloat64ComplexType: {
            double complex value = PSScalarDoubleComplexValueInUnit(input2, target->unit, NULL);
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue - value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue - value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue - value;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue =(long double) target->value.doubleComplexValue -  (long double) value;
                    return true;
                }
            }
        }
	}
	return false;
}

PSScalarRef PSScalarCreateBySubtracting(PSScalarRef input1, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(input1,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,NULL);
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(input1, PSQuantityBestElementType((PSQuantityRef) input1, (PSQuantityRef) input2));
    if(PSScalarSubtract((PSMutableScalarRef) result, input2, error)) return result;
    CFRelease(result);
    return NULL;
}

bool PSScalarMultiplyWithoutReducingUnit(PSMutableScalarRef target, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
  	IF_NO_OBJECT_EXISTS_RETURN(target,false);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
	
	double unit_multiplier = 1;
    PSUnitRef unit = PSUnitByMultiplyingWithoutReducing(target->unit, input2->unit, &unit_multiplier, error);
	target->unit = unit;
    
    if((target->elementType==kPSNumberFloat32ComplexType||
        target->elementType==kPSNumberFloat64ComplexType)
       && PSScalarIsReal(target))
        PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);

	switch(input2->elementType) {
		case kPSNumberFloat32Type: {
            float value = input2->value.floatValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    return true;
                }
            }
        }
		case kPSNumberFloat64Type: {
            double value = input2->value.doubleValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    return true;
                }
            }
        }
		case kPSNumberFloat32ComplexType: {
            float complex value = input2->value.floatComplexValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                    
            }
        }
		case kPSNumberFloat64ComplexType: {
            double complex value = input2->value.doubleComplexValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
	}
	return false;
}

PSScalarRef PSScalarCreateByMultiplyingWithoutReducingUnit(PSScalarRef input1, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(input1, PSQuantityBestElementType((PSQuantityRef) input1, (PSQuantityRef) input2));
    PSScalarMultiplyWithoutReducingUnit((PSMutableScalarRef) result, input2, error);
    return result;
}

bool PSScalarMultiply(PSMutableScalarRef target, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(target,false);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
	
	double unit_multiplier = 1;
	PSUnitRef unit = PSUnitByMultiplying(target->unit, input2->unit, &unit_multiplier, error);
	target->unit = unit;
    
    if((target->elementType==kPSNumberFloat32ComplexType||
        target->elementType==kPSNumberFloat64ComplexType)
       && PSScalarIsReal(target))
        PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);

	switch(input2->elementType) {
		case kPSNumberFloat32Type: {
            float value = input2->value.floatValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat64Type: {
            float value = input2->value.doubleValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat32ComplexType: {
            float value = input2->value.floatComplexValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat64ComplexType: {
            float value = input2->value.doubleComplexValue;
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * value*unit_multiplier;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * value*unit_multiplier;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
	}
	return false;
}

PSScalarRef PSScalarCreateByMultiplying(PSScalarRef input1, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(input1,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,NULL);
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(input1, PSQuantityBestElementType((PSQuantityRef) input1, (PSQuantityRef) input2));
    PSScalarMultiply((PSMutableScalarRef) result, input2, error);
    return result;
}

bool PSScalarDivideWithoutReducingUnit(PSMutableScalarRef target, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(target,false);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
	
	double unit_multiplier = 1;
    PSUnitRef unit = PSUnitByDividingWithoutReducing(target->unit, input2->unit, &unit_multiplier);
	target->unit = unit;
    
    if((target->elementType==kPSNumberFloat32ComplexType||
        target->elementType==kPSNumberFloat64ComplexType)
       && PSScalarIsReal(target))
        PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);

	switch(input2->elementType) {
		case kPSNumberFloat32Type: {
            float value = input2->value.floatValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat64Type: {
            double value = input2->value.doubleValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat32ComplexType: {
            float complex value = input2->value.floatComplexValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat64ComplexType: {
            double complex value = input2->value.doubleComplexValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue* unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue* unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
	}
	return false;
}

bool PSScalarDivide(PSMutableScalarRef target, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return false;
    if(NULL==target) {
        IF_NO_OBJECT_EXISTS_RETURN(target,false);
        
    }
    if(NULL==input2) {
        IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    }
	
	double unit_multiplier = 1;
    PSUnitRef unit = PSUnitByDividing(target->unit, input2->unit, &unit_multiplier);
	target->unit = unit;
    
    if((target->elementType==kPSNumberFloat32ComplexType||
        target->elementType==kPSNumberFloat64ComplexType)
       && PSScalarIsReal(target))
        PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);

	switch(input2->elementType) {
		case kPSNumberFloat32Type: {
            float value = input2->value.floatValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat64Type: {
            double value = input2->value.doubleValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat32ComplexType: {
            float complex value = input2->value.floatComplexValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
		case kPSNumberFloat64ComplexType: {
            double complex value = input2->value.doubleComplexValue;
            if(value==0) {
                if(error==NULL) return false;
                CFStringRef desc = CFSTR("Division by zero.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
                return false;
            }
            switch (target->elementType) {
                case kPSNumberFloat32Type: {
                    target->value.floatValue = target->value.floatValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat64Type: {
                    target->value.doubleValue = target->value.doubleValue * unit_multiplier/value;
                    return true;
                }
                case kPSNumberFloat32ComplexType: {
                    target->value.floatComplexValue = target->value.floatComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
                case kPSNumberFloat64ComplexType: {
                    target->value.doubleComplexValue = target->value.doubleComplexValue * unit_multiplier/value;
                    if(PSScalarIsReal(target)) PSScalarTakeComplexPart((PSMutableScalarRef) target,kPSRealPart);
                    return true;
                }
            }
        }
	}
	return false;
}

PSScalarRef PSScalarCreateByDividingWithoutReducingUnit(PSScalarRef input1, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(input1,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,NULL);
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(input1, PSQuantityBestElementType((PSQuantityRef) input1, (PSQuantityRef) input2));
    if(PSScalarDivideWithoutReducingUnit((PSMutableScalarRef) result, input2, error)) return result;
    CFRelease(result);
    return NULL;
}

PSScalarRef PSScalarCreateByDividing(PSScalarRef input1, PSScalarRef input2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(input1,NULL);
   	IF_NO_OBJECT_EXISTS_RETURN(input2,NULL);
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(input1, PSQuantityBestElementType((PSQuantityRef) input1, (PSQuantityRef) input2));
    if(PSScalarDivide((PSMutableScalarRef) result, input2, error)) return result;
    CFRelease(result);
    return NULL;
}

bool PSScalarRaiseToAPowerWithoutReducingUnit(PSMutableScalarRef theScalar, double power, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
	double unit_multiplier = 1;
	PSUnitRef unit = PSUnitByRaisingToAPowerWithoutReducing(theScalar->unit, power, &unit_multiplier, error);
    if(error) {
        if(*error) return false;
    }
   	IF_NO_OBJECT_EXISTS_RETURN(unit,false);
    if((theScalar->elementType==kPSNumberFloat32ComplexType||
       theScalar->elementType==kPSNumberFloat64ComplexType)
       && PSScalarIsReal(theScalar))
        PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
    
    theScalar->unit = unit;
    switch(theScalar->elementType) {
		case kPSNumberFloat32Type:
            theScalar->value.floatValue = pow(theScalar->value.floatValue,power)*unit_multiplier;
            return true;
		case kPSNumberFloat64Type:             
            theScalar->value.doubleValue = pow(theScalar->value.doubleValue,power)*unit_multiplier;
            return true;
		case kPSNumberFloat32ComplexType:
            theScalar->value.floatComplexValue = cpow(theScalar->value.floatComplexValue,power)*unit_multiplier;
            return true;
		case kPSNumberFloat64ComplexType:
            theScalar->value.doubleComplexValue = cpow(theScalar->value.doubleComplexValue,power)*unit_multiplier;
            return true;
	}
    return false;
}

PSScalarRef PSScalarCreateByRaisingToAPowerWithoutReducingUnit(PSScalarRef theScalar, double power, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarRaiseToAPowerWithoutReducingUnit((PSMutableScalarRef) result, power, error)) return result;
    if(result) CFRelease(result);
    return NULL;
}

bool PSScalarRaiseToAPower(PSMutableScalarRef theScalar, double power, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
	
	// Rules for multiplication and division:
	//	- returned PSScalar with have whichever elementType is greatest of two method arguments
	//	- returned PSScalar unit will be in coherent SI units
	
	double unit_multiplier = 1;
	PSUnitRef unit = PSUnitByRaisingToAPower(theScalar->unit, power, &unit_multiplier, error);
    if(error) {
        if(*error) return false;
    }
    
    if((theScalar->elementType==kPSNumberFloat32ComplexType||
        theScalar->elementType==kPSNumberFloat64ComplexType)
       && PSScalarIsReal(theScalar))
        PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);

    theScalar->unit = unit;
    switch(theScalar->elementType) {
		case kPSNumberFloat32Type:
            theScalar->value.floatValue = pow(theScalar->value.floatValue,power)*unit_multiplier;
            return true;
		case kPSNumberFloat64Type:             
            theScalar->value.doubleValue = pow(theScalar->value.doubleValue,power)*unit_multiplier;
            return true;
		case kPSNumberFloat32ComplexType:
            theScalar->value.floatComplexValue = cpow(theScalar->value.floatComplexValue,power)*unit_multiplier;
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            return true;
		case kPSNumberFloat64ComplexType:
            theScalar->value.doubleComplexValue = cpow(theScalar->value.doubleComplexValue,power)*unit_multiplier;
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            return true;
	}
    return false;
}

PSScalarRef PSScalarCreateByRaisingToAPower(PSScalarRef theScalar, double power, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarRaiseToAPower((PSMutableScalarRef) result, power, error)) return result;
    if(result) CFRelease(result);
    return NULL;
}

bool PSScalarTakeAbsoluteValue(PSMutableScalarRef theScalar, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
	
    if((theScalar->elementType==kPSNumberFloat32ComplexType||
        theScalar->elementType==kPSNumberFloat64ComplexType)
       && PSScalarIsReal(theScalar))
        PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);

    switch(theScalar->elementType) {
		case kPSNumberFloat32Type:
            theScalar->value.floatValue = fabsf(theScalar->value.floatValue);
            return true;
		case kPSNumberFloat64Type:
            theScalar->value.doubleValue = fabs(theScalar->value.doubleValue);
            return true;
		case kPSNumberFloat32ComplexType:
            theScalar->value.floatComplexValue = cabsf(theScalar->value.floatComplexValue);
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            return true;
		case kPSNumberFloat64ComplexType:
            theScalar->value.doubleComplexValue = cabs(theScalar->value.doubleComplexValue);
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            return true;
	}
    return false;
}

PSScalarRef PSScalarCreateByTakingAbsoluteValue(PSScalarRef theScalar, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarTakeAbsoluteValue((PSMutableScalarRef) result, error)) return result;
    if(result) CFRelease(result);
    return NULL;
}

PSScalarRef PSScalarCreateByGammaFunctionWithoutReducingUnit(PSScalarRef theScalar, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(PSScalarIsComplex(theScalar)) {
        if(error) {
            CFStringRef desc = CFSTR("Gamma function of complex number not implemented.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return NULL;
    }

    if(PSUnitIsDimensionless(theScalar->unit)) {
        PSMutableScalarRef temp = PSScalarCreateMutableCopy(theScalar);
        PSScalarReduceUnit(temp);
        double argument = PSScalarDoubleValue(temp)+1;
        double result = tgamma(argument);
        CFRelease(temp);
        return PSScalarCreate(PSUnitDimensionlessAndUnderived(), kPSNumberFloat64Type, &result);
    }
    else if(PSScalarIsRealNonNegativeInteger(theScalar)) {
        CFIndex integerValue = (CFIndex) PSScalarDoubleValue(theScalar);
        double unit_multiplier = 1;
        PSUnitRef newUnit = PSUnitByRaisingToAPower(theScalar->unit, integerValue, &unit_multiplier, error);
        double argument = PSScalarDoubleValue(theScalar)+1;
        double result = tgamma(argument);
        return PSScalarCreate(newUnit, kPSNumberFloat64Type, &result);
    }
    return NULL;
}

bool PSScalarMultiplyByDimensionlessRealConstant(PSMutableScalarRef theScalar, double constant)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
	switch(theScalar->elementType) {
		case kPSNumberFloat32Type:
            theScalar->value.floatValue *= constant;
            return true;
		case kPSNumberFloat64Type: 
            theScalar->value.doubleValue *= constant;
            return true;
		case kPSNumberFloat32ComplexType:
            theScalar->value.floatComplexValue *= constant;
            return true;
		case kPSNumberFloat64ComplexType: 
            theScalar->value.doubleComplexValue *= constant;
            return true;
	}
    return false;
}

PSScalarRef PSScalarCreateByMultiplyingByDimensionlessRealConstant(PSScalarRef theScalar, double constant)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    numberType elementType = kPSNumberFloat64Type;
    if(elementType<theScalar->elementType) elementType = theScalar->elementType;
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(theScalar, elementType);
    if(PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) result, constant)) return result;
    if(result) CFRelease(result);
    return NULL;
}

bool PSScalarMultiplyByDimensionlessComplexConstant(PSMutableScalarRef theScalar, double complex constant)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    
    
    // PSScalar elementType remains the same after multiplication, so information is loss
	switch(theScalar->elementType) {
		case kPSNumberFloat32Type:
            theScalar->value.floatValue = theScalar->value.floatValue * constant;
            return true;
		case kPSNumberFloat64Type: 
            theScalar->value.doubleValue = theScalar->value.doubleValue * constant;
            return true;
		case kPSNumberFloat32ComplexType:
            theScalar->value.floatComplexValue = theScalar->value.floatComplexValue * constant;
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            return true;
		case kPSNumberFloat64ComplexType: 
            theScalar->value.doubleComplexValue = theScalar->value.doubleComplexValue * constant;
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            return true;
	}
    return false;
}

PSScalarRef PSScalarCreateByMultiplyingByDimensionlessComplexConstant(PSScalarRef theScalar, double complex constant)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateByConvertingToNumberType(theScalar, kPSNumberFloat64ComplexType);
    if(PSScalarMultiplyByDimensionlessComplexConstant((PSMutableScalarRef) result, constant)) return result;
    if(result) CFRelease(result);
    return NULL;
}

bool PSScalarConjugate(PSMutableScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
	switch(theScalar->elementType) {
		case kPSNumberFloat32Type:
		case kPSNumberFloat64Type: 
            return true;
		case kPSNumberFloat32ComplexType: {
            theScalar->value.floatComplexValue = creal(theScalar->value.floatComplexValue) - I*cimag(theScalar->value.floatComplexValue);
            return true;
        }
		case kPSNumberFloat64ComplexType: 
            theScalar->value.doubleComplexValue = creal(theScalar->value.doubleComplexValue) - I*cimag(theScalar->value.doubleComplexValue);
            return true;
	}
	return false;
}

PSScalarRef PSScalarCreateByConjugation(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarConjugate((PSMutableScalarRef) result)) return result;
    if(result) CFRelease(result);
    return NULL;
}

bool PSScalarTakeNthRoot(PSMutableScalarRef theScalar, uint8_t root, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);

    double multiplier = 1;
    PSUnitRef newUnit = PSUnitByTakingNthRoot(theScalar->unit, root, &multiplier, error);
    if(error) {
        if(*error) return false;
    }
    theScalar->unit = newUnit;
	switch(theScalar->elementType) {
		case kPSNumberFloat32Type:
            if(root==2) theScalar->value.floatValue = sqrtf(theScalar->value.floatValue)*multiplier;
            else theScalar->value.floatValue = pow(theScalar->value.floatValue,1./root)*multiplier;
            break;
		case kPSNumberFloat64Type:
            if(root==2) theScalar->value.doubleValue = sqrt(theScalar->value.doubleValue)*multiplier;
            else theScalar->value.doubleValue = pow(theScalar->value.doubleValue,1./root)*multiplier;
            break;
		case kPSNumberFloat32ComplexType:
            if(root==2) theScalar->value.floatComplexValue = csqrtf(theScalar->value.floatComplexValue)*multiplier;
            else theScalar->value.floatComplexValue = cpow(theScalar->value.floatComplexValue,1./root)*multiplier;
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            break;
		case kPSNumberFloat64ComplexType:
            if(root==2) theScalar->value.doubleComplexValue = csqrt(theScalar->value.doubleComplexValue)*multiplier;
            else theScalar->value.doubleComplexValue = cpow(theScalar->value.doubleComplexValue,1./root)*multiplier;
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            break;
	}
	return true;
}

PSScalarRef PSScalarCreateByTakingNthRoot(PSScalarRef theScalar, uint8_t root, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarTakeNthRoot((PSMutableScalarRef) result, root, error)) return result;
    if(result) CFRelease(result);
    return NULL;
}


bool PSScalarTakeLog10(PSMutableScalarRef theScalar, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality(theScalar))) {
        if(error) {
            CFStringRef desc = CFSTR("Log10 requires dimensionless unit.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
    }
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type: {
            theScalar->value.floatValue = log10f(theScalar->value.floatValue);
            break;
        }
        case kPSNumberFloat64Type:{
            theScalar->value.doubleValue = log10(theScalar->value.doubleValue);
            break;
        }
        case kPSNumberFloat32ComplexType: {
            theScalar->value.floatComplexValue = clogf(theScalar->value.floatComplexValue)/logf(10);
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            break;
        }
        case kPSNumberFloat64ComplexType: {
            theScalar->value.doubleComplexValue = clog(theScalar->value.doubleComplexValue)/log(10);
            if(PSScalarIsReal(theScalar)) PSScalarTakeComplexPart((PSMutableScalarRef) theScalar,kPSRealPart);
            break;
        }
    }
    return true;
}


bool PSScalarZeroPart(PSMutableScalarRef theScalar, complexPart part)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
	switch (theScalar->elementType) {
		case kPSNumberFloat32Type:
            if(part == kPSRealPart || part == kPSMagnitudePart) {
                theScalar->value.floatValue = 0;
                return true;
            }
            if(part == kPSImaginaryPart || part == kPSArgumentPart) return true;
            break;
		case kPSNumberFloat64Type: 
            if(part == kPSRealPart || part == kPSMagnitudePart) {
                theScalar->value.doubleValue = 0;
                return true;
            }
            if(part == kPSImaginaryPart || part == kPSArgumentPart) return true;
            break;
		case kPSNumberFloat32ComplexType: {
            if(part == kPSMagnitudePart) {
                theScalar->value.floatComplexValue = 0;
                return true;
            }
            if(part == kPSRealPart) {
                theScalar->value.floatComplexValue = cimag(theScalar->value.floatComplexValue);
                return true;
            }
            if(part == kPSImaginaryPart) {
                theScalar->value.floatComplexValue = creal(theScalar->value.floatComplexValue);
                return true;
            }
            if(part == kPSArgumentPart) {
                theScalar->value.floatComplexValue = cabs(theScalar->value.floatComplexValue);
                return true;
            }
            break;
        }
		case kPSNumberFloat64ComplexType: {
            if(part == kPSMagnitudePart) {
                theScalar->value.doubleComplexValue = 0;
                return true;
            }
            if(part == kPSRealPart) {
                theScalar->value.doubleComplexValue = cimag(theScalar->value.doubleComplexValue);
                return true;
            }
            if(part == kPSImaginaryPart) {
                theScalar->value.doubleComplexValue = creal(theScalar->value.doubleComplexValue);
                return true;
            }
            if(part == kPSArgumentPart) {
                theScalar->value.doubleComplexValue = cabs(theScalar->value.doubleComplexValue);
                return true;
            }
            break;
        }
	}
    return false;
}

PSScalarRef PSScalarCreateByZeroingPart(PSScalarRef theScalar, complexPart part)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef result = PSScalarCreateCopy(theScalar);
    if(PSScalarZeroPart((PSMutableScalarRef) result, part)) return result;
    CFRelease(result);
    return NULL;
}


static CFStringRef PSScalarCreateStringValueSplitByUnits(PSScalarRef theScalar, CFArrayRef units, bool doubleCheck, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!PSScalarIsReal(theScalar)) return NULL;
    bool isPositive = false;
    if(PSScalarDoubleValue(theScalar) >0.0) isPositive = true;
    
    CFMutableStringRef stringValue = CFStringCreateMutable(kCFAllocatorDefault, 0);
    PSMutableScalarRef scalar = PSScalarCreateMutableCopy(theScalar);
    CFIndex count = CFArrayGetCount(units);
    CFIndex finalCount = 0;
    for(CFIndex index=0;index<count; index++) {
        PSUnitRef unit = CFArrayGetValueAtIndex(units, index);
        CFStringRef symbol = PSUnitCopySymbol(unit);
        PSScalarConvertToUnit(scalar, unit, error);
        double value = PSScalarDoubleValue(scalar);
        if(index<count-1) {
            if(isPositive) {
                value *= 100.;
                value = round(value);
                value /= 100.;
                value = PSDoubleFloor(value);
            }
            else {
                value *= 100.;
                value = round(value);
                value /= 100.;
                value = PSDoubleCeil(value);
            }
        }
        else {
            value *= 100.;
            value = round(value);
            value /= 100.;
        }
        
        if((value > 0.0 && isPositive) || (value < 0.0 && !isPositive)) {
            CFStringRef valueString = PSDoubleComplexCreateStringValueWithFormat(value,NULL);
            finalCount++;
            if(CFStringGetLength(stringValue)>0) {
                if(isPositive) CFStringAppend(stringValue, CFSTR(" + "));
                else CFStringAppend(stringValue, CFSTR(" "));
            }
            CFStringAppend(stringValue, valueString);
            CFStringAppend(stringValue, CFSTR(" "));
            CFStringAppend(stringValue, symbol);
            CFRelease(valueString);
            
            PSScalarRef scalarInUnit = PSScalarCreate(unit, kPSNumberFloat64Type, &value);
            PSScalarSubtract(scalar, scalarInUnit, error);
            CFRelease(scalarInUnit);
        }
        CFRelease(symbol);
    }
    
    if(CFStringGetLength(stringValue) ==0 || finalCount == 1) {
        if(stringValue) CFRelease(stringValue);
        if(scalar) CFRelease(scalar);
        return NULL;
    }
    if(scalar) CFRelease(scalar);
    
    if(doubleCheck) {
        PSScalarRef check = PSScalarCreateWithCFString(stringValue, error);
        if(check) {
            if(PSScalarCompare(theScalar, check)==kPSCompareEqualTo) {
                CFRelease(check);
                return stringValue;
            }
        }
        CFRelease(stringValue);
        return NULL;
    }
    return stringValue;
}

static CFComparisonResult compareOnlyTheStrings(const void *val1, const void *val2, void *context)
{
    CFTypeID type1 = CFGetTypeID((CFTypeRef) val1);
    CFTypeID type2 = CFGetTypeID((CFTypeRef) val2);
    CFTypeID stringType = CFStringGetTypeID();
    
    if(type1==type2) {
        if(type1 == stringType)  {
            return CFStringCompare((CFStringRef) val1, (CFStringRef) val2, (CFStringCompareFlags) context);
        }
    }
    return kCFCompareLessThan;
}


CFArrayRef PSScalarCreateArrayOfConversionQuantitiesScalarsAndStringValues(PSScalarRef theScalar, CFStringRef quantityName, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    CFMutableArrayRef result = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSUnitRef fahrenheit = PSUnitForSymbol(CFSTR("°F"));
    PSUnitRef rankine = PSUnitForSymbol(CFSTR("°R"));
    PSUnitRef kelvin = PSUnitForSymbol(CFSTR("K"));
    PSUnitRef celsius = PSUnitForSymbol(CFSTR("°C"));

    if(PSDimensionalityHasSameReducedDimensionality(PSDimensionalityForQuantityName(kPSQuantityTemperature), PSQuantityGetUnitDimensionality((PSQuantityRef)  theScalar))) {
        PSUnitRef theUnit = PSQuantityGetUnit(theScalar);
        if(theUnit == fahrenheit) {
            CFArrayAppendValue(result, theScalar);
            
            double complex value = PSScalarDoubleComplexValue(theScalar);
            
//            {
//                PSScalarRef scalar = PSScalarCreate(rankine, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//            }
//
//            {
//                value += 459.67;
//                PSScalarRef scalar = PSScalarCreate(rankine, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//                value -= 459.67;
//            }

            value = (value -32)*5./9.;
            {
                PSScalarRef scalar = PSScalarCreate(celsius, kPSNumberFloat64ComplexType, &value);
                CFArrayAppendValue(result, scalar);
                CFRelease(scalar);
            }
            
//            {
//                PSScalarRef scalar = PSScalarCreate(kelvin, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//            }
//
//            {
//                value += 273.15;
//                PSScalarRef scalar = PSScalarCreate(kelvin, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//            }
            return result;
        }
        if(theUnit == celsius) {
            CFArrayAppendValue(result, theScalar);
            double complex value = PSScalarDoubleComplexValue(theScalar);
            
//            {
//                PSScalarRef scalar = PSScalarCreate(kelvin, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//            }
//
//            {
//                value += 273.15;
//                PSScalarRef scalar = PSScalarCreate(kelvin, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//                value -= 273.15;
//            }

            {
                value = value*9./5. + 32;
                PSScalarRef scalar = PSScalarCreate(fahrenheit, kPSNumberFloat64ComplexType, &value);
                CFArrayAppendValue(result, scalar);
                CFRelease(scalar);
            }
            
//            {
//                PSScalarRef scalar = PSScalarCreate(rankine, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//            }
//            
//            {
//                value += 459.67;
//                PSScalarRef scalar = PSScalarCreate(rankine, kPSNumberFloat64ComplexType, &value);
//                CFArrayAppendValue(result, scalar);
//                CFRelease(scalar);
//            }
            
            return result;
        }
    }

    CFArrayRef units = NULL;
    CFArrayRef quantities = NULL;
    
    if(theScalar) {
        if(NULL == quantityName) {
            quantities = PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar));
            if(quantities) {
                CFArrayAppendArray(result, quantities,CFRangeMake(0, CFArrayGetCount(quantities)));
                CFRelease(quantities);
            }
        }
        if(NULL == quantityName) units = PSUnitCreateArrayOfConversionUnits(PSQuantityGetUnit((PSQuantityRef) theScalar));
        else units = PSUnitCreateArrayOfUnitsForQuantityName(quantityName);
        
        if(units) {
            for(CFIndex index = 0; index<CFArrayGetCount(units); index++) {
                PSUnitRef unit = (PSUnitRef) CFArrayGetValueAtIndex(units, index);
                
                if(unit && fahrenheit!=unit && celsius !=unit) {
                    PSScalarRef newScalar = PSScalarCreateByConvertingToUnit(theScalar, unit, error);
                    if(error && *error) {
                        if(newScalar) CFRelease(newScalar);
                        if(units) CFRelease(units);
                        return NULL;
                    }

                    if(newScalar) {
                        if(PSUnitIsCoherentDerivedUnit(unit)) {
                            CFArrayAppendValue(result, newScalar);
                        }
                        else {
                            int magnitude = log10(fabs(PSScalarDoubleValue(newScalar)));
                            if(abs(magnitude)<6) {
                                CFArrayAppendValue(result, newScalar);
                            }
                        }
                        CFRelease(newScalar);
                    }
                }
            }
            CFRelease(units);
        }
        if(PSDimensionalityHasSameReducedDimensionality(PSDimensionalityForQuantityName(kPSQuantityTime), PSQuantityGetUnitDimensionality((PSQuantityRef)  theScalar)) && PSScalarIsReal(theScalar)) {
            PSUnitRef unit1 = PSUnitForSymbol(CFSTR("yr"));
            PSUnitRef unit2 = PSUnitForSymbol(CFSTR("month"));
            PSUnitRef unit3 = PSUnitForSymbol(CFSTR("wk"));
            PSUnitRef unit4 = PSUnitForSymbol(CFSTR("d"));
            PSUnitRef unit5 = PSUnitForSymbol(CFSTR("h"));
            PSUnitRef unit6 = PSUnitForSymbol(CFSTR("min"));
            PSUnitRef unit7 = PSUnitForSymbol(CFSTR("s"));
            PSUnitRef theUnits[7] = {unit1,unit2,unit3,unit4, unit5, unit6, unit7};
            CFArrayRef units = CFArrayCreate(kCFAllocatorDefault,(const void **) theUnits, 7, &kCFTypeArrayCallBacks);
            CFStringRef stringValue = PSScalarCreateStringValueSplitByUnits(theScalar, units, true, error);
            CFRelease(units);
            if(stringValue) {
                CFArrayAppendValue(result, stringValue);
                CFRelease(stringValue);
            }
        }
        if(PSDimensionalityHasSameReducedDimensionality(PSDimensionalityForQuantityName(kPSQuantityVolume), PSQuantityGetUnitDimensionality((PSQuantityRef)  theScalar)) && PSScalarIsReal(theScalar)) {
            PSUnitRef unit1 = PSUnitForSymbol(CFSTR("gal"));
            PSUnitRef unit2 = PSUnitForSymbol(CFSTR("qt"));
            PSUnitRef unit3 = PSUnitForSymbol(CFSTR("pt"));
            PSUnitRef unit4 = PSUnitForSymbol(CFSTR("cup"));
            PSUnitRef unit5 = PSUnitForSymbol(CFSTR("floz"));
            PSUnitRef unit6 = PSUnitForSymbol(CFSTR("tbsp"));
            PSUnitRef unit7 = PSUnitForSymbol(CFSTR("tsp"));
            PSUnitRef unit8 = PSUnitForSymbol(CFSTR("halftsp"));
            PSUnitRef unit9 = PSUnitForSymbol(CFSTR("quartertsp"));
            PSUnitRef theUnits[9] = {unit1,unit2,unit3,unit4, unit5, unit6, unit7,unit8,unit9};
            CFArrayRef units = CFArrayCreate(kCFAllocatorDefault,(const void **) theUnits, 9, &kCFTypeArrayCallBacks);
            CFStringRef stringValue = PSScalarCreateStringValueSplitByUnits(theScalar, units, false, error);
            CFRelease(units);
            if(stringValue) {
                CFArrayAppendValue(result, stringValue);
                CFRelease(stringValue);
            }
        }
        if(PSDimensionalityHasSameReducedDimensionality(PSDimensionalityForQuantityName(kPSQuantityLength), PSQuantityGetUnitDimensionality((PSQuantityRef)  theScalar)) && PSScalarIsReal(theScalar)) {
            PSUnitRef unit1 = PSUnitForSymbol(CFSTR("mi"));
            PSUnitRef unit2 = PSUnitForSymbol(CFSTR("ft"));
            PSUnitRef unit3 = PSUnitForSymbol(CFSTR("in"));
            PSUnitRef theUnits[3] = {unit1,unit2,unit3};
            CFArrayRef units = CFArrayCreate(kCFAllocatorDefault,(const void **) theUnits, 3, &kCFTypeArrayCallBacks);
            CFStringRef stringValue = PSScalarCreateStringValueSplitByUnits(theScalar, units, false, error);
            CFRelease(units);
            if(stringValue) {
                CFArrayAppendValue(result, stringValue);
                CFRelease(stringValue);
            }
        }
        if(PSDimensionalityHasSameReducedDimensionality(PSDimensionalityForQuantityName(kPSQuantityLength), PSQuantityGetUnitDimensionality((PSQuantityRef)  theScalar)) && PSScalarIsReal(theScalar)) {
            PSUnitRef unit1 = PSUnitForSymbol(CFSTR("mi"));
            PSUnitRef unit2 = PSUnitForSymbol(CFSTR("yd"));
            PSUnitRef unit3 = PSUnitForSymbol(CFSTR("ft"));
            PSUnitRef unit4 = PSUnitForSymbol(CFSTR("in"));
            PSUnitRef theUnits[4] = {unit1,unit2,unit3,unit4};
            CFArrayRef units = CFArrayCreate(kCFAllocatorDefault,(const void **) theUnits, 4, &kCFTypeArrayCallBacks);
            CFStringRef stringValue = PSScalarCreateStringValueSplitByUnits(theScalar, units, false, error);
            CFRelease(units);
            if(stringValue) {
                if(CFArrayBSearchValues(result,CFRangeMake(0, CFArrayGetCount(result)),stringValue,
                                        (CFComparatorFunction)compareOnlyTheStrings,NULL) >= CFArrayGetCount(result) ) {
                    CFArrayAppendValue(result, stringValue);
                    CFRelease(stringValue);
                }
            }
        }
        if(PSDimensionalityHasSameReducedDimensionality(PSDimensionalityForQuantityName(kPSQuantityMass), PSQuantityGetUnitDimensionality((PSQuantityRef)  theScalar)) && PSScalarIsReal(theScalar)) {
            PSUnitRef unit1 = PSUnitForSymbol(CFSTR("ton"));
            PSUnitRef unit2 = PSUnitForSymbol(CFSTR("lb"));
            PSUnitRef unit3 = PSUnitForSymbol(CFSTR("oz"));
            PSUnitRef theUnits[3] = {unit1,unit2,unit3};
            CFArrayRef units = CFArrayCreate(kCFAllocatorDefault,(const void **) theUnits, 3, &kCFTypeArrayCallBacks);
            CFStringRef stringValue = PSScalarCreateStringValueSplitByUnits(theScalar, units, false, error);
            CFRelease(units);
            if(stringValue) {
                CFArrayAppendValue(result, stringValue);
                CFRelease(stringValue);
            }
        }
        if(PSDimensionalityHasSameReducedDimensionality(PSDimensionalityForQuantityName(kPSQuantityMass), PSQuantityGetUnitDimensionality((PSQuantityRef)  theScalar)) && PSScalarIsReal(theScalar)) {
            PSUnitRef unit1 = PSUnitForSymbol(CFSTR("ton"));
            PSUnitRef unit2 = PSUnitForSymbol(CFSTR("st"));
            PSUnitRef unit3 = PSUnitForSymbol(CFSTR("lb"));
            PSUnitRef unit4 = PSUnitForSymbol(CFSTR("oz"));
            PSUnitRef theUnits[4] = {unit1,unit2,unit3,unit4};
            CFArrayRef units = CFArrayCreate(kCFAllocatorDefault,(const void **) theUnits, 4, &kCFTypeArrayCallBacks);
            CFStringRef stringValue = PSScalarCreateStringValueSplitByUnits(theScalar, units, false, error);
            CFRelease(units);
            if(stringValue) {
                if(CFArrayBSearchValues(result,CFRangeMake(0, CFArrayGetCount(result)),stringValue,
                                        (CFComparatorFunction)compareOnlyTheStrings,NULL)>=CFArrayGetCount(result) ) {
                    
                    CFArrayAppendValue(result, stringValue);
                    CFRelease(stringValue);
                }
            }
        }
        return result;
    }
    return NULL;
}

CFArrayRef PSScalarCreateArrayOfConversionQuantitiesAndUnits(PSScalarRef theScalar, CFStringRef quantityName, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    CFArrayRef units = NULL;
    CFArrayRef quantities = NULL;
    CFMutableArrayRef result = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    if(theScalar) {
        if(NULL == quantityName) {
            quantities = PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar));
            if(quantities) {
                CFArrayAppendArray(result, quantities,CFRangeMake(0, CFArrayGetCount(quantities)));
                CFRelease(quantities);
            }
        }
        if(NULL == quantityName) units = PSUnitCreateArrayOfConversionUnits(PSQuantityGetUnit((PSQuantityRef) theScalar));
        else units = PSUnitCreateArrayOfUnitsForQuantityName(quantityName);
        
        if(units) {
            for(CFIndex index = 0; index<CFArrayGetCount(units); index++) {
                PSUnitRef unit = (PSUnitRef) CFArrayGetValueAtIndex(units, index);
                if(unit) {
                    PSScalarRef newScalar = PSScalarCreateByConvertingToUnit(theScalar, unit, error);
                    if(error) {
                        if(*error) {
                            if(newScalar) CFRelease(newScalar);
                            if(units) CFRelease(units);
                            return NULL;
                        }
                    }
                    if(newScalar) {
                        if(PSUnitIsCoherentDerivedUnit(unit)) CFArrayAppendValue(result, unit);
                        else {
                            int magnitude = log10(fabs(PSScalarDoubleValue(newScalar)));
                            if(abs(magnitude)<6)CFArrayAppendValue(result, unit);                            }
                        CFRelease(newScalar);
                    }
                }
            }
            CFRelease(units);
        }
        return result;
    }
    return NULL;
}



#pragma mark Strings and Archiving

void PSScalarShow(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,);
	CFStringRef cf_string = PSScalarCreateStringValue(theScalar);
    if(cf_string) {
        PSCFStringShow(cf_string);
//        PSCFStringShow(CFSTR("\n"));
        CFRelease(cf_string);
    }
    else fprintf(stdout,"invalid value.");
}

bool PSScalarValidateProposedStringValue(PSScalarRef theScalar,CFStringRef proposedStringValue, CFErrorRef *error)
{
    if(error) if(*error) return false;
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
   	IF_NO_OBJECT_EXISTS_RETURN(proposedStringValue,false);
    PSScalarRef proposedValue = PSScalarCreateWithCFString(proposedStringValue,error);
    if(proposedValue==NULL) {
        if(error) {
            PSDimensionalityRef dimensionality = PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar);
            CFStringRef dimensionalitySymbol = PSDimensionalityGetSymbol(dimensionality);
            
            CFStringRef userInfoKeys[2];
            CFStringRef userInfoValues[2];
            
            userInfoKeys[0] = kCFErrorLocalizedDescriptionKey;
            userInfoValues[0] = CFSTR("Unrecognized input.");
            
            userInfoKeys[1] = kCFErrorLocalizedRecoverySuggestionKey;
            userInfoValues[1] = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Value must have dimensionality: %@"),dimensionalitySymbol);
            
            *error = CFErrorCreateWithUserInfoKeysAndValues (kCFAllocatorDefault,CFSTR("PSScalar"),0,(CFTypeRef *) userInfoKeys,(CFTypeRef *) userInfoValues,2);
            CFRelease(userInfoValues[1]);}
        return false;
    }
    else if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) proposedValue, (PSQuantityRef) theScalar)) {
        if(error) {
            PSDimensionalityRef dimensionality = PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar);
            CFStringRef dimensionalitySymbol = PSDimensionalityGetSymbol(dimensionality);
            CFStringRef userInfoKeys[2];
            CFStringRef userInfoValues[2];
            
            userInfoKeys[0] = kCFErrorLocalizedDescriptionKey;
            userInfoValues[0] = CFSTR("Invalid Unit Dimensionality.");
            
            userInfoKeys[1] = kCFErrorLocalizedRecoverySuggestionKey;
            userInfoValues[1] = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Value must have dimensionality: %@"),dimensionalitySymbol);
            
            *error = CFErrorCreateWithUserInfoKeysAndValues (kCFAllocatorDefault,CFSTR("PSDimension"),0,(CFTypeRef *) userInfoKeys,(CFTypeRef *) userInfoValues,2);
            CFRelease(userInfoValues[1]);
        }
        return false;
    }
    return true;
}

CFStringRef PSScalarCreateNumericStringValue(PSScalarRef theScalar)
{
    if(theScalar==NULL) return CFSTR("");
    CFStringRef stringValue = NULL;
    
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type:
        case kPSNumberFloat32ComplexType:
            stringValue = PSScalarCreateNumericStringValueWithFormat(theScalar, CFSTR("%.7g"));
            break;
        case kPSNumberFloat64Type:
        case kPSNumberFloat64ComplexType:
//            stringValue = PSScalarCreateNumericStringValueWithFormat(theScalar, CFSTR("%.16lg"));
            stringValue = PSScalarCreateNumericStringValueWithFormat(theScalar, CFSTR("%.14lg"));
            break;
    }
    return stringValue;
}

CFStringRef PSScalarCreateStringValue(PSScalarRef theScalar)
{
    CFStringRef stringValue = NULL;
    if(theScalar==NULL) return stringValue;
    
    if(CFGetTypeID(theScalar)==CFNumberGetTypeID()) {
        return PSCFNumberCreateStringValue((CFNumberRef) ((CFTypeRef) theScalar));
    }
     switch (theScalar->elementType) {
        case kPSNumberFloat32Type:
        case kPSNumberFloat32ComplexType:
            stringValue = PSScalarCreateStringValueWithFormat(theScalar, CFSTR("%.7g"));
            break;
        case kPSNumberFloat64Type:
        case kPSNumberFloat64ComplexType:
             stringValue = PSScalarCreateStringValueWithFormat(theScalar, CFSTR("%.16lg"));
            break;
    }
    return stringValue;
}

CFStringRef PSScalarCreateStringValueForPart(PSScalarRef theScalar, complexPart thePart)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    PSScalarRef temp = PSScalarCreateByTakingComplexPart(theScalar, thePart);
    CFStringRef string = PSScalarCreateStringValue(temp);
    CFRelease(temp);
    return string;
}

CFStringRef PSScalarCreateNumericStringValueWithFormat(PSScalarRef theScalar, CFStringRef format)
{
    if(theScalar==NULL) return CFSTR("");
    
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type: {
            float value = PSScalarFloatValue(theScalar);
            if(PSCompareFloatValues(value, 0.0) == kPSCompareEqualTo) value = 0.0;
            
            CFStringRef numericString = PSFloatComplexCreateStringValueWithFormat(value,format);
            return numericString;
        }
        case kPSNumberFloat64Type: {
            double value = PSScalarDoubleValue(theScalar);
            if(PSCompareDoubleValues(value, 0.0) == kPSCompareEqualTo) value = 0.0;
            
            CFStringRef numericString = PSDoubleComplexCreateStringValueWithFormat(value,format);
            
            return numericString;
        }
        case kPSNumberFloat32ComplexType: {
            float complex value = PSScalarFloatComplexValue(theScalar);
            CFMutableStringRef cf_string = CFStringCreateMutable(kCFAllocatorDefault, 0);
            if(crealf(value)!=0.0 && cimagf(value)!=0.0) CFStringAppend(cf_string, CFSTR("("));
            CFStringRef numericString = PSFloatComplexCreateStringValueWithFormat(value,format);
            CFStringAppend(cf_string,numericString);
            CFRelease(numericString);
            if(crealf(value)!=0.0 && cimagf(value)!=0.0) CFStringAppend(cf_string, CFSTR(")"));
            return cf_string;
        }
        case kPSNumberFloat64ComplexType: {
            double complex value = PSScalarDoubleComplexValue(theScalar);
            CFMutableStringRef cf_string = CFStringCreateMutable(kCFAllocatorDefault, 0);
            if(creal(value)!=0.0 && cimag(value)!=0.0) CFStringAppend(cf_string, CFSTR("("));
            CFStringRef numericString = PSDoubleComplexCreateStringValueWithFormat(value,format);
            CFStringAppend(cf_string,numericString);
            CFRelease(numericString);
            if(creal(value)!=0.0 && cimag(value)!=0.0) CFStringAppend(cf_string, CFSTR(")"));
            return cf_string;
        }
    }
    return NULL;
}

CFStringRef PSScalarCreateUnitString(PSScalarRef theScalar)
{
    CFStringRef unit_symbol;
    if(PSUnitIsDimensionlessAndUnderived(theScalar->unit)) unit_symbol = CFSTR("");
    else unit_symbol = PSUnitCopySymbol(theScalar->unit);
    return unit_symbol;
}

CFStringRef PSScalarCreateStringValueWithFormat(PSScalarRef theScalar, CFStringRef format)
{	
    if(theScalar==NULL) return CFSTR("");
    
    CFStringRef unit_symbol = PSScalarCreateUnitString(theScalar);
    
	switch (theScalar->elementType) {
		case kPSNumberFloat32Type: {
            float value = PSScalarFloatValue(theScalar);
            if(PSCompareFloatValues(value, 0.0) == kPSCompareEqualTo) value = 0.0;

//            CFStringRef numericString = PSFloatCreateStringValue(value);
            CFStringRef numericString = PSFloatComplexCreateStringValueWithFormat(value,format);

            CFMutableStringRef cf_string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0,numericString);
            CFStringFindAndReplace (cf_string,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(cf_string)),0);
            CFRelease(numericString);
            
			if(theScalar->unit) {
                CFStringAppend(cf_string,CFSTR(" "));
                CFStringAppend(cf_string, unit_symbol);
            }
            CFStringTrimWhitespace (cf_string);
            CFRelease(unit_symbol);
			return cf_string;
		}
		case kPSNumberFloat64Type: {
            double value = PSScalarDoubleValue(theScalar);
            if(PSCompareDoubleValues(value, 0.0) == kPSCompareEqualTo) value = 0.0;
//            CFStringRef numericString = PSDoubleCreateStringValue(value);
            CFStringRef numericString = PSDoubleComplexCreateStringValueWithFormat(value,format);

            CFMutableStringRef cf_string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0,numericString);
            CFStringFindAndReplace (cf_string,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(cf_string)),0);
            CFRelease(numericString);
            
			if(theScalar->unit) {
                CFStringAppend(cf_string,CFSTR(" "));
                CFStringAppend(cf_string, unit_symbol);
            }
            CFStringTrimWhitespace (cf_string);
            CFRelease(unit_symbol);
			return cf_string;
		}
		case kPSNumberFloat32ComplexType: {
            float complex value = PSScalarFloatComplexValue(theScalar);
            CFMutableStringRef cf_string = CFStringCreateMutable(kCFAllocatorDefault, 0);
            if(crealf(value)!=0.0 && cimagf(value)!=0.0) CFStringAppend(cf_string, CFSTR("("));
            CFStringRef numericString = PSFloatComplexCreateStringValueWithFormat(value,format);
            CFStringAppend(cf_string,numericString);
            CFStringFindAndReplace (cf_string,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(cf_string)),0);
            CFRelease(numericString);
            if(crealf(value)!=0.0 && cimagf(value)!=0.0) CFStringAppend(cf_string, CFSTR(")"));
            if(theScalar->unit) {
                CFStringAppend(cf_string,CFSTR(" "));
                CFStringAppend(cf_string, unit_symbol);
            }
            CFStringTrimWhitespace (cf_string);
            CFRelease(unit_symbol);
			return cf_string;
		}
		case kPSNumberFloat64ComplexType: {
            double complex value = PSScalarDoubleComplexValue(theScalar);
            CFMutableStringRef cf_string = CFStringCreateMutable(kCFAllocatorDefault, 0);
            if(creal(value)!=0.0 && cimag(value)!=0.0) CFStringAppend(cf_string, CFSTR("("));
            CFStringRef numericString = PSDoubleComplexCreateStringValueWithFormat(value,format);
            CFStringAppend(cf_string,numericString);
            CFStringFindAndReplace (cf_string,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(cf_string)),0);
            CFRelease(numericString);
            if(creal(value)!=0.0 && cimag(value)!=0.0) CFStringAppend(cf_string, CFSTR(")"));
            if(theScalar->unit) {
                CFStringAppend(cf_string,CFSTR(" "));
                CFStringAppend(cf_string, unit_symbol);
            }
            CFStringTrimWhitespace (cf_string);
            CFRelease(unit_symbol);
			return cf_string;
		}
	}
	return NULL;
}

void PSScalarAddToArrayAsStringValue(PSScalarRef theScalar, CFMutableArrayRef array)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,);
   	IF_NO_OBJECT_EXISTS_RETURN(array,);
    CFStringRef stringValue = PSScalarCreateStringValue(theScalar);
    CFArrayAppendValue(array, stringValue);
    CFRelease(stringValue);
}

void PSScalarAddToArrayAsData(PSScalarRef theScalar, CFMutableArrayRef array)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,);
   	IF_NO_OBJECT_EXISTS_RETURN(array,);
    CFErrorRef error = NULL;
    CFDataRef data = PSScalarCreateData(theScalar, &error);
    CFArrayAppendValue(array, data);
    CFRelease(data);
}

CFDataRef PSScalarCreateData(PSScalarRef theScalar, CFErrorRef *error)
{
    if(error) if(*error) return NULL;

   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    
    CFNumberRef number = CFNumberCreate(kCFAllocatorDefault,kCFNumberIntType, &theScalar->elementType);
    CFDictionarySetValue(dictionary, CFSTR("elementType"), number);
    CFRelease(number);
    
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type: {
            CFDataRef data = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) &theScalar->value.floatValue, sizeof(float));
            CFDictionarySetValue(dictionary, CFSTR("value"), data);
            CFRelease(data);
            break;
        }
        case kPSNumberFloat64Type: {
            CFDataRef data = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) &theScalar->value.doubleValue, sizeof(double));
            CFDictionarySetValue(dictionary, CFSTR("value"), data);
            CFRelease(data);
            break;
        }
        case kPSNumberFloat32ComplexType: {
            CFDataRef data = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) &theScalar->value.floatComplexValue, sizeof(float complex));
            CFDictionarySetValue(dictionary, CFSTR("value"), data);
            CFRelease(data);
            break;
        }
        case kPSNumberFloat64ComplexType: {
            CFDataRef data = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) &theScalar->value.doubleComplexValue, sizeof(double complex));
            CFDictionarySetValue(dictionary, CFSTR("value"), data);
            CFRelease(data);
            break;
        }
    }
    
    CFDataRef unitData = PSUnitCreateData(theScalar->unit);
    CFDictionarySetValue(dictionary, CFSTR("unit"), unitData);
    CFRelease(unitData);
    
    CFDataRef data = CFPropertyListCreateData(kCFAllocatorDefault,dictionary,kCFPropertyListBinaryFormat_v1_0,0,error);
    CFRelease(dictionary);
    
    return data;
}

PSScalarRef PSScalarCreateWithData(CFDataRef data, CFErrorRef *error)
{
    if(error) if(*error) return NULL;

   	IF_NO_OBJECT_EXISTS_RETURN(data,NULL);
    CFPropertyListFormat format;
    CFDictionaryRef dictionary  = CFPropertyListCreateWithData (kCFAllocatorDefault,data,kCFPropertyListImmutable,&format,error);
    
    PSUnitRef unit = PSUnitWithData(CFDictionaryGetValue(dictionary, CFSTR("unit")),error);
    
    numberType elementType = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("elementType")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("elementType")),kCFNumberIntType,&elementType);
    else {
        CFRelease(dictionary); 
        return NULL;
    }
    
    PSScalarRef theScalar = NULL;
    switch (elementType) {
        case kPSNumberFloat32Type: {
            CFDataRef valueData = CFDictionaryGetValue(dictionary, CFSTR("value"));
            float value;
            CFDataGetBytes(valueData, CFRangeMake(0, sizeof(float)), (UInt8 *) &value);
            theScalar = PSScalarCreate(unit, elementType, &value);
            break;
        }
        case kPSNumberFloat64Type: {
            CFDataRef valueData = CFDictionaryGetValue(dictionary, CFSTR("value"));
            double value;
            CFDataGetBytes(valueData, CFRangeMake(0, sizeof(double)), (UInt8 *) &value);
            theScalar = PSScalarCreate(unit, elementType, &value);
            break;
        }
        case kPSNumberFloat32ComplexType: {
            CFDataRef valueData = CFDictionaryGetValue(dictionary, CFSTR("value"));
            float complex value;
            CFDataGetBytes(valueData, CFRangeMake(0, sizeof(float complex)), (UInt8 *) &value);
            theScalar = PSScalarCreate(unit, elementType, &value);
            break;
        }
        case kPSNumberFloat64ComplexType: {
            CFDataRef valueData = CFDictionaryGetValue(dictionary, CFSTR("value"));
            double complex value;
            CFDataGetBytes(valueData, CFRangeMake(0, sizeof(double complex)), (UInt8 *) &value);
            theScalar = PSScalarCreate(unit, elementType, &value);
            break;
        }
    }
    CFRelease(dictionary);
    return theScalar;
}

CFDictionaryRef PSScalarCreatePList(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,NULL);
    
    CFStringRef stringValue = PSScalarCreateStringValue(theScalar);
    CFMutableDictionaryRef dictionary = NULL;
    
    if(stringValue) {
        dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(dictionary, CFSTR("TypeIDDescription"), CFSTR("PSScalar"));
        
        CFNumberRef number = CFNumberCreate(kCFAllocatorDefault,kCFNumberIntType, &theScalar->elementType);
        CFDictionarySetValue(dictionary, CFSTR("elementType"), number);
        CFRelease(number);
        
        CFDictionarySetValue(dictionary, CFSTR("value"), stringValue);
        CFRelease(stringValue);
    }
    
    return dictionary;
}

PSScalarRef PSScalarCreateWithPList(CFDictionaryRef thePropertyList, CFErrorRef *error)
{
    if(error) if(*error) return NULL;

   	IF_NO_OBJECT_EXISTS_RETURN(thePropertyList,NULL);
    CFTypeID typeID = CFGetTypeID(thePropertyList);
    if(CFDictionaryGetTypeID() != typeID) return NULL;
    
    if(!CFDictionaryContainsKey(thePropertyList, CFSTR("TypeIDDescription"))) return NULL;
    CFStringRef typeIDDescription = CFDictionaryGetValue(thePropertyList, CFSTR("TypeIDDescription"));
    if(CFStringCompare(typeIDDescription, CFSTR("PSScalar"), 0)!=kCFCompareEqualTo) return NULL;
    
    numberType elementType = 0;
    if(CFDictionaryContainsKey(thePropertyList, CFSTR("elementType")))
        CFNumberGetValue(CFDictionaryGetValue(thePropertyList, CFSTR("elementType")),kCFNumberIntType,&elementType);
    else return NULL;
    
    PSScalarRef theScalar = PSScalarCreateWithCFString(CFDictionaryGetValue(thePropertyList, CFSTR("value")), error);
    PSScalarSetElementType((PSMutableScalarRef) theScalar, elementType);
    return theScalar;
}

#pragma mark Tests

bool PSScalarIsReal(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    double complex value = PSScalarDoubleComplexValue(theScalar);
    if(cimag(value)==0.0) return true;
    return false;
}

bool PSScalarIsImaginary(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    double complex value = PSScalarDoubleComplexValue(theScalar);
    if(creal(value)==0.0 && cabs(value) != 0.0) return true;
    return false;
}

bool PSScalarIsComplex(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    double complex value = PSScalarDoubleComplexValue(theScalar);
    if(cimag(value)==0.0) return false;
    return true;
}

bool PSScalarIsZero(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    double complex value = PSScalarDoubleComplexValue(theScalar);
    if(cimag(value)!=0.0) return false;
    if(creal(value)!=0.0) return false;
    return true;
}

bool PSScalarIsInfinite(PSScalarRef theScalar)
{
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    switch (PSQuantityGetElementType(theScalar)) {
        case kPSNumberFloat32Type:
            if(isinf(theScalar->value.floatValue)) return true;
        case kPSNumberFloat64Type:
            if(isinf(theScalar->value.doubleValue)) return true;
        case kPSNumberFloat32ComplexType:
            if(isinf(crealf(theScalar->value.floatComplexValue))) return true;
            if(isinf(cimagf(theScalar->value.floatComplexValue))) return true;
        case kPSNumberFloat64ComplexType:
            if(isinf(creal(theScalar->value.floatComplexValue))) return true;
            if(isinf(cimag(theScalar->value.floatComplexValue))) return true;
    }
    return false;
}

bool PSScalarIsRealNonNegativeInteger(PSScalarRef theScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    if(PSScalarIsComplex(theScalar)) return false;
    double value = PSScalarDoubleValue(theScalar);
    double integerPart;
    double fractionalPart = modf(value, &integerPart);
    if(fractionalPart != 0.0) return false;
    if(integerPart>=0) return true;
    return false;
}

bool PSScalarEqual(PSScalarRef input1,PSScalarRef input2)
{
   	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    if(input1 == input2) return true;
    
	if(input1->elementType != input2->elementType) return false;
	if(!PSUnitEqual(input1->unit, input2->unit)) return false;
    
    switch (input1->elementType) {
        case kPSNumberFloat32Type: {
            if(input1->value.floatValue != input2->value.floatValue) return false;
            break;
        }
        case kPSNumberFloat64Type: {
            if(input1->value.doubleValue != input2->value.doubleValue) return false;
            break;
        }
        case kPSNumberFloat32ComplexType: {
            if(input1->value.floatComplexValue != input2->value.floatComplexValue) return false;
            break;
        }
        case kPSNumberFloat64ComplexType: {
            if(input1->value.doubleComplexValue != input2->value.doubleComplexValue) return false;
            break;
        }
    }
	return true;
}

- (NSComparisonResult) compare: (PSScalar *) otherScalar
{
    return (NSComparisonResult) PSScalarCompare(self, otherScalar);
}

PSComparisonResult PSScalarCompare(PSScalarRef theScalar, PSScalarRef theOtherScalar)
{
    if(NULL==theScalar) {
        IF_NO_OBJECT_EXISTS_RETURN(theScalar,kPSCompareError);
    }
    if(NULL==theOtherScalar) {
        IF_NO_OBJECT_EXISTS_RETURN(theOtherScalar,kPSCompareError);
    }
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar),
                              PSQuantityGetUnitDimensionality((PSQuantityRef) theOtherScalar))) return kPSCompareUnequalDimensionalities;
    
    PSMutableScalarRef theOtherConverted = PSScalarCreateMutableCopy(theOtherScalar);
    PSScalarConvertToUnit(theOtherConverted, PSQuantityGetUnit(theScalar), NULL);
    
    PSComparisonResult result = kPSCompareError;
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    result = PSCompareFloatValues((float) theScalar->value.floatValue, (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    result = PSCompareFloatValues((float) theScalar->value.floatValue, (float) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValues((float) theScalar->value.floatValue, (float) crealf(theOtherConverted->value.floatComplexValue));
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValues((float) theScalar->value.floatValue, (float) creal(theOtherConverted->value.doubleComplexValue));
                    break;
                }
            }
            break;
        }
        case kPSNumberFloat64Type: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    result = PSCompareFloatValues((float) theScalar->value.doubleValue, (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    result = PSCompareDoubleValues((double) theScalar->value.doubleValue, (double) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValues((float) theScalar->value.doubleValue, (float) crealf(theOtherConverted->value.floatComplexValue));
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareDoubleValues((double) theScalar->value.doubleValue, creal(theOtherConverted->value.doubleComplexValue));
                    break;
                }
            }
            break;
        }
        case kPSNumberFloat32ComplexType: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValues((float) creal(theScalar->value.floatComplexValue), (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValues((float) crealf(theScalar->value.floatComplexValue), (float) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    PSComparisonResult realResult =  PSCompareFloatValues((float) crealf(theScalar->value.floatComplexValue), (float) crealf(theOtherConverted->value.floatComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareFloatValues((float) cimagf(theScalar->value.floatComplexValue), (float) cimagf(theOtherConverted->value.floatComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    PSComparisonResult realResult = PSCompareFloatValues((float) crealf(theScalar->value.floatComplexValue), (float) creal(theOtherConverted->value.doubleComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareFloatValues((float) cimagf(theScalar->value.floatComplexValue), (float) cimag(theOtherConverted->value.doubleComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
            }
            break;
        }
        case kPSNumberFloat64ComplexType: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result = kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValues((float) creal(theScalar->value.doubleComplexValue), (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result = kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareDoubleValues((double) creal(theScalar->value.doubleComplexValue), (double) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    PSComparisonResult realResult = PSCompareFloatValues((float) creal(theScalar->value.doubleComplexValue), (float) crealf(theOtherConverted->value.floatComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareFloatValues((float) cimag(theScalar->value.doubleComplexValue), (float) cimagf(theOtherConverted->value.floatComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    PSComparisonResult realResult = PSCompareDoubleValues((double) creal(theScalar->value.doubleComplexValue), (double) creal(theOtherConverted->value.doubleComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareDoubleValues((double) cimag(theScalar->value.doubleComplexValue), (double) cimag(theOtherConverted->value.doubleComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
            }
            break;
        }
    }
    CFRelease(theOtherConverted);
    return result;
}

PSComparisonResult PSScalarCompareReduced(PSScalarRef theScalar, PSScalarRef theOtherScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,kPSCompareError);
   	IF_NO_OBJECT_EXISTS_RETURN(theOtherScalar,kPSCompareError);
    PSScalarRef theScalarReduced = PSScalarCreateByReducingUnit(theScalar);
    PSScalarRef theOtherScalarReduced = PSScalarCreateByReducingUnit(theOtherScalar);
    PSComparisonResult result = PSScalarCompare(theScalarReduced, theOtherScalarReduced);
    CFRelease(theScalarReduced);
    CFRelease(theOtherScalarReduced);
    return result;
}

PSComparisonResult PSScalarCompareLoose(PSScalarRef theScalar, PSScalarRef theOtherScalar)
{
   	IF_NO_OBJECT_EXISTS_RETURN(theScalar,kPSCompareError);
   	IF_NO_OBJECT_EXISTS_RETURN(theOtherScalar,kPSCompareError);
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) theScalar),
                              PSQuantityGetUnitDimensionality((PSQuantityRef) theOtherScalar))) return kPSCompareUnequalDimensionalities;
    
    PSMutableScalarRef theOtherConverted = PSScalarCreateMutableCopy(theOtherScalar);
    PSScalarConvertToUnit(theOtherConverted, PSQuantityGetUnit(theScalar), NULL);
    
    PSComparisonResult result = kPSCompareError;
    switch (theScalar->elementType) {
        case kPSNumberFloat32Type: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    result = PSCompareFloatValuesLoose((float) theScalar->value.floatValue, (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    result = PSCompareFloatValuesLoose((float) theScalar->value.floatValue, (float) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValuesLoose((float) theScalar->value.floatValue, (float) crealf(theOtherConverted->value.floatComplexValue));
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValuesLoose((float) theScalar->value.floatValue, (float) creal(theOtherConverted->value.doubleComplexValue));
                    break;
                }
            }
            break;
        }
        case kPSNumberFloat64Type: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    result = PSCompareFloatValuesLoose((float) theScalar->value.doubleValue, (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    result = PSCompareDoubleValuesLoose((double) theScalar->value.doubleValue, (double) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValuesLoose((float) theScalar->value.doubleValue, (float) crealf(theOtherConverted->value.floatComplexValue));
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    if(!PSScalarIsReal(theOtherConverted)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareDoubleValuesLoose((double) theScalar->value.doubleValue, creal(theOtherConverted->value.doubleComplexValue));
                    break;
                }
            }
            break;
        }
        case kPSNumberFloat32ComplexType: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValuesLoose((float) creal(theScalar->value.floatComplexValue), (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result =  kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValuesLoose((float) crealf(theScalar->value.floatComplexValue), (float) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    PSComparisonResult realResult =  PSCompareFloatValuesLoose((float) crealf(theScalar->value.floatComplexValue), (float) crealf(theOtherConverted->value.floatComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareFloatValuesLoose((float) cimagf(theScalar->value.floatComplexValue), (float) cimagf(theOtherConverted->value.floatComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    PSComparisonResult realResult = PSCompareFloatValuesLoose((float) crealf(theScalar->value.floatComplexValue), (float) creal(theOtherConverted->value.doubleComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareFloatValuesLoose((float) cimagf(theScalar->value.floatComplexValue), (float) cimag(theOtherConverted->value.doubleComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
            }
            break;
        }
        case kPSNumberFloat64ComplexType: {
            switch (theOtherConverted->elementType) {
                case kPSNumberFloat32Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result = kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareFloatValuesLoose((float) creal(theScalar->value.doubleComplexValue), (float) theOtherConverted->value.floatValue);
                    break;
                }
                case kPSNumberFloat64Type: {
                    if(!PSScalarIsReal(theScalar)) {
                        result = kPSCompareNoSingleValue;
                        break;
                    }
                    result = PSCompareDoubleValuesLoose((double) creal(theScalar->value.doubleComplexValue), (double) theOtherConverted->value.doubleValue);
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    PSComparisonResult realResult = PSCompareFloatValuesLoose((float) creal(theScalar->value.doubleComplexValue), (float) crealf(theOtherConverted->value.floatComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareFloatValuesLoose((float) cimag(theScalar->value.doubleComplexValue), (float) cimagf(theOtherConverted->value.floatComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    PSComparisonResult realResult = PSCompareDoubleValuesLoose((double) creal(theScalar->value.doubleComplexValue), (double) creal(theOtherConverted->value.doubleComplexValue));
                    
                    PSComparisonResult imagResult = PSCompareDoubleValuesLoose((double) cimag(theScalar->value.doubleComplexValue), (double) cimag(theOtherConverted->value.doubleComplexValue));
                    
                    if(realResult == kPSCompareEqualTo && imagResult == kPSCompareEqualTo) result = kPSCompareEqualTo;
                    else result = kPSCompareNoSingleValue;
                    break;
                }
            }
            break;
        }
    }
    CFRelease(theOtherConverted);
    return result;
}


@end
