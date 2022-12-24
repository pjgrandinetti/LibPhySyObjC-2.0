//
//  PSUnit.c
//
//  Created by PhySy Ltd on 12/27/09.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

// ---- implementation ----

#import "PhySyFoundation.h"

@interface PSUnit ()
{
@private
    bool staticInstance;
    // Attributes needed to describe all Derived SI Units, including
    // Coherent SI Base Units, SI Base Units, & Derived Coherent SI Units
    PSDimensionalityRef dimensionality;
	PSSIPrefix numerator_prefix[7];
	PSSIPrefix denominator_prefix[7];
    CFStringRef symbol;
    
    // Attributes needed to describe Special SI Units and Non-SI units
	CFStringRef root_name;
	CFStringRef root_plural_name;
	CFStringRef root_symbol;
	PSSIPrefix root_symbol_prefix;
	bool is_special_si_symbol;
    bool allows_si_prefix;
    
    // Attributes needed to describe Non-SI units
    // unit must have a symbol for this value to have meaning.
	double scale_to_coherent_si;
}
@end

@implementation PSUnit

- (void) dealloc
{
    if(!staticInstance) {
//        if(dimensionality) CFRelease(dimensionality);
        if(root_name) CFRelease(root_name);
        if(root_plural_name) CFRelease(root_plural_name);
        if(root_symbol) CFRelease(root_symbol);
        if(symbol) CFRelease(symbol);
        [super dealloc];
    }
}

#define UNIT_NOT_FOUND -1

// unitsLibrary is a Singleton
CFMutableDictionaryRef unitsLibrary = NULL;
CFMutableDictionaryRef unitsQuantitiesLibrary = NULL;
CFMutableDictionaryRef unitsDimensionalitiesLibrary = NULL;
CFMutableArrayRef unitsNamesLibrary = NULL;
bool imperialVolumes = false;

static void UnitsLibraryCreate(void);

#pragma mark Static Utility Functions

static CFComparisonResult unitSort(const void *val1, const void *val2, void *context)
{
    PSUnitRef unit1 = (PSUnitRef) val1;
    PSUnitRef unit2 = (PSUnitRef) val2;
    double scale1 = PSUnitScaleToCoherentSIUnit(unit1);
    double scale2 = PSUnitScaleToCoherentSIUnit(unit2);
    if (scale1 < scale2) return kCFCompareLessThan;
    else if (scale1 > scale2) return kCFCompareGreaterThan;
    else {
        CFStringRef symbol1 = PSUnitCopySymbol((PSUnitRef) val1);
        CFStringRef symbol2 = PSUnitCopySymbol((PSUnitRef) val2);
        CFComparisonResult result = CFStringCompare(symbol1, symbol2, kCFCompareCaseInsensitive);
        CFRelease(symbol1);
        CFRelease(symbol2);
        return result;
    }
}

static CFComparisonResult unitNameSort(const void *val1, const void *val2, void *context)
{
    CFStringRef name1 = PSUnitCopyRootName((PSUnitRef) val1);
    CFStringRef name2 = PSUnitCopyRootName((PSUnitRef) val2);
    CFComparisonResult result = CFStringCompare(name1, name2, kCFCompareCaseInsensitive);
    CFRelease(name1);
    CFRelease(name2);
    return result;
}

static CFComparisonResult unitNameLengthSort(const void *val1, const void *val2, void *context)
{
    CFStringRef name1 = PSUnitCreateName((PSUnitRef) val1);
    CFStringRef name2 = PSUnitCreateName((PSUnitRef) val2);
    if(name1==NULL && name2 == NULL) return kCFCompareEqualTo;
    if(name1 == NULL) {
        CFRelease(name2);
        return kCFCompareGreaterThan;
    }
    if(name2 == NULL) {
        CFRelease(name1);
        return kCFCompareLessThan;
    }
    
    CFComparisonResult result = kCFCompareEqualTo;
    if(CFStringGetLength(name1)>CFStringGetLength(name2)) result = kCFCompareLessThan;
    if(CFStringGetLength(name1)<CFStringGetLength(name2)) result = kCFCompareGreaterThan;
    CFRelease(name1);
    CFRelease(name2);
    return result;
}

static bool isValidSIPrefix(PSSIPrefix input)
{
	switch (input) {
		case kPSSIPrefixYocto:
        case kPSSIPrefixZepto:
        case kPSSIPrefixAtto:
        case kPSSIPrefixFemto:
        case kPSSIPrefixPico:
        case kPSSIPrefixNano:
        case kPSSIPrefixMicro:
        case kPSSIPrefixMilli:
        case kPSSIPrefixCenti:
        case kPSSIPrefixDeci:
        case kPSSIPrefixNone:
		case kPSSIPrefixDeca:
        case kPSSIPrefixHecto:
        case kPSSIPrefixKilo:
        case kPSSIPrefixMega:
        case kPSSIPrefixGiga:
        case kPSSIPrefixTera:
        case kPSSIPrefixPeta:
        case kPSSIPrefixExa:
        case kPSSIPrefixZetta:
        case kPSSIPrefixYotta:
			return true;
	}
    return false;
}

PSSIPrefix findClosestPrefix(int input)
{
    if(input >= kPSSIPrefixYotta) return kPSSIPrefixYotta;
    if(input >= kPSSIPrefixZetta) return kPSSIPrefixZetta;
    if(input >= kPSSIPrefixExa) return kPSSIPrefixExa;
    if(input >= kPSSIPrefixPeta) return kPSSIPrefixPeta;
    if(input >= kPSSIPrefixTera) return kPSSIPrefixTera;
    if(input >= kPSSIPrefixGiga) return kPSSIPrefixGiga;
    if(input >= kPSSIPrefixMega) return kPSSIPrefixMega;
    if(input >= kPSSIPrefixKilo) return kPSSIPrefixKilo;
    if(input >= kPSSIPrefixHecto) return kPSSIPrefixHecto;
    if(input >= kPSSIPrefixDeca) return kPSSIPrefixDeca;
    if(input >= kPSSIPrefixNone) return kPSSIPrefixNone;
    if(input >= kPSSIPrefixDeci) return kPSSIPrefixDeci;
    if(input >= kPSSIPrefixCenti) return kPSSIPrefixCenti;
    if(input >= kPSSIPrefixMilli) return kPSSIPrefixMilli;
    if(input >= kPSSIPrefixMicro) return kPSSIPrefixMicro;
    if(input >= kPSSIPrefixNano) return kPSSIPrefixNano;
    if(input >= kPSSIPrefixPico) return kPSSIPrefixPico;
    if(input >= kPSSIPrefixFemto) return kPSSIPrefixFemto;
    if(input >= kPSSIPrefixAtto) return kPSSIPrefixAtto;
    if(input >= kPSSIPrefixZepto) return kPSSIPrefixZepto;
    return kPSSIPrefixYocto;
}

/*
 static PSSIPrefix SIPrefixForPrefixSymbol(CFStringRef symbol)
 {
 if(CFStringCompare(symbol,CFSTR("y"),0)!=kCFCompareEqualTo) return kPSSIPrefixYocto;
 if(CFStringCompare(symbol,CFSTR("z"),0)!=kCFCompareEqualTo) return kPSSIPrefixZepto;
 if(CFStringCompare(symbol,CFSTR("a"),0)!=kCFCompareEqualTo) return kPSSIPrefixAtto;
 if(CFStringCompare(symbol,CFSTR("f"),0)!=kCFCompareEqualTo) return kPSSIPrefixFemto;
 if(CFStringCompare(symbol,CFSTR("p"),0)!=kCFCompareEqualTo) return kPSSIPrefixPico;
 if(CFStringCompare(symbol,CFSTR("n"),0)!=kCFCompareEqualTo) return kPSSIPrefixNano;
 if(CFStringCompare(symbol,CFSTR("µ"),0)!=kCFCompareEqualTo) return kPSSIPrefixMicro;
 if(CFStringCompare(symbol,CFSTR("m"),0)!=kCFCompareEqualTo) return kPSSIPrefixMilli;
 if(CFStringCompare(symbol,CFSTR("c"),0)!=kCFCompareEqualTo) return kPSSIPrefixCenti;
 if(CFStringCompare(symbol,CFSTR("d"),0)!=kCFCompareEqualTo) return kPSSIPrefixDeci;
 if(CFStringCompare(symbol,CFSTR(""),0)!=kCFCompareEqualTo) return kPSSIPrefixNone;
 if(CFStringCompare(symbol,CFSTR("da"),0)!=kCFCompareEqualTo) return kPSSIPrefixDeca;
 if(CFStringCompare(symbol,CFSTR("h"),0)!=kCFCompareEqualTo) return kPSSIPrefixHecto;
 if(CFStringCompare(symbol,CFSTR("k"),0)!=kCFCompareEqualTo) return kPSSIPrefixKilo;
 if(CFStringCompare(symbol,CFSTR("M"),0)!=kCFCompareEqualTo) return kPSSIPrefixMega;
 if(CFStringCompare(symbol,CFSTR("G"),0)!=kCFCompareEqualTo) return kPSSIPrefixGiga;
 if(CFStringCompare(symbol,CFSTR("T"),0)!=kCFCompareEqualTo) return kPSSIPrefixTera;
 if(CFStringCompare(symbol,CFSTR("P"),0)!=kCFCompareEqualTo) return kPSSIPrefixPeta;
 if(CFStringCompare(symbol,CFSTR("E"),0)!=kCFCompareEqualTo) return kPSSIPrefixExa;
 if(CFStringCompare(symbol,CFSTR("Z"),0)!=kCFCompareEqualTo) return kPSSIPrefixZetta;
 if(CFStringCompare(symbol,CFSTR("Y"),0)!=kCFCompareEqualTo) return kPSSIPrefixYotta;
 return 0;
 }
 */

static CFStringRef prefixSymbolForSIPrefix(PSSIPrefix prefix)
{
	switch (prefix) {
		case kPSSIPrefixYocto:
			return CFSTR("y");
		case kPSSIPrefixZepto:
			return CFSTR("z");
		case kPSSIPrefixAtto:
			return CFSTR("a");
		case kPSSIPrefixFemto:
			return CFSTR("f");
		case kPSSIPrefixPico:
			return CFSTR("p");
		case kPSSIPrefixNano:
			return CFSTR("n");
		case kPSSIPrefixMicro:
			return CFSTR("µ");
		case kPSSIPrefixMilli:
			return CFSTR("m");
		case kPSSIPrefixCenti:
			return CFSTR("c");
		case kPSSIPrefixDeci:
			return CFSTR("d");
		case kPSSIPrefixNone:
			return CFSTR("");
		case kPSSIPrefixDeca:
			return CFSTR("da");
		case kPSSIPrefixHecto:
			return CFSTR("h");
		case kPSSIPrefixKilo:
			return CFSTR("k");
		case kPSSIPrefixMega:
			return CFSTR("M");
		case kPSSIPrefixGiga:
			return CFSTR("G");
		case kPSSIPrefixTera:
			return CFSTR("T");
		case kPSSIPrefixPeta:
			return CFSTR("P");
		case kPSSIPrefixExa:
			return CFSTR("E");
		case kPSSIPrefixZetta:
			return CFSTR("Z");
		case kPSSIPrefixYotta:
			return CFSTR("Y");
		default:
			return NULL;
	}
}

static CFStringRef prefixNameForSIPrefix(PSSIPrefix prefix)
{
	switch (prefix) {
		case kPSSIPrefixYocto:
			return CFSTR("yocto");
		case kPSSIPrefixZepto:
			return CFSTR("zepto");
		case kPSSIPrefixAtto:
			return CFSTR("atto");
		case kPSSIPrefixFemto:
			return CFSTR("femto");
		case kPSSIPrefixPico:
			return CFSTR("pico");
		case kPSSIPrefixNano:
			return CFSTR("nano");
		case kPSSIPrefixMicro:
			return CFSTR("micro");
		case kPSSIPrefixMilli:
			return CFSTR("milli");
		case kPSSIPrefixCenti:
			return CFSTR("centi");
		case kPSSIPrefixDeci:
			return CFSTR("deci");
		case kPSSIPrefixNone:
			return CFSTR("");
		case kPSSIPrefixDeca:
			return CFSTR("deca");
		case kPSSIPrefixHecto:
			return CFSTR("hecto");
		case kPSSIPrefixKilo:
			return CFSTR("kilo");
		case kPSSIPrefixMega:
			return CFSTR("mega");
		case kPSSIPrefixGiga:
			return CFSTR("giga");
		case kPSSIPrefixTera:
			return CFSTR("tera");
		case kPSSIPrefixPeta:
			return CFSTR("peta");
		case kPSSIPrefixExa:
			return CFSTR("exa");
		case kPSSIPrefixZetta:
			return CFSTR("zeta");
		case kPSSIPrefixYotta:
			return CFSTR("yotta");
		default:
			return NULL;
	}
}

static CFStringRef baseUnitRootName(const uint8_t index)
{
	switch (index) {
		case kPSLengthIndex:
			return kPSUnitMeter;
		case kPSMassIndex:
			return kPSUnitGram;
		case kPSTimeIndex:
			return kPSUnitSecond;
		case kPSCurrentIndex:
			return kPSUnitAmpere;
		case kPSTemperatureIndex:
			return kPSUnitKelvin;
		case kPSAmountIndex:
			return kPSUnitMole;
		case kPSLuminousIntensityIndex:
			return kPSUnitCandela;
		default:
			break;
	}
	return NULL;
}

static CFStringRef baseUnitName(const uint8_t index)
{
    if(index==kPSMassIndex) return CFSTR("kilogram");
    else return baseUnitRootName(index);
}

static CFStringRef baseUnitPluralRootName(const uint8_t index)
{
    
	switch (index) {
		case kPSLengthIndex:
			return kPSUnitMeters;
		case kPSMassIndex:
			return kPSUnitGrams;
		case kPSTimeIndex:
			return kPSUnitSeconds;
		case kPSCurrentIndex:
			return kPSUnitAmperes;
		case kPSTemperatureIndex:
			return kPSUnitKelvin;
		case kPSAmountIndex:
			return kPSUnitMoles;
		case kPSLuminousIntensityIndex:
			return kPSUnitCandelas;
		default:
			break;
	}
	return NULL;
}

static CFStringRef baseUnitPluralName(const uint8_t index)
{
    if(index==kPSMassIndex) return CFSTR("kilograms");
    else return baseUnitPluralRootName(index);
}

static CFStringRef baseUnitRootSymbol(const uint8_t index)
{
	switch (index) {
		case kPSLengthIndex:
			return CFSTR("m");
		case kPSMassIndex:
			return CFSTR("g");
		case kPSTimeIndex:
			return CFSTR("s");
		case kPSCurrentIndex:
			return CFSTR("A");
		case kPSTemperatureIndex:
			return CFSTR("K");
		case kPSAmountIndex:
			return CFSTR("mol");
		case kPSLuminousIntensityIndex:
			return CFSTR("cd");
		default:
			break;
	}
	return NULL;
}

static CFStringRef baseUnitSymbol(const uint8_t index)
{
    if(index==kPSMassIndex) return CFSTR("kg");
    else return baseUnitRootSymbol(index);
}

//static void PSUnitRelease(CFAllocatorRef allocator, CFTypeRef cf)
//{
//    PSUnitRef theUnit = (PSUnitRef) cf;
//    IF_NO_OBJECT_EXISTS_RETURN(theUnit,)
//
//    if(theUnit->root_name) CFRelease(theUnit->root_name);
//    if(theUnit->root_plural_name) CFRelease(theUnit->root_plural_name);
//    if(theUnit->root_symbol) CFRelease(theUnit->root_symbol);
//    if(theUnit->symbol) CFRelease(theUnit->symbol);
//    CFAllocatorDeallocate(allocator, (void *) theUnit);
//}
//


#pragma mark Designated Creator

/*
 @function PSUnitCreate
 @abstract Creates a new PSUnit object
 @param dimensionality dimensionality of the unit
 @param length_numerator_prefix integer exponent associated with SI prefix of length coherent base unit
 @param length_denominator_prefix integer exponent associated with SI prefix of length coherent base unit
 @param mass_numerator_prefix integer exponent associated with SI prefix of mass coherent base unit
 @param mass_denominator_prefix integer exponent associated with SI prefix of mass coherent base unit
 @param time_numerator_prefix integer exponent associated with SI prefix of time coherent base unit
 @param time_denominator_prefix integer exponent associated with SI prefix of time coherent base unit
 @param current_numerator_prefix integer exponent associated with SI prefix of current coherent base unit
 @param current_denominator_prefix integer exponent associated with SI prefix of current coherent base unit
 @param temperature_numerator_prefix integer exponent associated with SI prefix of temperature coherent base unit
 @param temperature_denominator_prefix integer exponent associated with SI prefix of temperature coherent base unit
 @param amount_numerator_prefix integer exponent associated with SI prefix of amount coherent base unit
 @param amount_denominator_prefix integer exponent associated with SI prefix of amount coherent base unit
 @param luminous_intensity_numerator_prefix integer exponent associated with SI prefix of luminous intensity coherent base unit
 @param luminous_intensity_denominator_prefix integer exponent associated with SI prefix of luminous intensity coherent base unit
 @param root_name the root name for the unit, such as Kelvin or mole, which can be prefixed with prefixes such as kilo, milli, etc.
 @param root_plural_name the plural version of the root name for the unit.
 @param root_symbol the symbol for the root name for the unit.
 @param root_symbol_prefix the integer exponent associated with SI prefix for the root unit.
 @param allows_si_prefix true if SI prefix can be used with root symbol
 @param is_special_si_symbol true for valid SI base symbols, false if base_symbol is non-SI symbol or if the base_name is NULL
 @param scale_to_coherent_si scaling of the Non-SI root unit
 to the coherent SI base unit or coherent derived SI unit with the
 same dimensionality.
 @result PSUnit object
 @discussion If unit is given a root name and symbol, then prefixes are allowed for this name and symbol, and the prefixes associated
 with the 7 dimensions are ignored.
 */
static PSUnitRef PSUnitCreate(PSDimensionalityRef dimensionality,
                              PSSIPrefix length_numerator_prefix,
                              PSSIPrefix length_denominator_prefix,
                              PSSIPrefix mass_numerator_prefix,
                              PSSIPrefix mass_denominator_prefix,
                              PSSIPrefix time_numerator_prefix,
                              PSSIPrefix time_denominator_prefix,
                              PSSIPrefix current_numerator_prefix,
                              PSSIPrefix current_denominator_prefix,
                              PSSIPrefix temperature_numerator_prefix,
                              PSSIPrefix temperature_denominator_prefix,
                              PSSIPrefix amount_numerator_prefix,
                              PSSIPrefix amount_denominator_prefix,
                              PSSIPrefix luminous_intensity_numerator_prefix,
                              PSSIPrefix luminous_intensity_denominator_prefix,
                              CFStringRef root_name,
                              CFStringRef root_plural_name,
                              CFStringRef root_symbol,
                              PSSIPrefix root_symbol_prefix,
                              bool allows_si_prefix,
                              bool is_special_si_symbol,
                              double scale_to_coherent_si)
{
    // Initialize object
    IF_NO_OBJECT_EXISTS_RETURN(dimensionality,NULL)
    
    PSUnit *newunit = [PSUnit alloc];
    
    newunit->allows_si_prefix = allows_si_prefix;
    
    //  setup attributes
    if(root_symbol==NULL) {
        // Only derived SI units are allowed to have no symbol
        if(is_special_si_symbol) {
            // Can't be valid SI symbol if there's no symbol
            CFRelease(newunit);
            fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
            fprintf(stderr,"          - can't be valid SI symbol if there's no symbol.\n");
            fprintf(stderr,"          - is_special_si_symbol = %d instead of 0\n",is_special_si_symbol);
            return NULL;
        }
        if(scale_to_coherent_si != 1.) {
            // non-SI units are not allowed to have no symbol
            CFRelease(newunit);
            fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
            fprintf(stderr,"          - Only derived SI units are allowed to have no symbol.\n");
            fprintf(stderr,"          - scale_to_coherent_si = %g instead of 1.\n",scale_to_coherent_si);
            return NULL;
        }
        if(root_symbol_prefix) {
            // no prefix possible if no symbol
            CFRelease(newunit);
            fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
            fprintf(stderr,"          - Trying to use SI prefix with no unit symbol.\n");
            return NULL;
        }
        newunit->is_special_si_symbol = false;
        newunit->root_symbol_prefix = 0;
        newunit->scale_to_coherent_si = 1.0;
    }
    else {
        if(!isValidSIPrefix(root_symbol_prefix)) {
            CFRelease(newunit);
            fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
            fprintf(stderr,"          - SI prefix request invalid: symbol_prefix = %d\n",root_symbol_prefix);
            return NULL;
        }
        if(is_special_si_symbol) {
            if(scale_to_coherent_si != 1.) {
                CFRelease(newunit);
                fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
                fprintf(stderr,"          - can't be special SI symbol if scale_to_coherent_si = %g instead of 1.\n",scale_to_coherent_si);
                return NULL;
            }
            newunit->is_special_si_symbol = true;
            newunit->root_symbol_prefix = root_symbol_prefix;
            newunit->scale_to_coherent_si = 1.0;
            
        }
        else {
            newunit->is_special_si_symbol = false;
            newunit->root_symbol_prefix = root_symbol_prefix;
            newunit->scale_to_coherent_si = scale_to_coherent_si;
        }
    }
    
    if(!isValidSIPrefix(length_numerator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: length_numerator_prefix = %d\n",length_numerator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(length_denominator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: length_denominator_prefix = %d\n",length_denominator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(mass_numerator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: mass_numerator_prefix = %d\n",mass_numerator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(mass_denominator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: mass_denominator__prefix = %d\n",mass_denominator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(time_numerator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: time_numerator_prefix = %d\n",time_numerator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(time_denominator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: time_denominator_prefix = %d\n",time_denominator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(current_numerator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: current_numerator_prefix = %d\n",current_numerator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(current_denominator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: current_denominator_prefix = %d\n",current_denominator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(temperature_numerator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: temperature_numerator_prefix = %d\n",temperature_numerator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(temperature_denominator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: temperature_denominator_prefix = %d\n",temperature_denominator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(luminous_intensity_numerator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: luminous_intensity_numerator_prefix = %d\n",luminous_intensity_numerator_prefix);
        return NULL;
    }
    
    if(!isValidSIPrefix(luminous_intensity_denominator_prefix)) {
        CFRelease(newunit);
        fprintf(stderr,"*** ERROR - %s %s\n",__FILE__,__func__);
        fprintf(stderr,"          - SI prefix request invalid: luminous_intensity_denominator_prefix = %d\n",luminous_intensity_denominator_prefix);
        return NULL;
    }
    
    if(root_name) newunit->root_name = CFStringCreateCopy(kCFAllocatorDefault, root_name);
    if(root_plural_name) newunit->root_plural_name = CFStringCreateCopy(kCFAllocatorDefault, root_plural_name);
    if(root_symbol) newunit->root_symbol = CFStringCreateCopy(kCFAllocatorDefault, root_symbol);
    newunit->dimensionality = dimensionality;
    newunit->numerator_prefix[kPSLengthIndex] = length_numerator_prefix;
    newunit->numerator_prefix[kPSMassIndex] = mass_numerator_prefix;
    newunit->numerator_prefix[kPSTimeIndex] = time_numerator_prefix;
    newunit->numerator_prefix[kPSCurrentIndex] = current_numerator_prefix;
    newunit->numerator_prefix[kPSTemperatureIndex] = temperature_numerator_prefix;
    newunit->numerator_prefix[kPSAmountIndex] = amount_numerator_prefix;
    newunit->numerator_prefix[kPSLuminousIntensityIndex] = luminous_intensity_numerator_prefix;
    
    newunit->denominator_prefix[kPSLengthIndex] = length_denominator_prefix;
    newunit->denominator_prefix[kPSMassIndex] = mass_denominator_prefix;
    newunit->denominator_prefix[kPSTimeIndex] = time_denominator_prefix;
    newunit->denominator_prefix[kPSCurrentIndex] = current_denominator_prefix;
    newunit->denominator_prefix[kPSTemperatureIndex] = temperature_denominator_prefix;
    newunit->denominator_prefix[kPSAmountIndex] = amount_denominator_prefix;
    newunit->denominator_prefix[kPSLuminousIntensityIndex] = luminous_intensity_denominator_prefix;
    
    {
        if(PSUnitIsSIBaseUnit(newunit)) {
            // The root_symbol attribute is empty for the seven base units, so we need to ask
            // baseUnitRootSymbol for its root_symbol
            for(int i=0;i<7;i++) {
                if(PSDimensionalityGetNumeratorExponentAtIndex(newunit->dimensionality, i)) {
                    // Only one numerator_exponent will be non-zero (and 1).
                    
                    CFMutableStringRef name = CFStringCreateMutable(NULL,64);
                    
                    CFStringRef prefix_string = prefixSymbolForSIPrefix(newunit->numerator_prefix[i]);
                    
                    CFStringRef name_string = baseUnitRootSymbol(i);
                    
                    CFStringAppend(name,prefix_string);
                    CFStringAppend(name,name_string);
                    newunit->symbol = name;
                }
            }
        }
        else {
            if(newunit->root_symbol) {
                CFMutableStringRef name = CFStringCreateMutable(NULL,64);
                CFStringRef prefix_string = prefixSymbolForSIPrefix(newunit->root_symbol_prefix);
                
                CFStringAppend(name,prefix_string);
                CFStringAppend(name,newunit->root_symbol);
                
                newunit->symbol = name;
            }
            else {
                CFStringRef symbol =  PSUnitCreateDerivedSymbol(newunit);
                newunit->symbol = symbol;
            }
        }
    }
    
    return (PSUnitRef)newunit;
}

static PSUnitRef PSUnitWithParameters(PSDimensionalityRef dimensionality,
                                      PSSIPrefix length_numerator_prefix,
                                      PSSIPrefix length_denominator_prefix,
                                      PSSIPrefix mass_numerator_prefix,
                                      PSSIPrefix mass_denominator_prefix,
                                      PSSIPrefix time_numerator_prefix,
                                      PSSIPrefix time_denominator_prefix,
                                      PSSIPrefix current_numerator_prefix,
                                      PSSIPrefix current_denominator_prefix,
                                      PSSIPrefix temperature_numerator_prefix,
                                      PSSIPrefix temperature_denominator_prefix,
                                      PSSIPrefix amount_numerator_prefix,
                                      PSSIPrefix amount_denominator_prefix,
                                      PSSIPrefix luminous_intensity_numerator_prefix,
                                      PSSIPrefix luminous_intensity_denominator_prefix,
                                      CFStringRef root_name,
                                      CFStringRef root_plural_name,
                                      CFStringRef root_symbol,
                                      PSSIPrefix root_symbol_prefix,
                                      bool allows_si_prefix,
                                      bool is_special_si_symbol,
                                      double scale_to_coherent_si)
{
    PSUnitRef theUnit = PSUnitCreate(dimensionality,
                                     length_numerator_prefix,
                                     length_denominator_prefix,
                                     mass_numerator_prefix,
                                     mass_denominator_prefix,
                                     time_numerator_prefix,
                                     time_denominator_prefix,
                                     current_numerator_prefix,
                                     current_denominator_prefix,
                                     temperature_numerator_prefix,
                                     temperature_denominator_prefix,
                                     amount_numerator_prefix,
                                     amount_denominator_prefix,
                                     luminous_intensity_numerator_prefix,
                                     luminous_intensity_denominator_prefix,
                                     root_name,
                                     root_plural_name,
                                     root_symbol,
                                     root_symbol_prefix,
                                     allows_si_prefix,
                                     is_special_si_symbol,
                                     scale_to_coherent_si);
    
    if(NULL == theUnit) return NULL;
    
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    if(CFDictionaryContainsKey(unitsLibrary, theUnit->symbol)) {
        PSUnitRef existingUnit = CFDictionaryGetValue(unitsLibrary, theUnit->symbol);
        theUnit->staticInstance = false;
        CFRelease(theUnit);
//        PSUnitRelease(kCFAllocatorDefault,theUnit);
        return existingUnit;
    }
    CFDictionaryAddValue(unitsLibrary, theUnit->symbol, theUnit);
    theUnit->staticInstance = true;
    CFRelease(theUnit); // Note: this does nothing for staticInstance = true
    return theUnit;
}

#pragma mark Accessors

PSDimensionalityRef PSUnitGetDimensionality(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    return theUnit->dimensionality;
}

CFStringRef PSUnitCopyRootName(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
	if(PSUnitIsSIBaseUnit(theUnit)) {
        for(uint8_t i=0; i<=6; i++)
            if(PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i)) return CFStringCreateCopy(kCFAllocatorDefault, baseUnitRootName(i));
	}
	else {
		if(theUnit->root_name) return CFStringCreateCopy(kCFAllocatorDefault, theUnit->root_name);
	}
	return CFSTR("");
}

CFStringRef PSUnitCopyRootPluralName(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
	if(PSUnitIsSIBaseUnit(theUnit)) {
        for(uint8_t i=0; i<7; i++)
            if(PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i)) return CFStringCreateCopy(kCFAllocatorDefault, baseUnitPluralRootName(i));
	}
	else {
		if(theUnit->root_plural_name) return CFStringCreateCopy(kCFAllocatorDefault, theUnit->root_plural_name);
	}
	return CFSTR("");
}

CFStringRef PSUnitCopyRootSymbol(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
    if(PSUnitIsSIBaseUnit(theUnit)) {
        for(uint8_t i=0; i<7; i++)
            if(PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i)) return CFStringCreateCopy(kCFAllocatorDefault, baseUnitRootSymbol(i));
    }
    else {
        if(theUnit->root_symbol) return CFStringCreateCopy(kCFAllocatorDefault,theUnit->root_symbol);
    }
    return NULL;
}

CFStringRef PSUnitRootSymbol(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
    if(PSUnitIsSIBaseUnit(theUnit)) {
        for(uint8_t i=0; i<7; i++)
            if(PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i)) return  baseUnitRootSymbol(i);
    }
    else {
        if(theUnit->root_symbol) return theUnit->root_symbol;
    }
    return NULL;
}

bool PSUnitAllowsSIPrefix(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false)
    
    return theUnit->allows_si_prefix;
}

PSSIPrefix PSUnitCopyRootSymbolPrefix(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,0)
    
	return theUnit->root_symbol_prefix;
}

