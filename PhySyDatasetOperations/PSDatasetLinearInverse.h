//
//  PSDatasetLinearInverse.h
//  RMN
//
//  Created by philip on 11/25/15.
//  Copyright © 2015 PhySy. All rights reserved.
//

#ifndef PSDatasetLinearInverse_h
#define PSDatasetLinearInverse_h

// Input Parameters
#define kPSDatasetLinearInverse CFSTR("kPSDatasetLinearInverse")
#define kPSDatasetLinearInverseAlgorithm CFSTR("kPSDatasetLinearInverseAlgorithm")
#define kPSDatasetLinearInverseKernelType CFSTR("kPSDatasetLinearInverseKernelType")
#define kPSDatasetLinearInverseCoordinateMin CFSTR("kPSDatasetLinearInverseCoordinateMin")
#define kPSDatasetLinearInverseCoordinateMax CFSTR("kPSDatasetLinearInverseCoordinateMax")
#define kPSDatasetLinearInverseCoordinateQuantity CFSTR("kPSDatasetLinearInverseCoordinateQuantity")
#define kPSDatasetLinearInverseCoordinateinverseQuantityName CFSTR("kPSDatasetLinearInverseCoordinateinverseQuantityName")
#define kPSDatasetLinearInverseNumberOfSamples CFSTR("kPSDatasetLinearInverseNumberOfSamples")
#define kPSDatasetLinearInverseModelCoordinateSpacing CFSTR("kPSDatasetLinearInverseModelCoordinateSpacing")
#define kPSDatasetLinearInverseLambda CFSTR("kPSDatasetLinearInverseLambda")
#define kPSDatasetLinearInverseNoiseStandardDeviation CFSTR("kPSDatasetLinearInverseNoiseStandardDeviation")

typedef enum linearInverseAlgorithm {
    kPSDatasetLinearInverseL2NormRidgeRegression=0,
    kPSDatasetLinearInverseL2NormFirstDerivative,
    kPSDatasetLinearInverseL2NormSecondDerivative
} linearInverseAlgorithm;


typedef enum linearInverseModelCoordinateSpacing {
    kPSDatasetLogCoordinate=0,
    kPSDatasetLinearCoordinate
} linearInverseModelCoordinateSpacing;

typedef enum linearInverseKernel {
    kPSDatasetInverseLaplace1DExponential=0
} linearInverseKernel;

CFMutableDictionaryRef PSDatasetLinearInverseCreateDefaultParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);

linearInverseAlgorithm PSDatasetLinearInverseGetAlgorithm(CFDictionaryRef parameters);
void PSDatasetLinearInverseSetAlgorithm(CFMutableDictionaryRef parameters, linearInverseAlgorithm algorithm);

linearInverseModelCoordinateSpacing PSDatasetLinearInverseGetCoordinateSpacing(CFDictionaryRef parameters);
void PSDatasetLinearInverseSetCoordinateSpacing(CFMutableDictionaryRef parameters, linearInverseModelCoordinateSpacing coordinateType);

linearInverseKernel PSDatasetLinearInverseGetKernelType(CFDictionaryRef parameters);
void PSDatasetLinearInverseSetKernelType(CFMutableDictionaryRef parameters, linearInverseKernel kernel);

PSScalarRef PSDatasetLinearInverseGetNoiseStandardDeviation(CFDictionaryRef parameters);
bool PSDatasetLinearInverseSetNoiseStandardDeviation(CFMutableDictionaryRef parameters, PSScalarRef noise);

PSScalarRef PSDatasetLinearInverseGetLambda(CFDictionaryRef parameters);
bool PSDatasetLinearInverseSetLambda(CFMutableDictionaryRef parameters, PSScalarRef lambda);

PSScalarRef PSDatasetLinearInverseGetMinimumCoordinate(CFDictionaryRef parameters);
bool PSDatasetLinearInverseSetMinimumCoordinate(CFMutableDictionaryRef parameters, PSScalarRef coordinate, PSDatasetRef theDataset);
PSScalarRef PSDatasetLinearInverseGetMaximumCoordinate(CFDictionaryRef parameters);
bool PSDatasetLinearInverseSetMaximumCoordinate(CFMutableDictionaryRef parameters, PSScalarRef coordinate, PSDatasetRef theDataset);

CFIndex PSDatasetLinearInverseGetNumberOfSamples(CFDictionaryRef parameters);
bool PSDatasetLinearInverseSetNumberOfSamples(CFMutableDictionaryRef parameters, CFIndex numberOfSamples, PSDatasetRef theDataset);

bool PSDatasetLinearInverseValidateForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters, CFErrorRef *error);

CFArrayRef PSDatasetLinearInverseCreateKernelAndSingularValuesDatasets(PSDatasetRef theDataset, CFDictionaryRef parameters,  CFErrorRef *error);

CFArrayRef PSDatasetLinearInverseCreateDatasetFromDataset(PSDatasetRef theDataset, CFDictionaryRef parameters,  CFErrorRef *error);


#endif /* PSDatasetLinearInverse_h */
