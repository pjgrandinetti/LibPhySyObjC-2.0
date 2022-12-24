//
//  PSDatasetImportRMNClassic.c
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

//CFIndex PSDatasetImportRMNClassicNumberOfDimensionsForTypeCode(OSType typeCode)
//{
//    switch(typeCode) {
//        case 'TIME': 
//        case 'FREQ': 
//            return 1;
//        case '2DTT':
//        case '2DFT':
//        case '2DTF':
//        case '2DFF':
//            return 2;
//    }
//    return 0;
//}

PSDatasetRef PSDatasetImportRMNClassicCreateSignalWithFileBytesAndTypeCode(const UInt8 * bytes, OSType typeCode, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL,error);
    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL,error);
    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL,error);
    long count = 0;
    CFIndex size = 1;
    CFIndex numberOfDimensions = 0;
    PSDimensionRef dim0 = NULL;
    PSDimensionRef dim1 = NULL;
    
    switch(typeCode) {
        case 'TIME':
        case 'FREQ':{
            if(bytes[0]<2) return NULL;
            numberOfDimensions = 1;
            
            count += (long) sizeof(Byte); // version number
            
            CFIndex npts = (CFIndex) CFSwapInt32(*((UInt32 *) &(bytes[count])));
            count += (long) sizeof(UInt32);
            
            UInt64 temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
            void *ptr = &temp;
            double dw = *((double *)ptr);
            count += (long) sizeof(UInt64);
            
            temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
            double timeOriginOffset = *((double *)&temp);
            count += (long) sizeof(UInt64);
            
            temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
            double sfreq = *((double *)&temp);
            count += (long) sizeof(UInt64);
            
            temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
            double offset = *((double *)&temp);
            count += (long) sizeof(UInt64);
            
            double frequencyOriginOffset = 0.0;
            double refPosition = offset/sfreq;
            double refFrequency = 0.0;
            
            CFStringRef quantityName = NULL;
            CFStringRef inverseQuantityName = NULL;
            PSScalarRef increment = NULL;
            PSScalarRef originOffset= NULL;
            PSScalarRef inverseOriginOffset= NULL;
            PSScalarRef referenceOffset= NULL;
            PSScalarRef inverseReferenceOffset= NULL;
            if(typeCode=='TIME') {
                quantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
                inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
                increment = PSScalarCreateWithDouble(dw, seconds);
                referenceOffset = PSScalarCreateWithDouble(timeOriginOffset, seconds);
                inverseReferenceOffset = PSScalarCreateWithDouble(offset, hertz);
                inverseOriginOffset = PSScalarCreateWithDouble(sfreq, megahertz);
            }
            else if(typeCode=='FREQ') {
                quantityName = CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityFrequency);
                inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
                PSScalarRef dwell = PSScalarCreateWithDouble(dw, seconds);
                PSScalarRef temp = PSScalarCreateByRaisingToAPower(dwell, -1, error);
                increment = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 1./(double) npts);
                referenceOffset = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 0.5);

                CFRelease(temp);
                CFRelease(dwell);
                referenceOffset = PSScalarCreateWithDouble(offset, hertz);
                originOffset = PSScalarCreateWithDouble(sfreq, megahertz);
                inverseReferenceOffset = PSScalarCreateWithDouble(timeOriginOffset, seconds);
            }
            
            
            // Put the rest into NMR meta-data
            PSScalarRef receiverFrequency = PSScalarCreateWithDouble(sfreq, megahertz);
            PSScalarRef referenceFrequency = PSScalarCreateWithDouble(refFrequency, hertz);
            PSScalarRef referencePosition = PSScalarCreateWithDouble(refPosition*sfreq, hertz);
            
            CFMutableDictionaryRef rmnClassicMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            
            CFStringRef stringValue = PSScalarCreateStringValue(receiverFrequency);
            CFDictionaryAddValue(rmnClassicMetaData, CFSTR("receiver frequency"), stringValue);
            CFRelease(stringValue);
            
            stringValue = PSScalarCreateStringValue(referenceFrequency);
            CFDictionaryAddValue(rmnClassicMetaData, CFSTR("reference frequency"), stringValue);
            CFRelease(stringValue);
            
            stringValue = PSScalarCreateStringValue(referencePosition);
            CFDictionaryAddValue(rmnClassicMetaData, CFSTR("reference position"), stringValue);
            CFRelease(stringValue);
            
            CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            
            CFDictionaryAddValue(nmr, CFSTR("RMN"), rmnClassicMetaData);
            CFRelease(rmnClassicMetaData);
            
            stringValue = PSScalarCreateStringValue(receiverFrequency);
            CFDictionaryAddValue(nmr, CFSTR("receiver frequency"), stringValue);
            CFRelease(stringValue);
            
            CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionaryAddValue(metaData, CFSTR("NMR"), nmr);
            CFRelease(nmr);
            
            dim0 = PSLinearDimensionCreateDefault(npts, increment, quantityName,inverseQuantityName);
            PSDimensionSetOriginOffset(dim0, originOffset);
            PSDimensionSetInverseOriginOffset(dim0, inverseOriginOffset);
            PSDimensionSetReferenceOffset(dim0, referenceOffset);
            PSDimensionSetInverseReferenceOffset(dim0, inverseReferenceOffset);
            PSDimensionSetMetaData(dim0, metaData);
            
            size *= npts;
            
            CFRelease(quantityName);
            if(inverseQuantityName) CFRelease(inverseQuantityName);
            if(increment) CFRelease(increment);
            if(originOffset) CFRelease(originOffset);
            if(inverseOriginOffset) CFRelease(inverseOriginOffset);
            if(referenceOffset) CFRelease(referenceOffset);
            if(inverseReferenceOffset) CFRelease(inverseReferenceOffset);
            if(metaData) CFRelease(metaData);
            break;
        }
        case '2DTT': 
        case '2DTF': 
        case '2DFT': 
        case '2DFF': {
            if(bytes[0] < 2) return NULL;
            numberOfDimensions = 2;
            {
                count += (long) sizeof(Byte); // version number
                
                CFIndex npt1 = (CFIndex) CFSwapInt32(*((UInt32 *) &(bytes[count])));
                count += (long) sizeof(UInt32);
                
                UInt64 temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                void *ptr = &temp;
                double dw1 = *((double *)ptr);
                count += (long) sizeof(UInt64);
                
                temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                double timeOriginOffset1 = *((double *)&temp);
                count += (long) sizeof(UInt64);
                
                temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                double sfreq1 = *((double *)&temp);
                count += (long) sizeof(UInt64);
                
                temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                double offset1 = *((double *)&temp);
                count += (long) sizeof(UInt64);
                
                double frequencyOriginOffset1 = 0.0;
                double refPosition1 = offset1/sfreq1;
                double refFrequency1 = 0.0;
                
                CFStringRef quantityName1, inverseQuantityName1;
                PSScalarRef increment1 = NULL;
                PSScalarRef originOffset1 = NULL;
                PSScalarRef inverseOriginOffset1 = NULL;
                PSScalarRef referenceOffset1 = NULL;
                PSScalarRef inverseReferenceOffset1 = NULL;
                
                if(typeCode=='2DTT' || typeCode=='2DFT') {
                    quantityName1 = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
                    inverseQuantityName1 = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
                    increment1 = PSScalarCreateWithDouble(dw1, seconds);
                    referenceOffset1 = PSScalarCreateWithDouble(timeOriginOffset1, seconds);
                    inverseReferenceOffset1 = PSScalarCreateWithDouble(offset1, hertz);
                    inverseOriginOffset1 = PSScalarCreateWithDouble(sfreq1, megahertz);
                }
                if(typeCode=='2DTF' || typeCode=='2DFF') {
                    
                    quantityName1 = CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityFrequency);
                    inverseQuantityName1 = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
                    PSScalarRef dwell1 = PSScalarCreateWithDouble(dw1, seconds);
                    PSScalarRef temp = PSScalarCreateByRaisingToAPower(dwell1, -1, error);
                    increment1 = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 1./(double) npt1);
                    referenceOffset1 = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 0.5);
                    CFRelease(temp);
                    CFRelease(dwell1);
                    originOffset1 = PSScalarCreateWithDouble(sfreq1, megahertz);
                    inverseReferenceOffset1 = PSScalarCreateWithDouble(timeOriginOffset1, seconds);
                }
                
                // Put the rest into NMR meta-data
                PSScalarRef receiverFrequency1 = PSScalarCreateWithDouble(sfreq1, megahertz);
                PSScalarRef referenceFrequency1 = PSScalarCreateWithDouble(refFrequency1, hertz);
                PSScalarRef referencePosition1 = PSScalarCreateWithDouble(refPosition1*sfreq1, hertz);
                
                CFMutableDictionaryRef rmnClassicMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                
                CFStringRef stringValue = PSScalarCreateStringValue(receiverFrequency1);
                CFDictionaryAddValue(rmnClassicMetaData, CFSTR("receiver frequency"), stringValue);
                CFRelease(stringValue);
                
                stringValue = PSScalarCreateStringValue(referenceFrequency1);
                CFDictionaryAddValue(rmnClassicMetaData, CFSTR("reference frequency"), stringValue);
                CFRelease(stringValue);
                
                stringValue = PSScalarCreateStringValue(referencePosition1);
                CFDictionaryAddValue(rmnClassicMetaData, CFSTR("reference position"), stringValue);
                CFRelease(stringValue);
                
                CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                
                CFDictionaryAddValue(nmr, CFSTR("RMN"), rmnClassicMetaData);
                CFRelease(rmnClassicMetaData);
                
                stringValue = PSScalarCreateStringValue(receiverFrequency1);
                CFDictionaryAddValue(nmr, CFSTR("receiver frequency"), stringValue);
                CFRelease(stringValue);
                
                CFMutableDictionaryRef metaData1 = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFDictionaryAddValue(metaData1, CFSTR("NMR"), nmr);
                CFRelease(nmr);
                
                dim1 = PSLinearDimensionCreateDefault(npt1, increment1, quantityName1,inverseQuantityName1);
                PSDimensionSetOriginOffset(dim1, originOffset1);
                PSDimensionSetInverseOriginOffset(dim1, inverseOriginOffset1);
                PSDimensionSetReferenceOffset(dim1, referenceOffset1);
                PSDimensionSetInverseReferenceOffset(dim1, inverseReferenceOffset1);
                PSDimensionSetMetaData(dim1, metaData1);

                size *= npt1;
                
                CFRelease(quantityName1);
                CFRelease(inverseQuantityName1);
                if(increment1) CFRelease(increment1);
                if(originOffset1) CFRelease(originOffset1);
                if(inverseOriginOffset1) CFRelease(inverseOriginOffset1);
                if(referenceOffset1) CFRelease(referenceOffset1);
                if(inverseReferenceOffset1) CFRelease(inverseReferenceOffset1);
                CFRelease(metaData1);
                
            }
            
            {
                CFIndex npt0 = (CFIndex) CFSwapInt32(*((UInt32 *) &(bytes[count])));
                count += (long) sizeof(UInt32);
                
                UInt64 temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                double dw0 = *((double *)&temp);
                count += (long) sizeof(UInt64);
                
                temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                double timeOriginOffset0 = *((double *)&temp);
                count += (long) sizeof(UInt64);
                
                temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                double sfreq0 = *((double *)&temp);
                count += (long) sizeof(UInt64);
                
                temp = CFSwapInt64(*((UInt64 *) &(bytes[count])));
                double offset0 = *((double *)&temp);
                count += (long) sizeof(UInt64);
                
                double frequencyOriginOffset0 = 0.0;
                double refPosition0 = offset0/sfreq0;
                double refFrequency0 = 0.0;
                
                CFStringRef quantityName0, inverseQuantityName0;
                PSScalarRef increment0 = NULL;
                PSScalarRef referenceOffset0= NULL;
                PSScalarRef inverseReferenceOffset0= NULL;
                PSScalarRef originOffset0= NULL;
                PSScalarRef inverseOriginOffset0= NULL;
                
                if(typeCode=='2DTT' || typeCode=='2DTF') {
                    quantityName0 = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
                    inverseQuantityName0 = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
                    increment0 = PSScalarCreateWithDouble(dw0, seconds);
                    referenceOffset0 = PSScalarCreateWithDouble(timeOriginOffset0, seconds);
                    inverseReferenceOffset0 = PSScalarCreateWithDouble(offset0, hertz);
                    inverseOriginOffset0 = PSScalarCreateWithDouble(sfreq0, megahertz);
                }
                if(typeCode=='2DFT' || typeCode=='2DFF') {
                    quantityName0 = CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityFrequency);
                    inverseQuantityName0 = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
                    PSScalarRef dwell0 = PSScalarCreateWithDouble(dw0, seconds);
                    PSScalarRef temp = PSScalarCreateByRaisingToAPower(dwell0, -1, error);
                    increment0 = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 1./(double) npt0);
                    referenceOffset0 = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 0.5);
                    CFRelease(temp);
                    CFRelease(dwell0);
                    originOffset0 = PSScalarCreateWithDouble(sfreq0, megahertz);
                    inverseReferenceOffset0 = PSScalarCreateWithDouble(timeOriginOffset0, seconds);
                }
                
                // Put the rest into NMR meta-data
                PSScalarRef receiverFrequency0 = PSScalarCreateWithDouble(sfreq0, megahertz);
                PSScalarRef referenceFrequency0 = PSScalarCreateWithDouble(refFrequency0, hertz);
                PSScalarRef referencePosition0 = PSScalarCreateWithDouble(refPosition0*sfreq0, hertz);
                
                CFMutableDictionaryRef rmnClassicMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                
                CFStringRef stringValue = PSScalarCreateStringValue(receiverFrequency0);
                CFDictionaryAddValue(rmnClassicMetaData, CFSTR("receiver frequency"), stringValue);
                CFRelease(stringValue);
                
                stringValue = PSScalarCreateStringValue(referenceFrequency0);
                CFDictionaryAddValue(rmnClassicMetaData, CFSTR("reference frequency"), stringValue);
                CFRelease(stringValue);
                
                stringValue = PSScalarCreateStringValue(referencePosition0);
                CFDictionaryAddValue(rmnClassicMetaData, CFSTR("reference position"), stringValue);
                CFRelease(stringValue);
                
                CFMutableDictionaryRef nmr = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                
                CFDictionaryAddValue(nmr, CFSTR("RMN"), rmnClassicMetaData);
                CFRelease(rmnClassicMetaData);
                
                stringValue = PSScalarCreateStringValue(receiverFrequency0);
                CFDictionaryAddValue(nmr, CFSTR("receiver frequency"), stringValue);
                CFRelease(stringValue);
                
                CFMutableDictionaryRef metaData0 = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFDictionaryAddValue(metaData0, CFSTR("NMR"), nmr);
                CFRelease(nmr);
                
                dim0 = PSLinearDimensionCreateDefault(npt0, increment0, quantityName0,inverseQuantityName0);
                PSDimensionSetOriginOffset(dim0, originOffset0);
                PSDimensionSetInverseOriginOffset(dim0, inverseOriginOffset0);
                PSDimensionSetReferenceOffset(dim0, referenceOffset0);
                PSDimensionSetInverseReferenceOffset(dim0, inverseReferenceOffset0);
                PSDimensionSetMetaData(dim0, metaData0);
                


                size *= npt0;
                
                CFRelease(quantityName0);
                CFRelease(inverseQuantityName0);
                if(increment0) CFRelease(increment0);
                if(referenceOffset0)  CFRelease(referenceOffset0);
                if(inverseReferenceOffset0) CFRelease(inverseReferenceOffset0);
                if(originOffset0)  CFRelease(originOffset0);
                if(inverseOriginOffset0) CFRelease(inverseOriginOffset0);
                CFRelease(metaData0);
            }
            break;
        }
    }
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    if(dim0) {
        PSDimensionMakeNiceUnits(dim0);
        CFArrayAppendValue(dimensions, dim0);
        CFRelease(dim0);
    }
    if(dim1) {
        PSDimensionMakeNiceUnits(dim1);
        CFArrayAppendValue(dimensions, dim1);
        CFRelease(dim1);
    }
    
    CFMutableDictionaryRef metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    char comm[512];
    memcpy(comm, &(bytes[count]), 512);
    count += 512;
    count += 512; // dummy bytes
    
    CFMutableDataRef values = CFDataCreateMutable(kCFAllocatorDefault, size*sizeof(float complex));
    CFDataSetLength(values, size*sizeof(float complex));
    
    PSDatasetRef dataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(dataset, dimensions, NULL);
    CFRelease(dimensions);

    PSDependentVariableRef dependentVariable = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
    
    PSDependentVariableSetComponentAtIndex(dependentVariable, values, 0);
    CFRelease(values);
    PSDatasetSetMetaData(dataset, metaData);
    CFRelease(metaData);

    
    PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutable(numberOfDimensions);
    dimensions = (CFMutableArrayRef) PSDatasetGetDimensions(dataset);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(dataset, 0);
    if(numberOfDimensions==1) {
        PSDimensionRef dim = PSDatasetGetDimensionAtIndex(dataset, 0);
        for(CFIndex index=PSDimensionLowestIndex(dim);index<PSDimensionHighestIndex(dim);index++) {
            UInt32 datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
            count += (long) sizeof(UInt32);
            void *ptr = &datum;
            float real = *((float *)ptr);
            
            datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
            count += (long) sizeof(UInt32);
            ptr = &datum;
            float imag = *((float *)ptr);
            
            PSScalarRef response = PSScalarCreateWithFloatComplex(real + I*imag, PSUnitDimensionlessAndUnderived());
            PSIndexArraySetValueAtIndex(indexValues, 0, index);
            PSDependentVariableSetValueAtCoordinateIndexes(theDependentVariable, 0, dimensions, indexValues, response, error);
            CFRelease(response);
        }
    }
    else {
        PSDimensionRef dim0 = PSDatasetGetDimensionAtIndex(dataset, 0);
        PSDimensionRef dim1 = PSDatasetGetDimensionAtIndex(dataset, 1);
        
        CFIndex highestIndex0 = PSDimensionHighestIndex(dim0);
        CFIndex highestIndex1 = PSDimensionHighestIndex(dim1);
        if(!PSDimensionGetFFT(dim0)) highestIndex0 = PSDimensionGetNpts(dim0);
        if(!PSDimensionGetFFT(dim1)) highestIndex1 = PSDimensionGetNpts(dim1);
        
        for(CFIndex index1=PSDimensionLowestIndex(dim1);index1<highestIndex1;index1++) {
            for(CFIndex index0=PSDimensionLowestIndex(dim0);index0<highestIndex0;index0++) {
                UInt32 datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
                count += (long) sizeof(UInt32);
                void *ptr = &datum;
                float real = *((float *)ptr);
                
                datum = CFSwapInt32(*((UInt32 *) &(bytes[count])));
                count += (long) sizeof(UInt32);
                ptr = &datum;
                float imag = *((float *)ptr);
                PSScalarRef response = PSScalarCreateWithFloatComplex(real + I*imag, PSUnitDimensionlessAndUnderived());
                PSIndexArraySetValueAtIndex(indexValues, 0, index0);
                PSIndexArraySetValueAtIndex(indexValues, 1, index1);
                PSDependentVariableSetValueAtCoordinateIndexes(theDependentVariable, 0, dimensions, indexValues, response, error);
                CFRelease(response);
            }
            count += (long) sizeof(UInt32);
            count += (long) sizeof(UInt32);
        }
    }
    
    CFRelease(indexValues);
    PSPlotRef thePlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(dataset, 0));
    PSPlotReset(thePlot);
    PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);

    return dataset;
}
