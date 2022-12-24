//
//  PSUnit.h
//
//  Created by PhySy Ltd on 10/30/09.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

 // ---- API ----

#import "PhySyFoundation.h"
//#import "PhySyFoundation.h"

@interface PSUnit : NSObject
@end

/*!
 @header PSUnit
 @copyright PhySy Ltd
 @discussion
 PSUnit represents the unit of a physical quantity.  An important characteristic of physical
 quantities is that any given physical quantity can be derived from other physical quantities
 through physical laws.  For example, the physical quantity of speed is calculated as a ratio
 of distance traveled to time elapsed.   The volume of a box is calculated as the product of
 three quantities of length: i.e., height, width, and depth of the box.  Any physical quantity
 can always be related back through physical laws to a smaller set of reference physical
 quantities.   In fact, as the laws of physics become unified it has been argued that this
 smaller set can be reduced to simply the Planck length and the speed of light.    At the level
 of theory employed by most scientists and engineers, however, there is a practical agreement
 that seven physical quantities should serve as fundamental reference quantities from which
 all other physical quantities can be derived.  These reference quantities are
 (1) length,
 (2) mass,
 (3) time,
 (4) electric current,
 (5) thermodynamic temperature (the absolute measure of temperature)
 (6) amount of substance,
 (7) luminous intensity.
  
 @unsorted
 @copyright PhySy
 */

/*!
 @typedef PSUnitRef
 This is the type of a reference to immutable PSUnit.
 */
typedef const PSUnit * PSUnitRef;

#pragma mark Accessors

/*!
 @functiongroup Accessors
 */

/*
 @function PSUnitGetTypeID
 @abstract Returns the type identifier for the PSUnit opaque type.
 @result The type identifier for the PSUnit opaque type.
 */
CFTypeID PSUnitGetTypeID(void);

/*!
 @function PSUnitGetDimensionality
 @abstract Gets unit's dimensionality.
 @param theUnit The unit.
 @result the dimensionality of a unit
 */
PSDimensionalityRef PSUnitGetDimensionality(PSUnitRef theUnit);

/*
 @function PSUnitGetNumeratorPrefixAtIndex
 @abstract Gets unit's numerator root unit prefix for the dimension at index.
 @param theUnit The unit.
 @result the integer exponent associated with an SI prefix
 @discussion root unit for length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
PSSIPrefix PSUnitGetNumeratorPrefixAtIndex(PSUnitRef theUnit, const uint8_t index);

/*
 @function PSUnitGetDenominatorPrefixAtIndex
 @abstract Gets unit's denominator root unit prefix for the dimension at index.
 @param theUnit The unit.
 @result the integer exponent associated with an SI prefix
 @discussion root unit for length, mass, time, current, temperature, amount, and luminous intensity are
 assigned to index constants kPSLengthIndex, kPSMassIndex, kPSTimeIndex, kPSCurrentIndex,  kPSTemperatureIndex,
 kPSAmountIndex, kPSLuminousIntensityIndex, respectively.
 */
PSSIPrefix PSUnitGetDenominatorPrefixAtIndex(PSUnitRef theUnit, const uint8_t index);

/*!
 @function PSUnitCopyRootName
 @abstract Gets the root name of unit.
 @param theUnit The unit.
 @result string containing the base name, or NULL.
 */
CFStringRef PSUnitCopyRootName(PSUnitRef theUnit);

/*!
 @function PSUnitCopyRootPluralName
 @abstract Gets the plural root name of unit.
 @param theUnit The unit.
 @result string containing the plural base name, or NULL.
 */
CFStringRef PSUnitCopyRootPluralName(PSUnitRef theUnit);

/*!
 @function PSUnitCopyRootSymbol
 @abstract Gets the root symbol of unit.
 @param theUnit The unit.
 @result string containing the base symbol, or NULL
 */
CFStringRef PSUnitCopyRootSymbol(PSUnitRef theUnit);


/*!
 @function PSUnitCopyRootSymbolPrefix
 @abstract returns whether an SI prefix can be used with root symbol.
 @param theUnit The unit.
 @result true or false.
 */
bool PSUnitAllowsSIPrefix(PSUnitRef theUnit);

/*!
 @function PSUnitCopyRootSymbolPrefix
 @abstract Gets the symbol prefix of unit.
 @param theUnit The unit.
 @result the integer exponent associated with SI prefix
 */
