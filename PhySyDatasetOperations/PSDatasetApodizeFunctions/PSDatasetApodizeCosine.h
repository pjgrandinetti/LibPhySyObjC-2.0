//
//  PSDatasetApodizeCosine.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeCosine CFSTR("Cosine")
#define kPSDatasetApodizeCosineCutoff CFSTR("Cutoff")

CFMutableDictionaryRef PSDatasetApodizeCosineCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeCosineValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDependentVariableRef PSDatasetApodizeCosineCreateSignal(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeCosineCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeCosineGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeCosineMinimumNumberOfDimensions(void);
