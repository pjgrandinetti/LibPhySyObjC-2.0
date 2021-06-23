//
//  PSDatasetImportIFF.h
//  RMN
//
//  Created by philip on 5/18/14.
//  Copyright (c) 2014 PhySy. All rights reserved.
//

PSDatasetRef PSDatasetImportIFFCreateSignalWithData(CFDataRef contents, CFErrorRef *error);
CFDataRef PSDatasetCreateWaveDataWithDataset(PSDatasetRef theDataset, CFErrorRef *error);
