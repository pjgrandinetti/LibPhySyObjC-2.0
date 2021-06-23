//
//  PSDatasetResponseOffsetAdjust.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 4/2/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#ifndef PSDatasetResponseOffsetAdjust_h
#define PSDatasetResponseOffsetAdjust_h

// Input Parameters
#define kPSDatasetResponseOffsetAdjustLowerBaselineLimits CFSTR("kPSDatasetResponseOffsetAdjustLowerBaselineLimits")
#define kPSDatasetResponseOffsetAdjustUpperBaselineLimits CFSTR("kPSDatasetResponseOffsetAdjustUpperBaselineLimits")
#define kPSDatasetResponseOffsetAdjustActiveDimensions CFSTR("kPSDatasetResponseOffsetAdjustActiveDimensions")

CFMutableDictionaryRef PSDatasetResponseOffsetAdjustCreateDefaultParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetResponseOffsetAdjustValidateParametersForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters);
PSDatasetRef PSDatasetCreateByCorrectingBaseline(CFDictionaryRef parameters, PSDatasetRef theDataset, CFErrorRef *error);

#endif
