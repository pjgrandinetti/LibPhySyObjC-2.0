//
//  PSDatasetAddNoise.h
//  PSDataset
//
//  Created by Philip J. Grandinetti on 10/22/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#ifndef PSDatasetAddNoise_h
#define PSDatasetAddNoise_h

PSDatasetRef PSDatasetCreateByAddingNoise(PSDatasetRef theDataset,
                                          PSScalarRef noise,
                                          CFIndex level,
                                          CFErrorRef *error);
bool PSDatasetAddNoiseValidateForDataset(PSScalarRef noise, PSDatasetRef theDataset);

#endif
