//
//  PSDatasetImportRMNClassic.h
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

//CFIndex PSDatasetImportRMNClassicNumberOfDimensionsForTypeCode(OSType typeCode);
PSDatasetRef PSDatasetImportRMNClassicCreateSignalWithFileBytesAndTypeCode(const UInt8 * bytes, OSType typeCode, CFErrorRef *error);
