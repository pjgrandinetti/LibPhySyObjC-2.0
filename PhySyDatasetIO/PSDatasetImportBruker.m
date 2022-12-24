//
//  PSDatasetImportBruker.c
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/14/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//
// Bruker needs complex conjugate

#import <LibPhySyObjC/PhySyDatasetIO.h>

CFDictionaryRef PSDatasetImportBrukerCreateDictionaryWithJCAMPData(CFDataRef resourceData)
{
    CFStringRef fileString = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,resourceData,kCFStringEncodingUTF8);
    
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFArrayRef lines = CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault,fileString,CFSTR("##"));
    CFRelease(fileString);
    
    for(CFIndex index = 0; index<CFArrayGetCount(lines); index++) {
        CFStringRef line = CFArrayGetValueAtIndex(lines, index);
        CFArrayRef keyAndValue = CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault,line,CFSTR("="));
        if(CFArrayGetCount(keyAndValue) == 2) {
            CFStringRef key = CFArrayGetValueAtIndex(keyAndValue, 0);
            CFMutableStringRef  mutKey = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(key),key);
            CFStringFindAndReplace (mutKey,CFSTR(" "), CFSTR(""),CFRangeMake(0,CFStringGetLength(mutKey)),0);
            CFStringRef value = CFArrayGetValueAtIndex(keyAndValue, 1);
            CFDictionarySetValue(dict, mutKey, value);
            CFRelease(mutKey);
        }
        if(keyAndValue) CFRelease(keyAndValue);
    }
    CFRelease(lines);
    return dict;
}

CFDictionaryRef PSDatasetImportBrukerCreateDictionaryWithJCAMPData2(CFDataRef contents)
{
    CFStringRef temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,contents,kCFStringEncodingUTF8);
    CFMutableStringRef fileString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
    CFRelease(temp);
    
    CFArrayRef array = (CFArrayRef) [(NSString *) fileString componentsSeparatedByString:@"##"];
    CFRelease(fileString);
    CFMutableArrayRef lines = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    if(NULL==lines) return NULL;
    
    if(CFArrayGetCount(lines)<1) {
        CFRelease(lines);
        return NULL;
    }
    
    for(CFIndex index = 0; index<CFArrayGetCount(lines); index++) {
        CFMutableStringRef line = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, CFArrayGetValueAtIndex(lines, index));
        CFRange range =CFStringFind(line, CFSTR("$$"), 0);
        if(range.location != kCFNotFound) CFStringDelete(line, CFRangeMake(range.location, CFStringGetLength(line)-range.location));
        
        CFStringFindAndReplace(line, CFSTR("\r"), CFSTR(""), CFRangeMake(0, CFStringGetLength(line)), 0);
        CFStringTrim(line, CFSTR("\n"));
        CFStringTrimWhitespace(line);
        
        CFArraySetValueAtIndex (lines,index,line);
        CFRelease(line);
    }
    
    
    for(CFIndex index = CFArrayGetCount(lines)-1; index>=0; index--) {
        CFStringRef string =CFArrayGetValueAtIndex(lines, index);
        if(CFStringGetLength(string) == 0) CFArrayRemoveValueAtIndex(lines, index);
    }
    CFIndex index = 0;
    CFDictionaryRef dictionary =  PSDatasetImportJCAMPCreateDictionaryWithLines(lines, &index);
    CFRelease(lines);
    return dictionary;
}

