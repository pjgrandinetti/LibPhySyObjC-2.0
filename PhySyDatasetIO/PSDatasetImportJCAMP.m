//
//  PSDatasetImportJCAMP.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 2/21/14.
//  Copyright (c) 2014 PhySy. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

//bool PSDatasetImportJCAMPIsValidURL(CFURLRef url)
//{
//    bool result = false;
//    CFStringRef extension = CFURLCopyPathExtension(url);
//    if(extension) {
//        if(CFStringCompare(extension, CFSTR("jdx"), 0) == kCFCompareEqualTo) result = true;
//        CFRelease(extension);
//    }
//    return result;
//}
//
//CFIndex PSDatasetImportJCAMPNumberOfDimensionsForURL(CFURLRef url)
//{
//    return 0;
//}

CFDictionaryRef  PSDatasetImportJCAMPCreateDictionaryWithLines(CFArrayRef lines, CFIndex *index)
{
    // Make sure first line is TITLE or DTYPx
    CFStringRef line = (CFStringRef) CFArrayGetValueAtIndex(lines, 0);
    bool dtypx = false;
    if(CFStringCompare(line, CFSTR("DTYPx"), 0)==kCFCompareEqualTo) {
        line = (CFStringRef) CFArrayGetValueAtIndex(lines, 1);
        *index = 1;
        dtypx=true;
    }
    CFArrayRef array = (CFArrayRef) [(NSString *) line componentsSeparatedByString:@"="];
    CFStringRef key0 = CFArrayGetValueAtIndex(array, 0);
    if(CFStringCompare(key0, CFSTR("TITLE"), 0)!=kCFCompareEqualTo) return NULL;
    
    // Valid first line, let's continue processing title and making first entry in dictionary.
    // Create dictionary with each entrying holding labeled-data-records or blocks
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(dictionary, key0, CFArrayGetValueAtIndex(array, 1));
    if(dtypx) CFDictionaryAddValue(dictionary, CFSTR("DTYPx"), kCFBooleanTrue);
    
    CFIndex start = *index+1;
    for(*index = start; *index<CFArrayGetCount(lines); (*index)++) {
        CFStringRef line = CFArrayGetValueAtIndex(lines, (*index));
        CFArrayRef array = (CFArrayRef) [(NSString *) line componentsSeparatedByString:@"="];
        if(CFArrayGetCount(array) == 2) {
            CFStringRef key = CFArrayGetValueAtIndex(array, 0);
            if(CFStringGetLength(key)) {
                if(CFStringCompare(key, CFSTR("TITLE"), kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
                    key = CFSTR("BLOCK_ARRAY");
                    CFMutableArrayRef blockArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
                    CFDictionaryRef blockDictionary = PSDatasetImportJCAMPCreateDictionaryWithLines(lines,index);
                    CFArrayAppendValue(blockArray, blockDictionary);
                    CFRelease(blockDictionary);
                }
                else if(CFStringCompare(key, CFSTR("END"), kCFCompareCaseInsensitive)==kCFCompareEqualTo) return dictionary;
                else  {
                    CFStringRef value = CFArrayGetValueAtIndex(array, 1);
                    
                    CFMutableStringRef mutValue = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, value);
                    CFStringTrimWhitespace(mutValue);
                    CFDictionaryAddValue(dictionary, key, mutValue);
                    CFRelease(mutValue);
                }
            }
            
        }
    }
    return dictionary;

}


