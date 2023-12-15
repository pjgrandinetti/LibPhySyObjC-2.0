//
//  PSDatasetApodizePIETA.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizePIETAMinimumNumberOfDimensions()
{
    return 2;
}

CFMutableDictionaryRef PSDatasetApodizePIETACreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset,CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);

    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFNumberRef theIntercept = PSCFNumberCreateWithCFIndex(0);
//    PSScalarRef intercept = PSScalarCreateWithInt64(0);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizePIETAIntercept);
    CFArrayAppendValue(parametersValues, theIntercept);
    CFRelease(theIntercept);
    
    
    CFNumberRef theSlope = PSCFNumberCreateWithCFIndex(2);
//    PSScalarRef slope = PSScalarCreateWithInt64(2);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizePIETASlope);
    CFArrayAppendValue(parametersValues, theSlope);
    CFRelease(theSlope);

    CFStringRef oddEvenAll = CFSTR("all");
    CFArrayAppendValue(parametersNames, kPSDatasetApodizePIETAOddEvenAll);
    CFArrayAppendValue(parametersValues, oddEvenAll);

    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}

bool PSDatasetApodizePIETAValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(functionParameters,false);
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    
    if(CFArrayGetCount(parametersValues)!=3) return false;
    
    CFNumberRef intercept = (CFNumberRef) CFArrayGetValueAtIndex(parametersValues, 0);
    if(CFGetTypeID(intercept)!=CFNumberGetTypeID()) return false;
//    PSScalarRef intercept = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
//    if(PSQuantityGetElementType(intercept)!=kPSNumberSInt64Type) return false;
    
    CFNumberRef slope = (CFNumberRef) CFArrayGetValueAtIndex(parametersValues, 1);
    if(CFGetTypeID(slope)!=CFNumberGetTypeID()) return false;
//    PSScalarRef slope = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 1);
//    if(PSQuantityGetElementType(slope)!=kPSNumberSInt64Type) return false;
    
    CFStringRef oddEvenAll = CFArrayGetValueAtIndex(parametersValues, 2);
    CFMutableStringRef oddEvenAllmut = CFStringCreateMutableCopy (kCFAllocatorDefault,CFStringGetLength(oddEvenAll),oddEvenAll);
    
    CFStringLowercase(oddEvenAllmut, CFLocaleCopyCurrent());
    if(CFGetTypeID(oddEvenAllmut)!=CFStringGetTypeID()) return false;
    if((CFStringCompare(oddEvenAllmut, CFSTR("odd"), 0) == kCFCompareEqualTo)||
        (CFStringCompare(oddEvenAllmut, CFSTR("even"), 0) == kCFCompareEqualTo) ||
        (CFStringCompare(oddEvenAllmut, CFSTR("all"), 0) == kCFCompareEqualTo)) return true;
    else return false;
    
    return true;
}

CFStringRef PSDatasetApodizePIETAGetParameterNameAtIndex(CFIndex index)
{
    if(index==0) return kPSDatasetApodizePIETAIntercept;
    else if(index==1) return kPSDatasetApodizePIETASlope;
    else if(index==2) return kPSDatasetApodizePIETAOddEvenAll;
    return NULL;
}

