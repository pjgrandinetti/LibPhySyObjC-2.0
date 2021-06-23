//
//  PSDatasetApodizeDerivative.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 11/3/15.
//  Copyright (c) 2015 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeDerivative CFSTR("Derivative Convolution")
#define kPSDatasetApodizeDerivativeCutoff CFSTR("Cutoff")

CFIndex PSDatasetApodizeDerivativeMinimumNumberOfDimensions(void);
CFMutableDictionaryRef PSDatasetApodizeDerivativeCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeDerivativeValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeDerivativeCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);


