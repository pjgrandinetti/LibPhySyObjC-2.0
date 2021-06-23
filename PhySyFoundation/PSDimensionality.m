//
//  PSDimensionality.m
//
//  Created by PhySy Ltd on 12/27/09.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

// ---- implementation ----

#import "PhySyFoundation.h"
#import <QuartzCore/QuartzCore.h>
@interface PSDimensionality ()
{
@private
    bool staticInstance;
	uint8_t numerator_exponent[7];
	uint8_t denominator_exponent[7];
    CFStringRef symbol;
}
@end

@implementation PSDimensionality

- (void) dealloc
{
    if(!staticInstance) {
        CFRelease(symbol);
        [super dealloc];
        return;
    }
}


#pragma mark Static Utility Functions

static CFStringRef baseDimensionSymbol(PSBaseDimensionIndex index)
{
	switch (index) {
		case kPSLengthIndex:
			return CFSTR("L");
		case kPSMassIndex:
			return CFSTR("M");
		case kPSTimeIndex:
			return CFSTR("T");
		case kPSCurrentIndex:
			return CFSTR("I");
		case kPSTemperatureIndex:
			return CFSTR("ϴ");
		case kPSAmountIndex:
			return CFSTR("N");
		case kPSLuminousIntensityIndex:
			return CFSTR("J");
		default:
			break;
	}
	return NULL;
}

// dimensionalityLibrary is a Singleton
CFMutableDictionaryRef dimensionalityLibrary = NULL;
CFMutableDictionaryRef dimensionalityQuantitiesLibrary = NULL;
static void DimensionalityLibraryBuild(void);

#pragma mark Designated Creator

static CFStringRef PSDimensionalityCreateSymbol(PSDimensionalityRef theDimensionality)
{
    
    /*
     *    This routine constructs a dimensionality symbol in terms of the seven base dimensions
     */
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
    CFMutableStringRef numerator = CFStringCreateMutable(NULL,0);
    
    CFMutableStringRef denominator = CFStringCreateMutable(NULL,0);
    bool denominator_multiple_dimensions = false;
    
    uint8_t exponent;
    
    // Numerator
    exponent = PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,0);
    if(exponent>0) {
        if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@^%d"),baseDimensionSymbol(0),exponent);
        else CFStringAppendFormat(numerator,NULL,CFSTR("%@"),baseDimensionSymbol(0));
    }
    for(uint8_t index = 1;index<7;index++) {
        exponent = PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,index);
        if(exponent>0) {
            if(CFStringGetLength(numerator)==0) {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@^%d"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("%@"),baseDimensionSymbol(index));
                
            }
            else {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("•%@^%d"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("•%@"),baseDimensionSymbol(index));
            }
        }
    }
    
    // Denominator
    exponent = PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,0);
    if(exponent>0) {
        if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@^%d"),baseDimensionSymbol(0),exponent);
        else CFStringAppendFormat(denominator,NULL,CFSTR("%@"),baseDimensionSymbol(0));
        
    }
    for(uint8_t index = 1;index<7;index++) {
        exponent = PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,index);
        if(exponent>0) {
            if(CFStringGetLength(denominator)==0) {
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@^%d"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("%@"),baseDimensionSymbol(index));
                
            }
            else {
                denominator_multiple_dimensions = true;
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("•%@^%d"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("•%@"),baseDimensionSymbol(index));
            }
        }
    }
    
    if(CFStringGetLength(numerator)!=0) {
        if(CFStringGetLength(denominator)!=0) {
            CFStringRef symbol;
            if(denominator_multiple_dimensions) symbol = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@/(%@)"), numerator,denominator);
            else symbol = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@/%@"), numerator,denominator);
            CFRelease(numerator);
            CFRelease(denominator);
            return symbol;
        }
        else {
            CFRelease(denominator);
            return numerator;
        }
    }
    else {
        if(CFStringGetLength(denominator)!=0) {
            CFStringRef symbol;
            if(denominator_multiple_dimensions) symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("1/(%@)"),denominator);
            else symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("1/%@"),denominator);
            CFRelease(numerator);
            CFRelease(denominator);
            return symbol;
        }
        else {
            return CFSTR("1");
        }
    }
}

CFStringRef PSDimensionalityCreateLaTeXSymbol(PSDimensionalityRef theDimensionality)
{
    
    /*
     *    This routine constructs a dimensionality latex symbol in terms of the seven base dimensions
     */
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
    CFMutableStringRef numerator = CFStringCreateMutable(NULL,0);
    
    CFMutableStringRef denominator = CFStringCreateMutable(NULL,0);
    bool denominator_multiple_dimensions = false;
    
    uint8_t exponent;
    
    // Numerator
    exponent = PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,0);
    if(exponent>0) {
        if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@$^{%d}$"),baseDimensionSymbol(0),exponent);
        else CFStringAppendFormat(numerator,NULL,CFSTR("%@"),baseDimensionSymbol(0));
    }
    for(uint8_t index = 1;index<7;index++) {
        exponent = PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,index);
        if(exponent>0) {
            if(CFStringGetLength(numerator)==0) {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@${^%d}$"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("%@"),baseDimensionSymbol(index));
                
            }
            else {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("$\\cdot$%@$^{%d}$"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("$\\cdot$%@"),baseDimensionSymbol(index));
            }
        }
    }
    
    // Denominator
    exponent = PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,0);
    if(exponent>0) {
        if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@^%d"),baseDimensionSymbol(0),exponent);
        else CFStringAppendFormat(denominator,NULL,CFSTR("%@"),baseDimensionSymbol(0));
        
    }
    for(uint8_t index = 1;index<7;index++) {
        exponent = PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,index);
        if(exponent>0) {
            if(CFStringGetLength(denominator)==0) {
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@^%d"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("%@"),baseDimensionSymbol(index));
                
            }
            else {
                denominator_multiple_dimensions = true;
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("$\\cdot$%@${^%d}$"),baseDimensionSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("$\\cdot$%@"),baseDimensionSymbol(index));
            }
        }
    }
    
    if(CFStringGetLength(numerator)!=0) {
        if(CFStringGetLength(denominator)!=0) {
            CFStringRef symbol;
            if(denominator_multiple_dimensions) symbol = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@/(%@)"), numerator,denominator);
            else symbol = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@/%@"), numerator,denominator);
            CFRelease(numerator);
            CFRelease(denominator);
            return symbol;
        }
        else {
            CFRelease(denominator);
            return numerator;
        }
    }
    else {
        if(CFStringGetLength(denominator)!=0) {
            CFStringRef symbol;
            if(denominator_multiple_dimensions) symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("1/(%@)"),denominator);
            else symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("1/%@"),denominator);
            CFRelease(numerator);
            CFRelease(denominator);
            return symbol;
        }
        else {
            return CFSTR("1");
        }
    }
}

/*
 @function PSDimensionalityCreate
 @abstract Creates a PSDimensionality.  
 @param length_numerator_exponent integer numerator exponent for length dimension
 @param length_denominator_exponent integer denominator exponent for length dimension
 @param mass_numerator_exponent integer numerator exponent for mass dimension
 @param mass_denominator_exponent integer denominator exponent for mass dimension
 @param time_numerator_exponent integer numerator exponent for time dimension
 @param time_denominator_exponent integer denominator exponent for time dimension
 @param current_numerator_exponent integer numerator exponent for current dimension
 @param current_denominator_exponent integer denominator exponent for current dimension
 @param temperature_numerator_exponent integer numerator exponent for temperature dimension
 @param temperature_denominator_exponent integer denominator exponent for temperature dimension
 @param amount_numerator_exponent integer numerator exponent for amount dimension
 @param amount_denominator_exponent integer denominator exponent for amount dimension
 @param luminous_intensity_numerator_exponent integer numerator exponent for luminous intensity dimension
 @param luminous_intensity_denominator_exponent integer denominator exponent for luminous intensity dimension
 @result PSDimensionality object
 */
static PSDimensionalityRef PSDimensionalityCreate(uint8_t length_numerator_exponent,            uint8_t length_denominator_exponent,        
                                                  uint8_t mass_numerator_exponent,              uint8_t mass_denominator_exponent,        
                                                  uint8_t time_numerator_exponent,              uint8_t time_denominator_exponent,        
                                                  uint8_t current_numerator_exponent,           uint8_t current_denominator_exponent,        
                                                  uint8_t temperature_numerator_exponent,       uint8_t temperature_denominator_exponent,        
                                                  uint8_t amount_numerator_exponent,            uint8_t amount_denominator_exponent,        
                                                  uint8_t luminous_intensity_numerator_exponent,uint8_t luminous_intensity_denominator_exponent)
{
    // Initialize object
    
    PSDimensionality *newDimensionality = [PSDimensionality alloc];

    newDimensionality->staticInstance = false;
    //  setup attributes
    newDimensionality->numerator_exponent[kPSLengthIndex] = length_numerator_exponent;
    newDimensionality->denominator_exponent[kPSLengthIndex] = length_denominator_exponent;
    newDimensionality->numerator_exponent[kPSMassIndex] = mass_numerator_exponent;
    newDimensionality->denominator_exponent[kPSMassIndex] = mass_denominator_exponent;
    newDimensionality->numerator_exponent[kPSTimeIndex] = time_numerator_exponent;
    newDimensionality->denominator_exponent[kPSTimeIndex] = time_denominator_exponent;
    newDimensionality->numerator_exponent[kPSCurrentIndex] = current_numerator_exponent;
    newDimensionality->denominator_exponent[kPSCurrentIndex] = current_denominator_exponent;
    newDimensionality->numerator_exponent[kPSTemperatureIndex] = temperature_numerator_exponent;
    newDimensionality->denominator_exponent[kPSTemperatureIndex] = temperature_denominator_exponent;
    newDimensionality->numerator_exponent[kPSAmountIndex] = amount_numerator_exponent;
    newDimensionality->denominator_exponent[kPSAmountIndex] = amount_denominator_exponent;
    newDimensionality->numerator_exponent[kPSLuminousIntensityIndex] = luminous_intensity_numerator_exponent;
    newDimensionality->denominator_exponent[kPSLuminousIntensityIndex] = luminous_intensity_denominator_exponent;
    
    newDimensionality->symbol = PSDimensionalityCreateSymbol(newDimensionality);
    
    return (PSDimensionalityRef) newDimensionality;
}


