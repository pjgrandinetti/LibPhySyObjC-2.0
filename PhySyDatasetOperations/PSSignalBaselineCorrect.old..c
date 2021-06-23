//
//  PSSignalBaselineCorrect.c
//  PSSignal
//
//  Created by Grandinetti Philip on 10/23/11.
//  Copyright (c) 2011 Philip J. Grandinetti. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

// PSSignalBaselineCorrect Opaque Type
struct __PSSignalBaselineCorrect { 
    CFIndex  numberOfDimensions;
    CFDataRef lowerLimits;
    CFDataRef upperLimits;
    PSSignalBaselineCorrectType correctionType;
    PSScalarRef baselineMean;
};

PSSignalBaselineCorrectRef PSSignalBaselineCorrectCreateWithFunctionTypeAndLimits(PSSignalBaselineCorrectType correctionType,CFDataRef lowerLimits,CFDataRef upperLimits,PSSignalRef theSignal)
{
    struct __PSSignalBaselineCorrect *operation = CFAllocatorAllocate(kCFAllocatorDefault, sizeof(struct __PSSignalBaselineCorrect), 0);
    operation->numberOfDimensions = PSSignalNumberOfDimensions(theSignal);
    operation->correctionType = correctionType;
    operation->lowerLimits = CFRetain(lowerLimits);
    operation->upperLimits = CFRetain(upperLimits);

    return operation;
}

void PSSignalBaselineCorrectFinalize(PSSignalBaselineCorrectRef operation)
{
    if(operation->lowerLimits) CFRelease(operation->lowerLimits);
    if(operation->upperLimits) CFRelease(operation->upperLimits);
    if(operation->baselineMean) CFRelease(operation->baselineMean);
    CFAllocatorDeallocate(kCFAllocatorDefault, (void *) operation);
}

static void PSSignalBaselineCorrectSetBaselineMean(PSSignalBaselineCorrectRef operation, PSScalarRef newValue)
{
    if(operation->baselineMean == newValue) return;
    if(operation->baselineMean) CFRelease(operation->baselineMean);
    operation->baselineMean = newValue;
}

static void doNestedLoopsWithSignal(PSSignalBaselineCorrectRef operation,
                                    CFMutableDataRef coordinateIndexes,
                                    PSSignalRef theSignal, CFIndex dimIndex)
{
    CFIndex *lowerIndexes = (CFIndex *) CFDataGetBytePtr(operation->lowerLimits);
    CFIndex *upperIndexes = (CFIndex *) CFDataGetBytePtr(operation->upperLimits);
    CFIndex *indexes = (CFIndex *) CFDataGetMutableBytePtr(coordinateIndexes);

    double complex baselineMean = PSScalarDoubleComplexValue(operation->baselineMean);
    double complex *responses = (double complex *) CFDataGetMutableBytePtr(PSSignalGetValues(theSignal));
    for(CFIndex index = lowerIndexes[dimIndex]; index<=upperIndexes[dimIndex]; index++) {
        indexes[dimIndex] = index;
        if(dimIndex>0) doNestedLoopsWithSignal(operation,coordinateIndexes,theSignal,dimIndex-1);
        else {
            CFIndex memOffset = PSSignalMemOffsetFromCoordinateIndexes(theSignal,coordinateIndexes);
            baselineMean += responses[memOffset];
        }
    }
    
    PSScalarRef temp = PSScalarCreateWithDoubleComplex(baselineMean, PSQuantityGetUnit(operation->baselineMean));
    PSSignalBaselineCorrectSetBaselineMean(operation,temp);
}

static void PSSignalBaselineCorrectCalculateBaselineMeanWithSignal(PSSignalBaselineCorrectRef operation, 
                                                                   PSSignalRef theSignal)
{
    PSScalarRef temp = PSScalarCreateWithDoubleComplex(0.0, PSSignalGetResponseUnit(theSignal));
    PSSignalBaselineCorrectSetBaselineMean(operation,temp);
    CFMutableDataRef coordinateIndexes = CFDataCreateMutable(kCFAllocatorDefault, sizeof(CFIndex)*PSSignalNumberOfDimensions(theSignal));
    doNestedLoopsWithSignal(operation, coordinateIndexes, theSignal, PSSignalNumberOfDimensions(theSignal)-1);
    CFRelease(coordinateIndexes);
    
    CFIndex *lowerIndexes = (CFIndex *) CFDataGetBytePtr(operation->lowerLimits);
    CFIndex *upperIndexes = (CFIndex *) CFDataGetBytePtr(operation->upperLimits);
    
    double complex baselineMean = PSScalarDoubleComplexValue(operation->baselineMean);
    for(CFIndex idim = 0; idim<PSSignalNumberOfDimensions(theSignal); idim++)
        baselineMean /= upperIndexes[idim] - lowerIndexes[idim] + 1;
    
    temp = PSScalarCreateWithDoubleComplex(baselineMean, PSSignalGetResponseUnit(theSignal));
    PSSignalBaselineCorrectSetBaselineMean(operation,temp);
}

static CFIndex lower;
static CFIndex upper;

