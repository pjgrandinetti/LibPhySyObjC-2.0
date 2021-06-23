//
//  PSMath.h
//
//  Created by PhySy Ltd on 2/17/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSMath
 PSMath extends math functions with additional methods.
  
 @copyright PhySy Ltd
 */
bool IsPowerOfTwo(CFIndex number);

SInt32 PSByteSwapSint32(SInt32 integer);
SInt64 PSByteSwapSint64(SInt64 integer);
float PSByteSwapFloat(float value);
double PSByteSwapDouble(double value);


SInt32 PSCastUInt32ToSInt32(UInt32 integer);
SInt64 PSCastUInt64ToSInt64(UInt64 integer);
float PSCastUInt32ToFloat(UInt32 integer);
double PSCastUInt64ToFloat(UInt64 integer);
/*!
 @function PSNumberTypeElementSize
 @abstract returns an integer indicating the number of bytes per element.
 @param elementType The numberType
 @result number of bytes
 */
int PSNumberTypeElementSize(numberType elementType);
int CSDMNumberTypeElementSize(csdmNumericType elementType);

/*!
 @function PSNumberTypeIsComplex
 @abstract returns boolean indicating whether numberType is complex.
 @param elementType The numberType
 @result true or false
 */
bool PSNumberTypeIsComplex(numberType elementType);
bool CSDMNumberTypeIsComplex(csdmNumericType elementType);


/*!
 @function PSCompareIntegerValues
 @abstract Compares two integer values and returns a comparison result.
 @param value The first value to compare..
 @param otherValue The second value to compare.
 @result A PSComparisonResult constant that indicates whether number is equal to, less than, or greater than otherNumber.
 Possible values are kPSCompareLessThan, kPSCompareEqualTo, kPSCompareGreaterThan
 */
PSComparisonResult PSCompareIntegerValues(int64_t value, int64_t otherValue);

/*!
 @function PSCompareFloatValues
 @abstract Compares two float values, taking into account machine precision,  and returns a comparison result.
 @param value The first value to compare..
 @param otherValue The second value to compare.
 @result A PSComparisonResult constant that indicates whether number is equal to, less than, or greater than otherNumber.
 Possible values are kPSCompareLessThan, kPSCompareEqualTo, kPSCompareGreaterThan
 */
PSComparisonResult PSCompareFloatValues(float value, float otherValue);

/*!
 @function PSCompareDoubleValues
 @abstract Compares two double values, taking into account machine precision,  and returns a comparison result.
 @param value The first value to compare..
 @param otherValue The second value to compare.
 @result A PSComparisonResult constant that indicates whether number is equal to, less than, or greater than otherNumber.
 Possible values are kPSCompareLessThan, kPSCompareEqualTo, kPSCompareGreaterThan
 */
PSComparisonResult PSCompareDoubleValues(double value, double otherValue);

/*!
 @function PSCompareFloatValuesLoose
 @abstract Compares two float values, taking into account machine precision,  and returns a comparison result.
 @param value The first value to compare..
 @param otherValue The second value to compare.
 @result A PSComparisonResult constant that indicates whether number is equal to, less than, or greater than otherNumber.
 Possible values are kPSCompareLessThan, kPSCompareEqualTo, kPSCompareGreaterThan
 */
PSComparisonResult PSCompareFloatValuesLoose(float value, float otherValue);

/*!
 @function PSCompareDoubleValuesLoose
 @abstract Compares two double values, taking into account machine precision,  and returns a comparison result.
 @param value The first value to compare..
 @param otherValue The second value to compare.
 @result A PSComparisonResult constant that indicates whether number is equal to, less than, or greater than otherNumber.
 Possible values are kPSCompareLessThan, kPSCompareEqualTo, kPSCompareGreaterThan
 */
PSComparisonResult PSCompareDoubleValuesLoose(double value, double otherValue);

/*
 @function cargument
 @abstract Calculates the argument of a complex number.
 @param z the complex number.
 @result the argument
 */
double cargument(double complex z);

double complex ccbrt(double complex z);
double complex cqtrt(double complex z);

double PSDoubleFloor(double value);
double PSDoubleCeil(double value);
double sine(double angle);
double complex complex_cosine(double complex angle);
double complex complex_sine(double complex angle);
double complex complex_tangent(double complex angle);
double complex raise_to_integer_power(double complex x, long power);


int simplex(float *vertices,
            float functionValues[],
            int numberOfDimensions,
            float tolerance,
            float (*function)(float [], void *),
            void *ptr);