double PSUnitGetScaleNonSIToCoherentSI(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,0)
    
	return theUnit->scale_to_coherent_si;
}

bool PSUnitGetIsSpecialSISymbol(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false)
    
	return theUnit->is_special_si_symbol;
}

PSSIPrefix PSUnitGetNumeratorPrefixAtIndex(PSUnitRef theUnit, const uint8_t index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,0)
    
	return theUnit->numerator_prefix[index];
}

PSSIPrefix PSUnitGetDenominatorPrefixAtIndex(PSUnitRef theUnit, const uint8_t index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,0)
    
	return theUnit->denominator_prefix[index];
}

CFStringRef PSUnitCopySymbol(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
    // Construct the symbol of the unit from root_symbol and prefix.
    
    if(PSUnitIsDimensionlessAndUnderived(theUnit)) {
        return CFSTR(" ");
    }
    
    /*
     if(CFStringGetLength(theUnit->symbol)>2) {
     CFRange range = CFStringFind(theUnit->symbol, CFSTR("1/"), 0);
     if(range.location != kCFNotFound) {
     CFMutableStringRef symbol = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, CFSTR("("));
     CFStringAppend(symbol, theUnit->symbol);
     CFStringAppend(symbol, CFSTR(")"));
     return symbol;
     }
     }
     */
    
    // Symbol should be generated and saved when unit is created.
    return CFStringCreateCopy(kCFAllocatorDefault, theUnit->symbol);
}

#pragma mark Operations

CFArrayRef PSUnitCreateArrayOfEquivalentUnits(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    CFArrayRef candidates = PSUnitCreateArrayOfUnitsForDimensionality(PSUnitGetDimensionality(theUnit));
    if(candidates) {
        CFMutableArrayRef result = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        
        for(CFIndex index = 0; index<CFArrayGetCount(candidates); index++) {
            PSUnitRef unit = CFArrayGetValueAtIndex(candidates, index);
            if(PSUnitAreEquivalentUnits(unit, theUnit)) CFArrayAppendValue(result, unit);
        }
        
        CFRelease(candidates);
        return result;
    }
    return NULL;
}

CFArrayRef PSUnitCreateArrayOfUnitsForQuantityName(CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(quantityName,NULL)
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    if(CFDictionaryContainsKey(unitsQuantitiesLibrary, quantityName)) {
        CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, quantityName);
        return CFArrayCreateCopy(kCFAllocatorDefault, array);
    }
    return NULL;
}

CFArrayRef PSUnitCreateArrayOfUnitsForDimensionality(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    if(NULL==unitsDimensionalitiesLibrary) UnitsLibraryCreate();
    CFStringRef symbol = PSDimensionalityGetSymbol(theDimensionality);
    if(CFDictionaryContainsKey(unitsDimensionalitiesLibrary, symbol)) {
        CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(unitsDimensionalitiesLibrary, symbol);
        if(array) return CFArrayCreateCopy(kCFAllocatorDefault, array);
    }
    return NULL;
}

CFArrayRef PSUnitCreateArrayOfUnitsWithSameRootSymbol(PSUnitRef theUnit)
{
    CFStringRef theUnitRootSymbol = PSUnitRootSymbol(theUnit);
    if(NULL==theUnitRootSymbol) return NULL;
    CFArrayRef sameDimensionalityUnits = PSUnitCreateArrayOfUnitsForDimensionality(theUnit->dimensionality);
    CFMutableArrayRef sameRootSymbols = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index=0;index<CFArrayGetCount(sameDimensionalityUnits);index++) {
        PSUnitRef unit = CFArrayGetValueAtIndex(sameDimensionalityUnits, index);
        CFStringRef unitRootSymbol = PSUnitRootSymbol(unit);
        if(unitRootSymbol && CFStringCompare(unitRootSymbol, theUnitRootSymbol, 0)==kCFCompareEqualTo) {
            CFArrayAppendValue(sameRootSymbols, unit);
        }
        if(unitRootSymbol) CFRelease(unitRootSymbol);
        CFRelease(theUnitRootSymbol);
    }
    CFRelease(sameDimensionalityUnits);
    return sameRootSymbols;
}


CFArrayRef PSUnitCreateArrayOfUnitsForSameReducedDimensionality(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    CFArrayRef dimensionalities = PSDimensionalityCreateArrayWithSameReducedDimensionality(theDimensionality);

    CFMutableArrayRef result = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index = 0; index<CFArrayGetCount(dimensionalities); index++) {
        PSDimensionalityRef dimensionality = CFArrayGetValueAtIndex(dimensionalities, index);
        CFStringRef symbol = PSDimensionalityGetSymbol(dimensionality);
        if(CFDictionaryContainsKey(unitsDimensionalitiesLibrary, symbol)) {
            CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(unitsDimensionalitiesLibrary, symbol);
            CFArrayAppendArray(result, array, CFRangeMake(0, CFArrayGetCount(array)));
        }
    }
    CFRelease(dimensionalities);
    return result;
}


CFArrayRef PSUnitCreateArrayOfConversionUnits(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
    CFArrayRef result = PSUnitCreateArrayOfUnitsForSameReducedDimensionality(PSUnitGetDimensionality(theUnit));
    
    CFMutableArrayRef sorted = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(result), result);
    CFArraySortValues(sorted, CFRangeMake(0, CFArrayGetCount(result)), unitSort, NULL);
    CFRelease(result);
    return sorted;
}

double PSUnitConversion(PSUnitRef initialUnit, PSUnitRef finalUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(initialUnit,0)
    IF_NO_OBJECT_EXISTS_RETURN(finalUnit,0)
    
    if(PSDimensionalityHasSameReducedDimensionality(initialUnit->dimensionality,finalUnit->dimensionality))
        return PSUnitScaleToCoherentSIUnit(initialUnit)/PSUnitScaleToCoherentSIUnit(finalUnit);
    return 0;
}

CFStringRef PSUnitCreateName(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
    // Construct the name of the unit from root_name and prefix.
    if(PSUnitIsDimensionlessAndUnderived(theUnit)) return kPSQuantityDimensionless;
    
	if(PSUnitIsSIBaseUnit(theUnit)) {
        // The root_name attribute is empty for the seven base units, so we need to ask
        // baseUnitRootName for its root_name
		for(int i=0;i<7;i++) {
            // Only one numerator_exponent will be non-zero (and 1).
			if(PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i)) {
                return CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL, CFSTR("%@%@"),prefixNameForSIPrefix(theUnit->numerator_prefix[i]),baseUnitRootName(i));
			}
		}
	}
	else {
        if(theUnit->root_name==NULL) return NULL;
        CFStringRef rootName= PSUnitCopyRootName(theUnit);
        CFStringRef name = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL, CFSTR("%@%@"),prefixNameForSIPrefix(theUnit->root_symbol_prefix),rootName);
        CFRelease(rootName);
        return name;
        
	}
	return NULL;
}

CFStringRef PSUnitCreatePluralName(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
    // Construct the plural name of the unit from root_plural_name and prefix.
    
	if(PSUnitIsSIBaseUnit(theUnit)) {
        // The root_plural_name attribute is empty for the seven base units, so we need to ask
        // baseUnitPluralRootName for its root_plural_name
		for(int i=0;i<7;i++) {
            // Only one numerator_exponent will be non-zero (and 1).
			if(PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i)) {
                
                CFMutableStringRef name = CFStringCreateMutable(NULL,64);
                
                CFStringRef prefix_string = prefixNameForSIPrefix(theUnit->numerator_prefix[i]);
                CFStringRef name_string = baseUnitPluralRootName(i);
                
                CFStringAppend(name,prefix_string);
                CFStringAppend(name,name_string);
				return name;
			}
		}
	}
	else {
        if(theUnit->root_plural_name==NULL) return NULL;
        CFMutableStringRef name = CFStringCreateMutable(NULL,64);
		CFStringRef prefix_string = prefixNameForSIPrefix(theUnit->root_symbol_prefix);
        
        CFStringAppend(name,prefix_string);
        CFStringAppend(name,theUnit->root_plural_name);
        
        return name;
	}
	return NULL;
}
double PSUnitScaleToCoherentSIUnit(PSUnitRef theUnit)
{
	/*
	 *	This method calculates the scaling factor needed to transform a number with this unit
	 *	into a number with the coherent si unit of the same dimensionality
	 */
	
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,0)
    
	// If this is one of the 7 SI base unit - or -
	// if the symbol is NULL then this must be a derived SI Unit
	// Either way calculate scale that returns to coherent derived unit
	// using dimension exponents and prefixes.
	if(theUnit->root_symbol == NULL) {
        // This method calculates the scaling back to a coherent derived unit
        // based solely on prefix and exponent for each of the seven dimensions.
        double scaling = 1.0;
        for(int i=0;i<7;i++) {
            double numerator_power = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i);
            double denominator_power = PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality, i);
            PSSIPrefix numerator_prefix = theUnit->numerator_prefix[i];
            PSSIPrefix denominator_prefix = theUnit->denominator_prefix[i];
            if(i==1) {
                numerator_prefix -= kPSSIPrefixKilo;   // Since kilogram is the base unit
                denominator_prefix -= kPSSIPrefixKilo;   // Since kilogram is the base unit
            }
            scaling *= pow(10.,(numerator_prefix*numerator_power - denominator_prefix*denominator_power));
        }
        return scaling;
    }
	
	// If symbol exists and it is is_special_si_symbol then return scale using symbol prefix
	// to return to base special SI symbol unit.
	if(theUnit->is_special_si_symbol) return pow(10.,theUnit->root_symbol_prefix);
	
	// If symbol exists but is not is_special_si_symbol, then
	// scale_to_coherent_si is scale from base non-SI symbol to coherent SI base unit with same dimensionality
	// symbol prefix gives scale from prefixed non-SI unit to non-SI root unit.
	return theUnit->scale_to_coherent_si*pow(10.,theUnit->root_symbol_prefix);
}

PSUnitRef PSUnitDimensionlessAndUnderived(void)
{
	return PSUnitWithParameters(PSDimensionalityDimensionless(),
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixKilo,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                NULL,
                                NULL,
                                NULL,
                                kPSSIPrefixNone,
                                false,
                                false,
                                1.0);
    
}

PSUnitRef PSUnitFindCoherentSIUnitWithDimensionality(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    
	return PSUnitWithParameters(theDimensionality,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixKilo,
                                kPSSIPrefixKilo,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                kPSSIPrefixNone,
                                NULL,
                                NULL,
                                NULL,
                                kPSSIPrefixNone,
                                false,
                                false,
                                1.0);
}

CFDictionaryRef PSUnitCreateDictionaryOfUnitsWithDimensionality(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    
    CFIndex totalCount = CFDictionaryGetCount(unitsLibrary);
    CFStringRef keys[totalCount];
    PSUnitRef units[totalCount];
    CFDictionaryGetKeysAndValues(unitsLibrary, (const void **) keys, (const void **) units);
    CFMutableDictionaryRef result = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    for(CFIndex index = 0; index<totalCount; index++) {
        PSDimensionalityRef dimensionality = PSUnitGetDimensionality(units[index]);
        if(PSDimensionalityEqual(theDimensionality, dimensionality)) {
            CFDictionaryAddValue(result, keys[index], units[index]);
        }
    }
    
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnitWithDimensionality(theDimensionality);
    CFStringRef symbol = PSUnitCopySymbol(coherentUnit);
    
    if(CFDictionaryContainsKey(result, symbol)) {
        CFRelease(symbol);
        return result;
    }
    CFDictionaryAddValue(result, symbol, coherentUnit);
    CFRelease(symbol);
    return result;
}

CFDictionaryRef PSUnitCreateDictionaryOfUnitsWithSameReducedDimensionality(PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDimensionality,NULL)
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    CFIndex totalCount = CFDictionaryGetCount(unitsLibrary);
    CFStringRef keys[totalCount];
    PSUnitRef units[totalCount];
    CFDictionaryGetKeysAndValues(unitsLibrary, (const void **) keys, (const void **) units);
    CFMutableDictionaryRef result = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFArrayRef dimensionalities = PSDimensionalityCreateArrayWithSameReducedDimensionality(theDimensionality);
    for(CFIndex index = 0; index<CFArrayGetCount(dimensionalities); index++) {
        PSDimensionalityRef dimensionality = CFArrayGetValueAtIndex(dimensionalities, index);
        for(CFIndex index = 0; index<totalCount; index++) {
            if(PSDimensionalityEqual(PSUnitGetDimensionality(units[index]), dimensionality))
                CFDictionaryAddValue(result, keys[index], units[index]);
        }
        PSUnitRef coherentUnit = PSUnitFindCoherentSIUnitWithDimensionality(dimensionality);
        CFStringRef symbol = PSUnitCopySymbol(coherentUnit);
        if(symbol) {
            if(!CFDictionaryContainsKey(result, symbol)) CFDictionaryAddValue(result, symbol, coherentUnit);
            CFRelease(symbol);
        }
    }
    CFRelease(dimensionalities);
    return result;
}

static PSUnitRef PSUnitFindEquivalentDerivedSIUnit(PSUnitRef input)
{
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL)
    
    if(input->root_symbol==NULL) return input;
    
    PSDimensionalityRef theDimensionality = PSUnitGetDimensionality(input);
    CFArrayRef candidates = PSUnitCreateArrayOfUnitsForDimensionality(theDimensionality);
    if(candidates) {
        CFIndex closest = -1;
        double bestScaling = 100;
        for(CFIndex index = 0; index<CFArrayGetCount(candidates); index++) {
            PSUnitRef unit = CFArrayGetValueAtIndex(candidates, index);
            if(PSUnitIsCoherentDerivedUnit(unit)) {  // was unit->root_symbol==NULL
                double scaling = fabs(log10(PSUnitScaleToCoherentSIUnit(unit)/PSUnitScaleToCoherentSIUnit(input)));
                if(fabs(log(PSUnitScaleToCoherentSIUnit(unit)/PSUnitScaleToCoherentSIUnit(input))) < bestScaling) {
                    bestScaling = scaling;
                    closest = index;
                }
            }
        }
        if(closest==-1) {
            CFRelease(candidates);
            return input;}
        PSUnitRef result = CFArrayGetValueAtIndex(candidates, closest);
        CFRelease(candidates);
        return result;
    }
    return input;
}

PSUnitRef PSUnitFindEquivalentUnitWithShortestSymbol(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    if(PSUnitIsDimensionlessAndUnderived(theUnit)) return theUnit;
    
    CFArrayRef candidates = PSUnitCreateArrayOfEquivalentUnits(theUnit);
    if(candidates) {
        if(CFArrayGetCount(candidates) == 0) {
            CFRelease(candidates);
            return theUnit;
        }
        PSUnitRef best = theUnit;
        CFStringRef symbol = PSUnitCopySymbol(theUnit);
        CFStringRef rootSymbol = PSUnitCopyRootSymbol(theUnit);
        if(rootSymbol) {
            if(symbol) CFRelease(symbol);
            if(rootSymbol) CFRelease(rootSymbol);
            CFRelease(candidates);
            return theUnit;
        }
        
        CFIndex length = CFStringGetLength(symbol);
        CFRelease(symbol);
        for(CFIndex index = 0; index<CFArrayGetCount(candidates); index++) {
            PSUnitRef candidate = CFArrayGetValueAtIndex(candidates, index);
            CFStringRef candidateSymbol = PSUnitCopySymbol(candidate);
            CFStringRef candidateRootSymbol = PSUnitCopyRootSymbol(candidate);
            if(candidateRootSymbol) best = candidate;
            else if(length>CFStringGetLength(candidateSymbol)) best = candidate;
            if(candidateSymbol) CFRelease(candidateSymbol);
            if(candidateRootSymbol) CFRelease(candidateRootSymbol);
        }
        CFRelease(candidates);
        return best;
    }
    return theUnit;
}

PSUnitRef PSUnitFindCoherentSIUnit(PSUnitRef input, double *unit_multiplier)
{
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL)
    
    PSUnitRef theUnit = PSUnitFindCoherentSIUnitWithDimensionality(PSUnitGetDimensionality(input));
    
   	/*
	 *	Calculate the multiplier for the numerical part of the new quantity.
	 */
	
    if(unit_multiplier) {
        if(*unit_multiplier == 0.0) *unit_multiplier = 1.0;
        *unit_multiplier *= PSUnitScaleToCoherentSIUnit(input)/PSUnitScaleToCoherentSIUnit(theUnit);
    }
    return theUnit;
}

PSUnitRef PSUnitForSymbol(CFStringRef symbol)
{
    if(NULL==symbol) {
        return NULL;
    }
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    IF_NO_OBJECT_EXISTS_RETURN(unitsLibrary,NULL)
    
    PSUnitRef unit = CFDictionaryGetValue(unitsLibrary, symbol);
    return unit;
}

PSUnitRef PSUnitByParsingSymbol(CFStringRef symbol, double *unit_multiplier, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    if(NULL==symbol) {
        if(error) {
            CFStringRef desc = CFSTR("Unknown unit symbol");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return NULL;
    }
    IF_NO_OBJECT_EXISTS_RETURN(unitsLibrary,NULL)
    
    if(CFStringCompare(symbol, CFSTR(" "),0)==kCFCompareEqualTo) return PSUnitDimensionlessAndUnderived();
    
    CFMutableStringRef mutSymbol = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, symbol);
    CFStringTrimWhitespace(mutSymbol);
    CFStringFindAndReplace(mutSymbol,CFSTR("*"),CFSTR("•"), CFRangeMake(0,CFStringGetLength(mutSymbol)),0);
    PSUnitRef unit = CFDictionaryGetValue(unitsLibrary, mutSymbol);
    CFRelease(mutSymbol);
    
    if(unit) return unit;
    
    CFRange range = CFRangeMake(0, CFStringGetLength(symbol));
    CFRange resultRange;
    CFCharacterSetRef theSet = CFCharacterSetCreateWithCharactersInString (kCFAllocatorDefault,CFSTR("*/^"));
    Boolean couldBeDerived = CFStringFindCharacterFromSet(symbol,theSet,range,kCFCompareBackwards,&resultRange);
    CFRelease(theSet);
    if(couldBeDerived) return PSUnitForParsedSymbol(symbol, unit_multiplier, error);
    return NULL;
}

CFArrayRef PSUnitCreateArrayForQuantity(CFStringRef quantityName)
{
    if(NULL==quantityName) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(unitsQuantitiesLibrary,NULL)
    CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, quantityName);
    if(array) return CFArrayCreateCopy(kCFAllocatorDefault, array);
    return NULL;
}

PSUnitRef PSUnitByReducing(PSUnitRef theUnit, double *unit_multiplier)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    
    PSDimensionalityRef dimensionality = PSDimensionalityByReducing(theUnit->dimensionality);
    if(PSDimensionalityEqual(dimensionality, theUnit->dimensionality)) return PSUnitFindEquivalentUnitWithShortestSymbol(theUnit);
    
    PSUnitRef reducedUnit = PSUnitWithParameters(dimensionality,
                                                 theUnit->numerator_prefix[kPSLengthIndex],
                                                 theUnit->denominator_prefix[kPSLengthIndex],
                                                 theUnit->numerator_prefix[kPSMassIndex],
                                                 theUnit->denominator_prefix[kPSMassIndex],
                                                 theUnit->numerator_prefix[kPSTimeIndex],
                                                 theUnit->denominator_prefix[kPSTimeIndex],
                                                 theUnit->numerator_prefix[kPSCurrentIndex],
                                                 theUnit->denominator_prefix[kPSCurrentIndex],
                                                 theUnit->numerator_prefix[kPSTemperatureIndex],
                                                 theUnit->denominator_prefix[kPSTemperatureIndex],
                                                 theUnit->numerator_prefix[kPSAmountIndex],
                                                 theUnit->denominator_prefix[kPSAmountIndex],
                                                 theUnit->numerator_prefix[kPSLuminousIntensityIndex],
                                                 theUnit->denominator_prefix[kPSLuminousIntensityIndex],
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 kPSSIPrefixNone,
                                                 false,
                                                 false,
                                                 1.0);
    if(unit_multiplier) {
        if(*unit_multiplier == 0.0) *unit_multiplier = 1.0;
        *unit_multiplier *= PSUnitScaleToCoherentSIUnit(theUnit)/PSUnitScaleToCoherentSIUnit(reducedUnit);
    }
	return PSUnitFindEquivalentUnitWithShortestSymbol(reducedUnit);
}

PSUnitRef PSUnitByMultiplyingWithoutReducing(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theUnit1,NULL)
    IF_NO_OBJECT_EXISTS_RETURN(theUnit2,NULL)
    if(theUnit1==theUnit2)
        return PSUnitByRaisingToAPowerWithoutReducing(theUnit1, 2, unit_multiplier, error);
    
    PSUnitRef dimensionlessAndUnderivedUnit = PSUnitDimensionlessAndUnderived();
    if(theUnit1 == dimensionlessAndUnderivedUnit) {
        return theUnit2;
    }
    if(theUnit2 == dimensionlessAndUnderivedUnit) {
        return theUnit1;
    }
    
	/*
	 *	This routine will create an derived SI Unit formed by the product of two units.
	 *	It will additionally return a multiplier for the numerical part of the quantity product
	 *
	 */
    
    PSUnitRef theUnit11 = PSUnitFindEquivalentDerivedSIUnit(theUnit1);
    PSUnitRef theUnit22 = PSUnitFindEquivalentDerivedSIUnit(theUnit2);
    
    PSDimensionalityRef dimensionality = PSDimensionalityByMultiplyingWithoutReducing(theUnit11->dimensionality,theUnit22->dimensionality, error);
    
	PSSIPrefix numerator_prefix[7];
	PSSIPrefix denominator_prefix[7];
    
    for(uint8_t i=0;i<7;i++) {
        uint8_t numerator_exponent = PSDimensionalityGetNumeratorExponentAtIndex(dimensionality,i);
        uint8_t input1_numerator_exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit11->dimensionality,i);
        uint8_t input2_numerator_exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit22->dimensionality,i);
        numerator_prefix[i] = theUnit11->numerator_prefix[i]*input1_numerator_exponent + theUnit22->numerator_prefix[i]*input2_numerator_exponent;
        if(numerator_exponent) numerator_prefix[i] /= numerator_exponent;
        else {
            numerator_prefix[i] = kPSSIPrefixNone;
            if(i==kPSMassIndex) numerator_prefix[i] = kPSSIPrefixKilo;
        }
        
        if(!isValidSIPrefix(numerator_prefix[i])) numerator_prefix[i] = findClosestPrefix(numerator_prefix[i]);
        
        uint8_t denominator_exponent = PSDimensionalityGetDenominatorExponentAtIndex(dimensionality,i);
        uint8_t input1_denominator_exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit11->dimensionality,i);
        uint8_t input2_denominator_exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit22->dimensionality,i);
        denominator_prefix[i] = theUnit11->denominator_prefix[i]*input1_denominator_exponent + theUnit22->denominator_prefix[i]*input2_denominator_exponent;
        if(denominator_exponent) denominator_prefix[i] /= denominator_exponent;
        else denominator_prefix[i] = kPSSIPrefixNone;
        
        if(!isValidSIPrefix(denominator_prefix[i])) denominator_prefix[i] = findClosestPrefix(denominator_prefix[i]);
    }
    
	PSUnitRef theUnit = PSUnitWithParameters(dimensionality,
                                             numerator_prefix[kPSLengthIndex],
                                             denominator_prefix[kPSLengthIndex],
                                             numerator_prefix[kPSMassIndex],
                                             denominator_prefix[kPSMassIndex],
                                             numerator_prefix[kPSTimeIndex],
                                             denominator_prefix[kPSTimeIndex],
                                             numerator_prefix[kPSCurrentIndex],
                                             denominator_prefix[kPSCurrentIndex],
                                             numerator_prefix[kPSTemperatureIndex],
                                             denominator_prefix[kPSTemperatureIndex],
                                             numerator_prefix[kPSAmountIndex],
                                             denominator_prefix[kPSAmountIndex],
                                             numerator_prefix[kPSLuminousIntensityIndex],
                                             denominator_prefix[kPSLuminousIntensityIndex],
                                             NULL,NULL,NULL,0,false,false,1.0);
    
	/*
	 *	Calculate the multiplier for the numerical part of the new quantity.
	 */
	
    if(unit_multiplier) {
        if(*unit_multiplier == 0.0) *unit_multiplier = 1.0;
        double unit1Scale = PSUnitScaleToCoherentSIUnit(theUnit1);
        double unit2Scale = PSUnitScaleToCoherentSIUnit(theUnit2);
        double unitScale = PSUnitScaleToCoherentSIUnit(theUnit);
        
        *unit_multiplier *= unit1Scale*unit2Scale/unitScale;
    }
	return theUnit;
}

