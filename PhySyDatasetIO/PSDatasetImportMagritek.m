//
//  PSDatasetImportMagritek.c
//  RMN
//
//  Created by philip on 4/28/15.
//  Copyright (c) 2015 PhySy. All rights reserved.
//

#import <stdint.h>
#import <LibPhySyObjC/PhySyDatasetIO.h>

static CFDictionaryRef PSDatasetImportMagritekCreateDictionaryWithAcquData(CFDataRef resourceData)
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
            CFStringTrimWhitespace(mutKey);
            CFStringFindAndReplace (mutKey,CFSTR(" "), CFSTR(""),CFRangeMake(0,CFStringGetLength(mutKey)),0);
            CFStringRef value = CFArrayGetValueAtIndex(keyAndValue, 1);
            
            CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(value),value);
            CFStringTrimWhitespace(mutString);

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

PSDatasetRef PSDatasetImportMagritekCreateSignalWithFolderData(CFDataRef fidData,
                                                             CFDataRef acquData,
                                                             CFErrorRef *error)

{
    if(error) if(*error) return NULL;
    bool fid = false;
    bool acqu = false;
    
    if(fidData) fid = true;
//    if(acquData) acqu = true;

    CFDataRef contents;
    if(fid) contents = fidData;
    else {
        if(error) {
            CFStringRef desc = CFSTR("No Magritek binary file could be found.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return nil;
    }
    CFDictionaryRef metaData = PSDatasetImportMagritekCreateDictionaryWithAcquData(acquData);
    
    const UInt8 *buffer = CFDataGetBytePtr(contents);
    
    CFIndex totalFileLength = CFDataGetLength(contents);

    CFIndex count = 0;
    while(count<totalFileLength) {
        UInt32 datum = CFSwapInt32(*((UInt32 *) &(buffer[count])));
        char owner[4];
        char *temp = owner;
        memcpy(owner, &datum,4);
        temp[4] = 0;
        count +=4;
        
        if(strcmp(owner, "PROS")==0 || strcmp(owner, "pros")==0) {
            UInt32 datum = CFSwapInt32(*((UInt32 *) &(buffer[count])));
            char format[4];
            memcpy(format, &datum,4);
            char *temp = format;
            temp[4] = 0;
            count +=4;

            if(strcmp(format, "DATA")==0 || strcmp(format, "data")==0) {
                
                UInt32 datum = CFSwapInt32(*((UInt32 *) &(buffer[count])));
                char version[4];
                memcpy(version, &datum,4);
                char *temp = version;
                temp[4] = 0;
                count +=4;


                if(strcmp(version, "V1.0")==0 || strcmp(version, "V1.1")==0) {
                    UInt32 npts[4];
                    
                    UInt32 dataType = (*((UInt32 *) &(buffer[count])));
                    count +=4;
                    
                    npts[0] = (*((UInt32 *) &(buffer[count])));
                    count +=4;
                    
                    npts[1] = (*((UInt32 *) &(buffer[count])));
                    count +=4;
                    
                    npts[2] = (*((UInt32 *) &(buffer[count])));
                    count +=4;
                    
                    npts[3] = (*((UInt32 *) &(buffer[count])));
                    count +=4;
                    
                    CFIndex numberOfDimensions = (npts[0]!=1)+ (npts[1]!=1)+ (npts[2]!=1)+ (npts[3]!=1);
                    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, numberOfDimensions, &kCFTypeArrayCallBacks);
//                    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL, error);
                    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL, error);
//                    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL, error);
                    PSUnitRef microseconds = PSUnitByParsingSymbol(CFSTR("µs"), NULL, error);

                    CFStringRef dwellTime = CFDictionaryGetValue(metaData, CFSTR("dwellTime"));
                    PSScalarRef increment = PSScalarCreateWithDouble(CFStringGetDoubleValue(dwellTime)/2., microseconds);
                    PSScalarRef originOffset = PSScalarCreateWithDouble(0, microseconds);

                    CFStringRef b1Freq1H = CFDictionaryGetValue(metaData, CFSTR("b1Freq1H"));
                    CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,0,b1Freq1H);
                    CFStringFindAndReplace (mutString,CFSTR("d"), CFSTR(""),CFRangeMake(0,CFStringGetLength(mutString)),0);
                    PSScalarRef inverseOriginOffset = PSScalarCreateWithDouble(CFStringGetDoubleValue(mutString), megahertz);
                    CFRelease(mutString);

                    CFIndex responseSize = 1;
                    for(CFIndex idim =0;idim<numberOfDimensions; idim++) {
                        responseSize *= npts[idim];
                        PSDimensionRef dimension = PSLinearDimensionCreateDefault(npts[idim], increment, kPSQuantityTime);
                        PSDimensionSetInverseQuantityName(dimension, kPSQuantityFrequency);
                        PSDimensionSetOriginOffset(dimension, originOffset);
                        PSDimensionSetInverseOriginOffset(dimension, inverseOriginOffset);
                        PSDimensionSetMetaData(dimension, metaData);

                        PSDimensionSetInverseMadeDimensionless(dimension, true);
                        PSDimensionMakeNiceUnits(dimension);
                        CFArrayAppendValue(dimensions, dimension);
                    }
                    
                    CFRelease(increment);
                    CFRelease(originOffset);
                    CFRelease(inverseOriginOffset);
                    
                    if(dataType==500) {
                        CFIndex dataLength = responseSize*sizeof(float);
                        numberType responseType = kPSNumberFloat32Type;
                        float *data = (float *) &(buffer[count]);
                        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) data, dataLength);
                        
                        
                        PSDependentVariableRef theDependentVariable = PSDependentVariableCreateWithComponent(NULL,
                                                                                               NULL,
                                                                                               NULL,
                                                                                               NULL,
                                                                                               responseType,
                                                                                               NULL,
                                                                                               values,
                                                                                               NULL,
                                                                                               NULL);
                        CFRelease(values);
                        free(data);
                        
                        PSDatasetRef dataset = PSDatasetCreateWithDependentVariable(dimensions,
                                                                                    NULL,
                                                                                    theDependentVariable,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    metaData);
                        
                        CFRelease(theDependentVariable);
                        CFRelease(dimensions);
                        CFRelease(metaData);

                        PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
                        PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), false);
                        PSPlotSetImag(thePlot, false);
                        PSPlotSetReal(thePlot, true);
                        PSPlotReset(thePlot);
                        
                        return dataset;

                    }
                    else if(dataType==501) {
                        CFIndex dataLength = responseSize*sizeof(float complex);
                        numberType responseType = kPSNumberFloat32ComplexType;
                        float complex *data = (float complex *) &(buffer[count]);
                        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) data, dataLength);
                        
                        PSDependentVariableRef theDependentVariable = PSDependentVariableCreateWithComponent(NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             responseType,
                                                                                                             NULL,
                                                                                                             values,
                                                                                                             NULL,
                                                                                                             NULL);
                        CFRelease(values);
                        free(data);

                        PSDatasetRef dataset = PSDatasetCreateWithDependentVariable(dimensions,
                                                                                    NULL,
                                                                                    theDependentVariable,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    metaData);
                        
                        CFRelease(theDependentVariable);
                        CFRelease(dimensions);
                        CFRelease(metaData);
                        
                        PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
                        PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), false);
                        PSPlotSetImag(thePlot, false);
                        PSPlotSetReal(thePlot, true);
                        PSPlotReset(thePlot);
                        
                        return dataset;

                    }
                    else if(dataType==502) {
                        CFIndex dataLength = responseSize*sizeof(double);
                        numberType responseType = kPSNumberFloat64Type;
                        double *data = (double *) &(buffer[count]);
                        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) data, dataLength);
                        
                        PSDependentVariableRef theDependentVariable = PSDependentVariableCreateWithComponent(NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             responseType,
                                                                                                             NULL,
                                                                                                             values,
                                                                                                             NULL,
                                                                                                             NULL);
                        CFRelease(values);
                        free(data);
                        
                        PSDatasetRef dataset = PSDatasetCreateWithDependentVariable(dimensions,
                                                                                    NULL,
                                                                                    theDependentVariable,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    metaData);
                        
                        CFRelease(theDependentVariable);
                        CFRelease(dimensions);
                        CFRelease(metaData);
                        
                        PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
                        PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), false);
                        PSPlotSetImag(thePlot, false);
                        PSPlotSetReal(thePlot, true);
                        PSPlotReset(thePlot);
                        
                        return dataset;

                    }
                    else if(dataType==503) {
                        CFIndex xSize = responseSize*sizeof(float);
                        CFIndex dataLength = responseSize*sizeof(float);
                        numberType responseType = kPSNumberFloat32Type;
//                        float *xdata = (float *) &(buffer[count]);
                        count += xSize;
                        float *data = (float *) &(buffer[count]);
                        count += dataLength;
                        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) data, dataLength);
                        
                        
                        PSDependentVariableRef theDependentVariable = PSDependentVariableCreateWithComponent(NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             responseType,
                                                                                                             NULL,
                                                                                                             values,
                                                                                                             NULL,
                                                                                                             NULL);
                        CFRelease(values);
                        free(data);
                        
                        PSDatasetRef dataset = PSDatasetCreateWithDependentVariable(dimensions,
                                                                                    NULL,
                                                                                    theDependentVariable,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    metaData);
                        
                        CFRelease(theDependentVariable);
                        CFRelease(dimensions);
                        CFRelease(metaData);
                        
                        PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
                        PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), false);
                        PSPlotSetImag(thePlot, false);
                        PSPlotSetReal(thePlot, true);
                        PSPlotReset(thePlot);
                        
                        return dataset;

                    }
                    else if(dataType==504) {
                        CFIndex xSize = responseSize*sizeof(float);
                        CFIndex dataLength = responseSize*sizeof(float complex);
                        numberType responseType = kPSNumberFloat32ComplexType;
                        count += xSize;
                        float complex *data = (float complex *) &(buffer[count]);
                        count += dataLength;
                        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) data, dataLength);
                        PSDependentVariableRef theDependentVariable = PSDependentVariableCreateWithComponent(NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             NULL,
                                                                                                             responseType,
                                                                                                             NULL,
                                                                                                             values,
                                                                                                             NULL,
                                                                                                             NULL);
                        CFRelease(values);
                        free(data);
                        
                        PSDatasetRef dataset = PSDatasetCreateWithDependentVariable(dimensions,
                                                                                    NULL,
                                                                                    theDependentVariable,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    metaData);
                        
                        CFRelease(theDependentVariable);
                        CFRelease(dimensions);
                        CFRelease(metaData);
                        
                        PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
                        PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), false);
                        PSPlotSetImag(thePlot, false);
                        PSPlotSetReal(thePlot, true);
                        PSPlotReset(thePlot);
                        
                        return dataset;

                    }
                    
                }
            }

        }
        else {
            if(metaData) CFRelease(metaData);
            return NULL;
        }}
    if(metaData) CFRelease(metaData);
    return NULL;
}