CFArrayRef PSDatasetImportBrukerCreateDimensionsFromAcqpData(CFDataRef acqpData, CFIndex *numberOfPointsInDim0, int *byteOrder, CFErrorRef *error)
{
    CFDictionaryRef dimensionsMetaData = PSDatasetImportBrukerCreateDictionaryWithJCAMPData2(acqpData);
    CFStringRef byteOrderString = CFDictionaryGetValue(dimensionsMetaData, CFSTR("$BYTORDA"));
    if(CFStringCompare(byteOrderString, CFSTR("little"), 0)==kCFCompareEqualTo) *byteOrder = 0;
    else *byteOrder = 1;
    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL,error);
    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL,error);
    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL,error);

    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFIndex numberOfDimensions = CFStringGetIntValue(CFDictionaryGetValue(dimensionsMetaData, CFSTR("$ACQ_dim")));
    CFStringRef string = CFDictionaryGetValue(dimensionsMetaData, CFSTR("$ACQ_size"));
    CFArrayRef array = (CFArrayRef) [(NSString *) string componentsSeparatedByString:@"\n"];

    CFArrayRef sizes = (CFArrayRef) [(NSString *) CFArrayGetValueAtIndex(array, 1) componentsSeparatedByString:@" "];
    CFIndex npts[numberOfDimensions];
    for(CFIndex index=0;index<numberOfDimensions; index++) {
        npts[index] = CFStringGetIntValue(CFArrayGetValueAtIndex(sizes, index));
    }
    
    
    for(CFIndex dimensionIndex = 0; dimensionIndex<numberOfDimensions; dimensionIndex++) {
        if(dimensionIndex == 0) {
            *numberOfPointsInDim0 = npts[0]/2;
            /* 	Next lines are to correct for Bruker fids which must be saved in multiples of 2048 bytes */
            double n = (double) npts[0]/256;
            n = ceil(n);
            CFIndex td = (int32_t) n*256;
            
            npts[0] = td/2;
            
            
            PSScalarRef originOffset = PSScalarCreateWithDouble(0.0, seconds);
            PSScalarRef SFO1 = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionsMetaData, CFSTR("$SFO1"))), megahertz);
            PSScalarRef inverseOriginOffset = PSScalarCreateCopy(SFO1);

            PSScalarRef SW_h = NULL;
            if(CFDictionaryContainsKey(dimensionsMetaData, CFSTR("$SW_h"))) {
                SW_h = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionsMetaData, CFSTR("$SW_h"))), hertz);
            }
            
            PSScalarRef SW = NULL;
            if(CFDictionaryContainsKey(dimensionsMetaData, CFSTR("$SW"))) {
                SW = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionsMetaData, CFSTR("$SW"))), hertz);
            }
            
            double dwell = 0;
            if(SW_h) {
                double temp = PSScalarDoubleValue(SW_h);
                if(temp) dwell = 1./temp;
            }
            else if(SW) {
                dwell = 1./(PSScalarDoubleValue(SW)*PSScalarDoubleValue(SFO1));
            }
            else {
                if(error) {
                    CFRelease(dimensionsMetaData);
                    CFStringRef desc = CFSTR("No sampling interval found in first dimension.");
                    *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                    kPSFoundationErrorDomain,
                                                                    0,
                                                                    (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                    (const void* const*)&desc,
                                                                    1);
                }
                return nil;
                
            }
            
            // Put the rest into NMR meta-data

            PSScalarRef increment = PSScalarCreateWithDouble(dwell, seconds);
            if(SW_h) CFRelease(SW_h);
            if(SW) CFRelease(SW);

            CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            
            CFStringRef stringValue = PSScalarCreateStringValue(SFO1);
            CFDictionaryAddValue(nmr, CFSTR("receiver frequency"), stringValue);
            CFRelease(stringValue);
            CFRelease(SFO1);

            CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionaryAddValue(metaData, CFSTR("NMR"), nmr);
            CFRelease(nmr);
            
            PSDimensionRef dim = PSLinearDimensionCreateDefault(npts[0], increment, kPSQuantityTime,kPSQuantityFrequency);
            PSDimensionSetOriginOffset(dim, originOffset);
            PSDimensionSetInverseOriginOffset(dim, inverseOriginOffset);
            PSDimensionSetMetaData(dim, metaData);
            PSDimensionSetInverseMadeDimensionless(dim, true);
            
            CFRelease(increment);
            CFRelease(originOffset);
            CFRelease(inverseOriginOffset);
            CFRelease(metaData);
            PSDimensionMakeNiceUnits(dim);

            CFArrayAppendValue(dimensions, dim);
            CFRelease(dim);

        }
        else {
            if(npts[dimensionIndex]>1) {
                PSScalarRef originOffset = PSScalarCreateWithDouble(0.0, seconds);
                
                CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("$SFO%ld"),dimensionIndex+1);
                PSScalarRef SFON = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionsMetaData, key)), megahertz);
                CFRelease(key);
                
                PSScalarRef inverseOriginOffset = PSScalarCreateCopy(SFON);
                
                PSScalarRef SW_h = NULL;
                if(CFDictionaryContainsKey(dimensionsMetaData, CFSTR("$SW_h"))) {
                    SW_h = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionsMetaData, CFSTR("$SW_h"))), hertz);
                }
                
                PSScalarRef SW = NULL;
                if(CFDictionaryContainsKey(dimensionsMetaData, CFSTR("$SW"))) {
                    SW = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionsMetaData, CFSTR("$SW"))), hertz);
                }
                
                
                double dwell = 0;
                if(SW_h) {
                    double temp = PSScalarDoubleValue(SW_h);
                    if(temp) dwell = 1./temp;
                }
                else if(SW) {
                    dwell = 1./(PSScalarDoubleValue(SW)*PSScalarDoubleValue(SFON));
                }
                else {
                    if(error) {
                        CFStringRef desc = CFSTR("No sampling interval found in second dimension.");
                        *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                        kPSFoundationErrorDomain,
                                                                        0,
                                                                        (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                        (const void* const*)&desc,
                                                                        1);
                    }
                    return nil;
                    
                }
                
                PSScalarRef increment = PSScalarCreateWithDouble(dwell, seconds);
                if(SW_h) CFRelease(SW_h);
                if(SW) CFRelease(SW);
                CFRelease(SFON);
                
                // Put the rest into NMR meta-data
                
                CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                
                CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFDictionaryAddValue(metaData, CFSTR("NMR"), nmr);
                CFRelease(nmr);
                
                PSDimensionRef dim = PSLinearDimensionCreateDefault(npts[dimensionIndex], increment, kPSQuantityTime,kPSQuantityFrequency);
                PSDimensionSetOriginOffset(dim, originOffset);
                PSDimensionSetInverseOriginOffset(dim, inverseOriginOffset);
                PSDimensionSetMetaData(dim, metaData);
                PSDimensionSetInverseMadeDimensionless(dim, true);
                PSDimensionSetInverseMadeDimensionless(dim, true);
                
                
                CFRelease(increment);
                CFRelease(originOffset);
                CFRelease(inverseOriginOffset);
                CFRelease(metaData);
                
                PSDimensionMakeNiceUnits(dim);
                CFArrayAppendValue(dimensions, dim);
                CFRelease(dim);
            }
        }
    }

    CFRelease(dimensionsMetaData);
    return dimensions;
}

