//
//  PSDatasetFill.h
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 11/7/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

// Input Parameters
#define kPSDatasetFill CFSTR("PSDatasetFill")
#define kPSDatasetFillSide CFSTR("PSDatasetFillSide")
#define kPSDatasetFillLengthPerSide CFSTR("PSDatasetFillLengthPerSide")
#define kPSDatasetFillConstants CFSTR("PSDatasetFillConstants")

typedef enum fillSide {
    kPSDatasetFillLeftSide,
    kPSDatasetFillRightSide,
    kPSDatasetFillBothSides
} fillSide;

CFMutableDictionaryRef PSDatasetFillCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetFillValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters);

PSScalarRef PSDatasetFillGetFillConstantAtIndex(CFDictionaryRef parameters, CFIndex dependentVariableIndex);
bool PSDatasetFillSetFillConstant(PSDatasetRef theDataset, CFIndex dependentVariableIndex, CFMutableDictionaryRef parameters, PSScalarRef fillConstant, CFErrorRef *error);

fillSide PSDatasetFillGetSide(CFDictionaryRef parameters);
bool PSDatasetFillSetFillSide(CFMutableDictionaryRef parameters, fillSide side, CFErrorRef *error);
bool PSDatasetFillSetFillLengthPerSide(CFMutableDictionaryRef parameters, CFIndex fillLengthPerSide, CFErrorRef *error);

CFIndex PSDatasetFillGetFillLengthPerSide(CFDictionaryRef parameters);

PSDatasetRef PSDatasetFillCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFErrorRef *error);

