//
//  PSDimensionality.h
//
//  Created by PhySy Ltd on 10/30/09.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//


/*!
 @header PSDimensionality
 @copyright PhySy Ltd
 */

// ---- API ----

@interface PSDimensionality : NSObject
@end

extern CFMutableDictionaryRef dimensionalityLibrary;
extern CFMutableDictionaryRef dimensionalityQuantitiesLibrary;

#define IF_UNEQUAL_DIMENSIONALITIES(DIM1,DIM2,RESULT) if(!PSDimensionalityEqual(DIM1,DIM2)) { \
fprintf(stderr, "%s : Unequal dimensionalities:  ",__FUNCTION__); \
PSCFStringShow(PSDimensionalityGetSymbol(DIM1)); \
fprintf(stderr, " and "); \
PSCFStringShow(PSDimensionalityGetSymbol(DIM2)); \
fprintf(stderr, "\n"); \
return RESULT;}

#define IF_INCOMPATIBLE_DIMENSIONALITIES(DIM1,DIM2,RESULT) if(!PSDimensionalityHasSameReducedDimensionality(DIM1,DIM2)) { \
fprintf(stderr, "%s : Incompatible dimensionalities:  ",__FUNCTION__); \
PSCFStringShow(PSDimensionalityGetSymbol(DIM1)); \
fprintf(stderr, " and "); \
PSCFStringShow(PSDimensionalityGetSymbol(DIM2)); \
fprintf(stderr, "\n"); \
return RESULT;}

/*!
 @header PSDimensionality
 PSDimensionality represents the dimensionality of a physical quantity. Seven 
 physical quantities serve as fundamental reference quantities from which 
 all other physical quantities can be derived.  These reference quantities are 
 (1) length, 
 (2) mass, 
 (3) time, 
 (4) electric current, 
 (5) thermodynamic temperature (the absolute measure of temperature)
 (6) amount of substance, 
 (7) luminous intensity.  
  
 @copyright PhySy
 */

/*!  @unsorted */

/*!
 @typedef PSDimensionalityRef
 This is the type of a reference to immutable PSDimensionality.   
 A NULL reference represents a dimensionless and underived dimensionality.
 */
typedef const PSDimensionality * PSDimensionalityRef;

#pragma mark Accessors
/*!
 @functiongroup Accessors
 */

/*!
 @function PSDimensionalityGetSymbol
 @abstract Returns the symbol for the dimensionality.
 @param theDimensionality the dimensionality.
 @result a string containing the symbol.
 */
CFStringRef PSDimensionalityGetSymbol(PSDimensionalityRef theDimensionality);

/*
 @function PSDimensionalityGetNumeratorExponentAtIndex
 @abstract Gets the numerator exponent for the dimension at index.
 @param thedimensionality the dimensionality.
 @param index the dimension index constant.
 @result the integer numerator exponent.
 @discussion base units length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
uint8_t PSDimensionalityGetNumeratorExponentAtIndex(PSDimensionalityRef theDimensionality, PSBaseDimensionIndex index);

/*
 @function PSDimensionalityGetDenominatorExponentAtIndex
 @abstract Gets the denominator exponent for the dimension at index.
 @param theDimensionality the dimensionality.
 @result the integer denominator exponent.
 @discussion base units length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
uint8_t PSDimensionalityGetDenominatorExponentAtIndex(PSDimensionalityRef theDimensionality, PSBaseDimensionIndex index);

/*
 @function PSDimensionalityReducedExponentAtIndex
 @abstract Returns the exponent for the dimension at Index.
 @param theDimensionality the dimensionality.
 @result the integer exponent (numerator-denominator).
 @discussion base units length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
int8_t PSDimensionalityReducedExponentAtIndex(PSDimensionalityRef theDimensionality, PSBaseDimensionIndex index);


#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSDimensionalityEqual
 @abstract Determines if the two dimensionalities are equal.
 @param theDimensionality1 The first dimensionality.
 @param theDimensionality2 The second dimensionality.
 @result true or false.
 */
bool PSDimensionalityEqual(PSDimensionalityRef theDimensionality1,PSDimensionalityRef theDimensionality2);

