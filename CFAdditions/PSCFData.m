//
//  PSCFData.c
//  LibPhySyObjC
//
//  Created by Philip Grandinetti on 1/6/19.
//  Copyright © 2019 PhySy Ltd. All rights reserved.
//

#import "CFAdditions.h"
#define BUFFERSIZE 1024 * 16


CFDataRef PSCFDataCreateDataFromURL( CFURLRef url )
{
    IF_NO_OBJECT_EXISTS_RETURN(url, NULL);

    CFMutableDataRef fileContent = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFReadStreamRef stream = CFReadStreamCreateWithFile(kCFAllocatorDefault, url);
    
    if (stream) {
        if (CFReadStreamOpen(stream)) {
            UInt8 buffer[BUFFERSIZE];
            CFIndex bytesRead;
            do {
                bytesRead = CFReadStreamRead(stream, buffer, sizeof(buffer));
                if (bytesRead > 0) {
                    CFDataAppendBytes(fileContent, buffer, bytesRead);
                }
            } while (bytesRead > 0);
            CFReadStreamClose(stream);
        }
        CFRelease(stream);
    }
    
    return fileContent;
}


CFDataRef PSCFDataCreateFromNSNumberArray(CFArrayRef array, csdmNumericType elementType)
{
    IF_NO_OBJECT_EXISTS_RETURN(array, NULL);
    CFIndex count = CFArrayGetCount(array);
    
    switch (elementType) {
        case kCSDMNumberUInt8Type:
        case  kCSDMNumberSInt8Type:
        {
            int8_t values[count];
            for(CFIndex index = 0; index<count; index++) {
                CFNumberRef number = CFArrayGetValueAtIndex(array, index);
                CFNumberGetValue(number, kCFNumberSInt8Type, &values[index]);
            }
            return CFDataCreate(kCFAllocatorDefault,(const UInt8 *) values, count*sizeof(int8_t));
        }
        case kCSDMNumberUInt16Type:
        case  kCSDMNumberSInt16Type:
        {
            int16_t values[count];
            for(CFIndex index = 0; index<count; index++) {
                CFNumberRef number = CFArrayGetValueAtIndex(array, index);
                CFNumberGetValue(number, kCFNumberSInt16Type, &values[index]);
            }
            return CFDataCreate(kCFAllocatorDefault,(const UInt8 *) values, count*sizeof(int16_t));
        }
        case  kCSDMNumberUInt32Type:
        case  kCSDMNumberSInt32Type:
        {
            int32_t values[count];
            for(CFIndex index = 0; index<count; index++) {
                CFNumberRef number = CFArrayGetValueAtIndex(array, index);
                CFNumberGetValue(number, kCFNumberSInt32Type, &values[index]);
            }
            return CFDataCreate(kCFAllocatorDefault,(const UInt8 *) values, count*sizeof(int32_t));
        }
        case  kCSDMNumberUInt64Type:
        case  kCSDMNumberSInt64Type:
        {
            int64_t values[count];
            for(CFIndex index = 0; index<count; index++) {
                CFNumberRef number = CFArrayGetValueAtIndex(array, index);
                CFNumberGetValue(number, kCFNumberSInt64Type, &values[index]);
            }
            return CFDataCreate(kCFAllocatorDefault,(const UInt8 *) values, count*sizeof(int64_t));
        }
        case  kCSDMNumberFloat32Type:
        case  kCSDMNumberComplex64Type:
        {
            float values[count];
            for(CFIndex index = 0; index<count; index++) {
                CFNumberRef number = CFArrayGetValueAtIndex(array, index);
                CFNumberGetValue(number, kCFNumberFloat32Type, &values[index]);
            }
            return CFDataCreate(kCFAllocatorDefault,(const UInt8 *) values, count*sizeof(float));
        }
        case kCSDMNumberFloat64Type:
        case  kCSDMNumberComplex128Type:
        {
            double values[count];
            for(CFIndex index = 0; index<count; index++) {
                CFNumberRef number = CFArrayGetValueAtIndex(array, index);
                CFNumberGetValue(number, kCFNumberFloat64Type, &values[index]);
            }
            return CFDataCreate(kCFAllocatorDefault,(const UInt8 *) values, count*sizeof(double));
        }
            
    }
    
}