PSUnitRef PSUnitByMultiplying(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    PSUnitRef unit = PSUnitByMultiplyingWithoutReducing(theUnit1, theUnit2, unit_multiplier, error);
    return PSUnitByReducing(unit, unit_multiplier);
}

PSUnitRef PSUnitByDividingWithoutReducing(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier)
{
	/*
	 *	This routine will create an derived SI Unit formed by dividing two units.
	 *	It will additionally return a multiplier for the numerical part of the quantity product
	 *
	 */
    
    IF_NO_OBJECT_EXISTS_RETURN(theUnit1,NULL)
    IF_NO_OBJECT_EXISTS_RETURN(theUnit2,NULL)
    
    PSUnitRef theUnit11 = PSUnitFindEquivalentDerivedSIUnit(theUnit1);
    PSUnitRef theUnit22 = PSUnitFindEquivalentDerivedSIUnit(theUnit2);
    
    PSDimensionalityRef dimensionality = PSDimensionalityByDividingWithoutReducing(theUnit1->dimensionality,theUnit2->dimensionality);
    
	PSSIPrefix numerator_prefix[7];
	PSSIPrefix denominator_prefix[7];
    
    for(uint8_t i=0;i<7;i++) {
        uint8_t numerator_exponent = PSDimensionalityGetNumeratorExponentAtIndex(dimensionality,i);
        uint8_t input1_numerator_exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit11->dimensionality,i);
        uint8_t input2_denominator_exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit22->dimensionality,i);
        numerator_prefix[i] = theUnit11->numerator_prefix[i]*input1_numerator_exponent + theUnit22->denominator_prefix[i]*input2_denominator_exponent;
        if(numerator_exponent) numerator_prefix[i] /= numerator_exponent;
        else {
            numerator_prefix[i] = kPSSIPrefixNone;
            if(i==kPSMassIndex) numerator_prefix[i] = kPSSIPrefixKilo;
        }
        
        if(!isValidSIPrefix(numerator_prefix[i])) numerator_prefix[i] = findClosestPrefix(numerator_prefix[i]);
        
        uint8_t denominator_exponent = PSDimensionalityGetDenominatorExponentAtIndex(dimensionality,i);
        uint8_t input1_denominator_exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit1->dimensionality,i);
        uint8_t input2_numerator_exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit2->dimensionality,i);
        denominator_prefix[i] = theUnit11->denominator_prefix[i]*input1_denominator_exponent + theUnit22->numerator_prefix[i]*input2_numerator_exponent;
        if(denominator_exponent) denominator_prefix[i] /= denominator_exponent;
        else denominator_prefix[i] = kPSSIPrefixNone;
        
        if(!isValidSIPrefix(denominator_prefix[i])) denominator_prefix[i] = findClosestPrefix(denominator_prefix[i]);
    }
    
	PSUnitRef theUnit = PSUnitWithParameters(dimensionality,
                                             numerator_prefix[kPSLengthIndex],
                                             denominator_prefix[kPSLengthIndex],
                                             numerator_prefix[kPSMassIndex],
                                             denominator_prefix[kPSMassIndex],
                                             numerator_prefix[kPSTimeIndex],
                                             denominator_prefix[kPSTimeIndex],
                                             numerator_prefix[kPSCurrentIndex],
                                             denominator_prefix[kPSCurrentIndex],
                                             numerator_prefix[kPSTemperatureIndex],
                                             denominator_prefix[kPSTemperatureIndex],
                                             numerator_prefix[kPSAmountIndex],
                                             denominator_prefix[kPSAmountIndex],
                                             numerator_prefix[kPSLuminousIntensityIndex],
                                             denominator_prefix[kPSLuminousIntensityIndex],
                                             NULL,NULL,NULL,0,false,false,1.0);
    
	/*
	 *	Calculate the multiplier for the numerical part of the new quantity.
	 */
	
    if(unit_multiplier) {
        if(*unit_multiplier == 0.0) *unit_multiplier = 1.0;
        double unit1Scale = PSUnitScaleToCoherentSIUnit(theUnit1);
        double unit2Scale = PSUnitScaleToCoherentSIUnit(theUnit2);
        double unitScale = PSUnitScaleToCoherentSIUnit(theUnit);
        *unit_multiplier *= unit1Scale/unit2Scale/unitScale;
    }
	return theUnit;
}

PSUnitRef PSUnitByDividing(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier)
{
    PSUnitRef unit = PSUnitByDividingWithoutReducing(theUnit1, theUnit2, unit_multiplier);
    return PSUnitByReducing(unit, unit_multiplier);
}

PSUnitRef PSUnitByTakingNthRoot(PSUnitRef input, uint8_t root, double *unit_multiplier, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL)
    PSUnitRef derivedUnit = PSUnitFindEquivalentDerivedSIUnit(input);
    PSDimensionalityRef dimensionality = PSDimensionalityByTakingNthRoot(derivedUnit->dimensionality,root,error);
    if(error) if(*error) return NULL;
    if(PSDimensionalityEqual(dimensionality, derivedUnit->dimensionality)) return input;
    
    PSUnitRef theUnit = PSUnitWithParameters(dimensionality,
                                             derivedUnit->numerator_prefix[kPSLengthIndex],
                                             derivedUnit->denominator_prefix[kPSLengthIndex],
                                             derivedUnit->numerator_prefix[kPSMassIndex],
                                             derivedUnit->denominator_prefix[kPSMassIndex],
                                             derivedUnit->numerator_prefix[kPSTimeIndex],
                                             derivedUnit->denominator_prefix[kPSTimeIndex],
                                             derivedUnit->numerator_prefix[kPSCurrentIndex],
                                             derivedUnit->denominator_prefix[kPSCurrentIndex],
                                             derivedUnit->numerator_prefix[kPSTemperatureIndex],
                                             derivedUnit->denominator_prefix[kPSTemperatureIndex],
                                             derivedUnit->numerator_prefix[kPSAmountIndex],
                                             derivedUnit->denominator_prefix[kPSAmountIndex],
                                             derivedUnit->numerator_prefix[kPSLuminousIntensityIndex],
                                             derivedUnit->denominator_prefix[kPSLuminousIntensityIndex],
                                             NULL,
                                             NULL,
                                             NULL,
                                             kPSSIPrefixNone,
                                             false,false,
                                             1.0);
    /*
	 *	Calculate the multiplier for the numerical part of the new quantity.
	 */
    
    if(unit_multiplier) {
        if(*unit_multiplier == 0.0) *unit_multiplier = 1.0;
        *unit_multiplier *= pow(PSUnitScaleToCoherentSIUnit(input),1./root)/PSUnitScaleToCoherentSIUnit(theUnit);
    }
	return theUnit;
}

PSUnitRef PSUnitByRaisingToAPowerWithoutReducing(PSUnitRef input, double power, double *unit_multiplier, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL)
    PSUnitRef derivedUnit = PSUnitFindEquivalentDerivedSIUnit(input);
    
    PSDimensionalityRef dimensionality = PSDimensionalityByRaisingToAPowerWithoutReducing(derivedUnit->dimensionality,power,error);
    if(error) if(*error) return NULL;
    PSUnitRef theUnit;
    if(power>0) theUnit = PSUnitWithParameters(dimensionality,
                                               derivedUnit->numerator_prefix[kPSLengthIndex],
                                               derivedUnit->denominator_prefix[kPSLengthIndex],
                                               derivedUnit->numerator_prefix[kPSMassIndex],
                                               derivedUnit->denominator_prefix[kPSMassIndex],
                                               derivedUnit->numerator_prefix[kPSTimeIndex],
                                               derivedUnit->denominator_prefix[kPSTimeIndex],
                                               derivedUnit->numerator_prefix[kPSCurrentIndex],
                                               derivedUnit->denominator_prefix[kPSCurrentIndex],
                                               derivedUnit->numerator_prefix[kPSTemperatureIndex],
                                               derivedUnit->denominator_prefix[kPSTemperatureIndex],
                                               derivedUnit->numerator_prefix[kPSAmountIndex],
                                               derivedUnit->denominator_prefix[kPSAmountIndex],
                                               derivedUnit->numerator_prefix[kPSLuminousIntensityIndex],
                                               derivedUnit->denominator_prefix[kPSLuminousIntensityIndex],
                                               NULL,NULL,NULL,0,false,false,1.0);
    else theUnit = PSUnitWithParameters(dimensionality,
                                        derivedUnit->denominator_prefix[kPSLengthIndex],
                                        derivedUnit->numerator_prefix[kPSLengthIndex],
                                        derivedUnit->denominator_prefix[kPSMassIndex],
                                        derivedUnit->numerator_prefix[kPSMassIndex],
                                        derivedUnit->denominator_prefix[kPSTimeIndex],
                                        derivedUnit->numerator_prefix[kPSTimeIndex],
                                        derivedUnit->denominator_prefix[kPSCurrentIndex],
                                        derivedUnit->numerator_prefix[kPSCurrentIndex],
                                        derivedUnit->denominator_prefix[kPSTemperatureIndex],
                                        derivedUnit->numerator_prefix[kPSTemperatureIndex],
                                        derivedUnit->denominator_prefix[kPSAmountIndex],
                                        derivedUnit->numerator_prefix[kPSAmountIndex],
                                        derivedUnit->denominator_prefix[kPSLuminousIntensityIndex],
                                        derivedUnit->numerator_prefix[kPSLuminousIntensityIndex],
                                        NULL,NULL,NULL,0,false,false,1.0);
    
    /*
	 *	Calculate the multiplier for the numerical part of the new quantity.
	 */
    
    if(unit_multiplier) {
        if(*unit_multiplier == 0.0) *unit_multiplier = 1.0;
        *unit_multiplier *= powl(PSUnitScaleToCoherentSIUnit(input),power)/PSUnitScaleToCoherentSIUnit(theUnit);
    }
	return theUnit;
}

PSUnitRef PSUnitByRaisingToAPower(PSUnitRef input, double power,double *unit_multiplier, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    PSUnitRef unit = PSUnitByRaisingToAPowerWithoutReducing(input, power, unit_multiplier, error);
    return PSUnitByReducing(unit, unit_multiplier);
}

PSUnitRef PSUnitFindWithName(CFStringRef input)
{
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    IF_NO_OBJECT_EXISTS_RETURN(unitsLibrary,NULL)
	
    CFIndex count = CFDictionaryGetCount (unitsLibrary);
    CFStringRef keys[count];
    PSUnitRef units[count];
    CFDictionaryGetKeysAndValues(unitsLibrary, (const void **) keys, (const void **) units);
    
	for(CFIndex index=0;index<count;index++) {
		CFStringRef name = PSUnitCreateName(units[index]);
		if(name)
            if(CFStringCompare(name,input,0)==kCFCompareEqualTo) {
                CFRelease(name);
                PSUnitRef theUnit = units[index];
                return theUnit;
            }
        if(name) CFRelease(name);
		name = PSUnitCreatePluralName(units[index]);
		if(name)
            if(CFStringCompare(name,input,0)==kCFCompareEqualTo){
                CFRelease(name);
                PSUnitRef theUnit = units[index];
                return theUnit;
            }
        if(name) CFRelease(name);
	}
	return NULL;
}

#pragma mark Strings and Archiving

CFStringRef PSUnitCreateDerivedLaTeXSymbol(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    /*
     *    This routine constructs a unit symbol in terms of the seven base unit symbols
     *    including their SI Prefix units.
     *
     *  This routine will not substitute any special SI symbols.
     */
    
    // Note:  This doesn't work for prefixed Special SI units or Non-SI units.
    // In both those cases, this routine would need to return a numerical value multiplier
    // so the quantity can be expressed correctly in the units of the derived symbol.
    // Therefore, we return the special SI or Non-Si unit prefixed symbol
    
    if(theUnit->root_symbol) return CFStringCreateCopy(kCFAllocatorDefault, theUnit->symbol);
    
    CFMutableStringRef numerator = CFStringCreateMutable(NULL,0);
    CFMutableStringRef denominator = CFStringCreateMutable(NULL,0);
    bool denominator_multiple_units = false;
    
    // Numerator
    uint8_t exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality,0);
    if(exponent>0) {
        CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetNumeratorPrefixAtIndex(theUnit,0));
        if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@%@$^{%d}$"),prefix,baseUnitRootSymbol(0),exponent);
        else CFStringAppendFormat(numerator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(0));
    }
    for(uint8_t index = 1;index<7;index++) {
        exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality,index);
        if(exponent>0) {
            CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetNumeratorPrefixAtIndex(theUnit,index));
            if(CFStringGetLength(numerator)==0) {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@%@$^{%d}$"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(index));
                
            }
            else {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("$\\cdot$%@%@$^{%d}$"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("$\\cdot$%@%@"),prefix,baseUnitRootSymbol(index));
            }
        }
    }
    
    // Denominator
    exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality,0);
    if(exponent>0) {
        CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetDenominatorPrefixAtIndex(theUnit,0));
        if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@%@$^{%d}$"),prefix,baseUnitRootSymbol(0),exponent);
        else CFStringAppendFormat(denominator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(0));
    }
    for(uint8_t index = 1;index<7;index++) {
        
        exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality,index);
        if(exponent>0) {
            CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetDenominatorPrefixAtIndex(theUnit,index));
            if(CFStringGetLength(denominator)==0) {
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@%@$^{%d}$"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(index));
            }
            else {
                denominator_multiple_units = true;
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("$\\cdot$%@%@$^{%d}$"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("$\\cdot$%@%@"),prefix,baseUnitRootSymbol(index));
            }
        }
    }
    
    if(CFStringGetLength(numerator)!=0) {
        if(CFStringGetLength(denominator)!=0) {
            CFStringRef symbol;
            if(denominator_multiple_units) symbol = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL, CFSTR("%@/(%@)"), numerator,denominator);
            else symbol = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL, CFSTR("%@/%@"), numerator,denominator);
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
            if(denominator_multiple_units) symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("(1/(%@))"),denominator);
            else symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("(1/%@)"),denominator);
            CFRelease(numerator);
            CFRelease(denominator);
            return symbol;
        }
        else {
            return CFSTR(" ");
        }
    }
}


CFStringRef PSUnitCreateDerivedSymbol(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    /*
     *    This routine constructs a unit symbol in terms of the seven base unit symbols
     *    including their SI Prefix units.
     *
     *  This routine will not substitute any special SI symbols.
     */
    
    // Note:  This doesn't work for prefixed Special SI units or Non-SI units.
    // In both those cases, this routine would need to return a numerical value multiplier
    // so the quantity can be expressed correctly in the units of the derived symbol.
    // Therefore, we return the special SI or Non-Si unit prefixed symbol
    
    if(theUnit->root_symbol) return CFStringCreateCopy(kCFAllocatorDefault, theUnit->symbol);
    
    CFMutableStringRef numerator = CFStringCreateMutable(NULL,0);
    CFMutableStringRef denominator = CFStringCreateMutable(NULL,0);
    bool denominator_multiple_units = false;
    
    // Numerator
    uint8_t exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality,0);
    if(exponent>0) {
        CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetNumeratorPrefixAtIndex(theUnit,0));
        if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@%@^%d"),prefix,baseUnitRootSymbol(0),exponent);
        else CFStringAppendFormat(numerator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(0));
    }
    for(uint8_t index = 1;index<7;index++) {
        exponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality,index);
        if(exponent>0) {
            CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetNumeratorPrefixAtIndex(theUnit,index));
            if(CFStringGetLength(numerator)==0) {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("%@%@^%d"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(index));
                
            }
            else {
                if(exponent!=1) CFStringAppendFormat(numerator,NULL,CFSTR("•%@%@^%d"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(numerator,NULL,CFSTR("•%@%@"),prefix,baseUnitRootSymbol(index));
            }
        }
    }
    
    // Denominator
    exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality,0);
    if(exponent>0) {
        CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetDenominatorPrefixAtIndex(theUnit,0));
        if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@%@^%d"),prefix,baseUnitRootSymbol(0),exponent);
        else CFStringAppendFormat(denominator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(0));
    }
    for(uint8_t index = 1;index<7;index++) {
        
        exponent = PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality,index);
        if(exponent>0) {
            CFStringRef prefix = prefixSymbolForSIPrefix(PSUnitGetDenominatorPrefixAtIndex(theUnit,index));
            if(CFStringGetLength(denominator)==0) {
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("%@%@^%d"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("%@%@"),prefix,baseUnitRootSymbol(index));
            }
            else {
                denominator_multiple_units = true;
                if(exponent!=1) CFStringAppendFormat(denominator,NULL,CFSTR("•%@%@^%d"),prefix,baseUnitRootSymbol(index),exponent);
                else CFStringAppendFormat(denominator,NULL,CFSTR("•%@%@"),prefix,baseUnitRootSymbol(index));
            }
        }
    }
    
    if(CFStringGetLength(numerator)!=0) {
        if(CFStringGetLength(denominator)!=0) {
            CFStringRef symbol;
            if(denominator_multiple_units) symbol = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL, CFSTR("%@/(%@)"), numerator,denominator);
            else symbol = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL, CFSTR("%@/%@"), numerator,denominator);
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
            if(denominator_multiple_units) symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("(1/(%@))"),denominator);
            else symbol = CFStringCreateWithFormat(NULL, NULL, CFSTR("(1/%@)"),denominator);
            CFRelease(numerator);
            CFRelease(denominator);
            return symbol;
        }
        else {
            return CFSTR(" ");
        }
    }
}

CFDataRef PSUnitCreateData(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,NULL)
    CFStringRef symbol = PSUnitCopySymbol(theUnit);
    CFDataRef result = CFStringCreateExternalRepresentation(kCFAllocatorDefault,symbol,kCFStringEncodingUTF16,0);
    CFRelease(symbol);
    return result;
}

PSUnitRef PSUnitWithData(CFDataRef data, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(data,NULL)
    CFStringRef symbol = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault,data, kCFStringEncodingUTF16);
    
    // Temporary Fix
    if(CFStringCompare(symbol, CFSTR("us"), 0)==kCFCompareEqualTo) {
        CFRelease(symbol);
        symbol = CFSTR("µs");
    }
    PSUnitRef unit = PSUnitByParsingSymbol(symbol, NULL, error);
    if(symbol) CFRelease(symbol);
    return unit;
}

void PSUnitShow(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,)
    PSCFStringShow(theUnit->symbol);
    fprintf(stdout,"\n");
    return;
}

static void PSUnitDisplay (const void *key, const void *value,void *context)
{
    PSUnitShow(value);
}

static void PSUnitDisplayFull (const void *key, const void *value,void *context)
{
    PSUnitShowFull(value);
}


#pragma mark Tests

bool PSUnitEqual(PSUnitRef theUnit1,PSUnitRef theUnit2)
{
    // if true, then Units are equal in every way
    IF_NO_OBJECT_EXISTS_RETURN(theUnit1,false)
    IF_NO_OBJECT_EXISTS_RETURN(theUnit2,false)
    
    if(theUnit1==theUnit2) return true;
    
    if(!PSUnitAreEquivalentUnits(theUnit1,theUnit2)) return false;
    
    if(theUnit1->root_name==NULL && theUnit2->root_name != NULL) return false;
	if(theUnit1->root_name!=NULL && theUnit2->root_name == NULL) return false;
	if(theUnit1->root_name!=NULL && theUnit2->root_name != NULL) {
        if(CFStringCompare(theUnit1->root_name,theUnit2->root_name,0)!=kCFCompareEqualTo) return false;
	}
    
    if(theUnit1->root_plural_name==NULL && theUnit2->root_plural_name != NULL) return false;
	if(theUnit1->root_plural_name!=NULL && theUnit2->root_plural_name == NULL) return false;
	if(theUnit1->root_plural_name!=NULL && theUnit2->root_plural_name != NULL) {
        if(CFStringCompare(theUnit1->root_plural_name,theUnit2->root_plural_name,0)!=kCFCompareEqualTo) return false;
	}
    
	if(theUnit1->root_symbol==NULL && theUnit2->root_symbol != NULL) return false;
	if(theUnit1->root_symbol!=NULL && theUnit2->root_symbol == NULL) return false;
	if(theUnit1->root_symbol!=NULL && theUnit2->root_symbol != NULL) {
        if(CFStringCompare(theUnit1->root_symbol,theUnit2->root_symbol,0)!=kCFCompareEqualTo) return false;
	}
    
    if(theUnit1->root_symbol_prefix != theUnit2->root_symbol_prefix) return false;
	if(theUnit1->is_special_si_symbol != theUnit2->is_special_si_symbol) return false;
	if(theUnit1->scale_to_coherent_si != theUnit2->scale_to_coherent_si) return false;
	
    CFStringRef symbol1 = PSUnitCreateDerivedSymbol(theUnit1);
    CFStringRef symbol2 = PSUnitCreateDerivedSymbol(theUnit2);
    if(CFStringCompare(symbol1, symbol2, 0) !=kCFCompareEqualTo) {
        CFRelease(symbol1);
        CFRelease(symbol2);
        return false;
    }
    CFRelease(symbol1);
    CFRelease(symbol2);
    return true;
}

bool PSUnitHasSameReducedDimensionality(PSUnitRef theUnit1, PSUnitRef theUnit2)
{
    if(theUnit1==NULL || theUnit2 == NULL) return false;
    
    return PSDimensionalityHasSameReducedDimensionality(theUnit1->dimensionality, theUnit2->dimensionality);
}

bool PSUnitAreEquivalentUnits(PSUnitRef theUnit1, PSUnitRef theUnit2)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit1,false)
    IF_NO_OBJECT_EXISTS_RETURN(theUnit2,false)
 	if(theUnit1==theUnit2) return true;
    
    // If true, these two units can be substituted for each other without modifying
    // the quantity's numerical value.
	if(!PSDimensionalityEqual(theUnit1->dimensionality, theUnit2->dimensionality)) return false;
    if(PSCompareDoubleValues(PSUnitScaleToCoherentSIUnit(theUnit1),PSUnitScaleToCoherentSIUnit(theUnit2)) != kPSCompareEqualTo) return false;
	return true;
}

bool PSUnitIsCoherentSIBaseUnit(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false)
    
    // Non-SI units return false
    if(theUnit->scale_to_coherent_si != 1.) return false;
    
    // To be an SI base unit all the denominator exponents must be 0
    // and all numerator exponents are zero except one, which is 1
	if(theUnit->root_symbol==NULL) {
		for(int i=0;i<7;i++) if(PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality, i) !=0) return false;
        int count = 0;
        int index = -1;
		for(int i=0;i<7;i++) {
            uint8_t numeratorExponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i);
            if(numeratorExponent>1) return false;
            if(numeratorExponent<0) return false;
            if(numeratorExponent==1) {
                index = i;
                count++;
            }
        }
        // To be a coherent base unit ...
        // All prefixes must be kPSSIPrefixNone, except mass, which is kPSSIPrefixKilo (for kilogram)
        if(index==1 && count==1 && theUnit->numerator_prefix[index]==kPSSIPrefixKilo) return true;
		else if(count==1 && theUnit->numerator_prefix[index]==kPSSIPrefixNone) return true;
	}
	return false;
}

bool PSUnitIsSIBaseRootUnit(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false)
    
    // Non-SI units return false
    if(theUnit->scale_to_coherent_si != 1.) return false;
    
    // To be an SI base unit all the denominator exponents must be 0
    // and all numerator exponents are zero except one, which is 1
	if(theUnit->root_symbol==NULL) {
		for(int i=0;i<7;i++) if(PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality, i) !=0) return false;
        int count = 0;
        int index = -1;
		for(int i=0;i<7;i++) {
            uint8_t numeratorExponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i);
            if(numeratorExponent>1) return false;
            if(numeratorExponent<0) return false;
            if(numeratorExponent==1) {
                index = i;
                count++;
            }
        }
        // To be a coherent base unit ...
        // All prefixes must be kPSSIPrefixNone
		if(count==1 && theUnit->numerator_prefix[index]==kPSSIPrefixNone) return true;
	}
	return false;
}

bool PSUnitIsSIBaseUnit(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false)
    
    // Non-SI units return false
    if(theUnit->scale_to_coherent_si != 1.) return false;
    
    // To be a base unit all the denominator exponents must be 0
    // and all numerator exponents are zero except one, which is 1
	if(theUnit->root_symbol==NULL) {
		for(int i=0;i<7;i++) if(PSDimensionalityGetDenominatorExponentAtIndex(theUnit->dimensionality, i)  != 0) return false;
        int count = 0;
		for(int i=0;i<7;i++) {
            uint8_t numeratorExponent = PSDimensionalityGetNumeratorExponentAtIndex(theUnit->dimensionality, i);
            if(numeratorExponent>1) return false;
            if(numeratorExponent<0) return false;
            if(numeratorExponent==1) count++;
        }
		if(count==1) return true;
	}
	return false;
}

