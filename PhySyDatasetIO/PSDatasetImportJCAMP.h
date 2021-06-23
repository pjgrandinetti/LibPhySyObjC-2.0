//
//  PSDatasetImportJCAMP.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 2/21/14.
//  Copyright (c) 2014 PhySy. All rights reserved.
//

//bool PSDatasetImportJCAMPIsValidURL(CFURLRef url);
//CFIndex PSDatasetImportJCAMPNumberOfDimensionsForURL(CFURLRef url);
PSDatasetRef PSDatasetImportJCAMPCreateSignalWithData(CFDataRef contents, CFErrorRef *error);
CFDictionaryRef  PSDatasetImportJCAMPCreateDictionaryWithLines(CFArrayRef lines, CFIndex *index);
