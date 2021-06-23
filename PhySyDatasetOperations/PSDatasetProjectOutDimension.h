//
//  PSDatasetProjectOutDimension.h
//  RMN 2.0
//
//  Created by Philip on 7/4/13.
//  Copyright (c) 2013 PhySy Ltd. All rights reserved.
//

#define kPSDatasetProjectOutDimension CFSTR("PSDatasetProjectOutDimension")
#define kPSDatasetProjectOutLowerLimits CFSTR("kPSDatasetProjectionOutLowerLimits")
#define kPSDatasetProjectOutUpperLimits CFSTR("kPSDatasetProjectionOutUpperLimits")
#define kPSDatasetProjectOutDimensionIndex CFSTR("kPSDatasetProjectionOutDimensionIndex")

CFMutableDictionaryRef PSDatasetProjectOutDimensionCreateDefaultParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetProjectOutDimensionValidateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters, CFErrorRef *error);
PSDatasetRef PSDatasetProjectOutDimensionCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFErrorRef *error);
void PSDatasetProjectOutDimensionSetDimensionIndex(CFMutableDictionaryRef parameters, CFIndex dimensionIndex);
CFIndex PSDatasetProjectOutDimensionGetDimensionIndex(CFMutableDictionaryRef parameters);
bool PSDatasetProjectOutDimensionSetLowerLimitForDimension(PSDatasetRef theDataset, CFMutableDictionaryRef parameters, CFIndex dimensionIndex, PSScalarRef lowerLimit);
PSScalarRef PSDatasetProjectOutDimensionGetLowerLimitForDimension(PSDatasetRef theDataset, CFDictionaryRef parameters, CFIndex dimensionIndex);
bool PSDatasetProjectOutDimensionSetUpperLimitForDimension(PSDatasetRef theDataset, CFMutableDictionaryRef parameters, CFIndex dimensionIndex, PSScalarRef upperLimit);
PSScalarRef PSDatasetProjectOutDimensionGetUpperLimitForDimension(PSDatasetRef theDataset, CFDictionaryRef parameters, CFIndex dimensionIndex);
