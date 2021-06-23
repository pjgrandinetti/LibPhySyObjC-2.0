//
//  PSDatasetApodizeTriangle.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizeTriangle CFSTR("Triangle")
#define kPSDatasetApodizeTriangleCutoff CFSTR("Cutoff")

CFMutableDictionaryRef PSDatasetApodizeTriangleCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetApodizeTriangleValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDependentVariableRef PSDatasetApodizeTriangleCreateSignal(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
PSDatasetRef PSDatasetApodizeTriangleCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

CFStringRef PSDatasetApodizeTriangleGetParameterNameAtIndex(CFIndex index);
CFIndex PSDatasetApodizeTriangleMinimumNumberOfDimensions(void);