static PSDependentVariableRef PSDatasetApodizePIETACreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    CFNumberRef intercept = (CFNumberRef) CFArrayGetValueAtIndex(parametersValues, 0);
    CFNumberRef slope = (CFNumberRef) CFArrayGetValueAtIndex(parametersValues, 1);
    CFStringRef oddEvenAll = (CFStringRef) CFArrayGetValueAtIndex(parametersValues, 2);
    CFMutableStringRef oddEvenAllmut = CFStringCreateMutableCopy (kCFAllocatorDefault,CFStringGetLength(oddEvenAll),oddEvenAll);
    CFStringLowercase(oddEvenAllmut, CFLocaleCopyCurrent());

    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);

    CFIndex interceptValue;
    CFNumberGetValue(intercept, kCFNumberCFIndexType, &interceptValue);
    
    CFIndex slopeValue;
    CFNumberGetValue(slope, kCFNumberCFIndexType, &slopeValue);

    bool even = true;
    bool odd = true;
    if((CFStringCompare(oddEvenAllmut, CFSTR("odd"), 0) == kCFCompareEqualTo)) even = false;
    if((CFStringCompare(oddEvenAllmut, CFSTR("even"), 0) == kCFCompareEqualTo)) odd = false;

    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(dimensions, horizontalDimension);
    CFArrayAppendValue(dimensions, verticalDimension);
    
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    CFIndex verticalDimensionNpts = PSDimensionGetNpts(verticalDimension);
    CFIndex size = horizontalDimensionNpts*verticalDimensionNpts;

    PSDependentVariableRef theBlock2D =  PSDependentVariableCreateWithSize(NULL,NULL,NULL,NULL,CFSTR("scalar"),
                                                                         kPSNumberFloat32Type,
                                                                         NULL,
                                                                         size,
                                                                         NULL,NULL);

    float *pieta = (float *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(theBlock2D,0));
    
    PSMutableIndexArrayRef coordinateIndexes = PSIndexArrayCreateMutable(2);
    
    CFIndex T = verticalDimensionNpts*(verticalDimensionNpts%2==0) + (verticalDimensionNpts-1)*(verticalDimensionNpts%2!=0);

    PSScalarRef one = PSScalarCreateWithFloat(1, NULL);
    for(CFIndex hCoordinateIndex = PSDimensionLowestIndex(horizontalDimension); hCoordinateIndex<=PSDimensionHighestIndex(horizontalDimension); hCoordinateIndex++) {
        if(hCoordinateIndex%2==0 && odd) {
            // Even horiztonal coordinate indexes
            CFIndex vCoordinateIndex = -slopeValue * hCoordinateIndex/2 - interceptValue + T/2;
            PSIndexArraySetValueAtIndex(coordinateIndexes, 0, hCoordinateIndex);
            PSIndexArraySetValueAtIndex(coordinateIndexes, 1, vCoordinateIndex);
            PSDependentVariableSetValueAtCoordinateIndexes(theBlock2D,0,
                                                           dimensions,
                                                           coordinateIndexes,
                                                           one,
                                                           error);
        }
        else if(hCoordinateIndex%2==1 && even) {
            CFIndex vCoordinateIndex = slopeValue * (hCoordinateIndex-1)/2 + interceptValue + T/2;
            PSIndexArraySetValueAtIndex(coordinateIndexes, 0, hCoordinateIndex);
            PSIndexArraySetValueAtIndex(coordinateIndexes, 1, vCoordinateIndex);
            PSDependentVariableSetValueAtCoordinateIndexes(theBlock2D,0,
                                                           dimensions,
                                                           coordinateIndexes,
                                                           one,
                                                           error);
        }
    }
    
    CFRelease(coordinateIndexes);
    CFRelease(dimensions);
    
    dimensions = (CFMutableArrayRef) PSDatasetGetDimensions(theDataset);
    size = PSDimensionCalculateSizeFromDimensions(dimensions);
    
    PSDependentVariableRef theBlock =  PSDependentVariableCreateWithSize(NULL,NULL,NULL,NULL,CFSTR("scalar"),
                                                                         kPSNumberFloat32Type,
                                                                         NULL,
                                                                         size,
                                                                         NULL,NULL);
    CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theBlock,0);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    
    __block float *multipliers = (float *) CFDataGetMutableBytePtr(values);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(size, queue, 
                   ^(size_t memOffset) {
                       PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions,  memOffset);
                       CFIndex hCoordinateIndex = PSIndexArrayGetValueAtIndex(coordinateIndexes, horizontalDimensionIndex);
                       CFIndex vCoordinateIndex = PSIndexArrayGetValueAtIndex(coordinateIndexes, verticalDimensionIndex);
                       multipliers[memOffset] = pieta[hCoordinateIndex + horizontalDimensionNpts*vCoordinateIndex];
                       CFRelease(coordinateIndexes);
                   }
                   );
    CFRelease(theBlock2D);
    return theBlock;
}

PSDatasetRef PSDatasetApodizePIETACreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizePIETACreateBlock(theDataset, functionParameters,error);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dvIndex=0; dvIndex<PSDatasetDependentVariablesCount(output); dvIndex++) {
        PSDependentVariableRef dV = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        PSDependentVariableMultiply(dV, theBlock, error);
    }
    
    CFRelease(theBlock);
    return output;
    
}

