//
//  PSCFData.h
//  LibPhySyObjC
//
//  Created by Philip Grandinetti on 1/6/19.
//  Copyright © 2019 PhySy Ltd. All rights reserved.
//

/*!
 @header PSCFData
 PSCFData extends CFArray with additional methods.
 
 @copyright PhySy Ltd
 */

/*!
 @function PSCFDataCreateDataFromURL
 @abstract Creates a CFData type from contents of URL
 @param url The url.
 @result A CFData type.
 */
CFDataRef PSCFDataCreateDataFromURL(CFURLRef url);

CFDataRef PSCFDataCreateFromNSNumberArray(CFArrayRef array, csdmNumericType elementType);
CFDataRef PSCFDataCreateFromCSDMNumericTypeData(CFDataRef csdmData, csdmNumericType srcType, numberType destType);
