//
//  PSDatasetApodizeExponential.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeExponential CFSTR("Exponential")
#define kPSDatasetApodizeExponentialFullWidthHalfMaximum CFSTR("full width at half maximum")

CFMutableDictionaryRef PSDatasetApodizeExponentialCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeExponentialValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDependentVariableRef PSDatasetApodizeExponentialCreateSignal(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeExponentialCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);
CFStringRef PSDatasetApodizeExponentialGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeExponentialMinimumNumberOfDimensions(void);