PSSIPrefix PSUnitCopyRootSymbolPrefix(PSUnitRef theUnit);

/*!
 @function PSUnitGetIsSpecialSISymbol
 @abstract returns whether root symbol is a special SI unit symbol.
 @param theUnit The unit.
 @result true or false .
 */
bool PSUnitGetIsSpecialSISymbol(PSUnitRef theUnit);


#pragma mark Tests
/*!
 @functiongroup Tests
 */

/*!
 @function PSUnitIsCoherentSIBaseUnit
 @abstract Determines if unit is one of the seven coherent base units.
 @param theUnit The unit.
 @result true or false.
 */
bool PSUnitIsCoherentSIBaseUnit(PSUnitRef theUnit);

/*!
 @function PSUnitIsSIBaseRootUnit
 @abstract Determines if unit is one of the seven base root units.
 @param theUnit The unit.
 @result true or false.
 */
bool PSUnitIsSIBaseRootUnit(PSUnitRef theUnit);

/*!
 @function PSUnitIsSIBaseUnit
 @abstract Determines if unit is one of the prefixed seven base units.
 @param theUnit The unit.
 @result true or false.
 */
bool PSUnitIsSIBaseUnit(PSUnitRef theUnit);

/*!
 @function PSUnitIsCoherentDerivedUnit
 @abstract Determines if unit is one of the SI coherent derived units.
 @param theUnit The unit.
 @result true or false.
 */
bool PSUnitIsCoherentDerivedUnit(PSUnitRef theUnit);

/*!
 @function PSUnitIsDimensionlessAndUnderived
 @abstract Determines if unit is the dimensionless and underived unit.
 @param theUnit The unit.
 @result true or false.
 */
bool PSUnitIsDimensionlessAndUnderived(PSUnitRef theUnit);

/*!
 @function PSUnitIsDimensionless
 @abstract Determines if unit is the dimensionless unit.
 @param theUnit The unit.
 @result true or false.
 */
bool PSUnitIsDimensionless(PSUnitRef theUnit);

bool PSUnitHasDerivedSymbol(PSUnitRef theUnit);

/*!
 @function PSUnitHasSameReducedDimensionality
 @abstract Determines if units have same reduced dimensionality.
 @param theUnit1 The unit.
 @param theUnit2 The unit.
 @result true or false.
 @discussion Determines if units have same reduced dimensionality.
 */
bool PSUnitHasSameReducedDimensionality(PSUnitRef theUnit1, PSUnitRef theUnit2);

/*!
 @function PSUnitAreEquivalentUnits
 @abstract Determines if units are equivalent.
 @param theUnit1 The unit.
 @param theUnit2 The unit.
 @result true or false.
 @discussion Determines if units are equivalent.  If true,
 these two units can be substituted for each other without modifying
 the quantity's numerical value.
 */
bool PSUnitAreEquivalentUnits(PSUnitRef theUnit1, PSUnitRef theUnit2);

/*!
 @function PSUnitEqual
 @abstract Determines if the two units are equal.
 @param theUnit1 The first unit.
 @param theUnit2 The second unit.
 @result true or false.
 */
bool PSUnitEqual(PSUnitRef theUnit1,PSUnitRef theUnit2);

#pragma mark Operations
/*!
 @functiongroup Operations
 */

/*!
 @function PSUnitDimensionlessAndUnderived
 @abstract returns the dimensionless and underived unit.
 @result The unit.
 */
PSUnitRef PSUnitDimensionlessAndUnderived(void);

/*!
 @function PSUnitCreateArrayOfEquivalentUnits
 @abstract Creates an array of units that are equivalent to a unit
 @param theUnit The equivalent unit.
 @result a CFArray containing the results.
 */
CFArrayRef PSUnitCreateArrayOfEquivalentUnits(PSUnitRef theUnit);

/*!
 @function PSUnitFindEquivalentUnitWithShortestSymbol
 @abstract Finds the unit with the shortest symbol
 @param theUnit The equivalent unit.
 @result the unit with the shortest symbol.
 */
PSUnitRef PSUnitFindEquivalentUnitWithShortestSymbol(PSUnitRef theUnit);

