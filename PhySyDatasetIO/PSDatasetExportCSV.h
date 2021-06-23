//
//  PSDatasetExportCSV.h
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

PSDatasetRef PSDatasetImportCSVCreateSignalWithFileData(CFDataRef contents, CFErrorRef *error);
CFStringRef PSDatasetCreateCSVString(PSDatasetRef theDataset, CFErrorRef *error);
