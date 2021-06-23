//
//  PSDatasetFourierTransform.c
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 11/7/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>
#include <fftw3.h>

@implementation PSDatasetFourierTransform

 void  cswap(float complex *v1, float complex *v2)
{
    float complex tmp = *v1;
    *v1 = *v2;
    *v2 = tmp;
}

 void  zswap(double complex *v1, double complex *v2)
{
    double complex tmp = *v1;
    *v1 = *v2;
    *v2 = tmp;
}

void cfftshift(float complex *data, CFIndex count)
{
    int k = 0;
    int c = (int) floor((float)count/2);
    // For odd and for even numbers of element use different algorithm
    if (count % 2 == 0)
    {
        for (k = 0; k < c; k++)
            cswap(&data[k], &data[k+c]);
    }
    else
    {
        float complex tmp = data[0];
        for (k = 0; k < c; k++)
        {
            data[k] = data[c + k + 1];
            data[c + k + 1] = data[k + 1];
        }
        data[c] = tmp;
    }
}

void icfftshift(float complex *data, CFIndex count)
{
    int k = 0;
    int c = (int) floor((float)count/2);
    if (count % 2 == 0)
    {
        for (k = 0; k < c; k++)
            cswap(&data[k], &data[k+c]);
    }
    else
    {
        float complex tmp = data[count - 1];
        for (k = c-1; k >= 0; k--)
        {
            data[c + k + 1] = data[k];
            data[k] = data[c + k];
        }
        data[c] = tmp;
    }
}

void zfftshift(double complex *data, CFIndex count)
{
    int k = 0;
    int c = (int) floor((float)count/2);
    // For odd and for even numbers of element use different algorithm
    if (count % 2 == 0)
    {
        for (k = 0; k < c; k++)
            zswap(&data[k], &data[k+c]);
    }
    else
    {
        double complex tmp = data[0];
        for (k = 0; k < c; k++)
        {
            data[k] = data[c + k + 1];
            data[c + k + 1] = data[k + 1];
        }
        data[c] = tmp;
    }
}

void izfftshift(double complex *data, CFIndex count)
{
    int k = 0;
    int c = (int) floor((float)count/2);
    if (count % 2 == 0)
    {
        for (k = 0; k < c; k++)
            zswap(&data[k], &data[k+c]);
    }
    else
    {
        double complex tmp = data[count - 1];
        for (k = c-1; k >= 0; k--)
        {
            data[c + k + 1] = data[k];
            data[k] = data[c + k];
        }
        data[c] = tmp;
    }
}

CFMutableDictionaryRef PSDatasetFourierTransformCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryAddValue(parameters, kPSDatasetFTPhaseCorrectBeforeFT, kCFBooleanFalse);
    CFDictionaryAddValue(parameters, kPSDatasetFTPhaseCorrectAfterFT, kCFBooleanTrue);
    CFDictionaryAddValue(parameters, kPSDatasetFTPhaseCorrectBeforeInverseFT, kCFBooleanTrue);
    CFDictionaryAddValue(parameters, kPSDatasetFTPhaseCorrectAfterInverseFT, kCFBooleanFalse);
    CFDictionaryAddValue(parameters, kPSDatasetFTPlotBackwardsAfterFT, kCFBooleanTrue);
    CFDictionaryAddValue(parameters, kPSDatasetFTPlotBackwardsAfterInverseFT, kCFBooleanFalse);
    return parameters;
}
bool PSDatasetFourierTransformValidateParameters(CFDictionaryRef parameters)
{
    if(parameters==NULL) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFTPhaseCorrectBeforeFT)) return false;
    if(CFGetTypeID(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectBeforeFT))!= CFBooleanGetTypeID()) return false;
    
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFTPhaseCorrectAfterFT)) return false;
    if(CFGetTypeID(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectAfterFT))!= CFBooleanGetTypeID()) return false;

    if(!CFDictionaryContainsKey(parameters, kPSDatasetFTPhaseCorrectBeforeInverseFT)) return false;
    if(CFGetTypeID(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectBeforeInverseFT))!= CFBooleanGetTypeID()) return false;

    if(!CFDictionaryContainsKey(parameters, kPSDatasetFTPhaseCorrectAfterInverseFT)) return false;
    if(CFGetTypeID(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectAfterInverseFT))!= CFBooleanGetTypeID()) return false;

    if(!CFDictionaryContainsKey(parameters, kPSDatasetFTPlotBackwardsAfterFT)) return false;
    if(CFGetTypeID(CFDictionaryGetValue(parameters, kPSDatasetFTPlotBackwardsAfterFT))!= CFBooleanGetTypeID()) return false;

    if(!CFDictionaryContainsKey(parameters, kPSDatasetFTPlotBackwardsAfterInverseFT)) return false;
    if(CFGetTypeID(CFDictionaryGetValue(parameters, kPSDatasetFTPlotBackwardsAfterInverseFT))!= CFBooleanGetTypeID()) return false;

    return true;
}

