//
//  PSDatasetApodizeExponential.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/9/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFIndex PSDatasetApodizeExponentialMinimumNumberOfDimensions(void)
{
    return 1;
}

CFMutableDictionaryRef PSDatasetApodizeExponentialCreateDefaultFunctionParametersForDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef functionParameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableArrayRef parametersNames = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef parametersValues = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    
    PSUnitRef unit = PSQuantityGetUnit(PSDimensionGetInverseIncrement(horizontalDimension));
    
    PSScalarRef fwhm = PSScalarCreateWithDouble(0.0, unit);
    CFArrayAppendValue(parametersNames, kPSDatasetApodizeExponentialFullWidthHalfMaximum);
    CFArrayAppendValue(parametersValues, fwhm);
    CFRelease(fwhm);

    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionNames, parametersNames);
    CFDictionaryAddValue(functionParameters, kPSDatasetApodizationFunctionValues, parametersValues);
    CFRelease(parametersNames);
    CFRelease(parametersValues);
    return functionParameters;
}

bool PSDatasetApodizeExponentialValidateFunctionParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(functionParameters,false);
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    if(CFArrayGetCount(parametersValues) == 0) return false;

    PSScalarRef fullWidthHalfMaximum = (PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef unit = PSQuantityGetUnit(PSDimensionGetInverseIncrement(horizontalDimension));

    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) fullWidthHalfMaximum),
                                                     PSUnitGetDimensionality(unit))) return false;
    return true;
}

CFStringRef PSDatasetApodizeExponentialGetParameterNameAtIndex(CFIndex index)
{
    if(index==0) return kPSDatasetApodizeExponentialFullWidthHalfMaximum;
    return NULL;
}

static PSDependentVariableRef PSDatasetApodizeExponentialCreateBlock(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    CFMutableArrayRef parametersValues = (CFMutableArrayRef) CFDictionaryGetValue(functionParameters, kPSDatasetApodizationFunctionValues);
    
    PSMutableScalarRef decayConstant = PSScalarCreateMutableCopy((PSScalarRef) CFArrayGetValueAtIndex(parametersValues, 0));
    PSScalarRaiseToAPower(decayConstant, -1, error);
    PSScalarMultiplyByDimensionlessRealConstant(decayConstant, 1./M_PI);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSUnitRef relativeUnit = PSDimensionGetRelativeUnit(horizontalDimension);
    PSDimensionalityRef relativeDimensionality = PSUnitGetDimensionality(relativeUnit);
    
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) decayConstant),relativeDimensionality)) return NULL;
    
    float complex decayConst = PSScalarFloatComplexValueInUnit(decayConstant, relativeUnit, NULL);
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    
    __block float *function1D = malloc(sizeof(float)*horizontalDimensionNpts);
    vDSP_vclr(function1D, 1, horizontalDimensionNpts);
    float *coordinates = PSDimensionCreateFloatVectorOfDisplayedCoordinates(horizontalDimension);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(horizontalDimensionNpts, queue, 
                   ^(size_t coordinateIndex) {
                       float horizontalCoordinate = fabsf(coordinates[coordinateIndex]);
                       float ratio = horizontalCoordinate/decayConst;
                       if(ratio !=0.0) function1D[coordinateIndex] = expf(-ratio);
                       else function1D[coordinateIndex] = 1.0;
                   });
    free(coordinates);

    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    PSDependentVariableRef theBlock =  PSDependentVariableCreateWithSize(NULL,NULL,NULL,NULL,CFSTR("scalar"),
                                                                         kPSNumberFloat32Type,
                                                                         NULL,
                                                                         size,
                                                                         NULL,NULL);
    CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theBlock,0);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);

    __block float *multipliers = (float *) CFDataGetMutableBytePtr(values);
     queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(size, queue, 
                   ^(size_t memOffset) {
                       PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions,  memOffset);
                       CFIndex index = PSIndexArrayGetValueAtIndex(coordinateIndexes, horizontalDimensionIndex);
                       multipliers[memOffset] = function1D[index];
                       CFRelease(coordinateIndexes);
                   }
                   );
    free(function1D);
    return theBlock;
}

PSDatasetRef PSDatasetApodizeExponentialCreateByApodizing(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(!CFDictionaryContainsKey(functionParameters, kPSDatasetApodizationFunctionValues)) return false;
    PSDependentVariableRef theBlock = PSDatasetApodizeExponentialCreateBlock(theDataset, functionParameters,error);
    
    PSDatasetRef output = NULL;
    if(theBlock) {
        output = PSDatasetCreateCopy(theDataset);
        CFIndex dvCount = PSDatasetDependentVariablesCount(output);
        for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
            PSDependentVariableRef signal = (PSDependentVariableRef) PSDatasetGetDependentVariableAtIndex(output, dvIndex);
            PSDependentVariableMultiply(signal, theBlock, error);
        }
        
        CFRelease(theBlock);
    }
    return output;
    
}