bool PSUnitIsCoherentDerivedUnit(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,false)
    
    // Non-SI units are not coherent SI units.
    if(theUnit->scale_to_coherent_si != 1.) return false;
	if(theUnit->is_special_si_symbol) return false;
    
    // Prefixed Special SI units are no coherent SI Units.
	if(theUnit->root_symbol_prefix) return false;
    
    // All the dimension prefixes must be kPSSIPrefixNone,
    // except mass which is kPSSIPrefixKilo
	if(theUnit->numerator_prefix[kPSLengthIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->numerator_prefix[kPSMassIndex]!=kPSSIPrefixKilo) return false;
	if(theUnit->numerator_prefix[kPSTimeIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->numerator_prefix[kPSCurrentIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->numerator_prefix[kPSTemperatureIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->numerator_prefix[kPSAmountIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->numerator_prefix[kPSLuminousIntensityIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->denominator_prefix[kPSLengthIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->denominator_prefix[kPSMassIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->denominator_prefix[kPSTimeIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->denominator_prefix[kPSCurrentIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->denominator_prefix[kPSTemperatureIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->denominator_prefix[kPSAmountIndex]!=kPSSIPrefixNone) return false;
	if(theUnit->denominator_prefix[kPSLuminousIntensityIndex]!=kPSSIPrefixNone) return false;
	return true;
}

bool PSUnitIsDimensionlessAndUnderived(PSUnitRef theUnit)
{
    if(!PSDimensionalityIsDimensionlessAndNotDerived(theUnit->dimensionality)) return false;
    if(theUnit->root_name!=NULL) return false;
    return true;
}

bool PSUnitIsDimensionless(PSUnitRef theUnit)
{
    if(!PSDimensionalityIsDimensionless(theUnit->dimensionality)) return false;
    return true;
}

bool PSUnitHasDerivedSymbol(PSUnitRef theUnit)
{
    CFRange range = CFRangeMake(0, CFStringGetLength(theUnit->symbol));
    CFRange resultRange;
    CFCharacterSetRef theSet = CFCharacterSetCreateWithCharactersInString (kCFAllocatorDefault,CFSTR("•*/^"));
    Boolean isDerived = CFStringFindCharacterFromSet(theUnit->symbol,theSet,range,kCFCompareBackwards,&resultRange);
    CFRelease(theSet);
    return isDerived;
}


void PSUnitShowFull(PSUnitRef theUnit)
{
    IF_NO_OBJECT_EXISTS_RETURN(theUnit,)
    char string[256];
    
    CFShow(CFSTR("============================================================================================================="));
    
    CFStringRef cf_string;
    
    CFStringRef name = PSUnitCreateName(theUnit);
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL,CFSTR("name: %@"),name);
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    if(name) CFRelease(name);
    CFRelease(cf_string);
    
    CFStringRef pluralName = PSUnitCreatePluralName(theUnit);
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL,CFSTR("plural name: %@"),pluralName);
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    if(pluralName) CFRelease(pluralName);
    CFRelease(cf_string);
    
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit), NULL,CFSTR("symbol: %@"),theUnit->symbol);
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
    PSDimensionalityShowFull(theUnit->dimensionality);
    
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("SI base dimension numerator prefix:                   %@   %@   %@   %@   %@   %@   %@"),
                                         prefixSymbolForSIPrefix(theUnit->numerator_prefix[kPSLengthIndex]),
                                         prefixSymbolForSIPrefix(theUnit->numerator_prefix[kPSMassIndex]),
                                         prefixSymbolForSIPrefix(theUnit->numerator_prefix[kPSTimeIndex]),
                                         prefixSymbolForSIPrefix(theUnit->numerator_prefix[kPSCurrentIndex]),
                                         prefixSymbolForSIPrefix(theUnit->numerator_prefix[kPSTemperatureIndex]),
                                         prefixSymbolForSIPrefix(theUnit->numerator_prefix[kPSAmountIndex]),
                                         prefixSymbolForSIPrefix(theUnit->numerator_prefix[kPSLuminousIntensityIndex])
                                         );
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("SI base dimension denominator prefix:                   %@   %@   %@   %@   %@   %@   %@"),
                                         prefixSymbolForSIPrefix(theUnit->denominator_prefix[kPSLengthIndex]),
                                         prefixSymbolForSIPrefix(theUnit->denominator_prefix[kPSMassIndex]),
                                         prefixSymbolForSIPrefix(theUnit->denominator_prefix[kPSTimeIndex]),
                                         prefixSymbolForSIPrefix(theUnit->denominator_prefix[kPSCurrentIndex]),
                                         prefixSymbolForSIPrefix(theUnit->denominator_prefix[kPSTemperatureIndex]),
                                         prefixSymbolForSIPrefix(theUnit->denominator_prefix[kPSAmountIndex]),
                                         prefixSymbolForSIPrefix(theUnit->denominator_prefix[kPSLuminousIntensityIndex])
                                         );
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
    CFMutableStringRef cf_mut_string = CFStringCreateMutableCopy(CFGetAllocator(theUnit), 0, CFSTR("SI base dimension derived symbol:  "));
    CFStringAppend(cf_mut_string,theUnit->symbol);
    
    CFStringGetCString(cf_mut_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_mut_string);
    
    CFShow(CFSTR("-------------------------------------------------------------------------------------------------------------"));
    
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("scale_to_coherent_si_system: \t\t %g "),
                                         theUnit->scale_to_coherent_si
                                         );
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("scale from symbol to coherent derived si unit: %g"),
                                         PSUnitScaleToCoherentSIUnit(theUnit)
                                         );
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
    CFStringRef rootName = PSUnitCopyRootName(theUnit);
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("root_name: \t\t\t\t\t %@"),
                                         rootName
                                         );
    if(rootName) CFRelease(rootName);
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
    CFStringRef pluralRootName = PSUnitCopyRootPluralName(theUnit);
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("root_plural_name: \t\t\t %@"),
                                         pluralRootName
                                         );
    if(pluralRootName) CFRelease(pluralRootName);
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
    CFStringRef rootSymbol = PSUnitCopyRootSymbol(theUnit);
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("root_symbol: \t\t\t\t %@"),
                                         rootSymbol
                                         );
    if(rootSymbol) CFRelease(rootSymbol);
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    CFRelease(cf_string);
    
	if(theUnit->is_special_si_symbol) cf_string = CFSTR("is_special_si_symbol: \t\t\t YES ");
	else cf_string = CFSTR("is_special_si_symbol: \t\t\t NO ");
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    
    CFRelease(cf_string);
    
    cf_string = CFStringCreateWithFormat(CFGetAllocator(theUnit),
                                         NULL,
                                         CFSTR("root_symbol_prefix: \t\t %d : %@"),
                                         theUnit->root_symbol_prefix,
                                         prefixSymbolForSIPrefix(theUnit->root_symbol_prefix)
                                         );
    
    CFStringGetCString(cf_string, string, 256, kCFStringEncodingUTF8);
    fprintf(stderr,"%s\n",string);
    
    CFRelease(cf_string);
    
    CFShow(CFSTR("============================================================================================================="));
}

#pragma mark PSUnits Library

static bool AddAllSIPrefixedUnitsToLibrary(PSUnitRef rootUnit, CFStringRef quantityName);

static PSUnitRef AddUnitForQuantityToLibrary(CFStringRef quantityName,
                                             PSSIPrefix length_numerator_prefix,           PSSIPrefix length_denominator_prefix,
                                             PSSIPrefix mass_numerator_prefix,             PSSIPrefix mass_denominator_prefix,
                                             PSSIPrefix time_numerator_prefix,             PSSIPrefix time_denominator_prefix,
                                             PSSIPrefix current_numerator_prefix,          PSSIPrefix current_denominator_prefix,
                                             PSSIPrefix temperature_numerator_prefix,      PSSIPrefix temperature_denominator_prefix,
                                             PSSIPrefix amount_numerator_prefix,           PSSIPrefix amount_denominator_prefix,
                                             PSSIPrefix luminous_intensity_numerator_prefix,   PSSIPrefix luminous_intensity_denominator_prefix,
                                             CFStringRef root_name,
                                             CFStringRef root_plural_name,
                                             CFStringRef root_symbol,
                                             PSSIPrefix root_symbol_prefix,
                                             bool is_special_si_symbol,
                                             double scale_to_coherent_si,
                                             bool allows_si_prefix)
{
    
    PSDimensionalityRef theDimensionality = PSDimensionalityForQuantityName(quantityName);
    PSUnitRef unit = PSUnitCreate(theDimensionality,
                                  length_numerator_prefix,              length_denominator_prefix,
                                  mass_numerator_prefix,                mass_denominator_prefix,
                                  time_numerator_prefix,                time_denominator_prefix,
                                  current_numerator_prefix,             current_denominator_prefix,
                                  temperature_numerator_prefix,         temperature_denominator_prefix,
                                  amount_numerator_prefix,              amount_denominator_prefix,
                                  luminous_intensity_numerator_prefix,  luminous_intensity_denominator_prefix,
                                  root_name,
                                  root_plural_name,
                                  root_symbol,
                                  root_symbol_prefix,
                                  allows_si_prefix,
                                  is_special_si_symbol,
                                  scale_to_coherent_si);
    
    // Add unit to units library dictionary
    if(CFDictionaryContainsKey(unitsLibrary, unit->symbol)) {
        fprintf(stderr,"WARNING - Cannot add unit to library because symbol already is present\n");
        PSCFStringShow(unit->symbol);
        CFRelease(unit);
        return CFDictionaryGetValue(unitsLibrary, unit->symbol);
    }
    CFDictionaryAddValue(unitsLibrary, unit->symbol, unit);
    unit->staticInstance = true;
    CFRelease(unit);    // Note: this does nothing for staticInstance = true
    
    // Append unit to mutable array value associated with quantity key inside quanity library dictionary
    {
        CFMutableArrayRef units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, quantityName);
        if(units) CFArrayAppendValue(units, unit);
        else {
            units = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFArrayAppendValue(units, unit);
            CFDictionaryAddValue(unitsQuantitiesLibrary, quantityName, units);
            CFRelease(units);
        }
    }
    
    // Append unit to mutable array value associated with dimensionality key inside dimensionality library dictionary
    {
        CFStringRef dimensionalitySymbol = PSDimensionalityGetSymbol(theDimensionality);
        CFMutableArrayRef units = (CFMutableArrayRef) CFDictionaryGetValue(unitsDimensionalitiesLibrary, dimensionalitySymbol);
        if(units) CFArrayAppendValue(units, unit);
        else {
            units = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFArrayAppendValue(units, unit);
            CFDictionaryAddValue(unitsDimensionalitiesLibrary, dimensionalitySymbol, units);
            CFRelease(units);
        }
    }
    
    if(allows_si_prefix) AddAllSIPrefixedUnitsToLibrary(unit, quantityName);
    return unit;
}

static bool AddAllSIPrefixedUnitsToLibrary(PSUnitRef rootUnit, CFStringRef quantityName)
{
	IF_NO_OBJECT_EXISTS_RETURN(rootUnit,false)
    
	// Table 5 - SI Prefixes
    PSSIPrefix prefix[21] = {
        kPSSIPrefixYocto,
        kPSSIPrefixZepto,
        kPSSIPrefixAtto,
        kPSSIPrefixFemto,
        kPSSIPrefixPico,
        kPSSIPrefixNano,
        kPSSIPrefixMicro,
        kPSSIPrefixMilli,
        kPSSIPrefixCenti,
        kPSSIPrefixDeci,
        kPSSIPrefixNone,
        kPSSIPrefixDeca,
        kPSSIPrefixHecto,
        kPSSIPrefixKilo,
        kPSSIPrefixMega,
        kPSSIPrefixGiga,
        kPSSIPrefixTera,
        kPSSIPrefixPeta,
        kPSSIPrefixExa,
        kPSSIPrefixZetta,
        kPSSIPrefixYotta};
    
    CFStringRef root_name = PSUnitCopyRootName(rootUnit);
    if(root_name) {
        for(int iPrefix = 0;iPrefix<21; iPrefix++)  {
            if(prefix[iPrefix]!=kPSSIPrefixNone) {
                if(PSUnitIsSIBaseUnit(rootUnit)) {
                    PSDimensionalityRef dimensionality = PSUnitGetDimensionality(rootUnit);
                    PSSIPrefix numerator_prefixes[7];
                    PSSIPrefix denominator_prefixes[7];
                    for(int8_t i = 0; i<7; i++) {
                        denominator_prefixes[i] = kPSSIPrefixNone;
                        if(PSDimensionalityGetNumeratorExponentAtIndex(dimensionality,i)==1) numerator_prefixes[i] = prefix[iPrefix];
                        else numerator_prefixes[i] = kPSSIPrefixNone;
                    }
                    AddUnitForQuantityToLibrary(quantityName,
                                                numerator_prefixes[kPSLengthIndex],
                                                denominator_prefixes[kPSLengthIndex],
                                                numerator_prefixes[kPSMassIndex],
                                                denominator_prefixes[kPSMassIndex],
                                                numerator_prefixes[kPSTimeIndex],
                                                denominator_prefixes[kPSTimeIndex],
                                                numerator_prefixes[kPSCurrentIndex],
                                                denominator_prefixes[kPSCurrentIndex],
                                                numerator_prefixes[kPSTemperatureIndex],
                                                denominator_prefixes[kPSTemperatureIndex],
                                                numerator_prefixes[kPSAmountIndex],
                                                denominator_prefixes[kPSAmountIndex],
                                                numerator_prefixes[kPSLuminousIntensityIndex],
                                                denominator_prefixes[kPSLuminousIntensityIndex],
                                                rootUnit->root_name,
                                                rootUnit->root_plural_name,
                                                rootUnit->root_symbol,
                                                rootUnit->root_symbol_prefix,
                                                rootUnit->is_special_si_symbol,
                                                rootUnit->scale_to_coherent_si, false);
                    
                }
                else if(rootUnit->root_symbol) {
                    AddUnitForQuantityToLibrary(quantityName,
                                                rootUnit->numerator_prefix[kPSLengthIndex],
                                                rootUnit->denominator_prefix[kPSLengthIndex],
                                                rootUnit->numerator_prefix[kPSMassIndex],
                                                rootUnit->denominator_prefix[kPSMassIndex],
                                                rootUnit->numerator_prefix[kPSTimeIndex],
                                                rootUnit->denominator_prefix[kPSTimeIndex],
                                                rootUnit->numerator_prefix[kPSCurrentIndex],
                                                rootUnit->denominator_prefix[kPSCurrentIndex],
                                                rootUnit->numerator_prefix[kPSTemperatureIndex],
                                                rootUnit->denominator_prefix[kPSTemperatureIndex],
                                                rootUnit->numerator_prefix[kPSAmountIndex],
                                                rootUnit->denominator_prefix[kPSAmountIndex],
                                                rootUnit->numerator_prefix[kPSLuminousIntensityIndex],
                                                rootUnit->denominator_prefix[kPSLuminousIntensityIndex],
                                                rootUnit->root_name,
                                                rootUnit->root_plural_name,
                                                rootUnit->root_symbol,
                                                prefix[iPrefix],
                                                rootUnit->is_special_si_symbol,
                                                rootUnit->scale_to_coherent_si, false);
                }
            }
        }
    }
    
	return true;
}

static void AddNonSIUnitToLibrary(CFStringRef quantityName, CFStringRef name, CFStringRef pluralName, CFStringRef symbol, double scale_to_coherent_si)
{
    AddUnitForQuantityToLibrary(quantityName,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                name,pluralName,symbol, kPSSIPrefixNone, false, scale_to_coherent_si,false);
}

void UnitsLibraryCreate()
{
    CFLocaleRef loc = CFLocaleCopyCurrent();
    CFStringRef countryCode = CFLocaleGetValue (loc, kCFLocaleCountryCode);
    CFStringRef countryName = CFLocaleCopyDisplayNameForPropertyValue (loc, kCFLocaleCountryCode, countryCode);
    
    CFShow(countryCode);
    CFShow(countryName);
    CFArrayRef langs = CFLocaleCopyPreferredLanguages();
    CFStringRef langCode = CFArrayGetValueAtIndex (langs, 0);
    CFStringRef langName = CFLocaleCopyDisplayNameForPropertyValue (loc, kCFLocaleLanguageCode, langCode);
//    CFShow(langCode);
//    CFShow(langName);
    if(countryName) CFRelease(countryName);
    if(langs) CFRelease(langs);
    if(langName) CFRelease(langName);
    if(loc) CFRelease(loc);
    
    if(unitsLibrary) CFRelease(unitsLibrary);
    unitsLibrary  = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	IF_NO_OBJECT_EXISTS_RETURN(unitsLibrary,)
    
    if(unitsQuantitiesLibrary) CFRelease(unitsQuantitiesLibrary);
    unitsQuantitiesLibrary  = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    IF_NO_OBJECT_EXISTS_RETURN(unitsQuantitiesLibrary,)
    
    if(unitsDimensionalitiesLibrary) CFRelease(unitsDimensionalitiesLibrary);
    unitsDimensionalitiesLibrary  = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    IF_NO_OBJECT_EXISTS_RETURN(unitsDimensionalitiesLibrary,)
    
    // Derived Constants
#pragma mark Derived Constants
    double hbar = kPSPlanckConstant/(2*kPSPi);
    double alpha = (1./(4.*kPSPi*kPSElectricConstant))*kPSElementaryCharge*kPSElementaryCharge/(kPSSpeedOfLight*kPSPlanckConstant/(2*kPSPi));
    double lightYear = (double) kPSYear * (double) kPSSpeedOfLight;
    double E_h = kPSElectronMass * (kPSElementaryCharge*kPSElementaryCharge/(2*kPSElectricConstant*kPSPlanckConstant))*(kPSElementaryCharge*kPSElementaryCharge/(2*kPSElectricConstant*kPSPlanckConstant));
    double a_0 = kPSElectricConstant*kPSPlanckConstant*kPSPlanckConstant/(kPSPi*kPSElectronMass*kPSElementaryCharge*kPSElementaryCharge);
    double R_H = kPSElectronMass*kPSElementaryCharge*kPSElementaryCharge*kPSElementaryCharge*kPSElementaryCharge/(8*kPSElectricConstant*kPSElectricConstant*kPSPlanckConstant*kPSPlanckConstant*kPSPlanckConstant*kPSSpeedOfLight);
    double Ry = kPSPlanckConstant*kPSSpeedOfLight*R_H;
    double Λ_0 = E_h/(kPSElementaryCharge*a_0*a_0);
    double G_0 = 2*kPSElementaryCharge*kPSElementaryCharge/kPSPlanckConstant;
    double mu_N = kPSElementaryCharge*hbar/(2*kPSProtonMass);
    double mu_e = kPSElementaryCharge*hbar/(2*kPSElectronMass);
    
    long double c_0 = (long double) kPSSpeedOfLight;
    long double c_03 = c_0*c_0*c_0;
    long double c_05 = c_0*c_0*c_0*c_0*c_0;

    double planckTime =sqrt(hbar* kPSGravitaionalConstant/c_05);
    double planckLength = sqrt(hbar * kPSGravitaionalConstant/c_03);
    double planckMass = sqrt(hbar*kPSSpeedOfLight/kPSGravitaionalConstant);
    double planckTemperature = planckMass*kPSSpeedOfLight*kPSSpeedOfLight/kPSBoltmannConstant;
    double planckCharge = sqrt(4 * kPSPi*kPSElectricConstant*hbar*kPSSpeedOfLight);
    // Base Root Name and Root Symbol Units - Table 1
    

    // ***** Dimensionless **********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityDimensionless
    AddUnitForQuantityToLibrary(kPSQuantityDimensionless,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1.,false);
    
    // Dimensionless - Percent
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("percent"), CFSTR("percent"), CFSTR("%"),0.01);
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("part per thousand"), CFSTR("parts per thousand"), CFSTR("‰"),0.001);
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("part per ten thousand"), CFSTR("parts per ten thousand"), CFSTR("‱"),0.0001);
    
    // Dimensionless - ppm
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("part per million"), CFSTR("parts per million"), CFSTR("ppm"),1.e-6);
    
    // Dimensionless - ppb
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("part per billion"), CFSTR("parts per billion"), CFSTR("ppb"),1.0e-9);
     
    // Dimensionless - ppt
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("part per trillion"), CFSTR("parts per trillion"), CFSTR("ppt"),1.e-12);
    
    // Dimensionless - ppq
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("part per quadrillion"), CFSTR("parts per quadrillion"), CFSTR("ppq"),1.e-15);
    

    // Derived Dimensionless - fine structure constant
    // (1/(4•π•ε_0))•q_e^2/(c_0•h_P/(2•π))
    AddNonSIUnitToLibrary(kPSQuantityFineStructureConstant, CFSTR("fine structure constant"), CFSTR("fine structure constant"), CFSTR("α"),alpha);

    // Derived Dimensionless - inverse fine structure constant
    AddNonSIUnitToLibrary(kPSQuantityFineStructureConstant, CFSTR("inverse fine structure constant"), CFSTR("inverse fine structure constant"), CFSTR("(1/α)"),1/alpha);

    // ***** Length *****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityLength
    AddUnitForQuantityToLibrary(kPSQuantityLength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1., true);
    
    CFMutableArrayRef units = nil;
    
    // Length - astronomical units
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("astronomical unit"), CFSTR("astronomical units"), CFSTR("ua"),1.49597870691e11);
    
    
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("light year"), CFSTR("light years"), CFSTR("ly"), lightYear);
    
    // Length - Angstrom
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("ångström"), CFSTR("ångströms"), CFSTR("Å"),1.e-10);
    
    // atomic unit of length
    // a_0 = ε_0•h_P^2/(π*m_e•q_e^2)
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("atomic unit of length"), CFSTR("atomic unit of length"), CFSTR("a_0"), a_0);

    // Length - nautical mile - !!!!!! Disabled in favor of Molarity !!!!!!!
