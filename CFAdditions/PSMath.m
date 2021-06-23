//
//  PSMath.c
//
//  Created by PhySy Ltd on 2/17/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "CFAdditions.h"

bool IsPowerOfTwo(CFIndex number)
{
    if(number<0) number = -number;
    
    return (number != 0) && ((number & (number - 1)) == 0);
}

SInt32 PSByteSwapSint32(SInt32 integer)
{
    UInt32 result = CFSwapInt32(*((UInt32 *) &integer));
    return *((SInt32 *) &result);
}

SInt64 PSByteSwapSint64(SInt64 integer)
{
    UInt64 result = CFSwapInt64(*((UInt64 *) &integer));
    return *((SInt64 *) &result);
}

float PSByteSwapFloat(float value)
{
    UInt32 result = CFSwapInt32(*((UInt32 *) &value));
    return *((float *) &result);
}

double PSByteSwapDouble(double value)
{
    UInt64 result = CFSwapInt64(*((UInt64 *) &value));
    return *((double *) &result);
}


SInt32 PSCastUInt32ToSInt32(UInt32 integer) {
    void *ptr = &integer;
    return *((SInt32 *)ptr);
}

SInt64 PSCastUInt64ToSInt64(UInt64 integer) {
    void *ptr = &integer;
    return *((SInt64 *)ptr);
}

float PSCastUInt32ToFloat(UInt32 integer) {
    void *ptr = &integer;
    return *((float *)ptr);
}

double PSCastUInt64ToFloat(UInt64 integer) {
    void *ptr = &integer;
    return *((double *)ptr);
}

static bool AlmostEqual2sComplementFloat(float A, float B, int maxUlps)
{
    // Make sure maxUlps is non-negative and small enough that the
    // default NAN won't compare as equal to anything.
    assert(maxUlps > 0 && maxUlps < 4 * 1024 * 1024);
    int aInt = *(int*)&A;
    // Make aInt lexicographically ordered as a twos-complement int
    if (aInt < 0)
        aInt = 0x80000000 - aInt;
    // Make bInt lexicographically ordered as a twos-complement int
    int bInt = *(int*)&B;
    if (bInt < 0)
        bInt = 0x80000000 - bInt;
    int intDiff = abs(aInt - bInt);
    if (intDiff <= maxUlps)
        return true;
    return false;
}

static bool AlmostEqual2sComplementDouble(double A, double B, int maxUlps)
{
    // Make sure maxUlps is non-negative and small enough that the
    // default NAN won't compare as equal to anything.
    assert(maxUlps > 0 && maxUlps < 8 * 1024 * 1024);
    int64_t aInt = *(int64_t*)&A;
    // Make aInt lexicographically ordered as a twos-complement int
    if (aInt < 0)
        aInt = 0x8000000000000000 - aInt;
    // Make bInt lexicographically ordered as a twos-complement int
    int64_t bInt = *(int64_t*)&B;
    if (bInt < 0)
        bInt = 0x8000000000000000 - bInt;
    int64_t intDiff = llabs(aInt - bInt);
    if (intDiff <= maxUlps)
        return true;
    return false;
}

int PSNumberTypeElementSize(numberType elementType)
{
    switch (elementType) {
        case kPSNumberFloat32Type:
            return sizeof(float);
        case kPSNumberFloat64Type:
            return sizeof(double);
        case kPSNumberFloat32ComplexType:
            return sizeof(float complex);
        case kPSNumberFloat64ComplexType:
            return sizeof(double complex);
    }
    return 0;
}

bool PSNumberTypeIsComplex(numberType elementType)
{
    switch (elementType) {
        case kPSNumberFloat32Type:
        case kPSNumberFloat64Type:
            return false;
        case kPSNumberFloat32ComplexType:
        case kPSNumberFloat64ComplexType:
            return true;
    }
    return false;
}

int CSDMNumberTypeElementSize(csdmNumericType elementType)
{
    switch (elementType) {
        case kCSDMNumberUInt8Type:
            return sizeof(uint8_t);
        case kCSDMNumberSInt8Type:
            return sizeof(int8_t);
        case kCSDMNumberUInt16Type:
            return sizeof(u_int16_t);
        case kCSDMNumberSInt16Type:
            return sizeof(int16_t);
        case kCSDMNumberUInt32Type:
            return sizeof(uint32_t);
        case kCSDMNumberSInt32Type:
            return sizeof(int32_t);
        case kCSDMNumberUInt64Type:
            return sizeof(uint64_t);
        case kCSDMNumberSInt64Type:
            return sizeof(int64_t);
        case kCSDMNumberFloat32Type:
            return sizeof(Float32);
        case kCSDMNumberFloat64Type:
            return sizeof(Float64);
        case kCSDMNumberComplex64Type:
            return 2*sizeof(Float32);
        case kCSDMNumberComplex128Type:
            return 2*sizeof(Float64);
    }
    return 0;
}

