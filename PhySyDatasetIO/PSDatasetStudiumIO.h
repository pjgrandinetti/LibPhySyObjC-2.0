//
//  PSDatasetStudiumIO.h
//  LibPhySyObjC
//
//  Created by philip on 4/26/17.
//  Copyright © 2017 PhySy Ltd. All rights reserved.
//

#ifndef PSDatasetStudiumIO_h
#define PSDatasetStudiumIO_h

typedef enum fileFormatType {
    kStudiumText,
    kStudiumBinary
} fileFormatType;


CFDictionaryRef PSDatasetStudiumIOCreateDictionaryFromDataset(PSDatasetRef theDataset, fileFormatType fileFormat);
PSDatasetRef PSDatasetStudiumIOCreateDatasetWithFileContents(CFDictionaryRef dataFiles,CFErrorRef *error);

#endif /* PSDatasetStudiumIO_h */