//  AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("nautical mile"), CFSTR("nautical miles"), CFSTR("M"),1852.);

    // Length - fathom
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("fathom"), CFSTR("fathoms"), CFSTR("ftm"), 2*1609.344/1760);

    // Length
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("inch"), CFSTR("inches"), CFSTR("in"), 1609.344/63360);
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("foot"), CFSTR("feet"), CFSTR("ft"), 1609.344/5280);
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("yard"), CFSTR("yards"), CFSTR("yd"), 1609.344/1760);
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("mile"), CFSTR("miles"), CFSTR("mi"), 1609.344);

    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("link"), CFSTR("links"), CFSTR("li"), 1609.344/5280*33/50);
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("rod"), CFSTR("rods"), CFSTR("rod"), 1609.344/5280*16.5);
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("chain"), CFSTR("chains"), CFSTR("ch"), 1609.344/5280*16.5*4);
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("furlong"), CFSTR("furlongs"), CFSTR("fur"), 1609.344/5280*16.5*4*10);
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("league"), CFSTR("leagues"), CFSTR("lea"), 1609.344*3);

    // ***** Inverse Length, Wave Number ********************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityWavenumber
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse meter"), CFSTR("inverse meters"), CFSTR("(1/m)"),1);
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse centimeter"), CFSTR("inverse centimeters"), CFSTR("(1/cm)"),100);
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse micrometer"), CFSTR("inverse micrometers"), CFSTR("(1/µm)"),1000000);
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse nanometer"), CFSTR("inverse nanometers"), CFSTR("(1/nm)"),1000000000);

    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse ångström"), CFSTR("inverse ångströms"), CFSTR("(1/Å)"),1.e10);
    
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse mile"), CFSTR("inverse miles"), CFSTR("(1/mi)"),1./1609.344);
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse yard"), CFSTR("inverse yards"), CFSTR("(1/yd)"),1./(1609.344/1760));
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse foot"), CFSTR("inverse feet"), CFSTR("(1/ft)"),1./(1609.344/5280));
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse inch"), CFSTR("inverse inches"), CFSTR("(1/in)"),1./(1609.344/63360));
    
    // Inverse Length - Rydberg constant
    // R_H = m_e•q_e^4/(8•ε_0^2•h_P^3•c_0)
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("rydberg constant"), CFSTR("rydberg constant"), CFSTR("R_∞"),R_H);
    
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityWavenumber);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityInverseLength, units);
    
    // ***** Length Ratio ***********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityLengthRatio
    AddUnitForQuantityToLibrary(kPSQuantityLengthRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("meter per meter"),CFSTR("meters per meter"),CFSTR("m/m"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Plane Angle ************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityPlaneAngle
    AddUnitForQuantityToLibrary(kPSQuantityPlaneAngle,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("radian"),CFSTR("radians"),CFSTR("rad"), kPSSIPrefixNone, true, 1.,true);
    

    // ***** Mass *******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMass
    AddUnitForQuantityToLibrary(kPSQuantityMass,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1., true);
    
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("microgram"), CFSTR("micrograms"), CFSTR("mcg"),1e-9);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("tonne"), CFSTR("tonnes"), CFSTR("t"),1e3);
    
    // Mass - Dalton
    AddUnitForQuantityToLibrary(kPSQuantityMass,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("dalton"),CFSTR("daltons"),CFSTR("Da"), kPSSIPrefixNone, false, kPSAtomicMassConstant,true);

    // Mass - unified atomic mass unit
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("atomic mass unit"), CFSTR("atomic mass units"), CFSTR("u"),kPSAtomicMassConstant);

    // Mass - atomic mass constant
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("atomic mass constant"), CFSTR("atomic mass constant"), CFSTR("m_u"),kPSAtomicMassConstant);

    // electron mass or atomic unit of mass
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("electron mass"), CFSTR("electron mass"), CFSTR("m_e"), kPSElectronMass);
    
    // proton mass
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("proton mass"), CFSTR("proton mass"), CFSTR("m_p"), kPSProtonMass);
    
    // neutron mass
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("neutron mass"), CFSTR("neutron mass"), CFSTR("m_n"), kPSNeutronMass);
    // alpha particle mass
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("alpha particle mass"), CFSTR("alpha particle mass"), CFSTR("m_a"), kPSAlphaParticleMass);
    
    // muon mass
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("muon mass"), CFSTR("myon mass"), CFSTR("m_µ"), kPSMuonMass);

    // Mass
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("ton"), CFSTR("tons"), CFSTR("ton"), 0.45359237*2000);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("hundredweight"), CFSTR("hundredweight"), CFSTR("cwt"), 0.45359237*100);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("pound"), CFSTR("pounds"), CFSTR("lb"), 0.45359237);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("stone"), CFSTR("stones"), CFSTR("st"), 6.35029318);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("ounce"), CFSTR("ounces"), CFSTR("oz"), 0.028349523125);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("grain"), CFSTR("grains"), CFSTR("gr"), 0.45359237/7000);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("dram"), CFSTR("drams"), CFSTR("dr"), 0.45359237/256);
    
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("tonUK"), CFSTR("tonsUK"), CFSTR("tonUK"), 0.45359237*2240);
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("hundredweightUK"), CFSTR("hundredweightUK"), CFSTR("cwtUK"), 0.45359237*112);

    // ***** Inverse Mass ***********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityInverseMass
    // Inverse Mass
    AddNonSIUnitToLibrary(kPSQuantityInverseMass, CFSTR("inverse kilogram"), CFSTR("inverse kilograms"), CFSTR("(1/kg)"),1.);
    AddNonSIUnitToLibrary(kPSQuantityInverseMass, CFSTR("inverse tonne"), CFSTR("inverse tonnes"), CFSTR("(1/t)"),1./1e3);
    AddNonSIUnitToLibrary(kPSQuantityInverseMass, CFSTR("inverse ton"), CFSTR("inverse tons"), CFSTR("(1/ton)"),1./(0.45359237*2000));
    AddNonSIUnitToLibrary(kPSQuantityInverseMass, CFSTR("inverse stone"), CFSTR("inverse stones"), CFSTR("(1/st)"),1./6.35029318);
    AddNonSIUnitToLibrary(kPSQuantityInverseMass, CFSTR("inverse pound"), CFSTR("inverse pounds"), CFSTR("(1/lb)"),1./0.45359237);
    AddNonSIUnitToLibrary(kPSQuantityInverseMass, CFSTR("inverse ounce"), CFSTR("inverse ounces"), CFSTR("(1/oz)"),1./0.028349523125);

    
    // ***** Mass Ratio *************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMassRatio
    AddUnitForQuantityToLibrary(kPSQuantityMassRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per kilogram"),CFSTR("grams per kilogram"),CFSTR("g/kg"), kPSSIPrefixNone, false, 0.001,true);
    
    // ***** Time *******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityTime
    AddUnitForQuantityToLibrary(kPSQuantityTime,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1., true);
    
    // Time
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("minute"), CFSTR("minutes"), CFSTR("min"),kPSMinute);
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("hour"), CFSTR("hours"), CFSTR("h"),kPSHour);
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("day"), CFSTR("days"), CFSTR("d"),kPSDay);
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("week"), CFSTR("weeks"), CFSTR("wk"),kPSWeek);
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("month"), CFSTR("months"), CFSTR("month"),kPSMonth);
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("year"), CFSTR("years"), CFSTR("yr"),kPSYear);
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("century"), CFSTR("centuries"), CFSTR("hyr"),kPSCentury);
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("millennium"), CFSTR("millennia"), CFSTR("kyr"),kPSMillennium);
    
    // atomic unit of time
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("atomic unit of time"), CFSTR("atomic units of time"), CFSTR("ℏ/E_h"),hbar/E_h);

    // natural unit of length
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("natural unit of length"), CFSTR("natural units of length"), CFSTR("ƛ_C"), 386.15926764e-15);

    // natural unit of time
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("natural unit of time"), CFSTR("natural units of time"), CFSTR("ℏ/(m_e•c_0^2)"), hbar/(kPSElectronMass*kPSSpeedOfLight*kPSSpeedOfLight));
    
    // natural unit of momentum
    AddNonSIUnitToLibrary(kPSQuantityLinearMomentum, CFSTR("natural unit of momentum"), CFSTR("natural units of momentum"), CFSTR("m_e•c_0"), kPSElectronMass*kPSSpeedOfLight);
    
    // natural unit of energy
    AddNonSIUnitToLibrary(kPSQuantityEnergy, CFSTR("natural unit of energy"), CFSTR("natural units of energy"), CFSTR("m_e•c_0^2"), kPSElectronMass*kPSSpeedOfLight*kPSSpeedOfLight);

    // planck length
    // sqrt(h_P * G_N/(2*π*c_0^3))
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("planck length"), CFSTR("planck length"), CFSTR("l_P"),planckLength);
    
    // planck mass
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("planck mass"), CFSTR("planck mass"), CFSTR("m_P"),planckMass);
    
    // planck time
    AddNonSIUnitToLibrary(kPSQuantityTime, CFSTR("planck time"), CFSTR("planck time"), CFSTR("t_P"),planckTime);
    
    // planck temperature
    AddNonSIUnitToLibrary(kPSQuantityTemperature, CFSTR("planck temperature"), CFSTR("planck temperature"), CFSTR("T_P"),planckTemperature);
    
    // planck charge
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("planck charge"), CFSTR("planck charge"), CFSTR("q_P"),planckCharge);
    
    // ***** Inverse Time ***********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityInverseTime
    AddNonSIUnitToLibrary(kPSQuantityInverseTime, CFSTR("inverse seconds"), CFSTR("inverse seconds"), CFSTR("(1/s)"),1.);
    AddNonSIUnitToLibrary(kPSQuantityInverseTime, CFSTR("inverse minute"), CFSTR("inverse minutes"), CFSTR("(1/min)"),1./60.);
    AddNonSIUnitToLibrary(kPSQuantityInverseTime, CFSTR("inverse hour"), CFSTR("inverse hours"), CFSTR("(1/h)"),1./(60.*60.));
    AddNonSIUnitToLibrary(kPSQuantityInverseTime, CFSTR("inverse day"), CFSTR("inverse days"), CFSTR("(1/d)"),1./(60.*60*24.));
    AddNonSIUnitToLibrary(kPSQuantityInverseTime, CFSTR("inverse week"), CFSTR("inverse weeks"), CFSTR("(1/wk)"),1./(60.*60*24.*7.));
    AddNonSIUnitToLibrary(kPSQuantityInverseTime, CFSTR("inverse month"), CFSTR("inverse months"), CFSTR("(1/month)"),1./(365.25*86400/12.));
    AddNonSIUnitToLibrary(kPSQuantityInverseTime, CFSTR("inverse year"), CFSTR("inverse years"), CFSTR("(1/yr)"),1./(365.25*86400));
    
    // ***** Time Ratio **************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityTimeRatio
    AddUnitForQuantityToLibrary(kPSQuantityTimeRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("second per second"),CFSTR("seconds per second"),CFSTR("s/s"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Frequency **************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityFrequency
    AddUnitForQuantityToLibrary(kPSQuantityFrequency,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("hertz"),CFSTR("hertz"),CFSTR("Hz"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Frequency Ratio *******************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityFrequencyRatio
    AddUnitForQuantityToLibrary(kPSQuantityFrequencyRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("hertz per hertz"),CFSTR("hertz per hertz"),CFSTR("Hz/Hz"), kPSSIPrefixNone, true, 1.,true);
    
    // Include ppm as a kPSQuantityFrequencyRatio to make NMR people happy.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityFrequencyRatio);
    CFArrayAppendValue(units, PSUnitForSymbol(CFSTR("ppm")));
    
    // ***** Radioactivity **********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityRadioactivity
    AddUnitForQuantityToLibrary(kPSQuantityRadioactivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("becquerel"),CFSTR("becquerels"),CFSTR("Bq"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityRadioactivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("curie"),CFSTR("curies"),CFSTR("Ci"), kPSSIPrefixNone, false, 3.7e10,true);

    // ***** inverse seconds ********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityInverseTimeSquared
    AddNonSIUnitToLibrary(kPSQuantityInverseTimeSquared, CFSTR("inverse millisecond squared"), CFSTR("inverse milliseconds squared"), CFSTR("(1/ms^2)"),1000000.);
    AddNonSIUnitToLibrary(kPSQuantityInverseTimeSquared, CFSTR("inverse second squared"), CFSTR("inverse seconds squared"), CFSTR("(1/s^2)"),1.);
    AddNonSIUnitToLibrary(kPSQuantityInverseTimeSquared, CFSTR("inverse hour inverse second"), CFSTR("inverse hour inverse seconds"), CFSTR("(1/(h•s))"),1./3600.);
    AddNonSIUnitToLibrary(kPSQuantityInverseTimeSquared, CFSTR("inverse hour inverse minute"), CFSTR("inverse hour inverse minutes"), CFSTR("(1/(h•min))"),1./3600./60.);


    // ***** Current ****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityCurrent
    AddUnitForQuantityToLibrary(kPSQuantityCurrent,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityCurrent, CFSTR("atomic unit of current"), CFSTR("atomic unit of current"), CFSTR("q_e•E_h/ℏ"), kPSElementaryCharge*E_h/hbar);
    
#pragma mark kPSQuantityInverseCurrent
    AddNonSIUnitToLibrary(kPSQuantityInverseCurrent, CFSTR("inverse ampere"), CFSTR("inverse amperes"), CFSTR("(1/A)"),1.);

#pragma mark kPSQuantityCurrentRatio
    AddUnitForQuantityToLibrary(kPSQuantityCurrentRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ampere per ampere"),CFSTR("amperes per ampere"),CFSTR("A/A"), kPSSIPrefixNone, true, 1.,true);

    // ***** Thermodynamic Temperature **********************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityTemperature
    AddUnitForQuantityToLibrary(kPSQuantityTemperature,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1.,true);
    AddNonSIUnitToLibrary(kPSQuantityTemperature, CFSTR("rankine"), CFSTR("rankines"), CFSTR("°R"),0.555555555555556);
    AddNonSIUnitToLibrary(kPSQuantityTemperature, CFSTR("fahrenheit"), CFSTR("fahrenheit"), CFSTR("°F"),0.555555555555556);
    AddNonSIUnitToLibrary(kPSQuantityTemperature, CFSTR("celsius"), CFSTR("celsius"), CFSTR("°C"),1);

#pragma mark kPSQuantityInverseTemperature
    AddNonSIUnitToLibrary(kPSQuantityInverseTemperature, CFSTR("inverse kelvin"), CFSTR("inverse kelvin"), CFSTR("(1/K)"),1.);
    
#pragma mark kPSQuantityTemperatureRatio
    AddUnitForQuantityToLibrary(kPSQuantityTemperatureRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("kelvin per kelvin"),CFSTR("kelvin per kelvin"),CFSTR("K/K"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Thermodynamic Temperature Gradient *************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityTemperatureGradient
    AddNonSIUnitToLibrary(kPSQuantityTemperatureGradient, CFSTR("kelvin per meter"), CFSTR("kelvin per meter"), CFSTR("K/m"),1);
    AddNonSIUnitToLibrary(kPSQuantityTemperatureGradient, CFSTR("celsius per meter"), CFSTR("celsius per meter"), CFSTR("°C/m"),1);
    AddNonSIUnitToLibrary(kPSQuantityTemperatureGradient, CFSTR("fahrenheit per foot"), CFSTR("fahrenheit per foot"), CFSTR("°F/ft"),0.555555555555556/(1609.344/5280));
    AddNonSIUnitToLibrary(kPSQuantityTemperatureGradient, CFSTR("rankine per foot"), CFSTR("rankines per foot"), CFSTR("°R/ft"),0.555555555555556/(1609.344/5280));
    
    
    // ***** Amount *****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityAmount
    AddUnitForQuantityToLibrary(kPSQuantityAmount,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1.,true);
    
#pragma mark kPSQuantityInverseAmount
    AddNonSIUnitToLibrary(kPSQuantityInverseAmount, CFSTR("inverse mole"), CFSTR("inverse moles"), CFSTR("(1/mol)"),1.);
    
#pragma mark kPSQuantityAmountRatio
    AddUnitForQuantityToLibrary(kPSQuantityAmountRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per mole"),CFSTR("moles per mole"),CFSTR("mol/mol"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Luminous Intensity *****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityLuminousIntensity
    AddUnitForQuantityToLibrary(kPSQuantityLuminousIntensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                NULL, NULL, NULL, kPSSIPrefixNone, false, 1.,true);
    
#pragma mark kPSQuantityInverseLuminousIntensity
    AddNonSIUnitToLibrary(kPSQuantityInverseLuminousIntensity, CFSTR("inverse candela"), CFSTR("inverse candelas"), CFSTR("(1/cd)"),1.);
    

#pragma mark kPSQuantityLuminousIntensityRatio
    AddUnitForQuantityToLibrary(kPSQuantityLuminousIntensityRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("candela per candela"),CFSTR("candelas per candela"),CFSTR("cd/cd"), kPSSIPrefixNone, true, 1.,true);
    

    // ***** Area *******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityArea
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("hectare"), CFSTR("hectares"), CFSTR("ha"),1e4);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("barn"), CFSTR("barns"), CFSTR("b"),1.e-28);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square meter"), CFSTR("square meters"), CFSTR("m^2"), 1);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square centimeter"), CFSTR("square centimeters"), CFSTR("cm^2"), 0.0001);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square millimeter"), CFSTR("square millimeters"), CFSTR("mm^2"), 1e-06);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square micrometer"), CFSTR("square micrometers"), CFSTR("µm^2"), 1e-12);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square nanometer"), CFSTR("square nanometers"), CFSTR("nm^2"), 1e-18);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square angstrom"), CFSTR("ångström ångströms"), CFSTR("Å^2"), 1e-20);
    
    
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square kilometer"), CFSTR("square kilometers"), CFSTR("km^2"), 1000000);
    
    // Area
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square inch"), CFSTR("square inches"), CFSTR("in^2"), 0.00064516);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square foot"), CFSTR("square feet"), CFSTR("ft^2"), 0.09290304);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square yard"), CFSTR("square yards"), CFSTR("yd^2"), 0.83612736);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square mile"), CFSTR("square miles"), CFSTR("mi^2"), 2589988.110336);

    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square rod"), CFSTR("square rods"), CFSTR("rod^2"), 5.029210*5.029210);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("square chain"), CFSTR("square chains"), CFSTR("ch^2"), 5.029210*5.029210*16);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("acre"), CFSTR("acres"), CFSTR("ac"), 4046.8564224);
    AddNonSIUnitToLibrary(kPSQuantityArea, CFSTR("township"), CFSTR("townships"), CFSTR("twp"), 2589988.110336*36.);
    
    
    // ***** Inverse Area ***********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityInverseArea
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse hectare"), CFSTR("inverse hectares"), CFSTR("(1/ha)"),1e-4);
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse barn"), CFSTR("inverse barns"), CFSTR("(1/b)"),1.e28);
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse square kilometer"), CFSTR("inverse square kilometer"), CFSTR("(1/km^2)"), 1./1000000);
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse square centimeter"), CFSTR("inverse square centimeters"), CFSTR("(1/cm^2)"), 1./0.0001);
    
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse square inch"), CFSTR("inverse square inches"), CFSTR("(1/in^2)"), 1./0.00064516);
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse square foot"), CFSTR("inverse square feet"), CFSTR("(1/ft^2)"), 1./0.09290304);
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse square yard"), CFSTR("inverse square yards"), CFSTR("(1/yd^2)"), 1./0.83612736);
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse acre"), CFSTR("inverse acres"), CFSTR("(1/ac)"), 1./4046.8564224);
    AddNonSIUnitToLibrary(kPSQuantityInverseArea, CFSTR("inverse square mile"), CFSTR("inverse square miles"), CFSTR("(1/mi^2)"), 1./2589988.110336);

    // ***** Area - rock permeability ***********************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityRockPermeability
    AddNonSIUnitToLibrary(kPSQuantityRockPermeability, CFSTR("darcy"), CFSTR("darcys"), CFSTR("Dc"),9.869233e-13);
    AddNonSIUnitToLibrary(kPSQuantityRockPermeability, CFSTR("millidarcy"), CFSTR("millidarcys"), CFSTR("mDc"),9.869233e-16);
    AddNonSIUnitToLibrary(kPSQuantityRockPermeability, CFSTR("microdarcy"), CFSTR("microdarcys"), CFSTR("µDc"),9.869233e-19);
    AddNonSIUnitToLibrary(kPSQuantityRockPermeability, CFSTR("nanodarcy"), CFSTR("nanodarcys"), CFSTR("nDc"),9.869233e-21);
    
    // ***** Solid Angle ************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantitySolidAngle
    AddUnitForQuantityToLibrary(kPSQuantitySolidAngle,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("steradian"),CFSTR("steradians"),CFSTR("sr"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Area Ratio ************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityAreaRatio
    AddNonSIUnitToLibrary(kPSQuantityAreaRatio, CFSTR("square meter per square meter"), CFSTR("square meters per square meter"), CFSTR("m^2/m^2"),1);
    

    // ***** Volume *****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityVolume
    AddUnitForQuantityToLibrary(kPSQuantityVolume,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("liter"),CFSTR("liters"),CFSTR("L"), kPSSIPrefixNone, false, 1e-3,true);
    
    // Volume
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("cubic inch"), CFSTR("cubic inches"), CFSTR("in^3"), (1609.344/63360)*(1609.344/63360)*(1609.344/63360));
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("cubic foot"), CFSTR("cubic feet"), CFSTR("ft^3"), (1609.344/5280)*(1609.344/5280)*(1609.344/5280));
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("cubic yard"), CFSTR("cubic yards"), CFSTR("yd^3"), (1609.344/1760)*(1609.344/1760)*(1609.344/1760));
    
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("acre foot"), CFSTR("acre feet"), CFSTR("ac•ft"), 1609.344/5280*4046.8564224);
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("oil barrel"), CFSTR("oil barrels"), CFSTR("bbl"), 0.158987295);
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("thousand oil barrels"), CFSTR("thousand oil barrels"), CFSTR("Mbbl"), 0.158987295e3);
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("million oil barrels"), CFSTR("million oil barrels"), CFSTR("MMbbl"), 0.158987295e6);
    
    AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("cubic ångström"), CFSTR("cubic ångströms"), CFSTR("Å^3"), 1e-30);


    // ***** Inverse Volume *********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityInverseVolume
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse liter"), CFSTR("inverse liters"), CFSTR("(1/L)"), 1./1e-3);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse milliliter"), CFSTR("inverse milliliters"), CFSTR("(1/mL)"), 1./1e-6);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic inch"), CFSTR("inverse cubic inches"), CFSTR("(1/in^3)"), 1./(1609.344/63360)*(1609.344/63360)*(1609.344/63360));
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic foot"), CFSTR("inverse cubic feet"), CFSTR("(1/ft^3)"), 1./(1609.344/5280)*(1609.344/5280)*(1609.344/5280));
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic yard"), CFSTR("inverse cubic yards"), CFSTR("(1/yd^3)"), 1./(1609.344/1760)*(1609.344/1760)*(1609.344/1760));
    
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic centimeter"), CFSTR("inverse cubic centimeters"), CFSTR("(1/cm^3)"), 1000000.);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic millimeter"), CFSTR("inverse cubic millimeters"), CFSTR("(1/mm^3)"), 1000000000.);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic micrometer"), CFSTR("inverse cubic micrometers"), CFSTR("(1/µm^3)"), 1e+18);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic nanometer"), CFSTR("inverse cubic nanometers"), CFSTR("(1/nm^3)"), 1e+27);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic ångström"), CFSTR("inverse cubic ångströms"), CFSTR("(1/Å^3)"), 1e+30);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic picometer"), CFSTR("inverse cubic picometers"), CFSTR("(1/pm^3)"), 1e+36);
    AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cubic femtometer"), CFSTR("inverse cubic femtometers"), CFSTR("(1/fm^3)"), 1e+45);


    
    // ***** Volume Ratio ***********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityVolumeRatio
    AddNonSIUnitToLibrary(kPSQuantityVolumeRatio, CFSTR("cubic meter per cubic meter"), CFSTR("cubic meters per cubic meter"), CFSTR("m^3/m^3"),1);
    

    // ***** Surface Area to Volume Ratio *******************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantitySurfaceAreaToVolumeRatio
    AddNonSIUnitToLibrary(kPSQuantitySurfaceAreaToVolumeRatio, CFSTR("square meter per cubic meter"), CFSTR("square meters per cubic meter"), CFSTR("m^2/m^3"),1);
    AddNonSIUnitToLibrary(kPSQuantitySurfaceAreaToVolumeRatio, CFSTR("square meter per liter"), CFSTR("square meters per liter"), CFSTR("m^2/L"),1000);
    

    // ***** Speed ******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantitySpeed
    AddUnitForQuantityToLibrary(kPSQuantitySpeed,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("meter per second"),CFSTR("meters per second"),CFSTR("m/s"), kPSSIPrefixNone, false, 1,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantitySpeed);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityVelocity, units);
    
    AddUnitForQuantityToLibrary(kPSQuantitySpeed,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("meter per minute"),CFSTR("meters per minute"),CFSTR("m/min"), kPSSIPrefixNone, false, 1./60.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantitySpeed,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("meter per hour"),CFSTR("meters per hour"),CFSTR("m/h"), kPSSIPrefixNone, false, 1./3600.,true);
    
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("knot"), CFSTR("knots"), CFSTR("kn"),0.514444444444444);
    // speed of light
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("speed of light"), CFSTR("speed of light"), CFSTR("c_0"), kPSSpeedOfLight);
    
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("inch per second"), CFSTR("inches per second"), CFSTR("in/s"), 1609.344/63360);
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("inch per minute"), CFSTR("inches per minute"), CFSTR("in/min"), 1609.344/63360/60.);
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("inch per hour"), CFSTR("inches per hour"), CFSTR("in/h"), 1609.344/63360/3600.);
    
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("foot per second"), CFSTR("feet per second"), CFSTR("ft/s"), 1609.344/5280);
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("foot per minute"), CFSTR("feet per minute"), CFSTR("ft/min"), 1609.344/5280/60.);
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("foot per hour"), CFSTR("feet per hour"), CFSTR("ft/h"), 1609.344/5280/3600.);
    
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("mile per second"), CFSTR("miles per second"), CFSTR("mi/s"), 1609.344);
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("mile per minute"), CFSTR("miles per minute"), CFSTR("mi/min"), 1609.344/60.);
    AddNonSIUnitToLibrary(kPSQuantitySpeed, CFSTR("mile per hour"), CFSTR("miles per hour"), CFSTR("mi/h"), 1609.344/3600.);
    
    // ***** Linear Momentum ********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityLinearMomentum
    AddUnitForQuantityToLibrary(kPSQuantityLinearMomentum,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram meter per second"),CFSTR("gram meters per second"),CFSTR("m•g/s"), kPSSIPrefixNone, false, 0.001,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityLinearMomentum,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("newton second"),CFSTR("newton seconds"),CFSTR("N•s"), kPSSIPrefixNone, false, 1,true);
    
    // ***** Angular Momentum, Action ***********************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityAngularMomentum
    AddUnitForQuantityToLibrary(kPSQuantityAngularMomentum,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule second"),CFSTR("joules second"),CFSTR("J•s"), kPSSIPrefixNone, false, 1,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityAngularMomentum,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram square meter per second"),CFSTR("gram square meters per second"),CFSTR("g•m^2/s"), kPSSIPrefixNone, false, 0.001,true);
    
    // Action - planck constant
    AddNonSIUnitToLibrary(kPSQuantityAction, CFSTR("planck constant"), CFSTR("planck constant"), CFSTR("h_P"),kPSPlanckConstant);
    
    // Reduced Action - planck constant/2π
    AddNonSIUnitToLibrary(kPSQuantityReducedAction, CFSTR("reduced planck constant"), CFSTR("reduced planck constant"), CFSTR("ℏ"),hbar);
    
    // quantum of circulation
    AddNonSIUnitToLibrary(kPSQuantityCirculation, CFSTR("quantum of circulation"), CFSTR("quantum of circulation"), CFSTR("h_P/(2•m_e)"),hbar);
    
    // second radiation constant
    AddNonSIUnitToLibrary(kPSQuantitySecondRadiationConstant, CFSTR("second radiation constant"), CFSTR("second radiation constant"), CFSTR("h_P•c_0/k_B"),kPSPlanckConstant*kPSSpeedOfLight/kPSBoltmannConstant);
    
    
    // von Klitzing constant
    AddNonSIUnitToLibrary(kPSQuantityElectricResistance, CFSTR("von klitzing constant"), CFSTR("von klitzing constant"), CFSTR("h_P/(q_e^2)"),kPSPlanckConstant/(kPSElementaryCharge*kPSElementaryCharge));

    
    // ***** Acceleration ***********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityAcceleration
    AddUnitForQuantityToLibrary(kPSQuantityAcceleration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("meter per square second"),CFSTR("meters per square second"),CFSTR("m/s^2"), kPSSIPrefixNone, false, 1,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityAcceleration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("meter per hour per second"),CFSTR("meters per hour per second"),CFSTR("m/(h•s)"), kPSSIPrefixNone, false, 1./3600.,true);
    
    // acceleration due to gravity at sea level
    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("gravity acceleration"), CFSTR("gravity acceleration"), CFSTR("g_0"), kPSGravityAcceleration);

    /******** American System of Units not accepted in SI System ********/
    // Acceleration
    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("mile per square second"), CFSTR("miles per square second"), CFSTR("mi/s^2"), 1609.344);
    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("foot per square second"), CFSTR("feet per square second"), CFSTR("ft/s^2"), 1609.344/5280);
    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("inch per square second"), CFSTR("inches per square second"), CFSTR("in/s^2"), 1609.344/63360);
    
    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("mile per square minute"), CFSTR("miles per square minute"), CFSTR("mi/min^2"), 1609.344/60./60.);
    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("foot per square minute"), CFSTR("feet per square minute"), CFSTR("ft/min^2"), 1609.344/5280/60./60.);
    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("inch per square minute"), CFSTR("inches per square minute"), CFSTR("in/min^2"), 1609.344/63360/60./60.);

    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("mile per hour per second"), CFSTR("miles per hour per second"), CFSTR("mi/(h•s)"), 1609.344/60./60.);

    AddNonSIUnitToLibrary(kPSQuantityAcceleration, CFSTR("knot per second"), CFSTR("knots per second"), CFSTR("kn/s"),0.514444444444444);

    // ***** Density ****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityDensity
    // Because kilogram is the base unit, this one is a little tricky to define.
    // Need to be false for is_special_si_symbol so scaling to coherent derived SI unit uses special symbol prefix and scale_to_coherent_si
    // In this case scale_to_coherent_si is 1e-3
    AddUnitForQuantityToLibrary(kPSQuantityDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per cubic meter"),CFSTR("grams per cubic meter"),CFSTR("g/m^3"), kPSSIPrefixNone, false, 1e-3,true);
    
    // ***** Mass Flow Rate ****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMassFlowRate
    AddUnitForQuantityToLibrary(kPSQuantityMassFlowRate,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per second"),CFSTR("grams per second"),CFSTR("g/s"), kPSSIPrefixNone, false, 1e-3,true);
    
    // ***** Mass Flux ****************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMassFlux
    AddUnitForQuantityToLibrary(kPSQuantityMassFlux,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per square meter per second"),CFSTR("grams per square meter per second"),CFSTR("g/(m^2•s)"), kPSSIPrefixNone, false, 1e-3,true);
    
    // ***** Surface Density ********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantitySurfaceDensity
    // Because kilogram is the base unit, this one is a little tricky to define.
    // Need to be false for is_special_si_symbol so scaling to coherent derived SI unit uses special symbol prefix and scale_to_coherent_si
    // In this case scale_to_coherent_si is 1e-3
    AddUnitForQuantityToLibrary(kPSQuantitySurfaceDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per square meter"),CFSTR("grams per square meter"),CFSTR("g/m^2"), kPSSIPrefixNone,false,1e-3,true);
    
    // ***** Current Density ********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityCurrentDensity
    AddUnitForQuantityToLibrary(kPSQuantityCurrentDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ampere per square meter"),CFSTR("amperes per square meter"),CFSTR("A/m^2"), kPSSIPrefixNone, true, 1,true);
    
    // ***** Amount Concentration ***************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityAmountConcentration
    AddUnitForQuantityToLibrary(kPSQuantityAmountConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per cubic meter"),CFSTR("moles per cubic meter"),CFSTR("mol/m^3"), kPSSIPrefixNone, true, 1,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityAmountConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per liter"),CFSTR("moles per liter"),CFSTR("mol/L"), kPSSIPrefixNone, false, 1000,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityAmountConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per milliliter"),CFSTR("moles per milliliter"),CFSTR("mol/mL"), kPSSIPrefixNone, false, 1000000.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityAmountConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per microliter"),CFSTR("moles per microliter"),CFSTR("mol/µL"), kPSSIPrefixNone, false, 1000000000.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityAmountConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per liter"),CFSTR("moles per liter"),CFSTR("M"), kPSSIPrefixNone, false, 1000,true);

    // ***** Mass Concentration *****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMassConcentration
    // Because kilogram is the base unit, this one is a really tricky to define.
    // Need to be false for is_special_si_symbol so scaling to coherent derived SI unit uses special symbol prefix and scale_to_coherent_si
    // In this case scale_to_coherent_si is 1e-3 (for grams) times 1e3 (for liters) to give scale_to_coherent_si = 1
    AddUnitForQuantityToLibrary(kPSQuantityMassConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per liter"),CFSTR("grams per liter"),CFSTR("g/L"), kPSSIPrefixNone, false, 1,true);
    
    // Because kilogram is the base unit, this one is a really tricky to define.
    // Need to be false for is_special_si_symbol so scaling to coherent derived SI unit uses special symbol prefix and scale_to_coherent_si
    // In this case scale_to_coherent_si is 1e-3 (for grams) times 1e6 (for liters) to give scale_to_coherent_si = 1e3
    AddUnitForQuantityToLibrary(kPSQuantityMassConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per milliliter"),CFSTR("grams per milliliter"),CFSTR("g/mL"), kPSSIPrefixNone, false, 1e3,true);
    
    // Because kilogram is the base unit, this one is a really tricky to define.
    // Need to be false for is_special_si_symbol so scaling to coherent derived SI unit uses special symbol prefix and scale_to_coherent_si
    // In this case scale_to_coherent_si is 1e-3 (for grams) times 1e9 (for liters) to give scale_to_coherent_si = 1e6
    AddUnitForQuantityToLibrary(kPSQuantityMassConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per microliter"),CFSTR("grams per microliter"),CFSTR("g/µL"), kPSSIPrefixNone, false, 1e6,true);
    
    // Special Names and Symbols for Coherent Derived Units - Table 3
    
    // ***** Force ******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityForce
    AddUnitForQuantityToLibrary(kPSQuantityForce,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("newton"),CFSTR("newtons"),CFSTR("N"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Torque ******************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityTorque
    AddUnitForQuantityToLibrary(kPSQuantityTorque,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("newton meter per radian"),CFSTR("newton meters per radian"),CFSTR("N•m/rad"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityTorque,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per radian"),CFSTR("joules per radian"),CFSTR("J/rad"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityTorque, CFSTR("pound force foot per radian"), CFSTR("pound force feet per radian"), CFSTR("lbf•ft/rad"),1.3558179483314);
    AddNonSIUnitToLibrary(kPSQuantityTorque, CFSTR("pound force inch per radian"), CFSTR("pound force inches per radian"), CFSTR("lbf•in/rad"),1.3558179483314/12.);
    AddNonSIUnitToLibrary(kPSQuantityTorque, CFSTR("kilogram force meter per radian"), CFSTR("kilogram force meters per radian"), CFSTR("kgf•m/rad"),9.80665);
    AddNonSIUnitToLibrary(kPSQuantityTorque, CFSTR("kilogram force centimeter per radian"), CFSTR("kilogram force centimeters per radian"), CFSTR("kgf•cm/rad"),0.0980665);

    // ***** Moment of Inertia ******************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMomentOfInertia
    AddNonSIUnitToLibrary(kPSQuantityMomentOfInertia, CFSTR("meter squared kilogram"), CFSTR("meters squared kilogram"), CFSTR("m^2•kg"),1);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfInertia, CFSTR("meter squared gram"), CFSTR("meters squared gram"), CFSTR("m^2•g"),1.e-3);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfInertia, CFSTR("centimeter squared kilogram"), CFSTR("centimeter squared kilogram"), CFSTR("cm^2•kg"),0.0001);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfInertia, CFSTR("centimeter squared gram"), CFSTR("centimeter squared gram"), CFSTR("cm^2•g"),1.e-7);
    
    // ***** Pressure, Stress *******************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityPressure, kPSQuantityStress
    // Pressure, Stress
    AddUnitForQuantityToLibrary(kPSQuantityPressure,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("pascal"),CFSTR("pascals"),CFSTR("Pa"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityPressure);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityStress, units);
    
    AddNonSIUnitToLibrary(kPSQuantityPressure, CFSTR("pound force per square inch"), CFSTR("pounds force per square inch"), CFSTR("lbf/in^2"), 6894.75729);
    AddNonSIUnitToLibrary(kPSQuantityPressure, CFSTR("pound force per square inch"), CFSTR("pounds force per square inch"), CFSTR("psi"), 6894.75729);
    AddNonSIUnitToLibrary(kPSQuantityPressure, CFSTR("pound force per square foot"), CFSTR("pounds force per square feet"), CFSTR("lbf/ft^2"), 47.880259);
    AddNonSIUnitToLibrary(kPSQuantityPressure, CFSTR("torr"), CFSTR("torrs"), CFSTR("Torr"), 1.01325e5/760);
    

    // ***** Inverse Pressure : Compressibility *******************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityCompressibility
    AddNonSIUnitToLibrary(kPSQuantityCompressibility, CFSTR("inverse pascal"), CFSTR("inverse pascals"), CFSTR("1/Pa"), 1);
    AddNonSIUnitToLibrary(kPSQuantityStressOpticCoefficient, CFSTR("brewster"), CFSTR("brewsters"), CFSTR("B"), 1.e-12);

    // ***** Pressure Gradient ******************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityPressureGradient
    // Pressure, Stress
    AddUnitForQuantityToLibrary(kPSQuantityPressureGradient,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("pascal per meter"),CFSTR("pascals per meter"),CFSTR("Pa/m"), kPSSIPrefixNone, true, 1.,true);

    AddNonSIUnitToLibrary(kPSQuantityPressureGradient, CFSTR("pound force per square inch per foot"), CFSTR("pounds force per square inch per foot"), CFSTR("psi/ft"), 6894.75729/(1609.344/5280));

    // ***** Energy, Work, Heat *****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityEnergy
    AddUnitForQuantityToLibrary(kPSQuantityEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule"),CFSTR("joules"),CFSTR("J"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt hour"),CFSTR("watt hour"),CFSTR("W•h"), kPSSIPrefixNone, false, 3.6e3,true);
    
    AddNonSIUnitToLibrary(kPSQuantityEnergy, CFSTR("rydberg"), CFSTR("rydbergs"), CFSTR("Ry"), Ry);
    
    // alpha particle mass energy
    AddNonSIUnitToLibrary(kPSQuantityMass, CFSTR("alpha particle mass energy"), CFSTR("alpha particle mass energy"), CFSTR("m_a•c_0^2"), kPSAlphaParticleMass*kPSSpeedOfLight*kPSSpeedOfLight);

    // ***** Spectral Radiant Energy ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantitySpectralRadiantEnergy
    AddUnitForQuantityToLibrary(kPSQuantitySpectralRadiantEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per nanometer"),CFSTR("joules per nanometer"),CFSTR("J/nm"), kPSSIPrefixNone, false, 1.e9,true);

    // ***** Power, Radiant Flux ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityPower, kPSQuantityRadiantFlux
    AddUnitForQuantityToLibrary(kPSQuantityPower,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt"),CFSTR("watts"),CFSTR("W"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityPower);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityRadiantFlux, units);
    
    AddUnitForQuantityToLibrary(kPSQuantityPower,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("Joule per second"),CFSTR("Joules per second"),CFSTR("J/s"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Spectral Power ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantitySpectralPower
    AddUnitForQuantityToLibrary(kPSQuantitySpectralPower,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per nanometer"),CFSTR("watts per nanometer"),CFSTR("W/nm"), kPSSIPrefixNone, false, 1.e9,true);

    // ***** Volume Power Density ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityVolumePowerDensity
    AddUnitForQuantityToLibrary(kPSQuantityVolumePowerDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per cubic meter"),CFSTR("watts per cubic meter"),CFSTR("W/m^3"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityVolumePowerDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per cubic centimeter"),CFSTR("watts per cubic centimeter"),CFSTR("W/cm^3"), kPSSIPrefixNone, false, 100000.,true);
    
    
    // ***** Specific Power ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantitySpecificPower
    AddUnitForQuantityToLibrary(kPSQuantitySpecificPower,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per kilogram"),CFSTR("watts per kilogram"),CFSTR("W/kg"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantitySpecificPower, CFSTR("horse power per pound"), CFSTR("horse power per pound"), CFSTR("hp/lb"),1643.986806920936);
    AddNonSIUnitToLibrary(kPSQuantitySpecificPower, CFSTR("horse power per ounce"), CFSTR("horse power per ounce"), CFSTR("hp/oz"),26303.78891073498);

    // ***** Electric Charge, Amount of Electricity *********************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityElectricCharge, kPSQuantityAmountOfElectricity
    AddUnitForQuantityToLibrary(kPSQuantityElectricCharge,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("coulomb"),CFSTR("coulombs"),CFSTR("C"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityElectricCharge);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityAmountOfElectricity, units);
    
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("ampere second"), CFSTR("ampere seconds"), CFSTR("A•s"), 1.0);
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("ampere minute"), CFSTR("ampere minutes"), CFSTR("A•min"), 60.);
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("ampere hour"), CFSTR("ampere hours"), CFSTR("A•h"), 3600);
    
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("milliampere second"), CFSTR("milliampere seconds"), CFSTR("mA•s"), 0.001);
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("milliampere minute"), CFSTR("milliampere minutes"), CFSTR("mA•min"), 0.06);
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("milliampere hour"), CFSTR("milliampere hours"), CFSTR("mA•h"), 3.6);

    
    AddNonSIUnitToLibrary(kPSQuantityChargeToMassRatio, CFSTR("ampere second per gram"), CFSTR("ampere seconds per gram"), CFSTR("A•s/g"),1000);
    AddNonSIUnitToLibrary(kPSQuantityChargeToMassRatio, CFSTR("ampere minute per gram"), CFSTR("ampere minutes per gram"), CFSTR("A•min/g"),60000);
    AddNonSIUnitToLibrary(kPSQuantityChargeToMassRatio, CFSTR("ampere hour per gram"), CFSTR("ampere hours per gram"), CFSTR("A•h/g"),3600000);
    
    AddNonSIUnitToLibrary(kPSQuantityChargeToMassRatio, CFSTR("milliampere second per gram"), CFSTR("milliampere seconds per gram"), CFSTR("mA•s/g"),1);
    AddNonSIUnitToLibrary(kPSQuantityChargeToMassRatio, CFSTR("milliampere minute per gram"), CFSTR("milliampere minutes per gram"), CFSTR("mA•min/g"),60);
    AddNonSIUnitToLibrary(kPSQuantityChargeToMassRatio, CFSTR("milliampere hour per gram"), CFSTR("milliampere hours per gram"), CFSTR("mA•h/g"),3600);
    


    
    // ***** Electric Potential Difference, Electromotive Force, Voltage ************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityElectricPotentialDifference, kPSQuantityElectromotiveForce, kPSQuantityVoltage
    AddUnitForQuantityToLibrary(kPSQuantityElectricPotentialDifference,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("volt"),CFSTR("volts"),CFSTR("V"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityElectricPotentialDifference);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityElectromotiveForce, units);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityVoltage, units);
  
    
#pragma mark kPSQuantityElectricFieldGradient
    AddUnitForQuantityToLibrary(kPSQuantityElectricFieldGradient,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("volt per square meter"),CFSTR("volts per square meter"),CFSTR("V/m^2"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityElectricFieldGradient, CFSTR("atomic unit of electric field gradient"), CFSTR("atomic unit of electric field gradient"), CFSTR("Λ_0"),Λ_0);
    AddNonSIUnitToLibrary(kPSQuantityElectricFieldGradient, CFSTR("atomic unit of electric field gradient"), CFSTR("atomic unit of electric field gradient"), CFSTR("E_h/(q_e•a_0^2)"),Λ_0);

    // ***** Capacitance ************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityCapacitance
    AddUnitForQuantityToLibrary(kPSQuantityCapacitance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("farad"),CFSTR("farads"),CFSTR("F"), kPSSIPrefixNone, true, 1.,true);
    
    
    // ***** Electric Resistance ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityElectricResistance
    AddUnitForQuantityToLibrary(kPSQuantityElectricResistance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ohm"),CFSTR("ohms"),CFSTR("Ω"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Electric Resistance per length ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityElectricResistancePerLength
    AddUnitForQuantityToLibrary(kPSQuantityElectricResistancePerLength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ohm per meter"),CFSTR("ohms per meter"),CFSTR("Ω/m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityElectricResistancePerLength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ohm per feet"),CFSTR("ohms per feet"),CFSTR("Ω/ft"), kPSSIPrefixNone, false, 1./(1609.344/5280),true);
    
    
    // ***** Electric Resistivity ****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityElectricResistivity
    AddUnitForQuantityToLibrary(kPSQuantityElectricResistivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ohm meter"),CFSTR("ohms meter"),CFSTR("Ω•m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityElectricResistivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ohm centimeter"),CFSTR("ohms centimeter"),CFSTR("Ω•cm"), kPSSIPrefixNone, false, 0.01,true);
    
    // ***** Electric Conductance ***************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityElectricConductance
    AddUnitForQuantityToLibrary(kPSQuantityElectricConductance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("siemen"),CFSTR("siemens"),CFSTR("S"), kPSSIPrefixNone, true, 1.,true);
    
    // Conductance Quantum
    AddNonSIUnitToLibrary(kPSQuantityElectricConductance, CFSTR("conductance quantum"), CFSTR("conductance quantum"), CFSTR("G_0"),G_0);
    
    
    // Inverse Conductance Quantum
    AddNonSIUnitToLibrary(kPSQuantityElectricResistance, CFSTR("inverse conductance quantum"), CFSTR("inverse conductance quantum"), CFSTR("(1/G_0)"),1/G_0);
    
    
    // ***** Electric Conductivity ***************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityElectricConductivity
    AddUnitForQuantityToLibrary(kPSQuantityElectricConductivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("siemen per meter"),CFSTR("siemens per meter"),CFSTR("S/m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityElectricConductivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("siemen per centimeter"),CFSTR("siemens per centimeter"),CFSTR("S/cm"), kPSSIPrefixNone, false, 100.,true);
    
    
    // ***** Molar Conductivity ***************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMolarConductivity
    AddUnitForQuantityToLibrary(kPSQuantityMolarConductivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("siemen meter squared per mole"),CFSTR("siemens meter squared per mole"),CFSTR("S•m^2/mol"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityMolarConductivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("siemen centimeter squared per mole"),CFSTR("siemens centimeter squared per mole"),CFSTR("S•cm^2/mol"), kPSSIPrefixNone, false, 0.0001,true);
    

    // ***** Gyromagnetic Ratio *****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityGyromagneticRatio
    AddUnitForQuantityToLibrary(kPSQuantityGyromagneticRatio,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("radian per second per tesla"),CFSTR("radians per second per tesla"),CFSTR("rad/(s•T)"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Magnetic Dipole Moment *************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMagneticDipoleMoment
    AddUnitForQuantityToLibrary(kPSQuantityMagneticDipoleMoment,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ampere square meter"),CFSTR("ampere square meters"),CFSTR("A•m^2"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityMagneticDipoleMoment,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per tesla"),CFSTR("joules per tesla"),CFSTR("J/T"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMoment, CFSTR("nuclear magneton"), CFSTR("nuclear magnetons"), CFSTR("µ_N"),mu_N);
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMoment, CFSTR("bohr magneton"), CFSTR("bohr magnetons"), CFSTR("µ_B"),mu_e);

    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMoment, CFSTR("proton magnetic moment"), CFSTR("proton magnetic moment"), CFSTR("µ_p"),kPSProtonMagneticMoment);
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMoment, CFSTR("neutron magnetic moment"), CFSTR("neutron magnetic moment"), CFSTR("µ_n"),kPSNeutronMagneticMoment);
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMoment, CFSTR("electron magnetic moment"), CFSTR("electron magnetic moment"), CFSTR("µ_e"),kPSElectronMagneticMoment);
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMoment, CFSTR("muon magnetic moment"), CFSTR("muon magnetic moment"), CFSTR("µ_µ"),kPSMuonMagneticMoment);
    
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMomentRatio, CFSTR("proton g factor"), CFSTR("proton g factor"), CFSTR("g_p"),kPSProtonGFactor);
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMomentRatio, CFSTR("neutron g factor"), CFSTR("neutron g factor"), CFSTR("g_n"),kPSNeutronGFactor);
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMomentRatio, CFSTR("electron g factor"), CFSTR("electron g factor"), CFSTR("g_e"),kPSElectronGFactor);
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMomentRatio, CFSTR("muon g factor"), CFSTR("muon g factor"), CFSTR("g_µ"),kPSMuonGFactor);
    
    // ***** Magnetic Flux **********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMagneticFlux
    AddUnitForQuantityToLibrary(kPSQuantityMagneticFlux,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("weber"),CFSTR("webers"),CFSTR("Wb"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityMagneticFlux, CFSTR("magnetic flux quantum"), CFSTR("magnetic flux quantum"), CFSTR("Φ_0"),kPSPlanckConstant/(2*kPSElementaryCharge));

    // ***** Magnetic Flux Density **************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMagneticFluxDensity
    AddUnitForQuantityToLibrary(kPSQuantityMagneticFluxDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("tesla"),CFSTR("tesla"),CFSTR("T"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Magnetic Field Gradient ************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityMagneticFieldGradient
    AddUnitForQuantityToLibrary(kPSQuantityMagneticFieldGradient,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("tesla per meter"),CFSTR("tesla per meter"),CFSTR("T/m"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityMagneticFieldGradient, CFSTR("tesla per centimeter"), CFSTR("tesla per centimeter"), CFSTR("T/cm"),100.);
    AddNonSIUnitToLibrary(kPSQuantityMagneticFieldGradient, CFSTR("gauss per centimeter"), CFSTR("gauss per centimeter"), CFSTR("G/cm"),0.01);
    
#pragma mark kPSQuantityMolarMagneticSusceptibility
    AddNonSIUnitToLibrary(kPSQuantityMolarMagneticSusceptibility, CFSTR("cubic meter per mole"), CFSTR("cubic meters per mole"), CFSTR("m^3/mol"),1.);
    AddNonSIUnitToLibrary(kPSQuantityMolarMagneticSusceptibility, CFSTR("cubic centimeter per mole"), CFSTR("cubic centimeters per mole"), CFSTR("cm^3/mol"),1e-06);

    
    
    // ***** Inductance *************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityInductance
    AddUnitForQuantityToLibrary(kPSQuantityInductance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("henry"),CFSTR("henries"),CFSTR("H"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Luminous Flux **********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityLuminousFlux
    AddUnitForQuantityToLibrary(kPSQuantityLuminousFlux,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("lumen"),CFSTR("lumens"),CFSTR("lm"), kPSSIPrefixNone, false, 1.,true);

#pragma mark kPSQuantityLuminousFluxDensity
    AddUnitForQuantityToLibrary(kPSQuantityLuminousFluxDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("lumen per square meter"),CFSTR("lumens per square meter"),CFSTR("lm/m^2"), kPSSIPrefixNone, false, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityLuminousFluxDensity, CFSTR("lumen per square foot"), CFSTR("lumens per square foot"), CFSTR("lm/ft^2"),10.76391041670972);

#pragma mark kPSQuantityLuminousEnergy
    AddUnitForQuantityToLibrary(kPSQuantityLuminousEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("lumen second"),CFSTR("lumen seconds"),CFSTR("lm•s"), kPSSIPrefixNone, false, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityLuminousFlux,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("candela steradian"),CFSTR("candela steradians"),CFSTR("cd•sr"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Illuminance ************************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityIlluminance
    AddUnitForQuantityToLibrary(kPSQuantityIlluminance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("lux"),CFSTR("lux"),CFSTR("lx"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Absorbed dose **********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityAbsorbedDose
    AddUnitForQuantityToLibrary(kPSQuantityAbsorbedDose,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gray"),CFSTR("grays"),CFSTR("Gy"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Dose equivalent ********************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityDoseEquivalent
    AddUnitForQuantityToLibrary(kPSQuantityDoseEquivalent,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("sievert"),CFSTR("sieverts"),CFSTR("Sv"), kPSSIPrefixNone, true, 1.,true);
    
    // ***** Catalytic Activity *****************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityCatalyticActivity
    AddUnitForQuantityToLibrary(kPSQuantityCatalyticActivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per second"),CFSTR("moles per second"),CFSTR("mol/s"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityCatalyticActivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per minute"),CFSTR("moles per minute"),CFSTR("mol/min"), kPSSIPrefixNone, false, 1./60.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityCatalyticActivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("katal"),CFSTR("katals"),CFSTR("kat"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityCatalyticActivityConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("katal per cubic meter"),CFSTR("katals per cubic meter"),CFSTR("kat/m^3"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityCatalyticActivityContent,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("katal per kilogram"),CFSTR("katals per kilogram"),CFSTR("kat/kg"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityCatalyticActivityConcentration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("katal per liter"),CFSTR("katals per liter"),CFSTR("kat/L"), kPSSIPrefixNone, false, 1000.,true);
    
    // Rate Per Amount Concentration Per Time Unit
    AddNonSIUnitToLibrary(kPSQuantityRatePerAmountConcentrationPerTime, CFSTR("liter per mole per second"), CFSTR("liter per mole per second"), CFSTR("L/(mol•s)"), 0.001);
    

    
    // ***** Refractive Index *******************************************************************************************************************************
    // ******************************************************************************************************************************************************
#pragma mark kPSQuantityRefractiveIndex
    AddNonSIUnitToLibrary(kPSQuantityRefractiveIndex, CFSTR("meter second per meter second"), CFSTR("meter seconds per meter second"), CFSTR("m•s/(m•s)"),1.);
    
#pragma mark kPSQuantityVoltage
    // Atomic Unit of Electric Potential
    AddNonSIUnitToLibrary(kPSQuantityVoltage, CFSTR("atomic unit of electric potential"), CFSTR("atomic units of electric potential"), CFSTR("E_h/q_e"),E_h/kPSElementaryCharge);

#pragma mark kPSQuantityElectricQuadrupoleMoment
    // Atomic Unit of Electric Quadrupole Moment
    AddNonSIUnitToLibrary(kPSQuantityElectricQuadrupoleMoment, CFSTR("atomic unit of electric quadrupole moment"), CFSTR("atomic units of electric quadrupole moment"), CFSTR("q_e•a_0^2"),kPSElementaryCharge*a_0*a_0);
    
#pragma mark kPSQuantityForce
    // Atomic Unit of Force
    AddNonSIUnitToLibrary(kPSQuantityForce, CFSTR("atomic unit of force"), CFSTR("atomic units of force"), CFSTR("E_h/a_0"),E_h/a_0);
    
#pragma mark kPSQuantityMagneticDipoleMoment
    // Atomic Unit of Magnetic Dipole Moment
    AddNonSIUnitToLibrary(kPSQuantityMagneticDipoleMoment, CFSTR("atomic unit of magnetic dipole moment"), CFSTR("atomic units of magnetic dipole moment"), CFSTR("ℏ•q_e/m_e"),hbar*kPSElementaryCharge/kPSElectronMass);
    
#pragma mark kPSQuantityMagneticFluxDensity
   // Atomic Unit of Magnetic Flux Density
    AddNonSIUnitToLibrary(kPSQuantityMagneticFluxDensity, CFSTR("atomic unit of magnetic flux density"), CFSTR("atomic units of magnetic flux density"), CFSTR("ℏ/(q_e•a_0^2)"),hbar/(kPSElementaryCharge*a_0*a_0));
    
#pragma mark kPSQuantityMagnetizability
    // Atomic Unit of Magnetizability
    AddNonSIUnitToLibrary(kPSQuantityMagnetizability, CFSTR("atomic unit of magnetizability"), CFSTR("atomic units of magnetizability"), CFSTR("q_e•a_0^2/m_e"),kPSElementaryCharge*a_0*a_0/kPSElectronMass);
    
#pragma mark kPSQuantityLinearMomentum
    // Atomic Unit of Momentum
    AddNonSIUnitToLibrary(kPSQuantityLinearMomentum, CFSTR("atomic unit of momentum"), CFSTR("atomic units of momentum"), CFSTR("ℏ/a_0"),hbar/a_0);

#pragma mark kPSQuantityPermittivity
    // Atomic Unit of Permittivity
    AddNonSIUnitToLibrary(kPSQuantityPermittivity, CFSTR("atomic unit of permittivity"), CFSTR("atomic units of permittivity"), CFSTR("q_e^2/(a_0•E_h)"),kPSElementaryCharge*kPSElementaryCharge/(a_0*E_h));
    
#pragma mark kPSQuantityVelocity
   // Atomic Unit of Velocity
    AddNonSIUnitToLibrary(kPSQuantityVelocity, CFSTR("atomic unit of velocity"), CFSTR("atomic units of velocity"), CFSTR("a_0•E_h/ℏ"),a_0*E_h/hbar);
    
    // Characteristic Impedance of Vacuum
    AddNonSIUnitToLibrary(kPSQuantityElectricResistance, CFSTR("characteristic impedance of vacuum"), CFSTR("characteristic impedance of vacuum"), CFSTR("Z_0"),4*kPSPi*1.e-7*kPSSpeedOfLight);

    // Compton Wavelength
    AddNonSIUnitToLibrary(kPSQuantityLength, CFSTR("compton wavelength"), CFSTR("compton wavelengths"), CFSTR("λ_C"),kPSPlanckConstant/(kPSElectronMass*kPSSpeedOfLight));

    // Atomic Unit of Electric Polarizability
    AddNonSIUnitToLibrary(kPSQuantityElectricPolarizability, CFSTR("atomic unit of electric polarizability"), CFSTR("atomic units of electric polarizability"), CFSTR("q_e^2•a_0^2/E_h"),kPSElementaryCharge*kPSElementaryCharge*a_0*a_0/(E_h));

    // First Hyperpolarizability
    AddNonSIUnitToLibrary(kPSQuantityFirstHyperPolarizability, CFSTR("atomic unit of 1st polarizability"), CFSTR("atomic units of 1st polarizability"), CFSTR("q_e^3•a_0^3/E_h^2"),kPSElementaryCharge*kPSElementaryCharge*kPSElementaryCharge*a_0*a_0*a_0/(E_h*E_h));
    
    // Second Hyperpolarizability
    AddNonSIUnitToLibrary(kPSQuantitySecondHyperPolarizability, CFSTR("atomic unit of 2nd polarizability"), CFSTR("atomic units of 2nd polarizability"), CFSTR("q_e^4•a_0^4/E_h^3"),kPSElementaryCharge*kPSElementaryCharge*kPSElementaryCharge*kPSElementaryCharge*a_0*a_0*a_0*a_0/(E_h*E_h*E_h));
    
    
    // Specific Volume
    AddNonSIUnitToLibrary(kPSQuantitySpecificVolume, CFSTR("cubic meter per kilogram"), CFSTR("cubic meters per kilogram"), CFSTR("m^3/kg"),1.);
    
    // Table 6 - Non-SI units but SI accepted
    
    
    // Plane Angle
    AddNonSIUnitToLibrary(kPSQuantityPlaneAngle, CFSTR("degree"), CFSTR("degrees"), CFSTR("°"),kPSPi/180.);
    
    // Turn
    AddUnitForQuantityToLibrary(kPSQuantityPlaneAngle,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("turn"),CFSTR("turns"),CFSTR("tr"), kPSSIPrefixNone, false, kPSPi*2,true);

    // Non-SI units whose values in SI Units must be obtained experimentally - Table 7
    
    // Units accepted for use with the SI
    // Energy
    AddUnitForQuantityToLibrary(kPSQuantityEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("electronvolt"),CFSTR("electronvolts"),CFSTR("eV"), kPSSIPrefixNone, false, kPSElementaryCharge,true);
    
    // Mass to Charge Ratio = Thompson
    AddNonSIUnitToLibrary(kPSQuantityMassToChargeRatio, CFSTR("thomson"), CFSTR("thomson"), CFSTR("Th"),kPSAtomicMassConstant/kPSElementaryCharge);
    
    // Charge to Mass Ratio = Inverse Thompson
    AddNonSIUnitToLibrary(kPSQuantityChargeToMassRatio, CFSTR("inverse thomson"), CFSTR("inverse thomson"), CFSTR("(1/Th)"),kPSElementaryCharge/kPSAtomicMassConstant);


    // Table 8 - Other Non-SI units
    
    // Pressure, Stress - bar
    AddUnitForQuantityToLibrary(kPSQuantityPressure,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("bar"),CFSTR("bars"),CFSTR("bar"), kPSSIPrefixNone, false, 1e5,true);
    
    // Pressure - millimeters of mercury
    AddNonSIUnitToLibrary(kPSQuantityPressure, CFSTR("millimeter of Hg"), CFSTR("millimeters of Hg"), CFSTR("mmHg"),133.322);
    
    // Pressure - atmospheres
    AddNonSIUnitToLibrary(kPSQuantityPressure, CFSTR("atmosphere"), CFSTR("atmospheres"), CFSTR("atm"),1.01325e5);
    
    
    // Table 9 - Non-SI units associated with the CGS and the CGS-Gaussian system
    // Energy - Erg
    AddUnitForQuantityToLibrary(kPSQuantityEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("erg"),CFSTR("ergs"),CFSTR("erg"), kPSSIPrefixNone, false, 1e-7,true);
    
#pragma mark kPSQuantityForce
    // Force - Dyne
    AddUnitForQuantityToLibrary(kPSQuantityForce,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("dyne"),CFSTR("dynes"),CFSTR("dyn"), kPSSIPrefixNone, false, 1e-5,true);
    
#pragma mark kPSQuantityDynamicViscosity
    // Dynamic Viscosity
    AddUnitForQuantityToLibrary(kPSQuantityDynamicViscosity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("poise"),CFSTR("poises"),CFSTR("P"), kPSSIPrefixNone, false, 0.1,true);
    
#pragma mark kPSQuantityKinematicViscosity
    // Kinematic Viscosity
    AddUnitForQuantityToLibrary(kPSQuantityKinematicViscosity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("stokes"),CFSTR("stokes"),CFSTR("St"), kPSSIPrefixNone, false, 1e-4,true);
    
    
#pragma mark kPSQuantityDiffusionCoefficient
    AddNonSIUnitToLibrary(kPSQuantityDiffusionCoefficient, CFSTR("square meter per second"), CFSTR("square meters per second"), CFSTR("m^2/s"),1);
    AddNonSIUnitToLibrary(kPSQuantityDiffusionCoefficient, CFSTR("square centimeter per second"), CFSTR("square centimeters per second"), CFSTR("cm^2/s"),0.0001);
    AddNonSIUnitToLibrary(kPSQuantityDiffusionCoefficient, CFSTR("square millimeter per second"), CFSTR("square millimeters per second"), CFSTR("mm^2/s"),1e-6);
    AddNonSIUnitToLibrary(kPSQuantityDiffusionCoefficient, CFSTR("square micrometer per second"), CFSTR("square micrometers per second"), CFSTR("µm^2/s"),1e-12);

    
    // Luminance
#pragma mark kPSQuantityLuminance
    AddUnitForQuantityToLibrary(kPSQuantityLuminance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("stilb"),CFSTR("stilbs"),CFSTR("sb"), kPSSIPrefixNone, false, 1e4,true);
    AddNonSIUnitToLibrary(kPSQuantityLuminance, CFSTR("nit"), CFSTR("nits"), CFSTR("nt"),1);
    AddNonSIUnitToLibrary(kPSQuantityLuminance, CFSTR("candela per square meter"), CFSTR("candelas per square meter"), CFSTR("cd/m^2"),1);

    AddUnitForQuantityToLibrary(kPSQuantityLuminance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("lumen per square meter per steradian"),CFSTR("lumens per square meter per steradian"),CFSTR("lm/(m^2•sr)"), kPSSIPrefixNone, false, 1,true);
    
    // Illuminance
    AddUnitForQuantityToLibrary(kPSQuantityIlluminance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("phot"),CFSTR("phots"),CFSTR("ph"), kPSSIPrefixNone, false, 1e4,true);
    

    /*  Sorry Galileo - too close to Gallons
     // Acceleration - gal
     AddUnitForQuantityToLibrary(kPSQuantityAcceleration,
     kPSSIPrefixNone,kPSSIPrefixNone,
     kPSSIPrefixKilo,kPSSIPrefixNone,
     kPSSIPrefixNone,kPSSIPrefixNone,
     kPSSIPrefixNone,kPSSIPrefixNone,
     kPSSIPrefixNone,kPSSIPrefixNone,
     kPSSIPrefixNone,kPSSIPrefixNone,
     kPSSIPrefixNone,kPSSIPrefixNone,
     CFSTR("galileo"),CFSTR("galileo"),CFSTR("Gal"), kPSSIPrefixNone, false, 1e-2,true);
     */
    
    // Magnetic Flux - maxwell
    AddUnitForQuantityToLibrary(kPSQuantityMagneticFlux,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("maxwell"),CFSTR("maxwells"),CFSTR("Mx"), kPSSIPrefixNone, false, 1e-8,true);
    
    // Magnetic Flux Density - gauss
    AddUnitForQuantityToLibrary(kPSQuantityMagneticFluxDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gauss"),CFSTR("gauss"),CFSTR("G"), kPSSIPrefixNone, false, 1e-4,true);
    
    AddNonSIUnitToLibrary(kPSQuantityInverseMagneticFluxDensity, CFSTR("inverse gauss"), CFSTR("inverse gauss"), CFSTR("(1/G)"),1.);
    
    // Magnetic Field Strength - ørsted
    AddUnitForQuantityToLibrary(kPSQuantityMagneticFieldStrength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ørsted"),CFSTR("ørsteds"),CFSTR("Oe"), kPSSIPrefixNone, false, 79.577471545947674,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityMagneticFieldStrength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("ampere per meter"),CFSTR("ampere per meter"),CFSTR("A/m"), kPSSIPrefixNone, true, 1.,true);
    
    
    // Table 4
    
    AddUnitForQuantityToLibrary(kPSQuantityDynamicViscosity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("pascal second"),CFSTR("pascal seconds"),CFSTR("Pa•s"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityDynamicViscosity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("newton second per square meter"),CFSTR("newton seconds per square meter"),CFSTR("N•s/m^2"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityMomentOfForce,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("newton meter"),CFSTR("newton meters"),CFSTR("N•m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantitySurfaceTension,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("netwon per meter"),CFSTR("newtons per meter"),CFSTR("N/m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityElasticModulus,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("netwon per square meter"),CFSTR("newtons per square meter"),CFSTR("N/m^2"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantitySurfaceTension, CFSTR("dyne per centimeter"), CFSTR("dynes per centimeter"), CFSTR("dyn/cm"),0.001);
    
    AddUnitForQuantityToLibrary(kPSQuantitySurfaceEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per square meter"),CFSTR("joules per square meter"),CFSTR("J/m^2"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantitySurfaceEnergy, CFSTR("dyne per square centimeter"), CFSTR("dynes per square centimeter"), CFSTR("dyn/cm^2"),0.1);
    
    AddUnitForQuantityToLibrary(kPSQuantityAngularFrequency,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("radian per second"),CFSTR("radians per second"),CFSTR("rad/s"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityAngularFrequency);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityAngularSpeed, units);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityAngularVelocity, units);
    
    AddUnitForQuantityToLibrary(kPSQuantityAngularAcceleration,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("radian per square second"),CFSTR("radians per square second"),CFSTR("rad/s^2"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityHeatFluxDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per square meter"),CFSTR("watts per square meter"),CFSTR("W/m^2"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityHeatFluxDensity);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityIrradiance, units);
    
    AddUnitForQuantityToLibrary(kPSQuantityHeatFluxDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per square centimeter"),CFSTR("watts per square centimeter"),CFSTR("W/cm^2"), kPSSIPrefixNone, false, 10000.,true);

    AddNonSIUnitToLibrary(kPSQuantityHeatFluxDensity, CFSTR("watt per square foot"), CFSTR("watts per square foot"), CFSTR("W/ft^2"),10.76391041670972);

    AddNonSIUnitToLibrary(kPSQuantityHeatFluxDensity, CFSTR("watt per square inch"), CFSTR("watts per square inch"), CFSTR("W/in^2"),10.76391041670972/12.);

    
    AddUnitForQuantityToLibrary(kPSQuantitySpectralRadiantFluxDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per square meter per nanometer"),CFSTR("watts per square meter per nanometer"),CFSTR("W/(m^2•nm)"), kPSSIPrefixNone, false, 1.e9,true);
    
    
    
    AddUnitForQuantityToLibrary(kPSQuantityEntropy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per kelvin"),CFSTR("joules per kelvin"),CFSTR("J/K"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityEntropy);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityHeatCapacity, units);
    
    AddUnitForQuantityToLibrary(kPSQuantitySpecificHeatCapacity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per kilogram kelvin"),CFSTR("joules per kilogram kelvin"),CFSTR("J/(kg•K)"), kPSSIPrefixNone, true, 1.,true);

    AddUnitForQuantityToLibrary(kPSQuantitySpecificHeatCapacity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per gram kelvin"),CFSTR("joules per gram kelvin"),CFSTR("J/(g•K)"), kPSSIPrefixNone, false, 1000.,true);

    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantitySpecificHeatCapacity);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantitySpecificEntropy, units);
    
    AddNonSIUnitToLibrary(kPSQuantitySpecificHeatCapacity, CFSTR("calorie per gram per kelvin"), CFSTR("calories per gram per kelvin"), CFSTR("cal/(g•K)"),4186.8);

    AddUnitForQuantityToLibrary(kPSQuantityMolarMass,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gram per mole"),CFSTR("grams per mole"),CFSTR("g/mol"), kPSSIPrefixNone, false, 1e-3,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityMolality,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("mole per kilogram"),CFSTR("moles per kilogram"),CFSTR("mol/kg"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantitySpecificEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per kilogram"),CFSTR("joules per kilogram"),CFSTR("J/kg"), kPSSIPrefixNone, true, 1,true);
    AddUnitForQuantityToLibrary(kPSQuantitySpecificEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixKilo,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per gram"),CFSTR("joules per gram"),CFSTR("J/g"), kPSSIPrefixNone, false, 1e3,true);

    AddUnitForQuantityToLibrary(kPSQuantityThermalConductance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per kelvin"),CFSTR("watts per kelvin"),CFSTR("W/K"), kPSSIPrefixNone, true, 1.,true);
    AddNonSIUnitToLibrary(kPSQuantityThermalConductance, CFSTR("Btu per hour per rankine"),
                          CFSTR("Btus per hour per rankine"),
                          CFSTR("Btu/(h•°R)"), 0.5275279262867396);
    AddNonSIUnitToLibrary(kPSQuantityThermalConductance, CFSTR("calorie per hour per kelvin"),
                          CFSTR("calories per hour per kelvin"),
                          CFSTR("cal/(h•K)"), 1.163e-3);
    AddNonSIUnitToLibrary(kPSQuantityThermalConductance, CFSTR("kilocalorie per hour per kelvin"),
                          CFSTR("kilocalories per hour per kelvin"),
                          CFSTR("kcal/(h•K)"), 1.163);

    AddUnitForQuantityToLibrary(kPSQuantityThermalConductivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per meter kelvin"),CFSTR("watts per meter kelvin"),CFSTR("W/(m•K)"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityThermalConductivity, CFSTR("Btu per hour per foot per rankine"),
                          CFSTR("Btus per hour per foot per rankine"),
                          CFSTR("Btu/(h•ft•°R)"), 1.730734666295077);
    AddNonSIUnitToLibrary(kPSQuantityThermalConductivity, CFSTR("calorie per hour per meter per kelvin"),
                          CFSTR("calories per hour per meter per kelvin"),
                          CFSTR("cal/(h•m•K)"), 1.163e-3);
    AddNonSIUnitToLibrary(kPSQuantityThermalConductivity, CFSTR("kilocalorie per hour per meter per kelvin"),
                          CFSTR("kilocalories per hour per meter per kelvin"),
                          CFSTR("kcal/(h•m•K)"), 1.163);

    
    AddUnitForQuantityToLibrary(kPSQuantityEnergyDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per cubic meter"),CFSTR("joules per cubic meter"),CFSTR("J/m^3"), kPSSIPrefixNone, true, 1.,true);
    AddNonSIUnitToLibrary(kPSQuantityEnergyDensity, CFSTR("joule per cubic centimeter"), CFSTR("joules per cubic centimeter"), CFSTR("J/cm^3"), 1000000);

    AddUnitForQuantityToLibrary(kPSQuantityEnergyDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per liter"),CFSTR("joules per liter"),CFSTR("J/L"), kPSSIPrefixNone, false, 1000.,true);
    AddNonSIUnitToLibrary(kPSQuantityEnergyDensity, CFSTR("joule per milliter"), CFSTR("joules per milliter"), CFSTR("J/mL"), 1000000);

    AddUnitForQuantityToLibrary(kPSQuantityElectricDipoleMoment,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("coulomb meter"),CFSTR("coulomb meters"),CFSTR("C•m"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityElectricDipoleMoment, CFSTR("debye"), CFSTR("debyes"), CFSTR("D"),3.335640951816991e-30);
    AddNonSIUnitToLibrary(kPSQuantityElectricDipoleMoment, CFSTR("atomic unit of electric dipole moment"), CFSTR("atomic unit of electric dipole moment"), CFSTR("q_e•a_0"),kPSElementaryCharge*a_0);
    
    AddUnitForQuantityToLibrary(kPSQuantityElectricFieldStrength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("volt per meter"),CFSTR("volts per meter"),CFSTR("V/m"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityElectricFieldStrength, CFSTR("atomic unit of electric field"), CFSTR("atomic unit of electric field"), CFSTR("E_h/(q_e•a_0)"),E_h/(kPSElementaryCharge*a_0));

    AddUnitForQuantityToLibrary(kPSQuantityElectricFieldStrength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("volt per centimeter"),CFSTR("volts per centimeter"),CFSTR("V/cm"), kPSSIPrefixNone, false, 100.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityElectricFieldStrength,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("newton per coulomb"),CFSTR("newtons per coulomb"),CFSTR("N/C"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityElectricFlux,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("volt meter"),CFSTR("volts meter"),CFSTR("V•m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityElectricChargeDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("coulomb per cubic meter"),CFSTR("coulombs per cubic meter"),CFSTR("C/m^3"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityElectricChargeDensity, CFSTR("charge density"),
                          CFSTR("charge density"), CFSTR("A•h/L"),3600000);

    AddNonSIUnitToLibrary(kPSQuantityElectricChargeDensity, CFSTR("atomic unit of charge density"),
                          CFSTR("atomic unit of charge density"), CFSTR("q_e/a_0^3"),kPSElementaryCharge/(a_0*a_0*a_0));

    
    
    
    AddUnitForQuantityToLibrary(kPSQuantitySurfaceChargeDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("coulomb per square meter"),CFSTR("coulombs per square meter"),CFSTR("C/m^2"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantitySurfaceChargeDensity);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityElectricFluxDensity, units);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityElectricDisplacement, units);
    
    AddUnitForQuantityToLibrary(kPSQuantityPermittivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("farad per meter"),CFSTR("farads per meter"),CFSTR("F/m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityPermittivity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("coulomb per volt meter"),CFSTR("coulombs per volt meter"),CFSTR("C/(V•m)"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityPermeability,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("henry per meter"),CFSTR("henries per meter"),CFSTR("H/m"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityPermeability,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("newton per square ampere"),CFSTR("newtons per square ampere"),CFSTR("N/A^2"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityPermeability,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("tesla meter per ampere"),CFSTR("tesla meter per ampere"),CFSTR("T•m/A"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityPermeability,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("weber per ampere meter"),CFSTR("webers per ampere meter"),CFSTR("Wb/(A•m)"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityMolarEntropy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per mole kelvin)"),CFSTR("joules per mole kelvin"),CFSTR("J/(mol•K)"), kPSSIPrefixNone, true, 1.,true);
    // UnitsQuantitiesLibrary contains an array of valid units for each quantity.
    units = (CFMutableArrayRef) CFDictionaryGetValue(unitsQuantitiesLibrary, kPSQuantityMolarEntropy);
    CFDictionaryAddValue(unitsQuantitiesLibrary, kPSQuantityMolarHeatCapacity, units);
    
    AddUnitForQuantityToLibrary(kPSQuantityMolarEnergy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("joule per mole"),CFSTR("joules per mole"),CFSTR("J/mol"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityRadiationExposure,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("coulomb per kilogram"),CFSTR("coulombs per kilogram"),CFSTR("C/kg"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityAbsorbedDoseRate,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("gray per second"),CFSTR("grays per second"),CFSTR("Gy/s"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityRadiantIntensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per steradian"),CFSTR("watts per steradian"),CFSTR("W/sr"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantitySpectralRadiantIntensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per steradian per nanometer"),CFSTR("watts per steradian per nanometer"),CFSTR("W/(sr•nm)"), kPSSIPrefixNone, false, 1.e9,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityRadiance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per square meter per steradian"),CFSTR("watts per square meter per steradian"),CFSTR("W/(m^2•sr)"), kPSSIPrefixNone, true, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantitySpectralRadiance,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per square meter per steradian per nanometer"),CFSTR("watts per square meter steradian per nanometer"),CFSTR("W/(m^2•sr•nm)"), kPSSIPrefixNone, false, 1.e9,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityFrequencyPerMagneticFluxDensity,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("hertz per tesla"),CFSTR("hertz per tesla"),CFSTR("Hz/T"), kPSSIPrefixNone, true, 1.,true);
    
    
    // Frequency Per Electric Field Gradient
    AddNonSIUnitToLibrary(kPSQuantityFrequencyPerElectricFieldGradient, CFSTR("hertz per atomic unit of electric field gradient"), CFSTR("hertz per atomic unit of electric field gradient"), CFSTR("Hz/Λ_0"), 1.029085839028452e-22);
    AddNonSIUnitToLibrary(kPSQuantityFrequencyPerElectricFieldGradient, CFSTR("kilohertz per atomic unit of electric field gradient"), CFSTR("kilohertz per atomic unit of electric field gradient"), CFSTR("kHz/Λ_0"), 1.029085839028452e-19);
    AddNonSIUnitToLibrary(kPSQuantityFrequencyPerElectricFieldGradient, CFSTR("megahertz per atomic unit of electric field gradient"), CFSTR("megahertz per atomic unit of electric field gradient"), CFSTR("MHz/Λ_0"), 1.029085839028452e-16);

    
    // Frequency Per Electric Field Gradient Squared
    AddNonSIUnitToLibrary(kPSQuantityFrequencyPerElectricFieldGradientSquared, CFSTR("hertz per atomic unit of electric field gradient squared"), CFSTR("hertz per atomic unit of electric field gradient squared"), CFSTR("Hz/Λ_0^2"), 1.059017664088893e-44);
    AddNonSIUnitToLibrary(kPSQuantityFrequencyPerElectricFieldGradientSquared, CFSTR("kilohertz per atomic unit of electric field gradient squared"), CFSTR("kilohertz per atomic unit of electric field gradient squared"), CFSTR("kHz/Λ_0^2"), 1.059017664088893e-41);
    AddNonSIUnitToLibrary(kPSQuantityFrequencyPerElectricFieldGradientSquared, CFSTR("megahertz per atomic unit of electric field gradient squared"), CFSTR("megahertz per atomic unit of electric field gradient squared"), CFSTR("MHz/Λ_0^2"), 1.059017664088893e-38);

    AddUnitForQuantityToLibrary(kPSQuantityLengthPerVolume,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("meter per liter"),CFSTR("meters per liter"),CFSTR("m/L"), kPSSIPrefixNone, false, 1./1.e-3,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityPowerPerLuminousFlux,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per lumens"),CFSTR("watts per lumen"),CFSTR("W/lm"), kPSSIPrefixNone, true, 1.,true);
    
    
    AddUnitForQuantityToLibrary(kPSQuantityLuminousEfficacy,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("lumen per watt"),CFSTR("lumens per watt"),CFSTR("lm/W"), kPSSIPrefixNone, false, 1.,true);
    
    AddUnitForQuantityToLibrary(kPSQuantityHeatTransferCoefficient,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixKilo,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                kPSSIPrefixNone,kPSSIPrefixNone,
                                CFSTR("watt per square meter per kelvin"),CFSTR("watts per square meter per kelvin"),CFSTR("W/(m^2•K)"), kPSSIPrefixNone, true, 1.,true);
    
    AddNonSIUnitToLibrary(kPSQuantityHeatTransferCoefficient, CFSTR("Btu per hour per square foot per rankine"), CFSTR("Btus per hour per square foot per rankine"), CFSTR("Btu/(h•ft^2•°R)"), 5.678263340863113);
    AddNonSIUnitToLibrary(kPSQuantityHeatTransferCoefficient, CFSTR("calorie per hour per square meter per kelvin"), CFSTR("calories per hour per square meter per kelvin"), CFSTR("cal/(h•m^2•K)"), 1.163e-3);
    AddNonSIUnitToLibrary(kPSQuantityHeatTransferCoefficient, CFSTR("kilocalorie per hour per square meter per kelvin"), CFSTR("kilocalories per hour per square meter per kelvin"), CFSTR("kcal/(h•m^2•K)"), 1.163);
    
    
    // Energy, Work, Heat
    AddNonSIUnitToLibrary(kPSQuantityEnergy, CFSTR("calorie"), CFSTR("calories"), CFSTR("cal"), 4.1868);
    AddNonSIUnitToLibrary(kPSQuantityEnergy, CFSTR("kilocalorie"), CFSTR("kilocalories"), CFSTR("kcal"), 4.1868*1000.);
    
    AddNonSIUnitToLibrary(kPSQuantityMolarEnergy, CFSTR("calorie per mole"), CFSTR("calories per mole"), CFSTR("cal/mol"), 4.1868);
    AddNonSIUnitToLibrary(kPSQuantityMolarEnergy, CFSTR("kilocalorie per mole"), CFSTR("kilocalories per mole"), CFSTR("kcal/mol"), 4.1868*1000.);
    
    /******** Math and Scientific Constants ********/
    // pi
    AddNonSIUnitToLibrary(kPSQuantityPlaneAngle, CFSTR("pi"), CFSTR("pi"), CFSTR("π"), kPSPi);
    // Euler's number
    AddNonSIUnitToLibrary(kPSQuantityDimensionless, CFSTR("euler constant"), CFSTR("euler constant"), CFSTR("e"), kPSEulersNumber);
    
    // boltzmann constant
    AddNonSIUnitToLibrary(kPSQuantityHeatCapacity, CFSTR("boltzmann constant"), CFSTR("boltzmann constant"), CFSTR("k_B"), kPSBoltmannConstant);
    
    // Gas constant
    AddNonSIUnitToLibrary(kPSQuantityMolarHeatCapacity, CFSTR("gas constant"), CFSTR("gas constant"), CFSTR("R"), kPSBoltmannConstant*kPSAvogadroConstant);
    
    // elementary charge
    AddNonSIUnitToLibrary(kPSQuantityElectricCharge, CFSTR("elementary charge"), CFSTR("elementary charge"), CFSTR("q_e"), kPSElementaryCharge);
    
    AddNonSIUnitToLibrary(kPSQuantityWavenumber, CFSTR("inverse atomic unit of length"), CFSTR("inverse atomic unit of length"), CFSTR("(1/a_0)"),1/a_0);
    
    // atomic unit of energy
    // E_h = m_e • (q_e^2/(2•ε_0•h_P))^2
    AddNonSIUnitToLibrary(kPSQuantityEnergy, CFSTR("atomic unit of energy"), CFSTR("atomic unit of energy"), CFSTR("E_h"), E_h);
    
    // Permittivity
    AddNonSIUnitToLibrary(kPSQuantityPermittivity, CFSTR("electric constant"), CFSTR("electric constant"), CFSTR("ε_0"), kPSElectricConstant);
    
    // Permeability
    AddNonSIUnitToLibrary(kPSQuantityPermeability, CFSTR("magnetic constant"), CFSTR("magnetic constant"), CFSTR("µ_0"),4*kPSPi*1.e-7);
    
    // avogadro constant
    AddNonSIUnitToLibrary(kPSQuantityInverseAmount, CFSTR("avogadro constant"), CFSTR("avogadro constant"), CFSTR("N_A"), kPSAvogadroConstant);
    
    // faraday constant
    AddNonSIUnitToLibrary(kPSQuantityChargeToAmountRatio, CFSTR("faraday constant"), CFSTR("faraday constant"), CFSTR("&F"), kPSElementaryCharge*kPSAvogadroConstant);
    AddNonSIUnitToLibrary(kPSQuantityChargeToAmountRatio, CFSTR("coulomb per mole"), CFSTR("coulombs per mole"), CFSTR("C/mol"), 1.0);
    
    // gravitational constant
    AddNonSIUnitToLibrary(kPSQuantityGravitationalConstant, CFSTR("gravitational constant"), CFSTR("gravitational constant"), CFSTR("G_N"), kPSGravitaionalConstant);
    
    // Heat, Energy
    AddNonSIUnitToLibrary(kPSQuantityEnergy, CFSTR("british thermal unit"), CFSTR("british thermal units"), CFSTR("Btu"), 1055.05585257348);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfForce, CFSTR("foot pound force"), CFSTR("feet pound force"), CFSTR("ft•lbf"), 1.3558179483314);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfForce, CFSTR("inch pound force"), CFSTR("inch pound force"), CFSTR("in•lbf"), 1.3558179483314/12.);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfForce, CFSTR("inch ounce force"), CFSTR("inch ounce force"), CFSTR("in•ozf"), 1.3558179483314/12./16.);
    
    AddNonSIUnitToLibrary(kPSQuantityMomentOfForce, CFSTR("pound force foot"), CFSTR("pound force feet"), CFSTR("lbf•ft"), 1.3558179483314);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfForce, CFSTR("pound force inch"), CFSTR("pound force inches"), CFSTR("lbf•in"), 1.3558179483314/12.);
    AddNonSIUnitToLibrary(kPSQuantityMomentOfForce, CFSTR("ounce force inch"), CFSTR("ounce force inches"), CFSTR("ozf•in"), 1.3558179483314/12./16.);
    
    
    // Power
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("calorie per second"), CFSTR("calories per second"), CFSTR("cal/s"), 4.1868);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("calorie per minute"), CFSTR("calories per minute"), CFSTR("cal/min"), 4.1868/60.);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("calorie per hour"), CFSTR("calories per hour"), CFSTR("cal/h"), 4.1868/3600.);

    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("horsepower"), CFSTR("horsepower"), CFSTR("hp"), 745.699872);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("british thermal unit per hour"), CFSTR("british thermal unit per hour"), CFSTR("Btu/h"), 1055.05585257348/3600.);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("british thermal unit per minute"), CFSTR("british thermal unit per minute"), CFSTR("Btu/min"), 1055.05585257348/60);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("british thermal unit per second"), CFSTR("british thermal unit per second"), CFSTR("Btu/s"), 1055.05585257348);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("erg per second"), CFSTR("ergs per second"), CFSTR("erg/s"), 1e-7);

    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("foot pound force per hour"), CFSTR("feet pound force per hour"), CFSTR("ft•lbf/h"), (1609.344/5280)*4.4482216152605/3600.);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("foot pound force per minute"), CFSTR("feet pound force per minute"), CFSTR("ft•lbf/min"), (1609.344/5280)*4.4482216152605/60.);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("foot pound force per second"), CFSTR("feet pound force per second"), CFSTR("ft•lbf/s"), (1609.344/5280)*4.4482216152605);
    
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("inch pound force per hour"), CFSTR("inches pound force per hour"), CFSTR("in•lbf/h"), 1.3558179483314/12./3600.);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("inch pound force per minute"), CFSTR("inches pound force per minute"), CFSTR("in•lbf/min"), 1.3558179483314/12./60.);
    AddNonSIUnitToLibrary(kPSQuantityPower, CFSTR("inch pound force per second"), CFSTR("inches pound force per second"), CFSTR("in•lbf/s"), 1.3558179483314/12.);
    
    // Force
    AddNonSIUnitToLibrary(kPSQuantityForce, CFSTR("pound force"), CFSTR("pounds force"), CFSTR("lbf"), 4.4482216152605);
    AddNonSIUnitToLibrary(kPSQuantityForce, CFSTR("ounce force"), CFSTR("ounces force"), CFSTR("ozf"), 4.4482216152605/16.);
    AddNonSIUnitToLibrary(kPSQuantityForce, CFSTR("kilogram force"), CFSTR("kilograms force"), CFSTR("kgf"), 9.80665);
    
    // Volume / Distance
    AddNonSIUnitToLibrary(kPSQuantityVolumePerLength, CFSTR("liter per 100 kilometers"), CFSTR("liters per 100 kilometers"), CFSTR("L/(100 km)"), 1e-3/100000.);
    
    // Volumetric Flow Rate
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic meter per hour"), CFSTR("cubic meters per hour"), CFSTR("m^3/h"),1./3600.);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic meter per minute"), CFSTR("cubic meters per minute"), CFSTR("m^3/min"),1./60.);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic meter per second"), CFSTR("cubic meters per second"), CFSTR("m^3/s"),1.);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic centimeter per hour"), CFSTR("cubic centimeters per hour"), CFSTR("cm^3/h"),1e-6/3600.);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic centimeter per minute"), CFSTR("cubic centimeters per minute"), CFSTR("cm^3/min"),1e-6/60.);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic centimeter per second"), CFSTR("cubic centimeters per second"), CFSTR("cm^3/s"),1e-6);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic foot per hour"), CFSTR("cubic feet per hour"), CFSTR("ft^3/h"),(1609.344/5280)*(1609.344/5280)*(1609.344/5280)/3600.);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic foot per minute"), CFSTR("cubic feet per minute"), CFSTR("ft^3/min"),(1609.344/5280)*(1609.344/5280)*(1609.344/5280)/60.);
    AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("cubic foot per second"), CFSTR("cubic feet per second"), CFSTR("ft^3/s"),(1609.344/5280)*(1609.344/5280)*(1609.344/5280));
    
    // Stefan-Boltzmann Constant
    AddNonSIUnitToLibrary(kPSQuantityPowerPerAreaPerTemperatureToFourthPower, CFSTR("stefan-boltzmann constant"), CFSTR("stefan-boltzmann constant"), CFSTR("σ"), kPSStefanBoltzmannConstant);
    
    AddNonSIUnitToLibrary(kPSQuantityWavelengthDisplacementConstant, CFSTR("wien wavelength displacement constant"), CFSTR("wien wavelength displacement constant"), CFSTR("b_λ"), kPSWeinDisplacementConstant);
    
    // Gas Permeance Unit
    AddNonSIUnitToLibrary(kPSQuantityGasPermeance, CFSTR("gas permeance unit"), CFSTR("gas permeance unit"), CFSTR("GPU"), 0.33);
    
    
    imperialVolumes = true;
    PSUnitsLibrarySetImperialVolumes(false);
    
    if(countryCode) {
        if(CFStringCompare(countryCode, CFSTR("UK"), 0)== kCFCompareEqualTo) {
            imperialVolumes = false;
            PSUnitsLibrarySetImperialVolumes(true);
        }
    }
}

bool PSUnitsLibraryRemoveUnitWithSymbol(CFStringRef symbol)
{
    if(NULL==unitsLibrary) UnitsLibraryCreate();

    if(CFDictionaryContainsKey(unitsLibrary, symbol)) {
        PSUnitRef unit = (PSUnitRef) CFDictionaryGetValue(unitsLibrary, symbol);
        unit->staticInstance = false;
        CFDictionaryRemoveValue(unitsLibrary, symbol);
        return true;
    }
    return false;
}

bool PSUnitsLibraryImperialVolumes(void)
{
    return imperialVolumes;
}

void PSUnitsLibrarySetImperialVolumes(bool value)
{
    if(imperialVolumes == value) return;
    
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("gal"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("qt"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("pt"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("cup"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("gi"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("floz"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("tbsp"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("tsp"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("halftsp"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("quartertsp"));
    
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/gal)"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/qt)"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/pt)"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/cup)"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/gi)"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/floz)"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/tbsp)"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/tsp)"));
    
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("mi/gal"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("gal/h"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("gal/min"));
    PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("gal/s"));
    
    if(value) {
        // Remove Imperial Volumes
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("qtUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("ptUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("cupUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("giUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("flozUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("tbspUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("tspUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("halftspUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("quartertspUK"));
        
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/galUK)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/qtUK)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/ptUK)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/cupUK)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/giUK)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/flozUK)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/tbspUK)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/tspUK)"));
        
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("mi/galUK"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUK/h"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUK/min"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUK/s"));
        
        
        // Define US Volume units
        // Volume
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US gallon"), CFSTR("US gallons"), CFSTR("galUS"), 0.003785411784);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US quart"), CFSTR("US quarts"), CFSTR("qtUS"), 0.003785411784/4);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US pint"), CFSTR("US pints"), CFSTR("ptUS"), 0.003785411784/8);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US cup"), CFSTR("US cups"), CFSTR("cupUS"), 0.003785411784/16);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US gill"), CFSTR("US gills"), CFSTR("giUS"), 0.003785411784/32);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US fluid ounce"), CFSTR("US fluid ounces"), CFSTR("flozUS"), 0.003785411784/128);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US tablespoon"), CFSTR("US tablespoons"), CFSTR("tbspUS"), 0.003785411784/256);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US teaspoon"), CFSTR("US teaspoons"), CFSTR("tspUS"), 0.003785411784/768);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US half teaspoon"), CFSTR("US half teaspoons"), CFSTR("halftspUS"), 0.003785411784/768/2.);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("US quarter teaspoon"), CFSTR("US quarter teaspoons"), CFSTR("quartertspUS"), 0.003785411784/768/4.);
        
        // Inverse Volume
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US gallon"), CFSTR("inverse US gallons"), CFSTR("(1/galUS)"), 1./0.003785411784);
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US quart"), CFSTR("inverse US quarts"), CFSTR("(1/qtUS)"), 1./(0.003785411784/4));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US pint"), CFSTR("inverse US pints"), CFSTR("(1/ptUS)"), 1./(0.003785411784/8));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US cup"), CFSTR("inverse US cups"), CFSTR("(1/cupUS)"), 1./(0.003785411784/16));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US gill"), CFSTR("inverse US gills"), CFSTR("(1/giUS)"), 1./(0.003785411784/32));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US fluid ounce"), CFSTR("inverse US fluid ounces"), CFSTR("(1/flozUS)"), 1./(0.003785411784/128));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US tablespoon"), CFSTR("inverse US tablespoons"), CFSTR("(1/tbspUS)"), 1./(0.003785411784/256));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse US teaspoon"), CFSTR("inverse US teaspoon"), CFSTR("(1/tspUS)"), 1./(0.003785411784/768));
        
        // Distance / Volume
        AddNonSIUnitToLibrary(kPSQuantityLengthPerVolume, CFSTR("mile per US gallon"), CFSTR("miles per US gallon"), CFSTR("mi/galUS"), 1609.344/0.003785411784);
        
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("US gallon per hour"), CFSTR("US gallons per hour"), CFSTR("galUS/h"), 0.003785411784/3600.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("US gallon per minute"), CFSTR("US gallons per minute"), CFSTR("galUS/min"), 0.003785411784/60.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("US gallon per second"), CFSTR("US gallons per second"), CFSTR("galUS/s"), 0.003785411784);
        
        
        // Define UK Volume units
        // Volume
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("gallon"), CFSTR("gallons"), CFSTR("gal"), 0.00454609);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("quart"), CFSTR("quarts"), CFSTR("qt"), 0.00454609/4);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("pint"), CFSTR("pints"), CFSTR("pt"), 0.00454609/8);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("cup"), CFSTR("cups"), CFSTR("cup"), 0.00454609/16);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("gill"), CFSTR("gill"), CFSTR("gi"), 0.00454609/32);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("fluid ounce"), CFSTR("fluid ounces"), CFSTR("floz"), 0.00454609/160);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("tablespoon"), CFSTR("tablespoons"), CFSTR("tbsp"), 0.00454609/256);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("teaspoon"), CFSTR("teaspoons"), CFSTR("tsp"), 0.00454609/768);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("half teaspoon"), CFSTR("half teaspoons"), CFSTR("halftsp"), 0.00454609/768/2.);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("quarter teaspoon"), CFSTR("quarter teaspoons"), CFSTR("quartertsp"), 0.00454609/768/4.);
        
        // Inverse Volume
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse gallon"), CFSTR("inverse gallons"), CFSTR("(1/gal)"), 1./0.00454609);
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse quart"), CFSTR("inverse quarts"), CFSTR("(1/qt)"), 1./(0.00454609/4));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse pint"), CFSTR("inverse pints"), CFSTR("(1/pt)"), 1./(0.00454609/8));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cup"), CFSTR("inverse cups"), CFSTR("(1/cup)"), 1./(0.00454609/16));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse gill"), CFSTR("inverse gills"), CFSTR("(1/gi)"), 1./(0.00454609/32));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse fluid ounce"), CFSTR("inverse fluid ounces"), CFSTR("(1/floz)"), 1./(0.00454609/160));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse tablespoon"), CFSTR("inverse tablespoons"), CFSTR("(1/tbsp)"), 1./(0.00454609/256));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse teaspoon"), CFSTR("inverse teaspoon"), CFSTR("(1/tsp)"), 1./(0.00454609/768));
        
        // Distance / Volume
        AddNonSIUnitToLibrary(kPSQuantityLengthPerVolume, CFSTR("mile per gallon"), CFSTR("miles per gallon"), CFSTR("mi/gal"), 1609.344/0.00454609);
        
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("gallon per hour"), CFSTR("gallons per hour"), CFSTR("gal/h"), 0.00454609/3600.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("gallon per minute"), CFSTR("gallons per minute"), CFSTR("gal/min"), 0.00454609/60.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("gallon per second"), CFSTR("gallons per second"), CFSTR("gal/s"), 0.00454609);
    }
    else {
        // Remove US Volumes
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("qtUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("ptUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("cupUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("giUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("flozUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("tbspUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("tspUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("halftspUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("quartertspUS"));
        
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/galUS)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/qtUS)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/ptUS)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/cupUS)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/giUS)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/flozUS)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/tbspUS)"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("(1/tspUS)"));
        
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("mi/galUS"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUS/h"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUS/min"));
        PSUnitsLibraryRemoveUnitWithSymbol(CFSTR("galUS/s"));
        
        
        // Define US Volume units
        // Volume
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("gallon"), CFSTR("gallons"), CFSTR("gal"), 0.003785411784);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("quart"), CFSTR("quarts"), CFSTR("qt"), 0.003785411784/4);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("pint"), CFSTR("pints"), CFSTR("pt"), 0.003785411784/8);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("cup"), CFSTR("cups"), CFSTR("cup"), 0.003785411784/16);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("gill"), CFSTR("gill"), CFSTR("gi"), 0.003785411784/32);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("fluid ounce"), CFSTR("fluid ounces"), CFSTR("floz"), 0.003785411784/128);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("tablespoon"), CFSTR("tablespoons"), CFSTR("tbsp"), 0.003785411784/256);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("teaspoon"), CFSTR("teaspoons"), CFSTR("tsp"), 0.003785411784/768);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("half teaspoon"), CFSTR("half teaspoons"), CFSTR("halftsp"), 0.003785411784/768/2);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("quarter teaspoon"), CFSTR("quarter teaspoons"), CFSTR("quartertsp"), 0.003785411784/768/4);
        
        // Inverse Volume
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse gallon"), CFSTR("inverse gallons"), CFSTR("(1/gal)"), 1./0.003785411784);
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse quart"), CFSTR("inverse quarts"), CFSTR("(1/qt)"), 1./(0.003785411784/4));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse pint"), CFSTR("inverse pints"), CFSTR("(1/pt)"), 1./(0.003785411784/8));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse cup"), CFSTR("inverse cups"), CFSTR("(1/cup)"), 1./(0.003785411784/16));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse gill"), CFSTR("inverse gill"), CFSTR("(1/gi)"), 1./(0.003785411784/32));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse fluid ounce"), CFSTR("inverse fluid ounces"), CFSTR("(1/floz)"), 1./(0.003785411784/128));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse tablespoon"), CFSTR("inverse tablespoons"), CFSTR("(1/tbsp)"), 1./(0.003785411784/256));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse teaspoon"), CFSTR("inverse teaspoon"), CFSTR("(1/tsp)"), 1./(0.003785411784/768));
        
        // Distance / Volume
        AddNonSIUnitToLibrary(kPSQuantityLengthPerVolume, CFSTR("mile per gallon"), CFSTR("miles per gallon"), CFSTR("mi/gal"), 1609.344/0.003785411784);
        
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("gallon per hour"), CFSTR("gallons per hour"), CFSTR("gal/h"), 0.003785411784/3600.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("gallon per minute"), CFSTR("gallons per minute"), CFSTR("gal/min"), 0.003785411784/60.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("gallon per second"), CFSTR("gallons per second"), CFSTR("gal/s"), 0.003785411784);
        
        
        // Define UK Volume units
        // Volume
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial gallon"), CFSTR("imperial gallons"), CFSTR("galUK"), 0.00454609);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial quart"), CFSTR("imperial quarts"), CFSTR("qtUK"), 0.00454609/4);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial pint"), CFSTR("imperial pints"), CFSTR("ptUK"), 0.00454609/8);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial cup"), CFSTR("imperial cups"), CFSTR("cupUK"), 0.00454609/16);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial gill"), CFSTR("imperial gill"), CFSTR("giUK"), 0.00454609/32);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial fluid ounce"), CFSTR("imperial fluid ounces"), CFSTR("flozUK"), 0.00454609/160);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial tablespoon"), CFSTR("imperial tablespoons"), CFSTR("tbspUK"), 0.00454609/256);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial teaspoon"), CFSTR("imperial teaspoons"), CFSTR("tspUK"), 0.00454609/768);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial half teaspoon"), CFSTR("imperial half teaspoons"), CFSTR("halftspUK"), 0.00454609/768/2);
        AddNonSIUnitToLibrary(kPSQuantityVolume, CFSTR("imperial quarter teaspoon"), CFSTR("imperial quarter teaspoons"), CFSTR("quartertspUK"), 0.00454609/768/4);
        
        // Inverse Volume
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial gallon"), CFSTR("inverse imperial gallons"), CFSTR("(1/galUK)"), 1./0.00454609);
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial quart"), CFSTR("inverse imperial quarts"), CFSTR("(1/qtUK)"), 1./(0.00454609/4));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial pint"), CFSTR("inverse imperial pints"), CFSTR("(1/ptUK)"), 1./(0.00454609/8));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial cup"), CFSTR("inverse imperial cups"), CFSTR("(1/cupUK)"), 1./(0.00454609/16));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial gill"), CFSTR("inverse imperial gills"), CFSTR("(1/giUK)"), 1./(0.00454609/32));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial fluid ounce"), CFSTR("inverse imperial fluid ounces"), CFSTR("(1/flozUK)"), 1./(0.00454609/160));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial tablespoon"), CFSTR("inverse imperial tablespoons"), CFSTR("(1/tbspUK)"), 1./(0.00454609/256));
        AddNonSIUnitToLibrary(kPSQuantityInverseVolume, CFSTR("inverse imperial teaspoon"), CFSTR("inverse imperial teaspoon"), CFSTR("(1/tspUK)"), 1./(0.00454609/768));
        
        // Distance / Volume
        AddNonSIUnitToLibrary(kPSQuantityLengthPerVolume, CFSTR("mile per imperial gallon"), CFSTR("miles per imperial gallon"), CFSTR("mi/galUK"), 1609.344/0.00454609);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("imperial gallon per hour"), CFSTR("imperial gallons per hour"), CFSTR("galUK/h"), 0.00454609/3600.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("imperial gallon per minute"), CFSTR("imperial gallons per minute"), CFSTR("galUK/min"), 0.00454609/60.);
        AddNonSIUnitToLibrary(kPSQuantityVolumetricFlowRate, CFSTR("imperial gallon per second"), CFSTR("imperial gallons per second"), CFSTR("galUK/s"), 0.00454609);
    }
    imperialVolumes = value;
}

