//
//  PSDatasetImportJOEL.h
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

bool PSDatasetImportJOELIsValidURL(CFURLRef url);
CFIndex PSDatasetImportJOELNumberOfDimensionsForURL(CFURLRef url);
PSDatasetRef PSDatasetImportJOELCreateSignalAtURL(CFURLRef url, CFErrorRef *error);
PSDatasetRef PSDatasetImportJOELCreateSignalWithData(CFDataRef contents, CFErrorRef *error);