/*!
 @function PSUnitCreateArrayOfUnitsForQuantityName
 @abstract Creates an array of units for a quantity
 @param quantityName The quantity.
 @result a CFArray containing the results.
 */
CFArrayRef PSUnitCreateArrayOfUnitsForQuantityName(CFStringRef quantityName);

/*!
 @function PSUnitCreateArrayOfUnitsForDimensionality
 @abstract Creates an array of units for a dimensionality
 @param theDimensionality The dimensionality.
 @result a CFArray containing the results.
 */
CFArrayRef PSUnitCreateArrayOfUnitsForDimensionality(PSDimensionalityRef theDimensionality);

CFArrayRef PSUnitCreateArrayOfUnitsWithSameRootSymbol(PSUnitRef theUnit);

/*!
 @function PSUnitCreateArrayOfUnitsForSameReducedDimensionality
 @abstract Creates an array of units having same reduced dimensionality
 @param theDimensionality The dimensionality.
 @result a CFArray containing the results.
 */
CFArrayRef PSUnitCreateArrayOfUnitsForSameReducedDimensionality(PSDimensionalityRef theDimensionality);

/*!
 @function PSUnitCreateArrayOfConversionUnits
 @abstract Creates an array of units that have same dimensionality as unit
 @param theUnit The unit.
 @result a CFArray containing the results.
 */
CFArrayRef PSUnitCreateArrayOfConversionUnits(PSUnitRef theUnit);

/*!
 @function PSUnitGetScaleNonSIToCoherentSI
 @abstract Gets the scaling from the Non-SI root unit
 to coherent derived SI unit with the same dimensionality.
 @param theUnit The unit.
 @result scaling factor.
 */
double PSUnitGetScaleNonSIToCoherentSI(PSUnitRef theUnit);

/*!
 @function PSUnitCreateName
 @abstract Creates a CFString with the name of unit
 from its root_name and prefix.
 @param theUnit The unit.
 @result a CFString with the name.
 */
CFStringRef PSUnitCreateName(PSUnitRef theUnit);

/*!
 @function PSUnitCreatePluralName
 @abstract Creates a CFString with the plural name of unit
 from its plural root name and prefix.
 @param theUnit The unit.
 @result a CFString with the plural name.
 */
CFStringRef PSUnitCreatePluralName(PSUnitRef theUnit);

/*!
 @function PSUnitCopySymbol
 @abstract Gets the CFString with the Symbol of unit
 from its root symbol and prefix.
 @param theUnit The unit.
 @result a CFString with the symbol.
 */
CFStringRef PSUnitCopySymbol(PSUnitRef theUnit);

/*!
 @function PSUnitScaleToCoherentSIUnit
 @abstract Calculates the conversion scaling factor.
 @param theUnit The unit.
 @result numerical value scaling factor.
 @discussion Calculates the scaling factor needed to transform the
 numerical value of quantity with this unit into the appropriate
 numerical value for the coherent si unit of the same dimensionality.
 */
double PSUnitScaleToCoherentSIUnit(PSUnitRef theUnit);

/*!
 @function PSUnitCreateDerivedLaTeXSymbol
 @abstract Creates a CFString with the unit's derived latex symbol
 @param theUnit The unit.
 @result a CFString with the derived unit latex symbol.
 */
CFStringRef PSUnitCreateDerivedLaTeXSymbol(PSUnitRef theUnit);

/*!
 @function PSUnitCreateDerivedSymbol
 @abstract Creates a CFString with the unit's derived symbol
 @param theUnit The unit.
 @result a CFString with the derived unit symbol.
 */
CFStringRef PSUnitCreateDerivedSymbol(PSUnitRef theUnit);

/*!
 @function PSUnitFindCoherentSIUnitWithDimensionality
 @abstract Returns a coherent SI unit with given dimensionality
 @param theDimensionality The dimensionality.
 @result the unit.
 */
PSUnitRef PSUnitFindCoherentSIUnitWithDimensionality(PSDimensionalityRef theDimensionality);

/*!
 @function PSUnitFindCoherentSIUnit
 @abstract Returns a coherent SI unit with the dimensionality of input unit
 @param input The input unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @result the new unit.
 */
PSUnitRef PSUnitFindCoherentSIUnit(PSUnitRef input, double *unit_multiplier);

