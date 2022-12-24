//
//  PSDatasetImportImage.c
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>


PSDatasetRef PSDatasetImportImageCreateSignalWithCGImages(CFArrayRef images, double frameIncrementInSec, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    CGImageRef image = (CGImageRef) CFArrayGetValueAtIndex(images, 0);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    size_t height = CGImageGetHeight(image);
    size_t width = CGImageGetWidth(image);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(image);
    size_t bytesPerPixel = bytesPerRow/width;
    CGBitmapInfo bitMapInfo = CGImageGetBitmapInfo(image);
    bool floatComponents = (bitMapInfo & kCGBitmapFloatComponents);
    
    CFIndex imageCount = CFArrayGetCount(images);
    
    PSScalarRef increment = PSScalarCreateWithDouble(1, NULL);
    PSDimensionRef dim0 = PSLinearDimensionCreateDefault(width, increment, kPSQuantityDimensionless,kPSQuantityDimensionless);
    PSDimensionRef dim1 = PSLinearDimensionCreateDefault(height, increment, kPSQuantityDimensionless,kPSQuantityDimensionless);
    CFRelease(increment);
    PSDimensionSetInverseQuantityName(dim0, kPSQuantityDimensionless);
    PSDimensionSetInverseQuantityName(dim1, kPSQuantityDimensionless);
    PSDimensionMakeNiceUnits(dim0);
    PSDimensionMakeNiceUnits(dim1);
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(dimensions, dim0);
    CFArrayAppendValue(dimensions, dim1);
    CFRelease(dim0);
    CFRelease(dim1);
    if(imageCount>1) {
        PSScalarRef dwell = PSScalarCreateWithDouble((double) frameIncrementInSec, PSUnitForSymbol(CFSTR("s")));
        PSDimensionRef dim2 = PSLinearDimensionCreateDefault(imageCount, dwell, kPSQuantityTime, kPSQuantityFrequency);
        CFRelease(dwell);
        CFArrayAppendValue(dimensions, dim2);
    }
    
    size_t size = height*width;
    
    PSDatasetRef dataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(dataset, dimensions, NULL);
    CFRelease(dimensions);
    
    numberType responseType = kPSNumberFloat32Type;   // For now, we convert all images to floating point.
    //    numberType responseType = kPSNumberSInt32Type;
    if(floatComponents) responseType = kPSNumberFloat32Type;
    
    CGRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.height = height;
    rect.size.width = width;
    
    
    if(bytesPerPixel==1) {
        PSDependentVariableRef dV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("pixel_1"), kPSNumberFloat32Type, kPSDatasetSizeFromDimensions);
        PSDependentVariableSetName(dV, CFSTR("gray image"));
        CFMutableDataRef values = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(dV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(values, PSDependentVariableSize(dV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        
        float *responses = (float *) CFDataGetMutableBytePtr(values);
        CFIndex count = bytesPerRow*height;
        CFIndex memOffset = 0;
        for(CFIndex depth = 0; depth<CFArrayGetCount(images);depth++) {
            CGImageRef image = (CGImageRef) CFArrayGetValueAtIndex(images, depth);
            
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         width,
                                                         height,
                                                         bitsPerComponent,
                                                         bytesPerRow,
                                                         CGImageGetColorSpace(image),
                                                         (CGBitmapInfo) bitMapInfo);
            if(NULL==context) {
                context = CGBitmapContextCreate(NULL,
                                                width,
                                                height,
                                                bitsPerComponent,
                                                bytesPerRow,
                                                CGImageGetColorSpace(image),
                                                (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
            }
            if(NULL==context) {
                CFRelease(values);
                return NULL;
                
            }
            
            
            CGContextDrawImage(context, rect, image);
            unsigned char *data = CGBitmapContextGetData(context);
            
            for(CFIndex index = 0; index < count; index+=bytesPerPixel) {
                responses[memOffset] = (float) data[index];
                memOffset++;
            }
            CFRelease(context);
        }
        
        PSDependentVariableSetComponentAtIndex(dV, values, 0);
        PSDependentVariableSetComponentLabelAtIndex(dV, CFSTR("gray"), 0);
        CFRelease(values);
    }
    else if(bytesPerPixel==2) {
        PSDependentVariableRef alphaDV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32Type, kPSDatasetSizeFromDimensions);
        
        PSDependentVariableRef grayDV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("pixel_1"), kPSNumberFloat32Type, kPSDatasetSizeFromDimensions);
        PSDependentVariableSetName(grayDV, CFSTR("gray image"));
        PSDependentVariableSetName(alphaDV, CFSTR("alpha channel"));
        
        CFMutableDataRef blackWhiteValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(grayDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFMutableDataRef alphaValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(alphaDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(blackWhiteValues,  PSDependentVariableSize(grayDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(alphaValues,  PSDependentVariableSize(alphaDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        
        float *blackWhiteResponses = (float *) CFDataGetMutableBytePtr(blackWhiteValues);
        float *alphaResponses = (float *) CFDataGetMutableBytePtr(alphaValues);
        CFIndex count = bytesPerRow*height;
        CFIndex memOffset = 0;
        for(CFIndex depth = 0; depth<CFArrayGetCount(images);depth++) {
            CGImageRef image = (CGImageRef) CFArrayGetValueAtIndex(images, depth);
            
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         width,
                                                         height,
                                                         bitsPerComponent,
                                                         bytesPerRow,
                                                         CGImageGetColorSpace(image),
                                                         (CGBitmapInfo) bitMapInfo);
            if(NULL==context) {
                context = CGBitmapContextCreate(NULL,
                                                width,
                                                height,
                                                bitsPerComponent,
                                                bytesPerRow,
                                                CGImageGetColorSpace(image),
                                                (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
            }
            if(NULL==context) {
                CFRelease(blackWhiteValues);
                CFRelease(alphaValues);
                return NULL;
            }
            
            
            CGContextDrawImage(context, rect, image);
            unsigned char *data = CGBitmapContextGetData(context);
            
            for(CFIndex index = 0; index < count; index+=bytesPerPixel) {
                blackWhiteResponses[memOffset] = (float) data[index];
                alphaResponses[memOffset] = (float) data[index+1];
                memOffset++;
            }
            CFRelease(context);
        }
        PSDependentVariableSetComponentAtIndex(grayDV, blackWhiteValues, 0);
        PSDependentVariableSetComponentAtIndex(alphaDV, alphaValues, 1);
        PSDependentVariableSetComponentLabelAtIndex(grayDV, CFSTR("gray"), 0);
        PSDependentVariableSetComponentLabelAtIndex(alphaDV, CFSTR("alpha"), 0);
        CFRelease(blackWhiteValues);
        CFRelease(alphaValues);
    }
    else if(bytesPerPixel==3) {
        PSDependentVariableRef rgbDV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("pixel_3"), responseType, kPSDatasetSizeFromDimensions);
        CFMutableDataRef redValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFMutableDataRef greenValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFMutableDataRef blueValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(redValues, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(greenValues, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(blueValues, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        PSDependentVariableSetName(rgbDV, CFSTR("RGB image"));
        
        float *redResponses = (float *) CFDataGetMutableBytePtr(redValues);
        float *greenResponses = (float *) CFDataGetMutableBytePtr(greenValues);
        float *blueResponses = (float *) CFDataGetMutableBytePtr(blueValues);
        CFIndex count = bytesPerRow*height;
        CFIndex memOffset = 0;
        
        for(CFIndex depth = 0; depth<CFArrayGetCount(images);depth++) {
            CGImageRef image = (CGImageRef) CFArrayGetValueAtIndex(images, depth);
            
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         width,
                                                         height,
                                                         bitsPerComponent,
                                                         bytesPerRow,
                                                         CGImageGetColorSpace(image),
                                                         (CGBitmapInfo) bitMapInfo);
            if(NULL==context) {
                context = CGBitmapContextCreate(NULL,
                                                width,
                                                height,
                                                bitsPerComponent,
                                                bytesPerRow,
                                                CGImageGetColorSpace(image),
                                                (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
            }
            if(NULL==context) {
                CFRelease(redValues);
                CFRelease(greenValues);
                CFRelease(blueValues);
                return NULL;
            }

            
            CGContextDrawImage(context, rect, image);
            unsigned char *data = CGBitmapContextGetData(context);
            
            
            for(CFIndex index = 0; index < count; index+=bytesPerPixel) {
                redResponses[memOffset] = (float) data[index];
                greenResponses[memOffset] = (float) data[index+1];
                blueResponses[memOffset] = (float) data[index+2];
                memOffset++;
            }
            CFRelease(context);
        }
        
        PSDependentVariableSetComponentAtIndex(rgbDV, redValues, 0);
        PSDependentVariableSetComponentAtIndex(rgbDV, greenValues, 1);
        PSDependentVariableSetComponentAtIndex(rgbDV, blueValues, 2);
        PSDependentVariableSetComponentLabelAtIndex(rgbDV, CFSTR("red"), 0);
        PSDependentVariableSetComponentLabelAtIndex(rgbDV, CFSTR("green"), 1);
        PSDependentVariableSetComponentLabelAtIndex(rgbDV, CFSTR("blue"), 2);
        CFRelease(redValues);
        CFRelease(greenValues);
        CFRelease(blueValues);
    }
    
    else if(bytesPerPixel==4) {
        PSDependentVariableRef rgbDV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("pixel_3"), responseType, kPSDatasetSizeFromDimensions);
        PSDependentVariableRef alphaDV = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), responseType, kPSDatasetSizeFromDimensions);
        CFMutableDataRef redValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFMutableDataRef greenValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFMutableDataRef blueValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(redValues, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(greenValues, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(blueValues, PSDependentVariableSize(rgbDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        
        CFMutableDataRef alphaValues = CFDataCreateMutable(kCFAllocatorDefault, PSDependentVariableSize(alphaDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        CFDataSetLength(alphaValues, PSDependentVariableSize(alphaDV)*PSNumberTypeElementSize(kPSNumberFloat32Type));
        
        PSDependentVariableSetName(rgbDV, CFSTR("RGB image"));
        PSDependentVariableSetName(alphaDV, CFSTR("alpha channel"));
        
        
        float *redResponses = (float *) CFDataGetMutableBytePtr(redValues);
        float *greenResponses = (float *) CFDataGetMutableBytePtr(greenValues);
        float *blueResponses = (float *) CFDataGetMutableBytePtr(blueValues);
        float *alphaResponses = (float *) CFDataGetMutableBytePtr(alphaValues);
        CFIndex count = bytesPerRow*height;
        CFIndex memOffset = 0;
        
        for(CFIndex depth = 0; depth<CFArrayGetCount(images);depth++) {
            CGImageRef image = (CGImageRef) CFArrayGetValueAtIndex(images, depth);
            
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         width,
                                                         height,
                                                         bitsPerComponent,
                                                         bytesPerRow,
                                                         CGImageGetColorSpace(image),
                                                         (CGBitmapInfo) bitMapInfo);
            if(NULL==context) {
                context = CGBitmapContextCreate(NULL,
                                                width,
                                                height,
                                                bitsPerComponent,
                                                bytesPerRow,
                                                CGImageGetColorSpace(image),
                                                (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
            }
            if(NULL==context) {
                CFRelease(redValues);
                CFRelease(greenValues);
                CFRelease(blueValues);
                CFRelease(alphaValues);
                return NULL;
            }

            
            CGContextDrawImage(context, rect, image);
            unsigned char *data = CGBitmapContextGetData(context);
            
            for(CFIndex index = 0; index < count; index+=bytesPerPixel) {
                redResponses[memOffset] = (float) data[index];
                greenResponses[memOffset] = (float) data[index+1];
                blueResponses[memOffset] = (float) data[index+2];
                alphaResponses[memOffset] = (float) data[index+3];
                memOffset++;
            }
            CFRelease(context);
        }
        PSDependentVariableSetComponentAtIndex(rgbDV, redValues, 0);
        PSDependentVariableSetComponentAtIndex(rgbDV, greenValues, 1);
        PSDependentVariableSetComponentAtIndex(rgbDV, blueValues, 2);
        PSDependentVariableSetComponentAtIndex(alphaDV, alphaValues, 0);
        PSDependentVariableSetComponentLabelAtIndex(rgbDV, CFSTR("red"), 0);
        PSDependentVariableSetComponentLabelAtIndex(rgbDV, CFSTR("green"), 1);
        PSDependentVariableSetComponentLabelAtIndex(rgbDV, CFSTR("blue"), 2);
        PSDependentVariableSetComponentLabelAtIndex(alphaDV, CFSTR("alpha"), 0);
        CFRelease(redValues);
        CFRelease(greenValues);
        CFRelease(blueValues);
        CFRelease(alphaValues);
    }
    
    
    CFIndex dvCount = PSDatasetDependentVariablesCount(dataset);
    for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef dV = PSDatasetGetDependentVariableAtIndex(dataset, dvIndex);
        CFIndex componentsCount = PSDependentVariableComponentsCount(dV);
        PSPlotRef thePlot = PSDependentVariableGetPlot(dV);
        PSPlotReset(thePlot);
        if(componentsCount == 1) {
            PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorBlack);
            PSPlotSetImage2DPlotTypeAtComponentIndex(thePlot,kPSImagePlotTypeValue,0);
        }
        else if(componentsCount == 2) {
            PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorBlack);
            PSPlotSetImage2DPlotTypeAtComponentIndex(thePlot,2,0);
            PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorBlack);
            PSPlotSetImage2DPlotTypeAtComponentIndex(thePlot,kPSImagePlotTypeValue,1);
        }
        else if(componentsCount==3) {
            PSPlotSetComponentColorAtIndex(thePlot, 0, kPSPlotColorRed);
            PSPlotSetComponentColorAtIndex(thePlot, 1, kPSPlotColorGreen);
            PSPlotSetComponentColorAtIndex(thePlot, 2, kPSPlotColorBlue);
            PSPlotSetShowImage2DCombineRGB(thePlot, true);
        }
        PSPlotSetImag(thePlot, false);
        PSPlotSetShowGrid(thePlot, false);
        PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
        PSAxisSetBipolar(responseAxis, false);
        PSAxisReset(responseAxis, kPSQuantityDimensionless);
        PSAxisSetReverse(PSPlotVerticalAxis(thePlot), true);
    }
    return dataset;
}

PSDatasetRef PSDatasetImportImageCreateSignalWithData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    CGImageRef image = NULL;
    CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData (contents);
    
    // Get CGImage from CFDataRef
    image = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    // If the image isn't a JPG Image, would be PNG file
    if(NULL==image) image = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    if(NULL==image) {
        CFRelease(imgDataProvider);
        return NULL;
    }
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithDataProvider(imgDataProvider, NULL);
    CFDictionaryRef metaData = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if(imageSource) CFRelease(imageSource);
    
    
    CFMutableArrayRef images = CFArrayCreateMutable(kCFAllocatorDefault, 1, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(images,image);
    PSDatasetRef dataset = PSDatasetImportImageCreateSignalWithCGImages(images,1.0, error);
    PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(dataset, 0);
    if(metaData) {
        CFDictionaryRef metaDataCopy = (CFDictionaryRef) CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef) metaData, kCFPropertyListMutableContainersAndLeaves);
        PSDependentVariableSetMetaData(dependentVariable, metaDataCopy);
        CFRelease(metaDataCopy);
        CFRelease(metaData);
    }
    if(imgDataProvider) CFRelease(imgDataProvider);
    if(image) CFRelease(image);
    return dataset;
    
}


