//
//  PSDatasetImportVideo.h
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

//bool PSDatasetImportVideoIsValidURL(CFURLRef url);
//CFIndex PSDatasetImportVideoNumberOfDimensionsForURL(CFURLRef url);
PSDatasetRef PSDatasetCreateWithVideoURL(CFURLRef url, CFErrorRef *error);
