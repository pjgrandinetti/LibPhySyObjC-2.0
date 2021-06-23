//
//  PSDatasetApodizeHamming.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeHamming CFSTR("Hamming")
#define kPSDatasetApodizeHammingCutoff CFSTR("Cutoff")

CFMutableDictionaryRef PSDatasetApodizeHammingCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeHammingValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDependentVariableRef PSDatasetApodizeHammingCreateSignal(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeHammingCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeHammingGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeHammingMinimumNumberOfDimensions(void);
