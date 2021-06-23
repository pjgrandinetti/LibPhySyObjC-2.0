//
//  PSDatasetImportBruker.h
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/14/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

bool PSDatasetImportBrukerIsValidURL(CFURLRef url);
CFIndex PSDatasetImportBrukerNumberOfDimensionsForURL(CFURLRef url);
CFDictionaryRef PSDatasetImportBrukerCreateDictionaryWithJCAMPFile(CFURLRef url);
PSDatasetRef PSDatasetImportBrukerCreateSignalAtURL(CFURLRef folderURL, CFErrorRef *error);
PSDatasetRef PSDatasetImportBrukerCreateSignalWithFolderData(CFDataRef fidData,
                                                             CFDataRef serData,
                                                             CFArrayRef acqusArray,
                                                             CFDataRef acqpData,
                                                             CFDataRef specParData,
                                                             CFDataRef shimvaluesData,
                                                             CFDataRef vdlistData,
                                                             CFErrorRef *error);
