//
//  PSScalarParser.h
//
//  Created by PhySy Ltd on 5/3/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

typedef const struct __scalarNode * ScalarNodeRef;
typedef const struct __scalarValue * NumberRef;
typedef const struct __scalarNodeMathFunction * ScalarNodeMathFunctionRef;
typedef const struct __scalarNodeConstantFunction * ScalarNodeConstantFunctionRef;
typedef const struct __scalarNodeSymbol * ScalarNodeSymbolRef;
typedef const struct __scalarNodeAssignment * ScalarNodeAssignmentRef;
typedef const struct __symbol * SymbolRef;


typedef enum builtInMathFunctions {
    BM_reduce = 1,
    BM_sqrt,
    BM_cbrt,
    BM_qtrt,
    BM_erf,
    BM_erfc,
    BM_exp,
    BM_ln,
    BM_log,
    BM_acos,
    BM_acosh,
    BM_asin,
    BM_asinh,
    BM_atan,
    BM_atanh,
    BM_cos,
    BM_cosh,
    BM_sin,
    BM_sinh,
    BM_tan,
    BM_tanh,
    BM_conj,
    BM_creal,
    BM_cimag,
    BM_carg,
    BM_cabs
} builtInMathFunctions;

typedef enum builtInConstantFunctions {
    BC_AW = 1,
    BC_FW,
    BC_Isotope_Abundance,
    BC_Isotope_Spin,
    BC_Isotope_HalfLife,
    BC_Isotope_Gyromag,
    BC_Isotope_MagneticDipole,
    BC_Isotope_ElectricQuadrupole,
    BC_nmr
} builtInConstantFunctions;

extern CFErrorRef scalarError;

ScalarNodeRef ScalarNodeCreateInnerNode(int nodeType, ScalarNodeRef left, ScalarNodeRef right);
ScalarNodeRef ScalarNodeCreateNumberLeaf(PSScalarRef number);
ScalarNodeRef ScalarNodeCreateMathFunction(builtInMathFunctions funcType, ScalarNodeRef left);
ScalarNodeRef ScalarNodeCreateConstantFunction(builtInConstantFunctions funcType, CFMutableStringRef string);
ScalarNodeRef NodeCreateImaginaryUnitLeaf(PSScalarRef number);
PSScalarRef ScalarNodeEvaluate(ScalarNodeRef tree, CFErrorRef *error);
PSScalarRef builtInMathFunction(ScalarNodeMathFunctionRef func, CFErrorRef *error);
PSScalarRef builtInConstantFunction(ScalarNodeConstantFunctionRef func, CFErrorRef *error);
bool ScalarNodeisLeaf(ScalarNodeRef node);
char ScalarNodeGetType(ScalarNodeRef node);
void ScalarNodeFree(ScalarNodeRef node);

PSUnitRef ConversionWithDefinedUnit(CFMutableStringRef mutString, double *unit_multiplier, CFErrorRef *error);
