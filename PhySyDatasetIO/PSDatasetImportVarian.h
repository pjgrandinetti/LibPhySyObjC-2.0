//
//  PSDatasetImportVarian.h
//  PSDataset
//
//  Created by Philip J. Grandinetti on 10/23/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

//bool PSDatasetImportVarianIsValidURL(CFURLRef url);
//CFIndex PSDatasetImportVarianNumberOfDimensionsForURL(CFURLRef url);
PSDatasetRef PSDatasetImportVarianCreateSignalWithFolderData(CFDataRef fidData,
                                                             CFDataRef logData,
                                                             CFDataRef procparData,
                                                             CFDataRef textData,
                                                             CFErrorRef *error);