/*!
 @function PSUnitByTakingNthRoot
 @abstract Returns the unit by dividing the numerator and denominator exponents by an integer.
 @param input The unit.
 @param root the integer root.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @param error pointer to a CFErrorRef.
 @result the nth root unit
 @discussion The numerator and denominator exponents in a valid unit can only take on integer values.
 If this function cannot return a valid unit then it will return NULL */
PSUnitRef PSUnitByTakingNthRoot(PSUnitRef input, uint8_t root, double *unit_multiplier, CFErrorRef *error);

/*!
 @function PSUnitByReducing
 @abstract Returns the unit by reducing the numerator and denominator exponents to their lowest integer values.
 @param theUnit The unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @result the reduced unit.
 */
PSUnitRef PSUnitByReducing(PSUnitRef theUnit, double *unit_multiplier);

/*!
 @function PSUnitByMultiplying
 @abstract Returns the unit obtained by multiplying two units and reducing the dimensionality numerator and denominator exponents to their lowest integer values.
 @param theUnit1 The first unit.
 @param theUnit2 The second unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @result the new unit.
 */
PSUnitRef PSUnitByMultiplying(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier, CFErrorRef *error);

/*!
 @function PSUnitByMultiplyingWithoutReducing
 @abstract Returns the unit obtained by multiplying two units.
 @param theUnit1 The first unit.
 @param theUnit2 The second unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @result the new unit.
 */
PSUnitRef PSUnitByMultiplyingWithoutReducing(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier, CFErrorRef *error);

/*!
 @function PSUnitByDividing
 @abstract Returns the unit obtained by dividing two units and reducing the dimensionality numerator and denominator exponents to their lowest integer values.
 @param theUnit1 The first unit.
 @param theUnit2 The second unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @result the new unit.
 */
PSUnitRef PSUnitByDividing(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier);

/*!
 @function PSUnitByDividingWithoutReducing
 @abstract Returns the unit obtained by dividing two units.
 @param theUnit1 The first unit.
 @param theUnit2 The second unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @result the new unit.
 */
PSUnitRef PSUnitByDividingWithoutReducing(PSUnitRef theUnit1, PSUnitRef theUnit2, double *unit_multiplier);

/*!
 @function PSUnitByRaisingToAPower
 @abstract Returns the unit obtained by raising a unit to a power and reducing the dimensionality numerator and denominator exponents to their lowest integer values.
 @param input The unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @result the new unit.
 */
PSUnitRef PSUnitByRaisingToAPower(PSUnitRef input, double power,double *unit_multiplier, CFErrorRef *error);

/*!
 @function PSUnitByRaisingToAPowerWithoutReducing
 @abstract Returns the unit obtained by raising a unit to a power.
 @param input The unit.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @param error a CFErrorRef.
 @result the new unit.
 */
PSUnitRef PSUnitByRaisingToAPowerWithoutReducing(PSUnitRef input, double power, double *unit_multiplier, CFErrorRef *error);

/*!
 @function PSUnitFindWithName
 @abstract Returns the unit with a specific name, if known.
 @param input The name.
 @result the unit or NULL if unit with name is not found.
 */
PSUnitRef PSUnitFindWithName(CFStringRef input);

/*
 @function PSUnitForUnderivedSymbol
 @abstract Returns the unit with an underived symbol, if known.
 @param input The symbol.
 @result the unit or NULL if unit with symbol is not found.
 */
PSUnitRef PSUnitForSymbol(CFStringRef symbol);

/*!
 @function PSUnitForSymbol
 @abstract Returns the unit with symbol, if valid.
 @param symbol The derived symbol.
 @param unit_multiplier pointer to a double float variable for the unit_multiplier.
 This unit_multiplier will be scaled to make the new quantity's numerical value consistent with the new unit.
 Thus, the initial value for the unit_multiplier should be non-zero.
 @param error a CFErrorRef.
 @result the unit or NULL if unit with derived symbol is not valid.
 */
PSUnitRef PSUnitByParsingSymbol(CFStringRef symbol, double *unit_multiplier, CFErrorRef *error);

/*!
 @function PSUnitCreateArrayForQuantity
 @abstract Create an array of units for quantity, if valid.
 @param quantityName The quantity.
 @result an array of units or NULL if no units for quantity are found.
 */
