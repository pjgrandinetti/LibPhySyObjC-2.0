//
//  PSDatasetApodizeTopHatBandStop.h
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeTopHatBandStop CFSTR("Top Hat BandStop")
#define kPSDatasetApodizeTopHatBandStopRisingEdge CFSTR("Rising Edge")
#define kPSDatasetApodizeTopHatBandStopFallingEdge CFSTR("Falling Edge")

CFMutableDictionaryRef PSDatasetApodizeTopHatBandStopCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeTopHatBandStopValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeTopHatBandStopCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeTopHatBandStopGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeTopHatBandStopMinimumNumberOfDimensions(void);

