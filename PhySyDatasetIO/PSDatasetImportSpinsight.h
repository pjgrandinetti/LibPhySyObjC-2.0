//
//  PSDatasetImportSpinsight.h
//  physy
//
//  Created by Philip on 6/29/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//


//bool PSDatasetImportSpinSightIsValidURL(CFURLRef folderURL);
//CFIndex PSDatasetImportSpinSightNumberOfDimensionsForURL(CFURLRef folderURL);
//PSDatasetRef PSDatasetImportSpinSightCreateSignalAtFolderURL(CFURLRef folderURL, CFErrorRef *error);
PSDatasetRef PSDatasetImportSpinSightCreateSignalWithFolderData(CFDataRef dataData,
                                                                CFDataRef acqData,
                                                                CFDataRef acq2Data,
                                                                CFDataRef procData,
                                                                CFDataRef proc_setupData,
                                                                CFDataRef apndData,
                                                                CFErrorRef *error);