- (void) dealloc
{
    if(self->fftSetup) vDSP_DFT_DestroySetup(self->fftSetup);
    if(self->fftDSetup) vDSP_DFT_DestroySetupD(self->fftDSetup);
    [super dealloc];

}
static bool isPowerOfTwo(CFIndex number)
{
    if(number==1 || number==2) return true;
    do{
        CFIndex frac = number%2;
        number /= 2;
        if(frac != 0) return false;
    } while(number != 2);
    return true;
}

// 2, 4, 8, 16, 24, 32, ...
bool canFFT(CFIndex count)
{
    bool allowOtherRadix = true;
    if(isPowerOfTwo(count)) return true;
    else if(!allowOtherRadix) return false;
    else if(count<16) return false;
    else if(isPowerOfTwo(count/3)) {
        if(count%3==0) {
            long n = log2(count/3);
            if(n>=3) return true;
        }
    }
    else if(isPowerOfTwo(count/5)) {
        if(count%5==0) {
            long n = log2(count/5);
            if(n>=3) return true;

        }
    }
    else if(isPowerOfTwo(count/15)) {
        if(count%15==0) {
            long n = log2(count/15);
            if(n>=3) return true;
        }
    }
    return false;
}

PSDatasetRef PSDatasetFourierTransformWestCreateSignalFromDataset(CFDictionaryRef parameters,
                                                                  PSDatasetRef input,
                                                                  CFErrorRef *error)
{
#ifdef PhySyDEBUG
    NSLog(@"Entering PSDatasetFourierTransformWestCreateSignalFromDataset");
#endif
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    // If inputDependentVariables are not complex, then convert them
    CFIndex dimensionsCount = PSDatasetDimensionsCount(input);
    if(dimensionsCount<1) return NULL;
    
    PSDatasetRef output = PSDatasetCreateComplexCopy(input);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(output);
    
    bool phaseShiftBeforeFT = CFBooleanGetValue(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectBeforeFT));
    bool phaseShiftAfterFT = CFBooleanGetValue(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectAfterFT));
    
    bool phaseShiftBeforeInverseFT = CFBooleanGetValue(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectBeforeInverseFT));
    bool phaseShiftAfterInverseFT = CFBooleanGetValue(CFDictionaryGetValue(parameters, kPSDatasetFTPhaseCorrectAfterInverseFT));
    
    bool reversePlotAfterFT = CFBooleanGetValue(CFDictionaryGetValue(parameters, kPSDatasetFTPlotBackwardsAfterFT));
    bool reversePlotAfterInverseFT = CFBooleanGetValue(CFDictionaryGetValue(parameters, kPSDatasetFTPlotBackwardsAfterInverseFT));
    

    // If signal has a non-zero inverse horizontal dimension reference offset, then apply phase correction first.
    PSScalarRef inverseReferenceOffset = PSDimensionGetInverseReferenceOffset(horizontalDimension);
    if(PSScalarDoubleValue(inverseReferenceOffset)) {
        if((PSDimensionGetFFT(horizontalDimension) && phaseShiftBeforeInverseFT) ||(!PSDimensionGetFFT(horizontalDimension) && phaseShiftBeforeFT)) {
            PSScalarRef temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(inverseReferenceOffset, -1);
            CFMutableDictionaryRef phasing = PSDatasetPhasingCreateWithShift(temp, output, error);
            CFRelease(temp);
            PSDatasetRef outputPhased = PSDatasetPhasingCreateDatasetFromDataset(phasing, output, 0, false,  error);
            CFRelease(output);
            CFRelease(phasing);
            output = outputPhased;
            horizontalDimension = PSDatasetHorizontalDimension(output);
        }
    }
    // Apply FT along horizontal dimension.
    bool periodic = PSDimensionGetPeriodic(horizontalDimension);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(PSDatasetGetDimensions(output));
    CFIndex reducedSize = size/PSDimensionGetNpts(horizontalDimension);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(output);
    CFIndex *npts = calloc(sizeof(CFIndex), dimensionsCount);
    bool *fft = calloc(sizeof(bool), dimensionsCount);
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef theDimension = PSDatasetGetDimensionAtIndex(output, idim);
        npts[idim] = PSDimensionGetNpts(theDimension);
        fft[idim] = PSDimensionGetFFT(theDimension);
    }
    vDSP_Length length = npts[horizontalDimensionIndex];
    vDSP_Stride stride = strideAlongDimensionIndex(npts, dimensionsCount, horizontalDimensionIndex);
    
    int dft_direction = FFTW_FORWARD;
    if(fft[horizontalDimensionIndex]) dft_direction = FFTW_BACKWARD;
    CFIndex dvCount = PSDatasetDependentVariablesCount(output);
    double inverseIncrementValue = PSScalarDoubleValueInCoherentUnit(PSDimensionGetInverseIncrement(horizontalDimension));
    double incrementValue = PSScalarDoubleValueInCoherentUnit(PSDimensionGetIncrement(horizontalDimension));
    fftwf_plan floatPlan = NULL;
    fftw_plan doublePlan = NULL;
    fftwf_complex *floatArray = NULL;
    fftw_complex *doubleArray = NULL;
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef theDV = PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        CFIndex componentsCount = PSDependentVariableComponentsCount(theDV);
        numberType elementType = PSQuantityGetElementType(theDV);
        if(elementType==kPSNumberFloat32ComplexType) {
            if(floatArray == NULL) floatArray = (fftwf_complex*) fftwf_malloc(sizeof(fftwf_complex) * length);
            if(floatPlan == NULL) floatPlan = fftwf_plan_dft_1d((int) length, floatArray, floatArray, dft_direction, FFTW_ESTIMATE);
            for(CFIndex cIndex=0; cIndex<componentsCount; cIndex++) {
                CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theDV, cIndex);
                float complex *responses = (float complex *) CFDataGetMutableBytePtr(values);
                for(size_t reducedMemOffset=0;reducedMemOffset<reducedSize; reducedMemOffset++) {
                    CFIndex indexes[dimensionsCount];
                    indexes[horizontalDimensionIndex] = 0;
                    setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes, dimensionsCount, npts, horizontalDimensionIndex);
                    CFIndex memOffset = memOffsetFromIndexes(indexes,  dimensionsCount, npts);
                    cblas_ccopy((int) length, &responses[memOffset], (int) stride, floatArray, 1);
                    if(dft_direction==FFTW_FORWARD ) {
                        if(!periodic) floatArray[0] /= 2;
                    }
                    else icfftshift(floatArray,length);
                    fftwf_execute(floatPlan);
                    cblas_csscal((int) length, incrementValue, floatArray,1);
                    if(dft_direction==FFTW_BACKWARD)  {
                        if(!periodic) floatArray[0] *= 2;
                    }
                    else cfftshift(floatArray,length);
                    cblas_ccopy((int) length, floatArray, 1, &responses[memOffset], (int) stride);
                }
            }
        }
        else {
            if(doubleArray == NULL) doubleArray = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * length);
            if(doublePlan == NULL) doublePlan = fftw_plan_dft_1d((int) length, doubleArray, doubleArray, dft_direction, FFTW_ESTIMATE);
            for(CFIndex cIndex=0; cIndex<componentsCount; cIndex++) {
                CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theDV, cIndex);
                double complex *responses = (double complex *) CFDataGetMutableBytePtr(values);
                for(size_t reducedMemOffset=0;reducedMemOffset<reducedSize; reducedMemOffset++) {
                    CFIndex indexes[dimensionsCount];
                    indexes[horizontalDimensionIndex] = 0;
                    setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes,  dimensionsCount, npts, horizontalDimensionIndex);
                    CFIndex memOffset = memOffsetFromIndexes(indexes,  dimensionsCount, npts);
                    cblas_zcopy((int) length, &responses[memOffset], (int) stride, doubleArray, 1);
                    if(dft_direction==FFTW_FORWARD ) {
                        if(!periodic) doubleArray[0] /= 2;
                    }
                    else izfftshift(doubleArray,length);
                    fftw_execute(doublePlan);
                    cblas_zdscal((int) length, incrementValue, doubleArray,1);
                    if(dft_direction==FFTW_BACKWARD)  {
                        if(!periodic) doubleArray[0] *= 2;
                    }
                    else zfftshift(doubleArray,length);
                    cblas_zcopy((int) length, doubleArray, 1,&responses[memOffset], (int) stride);
                }
            }
        }
    }
    if(floatPlan) fftwf_destroy_plan(floatPlan);
    if(floatArray) fftwf_free(floatArray);
    if(doublePlan) fftw_destroy_plan(doublePlan);
    if(doubleArray) fftw_free(doubleArray);
    FREE(fft);
    FREE(npts);

    // Update horizontal dimension and axis
    horizontalDimension = PSDatasetHorizontalDimension(output);
    PSDimensionInverse(horizontalDimension,error);
    //    PSDimensionToggleFTOutputOrder(horizontalDimension);
    PSDimensionToggleFFT(horizontalDimension);
    
    PSDatasetResetFocus(output);
    
    // If signal has a nonzero horizontal dimension inverse reference offset then apply phase correction.
    
    inverseReferenceOffset = PSDimensionGetInverseReferenceOffset(horizontalDimension);
    if(PSScalarDoubleValue(inverseReferenceOffset)) {
        if((PSDimensionGetFFT(horizontalDimension) && phaseShiftAfterFT) ||(!PSDimensionGetFFT(horizontalDimension) && phaseShiftAfterInverseFT)) {
            PSScalarRef referenceOffset = PSDimensionGetReferenceOffset(horizontalDimension);
            PSScalarRef phase = PSScalarCreateByMultiplying(referenceOffset, inverseReferenceOffset,error);
            PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) phase, -2*kPSPi);
            CFMutableDictionaryRef phasing = PSDatasetPhasingCreateWithPhaseAndShift(phase,
                                                                                     inverseReferenceOffset,
                                                                                     output,
                                                                                     error);
            PSDatasetRef outputPhased = PSDatasetPhasingCreateDatasetFromDataset(phasing, output,  0, false, error);
            CFRelease(phasing);
            CFRelease(output);
            output = outputPhased;
            horizontalDimension = PSDatasetHorizontalDimension(output);
        }
    }
    
    PSDatasetResetFocus(output);
    
    PSScalarRef minimum = PSDimensionCreateMinimumDisplayedCoordinate(horizontalDimension);
    PSScalarRef maximum = PSDimensionCreateMaximumDisplayedCoordinate(horizontalDimension);
    CFStringRef displayedQuantityName = PSDimensionCopyDisplayedQuantityName(horizontalDimension);
    PSScalarBestConversionForQuantityName((PSMutableScalarRef) minimum, displayedQuantityName);
    PSScalarBestConversionForQuantityName((PSMutableScalarRef) maximum, displayedQuantityName);
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef theDV = PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        PSPlotRef thePlot = PSDependentVariableGetPlot(theDV);
        CFStringRef dVQuantityName = PSDependentVariableGetQuantityName(theDV);
        PSAxisResetWithMinAndMax(PSPlotAxisAtIndex(thePlot, horizontalDimensionIndex), displayedQuantityName, minimum, maximum);
        PSAxisResetWithMinAndMax(PSPlotPreviousAxisAtIndex(thePlot, horizontalDimensionIndex), displayedQuantityName, minimum, maximum);
        
        PSAxisReset(PSPlotAxisAtIndex(thePlot, -1), dVQuantityName);
        PSAxisReset(PSPlotPreviousAxisAtIndex(thePlot, -1), dVQuantityName);
        PSAxisToggleBipolar(PSPlotGetResponseAxis(thePlot));
        
        PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
        if(dft_direction == FFTW_FORWARD) PSAxisSetReverse(horizontalAxis, reversePlotAfterFT);
        if(dft_direction == FFTW_BACKWARD) PSAxisSetReverse(horizontalAxis, reversePlotAfterInverseFT);
    }
    CFRelease(minimum);
    CFRelease(maximum);
    CFRelease(displayedQuantityName);
#ifdef PhySyDEBUG
    NSLog(@"Leaving PSDatasetFourierTransformWestCreateSignalFromDataset");
#endif
    return output;
}

@end
