//
//  PSDatasetImportRMNSim.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/15/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

CFDictionaryRef PSDatasetImportRMNCreateDictionaryWithRMNSimParametersData(CFDataRef resourceData);
PSDatasetRef PSDatasetImportRMNSimCreateSignalWithFolderData(CFArrayRef dataFiles,
                                                             CFDataRef paramData,
                                                             CFDataRef twoDparamData,
                                                             CFDataRef nDparamData,
                                                             CFErrorRef *error);
