//
//  PSDatasetStudiumIO.m
//  LibPhySyObjC
//
//  Created by philip on 4/26/17.
//  Copyright © 2017 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

#pragma mark Utilities

CFStringRef findAndCreateStringWithoutQuotesWithFormattedKey(CFDictionaryRef parametersDictionary, CFStringRef keyFormat, CFIndex index)
{
    CFMutableStringRef mutableString = NULL;
    CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, keyFormat, index+1);
    if(CFDictionaryContainsKey(parametersDictionary, key)) {
        CFStringRef temp = CFDictionaryGetValue(parametersDictionary, key);
        mutableString = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(temp), temp);
        PSCFStringTrimMatchingQuotes(mutableString);
    }
    CFRelease(key);
    return mutableString;
}

bool findBooleanWithFormattedKey(CFDictionaryRef parametersDictionary, CFStringRef keyFormat, CFIndex index, bool defaultValue)
{
    bool value = defaultValue;
    CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, keyFormat, index+1);
    if(CFDictionaryContainsKey(parametersDictionary, key)) {
        value = CFStringGetIntValue(CFDictionaryGetValue(parametersDictionary, key));
    }
    CFRelease(key);
    return value;
}

PSScalarRef findAndCreateScalarWithFormattedKey(CFDictionaryRef parametersDictionary, CFStringRef keyFormat, CFIndex index, CFErrorRef *error)
{
    PSScalarRef value = NULL;
    CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, keyFormat, index+1);
    if(CFDictionaryContainsKey(parametersDictionary, key)) {
        value = PSScalarCreateWithCFString(CFDictionaryGetValue(parametersDictionary, key), error);
    }
    CFRelease(key);
    return value;
}

CFStringRef findAndCreateStringWithoutQuotesWithKey(CFDictionaryRef parametersDictionary, CFStringRef key)
{
    CFMutableStringRef mutableString = NULL;
    if(CFDictionaryContainsKey(parametersDictionary, key)) {
        CFStringRef temp = CFDictionaryGetValue(parametersDictionary, key);
        mutableString = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(temp), temp);
        PSCFStringTrimMatchingQuotes(mutableString);
    }
    return mutableString;
}

CFStringRef findAndCreateStringWithKey(CFDictionaryRef dictionary, CFStringRef key)
{
    CFMutableStringRef mutableString = NULL;
    if(CFDictionaryContainsKey(dictionary, key)) {
        CFStringRef temp = CFDictionaryGetValue(dictionary, key);
        mutableString = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(temp), temp);
        PSCFStringTrimMatchingQuotes(mutableString);
    }
    return mutableString;
}

PSScalarRef findAndCreateScalarWithKey(CFDictionaryRef dictionary, CFStringRef key, CFErrorRef *error)
{
    PSScalarRef value = NULL;
    if(CFDictionaryContainsKey(dictionary, key)) {
        value = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, key), error);
    }
    return value;
}

bool findBooleanWithKey(CFDictionaryRef dictionary, CFStringRef key, bool defaultValue)
{
    bool value = defaultValue;
    if(CFDictionaryContainsKey(dictionary, key)) {
        value = CFBooleanGetValue(CFDictionaryGetValue(dictionary, key));
    }
    return value;
}

#pragma mark Import

