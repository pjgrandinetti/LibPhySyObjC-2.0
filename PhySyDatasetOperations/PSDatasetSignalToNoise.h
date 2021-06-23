//
//  PSDatasetSignalToNoise.h
//  LibPhySy
//
//  Created by Philip J. Grandinetti on 3/5/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#ifndef PSDatasetSignalToNoise_h
#define PSDatasetSignalToNoise_h

// Input Parameters
#define kPSDatasetSignalToNoiseLowerNoiseLimits CFSTR("kPSDatasetSignalToNoiseLowerNoiseLimits")
#define kPSDatasetSignalToNoiseUpperNoiseLimits CFSTR("kPSDatasetSignalToNoiseUpperNoiseLimits")
#define kPSDatasetSignalToNoiseLowerSignalLimits CFSTR("kPSDatasetSignalToNoiseLowerSignalLimits")
#define kPSDatasetSignalToNoiseUpperSignalLimits CFSTR("kPSDatasetSignalToNoiseUpperSignalLimits")

// Output Results
#define kPSDatasetSignalToNoiseNoiseMean CFSTR("kPSDatasetSignalToNoiseNoiseMean")
#define kPSDatasetSignalToNoiseNoiseStandardDeviation CFSTR("kPSDatasetSignalToNoiseNoiseStandardDeviation")
#define kPSDatasetSignalToNoiseNoiseSkewness CFSTR("kPSDatasetSignalToNoiseNoiseSkewness")
#define kPSDatasetSignalToNoiseNoiseKurtosis CFSTR("kPSDatasetSignalToNoiseNoiseKurtosis")
#define kPSDatasetSignalToNoiseResponseMax CFSTR("kPSDatasetSignalToNoiseResponseMax")
#define kPSDatasetSignalToNoiseResponseMin CFSTR("kPSDatasetSignalToNoiseResponseMin")
#define kPSDatasetSignalToNoiseSignalMaxToNoise CFSTR("kPSDatasetSignalToNoiseSignalMaxToNoise")
#define kPSDatasetSignalToNoiseSignalMinToNoise CFSTR("kPSDatasetSignalToNoiseSignalMinToNoise")

CFDictionaryRef PSDatasetSignalToNoiseCreateResultsForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters, CFErrorRef *error);
CFMutableDictionaryRef PSDatasetSignalToNoiseCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetSignalToNoiseValidateParametersForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters);


#endif
