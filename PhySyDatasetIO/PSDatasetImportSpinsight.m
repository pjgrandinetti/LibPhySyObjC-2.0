//
//  PSDatasetImportSpinsight.m
//  physy
//
//  Created by Philip on 6/29/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

//bool PSDatasetImportSpinSightIsValidURL(CFURLRef folderURL)
//{
//    CFDictionaryRef properties;
//    SInt32 errorCode;
//    bool result = CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,folderURL,NULL,&properties,NULL,&errorCode);
//    bool acq = false;
//    bool data = false;
//    bool apnd = false;
//    if(result && properties) {
//        CFArrayRef urls = CFDictionaryGetValue(properties, kCFURLFileDirectoryContents);
//        for(CFIndex index=0; index<CFArrayGetCount(urls); index++) {
//            CFStringRef fileName = CFURLCopyLastPathComponent(CFArrayGetValueAtIndex(urls, index));
//            if(CFStringCompare(fileName, CFSTR("acq"), 0)==kCFCompareEqualTo) acq = true;
//            if(CFStringCompare(fileName, CFSTR("data"), 0)==kCFCompareEqualTo) data = true;
////            if(CFStringCompare(fileName, CFSTR("apnd"), 0)==kCFCompareEqualTo) apnd = true;
//            CFRelease(fileName);
//        }
//    }
//    if(properties) CFRelease(properties);
//    return (acq && data);
//}
//
//
//CFIndex PSDatasetImportSpinSightNumberOfDimensionsForURL(CFURLRef folderURL)
//{
//    CFDictionaryRef properties;
//    SInt32 errorCode;
//    bool result = CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,folderURL,NULL,&properties,NULL,&errorCode);
//    bool acq = false;
//    bool data = false;
//    bool apnd = false;
//    if(result && properties) {
//        CFArrayRef urls = CFDictionaryGetValue(properties, kCFURLFileDirectoryContents);
//        for(CFIndex index=0; index<CFArrayGetCount(urls); index++) {
//            CFStringRef fileName = CFURLCopyLastPathComponent(CFArrayGetValueAtIndex(urls, index));
//            if(CFStringCompare(fileName, CFSTR("acq"), 0)==kCFCompareEqualTo) acq = true;
//            if(CFStringCompare(fileName, CFSTR("data"), 0)==kCFCompareEqualTo) data = true;
//            if(CFStringCompare(fileName, CFSTR("apnd"), 0)==kCFCompareEqualTo) apnd = true;
//            CFRelease(fileName);
//        }
//    }
//    if(properties) CFRelease(properties);
//    if(acq && data) {
//        if(apnd) return 2;
//        return 1;
//    }
//    return 0;
//}
//

//static CFDictionaryRef PSDatasetImportSpinSighCreateDictionaryWithSpinSightParametersAtURL(CFURLRef url)
//{
//    CFDataRef resourceData;
//    SInt32 errorCode;
//    CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,url,&resourceData,NULL,NULL,&errorCode);
//    CFStringRef temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,resourceData,kCFStringEncodingUTF8);
//    CFMutableStringRef fileString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
//    CFRelease(temp);
//    CFRelease(resourceData);
//    
//    CFStringFindAndReplace(fileString, CFSTR("\r"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(fileString)), 0);
//    
//    CFArrayRef lines = CFStringCreateArrayBySeparatingStrings (kCFAllocatorDefault,fileString,CFSTR("\n"));
//    CFRelease(fileString);
//    
//    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
//    
//    for(CFIndex index = 0; index<CFArrayGetCount(lines); index++) {
//        CFStringRef line = CFArrayGetValueAtIndex(lines, index);
//        CFArrayRef keyAndValue = CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault,line,CFSTR("="));
//        if(CFArrayGetCount(keyAndValue) == 2) {
//            CFStringRef key = CFArrayGetValueAtIndex(keyAndValue, 0);
//            CFMutableStringRef  mutKey = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(key),key);
//            CFStringFindAndReplace (mutKey,CFSTR(" "), CFSTR(""),CFRangeMake(0,CFStringGetLength(mutKey)),0);
//            CFStringRef value = CFArrayGetValueAtIndex(keyAndValue, 1);
//            
//            CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(value),value);
//            CFStringFindAndReplace (mutString,CFSTR(" "), CFSTR(""),CFRangeMake(0,CFStringGetLength(mutString)),0);
//            
//            CFDictionarySetValue(dict, mutKey, value);
//            CFRelease(mutString);
//            CFRelease(mutKey);
//        }
//        if(keyAndValue) CFRelease(keyAndValue);
//    }
//    CFRelease(lines);
//    return dict;
//}

static CFDictionaryRef PSDatasetImportSpinSightCreateDictionaryWithSpinSightParametersData(CFDataRef resourceData)
{
    CFStringRef temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,resourceData,kCFStringEncodingUTF8);
    CFMutableStringRef fileString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
    CFRelease(temp);
    
    CFStringFindAndReplace(fileString, CFSTR("\r"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(fileString)), 0);
    
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
            
            CFDictionarySetValue(dict, mutKey, value);
            CFRelease(mutString);
            CFRelease(mutKey);
        }
        if(keyAndValue) CFRelease(keyAndValue);
    }
    CFRelease(lines);
    return dict;
}

PSDatasetRef PSDatasetImportSpinSightCreateSignalWithFolderData(CFDataRef dataData,
                                                                CFDataRef acqData,
                                                                CFDataRef acq2Data,
                                                                CFDataRef procData,
                                                                CFDataRef proc_setupData,
                                                                CFDataRef apndData,
                                                                CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    bool acq = false;
    bool acq2 = false;
    bool data = false;
    bool proc = false;
    bool proc_setup = false;
    bool apnd = false;
    
    if(acqData) acq = true;
    if(acq2Data) acq2 = true;
    if(dataData) data = true;
//    if(procData) proc = true;
//    if(proc_setupData) proc_setup = true;
    if(apndData) apnd = true;

    CFDataRef contents;
    if(data) contents = dataData;
    else {
        fprintf(stderr, "no Spinsight binary file could be found.\n");
        return nil;
    }

    CFIndex npts = 1;
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL,error);
//    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL,error);
    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL,error);
    
    CFIndex size = 1;
    if(acq) {
        CFDictionaryRef dimensionMetaData = PSDatasetImportSpinSightCreateDictionaryWithSpinSightParametersData(acqData);
        
        npts = CFStringGetIntValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("al")));
        
        PSScalarRef originOffset = PSScalarCreateWithDouble(0.0, seconds);
        PSScalarRef inverseOriginOffset = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("sf1"))), megahertz);

        PSScalarRef increment = PSScalarCreateWithCFString(CFDictionaryGetValue(dimensionMetaData, CFSTR("dw")), error);

        PSScalarRef SFO1 = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("sf1"))), megahertz);
        
        // Put the rest into NMR meta-data
        
        CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(nmr, CFSTR("SpinSight"), dimensionMetaData);
        
        CFStringRef stringValue = PSScalarCreateStringValue(SFO1);
        CFDictionaryAddValue(nmr, CFSTR("receiver frequency"), stringValue);
        CFRelease(stringValue);
        CFRelease(SFO1);
        
        CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(metaData, CFSTR("NMR"), nmr);
        CFRelease(nmr);
        
        PSDimensionRef dim0 = PSLinearDimensionCreateDefault(npts, increment, kPSQuantityTime,kPSQuantityFrequency);
        PSDimensionSetOriginOffset(dim0, originOffset);
        PSDimensionSetInverseOriginOffset(dim0, inverseOriginOffset);
        PSDimensionSetMetaData(dim0, metaData);
        PSDimensionSetInverseMadeDimensionless(dim0, true);

        size *= npts;
        
        CFRelease(increment);
        CFRelease(originOffset);
        CFRelease(inverseOriginOffset);
        CFRelease(metaData);
        PSDimensionMakeNiceUnits(dim0);
        CFArrayAppendValue(dimensions, dim0);
        CFRelease(dim0);
        
        
        
        if((apnd || acq2) && CFDictionaryContainsKey(dimensionMetaData, CFSTR("al2"))) {
            
            npts = CFStringGetIntValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("al2")));
            
            PSScalarRef originOffset = PSScalarCreateWithDouble(0.0, seconds);
            
            if(CFDictionaryContainsKey(dimensionMetaData, CFSTR("sf2"))) {
                CFStringRef sf2String = CFDictionaryGetValue(dimensionMetaData, CFSTR("sf2"));
                inverseOriginOffset = PSScalarCreateWithDouble(CFStringGetDoubleValue(sf2String), megahertz);
            }
            else {
                inverseOriginOffset = PSScalarCreateWithDouble(CFStringGetDoubleValue(CFDictionaryGetValue(dimensionMetaData, CFSTR("sf1"))), megahertz);
            }
            

            PSScalarRef increment = PSScalarCreateWithCFString(CFDictionaryGetValue(dimensionMetaData, CFSTR("dw2")), error);
                                                                      
            // Put the rest into NMR meta-data
            
            CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionaryAddValue(nmr, CFSTR("SpinSight"), dimensionMetaData);
            
            CFStringRef stringValue = PSScalarCreateStringValue(inverseOriginOffset);
            CFDictionaryAddValue(nmr, CFSTR("receiver frequency"), stringValue);
            CFRelease(stringValue);
            
            CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionaryAddValue(metaData, CFSTR("NMR"), nmr);
            CFRelease(nmr);
            
            PSDimensionRef dim1 = PSLinearDimensionCreateDefault(npts, increment, kPSQuantityTime,kPSQuantityFrequency);
            PSDimensionSetOriginOffset(dim1, originOffset);
            PSDimensionSetInverseOriginOffset(dim1, inverseOriginOffset);
            PSDimensionSetMetaData(dim1, metaData);
            PSDimensionSetInverseMadeDimensionless(dim1, true);

            size *= npts;
            
            
            CFRelease(increment);
            CFRelease(originOffset);
            CFRelease(inverseOriginOffset);
            CFRelease(metaData);
            PSDimensionMakeNiceUnits(dim0);

            CFArrayAppendValue(dimensions, dim1);
            CFRelease(dim1);
            
        }
        CFRelease(dimensionMetaData);
        
    }
    
    
    CFMutableDataRef values = CFDataCreateMutable(kCFAllocatorDefault, size*sizeof(float complex));
    CFDataSetLength(values, size*sizeof(float complex));
    
    float complex *response = (float complex *) CFDataGetMutableBytePtr(values);
    UInt8 *bytes = (UInt8 *) CFDataGetBytePtr(contents);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(size, queue,
                   ^(size_t memOffset) {
                       CFIndex count = memOffset * sizeof(UInt32);
                       UInt32 datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
                       void *ptr = &datum;
                       int32_t value = *((int32_t *)ptr);
                       response[memOffset] = value;
                   }
                   );
    
    dispatch_apply(size, queue,
                   ^(size_t memOffset) {
                       CFIndex count = (memOffset + size) * sizeof(UInt32);
                       UInt32 datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
                       void *ptr = &datum;
                       int32_t value = *((int32_t *)ptr);
                       response[memOffset] += value*I;
                   }
                   );
    
    
    PSDatasetRef dataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(dataset, dimensions, NULL);
    CFRelease(dimensions);
    
    PSDependentVariableRef dependentVariable = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
    PSDependentVariableSetComponentAtIndex(dependentVariable, values, 0);
    PSDependentVariableSetQuantityName(dependentVariable, kPSQuantityDimensionless);
    CFRelease(values);
    

    PSPlotRef thePlot = PSDependentVariableGetPlot(dependentVariable);
    PSPlotReset(thePlot);
    PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);

    return dataset;
}