CFMutableDictionaryRef PSUnitGetLibrary()
{
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    return unitsLibrary;
}

void PSUnitSetLibrary(CFMutableDictionaryRef newUnitsLibrary)
{
    if(newUnitsLibrary == unitsLibrary) return;
    if(newUnitsLibrary) {
        if(unitsLibrary) CFRelease(unitsLibrary);
        unitsLibrary = (CFMutableDictionaryRef) CFRetain(newUnitsLibrary);
    }
}

void PSUnitLibraryShow(void)
{
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    CFDictionaryApplyFunction (unitsLibrary,(CFDictionaryApplierFunction) PSUnitDisplay, NULL);
}

void PSUnitLibraryShowFull(void)
{
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    CFDictionaryApplyFunction (unitsLibrary,(CFDictionaryApplierFunction) PSUnitDisplayFull,NULL);
}

void PSUnitLibraryShowUnitRegex(void)
{
    if(NULL==unitsLibrary) {
        UnitsLibraryCreate();
    }
    PSCFStringShow(CFSTR("("));
    CFArrayRef keys = PSCFDictionaryCreateArrayWithAllKeys(unitsLibrary);
    CFIndex count = CFArrayGetCount(keys);
    CFIndex length = 0;
    for(CFIndex index = 0; index < count; index++) {
        CFStringRef key = CFArrayGetValueAtIndex(keys, index);
        PSCFStringShow(key);
        length += CFStringGetLength(key);
        if(length > 1000) {
            PSCFStringShow(CFSTR(")"));
            printf("\n");
            length = 0;
            PSCFStringShow(CFSTR("("));
        }
        else if(index!=count-1) PSCFStringShow(CFSTR("|"));
    }
    PSCFStringShow(CFSTR(")"));
    CFRelease(keys);
}