CFArrayRef PSDatasetImportBrukerCreateDimensionsFromAcqusArray(CFArrayRef acqusArray, CFIndex *numberOfPointsInDim0, int *byteOrder, int*dtypa, CFErrorRef *error)
{
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL,error);
    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL,error);
    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL,error);
    
    CFIndex size = 1;

    for(CFIndex dimensionIndex = 0; dimensionIndex<CFArrayGetCount(acqusArray); dimensionIndex++) {
        CFDataRef acqusData = CFArrayGetValueAtIndex(acqusArray, dimensionIndex);
        CFDictionaryRef dimensionMetaData = PSDatasetImportBrukerCreateDictionaryWithJCAMPData2(acqusData);
        if(dimensionIndex == 0) {
            // BYTORDA (1 = big endian, 0 = little endian
            
            *byteOrder = CFStringGetIntValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$BYTORDA")));
            *dtypa = CFStringGetIntValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$DTYPA")));
            CFIndex td = CFStringGetIntValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$TD")));
            *numberOfPointsInDim0 = td/2;
            
            /* 	Next lines are to correct for Bruker fids which must be saved in multiples of 2048 bytes */
            // But these lines no longer needed for Neo console data
            double n = (double) td/256;
            n = ceil(n);
            td = (int32_t) n*256;
            CFIndex npts = td/2;
            
            PSScalarRef originOffset = PSScalarCreateWithDouble(0.0, seconds);
            PSScalarRef SFO1 = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$SFO1"))), megahertz);
            PSScalarRef inverseOriginOffset = PSScalarCreateCopy(SFO1);
            
            PSScalarRef SW_h = NULL;
            if(CFDictionaryContainsKey(dimensionMetaData, CFSTR("$SW_h"))) {
                SW_h = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$SW_h"))), hertz);
            }
            
            PSScalarRef SW = NULL;
            if(CFDictionaryContainsKey(dimensionMetaData, CFSTR("$SW"))) {
                SW = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$SW"))), hertz);
            }
            
            
            double dwell = 0;
            if(SW_h) {
                double temp = PSScalarDoubleValue(SW_h);
                if(temp) dwell = 1/temp;
            }
            else if(SW) {
                dwell = 1./(PSScalarDoubleValue(SW)*PSScalarDoubleValue(SFO1));
            }
            else {
                if(error) {
                    CFStringRef desc = CFSTR("No sampling interval found in first dimension.");
                    *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                    kPSFoundationErrorDomain,
                                                                    0,
                                                                    (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                    (const void* const*)&desc,
                                                                    1);
                }
                CFRelease(dimensionMetaData);
                return nil;
                
            }
            
            PSScalarRef increment = PSScalarCreateWithDouble(dwell, seconds);
            if(SW_h) CFRelease(SW_h);
            if(SW) CFRelease(SW);
            
            PSDimensionRef dim = PSLinearDimensionCreateDefault(npts, increment, kPSQuantityTime,kPSQuantityFrequency);
            PSDimensionSetOriginOffset(dim, originOffset);
            PSDimensionSetInverseOriginOffset(dim, inverseOriginOffset);
            // Put the rest into NMR meta-data
            
            CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionaryAddValue(nmr, CFSTR("Bruker"), dimensionMetaData);
            CFRelease(dimensionMetaData);
            
            CFStringRef stringValue = PSScalarCreateStringValue(SFO1);
            CFDictionaryAddValue(nmr, CFSTR("receiver frequency"), stringValue);
            CFRelease(stringValue);
            CFRelease(SFO1);
            
            CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionaryAddValue(metaData, CFSTR("NMR"), nmr);
            CFRelease(nmr);
            PSDimensionSetMetaData(dim, metaData);

            PSDimensionSetInverseMadeDimensionless(dim, true);
            
            size *= npts;
            
            CFRelease(increment);
            CFRelease(originOffset);
            CFRelease(inverseOriginOffset);
            CFRelease(metaData);
            
            PSDimensionMakeNiceUnits(dim);
            CFArrayAppendValue(dimensions, dim);
            CFRelease(dim);
        }
        else {
            CFIndex npts = CFStringGetIntValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$TD")));
            if(npts>1) {
                PSScalarRef originOffset = PSScalarCreateWithDouble(0.0, seconds);
                PSScalarRef SFO1 = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$SFO1"))), megahertz);
                PSScalarRef inverseOriginOffset = PSScalarCreateCopy(SFO1);
                
                PSScalarRef SW_h = NULL;
                if(CFDictionaryContainsKey(dimensionMetaData, CFSTR("$SW_h"))) {
                    SW_h = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$SW_h"))), hertz);
                }
                
                PSScalarRef SW = NULL;
                if(CFDictionaryContainsKey(dimensionMetaData, CFSTR("$SW"))) {
                    SW = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("$SW"))), hertz);
                }
                
                
                double dwell = 0;
                if(SW_h) {
                    double temp = PSScalarDoubleValue(SW_h);
                    if(temp) dwell = 1./temp;
                }
                else if(SW) {
                    dwell = 1./(PSScalarDoubleValue(SW)*PSScalarDoubleValue(SFO1));
                }
                else {
                    if(error) {
                        CFStringRef desc = CFSTR("No sampling interval found in second dimension.");
                        *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                        kPSFoundationErrorDomain,
                                                                        0,
                                                                        (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                        (const void* const*)&desc,
                                                                        1);
                    }
                    CFRelease(dimensionMetaData);
                    return nil;
                    
                }
                
                PSScalarRef increment = PSScalarCreateWithDouble(dwell, seconds);
                if(SW_h) CFRelease(SW_h);
                if(SW) CFRelease(SW);
                CFRelease(SFO1);
                
                PSDimensionRef dim = PSLinearDimensionCreateDefault(npts, increment, kPSQuantityTime,kPSQuantityFrequency);
                PSDimensionSetOriginOffset(dim, originOffset);
                PSDimensionSetInverseOriginOffset(dim, inverseOriginOffset);

                // Put the rest into NMR meta-data
                
                CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFDictionaryAddValue(nmr, CFSTR("Bruker"), dimensionMetaData);
                CFRelease(dimensionMetaData);
                
                CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFDictionaryAddValue(metaData, CFSTR("NMR"), nmr);
                CFRelease(nmr);
                PSDimensionSetMetaData(dim, metaData);

                PSDimensionSetInverseMadeDimensionless(dim, true);
                
                size *= npts;
                
                CFRelease(increment);
                CFRelease(originOffset);
                CFRelease(inverseOriginOffset);
                CFRelease(metaData);
                PSDimensionMakeNiceUnits(dim);

                CFArrayAppendValue(dimensions, dim);
                CFRelease(dim);
            }
            else CFRelease(dimensionMetaData);
        }
        
    }
    return dimensions;
}

