//
//  PSDatasetImportImage.h
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

//bool PSDatasetImportImageIsValidURL(CFURLRef url);
//CFIndex PSDatasetImportImageNumberOfDimensionsForURL(CFURLRef url);
//PSDatasetRef PSDatasetImportImageCreateSignalAtURL(CFURLRef url, CFErrorRef *error);
PSDatasetRef PSDatasetImportImageCreateSignalWithData(CFDataRef contents, CFErrorRef *error);
PSDatasetRef PSDatasetImportImageCreateSignalWithCGImages(CFArrayRef images, double frameIncrementInSec, CFErrorRef *error);