static PSSignalRef PSSignalBaselineCorrectOperateOnCrossSection(PSSignalBaselineCorrectRef operation,PSSignalRef crossSection)
{
    double complex baseline = 0;
    for(CFIndex index=lower;index<=upper;index++) {
        CFDataRef coordinateIndexes = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) &index, sizeof(CFIndex));
        PSScalarRef temp = PSSignalCreateComplexResponseFromCoordinateIndexes(crossSection, coordinateIndexes);
        baseline += PSScalarDoubleComplexValue(temp);
        CFRelease(coordinateIndexes);
    }
    baseline /= fabs(upper-lower + 1);
    
    double complex *responses = (double complex *) CFDataGetMutableBytePtr(PSSignalGetValues(crossSection));
    for(CFIndex index=0;index<PSSignalGetSize(crossSection);index++) responses[index] -= baseline;
    return crossSection;
}

static void doThreadedNestedLoops(PSSignalBaselineCorrectRef operation,
                                  PSMutableIndexSetRef dimensionIndexSet,
                                  CFMutableDataRef coordinateIndexes,
                                  PSSignalRef input,
                                  PSSignalRef output,
                                  CFIndex counter)
{
    CFIndex *dimIndexes = (CFIndex *) CFDataGetBytePtr(PSIndexSetGetIndexes(dimensionIndexSet));
    CFIndex dimIndex = dimIndexes[counter];
    
    PSDimensionRef dim = PSSignalDimensionAtIndex(input, dimIndex);
    if(counter==0) {
        PSSignalRef crossSection = PSSignalCreateCrossSectionAlongDimensionIndexContainingCoordinateIndexes(input, dimIndex,coordinateIndexes);
        
        PSSignalRef crossSectionPostOp = (PSSignalRef) CFRetain(PSSignalBaselineCorrectOperateOnCrossSection(operation,crossSection));
        CFRelease(crossSection);
        
        PSSignalSetCrossSectionAlongDimensionIndexContainingCoordinateIndexes(output, dimIndex, coordinateIndexes, crossSectionPostOp);
        CFRelease(crossSectionPostOp);
    }
    else {
        if(counter==PSSignalNumberOfDimensions(input)-1) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_apply(PSDimensionGetNpts(dim), queue, 
                           ^(size_t index) {
                               CFMutableDataRef threadIndexValues = CFDataCreateMutableCopy(kCFAllocatorDefault, CFDataGetLength(coordinateIndexes), coordinateIndexes);
                               CFIndex *indexes = (CFIndex *) CFDataGetMutableBytePtr(threadIndexValues);
                               indexes[dimIndex] = (CFIndex) index;
                               doThreadedNestedLoops(operation, dimensionIndexSet, threadIndexValues, input, output, counter-1);
                               CFRelease(threadIndexValues);
                           }
                           );
            
        }
        else {
            for(CFIndex index = 0; index<PSDimensionGetNpts(dim); index++) {
                CFIndex *indexes = (CFIndex *) CFDataGetMutableBytePtr(coordinateIndexes);
                indexes[dimIndex] = index;
                doThreadedNestedLoops(operation, dimensionIndexSet, coordinateIndexes, input, output, counter-1);
            }
        }
    }
}

PSSignalRef PSSignalBaselineCorrectCreateSignalFromSignal(PSSignalBaselineCorrectRef operation, PSSignalRef input, CFErrorRef *error)
{
    PSSignalRef output = PSSignalCreateCopy(input);
    switch (operation->correctionType) {
        case kMRBaselineCorrect0D: 
        {
            double complex baselineMean = PSScalarDoubleComplexValue(operation->baselineMean);
            double complex *responses = (double complex *) CFDataGetMutableBytePtr(PSSignalGetValues(output));
            for(CFIndex index=0;index<PSSignalGetSize(output);index++) responses[index] -= baselineMean;
            break;
        }
        case kMRBaselineCorrect1D:
        {
            CFMutableDataRef coordinateIndexes = CFDataCreateMutable(kCFAllocatorDefault, sizeof(CFIndex)*PSSignalNumberOfDimensions(output));
            uint8_t horizontalDimensionIndex = PSPlotGetHorizontalDimensionIndex(PSSignalGetPlot(output));
            
            PSMutableIndexSetRef dimensionIndexSet = PSIndexSetCreateMutable();
            PSIndexSetAddIndex(dimensionIndexSet, horizontalDimensionIndex);
            
            for(CFIndex idim = 0; idim<PSSignalNumberOfDimensions(output); idim++) 
                if(idim!=horizontalDimensionIndex) PSIndexSetAddIndex(dimensionIndexSet, idim);
            
            CFIndex *lowerIndexes = (CFIndex *) CFDataGetBytePtr(operation->lowerLimits);
            CFIndex *upperIndexes = (CFIndex *) CFDataGetBytePtr(operation->upperLimits);
            
            lower = lowerIndexes[horizontalDimensionIndex];
            upper = upperIndexes[horizontalDimensionIndex];
            doThreadedNestedLoops(operation, dimensionIndexSet, coordinateIndexes, input, output, PSSignalNumberOfDimensions(output)-1);
            CFRelease(coordinateIndexes);
            break;
        }
    }
    
    PSAxisReset(PSPlotGetResponseAxis(PSSignalGetPlot(output)));
    return output;
}
