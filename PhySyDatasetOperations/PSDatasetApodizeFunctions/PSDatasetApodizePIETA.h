//
//  PSDatasetApodizePIETA.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizePIETA CFSTR("PIETA")
#define kPSDatasetApodizePIETAIntercept CFSTR("Vertical Index Intercept")
#define kPSDatasetApodizePIETASlope CFSTR("Vertical/Horizontal Index Slope")
#define kPSDatasetApodizePIETAOddEvenAll CFSTR("odd, even, or all")

CFMutableDictionaryRef PSDatasetApodizePIETACreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset,CFErrorRef *error);
bool PSDatasetApodizePIETAValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizePIETACreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);
CFStringRef PSDatasetApodizePIETAGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizePIETAMinimumNumberOfDimensions(void);
