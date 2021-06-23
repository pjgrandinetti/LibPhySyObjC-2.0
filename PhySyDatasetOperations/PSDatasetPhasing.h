//
//  PSDatasetPhase.h
//  PSDataset
//
//  Created by Philip J. Grandinetti on 10/23/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

// Input Parameters
#define kPSDatasetPhasing CFSTR("PSDatasetPhasing")
#define kPSDatasetPhasingPhase CFSTR("kPSDatasetPhasingPhase")
#define kPSDatasetPhasingShift CFSTR("kPSDatasetPhasingShift")
#define kPSDatasetPhasingShear CFSTR("kPSDatasetPhasingShear")

CFMutableDictionaryRef PSDatasetPhasingCreateDefaultParameters(PSDatasetRef theDataset, CFErrorRef *error);
bool PSDatasetPhasingValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters, CFErrorRef *error);
PSScalarRef PSDatasetPhasingGetPhase(CFDictionaryRef parameters);
bool PSDatasetPhasingSetPhase(CFMutableDictionaryRef parameters, PSScalarRef phase, PSDatasetRef theDataset);
PSScalarRef PSDatasetPhasingGetShift(CFDictionaryRef parameters);
bool PSDatasetPhasingSetShift(CFMutableDictionaryRef parameters, PSScalarRef shift, PSDatasetRef theDataset);
PSScalarRef PSDatasetPhasingGetShear(CFDictionaryRef parameters);
bool PSDatasetPhasingSetShear(CFMutableDictionaryRef parameters, PSScalarRef shear, PSDatasetRef theDataset);


CFMutableDictionaryRef PSDatasetPhasingCreateWithPhase(PSScalarRef phase, PSDatasetRef theDataset, CFErrorRef *error);
CFMutableDictionaryRef PSDatasetPhasingCreateWithShift(PSScalarRef shift, PSDatasetRef theDataset, CFErrorRef *error);
CFMutableDictionaryRef PSDatasetPhasingCreateWithShear(PSScalarRef shear, PSDatasetRef theDataset, CFErrorRef *error);
CFMutableDictionaryRef PSDatasetPhasingCreateWithPhaseAndShift(PSScalarRef phase, PSScalarRef shift, PSDatasetRef theDataset, CFErrorRef *error);
CFMutableDictionaryRef PSDatasetPhasingCreateWithPhaseShiftAndShear(PSScalarRef phase, PSScalarRef shift,PSScalarRef shear, PSDatasetRef theDataset, CFErrorRef *error);

bool PSDatasetPhasingSetPhaseWithShiftAndPivot(CFMutableDictionaryRef parameters,
                                               PSScalarRef shift,
                                               PSScalarRef pivotCoordinate,
                                               PSScalarRef pivotCoordinatePhase,
                                               PSDatasetRef theDataset,
                                               CFErrorRef *error);

PSScalarRef PSDatasetPhasingCreatePhaseAtHorizontalCoordinate(CFDictionaryRef parameters, PSScalarRef horizontalCoordinate, CFErrorRef *error);
PSDatasetRef PSDatasetPhasingCreateDatasetByAutoPhasingOrigin(PSDatasetRef theDataset,
                                                              PSScalarRef *phase,
                                                              CFIndex level,
                                                              CFErrorRef *error);
PSDatasetRef PSDatasetPhasingCreateDatasetByAutoPhasingFocus(PSDatasetRef theDataset,
                                                             PSScalarRef *phase,
                                                             CFIndex level,
                                                             CFErrorRef *error);

/*!
 @function PSDatasetPhasingCreateDatasetFromDataset
 @abstract Creates a PSDataset by phase adjusting the dependentVariable components in the dataset focus.
 @param parameters a dictionary of parameters for this method.
 @param input the input PSDataset containing the dependentVariable to be phase adjusted.
 @param adjustOffset a boolean flag set to true if the zero_index_coordinate should be adjusted accordingly
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result A PSDataset containing phase adjusted dependentVariable in the dataset focus.
 */
PSDatasetRef PSDatasetPhasingCreateDatasetFromDataset(CFDictionaryRef parameters,
                                                      PSDatasetRef input,
                                                      CFIndex level,
                                                      bool adjustOffset,
                                                      CFErrorRef *error);

bool PSDatasetPhaseDataset(PSDatasetRef theDataset,
                           PSScalarRef thePhase,
                           PSScalarRef theShift,
                           PSScalarRef theShear,
                           CFIndex level,
                           CFErrorRef *error);

/*!
 @function PSDatasetPhasingAutoPhaseCreateDatasetFromDataset
 @abstract Creates a PSDataset by auto-phase adjusting the dependentVariable components in the dataset focus.
 This method uses the argument values of the first cross-section along the horizontal dimension as the phase adjustments.
 @param input the input PSDataset containing the dependentVariable to be phase adjusted.
 @param error a pointer to a CFError type for reporting errors if method was unsuccessful. Can be NULL.
 @result A PSDataset containing phase adjusted dependentVariable in the dataset focus.
 */
PSDatasetRef PSDatasetPhasingAutoPhaseCreateDatasetFromDataset(PSDatasetRef input, CFErrorRef *error);
