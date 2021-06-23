//
//  PSSignalBaselineCorrect.h
//  PSSignal
//
//  Created by Grandinetti Philip on 10/23/11.
//  Copyright (c) 2011 Philip J. Grandinetti. All rights reserved.
//

#ifndef PSSignal_PSSignalBaselineCorrect_h
#define PSSignal_PSSignalBaselineCorrect_h

typedef struct __PSSignalBaselineCorrect *PSSignalBaselineCorrectRef;

typedef enum {
    kMRBaselineCorrect0D = 0,
    kMRBaselineCorrect1D = 1,
} PSSignalBaselineCorrectType;

PSSignalBaselineCorrectRef PSSignalBaselineCorrectCreateWithFunctionTypeAndLimits(PSSignalBaselineCorrectType correctionType,
                                                                                  CFDataRef lowerLimits,
                                                                                  CFDataRef upperLimits,
                                                                                  PSSignalRef theSignal);

void PSSignalBaselineCorrectFinalize(PSSignalBaselineCorrectRef operation);

PSSignalRef PSSignalBaselineCorrectCreateSignalFromSignal(PSSignalBaselineCorrectRef operation, PSSignalRef input, CFErrorRef *error);

#endif