CFDataRef PSCFDataCreateFromCSDMNumericTypeData(CFDataRef csdmData, csdmNumericType srcType, numberType destType)
{
    CFIndex srcLength = CFDataGetLength(csdmData);
    int destElementSize = PSNumberTypeElementSize(destType);
    int srcElementSize = CSDMNumberTypeElementSize(srcType);
    
    CFIndex size = srcLength/srcElementSize;
    
    CFIndex destLength = srcLength*destElementSize/srcElementSize;
    CFMutableDataRef destData = CFDataCreateMutable(kCFAllocatorDefault,destLength);
    CFDataSetLength(destData, destLength);
    switch(destType) {
        case kPSNumberFloat32Type: {
            float *destBytes = (float *) CFDataGetBytePtr(destData);
            switch(srcType) {
                case kCSDMNumberUInt8Type: {
                    uint8_t *srcBytes = (uint8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt16Type: {
                    uint16_t *srcBytes = (uint16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt32Type: {
                    uint32_t *srcBytes = (uint32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt64Type: {
                    uint64_t *srcBytes = (uint64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt8Type: {
                    int8_t *srcBytes = (int8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt16Type: {
                    int16_t *srcBytes = (int16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt32Type: {
                    int32_t *srcBytes = (int32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt64Type: {
                    int64_t *srcBytes = (int64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberFloat32Type: {
                    float *srcBytes = (float *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberFloat64Type: {
                    double *srcBytes = (double *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex64Type: {
                    float complex *srcBytes = (float complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex128Type: {
                    double complex *srcBytes = (double complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float) srcBytes[memOffset];
                }
                    break;
            }
        }
            break;
        case kPSNumberFloat64Type: {
            double *destBytes = (double *) CFDataGetBytePtr(destData);
            switch(srcType) {
                case kCSDMNumberUInt8Type: {
                    uint8_t *srcBytes = (uint8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt16Type: {
                    uint16_t *srcBytes = (uint16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt32Type: {
                    uint32_t *srcBytes = (uint32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt64Type: {
                    uint64_t *srcBytes = (uint64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt8Type: {
                    int8_t *srcBytes = (int8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt16Type: {
                    int16_t *srcBytes = (int16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt32Type: {
                    int32_t *srcBytes = (int32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt64Type: {
                    int64_t *srcBytes = (int64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberFloat32Type: {
                    float *srcBytes = (float *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
               case kCSDMNumberFloat64Type: {
                    double *srcBytes = (double *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex64Type: {
                    float complex *srcBytes = (float complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex128Type: {
                    double complex *srcBytes = (double complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double) srcBytes[memOffset];
                }
                    break;
            }
        }
            break;
        case kPSNumberFloat32ComplexType: {
            float complex *destBytes = (float complex *) CFDataGetBytePtr(destData);
            switch(srcType) {
                case kCSDMNumberUInt8Type: {
                    uint8_t *srcBytes = (uint8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt16Type: {
                    uint16_t *srcBytes = (uint16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt32Type: {
                    uint32_t *srcBytes = (uint32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt64Type: {
                    uint64_t *srcBytes = (uint64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt8Type: {
                    int8_t *srcBytes = (int8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt16Type: {
                    int16_t *srcBytes = (int16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt32Type: {
                    int32_t *srcBytes = (int32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
               case kCSDMNumberSInt64Type: {
                    int64_t *srcBytes = (int64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
               case kCSDMNumberFloat32Type: {
                    float *srcBytes = (float *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberFloat64Type: {
                    double *srcBytes = (double *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex64Type: {
                    float complex *srcBytes = (float complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex128Type: {
                    double complex *srcBytes = (double complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (float complex) srcBytes[memOffset];
                }
                    break;
            }
        }
            break;
        case kPSNumberFloat64ComplexType: {
            double complex *destBytes = (double complex *) CFDataGetBytePtr(destData);
            switch(srcType) {
                case kCSDMNumberUInt8Type: {
                    uint8_t *srcBytes = (uint8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt16Type: {
                    uint16_t *srcBytes = (uint16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt32Type: {
                    uint32_t *srcBytes = (uint32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberUInt64Type: {
                    uint64_t *srcBytes = (uint64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt8Type: {
                    int8_t *srcBytes = (int8_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt16Type: {
                    int16_t *srcBytes = (int16_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt32Type: {
                    int32_t *srcBytes = (int32_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberSInt64Type: {
                    int64_t *srcBytes = (int64_t *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberFloat32Type: {
                    float *srcBytes = (float *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberFloat64Type: {
                    double *srcBytes = (double *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex64Type: {
                    float complex *srcBytes = (float complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
                case kCSDMNumberComplex128Type: {
                    double complex *srcBytes = (double complex *) CFDataGetBytePtr(csdmData);
                    for(CFIndex memOffset = 0; memOffset < size; memOffset++)
                        destBytes[memOffset] = (double complex) srcBytes[memOffset];
                }
                    break;
            }
        }
            break;
    }
    return destData;
}