#pragma mark Accessors

CFStringRef PSDimensionalityGetSymbol(PSDimensionalityRef theDimensionality)
{
    return theDimensionality->symbol;
}


/*
 @function PSDimensionalityGetNumeratorExponentAtIndex
 @abstract Gets the numerator exponent for the dimension at index.
 @param theDimensionality The Dimensionality.
 @result the integer numerator exponent.
 @discussion base units length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
uint8_t PSDimensionalityGetNumeratorExponentAtIndex(PSDimensionalityRef theDimensionality, PSBaseDimensionIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,0)

    if(theDimensionality) return theDimensionality->numerator_exponent[index];
    return 0;
}

/*
 @function PSDimensionalityGetDenominatorExponentAtIndex
 @abstract Gets the denominator exponent for the dimension at index.
 @param theDimensionality The Dimensionality.
 @result the integer denominator exponent.
 @discussion base units length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
uint8_t PSDimensionalityGetDenominatorExponentAtIndex(PSDimensionalityRef theDimensionality, PSBaseDimensionIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,0)

	if(theDimensionality) return theDimensionality->denominator_exponent[index];
    return 0;
}

/*
 @function PSDimensionalityReducedExponentAtIndex
 @abstract Returns the exponent for the dimension at Index.
 @param theDimensionality The Dimensionality.
 @result the integer exponent (numerator-denominator).
 @discussion base units length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
int8_t PSDimensionalityReducedExponentAtIndex(PSDimensionalityRef theDimensionality, PSBaseDimensionIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,0)

	if(theDimensionality) return theDimensionality->numerator_exponent[index] - theDimensionality->denominator_exponent[index];
    return 0;
}

#pragma mark Tests

bool PSDimensionalityEqual(PSDimensionalityRef input1,PSDimensionalityRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,false)
    IF_NO_OBJECT_EXISTS_RETURN(input2,false)
    
    if(NULL==input1) return false;
    if(NULL==input2) return false;
    
    if(input1==input2) return true;
    
	for(int i=0;i<7;i++) {
		if(input1->numerator_exponent[i] != input2->numerator_exponent[i]) return false;
		if(input1->denominator_exponent[i] != input2->denominator_exponent[i]) return false;
	}

    return true;
}

bool PSDimensionalityIsDimensionless(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,false)
    
    for(PSBaseDimensionIndex index=0;index<7;index++) {
        int theDimensionality_exponent = theDimensionality->numerator_exponent[index] - theDimensionality->denominator_exponent[index];
        if(theDimensionality_exponent != 0) return false;
    }
    return true;
}

bool PSDimensionalityIsDimensionlessAndNotDerived(PSDimensionalityRef theDimensionality)
{
    // To be dimensionless and not derived all the numerator and denominator exponents must be 0
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,false)
    for(PSBaseDimensionIndex index=0;index<7;index++) {
        if(theDimensionality->numerator_exponent[index] != 0) return false;
        if(theDimensionality->denominator_exponent[index] != 0) return false;
    }
    return true;
}

bool PSDimensionalityIsDimensionlessAndDerived(PSDimensionalityRef theDimensionality)
{
    if(PSDimensionalityIsDimensionlessAndNotDerived(theDimensionality)) return false;
    if(PSDimensionalityIsDimensionless(theDimensionality)) return true;
    return false;
}

bool PSDimensionalityIsBaseDimensionality(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,false)
    if(PSDimensionalityIsDimensionlessAndNotDerived(theDimensionality)) return false;
    // If it is base dimensionality, then all the denominator exponents must be 0
    // and all numerator exponents are zero except one, which is 1
    for(PSBaseDimensionIndex index=0;index<7;index++) if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality, index)  != 0) return false;
    int count = 0;
    for(PSBaseDimensionIndex index=0;index<7;index++) {
        if(theDimensionality->numerator_exponent[index]>1) return false;
        if(theDimensionality->numerator_exponent[index]==1) count++;
    }
    if(count==1) return true;
	return false;
}

bool PSDimensionalityIsDerived(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,false)
    if(PSDimensionalityIsDimensionlessAndNotDerived(theDimensionality)) return false;
    if(PSDimensionalityIsBaseDimensionality(theDimensionality)) return false;
    return true;
}


bool PSDimensionalityHasSameReducedDimensionality(PSDimensionalityRef theDimensionality1,PSDimensionalityRef theDimensionality2)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality1,NULL)
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality2,NULL)
	if(theDimensionality1==theDimensionality2) return true;
	
	for(int i=0;i<7;i++) {
		int theDimensionality1_exponent = theDimensionality1->numerator_exponent[i] - theDimensionality1->denominator_exponent[i];
		int theDimensionality2_exponent = theDimensionality2->numerator_exponent[i] - theDimensionality2->denominator_exponent[i];
		if(theDimensionality1_exponent != theDimensionality2_exponent) return false;
	}
	return true;
}

static bool PSDimensionalityHasExponents(PSDimensionalityRef theDimensionality,
                                         uint8_t length_numerator_exponent,             uint8_t length_denominator_exponent,
                                         uint8_t mass_numerator_exponent,               uint8_t mass_denominator_exponent,
                                         uint8_t time_numerator_exponent,               uint8_t time_denominator_exponent,
                                         uint8_t current_numerator_exponent,            uint8_t current_denominator_exponent,
                                         uint8_t temperature_numerator_exponent,        uint8_t temperature_denominator_exponent,
                                         uint8_t amount_numerator_exponent,             uint8_t amount_denominator_exponent,
                                         uint8_t luminous_intensity_numerator_exponent, uint8_t luminous_intensity_denominator_exponent)
{
    if(theDimensionality==NULL) theDimensionality = PSDimensionalityDimensionless();
    
    if(PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,kPSLengthIndex) != length_numerator_exponent) return false;
    if(PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,kPSMassIndex) != mass_numerator_exponent) return false;
    if(PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,kPSTimeIndex) != time_numerator_exponent) return false;
    if(PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,kPSCurrentIndex) != current_numerator_exponent) return false;
    if(PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,kPSTemperatureIndex) != temperature_numerator_exponent) return false;
    if(PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,kPSAmountIndex) != amount_numerator_exponent) return false;
    if(PSDimensionalityGetNumeratorExponentAtIndex(theDimensionality,kPSLuminousIntensityIndex) != luminous_intensity_numerator_exponent) return false;
    
    if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,kPSLengthIndex) != length_denominator_exponent) return false;
    if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,kPSMassIndex) != mass_denominator_exponent) return false;
    if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,kPSTimeIndex) != time_denominator_exponent) return false;
    if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,kPSCurrentIndex) != current_denominator_exponent) return false;
    if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,kPSTemperatureIndex) != temperature_denominator_exponent) return false;
    if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,kPSAmountIndex) != amount_denominator_exponent) return false;
    if(PSDimensionalityGetDenominatorExponentAtIndex(theDimensionality,kPSLuminousIntensityIndex) != luminous_intensity_denominator_exponent) return false;
    return true;
}

bool PSDimensionalityHasReducedExponents(PSDimensionalityRef theDimensionality,
                                         int8_t length_exponent,    
                                         int8_t mass_exponent,
                                         int8_t time_exponent,      
                                         int8_t current_exponent,
                                         int8_t temperature_exponent,
                                         int8_t amount_exponent,
                                         int8_t luminous_intensity_exponent)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
    if(PSDimensionalityReducedExponentAtIndex(theDimensionality,kPSLengthIndex) != length_exponent) return false;
    if(PSDimensionalityReducedExponentAtIndex(theDimensionality,kPSMassIndex) != mass_exponent) return false;
    if(PSDimensionalityReducedExponentAtIndex(theDimensionality,kPSTimeIndex) != time_exponent) return false;
    if(PSDimensionalityReducedExponentAtIndex(theDimensionality,kPSCurrentIndex) != current_exponent) return false;
    if(PSDimensionalityReducedExponentAtIndex(theDimensionality,kPSTemperatureIndex) != temperature_exponent) return false;
    if(PSDimensionalityReducedExponentAtIndex(theDimensionality,kPSAmountIndex) != amount_exponent) return false;
    if(PSDimensionalityReducedExponentAtIndex(theDimensionality,kPSLuminousIntensityIndex) != luminous_intensity_exponent) return false;
    return true;
}

/*
 @function PSDimensionalityHasSameDimensionlessAndDerivedDimensionalities
 @abstract Determines if the two Dimensionalities have the same dimensionless exponents, 
 @param theDimensionality1 The first Dimensionality.
 @param theDimensionality2 The second Dimensionality.
 @result true or false.
 */
static bool PSDimensionalityHasSameDimensionlessAndDerivedDimensionalities(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality1,NULL)
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality2,NULL)
    if(!PSDimensionalityIsDimensionlessAndDerived(theDimensionality1)) return false;
    if(!PSDimensionalityIsDimensionlessAndDerived(theDimensionality2)) return false;

    if(!PSDimensionalityEqual(theDimensionality1, theDimensionality2)) return false;
	return true;
}

#pragma mark Operations

static PSDimensionalityRef PSDimensionalityWithExponents(uint8_t length_numerator_exponent,             uint8_t length_denominator_exponent,               
                                                         uint8_t mass_numerator_exponent,               uint8_t mass_denominator_exponent,               
                                                         uint8_t time_numerator_exponent,               uint8_t time_denominator_exponent,               
                                                         uint8_t current_numerator_exponent,            uint8_t current_denominator_exponent,               
                                                         uint8_t temperature_numerator_exponent,        uint8_t temperature_denominator_exponent,               
                                                         uint8_t amount_numerator_exponent,             uint8_t amount_denominator_exponent,               
                                                         uint8_t luminous_intensity_numerator_exponent, uint8_t luminous_intensity_denominator_exponent)
{
    PSDimensionalityRef newDimensionality = PSDimensionalityCreate(length_numerator_exponent,               length_denominator_exponent,                         
                                                                   mass_numerator_exponent,                 mass_denominator_exponent,                         
                                                                   time_numerator_exponent,                 time_denominator_exponent,                         
                                                                   current_numerator_exponent,              current_denominator_exponent,                         
                                                                   temperature_numerator_exponent,          temperature_denominator_exponent,                         
                                                                   amount_numerator_exponent,               amount_denominator_exponent,                         
                                                                   luminous_intensity_numerator_exponent,   luminous_intensity_denominator_exponent);

    if(NULL == newDimensionality) return NULL;
    
    if(NULL==dimensionalityLibrary) DimensionalityLibraryBuild();
    if(CFDictionaryContainsKey(dimensionalityLibrary, newDimensionality->symbol)) {
        PSDimensionalityRef existingDimensionality = CFDictionaryGetValue(dimensionalityLibrary, newDimensionality->symbol);
        CFRelease(newDimensionality);
        return existingDimensionality;
    }
    
    newDimensionality->staticInstance = true;
    CFDictionaryAddValue(dimensionalityLibrary, newDimensionality->symbol, newDimensionality);
    CFRelease(newDimensionality);
    return newDimensionality;
}

