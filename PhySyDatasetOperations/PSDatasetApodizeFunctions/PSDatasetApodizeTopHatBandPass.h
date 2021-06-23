//
//  PSDatasetApodizeTopHatBandPass.h
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeTopHatBandPass CFSTR("Top Hat Bandpass")
#define kPSDatasetApodizeTopHatBandPassRisingEdge CFSTR("Rising Edge")
#define kPSDatasetApodizeTopHatBandPassFallingEdge CFSTR("Falling Edge")

CFMutableDictionaryRef PSDatasetApodizeTopHatBandPassCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeTopHatBandPassValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeTopHatBandPassCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeTopHatBandPassGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeTopHatBandPassMinimumNumberOfDimensions(void);

