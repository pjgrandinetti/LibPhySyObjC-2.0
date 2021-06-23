//
//  PSDatasetScaleDimension.h
//  RMN 2.0
//
//  Created by Philip on 7/1/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//

#define kPSDatasetHorizontalScale CFSTR("kPSDatasetHorizontalScale")
#define kPSDatasetVerticalScale CFSTR("kPSDatasetVerticalScale")
CFMutableDictionaryRef PSDatasetScaleCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetScaleValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters);
PSDatasetRef PSDatasetCreateByScalingDimension(PSDatasetRef theDataset, CFMutableDictionaryRef parameters, CFErrorRef *error);


