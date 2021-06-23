//
//  PSDatasetImportSimpson.m
//  RMN
//
//  Created by philip on 6/10/16.
//  Copyright © 2016 PhySy. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>


PSDatasetRef PSDatasetImportSimpsonCreateSignalWithFileData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(contents,NULL);
    
    CFStringRef temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,contents,kCFStringEncodingUTF8);
    CFMutableStringRef fileString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
    CFRelease(temp);
    
    CFStringFindAndReplace(fileString, CFSTR("\r"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(fileString)), 0);
    CFStringFindAndReplace(fileString, CFSTR("\n\n"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(fileString)), 0);

    CFArrayRef lines = (CFArrayRef) [(NSString *) fileString componentsSeparatedByString:@"\n"];
    CFRetain(lines);
    
    CFRelease(fileString);
    
    CFStringRef simpsonString = (CFStringRef) CFArrayGetValueAtIndex(lines, 0);
    
    if(CFStringCompare(simpsonString, CFSTR("SIMP"), 0) != kCFCompareEqualTo) {
        CFRelease(lines);
        return NULL;
    }

    CFIndex dataStart = 0;
    CFStringRef line = NULL;
    do{
        dataStart++;
        line = (CFStringRef) CFArrayGetValueAtIndex(lines, dataStart);
    } while(CFStringCompare(line, CFSTR("DATA"), 0) != kCFCompareEqualTo);
    dataStart++;

    CFIndex dataEnd = 0;
    do{
        dataEnd++;
        line = (CFStringRef) CFArrayGetValueAtIndex(lines, dataEnd);
    } while(CFStringCompare(line, CFSTR("END"), 0) != kCFCompareEqualTo);
    dataEnd--;

    size_t size = (size_t) (dataEnd-dataStart+1);

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
    
    CFIndex numberOfIndirectPoints = 1;
    if(CFDictionaryContainsKey(dict, CFSTR("NI"))) {
        CFStringRef niString = CFDictionaryGetValue(dict, CFSTR("NI"));
        numberOfIndirectPoints = CFStringGetIntValue(niString);
    }
    
    CFIndex numberOfPoints = 1;
    if(CFDictionaryContainsKey(dict, CFSTR("NP"))) {
        CFStringRef npString = CFDictionaryGetValue(dict, CFSTR("NP"));
        numberOfPoints = CFStringGetIntValue(npString);
    }
    
    if(size!=numberOfPoints*numberOfIndirectPoints) {
        CFRelease(lines);
        return NULL;
    }

    double sw = -1;
    if(CFDictionaryContainsKey(dict, CFSTR("SW"))) {
        CFStringRef swString = CFDictionaryGetValue(dict, CFSTR("SW"));
        sw = CFStringGetDoubleValue(swString);
    }
    
    double sw1 = -1;
    if(CFDictionaryContainsKey(dict, CFSTR("SW1"))) {
        CFStringRef sw1String = CFDictionaryGetValue(dict, CFSTR("SW1"));
        sw1 = CFStringGetDoubleValue(sw1String);
    }
    
    if(!CFDictionaryContainsKey(dict, CFSTR("TYPE"))) {
        CFRelease(lines);
        return NULL;
    }
    CFStringRef type = CFDictionaryGetValue(dict, CFSTR("TYPE"));
    bool fid = (CFStringCompare(type, CFSTR("FID"), 0) == kCFCompareEqualTo);
    bool spe = (CFStringCompare(type, CFSTR("SPE"), 0) == kCFCompareEqualTo);

    CFIndex numberOfDimensions = 1;
    if(numberOfIndirectPoints!=1) numberOfDimensions = 2;
    
    float complex *response = (float complex *) malloc(size*sizeof(float complex));
    
    CFIndex i = 0;
    for(CFIndex index=dataStart;index<=dataEnd;index++) {
        CFStringRef lineString = CFArrayGetValueAtIndex(lines, index);
        char *cString = CreateCString(lineString);
        float realPart, imagPart;
        if(sscanf(cString,"%g %g",&realPart,&imagPart)!=2) {
            free(response);
            CFRelease(lines);
            return NULL;
        }
        response[i++] = realPart + I*imagPart;
    }
    

    CFRelease(lines);
    
    if(fid) {
        CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        
        double dw = 1./sw;
        PSUnitRef seconds = PSUnitForSymbol(CFSTR("s"));
        PSUnitRef hertz = PSUnitForSymbol(CFSTR("Hz"));
        PSScalarRef increment = PSScalarCreateWithDouble(dw, seconds);
        PSScalarRef referenceOffset = PSScalarCreateWithDouble(0.0, seconds);
        PSScalarRef originOffset = PSScalarCreateWithFloat(0.0, seconds);
        PSScalarRef inverseOriginOffset = PSScalarCreateWithFloat(0.0, hertz);
        
        PSDimensionRef dimX = PSLinearDimensionCreateDefault(numberOfPoints, increment, kPSQuantityTime);
        PSDimensionSetInverseQuantityName(dimX, kPSQuantityFrequency);
        PSDimensionSetOriginOffset(dimX, originOffset);
        PSDimensionSetInverseOriginOffset(dimX, inverseOriginOffset);
        PSDimensionSetReferenceOffset(dimX, referenceOffset);

        
        CFRelease(increment);
        CFRelease(referenceOffset);
        
        PSDimensionMakeNiceUnits(dimX);
        CFArrayAppendValue(dimensions, dimX);
        CFRelease(dimX);
        
        CFRelease(originOffset);
        CFRelease(inverseOriginOffset);
        
        if(numberOfDimensions==2) {
            double dw1 = 1./sw1;
            PSUnitRef seconds = PSUnitForSymbol(CFSTR("s"));
            PSUnitRef hertz = PSUnitForSymbol(CFSTR("Hz"));
            PSScalarRef increment1 = PSScalarCreateWithDouble(dw1, seconds);
            PSScalarRef referenceOffset1 = PSScalarCreateWithDouble(0.0, seconds);
            PSScalarRef originOffset1 = PSScalarCreateWithFloat(0.0, seconds);
            PSScalarRef inverseOriginOffset1 = PSScalarCreateWithFloat(0.0, hertz);
            
            PSDimensionRef dimY = PSLinearDimensionCreateDefault(numberOfIndirectPoints, increment1, kPSQuantityTime);
            PSDimensionSetInverseQuantityName(dimY, kPSQuantityFrequency);
            PSDimensionSetOriginOffset(dimY, originOffset1);
            PSDimensionSetInverseOriginOffset(dimY, inverseOriginOffset1);
            PSDimensionSetReferenceOffset(dimY, referenceOffset1);

            CFRelease(increment1);
            CFRelease(referenceOffset1);
            
            PSDimensionMakeNiceUnits(dimY);
            CFArrayInsertValueAtIndex(dimensions, 0, dimY);
            CFRelease(dimY);
            
            CFRelease(originOffset1);
            CFRelease(inverseOriginOffset1);

        }
        
        PSDatasetRef dataset = PSDatasetCreateDefault();
        PSDatasetSetDimensions(dataset, dimensions, NULL);
        CFRelease(dimensions);

        PSDependentVariableRef theDV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
        
        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) response, size*sizeof(float complex));
        free(response);
        PSDependentVariableSetComponentAtIndex(theDV, values, 0);
        CFRelease(values);
        
        
        PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
        PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);
        PSPlotSetImag(thePlot, true);
        PSPlotSetReal(thePlot, true);
        PSPlotReset(thePlot);

        return dataset;

    }
    else if(spe) {
        CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        PSUnitRef seconds = PSUnitForSymbol(CFSTR("s"));
        PSUnitRef hertz = PSUnitForSymbol(CFSTR("Hz"));
        PSScalarRef increment = PSScalarCreateWithDouble(sw/numberOfPoints, hertz);
        PSScalarRef referenceOffset = PSScalarCreateWithDouble(-sw/2, hertz);
        PSScalarRef originOffset = PSScalarCreateWithFloat(0.0, hertz);
        PSScalarRef inverseOriginOffset = PSScalarCreateWithFloat(0.0, seconds);
        
        PSDimensionRef dimX = PSLinearDimensionCreateDefault(numberOfPoints, increment, kPSQuantityFrequency);
        PSDimensionSetInverseQuantityName(dimX, kPSQuantityTime);
        PSDimensionSetOriginOffset(dimX, originOffset);
        PSDimensionSetInverseOriginOffset(dimX, inverseOriginOffset);
        PSDimensionSetReferenceOffset(dimX, referenceOffset);

        CFRelease(increment);
        CFRelease(referenceOffset);
        
        PSDimensionMakeNiceUnits(dimX);
        CFArrayAppendValue(dimensions, dimX);
        CFRelease(dimX);
        
        CFRelease(originOffset);
        CFRelease(inverseOriginOffset);
        
        if(numberOfDimensions==2) {
            PSUnitRef seconds = PSUnitForSymbol(CFSTR("s"));
            PSUnitRef hertz = PSUnitForSymbol(CFSTR("Hz"));
            PSScalarRef increment1 = PSScalarCreateWithDouble(sw1/numberOfIndirectPoints, hertz);
            PSScalarRef referenceOffset1 = PSScalarCreateWithDouble(-sw1/2, hertz);
            PSScalarRef originOffset1 = PSScalarCreateWithFloat(0.0, hertz);
            PSScalarRef inverseOriginOffset1 = PSScalarCreateWithFloat(0.0, seconds);
            
            PSDimensionRef dimY = PSLinearDimensionCreateDefault(numberOfIndirectPoints, increment1, kPSQuantityFrequency);
            PSDimensionSetInverseQuantityName(dimY, kPSQuantityTime);
            PSDimensionSetOriginOffset(dimY, originOffset1);
            PSDimensionSetInverseOriginOffset(dimY, inverseOriginOffset1);
            PSDimensionSetReferenceOffset(dimY, referenceOffset1);

            CFRelease(increment1);
            CFRelease(referenceOffset1);
            
            PSDimensionMakeNiceUnits(dimY);
            CFArrayInsertValueAtIndex(dimensions, 0, dimY);
            CFRelease(dimY);
            
            CFRelease(originOffset1);
            CFRelease(inverseOriginOffset1);
            
        }

        
        PSDatasetRef dataset = PSDatasetCreateDefault();
        PSDatasetSetDimensions(dataset, dimensions, NULL);
        CFRelease(dimensions);
        
        PSDependentVariableRef theDV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
        
        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) response, size*sizeof(float complex));
        free(response);
        PSDependentVariableSetComponentAtIndex(theDV, values, 0);
        CFRelease(values);

        PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
        PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), false);
        PSPlotSetImag(thePlot, false);
        PSPlotSetReal(thePlot, true);
        PSPlotReset(thePlot);

        return dataset;
        
    }
    free(response);
    return NULL;
}
