//
//  PSPList.h
//
//  Created by PhySy Ltd on 4/12/13.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

CFArrayRef PSCFArrayCreatePListCompatibleArray(CFArrayRef theArray);
CFMutableArrayRef PSCFArrayCreateWithPListCompatibleArray(CFArrayRef theArray, CFErrorRef *error);

CFDictionaryRef PSCFDictionaryCreatePListCompatible(CFDictionaryRef theDictionary);
CFMutableDictionaryRef PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryRef theDictionary, CFErrorRef *error);


