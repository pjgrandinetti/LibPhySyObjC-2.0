//
//  PSDatasetFourierTransform.h
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 11/7/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#include <fftw3.h>

#define kPSDatasetFT CFSTR("PSDatasetFourierTransform")
#define kPSDatasetFTPhaseCorrectBeforeFT CFSTR("kPSDatasetFTPhaseCorrectBeforeFT")
#define kPSDatasetFTPhaseCorrectAfterFT CFSTR("kPSDatasetFTPhaseCorrectAfterFT")
#define kPSDatasetFTPhaseCorrectBeforeInverseFT CFSTR("kPSDatasetFTPhaseCorrectBeforeInverseFT")
#define kPSDatasetFTPhaseCorrectAfterInverseFT CFSTR("kPSDatasetFTPhaseCorrectAfterInverseFT")
#define kPSDatasetFTPlotBackwardsAfterFT CFSTR("kPSDatasetFTPlotBackwardsAfterFT")
#define kPSDatasetFTPlotBackwardsAfterInverseFT CFSTR("kPSDatasetFTPlotBackwardsAfterInverseFT")

@interface PSDatasetFourierTransform : NSObject
{
    vDSP_DFT_Setup  fftSetup;
    vDSP_DFT_SetupD fftDSetup;
}
@end

typedef const PSDatasetFourierTransform *PSDatasetFourierTransformRef;
PSDatasetRef PSDatasetFourierTransformWestCreateSignalFromDataset(CFDictionaryRef parameters,
                                                                  PSDatasetRef input,
                                                                  CFErrorRef *error);
CFMutableDictionaryRef PSDatasetFourierTransformCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetFourierTransformValidateParameters(CFDictionaryRef parameters);
bool canFFT(CFIndex count);
