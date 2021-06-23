//
//  PSDatasetApodization.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/8/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PSDatasetApodizeGaussian.h>
#import <LibPhySyObjC/PSDatasetApodizeExponential.h>
#import <LibPhySyObjC/PSDatasetApodizeStretchedExponential.h>
#import <LibPhySyObjC/PSDatasetApodizeTopHatBandPass.h>
#import <LibPhySyObjC/PSDatasetApodizeTopHatBandStop.h>
#import <LibPhySyObjC/PSDatasetApodizeSinc.h>
#import <LibPhySyObjC/PSDatasetApodizePIETA.h>
#import <LibPhySyObjC/PSDatasetApodizeDerivative.h>
#import <LibPhySyObjC/PSDatasetApodizeRamLak.h>
#import <LibPhySyObjC/PSDatasetApodizeTriangle.h>
#import <LibPhySyObjC/PSDatasetApodizeCosine.h>
#import <LibPhySyObjC/PSDatasetApodizeHamming.h>

CFArrayRef PSDatasetApodizationCreateArrayOfFunctions(void);
CFArrayRef PSDatasetApodizationCreateArrayOfFunctionNames(CFArrayRef functions);
bool PSDatasetApodizationValidateAndUpdateParametersForDataset(CFMutableArrayRef functions,
                                                               PSDatasetRef theDataset, 
                                                               CFMutableDictionaryRef parameters,
                                                               CFErrorRef *error);