/*!
 @function PSDimensionalityIsDimensionless
 @abstract Determines if the dimensionality is dimensionless.
 @param theDimensionality the dimensionality.
 @result true or false.
 */
bool PSDimensionalityIsDimensionless(PSDimensionalityRef theDimensionality);

/*
 @function PSDimensionalityIsDerived
 @abstract Determines if the dimensionality is derived from at least one of seven base dimensions.
 @param theDimensionality the dimensionality.
 @result true or false.
 */
bool PSDimensionalityIsDerived(PSDimensionalityRef theDimensionality);

/*!
 @function PSDimensionalityIsDimensionlessAndNotDerived
 @abstract Determines if the dimensionality is dimensionless but not derived.
 @param theDimensionality The dimensionality.
 @result true or false.
 @discussion Determines if the Dimensionality is dimensionless but not derived, that is, 
 it may be a counting Dimensionality.
 */
bool PSDimensionalityIsDimensionlessAndNotDerived(PSDimensionalityRef theDimensionality);

/*!
 @function PSDimensionalityIsDimensionlessAndDerived
 @abstract Determines if the dimensionality is dimensionless and derived.
 @param theDimensionality The dimensionality.
 @result true or false.
 */
bool PSDimensionalityIsDimensionlessAndDerived(PSDimensionalityRef theDimensionality);

/*!
 @function PSDimensionalityIsBaseDimensionality
 @abstract Determines if the dimensionality is one of the seven base dimensionalities.
 @param theDimensionality The dimensionality.
 @result true or false.
 */
bool PSDimensionalityIsBaseDimensionality(PSDimensionalityRef theDimensionality);

/*!
 @function PSDimensionalityHasSameReducedDimensionality
 @abstract Determines if the two dimensionalities have the same reduced dimensionality, 
 @param theDimensionality1 The first dimensionality.
 @param theDimensionality2 The second dimensionality.
 @result true or false.
 */
bool PSDimensionalityHasSameReducedDimensionality(PSDimensionalityRef theDimensionality1,PSDimensionalityRef theDimensionality2);

/*
 @function PSDimensionalityHasReducedExponents
 @abstract Determines if the dimensionality has the same seven base dimension exponents,
 @param theDimensionality the dimensionality.
 @param length_exponent The length exponent.
 @param mass_exponent The mass exponent.
 @param time_exponent The time exponent.
 @param current_exponent The current exponent.
 @param temperature_exponent The temperature exponent.
 @param amount_exponent The amount exponent.
 @param luminous_intensity_exponent The luminous intensity exponent.
 @result true or false.
 */
bool PSDimensionalityHasReducedExponents(PSDimensionalityRef theDimensionality,
                                         int8_t length_exponent,
                                         int8_t mass_exponent,
                                         int8_t time_exponent,
                                         int8_t current_exponent,
                                         int8_t temperature_exponent,
                                         int8_t amount_exponent,
                                         int8_t luminous_intensity_exponent);

#pragma mark Operations
/*!
 @functiongroup Operations
 */

/*
 @function PSDimensionalityDimensionless
 @abstract Returns the dimensionality where all exponents are zero.
 @result theDimensionality the dimensionality.
 */
PSDimensionalityRef PSDimensionalityDimensionless(void);

/*
 @function PSDimensionalityForBaseDimensionIndex
 @abstract Returns the dimensionality associated with the base dimension index .
 @result theDimensionality the dimensionality.
 */
PSDimensionalityRef PSDimensionalityForBaseDimensionIndex(PSBaseDimensionIndex index);

/*
 @function PSDimensionalityWithBaseDimensionSymbol
 @abstract Returns the dimensionality associated with the base dimension symbol.  Base dimemension symbols are L, M, T, I, ϴ, N, and J.  The symbol for temperature, "ϴ", does not exist as a valid ascii character, so, if needed, the symbol "@" can be substituted for "ϴ" in this method.
 @result theDimensionality the dimensionality.
 */
PSDimensionalityRef PSDimensionalityWithBaseDimensionSymbol(CFStringRef theString);

