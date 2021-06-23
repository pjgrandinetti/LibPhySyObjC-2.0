//
//  PSDatasetApodizeExponential.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeStretchedExponential CFSTR("StretchedExponential")
#define kPSDatasetApodizeStretchedExponentialDecayConstant CFSTR("decay constant")
#define kPSDatasetApodizeStretchedExponentialBeta CFSTR("beta")

CFMutableDictionaryRef PSDatasetApodizeStretchedExponentialCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeStretchedExponentialValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDependentVariableRef PSDatasetApodizeStretchedExponentialCreateSignal(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeStretchedExponentialCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeStretchedExponentialGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeStretchedExponentialMinimumNumberOfDimensions(void);