PSDatasetRef PSDatasetImportJCAMPCreateSignalWithData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
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

        CFStringFindAndReplace(line, CFSTR("\r"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(line)), 0);
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

    if(NULL==dictionary) return NULL;
    
    CFStringRef key = CFSTR("PEAK TABLE");
    if(CFDictionaryContainsKey(dictionary, key)) {
        if(error) {
            CFStringRef desc = CFSTR("JCAMP Peak Table file is unsupported.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        CFRelease(dictionary);
        return NULL;
    }
    

    
    // Read in JCAMP Core Header
    CFMutableDictionaryRef jcampDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFStringRef string = NULL;
    key = CFSTR("TITLE");
    CFStringRef title = NULL;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            CFDictionaryAddValue(jcampDatasetMetaData, key, string);
            title = CFRetain(string);

        }
    }
    
    string = NULL;
    key = CFSTR("JCAMP-DX");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("DATA CLASS");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    bool nmrSpectrumType = false;
    bool irSpectrumType = false;
    bool eprSpectrumType = false;
    key = CFSTR("DATA TYPE");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            CFDictionaryAddValue(jcampDatasetMetaData, key, string);
            if(CFStringCompare(string, CFSTR("NMR SPECTRUM"), 0)==kCFCompareEqualTo) nmrSpectrumType = true;
            if(CFStringCompare(string, CFSTR("INFRARED SPECTRUM"), 0)==kCFCompareEqualTo) irSpectrumType = true;
            if(CFStringCompare(string, CFSTR("EPR SPECTRUM"), 0)==kCFCompareEqualTo) eprSpectrumType = true;
        }
    }

    string = NULL;
    key = CFSTR("ORIGIN");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("OWNER");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("BLOCKS");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("DATE");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("TIME");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("SPECTROMETER/DATA SYSTEM");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("INSTRUMENT PARAMETERS");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("SAMPLING PROCEDURE");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("XUNITS");
    PSUnitRef xUnits = NULL;
    PSUnitRef inverseXUnits = NULL;
    CFStringRef quantityName = NULL;
    CFStringRef inverseQuantityName = NULL;
    if(CFDictionaryContainsKey(dictionary, key)) {
        CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFStringRef) CFDictionaryGetValue(dictionary, key));
        if(string) {
            CFStringTrimWhitespace(string);
            CFDictionaryAddValue(jcampDatasetMetaData, key, string);
            if(CFStringCompare(string, CFSTR("1/CM"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitForParsedSymbol(CFSTR("1/cm"), &unit_multiplier, error);
                inverseXUnits = PSUnitForParsedSymbol(CFSTR("cm"), &unit_multiplier, error);
                quantityName = kPSQuantityWavenumber;
                inverseQuantityName = kPSQuantityLength;
            }
            if(CFStringCompare(string, CFSTR("VOLUME"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitForParsedSymbol(CFSTR("mL"), &unit_multiplier, error);
                inverseXUnits = PSUnitForParsedSymbol(CFSTR("1/mL"), &unit_multiplier, error);
                quantityName = kPSQuantityVolume;
                inverseQuantityName = kPSQuantityInverseVolume;
            }
            else if(CFStringCompare(string, CFSTR("m/z"), 0)== kCFCompareEqualTo || CFStringCompare(string, CFSTR("M/Z"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitByParsingSymbol(CFSTR("Th"), &unit_multiplier, error);
                inverseXUnits = PSUnitByParsingSymbol(CFSTR("(1/Th)"), &unit_multiplier, error);
                quantityName = kPSQuantityMassToChargeRatio;
                inverseQuantityName = kPSQuantityChargeToMassRatio;
            }
            else if(CFStringCompare(string, CFSTR("NANOMETERS"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitByParsingSymbol(CFSTR("nm"), &unit_multiplier, error);
                inverseXUnits = PSUnitForParsedSymbol(CFSTR("1/nm"), &unit_multiplier, error);
                quantityName = kPSQuantityLength;
                inverseQuantityName = kPSQuantityWavenumber;
            }
            else if(CFStringCompare(string, CFSTR("GAUSS"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitByParsingSymbol(CFSTR("G"), &unit_multiplier, error);
                inverseXUnits = PSUnitForParsedSymbol(CFSTR("1/G"), &unit_multiplier, error);
                quantityName = kPSQuantityMagneticFluxDensity;
                inverseQuantityName = kPSQuantityInverseMagneticFluxDensity;
            }
            else if(CFStringCompare(string, CFSTR("HZ"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitByParsingSymbol(CFSTR("Hz"), &unit_multiplier, error);
                inverseXUnits = PSUnitForSymbol(CFSTR("s"));
                quantityName = kPSQuantityFrequency;
                inverseQuantityName = kPSQuantityTime;
            }
            else if(CFStringCompare(string, CFSTR("TIME"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitByParsingSymbol(CFSTR("min"), &unit_multiplier, error);
                inverseXUnits = PSUnitForSymbol(CFSTR("Hz"));
                quantityName = kPSQuantityTime;
                inverseQuantityName = kPSQuantityFrequency;
            }
            else if(CFStringCompare(string, CFSTR("SECONDS"), 0)== kCFCompareEqualTo) {
                double unit_multiplier = 1;
                xUnits = PSUnitByParsingSymbol(CFSTR("s"), &unit_multiplier, error);
                inverseXUnits = PSUnitForSymbol(CFSTR("Hz"));
                quantityName = kPSQuantityTime;
                inverseQuantityName = kPSQuantityFrequency;
            }
            CFRelease(string);
        }
    }
    
    string = NULL;
    key = CFSTR("YUNITS");
//    PSUnitRef yUnits = NULL;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR("RESOLUTION");
    double resolution = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        resolution = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("COMMENT");
    CFStringRef description = NULL;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            CFDictionaryAddValue(jcampDatasetMetaData, key, string);
            description = CFRetain(string);
            
        }
    }
    
    
    string = NULL;
    key = CFSTR("FIRSTX");
    double firstX = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        firstX = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("LASTX");
    double lastX = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        lastX = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("DELTAX");
    double deltaX = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        deltaX = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("MAXY");
    double maxY = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        maxY = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("MINY");
    double minY = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        minY = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("XFACTOR");
    double xFactor = 1;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        xFactor = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("YFACTOR");
    double yFactor = 1;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        yFactor = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR("NPOINTS");
    CFIndex size = 1;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        size = CFStringGetIntValue(string);
    }
    
    string = NULL;
    key = CFSTR("FIRSTY");
    double firstY = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        firstY = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR(".OBSERVE FREQUENCY");
    double observeFrequency = 0;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
        observeFrequency = CFStringGetDoubleValue(string);
    }
    
    string = NULL;
    key = CFSTR(".OBSERVE NUCLEUS");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR(".ACQUISITION MODE");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    string = NULL;
    key = CFSTR(".AVERAGES");
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) CFDictionaryAddValue(jcampDatasetMetaData, key, string);
    }
    
    key = CFSTR("XYDATA");
    float data[2*size];
    float originOffsetValue = firstX;
    bool sqz = false;
    bool dif = false;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        
        CFMutableArrayRef dataLines = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFMutableArrayRef) [(NSString *) string componentsSeparatedByString:@"\n"]);
        
        CFIndex i=0;
        for(CFIndex index = 1; index<CFArrayGetCount(dataLines);index++) {
            CFMutableStringRef line = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, CFArrayGetValueAtIndex(dataLines, index));
            CFStringFindAndReplace(line, CFSTR("+"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(line)), 0);
            CFStringFindAndReplace(line, CFSTR("-"), CFSTR(" -"), CFRangeMake(0, CFStringGetLength(line)), 0);
            
            if(CFStringFindAndReplace(line, CFSTR("@"), CFSTR(" 0"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("A"), CFSTR(" 1"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("B"), CFSTR(" 2"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("C"), CFSTR(" 3"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("D"), CFSTR(" 4"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("E"), CFSTR(" 5"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("F"), CFSTR(" 6"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("G"), CFSTR(" 7"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("H"), CFSTR(" 8"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("I"), CFSTR(" 9"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            
            if(CFStringFindAndReplace(line, CFSTR("a"), CFSTR(" -1"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("b"), CFSTR(" -2"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("c"), CFSTR(" -3"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("d"), CFSTR(" -4"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("e"), CFSTR(" -5"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("f"), CFSTR(" -6"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("g"), CFSTR(" -7"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("h"), CFSTR(" -8"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            if(CFStringFindAndReplace(line, CFSTR("i"), CFSTR(" -9"), CFRangeMake(0, CFStringGetLength(line)), 0)) sqz = true;
            
            
            if(CFStringFindAndReplace(line, CFSTR("%"), CFSTR(" 0"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("J"), CFSTR(" 1"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("K"), CFSTR(" 2"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("L"), CFSTR(" 3"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("M"), CFSTR(" 4"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("N"), CFSTR(" 5"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("O"), CFSTR(" 6"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("P"), CFSTR(" 7"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("Q"), CFSTR(" 8"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("R"), CFSTR(" 9"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            
            if(CFStringFindAndReplace(line, CFSTR("j"), CFSTR(" -1"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("k"), CFSTR(" -2"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("l"), CFSTR(" -3"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("m"), CFSTR(" -4"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("n"), CFSTR(" -5"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("o"), CFSTR(" -6"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("p"), CFSTR(" -7"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("q"), CFSTR(" -8"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            if(CFStringFindAndReplace(line, CFSTR("r"), CFSTR(" -9"), CFRangeMake(0, CFStringGetLength(line)), 0)) dif = true;
            
            
            CFStringTrimWhitespace(line);
            CFMutableArrayRef array = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFMutableArrayRef) [(NSString *) line componentsSeparatedByString:@" "]);
            CFRelease(line);
            for(CFIndex jndex = CFArrayGetCount(array)-1; jndex>=0;jndex--) {
                CFStringRef item = CFArrayGetValueAtIndex(array, jndex);
                if(CFStringGetLength(item)==0) CFArrayRemoveValueAtIndex(array, jndex);
            }
            for(CFIndex jndex=0;jndex<CFArrayGetCount(array);jndex++) {
                CFMutableStringRef stringNumber = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, CFArrayGetValueAtIndex(array, jndex));
                int dup = 0;
                if(CFStringFindAndReplace(stringNumber, CFSTR("S"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 1;
                if(CFStringFindAndReplace(stringNumber, CFSTR("T"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 2;
                if(CFStringFindAndReplace(stringNumber, CFSTR("U"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 3;
                if(CFStringFindAndReplace(stringNumber, CFSTR("V"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 4;
                if(CFStringFindAndReplace(stringNumber, CFSTR("W"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 5;
                if(CFStringFindAndReplace(stringNumber, CFSTR("X"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 6;
                if(CFStringFindAndReplace(stringNumber, CFSTR("Y"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 7;
                if(CFStringFindAndReplace(stringNumber, CFSTR("Z"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 8;
                if(CFStringFindAndReplace(stringNumber, CFSTR("s"), CFSTR(" "), CFRangeMake(0, CFStringGetLength(stringNumber)), 0)) dup = 9;
                if(jndex>0) {
                    data[i] = CFStringGetDoubleValue(stringNumber);
                    if(dif && jndex>1) data[i] += data[i-1];
                    for(CFIndex kndex=0;kndex<dup;kndex++) {
                        i++;
                        data[i] = data[i-1];
                    }
                    i++;
                }
                CFRelease(stringNumber);
            }
            CFRelease(array);
        }
        CFRelease(dataLines);
    }

    CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) data, sizeof(float)*size);

    double sampleInc = (lastX - firstX)/(size-1);
    bool reverse = false;
    if(sampleInc<0) reverse = true;
    PSScalarRef increment = PSScalarCreateWithDouble(fabs(sampleInc), xUnits);
    PSScalarRef originOffset = PSScalarCreateWithDouble(originOffsetValue, xUnits);
    
    if(quantityName && CFStringCompare(quantityName,kPSQuantityFrequency,0)==kCFCompareEqualTo) {
        CFRelease(originOffset);
        PSUnitRef megahertz = PSUnitForSymbol(CFSTR("MHz"));
        originOffset = PSScalarCreateWithDouble(observeFrequency, megahertz);
    }
    else {
        originOffset = PSScalarCreateWithDouble(observeFrequency, xUnits);
    }
    PSScalarRef referenceOffset = PSScalarCreateWithDouble(0.0, xUnits);
    PSScalarRef inverseOriginOffset = PSScalarCreateWithDouble(0.0, inverseXUnits);
    if(inverseQuantityName && CFStringCompare(inverseQuantityName,kPSQuantityFrequency,0)==kCFCompareEqualTo) {
        CFRelease(inverseOriginOffset);
        PSUnitRef megahertz = PSUnitForSymbol(CFSTR("MHz"));
        inverseOriginOffset = PSScalarCreateWithDouble(observeFrequency, megahertz);
    }
    else {
        inverseOriginOffset = PSScalarCreateWithDouble(observeFrequency, inverseXUnits);
    }

    PSScalarRef reciprocalReferenceOffset = PSScalarCreateWithDouble(0.0, inverseXUnits);

    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

    PSDimensionRef dim = PSLinearDimensionCreateDefault(size, increment, quantityName,inverseQuantityName);
    PSDimensionSetOriginOffset(dim, originOffset);
    PSDimensionSetInverseOriginOffset(dim, inverseOriginOffset);
    PSDimensionSetReferenceOffset(dim, referenceOffset);
    PSDimensionSetInverseQuantityName(dim, inverseQuantityName);
    if(nmrSpectrumType) {
        PSDimensionSetMadeDimensionless(dim, true);
    }
    
    CFRelease(increment);
    CFRelease(originOffset);
    CFRelease(referenceOffset);
    CFRelease(inverseOriginOffset);
    CFRelease(reciprocalReferenceOffset);
    if(NULL==dim) {
        CFRelease(values);
        return NULL;
    }
    
    PSDimensionMakeNiceUnits(dim);
    CFArrayAppendValue(dimensions, dim);
    CFRelease(dim);

    PSDatasetRef theDataset = PSDatasetCreateDefault();
    
    PSDatasetSetDimensions(theDataset, dimensions, NULL);
    CFRelease(dimensions);

    PSDependentVariableRef theDependentVariable = PSDatasetAddDefaultDependentVariable(theDataset, CFSTR("scalar"), kPSNumberFloat32Type, kPSDatasetSizeFromDimensions);
    PSDependentVariableSetValues(theDependentVariable, 0, values);
    CFRelease(values);
    PSDependentVariableMultiplyValuesByDimensionlessRealConstant(theDependentVariable, -1, yFactor);
    CFStringRef yUnits = CFDictionaryGetValue(jcampDatasetMetaData, CFSTR("YUNITS"));
    
    if(yUnits) {
        if(CFStringCompare(yUnits, CFSTR("pH"), 0)==kCFCompareEqualTo) {
            PSDependentVariableSetQuantityName(theDependentVariable, kPSQuantityDimensionless);
            PSDependentVariableSetComponentLabelAtIndex(theDependentVariable, CFSTR("pH"), 0);
        }
        if(CFStringCompare(yUnits, CFSTR("TRANSMITTANCE"), 0)==kCFCompareEqualTo) {
            PSDependentVariableSetQuantityName(theDependentVariable, kPSQuantityDimensionless);
            PSDependentVariableSetComponentLabelAtIndex(theDependentVariable, CFSTR("Transmittance"), 0);
        }
        if(CFStringCompare(yUnits, CFSTR("ABSORBANCE"), 0)==kCFCompareEqualTo) {
            PSDependentVariableSetQuantityName(theDependentVariable, kPSQuantityDimensionless);
            PSDependentVariableSetComponentLabelAtIndex(theDependentVariable, CFSTR("Absorbance"), 0);
        }
    }
    
    if(eprSpectrumType) {
        PSDependentVariableSetComponentLabelAtIndex(theDependentVariable, CFSTR("Derivative Intensity"), 0);
    }

    string = NULL;
    key = CFSTR("TEMPERATURE");
    PSUnitRef unit = PSUnitByParsingSymbol(CFSTR("°C"), NULL, error);
    quantityName = kPSQuantityTemperature;
    
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            double value = CFStringGetDoubleValue(string);
            PSScalarRef scalar = PSScalarCreateWithDouble(value, unit);
            CFDictionaryAddValue(jcampDatasetMetaData, key, scalar);
            CFRelease(scalar);
        }
    }
    
    string = NULL;
    key = CFSTR("PRESSURE");
    unit = PSUnitByParsingSymbol(CFSTR("atm"), NULL, error);
    quantityName = kPSQuantityPressure;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            double value = CFStringGetDoubleValue(string);
            PSScalarRef scalar = PSScalarCreateWithDouble(value, unit);
            CFDictionaryAddValue(jcampDatasetMetaData, key, scalar);
            CFRelease(scalar);
        }
    }
    
    string = NULL;
    key = CFSTR("REFRACTIVE INDEX");
    unit = PSUnitByParsingSymbol(CFSTR("m•s/(m•s)"), NULL, error);
    quantityName = kPSQuantityRefractiveIndex;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            double value = CFStringGetDoubleValue(string);
            PSScalarRef scalar = PSScalarCreateWithDouble(value, unit);
            CFDictionaryAddValue(jcampDatasetMetaData, key, scalar);
            CFRelease(scalar);
        }
    }
    
    string = NULL;
    key = CFSTR("DENSITY");
    unit = PSUnitByParsingSymbol(CFSTR("g/cm^3"), NULL, error);
    quantityName = kPSQuantityDensity;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            double value = CFStringGetDoubleValue(string);
            PSScalarRef scalar = PSScalarCreateWithDouble(value, unit);
            CFDictionaryAddValue(jcampDatasetMetaData, key, scalar);
            CFRelease(scalar);
       }
    }
    
    string = NULL;
    key = CFSTR("MW");
    unit = PSUnitByParsingSymbol(CFSTR("g/mol"), NULL, error);
    quantityName = kPSQuantityMolarMass;
    if(CFDictionaryContainsKey(dictionary, key)) {
        string = (CFStringRef) CFDictionaryGetValue(dictionary, key);
        if(string) {
            double value = CFStringGetDoubleValue(string);
            PSScalarRef scalar = PSScalarCreateWithDouble(value, unit);
            CFDictionaryAddValue(jcampDatasetMetaData, key, scalar);
            CFRelease(scalar);
       }
    }
    
    PSDatasetSetMetaData(theDataset, jcampDatasetMetaData);
    PSDatasetSetDescription(theDataset, description);
    PSDatasetSetTitle(theDataset, title);
    CFRelease(jcampDatasetMetaData);

    PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(theDataset, 0));
    PSPlotReset(thePlot);
    PSAxisRef horiztontalAxis = PSPlotHorizontalAxis(thePlot);
    if(irSpectrumType) PSAxisSetReverse(horiztontalAxis, true);
    if(nmrSpectrumType) PSAxisSetReverse(horiztontalAxis, true);
    return theDataset;
}