bool CSDMNumberTypeIsComplex(csdmNumericType elementType)
{
    switch (elementType) {
        case kCSDMNumberComplex64Type:
        case kCSDMNumberComplex128Type:
            return true;
        default:
            return false;
    }
    return false;
}

PSComparisonResult PSCompareIntegerValues(int64_t value, int64_t otherValue)
{
    PSComparisonResult result = kPSCompareGreaterThan;
    if(value>otherValue) return result;
    if(value<otherValue) result = kPSCompareLessThan;
    if(value==otherValue) result = kPSCompareEqualTo;
    return result;
}

PSComparisonResult PSCompareDoubleValues(double value, double otherValue)
{
//    if(AlmostEqual2sComplementDouble(value, otherValue, 12)) return kPSCompareEqualTo;
    if(AlmostEqual2sComplementDouble(value, otherValue, 18)) return kPSCompareEqualTo;
    if(value>otherValue) return kPSCompareGreaterThan;
    return kPSCompareLessThan;
}

PSComparisonResult PSCompareFloatValues(float value, float otherValue)
{
    if(AlmostEqual2sComplementFloat(value, otherValue, 8)) return kPSCompareEqualTo;
    if(value>otherValue) return kPSCompareGreaterThan;
    return kPSCompareLessThan;
}

PSComparisonResult PSCompareDoubleValuesLoose(double value, double otherValue)
{
    if(AlmostEqual2sComplementDouble(value, otherValue, 256)) return kPSCompareEqualTo;
    if(value>otherValue) return kPSCompareGreaterThan;
    return kPSCompareLessThan;
}

PSComparisonResult PSCompareFloatValuesLoose(float value, float otherValue)
{
    if(AlmostEqual2sComplementFloat(value, otherValue, 128)) return kPSCompareEqualTo;
    if(value>otherValue) return kPSCompareGreaterThan;
    return kPSCompareLessThan;
}

double complex ccbrt(double complex z)
{
    return cpow(z, 1./3.);
}

double complex cqtrt(double complex z)
{
    return cpow(z, 1./4.);
}

double cargument(double complex z)
{
    double temp = cabs(z);
    if(temp == 0.0) return 0.0;
    double cosphase = creal(z)/temp;
    double sinphase = cimag(z)/temp;
    double phase = -acos((double) cosphase);
    if(sinphase < 0) phase *= -1;
    return phase;
}

double sine(double angle)
{
    double my_pi = 4*atan(1);
    int multiple = rint(fabs(angle/my_pi));
    angle = fmod(angle,my_pi)*my_pi;
    if(PSCompareDoubleValues(angle, my_pi)==kPSCompareEqualTo) angle = 0.0;
    if(multiple>0) angle = angle*my_pi;
    return sin(angle);
}

double complex complex_sine(double complex angle)
{
    double my_pi = 4*atan(1);
    double real_angle = creal(angle);
    int multiple = rint(real_angle/my_pi);
    double weight = cos(real_angle);
    return csin(angle) - csin(multiple*my_pi)*weight*weight;
}

double complex complex_cosine(double complex angle)
{
    double complex my_pi = 4*atan(1);
    double real_angle = creal(angle);
    int multiple = rint((real_angle-my_pi/2.)/my_pi);
    double weight = sin(real_angle);
    return  ccos(angle) - ccos((2*multiple+1)*my_pi/2.)*weight*weight;
}

double complex complex_tangent(double complex angle)
{
    double complex cosine = complex_cosine(angle);
    double complex sine = complex_sine(angle);
    if(cosine == 0.0) {
        if(signbit(sine)) return -INFINITY;
        else return INFINITY;
    }
    return sine/cosine;
}

double complex raise_to_integer_power(double complex x, long power)
{
    if(power==0) return 1.;
    if(power>0) {
        double complex result = x;
        for(long i=1;i<power;i++) result *= x;
        if(isnan(result)) return nan(NULL);
        return result;
    }
    else if(x!=0.0){
        double complex result = 1./x;
        for(long i=1;i<-power;i++) result *= 1./x;
        if(isnan(result)) return nan(NULL);
        return result;
    }
    return nan(NULL);
}


double PSDoubleFloor(double value)
{
    double ceilValue = ceil(value);
    if(PSCompareDoubleValues(ceilValue,value) == kPSCompareEqualTo) return ceilValue;
    return floor(value);
}

double PSDoubleCeil(double value)
{
    double floorValue = floor(value);
    if(PSCompareDoubleValues(floorValue,value) == kPSCompareEqualTo) return floorValue;
    return ceil(value);
}