CFMutableArrayRef PSDatasetStudiumIOCreateDimensionsFromFlatTextParameters(CFDictionaryRef parametersDictionary, CFErrorRef *error)
{
    
    // based on the keys present or absent from the parameters file we work out the number of dimensions.

    int numberOfDimensions = 1;
    if(!CFDictionaryContainsKey(parametersDictionary, CFSTR("number_of_points"))) {
        // key "number_of_points" not found.
        // Only two possibilities, (1) there are multiple dimensions or
        // (2) it is one dimension with non-uniform grid.
        // Here we search for multiD keys.
        CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dim%d_number_of_points"), numberOfDimensions);
        while(CFDictionaryContainsKey(parametersDictionary, key)) {
            numberOfDimensions++;
            CFRelease(key);
            key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dim%d_number_of_points"), numberOfDimensions);
        }
        CFRelease(key);
        numberOfDimensions--;
        
        if(numberOfDimensions == 0) {
            // could not find number_of_points or dimX_number_of_points
            // only possibility is one dimension with non-uniform grid.
            numberOfDimensions = 1;
            // If "sampling_interval" is present it will be ignored.
            // There must be "coord%d" keys present.
        }
    }
    else {
        //  key "number_of_points" found : must be only 1 D.
        numberOfDimensions = 1;
    }
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, numberOfDimensions, &kCFTypeArrayCallBacks);
    
    for(int dimIndex= numberOfDimensions-1;dimIndex>=0; dimIndex--) {
        PSDimensionRef theDimension = NULL;
        CFStringRef keyPrefix = CFSTR("");
        if(numberOfDimensions>1)
            keyPrefix = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dim%d_"), dimIndex+1);

        CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@quantity"), keyPrefix);
        CFStringRef quantityName = findAndCreateStringWithKey(parametersDictionary,  key);
        CFRelease(key);

        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@sampling_interval"), keyPrefix);
        PSScalarRef increment = findAndCreateScalarWithKey(parametersDictionary, key, error);
        CFRelease(key);
        
        CFIndex npts = 0;
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@number_of_points"), keyPrefix);
        if(CFDictionaryContainsKey(parametersDictionary, key))
            npts = CFStringGetIntValue(CFDictionaryGetValue(parametersDictionary, key));
        CFRelease(key);

        CFMutableArrayRef nonUniformCoordinates=NULL;
        if(NULL==increment) {
            CFStringRef keyPrefix = CFSTR("");
            if(numberOfDimensions>1)
                keyPrefix = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dim%d_"), dimIndex+1);
            
            npts = 1;
            CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@coord%ld"), keyPrefix,npts);
            while(CFDictionaryContainsKey(parametersDictionary, key)) {
                npts++;
                CFRelease(key);
                key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@coord%ld"), keyPrefix,npts);
            }
            npts--;
            CFRelease(key);
            
            nonUniformCoordinates = CFArrayCreateMutable(kCFAllocatorDefault, npts, &kCFTypeArrayCallBacks);
            
            for(int coordinateIndex=0;coordinateIndex<npts; coordinateIndex++) {
                CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@coord%d"), keyPrefix,coordinateIndex+1);
                if(CFDictionaryContainsKey(parametersDictionary, key)) {
                    PSScalarRef theCoordinate = PSScalarCreateWithCFString(CFDictionaryGetValue(parametersDictionary, key), error);
                    CFArrayAppendValue(nonUniformCoordinates, theCoordinate);
                }
                CFRelease(key);
            }
            theDimension = PSMonotonicDimensionCreateDefault(nonUniformCoordinates, quantityName);
            if(numberOfDimensions>1) CFRelease(keyPrefix);
            CFRelease(nonUniformCoordinates);

        }
        else  {
            theDimension = PSLinearDimensionCreateDefault(npts, increment, quantityName);
        }
        CFRelease(quantityName);
        
        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@inverseQuantity"), keyPrefix));
        CFStringRef inverseQuantityName = findAndCreateStringWithKey(parametersDictionary,  key);
        if(inverseQuantityName) {PSDimensionSetInverseQuantityName(theDimension,inverseQuantityName);CFRelease(inverseQuantityName);}

        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@label"), keyPrefix));
        CFStringRef label = findAndCreateStringWithKey(parametersDictionary,  key);
        if(label) {PSDimensionSetLabel(theDimension,label);CFRelease(label);}

        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@inverseLabel"), keyPrefix));
        CFStringRef inverseLabel = findAndCreateStringWithKey(parametersDictionary,  key);
        if(inverseLabel) {PSDimensionSetInverseLabel(theDimension,inverseLabel);CFRelease(inverseLabel);}
        
        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@reference_offset"), keyPrefix));
        PSScalarRef referenceOffset = findAndCreateScalarWithKey(parametersDictionary, key, error);
        if(referenceOffset) {PSDimensionSetReferenceOffset(theDimension,referenceOffset);CFRelease(referenceOffset);}

        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@inverse_reference_offset"), keyPrefix));
        PSScalarRef inverseReferenceOffset = findAndCreateScalarWithKey(parametersDictionary, key, error);
        if(inverseReferenceOffset) {PSDimensionSetInverseReferenceOffset(theDimension,inverseReferenceOffset);CFRelease(inverseReferenceOffset);}

        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@origin_offset"), keyPrefix));
        PSScalarRef originOffset = findAndCreateScalarWithKey(parametersDictionary, key, error);
        if(originOffset) {PSDimensionSetOriginOffset(theDimension,originOffset);CFRelease(originOffset);}
        
        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@inverse_origin_offset"), keyPrefix));
        PSScalarRef inverseOriginOffset = findAndCreateScalarWithKey(parametersDictionary, key, error);
        if(inverseOriginOffset) {PSDimensionSetInverseOriginOffset(theDimension,inverseOriginOffset);CFRelease(inverseOriginOffset);}

        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@periodic"), keyPrefix));
        PSDimensionSetPeriodic(theDimension, findBooleanWithKey(parametersDictionary, key, false));
        
        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@inverse_periodic"), keyPrefix));
        PSDimensionSetInversePeriodic(theDimension, findBooleanWithKey(parametersDictionary, key, false));
        
        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@made_dimensionless"), keyPrefix));
        PSDimensionSetMadeDimensionless(theDimension, findBooleanWithKey(parametersDictionary, key, false));
        
        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@inverse_made_dimensionless"), keyPrefix));
        PSDimensionSetInverseMadeDimensionless(theDimension, findBooleanWithKey(parametersDictionary, key, false));
        
        key = CFAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@ftFlag"), keyPrefix));
        PSDimensionSetFFT(theDimension, findBooleanWithKey(parametersDictionary, key, false));
        
        CFRelease(keyPrefix);
        CFArrayAppendValue(dimensions, theDimension);
        CFRelease(theDimension);

    }
    return dimensions;
}

