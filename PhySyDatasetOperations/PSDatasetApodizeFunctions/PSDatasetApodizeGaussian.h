//
//  PSDatasetApodizeGaussian.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeGaussian CFSTR("Gaussian")
#define kPSDatasetApodizeGaussianStandardDeviation CFSTR("Standard Deviation")

CFMutableDictionaryRef PSDatasetApodizeGaussianCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeGaussianValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeGaussianCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeGaussianGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeGaussianMinimumNumberOfDimensions(void);
