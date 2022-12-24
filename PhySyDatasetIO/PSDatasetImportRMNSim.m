//
//  PSDatasetImportRMNSim.c
//
//  Created by Philip J. Grandinetti on 3/15/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

/* Define coordinate units */
#define SECONDS			0
#define MILLISECONDS	1
#define MICROSECONDS	2
#define HZ				4
#define KHZ				5
#define MHZ				6
#define PPM				7


CFDictionaryRef PSDatasetImportRMNCreateDictionaryWithRMNSimParametersData(CFDataRef resourceData)
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
            
            if(CFStringCompare(mutString, CFSTR("SECONDS"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(SECONDS);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else if(CFStringCompare(mutString, CFSTR("MILLISECONDS"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(MILLISECONDS);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else if(CFStringCompare(mutString, CFSTR("MICROSECONDS"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(MICROSECONDS);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else if(CFStringCompare(mutString, CFSTR("HZ"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(HZ);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else if(CFStringCompare(mutString, CFSTR("KHZ"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(KHZ);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else if(CFStringCompare(mutString, CFSTR("MHZ"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(MHZ);
                CFDictionarySetValue(dict, mutKey, number);
                CFRelease(number);
            }
            else if(CFStringCompare(mutString, CFSTR("PPM"), 0)==kCFCompareEqualTo) {
                CFNumberRef number = PSCFNumberCreateWithCFIndex(PPM);
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

CFMutableArrayRef PSDatasetImportRMNSimCreateDimensionsWithNDParamData(CFDataRef nDparamData, CFErrorRef *error)
{
    
    CFDictionaryRef nDparamDictionary = PSDatasetImportRMNCreateDictionaryWithRMNSimParametersData(nDparamData);
    if(!CFDictionaryContainsKey(nDparamDictionary, CFSTR("dimensions"))) {
        CFRelease(nDparamDictionary);
        if(error) {
            CFStringRef desc = CFSTR("dimensions missing from nDparam file");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            3);
        }
        return NULL;
    }
    
    int numberOfDimensions = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, CFSTR("dimensions")));
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, numberOfDimensions, &kCFTypeArrayCallBacks);
    
    for(int dimIndex= numberOfDimensions-1;dimIndex>=0; dimIndex--) {
        CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_number_of_samples"), dimIndex+1);
        CFIndex npts = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, key));
        CFRelease(key);
        
        PSScalarRef increment = NULL;
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_sampling_interval"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            increment = PSScalarCreateWithCFString(CFDictionaryGetValue(nDparamDictionary, key), error);
        }
        CFRelease(key);

        if(NULL==increment) {
            CFRelease(nDparamDictionary);
            CFRelease(dimensions);
            return NULL;
        }
        CFStringRef quantityName = NULL;
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_quantity"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            quantityName = CFDictionaryGetValue(nDparamDictionary, key);
            if(quantityName) CFRetain(quantityName);
        }
        CFRelease(key);
        
        
        PSDimensionRef theDimension = PSLinearDimensionCreateDefault(npts, increment, quantityName,NULL);
        CFRelease(increment);
        if(quantityName) CFRelease(quantityName);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_inverse_quantity"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            PSDimensionSetInverseQuantityName(theDimension, CFDictionaryGetValue(nDparamDictionary, key));
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_label"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            PSDimensionSetLabel(theDimension,CFDictionaryGetValue(nDparamDictionary, key));
        }
        CFRelease(key);
        
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_inverse_label"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            PSDimensionSetInverseLabel(theDimension,CFDictionaryGetValue(nDparamDictionary, key));
        }
        CFRelease(key);
        
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_reference_offset"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(nDparamDictionary, key), error);
            PSDimensionSetReferenceOffset(theDimension,value);
            CFRelease(value);
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_inverse_referenceOffset"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(nDparamDictionary, key), error);
            PSDimensionSetInverseReferenceOffset(theDimension,value);
            CFRelease(value);
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_origin_offset"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(nDparamDictionary, key), error);
            PSDimensionSetOriginOffset(theDimension,value);
           CFRelease(value);
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_inverse_originOffset"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            PSScalarRef value = PSScalarCreateWithCFString(CFDictionaryGetValue(nDparamDictionary, key), error);
            PSDimensionSetInverseOriginOffset(theDimension,value);
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_periodic"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            bool value = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, key));
            PSDimensionSetPeriodic(theDimension, value);
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_inversePeriodic"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            bool value = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, key));
            PSDimensionSetInversePeriodic(theDimension, value);
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_made_dimensionless"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            bool value = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, key));
            PSDimensionSetMadeDimensionless(theDimension, value);
        }
        CFRelease(key);
        
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_inverse_made_dimensionless"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            bool value = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, key));
            PSDimensionSetInverseMadeDimensionless(theDimension, value);
       }
        CFRelease(key);
        
        bool ftFlag = false;
        key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("dimension%d_ftFlag"), dimIndex+1);
        if(CFDictionaryContainsKey(nDparamDictionary, key)) {
            ftFlag = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, key));
        }
        CFRelease(key);
        
        PSDimensionMakeNiceUnits(theDimension);
        CFArrayAppendValue(dimensions, theDimension);
        CFRelease(theDimension);
    }
    CFRelease(nDparamDictionary);
    return dimensions;
}

PSDatasetRef PSDatasetImportRMNSimCreateSignalWithFolderData(CFArrayRef dataFiles,
                                                             CFDataRef paramData,
                                                             CFDataRef twoDparamData,
                                                             CFDataRef nDparamData,
                                                             CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(CFArrayGetCount(dataFiles)==0) {
        if(error) {
            CFStringRef desc = CFSTR("data missing from folder");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            3);
        }
        return NULL;
    }

    bool param = false;
    bool twoDparam = false;
    bool nDparam = false;
    if(paramData) param = true;
    if(twoDparamData) twoDparam = true;
    if(nDparamData) nDparam = true;
    
    numberType elementType = kPSNumberFloat32ComplexType;
    CFStringRef fileFormat = CFSTR("text");
    CFStringRef responseQuantityName = NULL;
    CFStringRef responseName = NULL;
    PSUnitRef responseUnit = NULL;
    double response_unit_multiplier = 1;
    int numberOfSignals = 1;

    CFMutableArrayRef dimensions = NULL;
    if(nDparam) {
        dimensions = PSDatasetImportRMNSimCreateDimensionsWithNDParamData(nDparamData,error);
        
        CFDictionaryRef nDparamDictionary = PSDatasetImportRMNCreateDictionaryWithRMNSimParametersData(nDparamData);
        numberOfSignals = CFStringGetIntValue(CFDictionaryGetValue(nDparamDictionary, CFSTR("signals")));

        if(CFDictionaryContainsKey(nDparamDictionary, CFSTR("number_type"))) {
            CFStringRef elementTypeString = CFRetain(CFDictionaryGetValue(nDparamDictionary, CFSTR("number_type")));
            if(CFStringCompare(elementTypeString, CFSTR("float32"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kPSNumberFloat32Type;
            else if(CFStringCompare(elementTypeString, CFSTR("float32 complex"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kPSNumberFloat32ComplexType;
            else if(CFStringCompare(elementTypeString, CFSTR("float64"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kPSNumberFloat64Type;
            else if(CFStringCompare(elementTypeString, CFSTR("float64 complex"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) elementType = kPSNumberFloat64ComplexType;
            CFRelease(elementTypeString);
        }

        if(CFDictionaryContainsKey(nDparamDictionary, CFSTR("file_format"))) {
            fileFormat = CFRetain(CFDictionaryGetValue(nDparamDictionary, CFSTR("file_format")));
        }

        if(CFDictionaryContainsKey(nDparamDictionary, CFSTR("response_quantity"))) {
            responseQuantityName = CFRetain(CFDictionaryGetValue(nDparamDictionary, CFSTR("response_quantity")));
        }
        
        if(CFDictionaryContainsKey(nDparamDictionary, CFSTR("response_unit"))) {
            responseUnit = PSUnitByParsingSymbol(CFDictionaryGetValue(nDparamDictionary, CFSTR("response_unit")), &response_unit_multiplier, error);
        }
        
        if(CFDictionaryContainsKey(nDparamDictionary, CFSTR("response_name"))) {
            responseName = CFRetain(CFDictionaryGetValue(nDparamDictionary, CFSTR("response_name")));
        }
        
        CFRelease(nDparamDictionary);
    }
    
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    
    CFMutableArrayRef signals = CFArrayCreateMutable(kCFAllocatorDefault, numberOfSignals, &kCFTypeArrayCallBacks);
    for(CFIndex dependentVariableIndex=0;dependentVariableIndex<numberOfSignals;dependentVariableIndex++) {
        CFDataRef dataData = CFArrayGetValueAtIndex(dataFiles, dependentVariableIndex);
        CFStringRef signalName = NULL;
        
        PSDependentVariableRef theDependentVariable = NULL;
        if(CFStringCompare(fileFormat, CFSTR("text"), kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
            CFStringRef fileString = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,dataData,kCFStringEncodingUTF8);
            CFArrayRef lines = CFStringCreateArrayBySeparatingStrings (kCFAllocatorDefault,fileString,CFSTR("\n"));
            CFRelease(fileString);
            
            switch(elementType) {
                case kCSDMNumberFloat32Type: {
                    theDependentVariable = PSDependentVariableCreateWithSize(signalName,
                                                                             NULL,
                                                                             NULL,
                                                                             NULL,
                                                                             CFSTR("scalar"),
                                                                             kPSNumberFloat32Type,
                                                                             NULL,
                                                                             size,
                                                                             NULL,
                                                                             NULL);
                    
                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                        float real = CFStringGetDoubleValue(line);
                        PSScalarRef response = PSScalarCreateWithFloat(real, NULL);
                        
                        PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
                        
                        PSDependentVariableSetValueAtCoordinateIndexes(theDependentVariable,
                                                                       0,
                                                                       dimensions,
                                                                       coordinateIndexes,
                                                                       response,
                                                                       error);

                        CFRelease(coordinateIndexes);
                        CFRelease(response);
                    }
                }
                    break;
                case kCSDMNumberFloat64Type: {
                    theDependentVariable = PSDependentVariableCreateWithSize(signalName,
                                                                             NULL,
                                                                             NULL,
                                                                             NULL,
                                                                             CFSTR("scalar"),
                                                                             kPSNumberFloat64Type,
                                                                             NULL,
                                                                             size,
                                                                             NULL,
                                                                             NULL);

                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines);memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, memOffset);
                        double real = CFStringGetDoubleValue(line);
                        PSScalarRef response = PSScalarCreateWithDouble(real, NULL);
                        
                        PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
                        PSDependentVariableSetValueAtCoordinateIndexes(theDependentVariable,
                                                                       0,
                                                                       dimensions,
                                                                       coordinateIndexes,
                                                                       response,
                                                                       error);
                        CFRelease(coordinateIndexes);
                        CFRelease(response);
                    }
                }
                    break;
                case kCSDMNumberComplex64Type: {
                    theDependentVariable = PSDependentVariableCreateWithSize(signalName,
                                                                             NULL,
                                                                             NULL,
                                                                             NULL,
                                                                             CFSTR("scalar"),
                                                                             kPSNumberFloat32ComplexType,
                                                                             NULL,
                                                                             size,
                                                                             NULL,
                                                                             NULL);

                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines)/2;memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, 2*memOffset);
                        float real = CFStringGetDoubleValue(line);
                        line = CFArrayGetValueAtIndex(lines, 2*memOffset+1);
                        float imag = CFStringGetDoubleValue(line);
                        PSScalarRef response = PSScalarCreateWithFloatComplex(real+I*imag, NULL);
                        
                        PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
                        PSDependentVariableSetValueAtCoordinateIndexes(theDependentVariable,
                                                                       0,
                                                                       dimensions,
                                                                       coordinateIndexes,
                                                                       response,
                                                                       error);
                        CFRelease(coordinateIndexes);
                        CFRelease(response);
                    }
                }
                    break;
                case kCSDMNumberComplex128Type: {
                    theDependentVariable = PSDependentVariableCreateWithSize(signalName,
                                                                             NULL,
                                                                             NULL,
                                                                             NULL,
                                                                             CFSTR("scalar"),
                                                                             kPSNumberFloat64ComplexType,
                                                                             NULL,
                                                                             size,
                                                                             NULL,
                                                                             NULL);

                    for(CFIndex memOffset=0;memOffset<CFArrayGetCount(lines)/2;memOffset++) {
                        CFStringRef line = CFArrayGetValueAtIndex(lines, 2*memOffset);
                        double real = CFStringGetDoubleValue(line);
                        line = CFArrayGetValueAtIndex(lines, 2*memOffset+1);
                        double imag = CFStringGetDoubleValue(line);
                        PSScalarRef response = PSScalarCreateWithDoubleComplex(real+I*imag, NULL);
                        
                        PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
                        PSDependentVariableSetValueAtCoordinateIndexes(theDependentVariable,
                                                                       0,
                                                                       dimensions,
                                                                       coordinateIndexes,
                                                                       response,
                                                                       error);
                        CFRelease(coordinateIndexes);
                        CFRelease(response);
                    }
                }
                    break;
            }
            CFRelease(lines);
        }
        else {
            theDependentVariable = PSDependentVariableCreateWithComponent(signalName,
                                                                          NULL,
                                                                          NULL,
                                                                          NULL,
                                                                          elementType,
                                                                          NULL,
                                                                          dataData,
                                                                          NULL,
                                                                          NULL);

            if(PSDependentVariableSize((PSDependentVariableRef) theDependentVariable)<size) PSDependentVariableSetSize((PSDependentVariableRef) theDependentVariable, size);
        }
        CFArrayAppendValue(signals, theDependentVariable);
        CFRelease(theDependentVariable);
    }
    PSDatasetRef theDataset =   PSDatasetCreate(dimensions,
                                                NULL,
                                                signals,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL);

    if(fileFormat) CFRelease(fileFormat);
    if(signals) CFRelease(signals);
    if(dimensions) CFRelease(dimensions);
    if(responseQuantityName) CFRelease(responseQuantityName);
    if(responseName) CFRelease(responseName);
    
    return theDataset;
}
