//
//  PSDatasetTrim.h
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 11/7/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

// Input Parameters
#define kPSDatasetTrim CFSTR("PSDatasetTrim")
#define kPSDatasetTrimSide CFSTR("PSDatasetTrimSide")
#define kPSDatasetTrimLengthPerSide CFSTR("PSDatasetTrimLengthPerSide")

typedef enum trimSide {
    kPSDatasetTrimLeftSide,
    kPSDatasetTrimRightSide,
    kPSDatasetTrimBothSides
} trimSide;

CFMutableDictionaryRef PSDatasetTrimCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetTrimValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters);

trimSide PSDatasetTrimGetSide(CFDictionaryRef parameters);
bool PSDatasetTrimSetTrimSide(CFMutableDictionaryRef parameters, trimSide side, CFErrorRef *error);
bool PSDatasetTrimSetTrimLengthPerSide(CFMutableDictionaryRef parameters, CFIndex trimLengthPerSide, CFErrorRef *error);

CFIndex PSDatasetTrimGetTrimLengthPerSide(CFDictionaryRef parameters);

PSDatasetRef PSDatasetTrimCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFErrorRef *error);