PSDatasetRef PSDatasetImportBrukerCreateSignalWithFolderData(CFDataRef fidData,
                                                             CFDataRef serData,
                                                             CFArrayRef acqusArray,
                                                             CFDataRef acqpData,
                                                             CFDataRef specParData,
                                                             CFDataRef shimvaluesData,
                                                             CFDataRef vdlistData,
                                                             CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    bool fid = false;
    bool ser = false;
    bool specPar = false;
    bool shimValues = false;
    bool vdlist = false;
    bool acqp = false;
    
    if(shimvaluesData) shimValues = true;
    if(fidData) fid = true;
    if(serData) ser = true;
    if(acqpData) acqp = true;
    if(specParData) specPar = true;
    if(vdlistData) vdlist = true;
    

    if(ser&&fid) {
        if(error) {
            CFStringRef desc = CFSTR("Two Bruker binary files (fid, ser) were found.  Cannot proceed.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return nil;
    }
    CFDataRef contents;
    if(fid) contents = fidData;
    else if(ser) contents = serData;
    else {
        if(error) {
            CFStringRef desc = CFSTR("No Bruker binary file (fid, ser) could be found.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return nil;
    }
    
    
    CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    int byteOrder = 0;
    int dtypa = 0;
    CFIndex numberOfPointsInDim0 = 1;
    CFArrayRef dimensions = NULL;
    if(CFArrayGetCount(acqusArray)>0) {
        dimensions = PSDatasetImportBrukerCreateDimensionsFromAcqusArray(acqusArray, &numberOfPointsInDim0,&byteOrder, &dtypa, error);
    }
    else if (acqpData) {
        dimensions = PSDatasetImportBrukerCreateDimensionsFromAcqpData(acqpData, &numberOfPointsInDim0,&byteOrder, error);
    }
    else {
        if(error) {
            CFStringRef desc = CFSTR("No Bruker acquisition paramters file (acqus, acqp) could be found.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return nil;
    }
    
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    // Check if file size is consistent with what is expected.
    CFIndex numberOfSamplesInFile = CFDataGetLength(contents)/sizeof(UInt32);
    if(dtypa==2) numberOfSamplesInFile /=2; // divide by 2 since it uses uint64
    numberOfSamplesInFile /=2;   // divide by 2 for complex data

    PSDimensionRef directDimension = CFArrayGetValueAtIndex(dimensions, 0);

    if(size>numberOfSamplesInFile) {
        if(error) {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("Number Of Samples In data file, %ld, not consistent with dimensions, %ld "),(long)numberOfSamplesInFile,(long)size);
            *error  = PSCFErrorCreate(CFSTR("Cannot open file"), reason, NULL);
            CFRelease(reason);
        }
        CFRelease(dimensions);
        return nil;
    }
    else if(size<numberOfSamplesInFile) {
        numberOfSamplesInFile = size;
    }

//    else if(size<numberOfSamplesInFile) {
//        PSIndexSetRef indexSet = PSIndexSetCreateWithIndex(0);
//        CFIndex indirectSize = PSDimensionCalculateSizeFromDimensionsIgnoreDimensions(dimensions, indexSet);
//        CFRelease(indexSet);
//        CFIndex npts = numberOfSamplesInFile/indirectSize;
//        PSDimensionSetNpts(directDimension, npts);
//        size = PSDimensionCalculateSizeFromDimensions(dimensions);
//    }
    
    CFMutableDataRef values = CFDataCreateMutable(kCFAllocatorDefault, size*sizeof(float complex));
    CFDataSetLength(values, size*sizeof(float complex));
    
    float complex *response = (float complex *) CFDataGetMutableBytePtr(values);
    UInt8 *bytes = (UInt8 *) CFDataGetBytePtr(contents);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(numberOfSamplesInFile, queue,
                   ^(size_t memOffset) {
                       if(dtypa==0) {
                           CFIndex count = 2 * memOffset * sizeof(UInt32);
                           UInt32 datum;
                           if(byteOrder) datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
                           else datum = (*((UInt32 *) &(bytes[count])));
                           
                           count = (2 * memOffset +1) * sizeof(UInt32);
                           void *ptr = &datum;
                           int32_t real = *((int32_t *)ptr);
                           
                           if(byteOrder) datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
                           else datum = (*((UInt32 *) &(bytes[count])));
                           
                           ptr = &datum;
                           int32_t imag = *((int32_t *)ptr);
                           
                           float complex temp = real + I*imag;
                           response[memOffset] = temp;
                       }
                       else if(dtypa==2) {
                           CFIndex count = 2 * memOffset * sizeof(UInt64);
                           UInt64 datum;
                           if(byteOrder) datum = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                           else datum = (*((UInt64 *) &(bytes[count])));
                           
                           count = (2 * memOffset +1) * sizeof(double);
                           void *ptr = &datum;
                           double real = *((double *)ptr);
                           
                           if(byteOrder) datum = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                           else datum = (*((UInt64 *) &(bytes[count])));
                           
                           ptr = &datum;
                           double imag = *((double *)ptr);
                           
                           float complex temp = real + I*imag;
                           response[memOffset] = temp;
                       }
                   }
                   );
    
    PSDatasetRef dataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(dataset, dimensions, NULL);
    CFRelease(dimensions);

    PSDependentVariableRef dependentVariable = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
    PSDependentVariableSetComponentAtIndex(dependentVariable, values, 0);
    CFRelease(values);


//     Next lines are to correct for Bruker fids which must be saved in multiples of 2048 bytes
    PSDimensionRef dim0 = PSDatasetGetDimensionAtIndex(dataset, 0);
    if(numberOfPointsInDim0 != PSDimensionGetNpts(dim0)) {
        dim0 = PSDimensionCreateCopy(dim0);
        PSDimensionSetNpts(dim0, numberOfPointsInDim0);
        PSDatasetReplaceDimensionAtIndex(dataset, 0, dim0, error);
        CFRelease(dim0);
    }

    if(specPar) {
        CFDictionaryRef specParMetaData = PSDatasetImportBrukerCreateDictionaryWithJCAMPData2(specParData);
        if(specParMetaData) {
            CFDictionaryAddValue(metaData, CFSTR("specPar"), specParMetaData);
            CFRelease(specParMetaData);
        }
    }
    
    
    if(shimValues) {
        CFDictionaryRef shimValuesMetaData = PSDatasetImportBrukerCreateDictionaryWithJCAMPData2(shimvaluesData);
        if(shimValuesMetaData) {
            CFDictionaryAddValue(metaData, CFSTR("shimValues"), shimValuesMetaData);
            CFRelease(shimValuesMetaData);
        }
    }
    
    if(vdlist) {
        CFDictionaryRef vdlistMetaData = PSDatasetImportBrukerCreateDictionaryWithJCAMPData2(vdlistData);
        if(vdlistMetaData) {
            CFDictionaryAddValue(metaData, CFSTR("vdlist"), vdlistMetaData);
            CFRelease(vdlistMetaData);
        }
    }
    
    PSDatasetSetMetaData(dataset, metaData);
    
    PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
    PSPlotReset(thePlot);
    PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);
   return dataset;
}

