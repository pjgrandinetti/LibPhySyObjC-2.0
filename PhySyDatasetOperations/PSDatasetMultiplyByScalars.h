//
//  PSDatasetMultiplyByScalars.h
//  LibPhySy
//
//  Created by Philip J. Grandinetti on 3/6/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#ifndef PSDatasetMultiplyByScalars_h
#define PSDatasetMultiplyByScalars_h

// Input Parameters
#define kPSDatasetMultiplyByScalarsDimensionMultipliers CFSTR("kPSDatasetMultiplyByScalarsDimensionMultipliers")
#define kPSDatasetMultiplyByScalarsResponseMultiplier CFSTR("kPSDatasetMultiplyByScalarsResponseMultiplier")

CFMutableDictionaryRef PSDatasetMultiplyByScalarsCreateDefaultParametersForDataset(PSDatasetRef theDataset);
bool PSDatasetMultiplyByScalarsValidateParametersForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters);
PSDatasetRef PSDatasetCreateByMultiplyingByScalars(PSDatasetRef theDataset, CFDictionaryRef parameters, CFErrorRef *error);

#endif
