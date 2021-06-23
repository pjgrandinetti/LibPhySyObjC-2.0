//
//  PSScalarParser.c
//
//  Created by PhySy Ltd on 5/3/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "PhySyFoundation.h"

struct __symbol {
    char *name;
    PSScalarRef value;
} __symbol;

#define NHASH 9997
struct __symbol symbolTable[NHASH];

struct __scalarNode {
    int nodeType;
    ScalarNodeRef left;
    ScalarNodeRef right;
}  __scalarNode;

struct __scalarValue {
    int nodeType;
    PSScalarRef number;
} __scalarValue;

struct __scalarNodeMathFunction {
    int nodeType;
    ScalarNodeRef left;
    builtInMathFunctions funcType;
} __scalarNodeMathFunction;

struct __scalarNodeConstantFunction {
    int nodeType;
    builtInConstantFunctions funcType;
    CFMutableStringRef string;
} __scalarNodeConstantFunction;


PSScalarRef ScalarNodeEvaluate(ScalarNodeRef node, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    switch(node->nodeType) {
        case 'K': {
            NumberRef leaf = (NumberRef) node;
            return leaf->number;
        }
        case '+': {
            PSScalarRef left = ScalarNodeEvaluate(node->left, error);
            if(error) if(*error) return NULL;
            PSScalarRef right = ScalarNodeEvaluate(node->right, error);
            if(error) if(*error) return NULL;
            PSScalarRef temp = PSScalarCreateByAdding(left, right, error);
            if(error) if(*error) return NULL;
            if(temp) return temp;
            return NULL;
        }
        case '-': {
            PSScalarRef left = ScalarNodeEvaluate(node->left,error);
            if(error) if(*error) return NULL;
            PSScalarRef right = ScalarNodeEvaluate(node->right,error);
            if(error) if(*error) return NULL;
            PSScalarRef temp = PSScalarCreateBySubtracting(left, right, error);
            if(error) if(*error) return NULL;
            if(temp) return temp;
            return NULL;
        }
        case '*': {
            PSScalarRef left = ScalarNodeEvaluate(node->left,error);
            if(error) if(*error) return NULL;
            PSScalarRef right = ScalarNodeEvaluate(node->right,error);
            if(error) if(*error) return NULL;
            PSScalarRef temp = PSScalarCreateByMultiplyingWithoutReducingUnit(left, right, error);
            if(temp) return temp;
            return NULL;
        }
        case '/': {
            PSScalarRef left = ScalarNodeEvaluate(node->left,error);
            if(error) if(*error) return NULL;
            PSScalarRef right = ScalarNodeEvaluate(node->right,error);
            if(error) if(*error) return NULL;
            PSScalarRef temp = PSScalarCreateByDividingWithoutReducingUnit(left, right, error);
            if(temp) return temp;
            return NULL;
        }
        case '!': {
            PSScalarRef left = ScalarNodeEvaluate(node->left,error);
            if(error) if(*error) return NULL;
            PSScalarRef temp = PSScalarCreateByGammaFunctionWithoutReducingUnit(left, error);
            if(temp) return temp;
            return NULL;
        }
        case '^': {
            PSScalarRef left = ScalarNodeEvaluate(node->left,error);
            if(error) if(*error) return NULL;
            PSScalarRef right = ScalarNodeEvaluate(node->right,error);
            if(error) if(*error) return NULL;
            if(PSUnitIsDimensionless(PSQuantityGetUnit((PSQuantityRef) right))) {
                PSScalarReduceUnit((PSMutableScalarRef) right);
                double complex power = PSScalarDoubleComplexValue(right);
                PSUnitRef argumentUnit = PSQuantityGetUnit((PSQuantityRef) left);
                if(PSUnitIsDimensionless(argumentUnit) && PSUnitGetScaleNonSIToCoherentSI(argumentUnit) == 1.0) {
                    PSScalarReduceUnit((PSMutableScalarRef) left);
                    double complex x = PSScalarDoubleComplexValue(left);
                    if(cimag(power) == 0 && power == floor(creal(power))) {
                        double complex result = raise_to_integer_power(x,  (long) creal(power));
                        if(isnan(result)) {
                            if(error) {
                                CFStringRef desc = CFSTR("Overflow.");
                                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
                            }
                            
                            return NULL;
                        }
                        return PSScalarCreateWithDoubleComplex(result, NULL);
                    }
                    else {
                        double complex result = cpow(x, power);
                        if(isnan(result)) {
                            if(error) {
                                CFStringRef desc = CFSTR("Overflow.");
                                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
                            }
                            
                            return NULL;
                        }
                        return PSScalarCreateWithDoubleComplex(result, NULL);
                    }
                }
                else {
                    if(PSScalarIsReal(right)) {
                        return  PSScalarCreateByRaisingToAPowerWithoutReducingUnit(left, power, error);
                    }
                    else {
                        if(error) {
                            CFStringRef desc = CFSTR("Powers must be real.");
                            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
                        }
                        return NULL;

                    }
                }
            }
            if(error) {
                CFStringRef desc = CFSTR("Powers must be dimensionless.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            return NULL;
        }
        case '|': {
            PSScalarRef left = ScalarNodeEvaluate(node->left,error);
            if(error) if(*error) return NULL;
            return PSScalarCreateByTakingComplexPart(left, kPSMagnitudePart);
        }
        case 'M': {
            PSScalarRef left = ScalarNodeEvaluate(node->left,error);
            if(error) if(*error) return NULL;
            return PSScalarCreateByMultiplyingByDimensionlessRealConstant(left, -1.);
        }
        case 'F': {
            PSScalarRef result = builtInMathFunction((ScalarNodeMathFunctionRef) node, error);
            if(error) if(*error) return NULL;
            return result;
        }
        case 'C': {
            PSScalarRef result = builtInConstantFunction((ScalarNodeConstantFunctionRef) node, error);
            if(error) if(*error) return NULL;
            return result;
        }
        default:
            return NULL;
    }
    return 0;
}

ScalarNodeRef ScalarNodeCreateInnerNode(int nodeType, ScalarNodeRef left, ScalarNodeRef right)
{
    struct __scalarNode *node = malloc(sizeof(struct __scalarNode));
    node->nodeType = nodeType;
    node->left = left;
    node->right = right;
    return node;
}

ScalarNodeRef ScalarNodeCreateMathFunction(builtInMathFunctions funcType, ScalarNodeRef left)
{
    struct __scalarNodeMathFunction *node = malloc(sizeof(struct __scalarNodeMathFunction));
    node->nodeType = 'F';
    node->left = left;
    node->funcType = funcType;
    return (ScalarNodeRef) node;
}

ScalarNodeRef ScalarNodeCreateConstantFunction(builtInConstantFunctions funcType, CFMutableStringRef string)
{
    struct __scalarNodeConstantFunction *node = malloc(sizeof(struct __scalarNodeConstantFunction));
    node->nodeType = 'C';
    node->string = string;
    node->funcType = funcType;
    return (ScalarNodeRef) node;
}

ScalarNodeRef ScalarNodeCreateNumberLeaf(PSScalarRef number)
{
    struct __scalarValue *leaf = malloc(sizeof(struct __scalarValue));
    leaf->nodeType = 'K';
    leaf->number = number;
    return (ScalarNodeRef) leaf;
}

char ScalarNodeGetType(ScalarNodeRef node)
{
    return node->nodeType;
}

bool ScalarNodeisLeaf(ScalarNodeRef node)
{
    return (node->nodeType =='K');
}

void ScalarNodeFree(ScalarNodeRef node)
{
    if(node==NULL) return;
    
    switch(node->nodeType) {
        case '+':
        case '-':
        case '*':
        case '/':
        case '^':
            ScalarNodeFree(node->right);
        case '|':
        case 'M':
        case 'F':
        case '!':
            ScalarNodeFree(node->left);
            break;
        case 'K': {
            struct __scalarValue *leaf = (struct __scalarValue *) node;
            CFRelease(leaf->number);
            free((void *) node);
        }
    }
}

PSScalarRef builtInConstantFunction(ScalarNodeConstantFunctionRef func, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    builtInConstantFunctions funcType = func->funcType;
    
    // Remove square brackets
    CFRange range;
    range.location = CFStringGetLength(func->string)-1;
    range.length = 1;
    CFStringDelete (func->string, range);
    range.location = 0;
    range.length = 1;
    CFStringDelete (func->string, range);
    
    switch (funcType) {
        case BC_AW: {
            return PSPeriodicTableCreateMolarMass(func->string, error);
            break;
        }
        case BC_FW: {
            return PSPeriodicTableCreateFormulaMass(func->string, error);
            break;
        }
        case BC_Isotope_Abundance:
            return PSPeriodicTableCreateIsotopeAbundance(func->string, error);
            break;
        case BC_Isotope_Spin:
            return PSPeriodicTableCreateIsotopeSpin(func->string, error);
            break;
        case BC_Isotope_HalfLife:
            return PSPeriodicTableCreateIsotopeHalfLife(func->string, error);
            break;
        case BC_Isotope_Gyromag:
            return PSPeriodicTableCreateIsotopeGyromagneticRatio(func->string, error);
            break;
        case BC_Isotope_MagneticDipole:
            return PSPeriodicTableCreateIsotopeMagneticDipoleMoment(func->string, error);
            break;
        case BC_Isotope_ElectricQuadrupole:
            return PSPeriodicTableCreateIsotopeElectricQuadrupoleMoment(func->string, error);
            break;
        case BC_nmr:
            return PSPeriodicTableCreateNMRFrequency(func->string, error);
            break;
        default:
            return NULL;
    }
    return NULL;
}

PSScalarRef builtInMathFunction(ScalarNodeMathFunctionRef func, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    builtInMathFunctions funcType = func->funcType;
    PSScalarRef scalar = ScalarNodeEvaluate(func->left,error);
    if(NULL==scalar) return NULL;
    
    switch(funcType) {
        case BM_reduce: {
            return PSScalarCreateByReducingUnit(scalar);
        }
        case BM_sqrt: {
            return PSScalarCreateByTakingNthRoot(scalar,2,error);
        }
        case BM_cbrt: {
            return PSScalarCreateByTakingNthRoot(scalar,3,error);
        }
        case BM_qtrt: {
            return PSScalarCreateByTakingNthRoot(scalar,4,error);
        }
        case BM_exp: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = cexp(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("exp requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
                
            }
            return NULL;
        }
        case BM_erf: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                if(!PSScalarIsComplex(scalar)) {
                    PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                    double complex value = erf(PSScalarDoubleValue(scalar));
                    return PSScalarCreateWithDoubleComplex(value, NULL);
                }
            }
            if(error) {
                CFStringRef desc = CFSTR("erf requires dimensionless real quantity.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
                
            }
            return NULL;
        }
        case BM_erfc: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                if(!PSScalarIsComplex(scalar)) {
                    PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                    double complex value = erfc(PSScalarDoubleValue(scalar));
                    return PSScalarCreateWithDoubleComplex(value, NULL);
                }
            }
            if(error) {
                CFStringRef desc = CFSTR("erfc requires dimensionless real quantity.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
                
            }
            return NULL;
        }
        case BM_ln: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = clog(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("ln requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_log: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = clog(PSScalarDoubleComplexValue(scalar))/log(10);
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("ln requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_acos: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = cacos(PSScalarDoubleComplexValue(scalar));
                PSUnitRef unit = PSUnitForSymbol(CFSTR("rad"));
                return PSScalarCreateWithDoubleComplex(value, unit);
            }
            if(error) {
                CFStringRef desc = CFSTR("acos requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
                
                return NULL;
            }
        case BM_acosh: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = cacosh(PSScalarDoubleComplexValue(scalar));
                PSUnitRef unit = PSUnitForSymbol(CFSTR("rad"));
                return PSScalarCreateWithDoubleComplex(value, unit);
            }
            if(error) {
                CFStringRef desc = CFSTR("acosh requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_asin: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = casin(PSScalarDoubleComplexValue(scalar));
                PSUnitRef unit = PSUnitForSymbol(CFSTR("rad"));
                return PSScalarCreateWithDoubleComplex(value, unit);
            }
            if(error) {
                CFStringRef desc = CFSTR("asin requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_asinh: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                PSUnitRef unit = PSUnitForSymbol(CFSTR("rad"));
                double complex value = casinh(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, unit);
            }
            if(error) {
                CFStringRef desc = CFSTR("asinh requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_atan: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                PSUnitRef unit = PSUnitForSymbol(CFSTR("rad"));
                double complex value = catan(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, unit);
            }
            if(error) {
                CFStringRef desc = CFSTR("atan requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_atanh: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                PSUnitRef unit = PSUnitForSymbol(CFSTR("rad"));
                double complex value = catanh(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, unit);
            }
            if(error) {
                CFStringRef desc = CFSTR("atanh requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_cos: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = complex_cosine(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("cos requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_cosh: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = ccosh(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("cosh requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_sin: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = complex_sine(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("sin requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_sinh: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = csinh(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("sinh requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_tan: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = complex_tangent(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("tan requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_tanh: {
            if(PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) scalar))) {
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, error);
                double complex value = ctanh(PSScalarDoubleComplexValue(scalar));
                return PSScalarCreateWithDoubleComplex(value, NULL);
            }
            if(error) {
                CFStringRef desc = CFSTR("tanh requires dimensionless unit.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }
            
            return NULL;
        }
        case BM_conj:
            return PSScalarCreateByConjugation(scalar);
        case BM_creal:
            return PSScalarCreateByTakingComplexPart(scalar,kPSRealPart);
        case BM_cimag:
            return PSScalarCreateByTakingComplexPart(scalar,kPSImaginaryPart);
        case BM_carg:
            return PSScalarCreateByTakingComplexPart(scalar,kPSArgumentPart);
        case BM_cabs:
            return PSScalarCreateByTakingComplexPart(scalar,kPSMagnitudePart);
        default:
            if(error) {
                CFStringRef desc = CFSTR("unknown function.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,kPSFoundationErrorDomain,0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,(const void* const*)&desc,1);
            }

            return NULL;
        }
    }
}

PSUnitRef ConversionWithDefinedUnit(CFMutableStringRef mutString, double *unit_multiplier, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    // Remove appended unit conversion
    CFArrayRef conversions = CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault,mutString,CFSTR(".."));
    if(conversions) {
        if(CFArrayGetCount(conversions) == 2) {
            CFStringRef firstString = CFArrayGetValueAtIndex(conversions, 0);
            CFStringRef secondString = CFArrayGetValueAtIndex(conversions, 1);
            if(CFStringGetLength(firstString)==0 || CFStringGetLength(secondString)==0) {
                CFRelease(conversions);
                return NULL;
            }
            PSUnitRef finalUnit = PSUnitByParsingSymbol(secondString, unit_multiplier, error);
            if(finalUnit) {
                CFStringReplaceAll(mutString, firstString);
                CFRelease(conversions);
                return finalUnit;
            }
        }
        CFRelease(conversions);
    }
    return NULL;
}