PSDimensionalityRef PSDimensionalityWithBaseDimensionSymbol(CFStringRef theString)
{
    if(CFStringGetLength(theString)>1) {
        return NULL;
    }

    PSBaseDimensionIndex index;
    if(CFStringCompare(theString, CFSTR("L"), 0) == kCFCompareEqualTo) index = kPSLengthIndex;
    else if(CFStringCompare(theString, CFSTR("M"), 0) == kCFCompareEqualTo) index = kPSMassIndex;
    else if(CFStringCompare(theString, CFSTR("T"), 0) == kCFCompareEqualTo) index = kPSTimeIndex;
    else if(CFStringCompare(theString, CFSTR("I"), 0) == kCFCompareEqualTo) index = kPSCurrentIndex;
    else if(CFStringCompare(theString, CFSTR("ϴ"), 0) == kCFCompareEqualTo) index = kPSTemperatureIndex;
    else if(CFStringCompare(theString, CFSTR("@"), 0) == kCFCompareEqualTo) index = kPSTemperatureIndex;
    else if(CFStringCompare(theString, CFSTR("N"), 0) == kCFCompareEqualTo) index = kPSAmountIndex;
    else if(CFStringCompare(theString, CFSTR("J"), 0) == kCFCompareEqualTo) index = kPSLuminousIntensityIndex;
    else return NULL;
    
    return PSDimensionalityForBaseDimensionIndex(index);
}

PSDimensionalityRef PSDimensionalityByReducing(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
    uint8_t numerator_exponent[7];
    uint8_t denominator_exponent[7];
    
    for(int8_t i=0;i<7;i++) {
        int power = theDimensionality->numerator_exponent[i] - theDimensionality->denominator_exponent[i];
        if(power>0) {
            numerator_exponent[i] = power;
            denominator_exponent[i] = 0;
        }
        else if(power<0) {
            denominator_exponent[i] = -power;
            numerator_exponent[i] = 0;
        }
        else denominator_exponent[i] = numerator_exponent[i] = 0;
    }
    return PSDimensionalityWithExponents(numerator_exponent[kPSLengthIndex],            denominator_exponent[kPSLengthIndex],
                                         numerator_exponent[kPSMassIndex],              denominator_exponent[kPSMassIndex],
                                         numerator_exponent[kPSTimeIndex],              denominator_exponent[kPSTimeIndex],
                                         numerator_exponent[kPSCurrentIndex],           denominator_exponent[kPSCurrentIndex],
                                         numerator_exponent[kPSTemperatureIndex],       denominator_exponent[kPSTemperatureIndex],
                                         numerator_exponent[kPSAmountIndex],            denominator_exponent[kPSAmountIndex],
                                         numerator_exponent[kPSLuminousIntensityIndex], denominator_exponent[kPSLuminousIntensityIndex]);
}

PSDimensionalityRef PSDimensionalityByTakingNthRoot(PSDimensionalityRef theDimensionality, uint8_t root, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
    uint8_t numerator_exponent[7];
    uint8_t denominator_exponent[7];
    
    PSDimensionalityRef reducedDimensionality = PSDimensionalityByReducing(theDimensionality);
    
    for(int8_t i=0;i<7;i++) {
        if(reducedDimensionality->numerator_exponent[i]%root !=0 || reducedDimensionality->denominator_exponent[i]%root != 0) {
            if(error) {
                CFStringRef desc = CFSTR("Can't raise physical dimensionality to a non-integer power.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            return NULL;
        }
        numerator_exponent[i] = theDimensionality->numerator_exponent[i]/root;
        denominator_exponent[i] = theDimensionality->denominator_exponent[i]/root;
    }
    
    return PSDimensionalityWithExponents(numerator_exponent[kPSLengthIndex],            denominator_exponent[kPSLengthIndex],
                                         numerator_exponent[kPSMassIndex],              denominator_exponent[kPSMassIndex],
                                         numerator_exponent[kPSTimeIndex],              denominator_exponent[kPSTimeIndex],
                                         numerator_exponent[kPSCurrentIndex],           denominator_exponent[kPSCurrentIndex],
                                         numerator_exponent[kPSTemperatureIndex],       denominator_exponent[kPSTemperatureIndex],
                                         numerator_exponent[kPSAmountIndex],            denominator_exponent[kPSAmountIndex],
                                         numerator_exponent[kPSLuminousIntensityIndex], denominator_exponent[kPSLuminousIntensityIndex]);
}

PSDimensionalityRef PSDimensionalityByMultiplying(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    return PSDimensionalityByReducing(PSDimensionalityByMultiplyingWithoutReducing(theDimensionality1,theDimensionality2, error));
}

PSDimensionalityRef PSDimensionalityByMultiplyingWithoutReducing(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2, CFErrorRef *error)
{
	/*
	 *	This routine will create an derived SI Dimensionality formed by the product of two Dimensionalities.
	 *	It will additionally return a multiplier for the numerical part of the quantity product
	 *	
	 */
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality1,NULL)
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality2,NULL)
    if(theDimensionality1 == theDimensionality2)
        return PSDimensionalityByRaisingToAPowerWithoutReducing(theDimensionality1, 2, error);
    
	uint8_t numerator_exponent[7];
	uint8_t denominator_exponent[7];
    for(uint8_t i=0;i<7;i++) {
        numerator_exponent[i] = theDimensionality1->numerator_exponent[i]+theDimensionality2->numerator_exponent[i];
        denominator_exponent[i] = theDimensionality1->denominator_exponent[i]+theDimensionality2->denominator_exponent[i];
    }
    return PSDimensionalityWithExponents(numerator_exponent[kPSLengthIndex],            denominator_exponent[kPSLengthIndex],
                                         numerator_exponent[kPSMassIndex],              denominator_exponent[kPSMassIndex],
                                         numerator_exponent[kPSTimeIndex],              denominator_exponent[kPSTimeIndex],
                                         numerator_exponent[kPSCurrentIndex],           denominator_exponent[kPSCurrentIndex],
                                         numerator_exponent[kPSTemperatureIndex],       denominator_exponent[kPSTemperatureIndex],
                                         numerator_exponent[kPSAmountIndex],            denominator_exponent[kPSAmountIndex],
                                         numerator_exponent[kPSLuminousIntensityIndex], denominator_exponent[kPSLuminousIntensityIndex]);
}

PSDimensionalityRef PSDimensionalityByDividing(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2)
{
    return PSDimensionalityByReducing(PSDimensionalityByDividingWithoutReducing(theDimensionality1,theDimensionality2));    
}

PSDimensionalityRef PSDimensionalityByDividingWithoutReducing(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2)
{
	/*
	 *	This routine will create an derived SI Dimensionality formed by the division of theDimensionality1 by theDimensionality2.
	 *	It will additionally return a multiplier for the numerical part of the quantity product
	 *	
	 */
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality1,NULL)
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality2,NULL)

	uint8_t numerator_exponent[7];
	uint8_t denominator_exponent[7];
    for(uint8_t i=0;i<7;i++) {
        numerator_exponent[i] = theDimensionality1->numerator_exponent[i]+theDimensionality2->denominator_exponent[i];
        denominator_exponent[i] = theDimensionality1->denominator_exponent[i]+theDimensionality2->numerator_exponent[i];
    }
    return PSDimensionalityWithExponents(numerator_exponent[kPSLengthIndex],            denominator_exponent[kPSLengthIndex],
                                         numerator_exponent[kPSMassIndex],              denominator_exponent[kPSMassIndex],
                                         numerator_exponent[kPSTimeIndex],              denominator_exponent[kPSTimeIndex],
                                         numerator_exponent[kPSCurrentIndex],           denominator_exponent[kPSCurrentIndex],
                                         numerator_exponent[kPSTemperatureIndex],       denominator_exponent[kPSTemperatureIndex],
                                         numerator_exponent[kPSAmountIndex],            denominator_exponent[kPSAmountIndex],
                                         numerator_exponent[kPSLuminousIntensityIndex], denominator_exponent[kPSLuminousIntensityIndex]);
}

PSDimensionalityRef PSDimensionalityByRaisingToAPower(PSDimensionalityRef theDimensionality, double power, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    return PSDimensionalityByReducing(PSDimensionalityByRaisingToAPowerWithoutReducing(theDimensionality,power, error));
}