CFDataRef PSDatasetStudiumIOCreateDataFromFile(CFDataRef data_file_data,
                                               CFIndex size,
                                               fileFormatType file_format,
                                               csdmNumericType elementType,
                                               CFByteOrder endian,
                                               long unsigned start_byte)
{
    CFDataRef values = NULL;
    switch (file_format) {
        case kStudiumText: {
            CFStringRef fileString = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,data_file_data,kCFStringEncodingUTF8);
            CFArrayRef lines = CFStringCreateArrayBySeparatingStrings (kCFAllocatorDefault,fileString,CFSTR("\n"));
            CFRelease(fileString);
            
            switch(elementType) {
                default:
                    break;
                case kCSDMNumberFloat32Type:
                {
                    float responses[size];
                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                        responses[memOffset] = CFStringGetDoubleValue(line);
                    }
                    values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) responses, sizeof(float)*size);
                }
                    break;
                case kCSDMNumberFloat64Type: {
                    double responses[size];
                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                        responses[memOffset] = CFStringGetDoubleValue(line);
                    }
                    values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) responses, sizeof(double)*size);
                }
                    break;
                case kCSDMNumberComplex64Type: {
                    float complex responses[size];
                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                        responses[memOffset] = PSCFStringGetFloatComplexFromCommaSeparatedParts(line);
                    }
                    values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) responses, sizeof(float complex)*size);
                    
                }
                    break;
                case kCSDMNumberComplex128Type: {
                    double complex responses[size];
                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                        responses[memOffset] = PSCFStringGetDoubleComplexFromCommaSeparatedParts(line);
                    }
                    values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) responses, sizeof(double complex)*size);
                    
                }
                    break;
            }
            CFRelease(lines);
        }
            break;
        case kStudiumBinary: {
            CFByteOrder nativeEndian = CFByteOrderGetCurrent();
            if(IS_BIG_ENDIAN) nativeEndian = CFByteOrderBigEndian;
            
            UInt8 *buffer = (UInt8 *) CFDataGetBytePtr(data_file_data);
            switch(elementType) {
                default:
                    break;
                case kCSDMNumberSInt32Type:
                {
                    SInt32 *srcResponses = (SInt32 *) &buffer[start_byte];
                    values = CFDataCreateMutable(kCFAllocatorDefault, size*sizeof(SInt32));
                    float *destResponses = (float *) CFDataGetBytePtr(values);
                    
                    for(CFIndex index=0;index<size;index++) {
                        if(endian == nativeEndian) destResponses[index] = srcResponses[index];
                        else  destResponses[index] = PSByteSwapSint32(srcResponses[index]);
                    }
                }
                    break;
                case kCSDMNumberFloat32Type: {
                    if(endian != nativeEndian) {
                        float *srcResponses = (float *) &buffer[start_byte];
                        values = CFDataCreateMutable(kCFAllocatorDefault, size*sizeof(float));
                        float *destResponses = (float *) CFDataGetBytePtr(values);
                        for(CFIndex index=0;index<size;index++)
                            destResponses[index] = PSByteSwapFloat(srcResponses[index]);
                    }
                    else values = CFRetain(data_file_data);
                }
                    break;
                    
                case kCSDMNumberFloat64Type:
                {
                    if(endian != nativeEndian) {
                        double *srcResponses = (double *) &buffer[start_byte];
                        values = CFDataCreateMutable(kCFAllocatorDefault, size*sizeof(double));
                        double *destResponses = (double *) CFDataGetBytePtr(values);
                        for(CFIndex index=0;index<size;index++)
                            destResponses[index] = PSByteSwapDouble(srcResponses[index]);
                    }
                    else values = CFRetain(data_file_data);
                }
                    break;
                    
                case kCSDMNumberComplex64Type: {
                    if(endian != nativeEndian) {
                        float *srcResponses = (float *) &buffer[start_byte];
                        values = CFDataCreateMutable(kCFAllocatorDefault, 2*size*sizeof(float));
                        float *destResponses = (float *) CFDataGetBytePtr(values);
                        for(CFIndex index=0;index<2*size;index++)
                            destResponses[index] = PSByteSwapFloat(srcResponses[index]);
                    }
                    else values = CFRetain(data_file_data);
                }
                    break;
                    
                case kCSDMNumberComplex128Type: {
                    if(endian != nativeEndian) {
                        double *srcResponses = (double *) &buffer[start_byte];
                        values = CFDataCreateMutable(kCFAllocatorDefault, 2*size*sizeof(double));
                        double *destResponses = (double *) CFDataGetBytePtr(values);
                        for(CFIndex index=0;index<2*size;index++)
                            destResponses[index] = PSByteSwapDouble(srcResponses[index]);
                    }
                    else values = CFRetain(data_file_data);
                    
                }
                    break;
            }
        }
            
            break;
            
    }
    return values;
}

