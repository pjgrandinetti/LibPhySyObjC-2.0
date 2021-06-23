//
//  PSDatasetAffine.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 4/5/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetRotateAngle CFSTR("kPSDatasetRotateAngle")

CFMutableDictionaryRef PSDatasetRotateCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetRotateValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters);
PSDatasetRef PSDatasetCreateByRotating(PSDatasetRef theDataset,
                                       PSScalarRef rotateAngle,
                                       CFIndex level,
                                       CFErrorRef *error);

#define kPSDatasetShearAngle CFSTR("kPSDatasetShearAngle")

CFMutableDictionaryRef PSDatasetShearCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetShearValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters);
PSDatasetRef PSDatasetCreateByShearing(PSDatasetRef theDataset,
                                       PSScalarRef shearAngle,
                                       CFIndex level,
                                       CFErrorRef *error);

#define kPSDatasetTranslation CFSTR("kPSDatasetTranslation")
#define kPSDatasetTranslationMaximum CFSTR("kPSDatasetTranslationMaximum")

CFMutableDictionaryRef PSDatasetTranslateCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetTranslateValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters);
PSDatasetRef PSDatasetCreateByTranslating(PSDatasetRef theDataset,
                                          PSScalarRef translation,
                                          CFIndex level,
                                          CFErrorRef *error);

PSDatasetRef PSDatasetCreateByApplyingAffineTransform(PSDatasetRef theDataset,
                                                      vImage_AffineTransform_Double transform,
                                                      CFIndex level,
                                                      CFErrorRef *error);