/*!
 @function PSDimensionalityForSymbol
 @abstract Parses the string and returns the dimensionality for the symbol
 @param theString the string with the dimensionality symbol.
 @result the dimensionality.
 @discussion symbols for the seven base dimensions, length, mass, time, current, temperature, amount, and luminous intensity are L, M, T, I, ϴ, N, and J, respectively.
 The input symbol can be in the general form 
 
 L^l * M^m * T^t * I^i * ϴ^q * N^n * J^j / (L^l' * M^m' * T^t' * I^i' * ϴ^q' *• N^n' • J^j'), 
 
 where the lower case exponents are replaced with integer values and any combination of symbols in the numerator or denominator can be omitted.  This method is intelligent enough to handle any valid combination of the base dimension symbols multiplied, divided, and raised to arbitrary signed integer powers.   The symbol for temperature, "ϴ", does not exist as a valid ascii character, so, if needed, the symbol "@" can be substituted for "ϴ" in this parser.
 */
PSDimensionalityRef PSDimensionalityForSymbol(CFStringRef theString);

/*!
 @function PSDimensionalityForQuantityName
 @abstract Returns the dimensionality for the quantity
 @param quantityName The quantity Name.
 @result the dimensionality.
 */
PSDimensionalityRef PSDimensionalityForQuantityName(CFStringRef quantityName);

/*!
 @function PSDimensionalityByReducing
 @abstract Returns the dimensionality by reducing the numerator and denominator exponents to their lowest values.
 @param theDimensionality the dimensionality.
 @result the dimensionality with reduced numerator and denominator exponents
 */
PSDimensionalityRef PSDimensionalityByReducing(PSDimensionalityRef theDimensionality);

/*!
 @function PSDimensionalityByTakingNthRoot
 @abstract Returns the dimensionality by dividing the numerator and denominator exponents by an integer.
 @param theDimensionality the dimensionality.
 @param root the integer root.
 @param error pointer to a CFErrorRef.
 @result the nth root dimensionality
 @discussion The numerator and denominator exponents in a valid dimensionality can only take on integer values.
 If this function cannot return a valid dimensionality then it will return NULL.
 */
PSDimensionalityRef PSDimensionalityByTakingNthRoot(PSDimensionalityRef theDimensionality, uint8_t root, CFErrorRef *error);

/*!
 @function PSDimensionalityByMultiplying
 @abstract Returns the dimensionality after multiplying two dimensionalities and reducing the dimensionality numerator and denominator exponents to their lowest integer values
 @param theDimensionality1 The first dimensionality.
 @param theDimensionality2 The second dimensionality.
 @param error pointer to a CFErrorRef.
 @result the new dimensionality.
 */
PSDimensionalityRef PSDimensionalityByMultiplying(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2, CFErrorRef *error);

/*!
 @function PSDimensionalityByMultiplyingWithoutReducing
 @abstract Returns the dimensionality after multiplying two dimensionalities
 @param theDimensionality1 The first dimensionality.
 @param theDimensionality2 The second dimensionality.
 @param error pointer to a CFErrorRef.
 @result the new dimensionality.
 */
PSDimensionalityRef PSDimensionalityByMultiplyingWithoutReducing(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2, CFErrorRef *error);

/*!
 @function PSDimensionalityByDividing
 @abstract Returns the dimensionality after dividing theDimensionality1 by theDimensionality2 and reducing the dimensionality numerator and denominator exponents to their lowest integer values
 @param theDimensionality1 The first dimensionality.
 @param theDimensionality2 The second dimensionality.
 @result the new dimensionality.
 */
PSDimensionalityRef PSDimensionalityByDividing(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2);

/*!
 @function PSDimensionalityByDividingWithoutReducing
 @abstract Returns the dimensionality after dividing theDimensionality1 by theDimensionality2
 @param theDimensionality1 The first dimensionality.
 @param theDimensionality2 The second dimensionality.
 @result the new dimensionality.
 */
PSDimensionalityRef PSDimensionalityByDividingWithoutReducing(PSDimensionalityRef theDimensionality1, PSDimensionalityRef theDimensionality2);

/*!
 @function PSDimensionalityByRaisingToAPower
 @abstract Returns the dimensionality after raising a dimensionality to a power and reducing the dimensionality numerator and denominator exponents to their lowest integer values.
 @param theDimensionality the dimensionality.
 @result the new dimensionality.
 */
PSDimensionalityRef PSDimensionalityByRaisingToAPower(PSDimensionalityRef theDimensionality, double power, CFErrorRef *error);

