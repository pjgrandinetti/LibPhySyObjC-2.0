
//  CFAdditions.h
//
//  Created by PhySy Ltd on 10/7/11.
//  Copyright 2013 PhySy Ltd. All rights reserved.
//

#import <stdio.h>
#import <stdarg.h>
#import <stdlib.h>
#import <complex.h>
#import <stdbool.h>
#import <unistd.h>
#import <math.h>

//#define PhySyDEBUG 

#define IS_BIG_ENDIAN (*(uint16_t *)"\0\xff" < 0x100)

#define FREE(X) {free(X); X=NULL;}
#define IF_NO_OBJECT_EXISTS_RETURN(OBJECT,X) if(OBJECT==NULL) {NSLog(@"*** WARNING - %s - object doesn't exist.  line %d\n",__func__,__LINE__); return X;}

typedef union __PSNumber
{
    float   floatValue;
    double  doubleValue;
    float complex floatComplexValue;
    double complex doubleComplexValue;
} __PSNumber;



//kCFNumberSInt8Type = 1,
//kCFNumberSInt16Type = 2,
//kCFNumberSInt32Type = 3,
//kCFNumberSInt64Type = 4,
//kCFNumberFloat32Type = 5,
//kCFNumberFloat64Type = 6,    /* 64-bit IEEE 754 */
///* Basic C types */
//kCFNumberCharType = 7,
//kCFNumberShortType = 8,
//kCFNumberIntType = 9,
//kCFNumberLongType = 10,
//kCFNumberLongLongType = 11,
//kCFNumberFloatType = 12,
//kCFNumberDoubleType = 13,
///* Other */
//kCFNumberCFIndexType = 14,
//kCFNumberNSIntegerType API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) = 15,
//kCFNumberCGFloatType API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) = 16,
//kCFNumberMaxType = 16


typedef enum csdmNumericType {
    kCSDMNumberUInt8Type = -1,
    kCSDMNumberSInt8Type = 1,
    kCSDMNumberUInt16Type = -2,
    kCSDMNumberSInt16Type = 2,
    kCSDMNumberUInt32Type = -3,
    kCSDMNumberSInt32Type = 3,
    kCSDMNumberUInt64Type = -4,
    kCSDMNumberSInt64Type = 4,
    kCSDMNumberFloat32Type = 12,
    kCSDMNumberFloat64Type = 13,
    kCSDMNumberComplex64Type = 24,
    kCSDMNumberComplex128Type = 26,
} csdmNumericType;

/*!
 @enum numberType
 @constant kPSNumberFloat32Type Basic C float type.
 @constant kPSNumberFloat64Type Basic C double type.
 @constant kPSNumberLongDoubleType Basic C double type.
 @constant kPSNumberFloat32ComplexType Basic C float complex type.
 @constant kPSNumberFloat64ComplexType Basic C double complex type.
 */

typedef enum numberType {
    kPSNumberFloat32Type = 12,
    kPSNumberFloat64Type = 13,
    kPSNumberFloat32ComplexType = 24,
    kPSNumberFloat64ComplexType = 26,
} numberType;

/*!
 @enum complexPart
 @constant kPSRealPart real part of complex number.
 @constant kPSImaginaryPart imaginary part of complex number.
 @constant kPSMagnitudePart magnitude part of complex number.
 @constant kPSArgumentPart argument part of complex number.
 */
typedef enum complexPart {
    kPSRealPart,
    kPSImaginaryPart,
    kPSMagnitudePart,
    kPSArgumentPart,
} complexPart;

/*!
 @enum PSComparisonResult
 @constant kPSCompareLessThan Returned by a comparison function if the first value is less than the second value..
 @constant kPSCompareEqualTo Returned by a comparison function if the first value is equal to the second value.
 @constant kPSCompareGreaterThan Returned by a comparison function if the first value is greater than the second value.
 @constant kPSCompareUnequalDimensionalities Returned by a comparison function if the two values have different dimensionalities.
 */
typedef enum PSComparisonResult {
    kPSCompareLessThan = -1,
    kPSCompareEqualTo = 0,
    kPSCompareGreaterThan = 1,
    kPSCompareUnequalDimensionalities = 2,
    kPSCompareNoSingleValue = 3,
    kPSCompareError = 99
} PSComparisonResult;

#define kPSFoundationErrorDomain            CFSTR("com.PhySyApps.Foundation.ErrorDomain")

#import <Foundation/Foundation.h>
#import "PSMath.h"
#import "PSIndexSet.h"
#import "PSCFArray.h"
#import "PSCFData.h"
#import "PSCFDictionary.h"
#import "PSCFString.h"
#import "PSCFNumber.h"
#import "PSCFSet.h"
#import "PSCFType.h"