PSDimensionalityRef PSDimensionalityByRaisingToAPowerWithoutReducing(PSDimensionalityRef theDimensionality, double power, CFErrorRef *error)
{
	/*
	 *	This routine will create an derived SI Dimensionality formed by the raising theDimensionality to a power.
	 *	It will additionally return a multiplier for the numerical part of the quantity product
	 *
	 */
    
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
    CFIndex pow = (CFIndex) floor(power);
    double fraction = power -  pow;
    if(PSCompareDoubleValues(fraction, 0.0) != kPSCompareEqualTo) {
        CFIndex root = (CFIndex) floor(1./power);
        fraction = 1./power -  root;
        if(PSCompareDoubleValues(fraction, 0.0) == kPSCompareEqualTo)
            return PSDimensionalityByTakingNthRoot(theDimensionality, root, error);
        else {
            if(error) {
                CFStringRef desc = CFSTR("Can't raise physical dimensionality to a non-integer power.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            return NULL;
        }
    }
    
	uint8_t numerator_exponent[7];
	uint8_t denominator_exponent[7];
    for(uint8_t i=0;i<7;i++) {
        if(pow>0) {
            numerator_exponent[i] = theDimensionality->numerator_exponent[i]*pow;
            denominator_exponent[i] = theDimensionality->denominator_exponent[i]*pow;
        }
        else {
            numerator_exponent[i] = theDimensionality->denominator_exponent[i]*(-pow);
            denominator_exponent[i] = theDimensionality->numerator_exponent[i]*(-pow);
        }
    }
    return PSDimensionalityWithExponents(numerator_exponent[kPSLengthIndex],            denominator_exponent[kPSLengthIndex],
                                         numerator_exponent[kPSMassIndex],              denominator_exponent[kPSMassIndex],
                                         numerator_exponent[kPSTimeIndex],              denominator_exponent[kPSTimeIndex],
                                         numerator_exponent[kPSCurrentIndex],           denominator_exponent[kPSCurrentIndex],
                                         numerator_exponent[kPSTemperatureIndex],       denominator_exponent[kPSTemperatureIndex],
                                         numerator_exponent[kPSAmountIndex],            denominator_exponent[kPSAmountIndex],
                                         numerator_exponent[kPSLuminousIntensityIndex], denominator_exponent[kPSLuminousIntensityIndex]);
}

PSDimensionalityRef PSDimensionalityDimensionless()
{
    return PSDimensionalityWithExponents(0,0,   0,0,    0,0,    0,0,    0,0,    0,0,    0,0);
}

PSDimensionalityRef PSDimensionalityForBaseDimensionIndex(PSBaseDimensionIndex index)
{
    switch (index) {
        case kPSLengthIndex:
            return PSDimensionalityWithExponents(1,0,   0,0,    0,0,    0,0,    0,0,    0,0,    0,0);
            
        case kPSMassIndex:
            return PSDimensionalityWithExponents(0,0,   1,0,    0,0,    0,0,    0,0,    0,0,    0,0);
            
        case kPSTimeIndex:
            return PSDimensionalityWithExponents(0,0,   0,0,    1,0,    0,0,    0,0,    0,0,    0,0);
            
        case kPSCurrentIndex:
            return PSDimensionalityWithExponents(0,0,   0,0,    0,0,    1,0,    0,0,    0,0,    0,0);
            
        case kPSTemperatureIndex:
            return PSDimensionalityWithExponents(0,0,   0,0,    0,0,    0,0,    1,0,    0,0,    0,0);
            
        case kPSAmountIndex:
            return PSDimensionalityWithExponents(0,0,   0,0,    0,0,    0,0,    0,0,    1,0,    0,0);
            
        case kPSLuminousIntensityIndex:
            return PSDimensionalityWithExponents(0,0,   0,0,    0,0,    0,0,    0,0,    0,0,    1,0);
    } 
    return NULL;
}

static CFComparisonResult stringSort(const void *val1, const void *val2, void *context)
{
    CFStringRef string1 = (CFStringRef) val1;
    CFStringRef string2 = (CFStringRef) val2;
    return CFStringCompare(string1, string2, kCFCompareCaseInsensitive);
}

CFArrayRef PSDimensionalityCreateArrayOfQuantityNames(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
    if(NULL==dimensionalityQuantitiesLibrary) DimensionalityLibraryBuild();
    CFIndex count = CFDictionaryGetCountOfValue(dimensionalityQuantitiesLibrary, theDimensionality);
    if(0==count) return NULL;
    CFStringRef quantities[count];
    
    CFIndex totalCount = CFDictionaryGetCount(dimensionalityQuantitiesLibrary);
    CFStringRef keys[totalCount];
    PSDimensionalityRef dimensionalities[totalCount];
    
    CFDictionaryGetKeysAndValues(dimensionalityQuantitiesLibrary, (CFTypeRef *) keys, (CFTypeRef *)  dimensionalities);
    CFIndex i=0;
    for(CFIndex index=0; index<totalCount; index++) {
        if(PSDimensionalityEqual(dimensionalities[index], theDimensionality)) {
            quantities[i++] = keys[index];
        }
    }
    CFArrayRef result = NULL;
    if(i==count) result = CFArrayCreate(kCFAllocatorDefault, (CFTypeRef *) quantities, count, &kCFTypeArrayCallBacks);
    else return result;
    
    CFMutableArrayRef sortedArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, count, result);
    if(result) CFRelease(result);
    
    CFArraySortValues(sortedArray, CFRangeMake(0, count), stringSort, NULL);
    return sortedArray;
}

CFArrayRef PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality(PSDimensionalityRef theDimensionality)
{
    CFArrayRef reducedDimensionalities = PSDimensionalityCreateArrayWithSameReducedDimensionality(theDimensionality);
    CFMutableArrayRef result = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dimensionalityIndex = 0; dimensionalityIndex <CFArrayGetCount(reducedDimensionalities); dimensionalityIndex++) {
        PSDimensionalityRef dimensionality = CFArrayGetValueAtIndex(reducedDimensionalities, dimensionalityIndex);
        CFArrayRef quantities = PSDimensionalityCreateArrayOfQuantityNames(dimensionality);
        if(quantities) {
            CFArrayAppendArray(result, quantities, CFRangeMake(0, CFArrayGetCount(quantities)));
            CFRelease(quantities);
        }
        else {
            CFMutableStringRef quantityName = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, CFSTR("Dimensionality: "));
            CFStringAppend(quantityName, PSDimensionalityGetSymbol(dimensionality));
            CFArrayAppendValue(result, quantityName);
        }
    }
    CFRelease(reducedDimensionalities);
    return result;
}

