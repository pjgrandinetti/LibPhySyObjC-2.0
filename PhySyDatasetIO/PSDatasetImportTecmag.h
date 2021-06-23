//
//  PSDatasetImportTecmag.h
//  PSDataset
//
//  Created by Philip J. Grandinetti on 10/23/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

//bool PSDatasetImportTecmagIsValidURL(CFURLRef url);
//CFIndex PSDatasetImportTecmagNumberOfDimensionsForURL(CFURLRef url);
//PSDatasetRef PSDatasetImportTecmagCreateSignalAtURL(CFURLRef url, CFErrorRef *error);
PSDatasetRef PSDatasetImportTecmagCreateWithFileData(CFDataRef contents, CFErrorRef *error);
