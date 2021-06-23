//
//  PSDatasetApodizeSinc.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeSinc CFSTR("Sinc")
#define kPSDatasetApodizeSincBandWidth CFSTR("BandWidth")

CFMutableDictionaryRef PSDatasetApodizeSincCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeSincValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDependentVariableRef PSDatasetApodizeSincCreateSignal(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeSincCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeSincGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeSincMinimumNumberOfDimensions(void);
