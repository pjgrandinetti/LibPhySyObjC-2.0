//
//  PSDatasetShift.h
//  RMN 2.0
//
//  Created by Philip on 7/1/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//

// Input Parameters
#define kPSDatasetShift CFSTR("PSDatasetShift")
#define kPSDatasetShiftValue CFSTR("kPSDatasetShiftValue")
#define kPSDatasetShiftWrap CFSTR("kPSDatasetShiftWrap")
#define kPSDatasetShiftCoordinates CFSTR("kPSDatasetShiftCoordinates")

CFMutableDictionaryRef PSDatasetShiftCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetShiftValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters);
CFIndex PSDatasetShiftGetShiftValue(CFDictionaryRef parameters);
bool PSDatasetShiftGetWrap(CFDictionaryRef parameters);
void PSDatasetShiftSetShiftValue(CFMutableDictionaryRef parameters, CFIndex shiftValue);
void PSDatasetShiftSetWrap(CFMutableDictionaryRef parameters, bool wrap);

void PSDatasetShiftSetShiftCoordinates(CFMutableDictionaryRef parameters, bool shiftCoord);
bool PSDatasetShiftGetShiftCoordinates(CFDictionaryRef parameters);

void PSDatasetShiftSetToRightShift(CFMutableDictionaryRef parameters);
void PSDatasetShiftSetToLeftShift(CFMutableDictionaryRef parameters);

PSDatasetRef PSDatasetShiftCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFIndex level, CFErrorRef *error);