CFDictionaryRef PSDatasetStudiumIOCreateParametersDictionaryFromFlatTextParametersFileData(CFDataRef resourceData)
{
    CFStringRef fileString = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,resourceData,kCFStringEncodingUTF8);
    CFArrayRef lines = CFStringCreateArrayBySeparatingStrings (kCFAllocatorDefault,fileString,CFSTR("\n"));
    CFRelease(fileString);
    
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    for(CFIndex index = 0; index<CFArrayGetCount(lines); index++) {
        CFStringRef line = CFArrayGetValueAtIndex(lines, index);
        CFArrayRef keyAndValue = CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault,line,CFSTR("="));
        if(CFArrayGetCount(keyAndValue) == 2) {
            CFStringRef key = CFArrayGetValueAtIndex(keyAndValue, 0);
            CFMutableStringRef  mutKey = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(key),key);
            CFStringFindAndReplace (mutKey,CFSTR(" "), CFSTR(""),CFRangeMake(0,CFStringGetLength(mutKey)),0);
            CFStringRef value = CFArrayGetValueAtIndex(keyAndValue, 1);
            
            CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(value),value);
            CFStringFindAndReplace (mutString,CFSTR(" "), CFSTR(""),CFRangeMake(0,CFStringGetLength(mutString)),0);
            
            if(CFStringCompare(mutString, CFSTR("false"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(0);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else if(CFStringCompare(mutString, CFSTR("true"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(1);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else {
                CFDictionarySetValue(dict, mutKey, value);
            }
            CFRelease(mutString);
            CFRelease(mutKey);
        }
        if(keyAndValue) CFRelease(keyAndValue);
    }
    CFRelease(lines);
    return dict;
}

PSDatasetRef PSDatasetStudiumIOCreateDatasetWithFileContents(CFDictionaryRef dataFiles,CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(dataFiles, CFSTR("parameters.txt"))) return NULL;
    CFDataRef parametersData = CFDictionaryGetValue(dataFiles, CFSTR("parameters.txt"));
    CFDictionaryRef dictionary = PSDatasetStudiumIOCreateParametersDictionaryFromFlatTextParametersFileData(parametersData);
    
    CFMutableArrayRef dimensions = PSDatasetStudiumIOCreateDimensionsFromFlatTextParameters(dictionary, error);
    if(NULL==dimensions) {
        CFRelease(dictionary);
        return NULL;
    }
    
    PSDatasetRef theDataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(theDataset, dimensions, NULL);
    CFRelease(dimensions);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(PSDatasetGetDimensions(theDataset));

    // based on the keys present or absent from the parameters file we work out the number of dimensions.
    int dvCount = 1;
    if(!CFDictionaryContainsKey(dictionary, CFSTR("file_url"))) {
        // key "file_url" not found.
        // Here we search for multiD keys.
        CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("signal%d_file_url"), dvCount);
        while(CFDictionaryContainsKey(dictionary, key)) {
            dvCount++;
            CFRelease(key);
            key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("signal%d_file_url"), dvCount);
        }
        CFRelease(key);
        dvCount--;
        
        if(dvCount == 0) {
            CFRelease(dictionary);
            // could not find file_url or signalX_file_url
            // This is bad.
            return NULL;
        }
    }
    else {
        //  key "number_of_points" found : must be only 1 D.
        dvCount = 1;
    }
    
    for(int dvIndex = 0;dvIndex<dvCount; dvIndex++) {
        CFStringRef keyPrefix = CFSTR("");
        if(dvCount>1)
            keyPrefix = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("signal%d_"), dvIndex+1);
        
        csdmNumericType elementType = kCSDMNumberComplex64Type;
        CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@number_type"),keyPrefix);
        if(CFDictionaryContainsKey(dictionary, key)) {
            CFStringRef elementTypeString = CFDictionaryGetValue(dictionary, key);
            if(CFStringCompare(elementTypeString, CFSTR("float32"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kCSDMNumberFloat32Type;
            else if(CFStringCompare(elementTypeString, CFSTR("float32_complex"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kCSDMNumberComplex64Type;
            else if(CFStringCompare(elementTypeString, CFSTR("float64"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kCSDMNumberFloat32Type;
            else if(CFStringCompare(elementTypeString, CFSTR("float64_complex"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kCSDMNumberComplex128Type;
            else if(CFStringCompare(elementTypeString, CFSTR("integer32"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kCSDMNumberSInt32Type;
            else if(CFStringCompare(elementTypeString, CFSTR("integer64_complex"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kCSDMNumberSInt64Type;
        }
        CFRelease(key);
        
        PSDependentVariableRef dV = PSDatasetAddDefaultDependentVariable(theDataset,
                                                                         CFSTR("scalar"),
                                                                         elementType,
                                                                         kPSDatasetSizeFromDimensions);
        
        PSUnitRef responseUnit = PSUnitDimensionlessAndUnderived();
        double response_unit_multiplier = 1;
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@response_unit"), keyPrefix);
        CFErrorRef localError = NULL;
        if(CFDictionaryContainsKey(dictionary, key)) {
            CFStringRef responseUnitString = CFDictionaryGetValue(dictionary, key);
            responseUnit = PSUnitByParsingSymbol(responseUnitString, &response_unit_multiplier, &localError);
        }
        PSQuantitySetUnit(dV, responseUnit);
        
        CFRelease(key);
        fileFormatType file_format = kStudiumBinary;
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@file_format"),keyPrefix);
        if(CFDictionaryContainsKey(dictionary, key)) {
            CFStringRef fileFormatString = CFDictionaryGetValue(dictionary, key);
            if(CFStringCompare(fileFormatString, CFSTR("binary"), 0)==kCFCompareEqualTo) file_format = kStudiumBinary;
            else if(CFStringCompare(fileFormatString, CFSTR("text"), 0)==kCFCompareEqualTo) file_format = kStudiumText;
        }
        CFRelease(key);
        
        CFByteOrder endian = CFByteOrderGetCurrent();
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@endianness"),keyPrefix);
        if(CFDictionaryContainsKey(dictionary, key)) {
            CFStringRef fileFormatString = CFDictionaryGetValue(dictionary, key);
            if(CFStringCompare(fileFormatString, CFSTR("big"), 0)==kCFCompareEqualTo) endian = CFByteOrderBigEndian;
            else if(CFStringCompare(fileFormatString, CFSTR("little"), 0)==kCFCompareEqualTo) endian = CFByteOrderLittleEndian;
        }
        CFRelease(key);
        
        long unsigned start_byte = 0;
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@start_byte"),keyPrefix);
        if(CFDictionaryContainsKey(dictionary, key)) {
            bool success;
            start_byte = PSCFStringGetLongUnsignedInt(CFDictionaryGetValue(dictionary, key), &success);
            if(!success) start_byte = 0;
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@file_url"),keyPrefix);
        CFStringRef data_file_name = findAndCreateStringWithoutQuotesWithKey(dictionary, key);
        
        if(NULL==data_file_name) {
            CFRelease(keyPrefix);
            CFRelease(key);
            return NULL;
        }
        
        CFDataRef data_file_data = CFDictionaryGetValue(dataFiles, data_file_name);
        CFRelease(data_file_name);
        
        if(data_file_data==NULL) {
            if(error) {
                CFStringRef desc = CFSTR("data missing from folder");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                3);
            }
            CFRelease(keyPrefix);
            CFRelease(key);
            return NULL;
        }
        
        CFRelease(key);
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@name"),keyPrefix);
        CFRelease(keyPrefix);
        CFStringRef signalName = findAndCreateStringWithoutQuotesWithKey(dictionary, key);
        CFRelease(key);
        PSDependentVariableSetName(dV, signalName);
        CFRelease(signalName);
        
        CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(dV, 0);
        switch (file_format) {
            case kStudiumText: {
                CFStringRef fileString = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,data_file_data,kCFStringEncodingUTF8);
                CFArrayRef lines = CFStringCreateArrayBySeparatingStrings (kCFAllocatorDefault,fileString,CFSTR("\n"));
                CFRelease(fileString);
                
                switch(elementType) {
                    default:
                        break;
                    case kCSDMNumberFloat32Type:
                    {
                        float *responses = (float *) CFDataGetMutableBytePtr(values);
                        for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                            CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                            responses[memOffset] = CFStringGetDoubleValue(line);
                        }
                    }
                        break;
                    case kCSDMNumberFloat64Type: {
                        double *responses = (double *) CFDataGetMutableBytePtr(values);
                        for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                            CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                            responses[memOffset] = CFStringGetDoubleValue(line);
                        }
                    }
                        break;
                    case kCSDMNumberComplex64Type: {
                        float complex *responses = (float complex *) CFDataGetMutableBytePtr(values);
                        for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                            CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                            responses[memOffset] = PSCFStringGetFloatComplexFromCommaSeparatedParts(line);
                        }
                    }
                        break;
                    case kCSDMNumberComplex128Type: {
                        double complex *responses = (double complex *) CFDataGetMutableBytePtr(values);
                        for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                            CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                            responses[memOffset] = PSCFStringGetDoubleComplexFromCommaSeparatedParts(line);
                        }
                    }
                        break;
                }
                CFRelease(lines);
            }
                break;
            case kStudiumBinary: {
                CFByteOrder nativeEndian = CFByteOrderGetCurrent();
                if(IS_BIG_ENDIAN) nativeEndian = CFByteOrderBigEndian;
                
                UInt8 *buffer = (UInt8 *) CFDataGetBytePtr(data_file_data);
                switch(elementType) {
                    default:
                        break;
                    case kCSDMNumberSInt32Type:
                    {
                        SInt32 *srcResponses = (SInt32 *) &buffer[start_byte];
                        float *destResponses = (float *) CFDataGetMutableBytePtr(values);
                        
                        for(CFIndex index=0;index<size;index++) {
                            if(endian == nativeEndian) destResponses[index] = srcResponses[index];
                            else  destResponses[index] = PSByteSwapSint32(srcResponses[index]);
                        }
                    }
                        break;
                    case kCSDMNumberFloat32Type:
                    {
                        float *srcResponses = (float *) &buffer[start_byte];
                        float *destResponses = (float *) CFDataGetMutableBytePtr(values);
                        for(CFIndex index=0;index<size;index++) {
                            if(endian == nativeEndian) destResponses[index] = srcResponses[index];
                            else  destResponses[index] = PSByteSwapFloat(srcResponses[index]);
                        }
                    }
                        break;
                        
                    case kCSDMNumberFloat64Type:
                    {
                        double *srcResponses = (double *) &buffer[start_byte];
                        double *destResponses = (double *) CFDataGetMutableBytePtr(values);
                        for(CFIndex index=0;index<size;index++) {
                            if(endian == nativeEndian) destResponses[index] = srcResponses[index];
                            else  destResponses[index] =PSByteSwapDouble(srcResponses[index]);
                        }
                    }
                        break;
                        
                    case kCSDMNumberComplex64Type:
                    {
                        float *srcResponses = (float *) &buffer[start_byte];
                        float *destResponses = (float *) CFDataGetMutableBytePtr(values);
                        for(CFIndex index=0;index<2*size;index++) {
                            if(endian == nativeEndian) destResponses[index] = srcResponses[index];
                            else destResponses[index] = PSByteSwapFloat(srcResponses[index]);
                        }
                    }
                        break;
                        
                    case kCSDMNumberComplex128Type: {
                        double *srcResponses = (double *) &buffer[start_byte];
                        double *destResponses = (double *) CFDataGetMutableBytePtr(values);
                        for(CFIndex index=0;index<2*size;index++) {
                            if(endian == nativeEndian) destResponses[index] = srcResponses[index];
                            else destResponses[index] = PSByteSwapDouble(srcResponses[index]);
                        }
                    }
                        break;
                }
            }
                
                break;
                
        }
    }

    CFRelease(dictionary);

    return theDataset;
}