CFArrayRef PSUnitGetUnitsSortedByNameLength(void)
{
    if(NULL != unitsNamesLibrary) return unitsNamesLibrary;
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    CFArrayRef units = PSCFDictionaryCreateArrayWithAllValues(unitsLibrary);
    unitsNamesLibrary = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(units), units);
    CFRelease(units);
    CFArraySortValues(unitsNamesLibrary, CFRangeMake(0, CFArrayGetCount(unitsNamesLibrary)), unitNameLengthSort, NULL);
    return unitsNamesLibrary;
}

CFArrayRef PSUnitCreateArrayOfRootUnits(void)
{
    if(NULL==unitsLibrary) UnitsLibraryCreate();
    CFArrayRef keys = PSCFDictionaryCreateArrayWithAllKeys(unitsLibrary);
    CFIndex count = CFArrayGetCount(keys);
    CFMutableArrayRef results = CFArrayCreateMutable(kCFAllocatorDefault,0, &kCFTypeArrayCallBacks);
    
    CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("m")));
    CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("g")));
    CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("s")));
    CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("A")));
    CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("K")));
    CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("mol")));
    CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("cd")));
    
    for(CFIndex index=0;index<count; index++) {
        CFStringRef key = CFArrayGetValueAtIndex(keys, index);
        PSUnitRef unit = CFDictionaryGetValue(unitsLibrary, key);
        if(unit->root_symbol_prefix == kPSSIPrefixNone && !PSUnitIsSIBaseUnit(unit) && unit != PSUnitDimensionlessAndUnderived() && unit->root_name != NULL) {
            CFArrayAppendValue(results, unit);
        }
    }
    CFRelease(keys);
    CFMutableArrayRef sorted = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(results), results);
    CFArraySortValues(sorted, CFRangeMake(0, CFArrayGetCount(results)), unitNameSort, NULL);
    CFRelease(results);
    return sorted;
}