/*!
 @function PSDimensionalityByRaisingToAPowerWithoutReducing
 @abstract Returns the dimensionality after by raising a dimensionality to a power.
 @param theDimensionality the dimensionality.
 @param power the power.
 @param error a pointer to a CFError.
 @result the new dimensionality.
 */
PSDimensionalityRef PSDimensionalityByRaisingToAPowerWithoutReducing(PSDimensionalityRef theDimensionality, double power, CFErrorRef *error);

/*!
 @function PSDimensionalityCreateArrayOfQuantityNames
 @abstract Creates an array of physical quantity names for the dimensionality.
 @param theDimensionality the dimensionality.
 @result a CFArray of strings with all the physical quantity names having this dimensionality.
 */
CFArrayRef PSDimensionalityCreateArrayOfQuantityNames(PSDimensionalityRef theDimensionality);

/*!
 @function PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality
 @abstract Creates an array of physical quantity names for with the same reduced dimensionality.
 @param theDimensionality the dimensionality.
 @result a CFArray of strings with all the physical quantity names having the same reduced dimensionality.
 */
CFArrayRef PSDimensionalityCreateArrayOfQuantityNamesWithSameReducedDimensionality(PSDimensionalityRef theDimensionality);

/*!
 @function PSDimensionalityCreateArrayWithSameReducedDimensionality
 @abstract Creates an array of dimenstionalities with the same dimensionality.
 @param theDimensionality the dimensionality.
 @result a CFArray of dimenstionalities with all dimensionalities having the same reduced dimensionality as input.
 @discussion The routine returns all the dimensionalities starting with the largest exponent (numerator or denominator) down to the reduced dimensionality.
 */
CFArrayRef PSDimensionalityCreateArrayWithSameReducedDimensionality(PSDimensionalityRef theDimensionality);

#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */

/*
 @function PSDimensionalityCreateLaTeXSymbol
 @abstract Creates a CFString encoding of the dimensionality
 @param theDimensionality the dimensionality.
 @param error a pointer to a CFError.
 @result a CFString latex encoding of the dimensionality.
 */
CFStringRef PSDimensionalityCreateLaTeXSymbol(PSDimensionalityRef theDimensionality);

/*
 @function PSDimensionalityCreateData
 @abstract Creates a CFData encoding of the dimensionality
 @param theDimensionality the dimensionality.
 @param error a pointer to a CFError.
 @result a CFData encoding of the dimensionality.
 */
CFDataRef PSDimensionalityCreateData(PSDimensionalityRef theDimensionality, CFErrorRef *error);

/*
 @function PSDimensionalityWithData
 @abstract Returns a dimensionality decoded from a CFData instance
 @param data the CFData with encoded dimensionality.
 @param error a pointer to a CFError.
 @result the dimensionality.
 */
PSDimensionalityRef PSDimensionalityWithData(CFDataRef data, CFErrorRef *error);

/*
 @function PSDimensionalityShow
 @abstract Shows a short descriptor of the dimensionality
 @param theDimensionality the dimensionality.
 */
void PSDimensionalityShow(PSDimensionalityRef theDimensionality);

/*
 @function PSDimensionalityShowFull
 @abstract Shows a long descriptor of the dimensionality
 @param theDimensionality the dimensionality.
 */
void PSDimensionalityShowFull(PSDimensionalityRef theDimensionality);

#pragma mark Library
/*!
 @functiongroup Library
 */

/*!
 @function PSDimensionalityGetLibrary
 @abstract Gets a copy of the library of dimensionalities
 @result a CFMutableDictionary containing the dimensionalities.
 */
CFMutableDictionaryRef PSDimensionalityGetLibrary(void);

/*!
 @function PSDimensionalityLibraryCreateArrayOfAllQuantities
 @abstract Creates a alphabetical sorted array of all quantity names 
 */
CFArrayRef PSDimensionalityLibraryCreateArrayOfAllQuantities(void);


void PSDimensionalitySetLibrary(CFMutableDictionaryRef newDimensionalityLibrary);
void PSDimensionalityRGBColorForDimensionality(PSDimensionalityRef theDimensionality, float *red, float *green, float *blue);
