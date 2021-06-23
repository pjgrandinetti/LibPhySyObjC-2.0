//
//  PSCFDictionary.h
//
//  Created by PhySy Ltd on 9/25/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSCFDictionary
 PSCFDictionary extends CFDictionary with additional methods.
  
 @copyright PhySy Ltd
 */

/*!
 @function PSCFDictionaryCreateArrayWithAllKeys
 @abstract Returns a new array containing the dictionary’s keys.
 @param theDictionary The dictionary.
 @result array with keys
 */
CFArrayRef PSCFDictionaryCreateArrayWithAllKeys(CFDictionaryRef theDictionary);

/*!
 @function PSCFDictionaryCreateArrayWithAllValues
 @abstract Returns a new array containing the dictionary’s values.
 @param theDictionary The dictionary.
 @result array with values
 */
CFArrayRef PSCFDictionaryCreateArrayWithAllValues(CFDictionaryRef theDictionary);