#define NMAX 50000
#define SWAP(a,b) {swap=(a);(a)=(b);(b)=swap;}

float simplexTry(float *vertices,
                 float functionValues[],
                 float psum[],
                 int numberOfDimensions,
                 float (*function)(float [], void *),
                 void *ptr,
                 int highestVertexIndex,
                 float factor)
{
    /*
     Extrapolates by a factor through the face of the simplex across from the high point,
     tries it, and replaces the high point if the new point is better.
     */
    float ptry[numberOfDimensions+1];
    float (*v)[numberOfDimensions] = (float (*)[numberOfDimensions]) vertices;

    float fac1=(1.0-factor)/numberOfDimensions;
    float fac2=fac1-factor;
    for (int j=0;j<numberOfDimensions;j++) ptry[j]=psum[j]*fac1-v[highestVertexIndex][j]*fac2;
    float ytry=(*function)(ptry,ptr);
    if (ytry < functionValues[highestVertexIndex]) {
        functionValues[highestVertexIndex]=ytry;
        for (int j=0;j<numberOfDimensions;j++) {
            psum[j] += ptry[j]-v[highestVertexIndex][j];
            v[highestVertexIndex][j]=ptry[j];
        }
    }
    return ytry;
}


/*!
 @function simplex
 @abstract Performs a simplex multidimensional minimization of a function.
 @param vertices a 2D matrix [1..numberOfDimensions+1][1..numberOfDimensions]
 @param functionValues a vector [1..numberOfDimensions+1] with the function evaluated at vertices.
        must be pre-initialized to the values.
 @param numberOfDimensions number of dimensions
 @param tolerance tolerance for convergence
 @param function the function to be minimized
 @result number of function evaluations taken.
 @comment On output, vertices and functionValues are reset to numberOfDimensions+1 new points 
        all within ftol of a minimum function value,
 */
int simplex(float *vertices,
            float functionValues[],
            int numberOfDimensions,
            float tolerance,
            float (*function)(float [], void *),
            void *ptr)
{
    
    float (*v)[numberOfDimensions] = (float (*)[numberOfDimensions]) vertices;
    int  inhi;
    int numberOfVertices = numberOfDimensions+1;
    float swap, ysave;
    
    float psum[numberOfVertices];

    uint32_t numberOfFunctionCalls=0;
    for (int j=0;j<numberOfDimensions;j++) {
        float sum=0.0;
        for (int i=0; i<numberOfVertices; i++) sum += v[i][j];
        psum[j]=sum;
    }
    
    for (;;) {
        int ilo = 0;
        int ihi = functionValues[0] > functionValues[1] ? ((void)(inhi=1),0) : ((void)(inhi=0),1);
        for (int i=0; i<numberOfVertices; i++) {
            if (functionValues[i] < functionValues[ilo]) ilo=i;
            if (functionValues[i] > functionValues[ihi]) {
                inhi=ihi;
                ihi=i;
            } else if (functionValues[i] > functionValues[inhi] && i != ihi) inhi = i;
        }
        float denom = (float) fabs((double) functionValues[ihi])+fabs((double) functionValues[ilo]);
        if(denom == 0.) break;
        float rtol = 2.0*fabs((double) functionValues[ihi]-(double) functionValues[ilo])/denom;
        if (rtol < tolerance) {
            SWAP(functionValues[0],functionValues[ilo])
            for(int i=0;i<numberOfDimensions;i++) SWAP(v[0][i],v[ilo][i])
                break;
        }
        if (numberOfFunctionCalls >= NMAX) break;
        numberOfFunctionCalls += 2;
        
        float ytry = simplexTry(vertices,functionValues,psum,numberOfDimensions,function,ptr,ihi,-1.0);
        if (ytry <= functionValues[ilo])
            ytry = simplexTry(vertices,functionValues,psum,numberOfDimensions,function,ptr,ihi,2.0);
        else if (ytry >= functionValues[inhi]) {
            ysave = functionValues[ihi];
            ytry = simplexTry(vertices,functionValues,psum,numberOfDimensions,function,ptr,ihi,0.5);
            if (ytry >= ysave) {
                for (int i = 0; i<numberOfVertices; i++) {
                    if (i != ilo) {
                        for (int j=0; j<numberOfDimensions; j++)
                            v[i][j] = psum[j] = (float) 0.5 * (v[i][j]+v[ilo][j]);
                        functionValues[i]=(*function)(psum,ptr);
                    }
                }
                numberOfFunctionCalls += numberOfDimensions;
                for (int j=0; j<numberOfDimensions; j++) {
                    float sum=0.0;
                    for (int i=0; i<numberOfVertices; i++) sum += v[i][j];
                    psum[j]=sum;
                }
            }
        } else --(numberOfFunctionCalls);
    }
    
    return numberOfFunctionCalls;
}