CFArrayRef PSUnitCreateArrayForQuantity(CFStringRef quantityName);

/*!
 @function PSUnitCreateDictionaryOfUnitsWithDimensionality
 @abstract Returns a CFDictionary with units with a given dimensionality.
 @param theDimensionality The dimensionality.
 @result a dictionary with unit symbols as keys, and unit objects as values.
 */
CFDictionaryRef PSUnitCreateDictionaryOfUnitsWithDimensionality(PSDimensionalityRef theDimensionality);

/*!
 @function PSUnitCreateDictionaryOfUnitsWithSameReducedDimensionality
 @abstract Returns a CFDictionary with units with the same reduced dimensionality.
 @param theDimensionality The dimensionality.
 @result a dictionary with unit symbols as keys, and unit objects as values.
 */
CFDictionaryRef PSUnitCreateDictionaryOfUnitsWithSameReducedDimensionality(PSDimensionalityRef theDimensionality);

/*!
 @function PSUnitConversion
 @abstract Calculates the conversion factor between units of the same dimensionality.
 @param initialUnit The initial unit.
 @param finalUnit The final value.
 @result the conversion factor.
 */
double PSUnitConversion(PSUnitRef initialUnit, PSUnitRef finalUnit);

#pragma mark Strings and Archiving
/*!
 @functiongroup Strings and Archiving
 */

/*!
 @function PSUnitShow
 @abstract Shows a short descriptor of the unit
 @param theUnit The unit.
 */
void PSUnitShow(PSUnitRef theUnit);

/*!
 @function PSUnitShowFull
 @abstract Shows a long descriptor of the unit
 @param theUnit The unit.
 */
void PSUnitShowFull(PSUnitRef theUnit);

/*!
 @function PSUnitCreateData
 @abstract Creates a CFData encoding of the unit
 @param theUnit The unit.
 @result a CFData encoding of theUnit.
 */
CFDataRef PSUnitCreateData(PSUnitRef theUnit);

/*!
 @function PSUnitWithData
 @abstract Creates a unit from a CFData encoding of the unit
 @param data the CFData with encoded unit.
 @result the unit.
 */
PSUnitRef PSUnitWithData(CFDataRef data, CFErrorRef *error);

#pragma mark Library
/*!
 @function PSUnitsLibraryImperialVolumes
 @abstract Returns a boolean indicating if library uses imperial volumes for gallon, quart, pint, fluid ounce, tablespoon, and teaspoon
 If true, the US unit symbols are appended with 'US', i.e. galUS, qtUS, ptUS, etc...
 if false, the imperial symbols are appended with 'UK', i.e. galUK, qtUK, ptUK, etc...
@result the boolean result
 */
bool PSUnitsLibraryImperialVolumes(void);

/*!
 @function PSUnitsLibrarySetImperialVolumes
 @abstract Sets the library to use imperial volumes for gallon, quart, pint, fluid ounce, tablespoon, and teaspoon
 If true, the US unit symbols are appended with 'US', i.e. galUS, qtUS, ptUS, etc...
 if false, the imperial symbols are appended with 'UK', i.e. galUK, qtUK, ptUK, etc...
 */
void PSUnitsLibrarySetImperialVolumes(bool value);

/*!
 @functiongroup Library
 */

/*
 @function PSUnitGetLibrary
 @abstract Gets a copy of the library of units
 @result a CFMutableDictionary containing the units.
 */
CFMutableDictionaryRef PSUnitGetLibrary(void);

void PSUnitSetLibrary(CFMutableDictionaryRef newUnitsLibrary);

/*
 @function PSUnitLibraryShow
 @abstract Shows a description every unit in the library
 */
void PSUnitLibraryShow(void);

/*
 @function PSUnitLibraryShowFull
 @abstract Shows a full description every unit in the library
 */
void PSUnitLibraryShowFull(void);


CFArrayRef PSUnitGetUnitsSortedByNameLength(void);

/*
 @function PSUnitCreateArrayOfRootUnits
 @abstract Creates an array of root units in alphabetical order according to root unit name.
 */
CFArrayRef PSUnitCreateArrayOfRootUnits(void);
CFArrayRef PSUnitCreateArrayOfRootUnitsForQuantityName(CFStringRef quantityName);
CFStringRef PSUnitGuessQuantityName(PSUnitRef theUnit);


