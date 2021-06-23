//
//  PSDatasetApodizeRamLak.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeRamLak CFSTR("RamLak")
#define kPSDatasetApodizeRamLakCutoff CFSTR("Cutoff")

CFMutableDictionaryRef PSDatasetApodizeRamLakCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeRamLakValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDependentVariableRef PSDatasetApodizeRamLakCreateSignal(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeRamLakCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeRamLakGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeRamLakMinimumNumberOfDimensions(void);