CFArrayRef PSDimensionalityCreateArrayWithSameReducedDimensionality(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    if(NULL==dimensionalityQuantitiesLibrary) DimensionalityLibraryBuild();
    
    int8_t reducedLength = theDimensionality->numerator_exponent[kPSLengthIndex] - theDimensionality->denominator_exponent[kPSLengthIndex];
    int8_t largestLength = theDimensionality->numerator_exponent[kPSLengthIndex];
    if(reducedLength < 0 ) largestLength = theDimensionality->denominator_exponent[kPSLengthIndex];

    int8_t reducedMass = theDimensionality->numerator_exponent[kPSMassIndex] - theDimensionality->denominator_exponent[kPSMassIndex];
    int8_t largestMass = theDimensionality->numerator_exponent[kPSMassIndex];
    if(reducedMass < 0 ) largestMass = theDimensionality->denominator_exponent[kPSMassIndex];

    int8_t reducedTime= theDimensionality->numerator_exponent[kPSTimeIndex] - theDimensionality->denominator_exponent[kPSTimeIndex];
    int8_t largestTime = theDimensionality->numerator_exponent[kPSTimeIndex];
    if(reducedTime < 0 ) largestTime = theDimensionality->denominator_exponent[kPSTimeIndex];

    int8_t reducedCurrent = theDimensionality->numerator_exponent[kPSCurrentIndex] - theDimensionality->denominator_exponent[kPSCurrentIndex];
    int8_t largestCurrent = theDimensionality->numerator_exponent[kPSCurrentIndex];
    if(reducedCurrent < 0 ) largestCurrent = theDimensionality->denominator_exponent[kPSCurrentIndex];

    int8_t reducedTemperature = theDimensionality->numerator_exponent[kPSTemperatureIndex] - theDimensionality->denominator_exponent[kPSTemperatureIndex];
    int8_t largestTemperature = theDimensionality->numerator_exponent[kPSTemperatureIndex];
    if(reducedTemperature < 0 ) largestTemperature = theDimensionality->denominator_exponent[kPSTemperatureIndex];

    int8_t reducedAmount = theDimensionality->numerator_exponent[kPSAmountIndex] - theDimensionality->denominator_exponent[kPSAmountIndex];
    int8_t largestAmount = theDimensionality->numerator_exponent[kPSAmountIndex];
    if(reducedAmount < 0 ) largestAmount = theDimensionality->denominator_exponent[kPSAmountIndex];

    int8_t reducedLuminous = theDimensionality->numerator_exponent[kPSLuminousIntensityIndex] - theDimensionality->denominator_exponent[kPSLuminousIntensityIndex];
    int8_t largestLuminous = theDimensionality->numerator_exponent[kPSLuminousIntensityIndex];
    if(reducedLuminous < 0 ) largestLuminous = theDimensionality->denominator_exponent[kPSLuminousIntensityIndex];

    CFMutableArrayRef result = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    if(result)  {
        for(int8_t iLength = largestLength;iLength>=abs(reducedLength);iLength--) {
            int8_t length_numerator = iLength;
            int8_t length_denominator = iLength - abs(reducedLength);
            if(reducedLength < 0) {
                length_numerator = iLength - abs(reducedLength);
                length_denominator = iLength;
            }
            for(int8_t iMass = largestMass;iMass>=abs(reducedMass);iMass--) {
                int8_t mass_numerator = iMass;
                int8_t mass_denominator = iMass - abs(reducedMass);
                if(reducedMass < 0) {
                    mass_numerator = iMass - abs(reducedMass);
                    mass_denominator = iMass;
                }
                for(int8_t iTime = largestTime;iTime>=abs(reducedTime);iTime--) {
                    int8_t time_numerator = iTime;
                    int8_t time_denominator = iTime - abs(reducedTime);
                    if(reducedTime < 0) {
                        time_numerator = iTime - abs(reducedTime);
                        time_denominator = iTime;
                    }
                    for(int8_t iCurrent = largestCurrent;iCurrent>=abs(reducedCurrent);iCurrent--) {
                        int8_t current_numerator = iCurrent;
                        int8_t current_denominator = iCurrent - abs(reducedCurrent);
                        if(reducedCurrent < 0) {
                            current_numerator = iCurrent - abs(reducedCurrent);
                            current_denominator = iCurrent;
                        }
                        for(int8_t iTemp = largestTemperature;iTemp>=abs(reducedTemperature);iTemp--) {
                            int8_t temperature_numerator = iTemp;
                            int8_t temperature_denominator = iTemp - abs(reducedTemperature);
                            if(reducedTemperature < 0) {
                                temperature_numerator = iTemp - abs(reducedTemperature);
                                temperature_denominator = iTemp;
                            }
                            for(int8_t iAmount = largestAmount;iAmount>=abs(reducedAmount);iAmount--) {
                                int8_t amount_numerator = iAmount;
                                int8_t amount_denominator = iAmount - abs(reducedAmount);
                                if(reducedAmount < 0) {
                                    amount_numerator = iAmount - abs(reducedAmount);
                                    amount_denominator = iAmount;
                                }
                                for(int8_t iLuminous = largestLuminous;iLuminous>=abs(reducedLuminous);iLuminous--) {
                                    int8_t luminous_numerator = iLuminous;
                                    int8_t luminous_denominator = iLuminous - abs(reducedLuminous);
                                    if(reducedLuminous < 0) {
                                        luminous_numerator = iLuminous - abs(reducedLuminous);
                                        luminous_denominator = iLuminous;
                                    }
                                    PSDimensionalityRef dimensionality = PSDimensionalityWithExponents(length_numerator,    length_denominator,
                                                                                                       mass_numerator,      mass_denominator,
                                                                                                       time_numerator,      time_denominator,
                                                                                                       current_numerator,   current_denominator,
                                                                                                       temperature_numerator,temperature_denominator,
                                                                                                       amount_numerator,      amount_denominator,
                                                                                                       luminous_numerator,  luminous_denominator);
                                    CFArrayAppendValue(result, dimensionality);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return result;
}


typedef struct {
    float r;       // percent
    float g;       // percent
    float b;       // percent
} rgb;

typedef struct {
    float h;       // angle in degrees
    float s;       // percent
    float v;       // percent
} hsv;

static hsv      rgb2hsv(rgb in);
static rgb      hsv2rgb(hsv in);

rgb hsv2rgb(hsv in)
{
    double      hh, p, q, t, ff;
    long        i;
    rgb         out;
    
    if(in.s <= 0.0) {       // < is bogus, just shuts up warnings
        out.r = in.v;
        out.g = in.v;
        out.b = in.v;
        return out;
    }
    hh = in.h;
    while(hh >= 360.0) hh -= 360.;
    while(hh < 0.0) hh += 360.;
    hh /= 60.0;
    i = (long)hh;
    ff = hh - i;
    p = in.v * (1.0 - in.s);
    q = in.v * (1.0 - (in.s * ff));
    t = in.v * (1.0 - (in.s * (1.0 - ff)));
    
    switch(i) {
        case 0:
            out.r = in.v;
            out.g = t;
            out.b = p;
            break;
        case 1:
            out.r = q;
            out.g = in.v;
            out.b = p;
            break;
        case 2:
            out.r = p;
            out.g = in.v;
            out.b = t;
            break;
            
        case 3:
            out.r = p;
            out.g = q;
            out.b = in.v;
            break;
        case 4:
            out.r = t;
            out.g = p;
            out.b = in.v;
            break;
        case 5:
        default:
            out.r = in.v;
            out.g = p;
            out.b = q;
            break;
    }
    return out;
}

void PSDimensionalityRGBColorForDimensionality(PSDimensionalityRef theDimensionality, float *red, float *green, float *blue)
{
    hsv dimensionless_hsv = {215.,.26,.36};
    rgb dimensionless_rgb = hsv2rgb(dimensionless_hsv);
    
    *red = dimensionless_rgb.r;
    *green = dimensionless_rgb.g;
    *blue = dimensionless_rgb.b;
    if(PSDimensionalityIsDimensionless(theDimensionality)) return;
    
    int8_t length = PSDimensionalityReducedExponentAtIndex(theDimensionality, kPSLengthIndex);
    int8_t time = PSDimensionalityReducedExponentAtIndex(theDimensionality, kPSTimeIndex);
    int8_t mass = PSDimensionalityReducedExponentAtIndex(theDimensionality, kPSMassIndex);
    int8_t amount = PSDimensionalityReducedExponentAtIndex(theDimensionality, kPSAmountIndex);
    int8_t luminous = PSDimensionalityReducedExponentAtIndex(theDimensionality, kPSLuminousIntensityIndex);
    int8_t temperature = PSDimensionalityReducedExponentAtIndex(theDimensionality, kPSTemperatureIndex);
    int8_t current = PSDimensionalityReducedExponentAtIndex(theDimensionality, kPSCurrentIndex);

    float saturation = 0.4;
    float brightness = 0.4;
    float hue = 0;
    float reduction = 0.05;
    float hue_step = 15;
    int divisor = 0;
    
    rgb temperature_rgb = {0,0,0};
    if(temperature) {
        hsv temperature_hsv;
        temperature_hsv.h = hue + 180*(temperature<0) + hue_step*(abs(temperature)-1)/2;
        temperature_hsv.s = saturation - (abs(temperature)-1)*reduction;
        temperature_hsv.v = brightness - (abs(temperature)-1)*reduction;
        temperature_rgb = hsv2rgb(temperature_hsv);
        divisor++;
    }
    
    hue_step = 20;
    hue += hue_step;
    rgb amount_rgb = {0,0,0};
    if(amount) {
        hsv amount_hsv;
        amount_hsv.h = hue + 180*(amount<0) + hue_step*(abs(amount)-1);
        amount_hsv.s = saturation - (abs(amount)-1)*reduction;
        amount_hsv.v = brightness - (abs(amount)-1)*reduction;
        amount_rgb = hsv2rgb(amount_hsv);
        divisor++;
    }

    hue_step = 20;
    hue += hue_step;
    rgb mass_rgb = {0,0,0};
    if(mass) {
        hsv mass_hsv;
        mass_hsv.h = hue + 180*(mass<0) + hue_step*(abs(mass)-1)*10;
        mass_hsv.s = saturation - (abs(mass)-1)*reduction;
        mass_hsv.v = brightness - (abs(mass)-1)*reduction;
        mass_rgb = hsv2rgb(mass_hsv);
        divisor++;
    }


    hue_step = 30;
    hue += hue_step;

    
    rgb time_rgb = {0,0,0};
    if(time) {
        hsv time_hsv;
        time_hsv.h = hue + 90*(time<0) - hue_step*(abs(time)-1)*2;
        time_hsv.s = saturation - (abs(time)-1)*reduction;
        time_hsv.v = brightness - (abs(time)-1)*reduction;
        time_rgb = hsv2rgb(time_hsv);
        divisor++;
    }
    hue_step = 75;
    hue += hue_step;
    
    rgb current_rgb = {0,0,0};
    if(current) {
        hsv current_hsv;
        current_hsv.h = hue + 180*(current<0) + hue_step*(abs(current)-1)/6;
        current_hsv.s = saturation - (abs(current)-1)*reduction/2;
        current_hsv.v = brightness - (abs(current)-1)*reduction/2;
        current_rgb = hsv2rgb(current_hsv);
        divisor++;
    }

    hue_step = 50;
    hue += hue_step;

    
    rgb length_rgb = {0,0,0};
    if(length) {
        hsv length_hsv;
        length_hsv.h = hue + 180*(length<0) - hue_step*(abs(length)-1)/6;
        length_hsv.s = saturation - (abs(length)-1)*reduction/1.5;
        length_hsv.v = brightness - (abs(length)-1)*reduction/1.5;
        length_rgb = hsv2rgb(length_hsv);
        divisor++;
    }


    hue_step = 100;
    hue += hue_step;
    rgb luminous_rgb = {0,0,0};
    if(luminous) {
        hsv luminous_hsv;
        luminous_hsv.h = hue + 180*(luminous<0) + hue_step*abs(luminous-1)/2;
        luminous_hsv.s = saturation - abs(luminous-1)*reduction;
        luminous_hsv.v = brightness - abs(luminous-1)*reduction;
        luminous_rgb = hsv2rgb(luminous_hsv);
        divisor++;
    }

    
    if(divisor) {
        *red =      (luminous_rgb.r + temperature_rgb.r + current_rgb.r + time_rgb.r + length_rgb.r + mass_rgb.r + amount_rgb.r)/divisor;
        *green =    (luminous_rgb.g + temperature_rgb.g + current_rgb.g + time_rgb.g + length_rgb.g + mass_rgb.g + amount_rgb.g)/divisor;
        *blue =     (luminous_rgb.b + temperature_rgb.b + current_rgb.b + time_rgb.b + length_rgb.b + mass_rgb.b + amount_rgb.b)/divisor;
    }
    else {
        hsv dimensionless_hsv = {215.,.26,.36};
        rgb dimensionless_rgb = hsv2rgb(dimensionless_hsv);

        *red = dimensionless_rgb.r;
        *green = dimensionless_rgb.g;
        *blue = dimensionless_rgb.b;
    }
}

#pragma mark Strings and Archiving

CFDataRef PSDimensionalityCreateData(PSDimensionalityRef theDimensionality, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)

    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFDataRef numerators = CFDataCreate(kCFAllocatorDefault, theDimensionality->numerator_exponent, 7);
    CFDictionarySetValue(dictionary, CFSTR("numerators"), numerators);
    CFRelease(numerators);
    
    CFDataRef denominators = CFDataCreate(kCFAllocatorDefault, theDimensionality->denominator_exponent, 7);
    CFDictionarySetValue(dictionary, CFSTR("denominators"), denominators);
    CFRelease(denominators);

    CFDataRef data = CFPropertyListCreateData (kCFAllocatorDefault,dictionary,kCFPropertyListBinaryFormat_v1_0,0,error);
    CFRelease(dictionary);
    return data;
}

PSDimensionalityRef PSDimensionalityWithData(CFDataRef data, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(data,NULL)
    CFPropertyListFormat format;
    CFDictionaryRef dictionary  = CFPropertyListCreateWithData (kCFAllocatorDefault,data,kCFPropertyListImmutable,&format,error);

    uint8_t numerator_exponent[7];
    CFDataRef numerator_data = CFDictionaryGetValue(dictionary, CFSTR("numerators"));
    if(numerator_data==NULL) {
        CFRelease(dictionary);
        return NULL;
    }
    CFDataGetBytes(numerator_data, CFRangeMake(0, 7), numerator_exponent);

    uint8_t denominator_exponent[7];
    CFDataRef denominator_data = CFDictionaryGetValue(dictionary, CFSTR("denominators"));
    if(denominator_data==NULL) {
        CFRelease(dictionary);
        return NULL;
    }
    CFDataGetBytes(denominator_data, CFRangeMake(0, 7), denominator_exponent);
    CFRelease(dictionary);
    
    return PSDimensionalityWithExponents(numerator_exponent[0], denominator_exponent[0],
                                         numerator_exponent[1], denominator_exponent[1],
                                         numerator_exponent[2], denominator_exponent[2],
                                         numerator_exponent[3], denominator_exponent[3],
                                         numerator_exponent[4], denominator_exponent[4],
                                         numerator_exponent[5], denominator_exponent[5],
                                         numerator_exponent[6], denominator_exponent[6]);
}

void PSDimensionalityShow(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,)
    PSCFStringShow((theDimensionality)->symbol);
    fprintf(stdout, "\n");
}

void PSDimensionalityShowFull(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,)

    CFShow(CFSTR("============================================================================================================="));
    
    CFStringRef cf_string;
    
    CFShow(CFSTR("                                            m  kg   s   A   K  mol cd"));
    CFShow(CFSTR("-------------------------------------------------------------------------------------------------------------"));
    
    cf_string = CFStringCreateWithFormat(kCFAllocatorDefault, 
                                         NULL,
                                         CFSTR("SI base dimension numerator exponents:    %3d %3d %3d %3d %3d %3d %3d"),
                                         theDimensionality->numerator_exponent[kPSLengthIndex],
                                         theDimensionality->numerator_exponent[kPSMassIndex],
                                         theDimensionality->numerator_exponent[kPSTimeIndex],
                                         theDimensionality->numerator_exponent[kPSCurrentIndex],
                                         theDimensionality->numerator_exponent[kPSTemperatureIndex],
                                         theDimensionality->numerator_exponent[kPSAmountIndex],
                                         theDimensionality->numerator_exponent[kPSLuminousIntensityIndex]
                                         );
    CFShow(cf_string);
    CFRelease(cf_string);
    
    cf_string = CFStringCreateWithFormat(kCFAllocatorDefault, 
                                         NULL,
                                         CFSTR("SI base dimension denominator exponents:  %3d %3d %3d %3d %3d %3d %3d"),
                                         theDimensionality->denominator_exponent[kPSLengthIndex],
                                         theDimensionality->denominator_exponent[kPSMassIndex],
                                         theDimensionality->denominator_exponent[kPSTimeIndex],
                                         theDimensionality->denominator_exponent[kPSCurrentIndex],
                                         theDimensionality->denominator_exponent[kPSTemperatureIndex],
                                         theDimensionality->denominator_exponent[kPSAmountIndex],
                                         theDimensionality->denominator_exponent[kPSLuminousIntensityIndex]
                                         );
    CFShow(cf_string);
    CFRelease(cf_string);
    
    
    CFShow(CFSTR("-------------------------------------------------------------------------------------------------------------"));
    
    char string[256];
    CFStringGetCString(theDimensionality->symbol, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr," %s \t ",string);
    
    CFArrayRef quantityNames = PSDimensionalityCreateArrayOfQuantityNames(theDimensionality);
    if(quantityNames) {
        for(CFIndex index=0;index<CFArrayGetCount(quantityNames);index++) {
            CFStringRef quantityName = CFArrayGetValueAtIndex(quantityNames, index);
            CFStringGetCString(quantityName, string, 256, kCFStringEncodingUTF8);
            if(index!= CFArrayGetCount(quantityNames)-1) fprintf(stderr," %s,",string);
            else fprintf(stderr," %s",string);
        }
        CFRelease(quantityNames);
    }
    CFShow(CFSTR("\n============================================================================================================="));

    fprintf(stderr,"\n\n");
}

#pragma mark Library

static PSDimensionalityRef AddDimensionalityToLibrary(uint8_t length_numerator_exponent,            uint8_t length_denominator_exponent,
                                                      uint8_t mass_numerator_exponent,              uint8_t mass_denominator_exponent,            
                                                      uint8_t time_numerator_exponent,              uint8_t time_denominator_exponent,            
                                                      uint8_t current_numerator_exponent,           uint8_t current_denominator_exponent,            
                                                      uint8_t temperature_numerator_exponent,       uint8_t temperature_denominator_exponent,            
                                                      uint8_t amount_numerator_exponent,            uint8_t amount_denominator_exponent,            
                                                      uint8_t luminous_intensity_numerator_exponent,uint8_t luminous_intensity_denominator_exponent)
{
    PSDimensionalityRef dimensionality = PSDimensionalityCreate(length_numerator_exponent,               length_denominator_exponent,                      
                                                                mass_numerator_exponent,                 mass_denominator_exponent,                      
                                                                time_numerator_exponent,                 time_denominator_exponent,                      
                                                                current_numerator_exponent,              current_denominator_exponent,                      
                                                                temperature_numerator_exponent,          temperature_denominator_exponent,                      
                                                                amount_numerator_exponent,               amount_denominator_exponent,                      
                                                                luminous_intensity_numerator_exponent,   luminous_intensity_denominator_exponent);

    dimensionality->staticInstance = true;
    CFDictionaryAddValue(dimensionalityLibrary, dimensionality->symbol, dimensionality);
    CFRelease(dimensionality);
    return dimensionality;
}

static void DimensionalityLibraryBuild(void)
{    
    dimensionalityLibrary  = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    dimensionalityQuantitiesLibrary  = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    PSDimensionalityRef dimensionality;
    
    // Base Root Name and Root Symbol Units - Table 1
    
    // ***** Dimensionless **********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityDimensionless
    // Dimensionless                           length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityDimensionless,dimensionality);
    
    
    // ***** Length *****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityLength
    // Length                                   length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(1,0,       0,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLength,dimensionality);
    
    // Wavenumber, Inverse Length
    dimensionality  = AddDimensionalityToLibrary(0,1,       0,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityWavenumber,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseLength,dimensionality);

    // Plane Angle, Length Ratio
    dimensionality  = AddDimensionalityToLibrary(1,1,       0,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPlaneAngle,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLengthRatio,dimensionality);
    

    // ***** Mass *******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMass
    // Mass                                     length      mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,        1,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMass,dimensionality);
    
    // Inverse Mass                                     length      mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,        0,1,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseMass,dimensionality);
    
    // Mass Ratio                               length      mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,        1,1,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMassRatio,dimensionality);
    
    
    // ***** Time *******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityTime
    // Time                                     length      mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,        0,0,        1,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityTime,dimensionality);
    
    // Inverse Time, Frequency, Radioactivity
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,        0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFrequency,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRadioactivity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseTime,dimensionality);
    
    // Time, Frequency Ratio
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,        1,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityTimeRatio,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFrequencyRatio,dimensionality);

    // Inverse Time Squared
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseTimeSquared,dimensionality);
    
    // ***** Current ****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityCurrent
    // Current                                  length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        1,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCurrent,dimensionality);
    
    // Inverse Current                          length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,1,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseCurrent,dimensionality);
    
    // Current Ratio                            length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        1,1,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCurrentRatio,dimensionality);
    
    
    // ***** Thermodynamic Temperature **********************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityTemperature
    // Temperature                              length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        1,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityTemperature,dimensionality);

    // Inverse Temperature                      length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        0,1,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseTemperature,dimensionality);
    
    // Temperature Ratio                        length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        1,1,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityTemperatureRatio,dimensionality);
    
    // ***** Amount *****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityAmount
    // Amount                                   length     mass        time        current     temperature     amount      luminous intensity
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        0,0,            1,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAmount,dimensionality);
    
    // inverse amount
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,       0,0,         0,0,        0,0,            0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseAmount,dimensionality);
    
    // amount ratio
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,       0,0,         0,0,        0,0,            1,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAmountRatio,dimensionality);
    
    // ***** Luminous Intensity *****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityLuminousIntensity
    // Luminous Intensity                       length     mass        time        current     temperature     amount      luminous intensity
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        0,0,            0,0,        1,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLuminousIntensity,dimensionality);
    
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        0,0,            0,0,        0,1);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseLuminousIntensity,dimensionality);
    
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,        0,0,        0,0,        0,0,            0,0,        1,1);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLuminousIntensityRatio,dimensionality);
    
    
    // ***** Area *******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityArea
    // Area
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityArea,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRockPermeability,dimensionality);
    
    // Inverse Area
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseArea,dimensionality);
    
    // Area Ratio, Solid Angle
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAreaRatio,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySolidAngle,dimensionality);
    
    // ***** Volume *******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityVolume
    // Volume
    dimensionality  = AddDimensionalityToLibrary(3,0,       0,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityVolume,dimensionality);
    
    // Inverse Volume
    dimensionality  = AddDimensionalityToLibrary(0,3,       0,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseVolume,dimensionality);
    
    // Volume Ratio
    dimensionality  = AddDimensionalityToLibrary(3,3,       0,0,        0,0,        0,0,        0,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityVolumeRatio,dimensionality);


    // Temperature Gradient                    length     mass        time        current     temperature     amount      luminous intensity
    dimensionality = AddDimensionalityToLibrary(0,1,       0,0,        0,0,        0,0,        1,0,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityTemperatureGradient,dimensionality);
    
    // Coherent Units with no Unit name - Table 2
    
    // Speed, Velocity
    dimensionality  = AddDimensionalityToLibrary(1,0,       0,0,        0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpeed,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityVelocity,dimensionality);
    
    // Linear Momentum                          length     mass        time        current     temperature     amount      luminous intensity
    dimensionality  = AddDimensionalityToLibrary(1,0,       1,0,        0,1,       0,0,       0,0,              0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLinearMomentum,dimensionality);
    
    // Acceleration
    dimensionality  = AddDimensionalityToLibrary(1,0,       0,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAcceleration,dimensionality);
    
    // Moment of Inertia
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMomentOfInertia,dimensionality);
    
    // Mass Flow Rate
    dimensionality  = AddDimensionalityToLibrary(0,0,       1,0,        0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMassFlowRate,dimensionality);
    
    // Mass Flux
    dimensionality  = AddDimensionalityToLibrary(0,2,       1,0,        0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMassFlux,dimensionality);

    // Diffusion Flux
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,0,        0,1,       0,0,       0,0,       1,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityDiffusionFlux,dimensionality);

    // Density
    dimensionality  = AddDimensionalityToLibrary(0,3,       1,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityDensity,dimensionality);
    
    // Specific Gravity
    dimensionality  = AddDimensionalityToLibrary(3,3,       1,1,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpecificGravity,dimensionality);
    
    // Surface Density
    dimensionality  = AddDimensionalityToLibrary(0,2,       1,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySurfaceDensity,dimensionality);
    
    // Specific Surface Area
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,1,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpecificSurfaceArea,dimensionality);

    // Surface Area to Volume Ratio
    dimensionality  = AddDimensionalityToLibrary(2,3,       0,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySurfaceAreaToVolumeRatio,dimensionality);
    
    // Specific Volume
    dimensionality  = AddDimensionalityToLibrary(3,0,       0,1,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpecificVolume,dimensionality);
    
    // Current Density
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,0,        0,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCurrentDensity,dimensionality);
    
    
    // Magnetic Field Strength
    dimensionality  = AddDimensionalityToLibrary(0,1,       0,0,        0,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMagneticFieldStrength,dimensionality);
    
    
	// Luminance
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,0,        0,0,       0,0,       0,0,       0,0,       1,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLuminance,dimensionality);
    
    
	// Refractive Index
    dimensionality  = AddDimensionalityToLibrary(1,1,       0,0,        1,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRefractiveIndex,dimensionality);
    
    
    // More Coherent Units with no Symbols - Table 4
	
    // Dynamic Viscosity
    dimensionality  = AddDimensionalityToLibrary(0,1,       1,0,        0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityDynamicViscosity,dimensionality);
    
    // Fluidity (inverse dynamic viscosity)
    dimensionality  = AddDimensionalityToLibrary(1,0,       0,1,        1,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFluidity,dimensionality);
    
	// Moment of Force
    dimensionality  = AddDimensionalityToLibrary(2,0,       2,1,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMomentOfForce,dimensionality);
    
    // Surface Tension
    dimensionality  = AddDimensionalityToLibrary(0,0,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySurfaceTension,dimensionality);
    
    // Surface Energy                           length     mass        time        current     temperature     amount      luminous intensity
    dimensionality  = AddDimensionalityToLibrary(2,2,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySurfaceEnergy,dimensionality);
    
	// Angular Velocity
    dimensionality  = AddDimensionalityToLibrary(1,1,       0,0,        0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAngularVelocity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAngularSpeed,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAngularFrequency,dimensionality);
    
    // Angular Acceleration
    dimensionality  = AddDimensionalityToLibrary(1,1,       0,0,       0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAngularAcceleration,dimensionality);
    
    
	// Heat Flux Density, Irradiance
    dimensionality  = AddDimensionalityToLibrary(2,2,       1,0,        0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityHeatFluxDensity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityIrradiance,dimensionality);
    
    // Spectral Radiant Flux Density
    dimensionality  = AddDimensionalityToLibrary(0,1,       1,0,        0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpectralRadiantFluxDensity,dimensionality);

	// Heat Capacity, Entropy
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,        0,2,       0,0,       0,1,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityHeatCapacity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityEntropy,dimensionality);
    
    
	// Specific Heat Capacity, Specific Entropy
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,0,        0,2,       0,0,       0,1,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpecificHeatCapacity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpecificEntropy,dimensionality);
    
    
    // Specific Energy
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpecificEnergy,dimensionality);
    
    
    // Thermal Conductance                      length      mass        time        current     temperature     amount      luminous intensity
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,        0,3,        0,0,        0,1,            0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityThermalConductance,dimensionality);
    
    // Thermal Conductivity
    dimensionality  = AddDimensionalityToLibrary(1,0,       1,0,        0,3,       0,0,       0,1,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityThermalConductivity,dimensionality);
    
    
	// Electric Field Strength
    dimensionality  = AddDimensionalityToLibrary(1,0,       1,0,        0,3,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricFieldStrength,dimensionality);
    
    // Electric Charge Density
    dimensionality  = AddDimensionalityToLibrary(0,3,       0,0,        1,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricChargeDensity,dimensionality);
    
    //  Electric Flux                           length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(3,0,       1,0,        0,1,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricFlux,dimensionality);

	// Surface Charge Density, Electric Flux Density, Electric Displacement
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,0,        1,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySurfaceChargeDensity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricFluxDensity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricDisplacement,dimensionality);
    
    // Electric Polarizability
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,1,        4,0,       2,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricPolarizability,dimensionality);

    // Electric Quadrupole Moment
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,0,        1,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricQuadrupoleMoment,dimensionality);
    
    
    //  Magnetizability                        length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,2,        4,2,       2,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMagnetizability,dimensionality);
    
    
    
    
	// Permittivity
    dimensionality  = AddDimensionalityToLibrary(0,3,       0,1,        4,0,       2,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPermittivity,dimensionality);
    
    //  Permeability                    length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(1,0,       1,0,        0,2,       0,2,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPermeability,dimensionality);
    
	// Molar Energy
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,        0,2,       0,0,       0,0,       0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMolarEnergy,dimensionality);
    
	// Molar Entropy, Molar Heat Capacity
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,        0,2,       0,0,       0,1,       0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMolarEntropy,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMolarHeatCapacity,dimensionality);
    
    
	// Absorbed Dose Rate
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,0,        0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAbsorbedDoseRate,dimensionality);
    
    
    // Radiant Intensity
    dimensionality  = AddDimensionalityToLibrary(4,2,       1,0,        0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRadiantIntensity,dimensionality);
    
    // Spectral Radiant Intensity
    dimensionality  = AddDimensionalityToLibrary(4,3,       1,0,        0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpectralRadiantIntensity,dimensionality);

    // Radiance
    dimensionality  = AddDimensionalityToLibrary(4,4,       1,0,        0,3,        0,0,        0,0,        0,0,        0,0);

    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRadiance,dimensionality);
    
    // Spectral Radiance
    dimensionality  = AddDimensionalityToLibrary(4,5,       1,0,        0,3,        0,0,        0,0,        0,0,        0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpectralRadiance,dimensionality);
    
    
    // Special Names and Symbols for Coherent Derived Units - Table 3
	
    // Porosity
    dimensionality  = AddDimensionalityToLibrary(3,3,       0,0,        0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPorosity,dimensionality);
    
	// Force
    dimensionality  = AddDimensionalityToLibrary(1,0,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityForce,dimensionality);
    
	// Pressure, Stress, Energy Density
    dimensionality  = AddDimensionalityToLibrary(0,1,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPressure,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityStress,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityEnergyDensity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElasticModulus,dimensionality);
    
    // Compressibility : Inverse Pressure
    dimensionality  = AddDimensionalityToLibrary(1,0,       0,1,        2,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCompressibility,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityStressOpticCoefficient,dimensionality);

    // Pressure Gradient                       length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(0,2,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPressureGradient,dimensionality);
    
	// Energy, Work, Heat
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityEnergy,dimensionality);
    
    // Spectral radiant energy
    dimensionality  = AddDimensionalityToLibrary(2,1,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpectralRadiantEnergy,dimensionality);
    
    // Torque
    dimensionality  = AddDimensionalityToLibrary(3,1,       1,0,        0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityTorque,dimensionality);
    
    // Power, Radiant Flux
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,       0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPower,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRadiantFlux,dimensionality);

    // Spectral Power
    dimensionality  = AddDimensionalityToLibrary(2,1,       1,0,       0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpectralPower,dimensionality);
    
    // Volume Power Density
    dimensionality  = AddDimensionalityToLibrary(2,3,       1,0,       0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityVolumePowerDensity,dimensionality);
    
    // Specific Power
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,1,       0,3,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySpecificPower,dimensionality);
    
    // Electric Charge, Amount of Electricity
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,       1,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricCharge,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAmountOfElectricity,dimensionality);
    
    //  Electric Dipole Moment                  length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(1,0,       0,0,       1,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricDipoleMoment,dimensionality);
    
    //  Gyromagnetic Ratio                      length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(1,1,       0,1,       2,1,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityGyromagneticRatio,dimensionality);

    // Electric Potential Difference, Electromotive Force
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,       0,3,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricPotentialDifference,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectromotiveForce,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityVoltage,dimensionality);
    
    // Electrical Mobility
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,1,       3,1,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricalMobility,dimensionality);
    
    // Electric Field Gradient
    dimensionality  = AddDimensionalityToLibrary(2,2,       1,0,       0,3,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricFieldGradient,dimensionality);
    
	// Capacitance
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,1,       4,0,       2,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCapacitance,dimensionality);
    
    // Electric Resistance
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,       0,3,       0,2,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricResistance,dimensionality);

    // Electric Resistance per length
    dimensionality  = AddDimensionalityToLibrary(2,1,       1,0,       0,3,       0,2,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricResistancePerLength,dimensionality);

    // Electric Resistivity
    dimensionality  = AddDimensionalityToLibrary(3,0,       1,0,       0,3,       0,2,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricResistivity,dimensionality);
    
    // Electric Conductance
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,1,       3,0,       2,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricConductance,dimensionality);
    
    // Electric Conductivity
    dimensionality  = AddDimensionalityToLibrary(0,3,       0,1,       3,0,       2,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityElectricConductivity,dimensionality);
    
    // Molar Conductivity
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,1,       3,0,       2,0,       0,0,       0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMolarConductivity,dimensionality);
    
    //  Magnetic Dipole Moment                  length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,0,       0,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMagneticDipoleMoment,dimensionality);
    
    //  Magnetic Dipole Moment Ratio             length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,0,       0,0,       1,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMagneticDipoleMomentRatio,dimensionality);
    
    // Magnetic Flux
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,       0,2,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMagneticFlux,dimensionality);
    
    // Magnetic Flux Density
    dimensionality  = AddDimensionalityToLibrary(0,0,       1,0,       0,2,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMagneticFluxDensity,dimensionality);
    
    // Inverse Magnetic Flux Density
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,1,       2,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInverseMagneticFluxDensity,dimensionality);
    
    // Frequency per Magnetic Flux Density, Charge to Mass Ratio, Radiation Exposure (x- and gamma-rays)
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,1,       1,0,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRadiationExposure,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityChargeToMassRatio,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFrequencyPerMagneticFluxDensity,dimensionality);

    // Frequency per Electric Field Gradient
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,1,       3,1,       1,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFrequencyPerElectricFieldGradient,dimensionality);
    
    // Frequency per Electric Field Gradient Squared
    dimensionality  = AddDimensionalityToLibrary(4,4,       0,2,       6,1,       2,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFrequencyPerElectricFieldGradientSquared,dimensionality);
    
    
    
    // Mass to Charge Ratio                     length     mass       time      current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(0,0,       1,0,       0,1,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMassToChargeRatio,dimensionality);

    // Magnetic Field Gradient                  length     mass        time        current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(0,1,       1,0,       0,2,       0,1,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMagneticFieldGradient,dimensionality);
    
    // Inductance
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,       0,2,       0,2,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityInductance,dimensionality);
    
    // Luminous Flux
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,0,       0,0,       0,0,       0,0,       0,0,       1,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLuminousFlux,dimensionality);
    
    // Luminous Flux Density
    dimensionality  = AddDimensionalityToLibrary(2,4,       0,0,       0,0,       0,0,       0,0,       0,0,       1,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLuminousFluxDensity,dimensionality);
    
    // Luminous Energy
    dimensionality  = AddDimensionalityToLibrary(2,2,       0,0,       1,0,       0,0,       0,0,       0,0,       1,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLuminousEnergy,dimensionality);
    
    // Illuminance
    dimensionality  = AddDimensionalityToLibrary(2,4,       0,0,       0,0,       0,0,       0,0,       0,0,       1,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityIlluminance,dimensionality);
    
    
    // Absorbed dose, Dose equivalent
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,1,       0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAbsorbedDose,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityDoseEquivalent,dimensionality);
    
    // Catalytic Activity
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,       0,1,       0,0,       0,0,       1,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCatalyticActivity,dimensionality);
    
    // Catalytic Activity Concentration
    dimensionality  = AddDimensionalityToLibrary(0,3,       0,0,       0,1,       0,0,       0,0,       1,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCatalyticActivityConcentration,dimensionality);

    // Catalytic Activity Content
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,1,       0,1,       0,0,       0,0,       1,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCatalyticActivityContent,dimensionality);
    
    // Table 6 - Non-SI units but SI accepted
    
	// Reduced Action
    dimensionality  = AddDimensionalityToLibrary(3,1,       1,0,       0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityReducedAction,dimensionality);
    
	// Action, Angular Momentum
    dimensionality  = AddDimensionalityToLibrary(2,0,       1,0,       0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAction,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAngularMomentum,dimensionality);

	// Kinematic Viscosity
    dimensionality  = AddDimensionalityToLibrary(2,0,       0,0,       0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityKinematicViscosity,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityDiffusionCoefficient,dimensionality);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityCirculation,dimensionality);
    
    // amount concentration                     length     mass       time      current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(0,3,       0,0,       0,0,       0,0,       0,0,       1,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityAmountConcentration,dimensionality);

	// mass concentration
    dimensionality  = AddDimensionalityToLibrary(0,3,       1,0,       0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMassConcentration,dimensionality);

    // molar mass
    dimensionality  = AddDimensionalityToLibrary(0,0,       1,0,       0,0,       0,0,       0,0,       0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMolarMass,dimensionality);
    
    // molality
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,1,       0,0,       0,0,       0,0,       1,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMolality,dimensionality);
    
    // molar magnetic susceptibility
    dimensionality  = AddDimensionalityToLibrary(3,0,       0,0,       0,0,       0,0,       0,0,       0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityMolarMagneticSusceptibility,dimensionality);
    
    // charge per amount
    dimensionality  = AddDimensionalityToLibrary(0,0,       0,0,       1,0,       1,0,       0,0,       0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityChargeToAmountRatio,dimensionality);
    
    // cubic meters per kilogram second (Gravitational Constant)
    dimensionality  = AddDimensionalityToLibrary(3,0,       0,1,       0,2,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityGravitationalConstant,dimensionality);
    
    // distance per volume
    dimensionality  = AddDimensionalityToLibrary(1,3,       0,0,       0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLengthPerVolume,dimensionality);
    
    // volume per distance
    dimensionality  = AddDimensionalityToLibrary(3,1,       0,0,       0,0,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityVolumePerLength,dimensionality);
    
    // volume per time
    dimensionality  = AddDimensionalityToLibrary(3,0,       0,0,       0,1,       0,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityVolumetricFlowRate,dimensionality);
    
    // power per luminous flux
    dimensionality  = AddDimensionalityToLibrary(3,1,       1,0,       0,3,       0,0,       0,0,       0,0,       0,1);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPowerPerLuminousFlux,dimensionality);
    
    // luminous efficacy
    dimensionality  = AddDimensionalityToLibrary(0,2,       0,1,       3,0,       0,0,       0,0,       0,0,       1,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityLuminousEfficacy,dimensionality);
    
    // Heat Transfer Coefficient                length     mass       time      current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(0,0,       1,0,       0,3,       0,0,       0,1,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityHeatTransferCoefficient,dimensionality);

    // Stefan Boltzman constant dimensionality  length     mass       time      current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(2,2,       1,0,       0,3,       0,0,       0,4,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityPowerPerAreaPerTemperatureToFourthPower,dimensionality);
    
    // Gas Permeance
    dimensionality  = AddDimensionalityToLibrary(1,2,       0,1,        2,1,       0,0,       0,0,       1,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityGasPermeance,dimensionality);
    
    
    // kPSQuantityFirstHyperPolarizability
    dimensionality  = AddDimensionalityToLibrary(3,4,       0,2,        7,0,       3,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFirstHyperPolarizability,dimensionality);
    
    // kPSQuantitySecondHyperPolarizability
    dimensionality  = AddDimensionalityToLibrary(4,6,       0,3,        10,0,       4,0,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySecondHyperPolarizability,dimensionality);
    
    // Second Radiation Constant                length     mass       time      current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(3,2,       1,1,        2,2,       0,0,       1,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantitySecondRadiationConstant,dimensionality);
    
    
    // Wien Wavelength Displacement Constant    length     mass       time      current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(1,0,       0,0,        0,0,       0,0,       1,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityWavelengthDisplacementConstant,dimensionality);
    
    
    // Fine Structure Constant                  length     mass       time      current   temperature  amount    luminous intensity
    dimensionality  = AddDimensionalityToLibrary(5,5,       1,1,        4,4,       2,2,       0,0,       0,0,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityFineStructureConstant,dimensionality);

    // 1/(N•T)  kPSQuantityRatePerAmountConcentrationPerTime
    dimensionality  = AddDimensionalityToLibrary(3,0,       0,0,        0,1,       0,0,       0,0,       0,1,       0,0);
    CFDictionaryAddValue(dimensionalityQuantitiesLibrary,kPSQuantityRatePerAmountConcentrationPerTime,dimensionality);
    }

/*
 @function PSDimensionalityCopyDimensionalityLibrary
 @abstract Gets a copy of the dimensionalityLibrary of dimensionalities
 @result a CFSet containing the dimensionalities.
 */
static CFDictionaryRef PSDimensionalityCopyDimensionalityLibrary(void)
{
    if(NULL==dimensionalityLibrary) DimensionalityLibraryBuild();
    return CFDictionaryCreateCopy(kCFAllocatorDefault,dimensionalityLibrary);
}

PSDimensionalityRef PSDimensionalityForQuantityName(CFStringRef quantityName)
{
    if(quantityName==NULL) return NULL;
    if(NULL==dimensionalityQuantitiesLibrary) DimensionalityLibraryBuild();
    PSDimensionalityRef dimensionality = NULL;
    
    if(CFDictionaryContainsKey(dimensionalityQuantitiesLibrary, quantityName)) {
        dimensionality = CFDictionaryGetValue(dimensionalityQuantitiesLibrary, quantityName);
        return dimensionality;
    }

    CFMutableStringRef lowerCaseQuantityName = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(quantityName), quantityName);
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFStringLowercase(lowerCaseQuantityName, locale);
    CFRelease(locale);
    
    if(CFDictionaryContainsKey(dimensionalityQuantitiesLibrary, lowerCaseQuantityName)) {
        dimensionality = CFDictionaryGetValue(dimensionalityQuantitiesLibrary, lowerCaseQuantityName);
    }
    CFRelease(lowerCaseQuantityName);
    if(dimensionality==NULL) {
        dimensionality = PSDimensionalityForSymbol(quantityName);
    }
    return dimensionality;
}