CFArrayRef PSUnitCreateArrayOfRootUnitsForQuantityName(CFStringRef quantityName)
{
    if(NULL==quantityName) return NULL;
    CFArrayRef allUnits = PSUnitCreateArrayOfUnitsForQuantityName(quantityName);
    if(NULL==allUnits) return NULL;
    CFIndex count = CFArrayGetCount(allUnits);
    CFMutableArrayRef results = CFArrayCreateMutable(kCFAllocatorDefault,0, &kCFTypeArrayCallBacks);
    
    PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName(quantityName);
    if(dimensionality == PSDimensionalityForQuantityName(kPSQuantityLength)) CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("m")));
    else if(dimensionality == PSDimensionalityForQuantityName(kPSQuantityMass)) CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("g")));
    else if(dimensionality == PSDimensionalityForQuantityName(kPSQuantityTime)) CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("s")));
    else if(dimensionality == PSDimensionalityForQuantityName(kPSQuantityCurrent)) CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("A")));
    else if(dimensionality == PSDimensionalityForQuantityName(kPSQuantityTemperature)) CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("K")));
    else if(dimensionality == PSDimensionalityForQuantityName(kPSQuantityAmount)) CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("mol")));
    else if(dimensionality == PSDimensionalityForQuantityName(kPSQuantityLuminousIntensity)) CFArrayAppendValue(results, PSUnitForSymbol(CFSTR("cd")));
    
    for(CFIndex index=0;index<count; index++) {
        PSUnitRef unit = CFArrayGetValueAtIndex(allUnits, index);
        if(unit->root_symbol_prefix == kPSSIPrefixNone && !PSUnitIsSIBaseUnit(unit) && unit != PSUnitDimensionlessAndUnderived() && unit->root_name != NULL) {
            CFArrayAppendValue(results, unit);
        }
    }
    CFRelease(allUnits);
    CFIndex resultsCount = CFArrayGetCount(results);
    if(resultsCount==0) {
        CFRelease(results);
        return NULL;
    }
    CFMutableArrayRef sorted = CFArrayCreateMutableCopy(kCFAllocatorDefault, resultsCount, results);
    CFArraySortValues(sorted, CFRangeMake(0, resultsCount), unitNameSort, NULL);
    CFRelease(results);
    return sorted;
}

CFStringRef PSUnitGuessQuantityName(PSUnitRef theUnit)
{
    CFStringRef quantityName = NULL;
    PSDimensionalityRef theDimensionality = PSUnitGetDimensionality(theUnit);
    CFArrayRef quantityNames = PSDimensionalityCreateArrayOfQuantityNames(theDimensionality);
    if(quantityNames) {
        quantityName = CFArrayGetValueAtIndex(quantityNames, 0);
        CFRelease(quantityNames);
        return quantityName;
    }
    else {
        // Let's not guess at this point.  Just return dimensionality symbol and let user decide
        return PSDimensionalityGetSymbol(theDimensionality);
        // If failed to find quantity, reduce the unit and try again.
        double multiplier = 1;
        PSUnitRef reducedUnit = PSUnitByReducing(theUnit, &multiplier);
        if(reducedUnit != theUnit) return PSUnitGuessQuantityName(reducedUnit);
        else return PSDimensionalityGetSymbol(theDimensionality);
    }
    return NULL;
}



@end

