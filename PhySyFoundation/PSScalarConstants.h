//
//  PSScalarConstants
//
//  Created by PhySy Ltd on 5/5/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSScalarConstants
 
 @copyright PhySy Ltd
 @unsorted
 */

#ifndef PSScalarConstants_h
#define PSScalarConstants_h

/*!
 @function PSPeriodicTableCreateElementSymbols
 @abstract Returns an array with the element symbols
 @result an integer.
 */
CFArrayRef PSPeriodicTableCreateElementSymbols(CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeSymbols
 @abstract Returns an array with the isotope symbols
 @result an integer.
 */
CFArrayRef PSPeriodicTableCreateIsotopeSymbols(CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateStableIsotopeSymbols
 @abstract Returns an array with the NMR active isotope symbols
 @result an integer.
 */
CFArrayRef PSPeriodicTableCreateStableIsotopeSymbols(CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateNMRActiveIsotopeSymbols
 @abstract Returns an array with the NMR active isotope symbols
 @result an integer.
 */
CFArrayRef PSPeriodicTableCreateNMRActiveIsotopeSymbols(CFErrorRef *error);

/*!
 @function PSPeriodicTableGetStableNMRActiveIsotopeSymbols
 @abstract Returns an array with the stable NMR active isotope symbols
 @result an integer.
 */
CFArrayRef PSPeriodicTableCreateStableNMRActiveIsotopeSymbols(CFErrorRef *error);

/*!
 @function PSPeriodicTableGetAtomicNumber
 @abstract Returns the atomic number of an element
 @param elementSymbol a CFString containing the element symbol.
 @result an integer.
 */
CFIndex PSPeriodicTableGetAtomicNumber(CFStringRef elementSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateMolarMass
 @abstract Creates a scalar with the molar mass of an element
 @param elementSymbol a CFString containing the element symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateMolarMass(CFStringRef elementSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeStable
 @abstract Creates a bool for whether isotope is stable or not.
 @param isotopeSymbol  a CFString containing the isotope symbol.
 @result a bool.
 */
bool PSPeriodicTableCreateIsotopeStable(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeMagneticDipoleMoment
 @abstract Creates a scalar with the magnetic dipole moment of an isotope
 @param isotopeSymbol  a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateIsotopeMagneticDipoleMoment(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeElectricQuadrupoleMoment
 @abstract Creates a scalar with the electric quadrupole moment of an isotope
 @param isotopeSymbol  a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateIsotopeElectricQuadrupoleMoment(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeGyromagneticRatio
 @abstract Creates a scalar with the gyromagnetic ratio of an isotope
 @param isotopeSymbol  a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateIsotopeGyromagneticRatio(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeAbundance
 @abstract Creates a scalar with the natural abundance of an isotope
 @param isotopeSymbol a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateIsotopeAbundance(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeLifetime
 @abstract Creates a scalar with the lifetime of an isotope
 @param isotopeSymbol a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateIsotopeLifetime(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeHalfLife
 @abstract Creates a scalar with the half life of an isotope
 @param isotopeSymbol a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateIsotopeHalfLife(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateIsotopeSpin
 @abstract Creates a scalar with the nuclear spin of an isotope
 @param isotopeSymbol a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateIsotopeSpin(CFStringRef isotopeSymbol, CFErrorRef *error);

/*!
 @function PSPeriodicTableCreateNMRFrequency
 @abstract Creates a scalar with the NMR frequency/magnetic flux density of an isotope
 @param isotopeSymbol a CFString containing the isotope symbol.
 @result a scalar.
 */
PSScalarRef PSPeriodicTableCreateNMRFrequency(CFStringRef isotopeSymbol, CFErrorRef *error);

PSScalarRef PSPeriodicTableCreateFormulaMass(CFStringRef formula, CFErrorRef *error);


#endif