/*
 @function PSDimensionalityLibraryShowFull
 @abstract Shows every dimensionality in the dimensionalityLibrary
 */
static void PSDimensionalityLibraryShowFull(void)
{
    if(NULL==dimensionalityLibrary) DimensionalityLibraryBuild();
    CFDictionaryApplyFunction(dimensionalityLibrary,(CFDictionaryApplierFunction) PSDimensionalityShowFull,NULL);
}

CFMutableDictionaryRef PSDimensionalityGetLibrary()
{
    if(NULL==dimensionalityLibrary) DimensionalityLibraryBuild();
    return dimensionalityLibrary;
}

void PSDimensionalitySetLibrary(CFMutableDictionaryRef newDimensionalityLibrary)
{
    if(newDimensionalityLibrary == dimensionalityLibrary) return;
    if(newDimensionalityLibrary) {
        if(dimensionalityLibrary) CFRelease(dimensionalityLibrary);
        dimensionalityLibrary = (CFMutableDictionaryRef) CFRetain(newDimensionalityLibrary);
    }
}

CFArrayRef PSDimensionalityLibraryCreateArrayOfAllQuantities()
{
    if(NULL==dimensionalityQuantitiesLibrary) DimensionalityLibraryBuild();
    CFIndex totalCount = CFDictionaryGetCount(dimensionalityQuantitiesLibrary);
    CFStringRef keys[totalCount];
    PSDimensionalityRef dimensionalities[totalCount];
    CFDictionaryGetKeysAndValues(dimensionalityQuantitiesLibrary, (CFTypeRef *) keys, (CFTypeRef *)  dimensionalities);
    CFArrayRef quantities = CFArrayCreate(kCFAllocatorDefault, (void *) keys, totalCount, &kCFTypeArrayCallBacks);
    CFMutableArrayRef sorted = CFArrayCreateMutableCopy(kCFAllocatorDefault, totalCount, quantities);
    CFArraySortValues(sorted, CFRangeMake(0, totalCount), (CFComparatorFunction)CFStringCompare, NULL);
    CFRelease(quantities);
    return sorted;
}

@end


