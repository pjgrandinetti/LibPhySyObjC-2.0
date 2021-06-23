//
//  PSDatasetMultiplyByScalars.c
//
//  Created by Philip J. Grandinetti on 3/6/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetMultiplyByScalarsCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    PSScalarRef responseMultiplier = NULL;
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtFocus(theDataset);
    switch (PSQuantityGetElementType(theDependentVariable)) {
        case kPSNumberFloat32Type:
            responseMultiplier = PSScalarCreateWithFloat(1, PSUnitDimensionlessAndUnderived());
            break;
        case kPSNumberFloat64Type:
            responseMultiplier = PSScalarCreateWithDouble(1, PSUnitDimensionlessAndUnderived());
            break;
        case kPSNumberFloat32ComplexType:
            responseMultiplier = PSScalarCreateWithFloatComplex(1, PSUnitDimensionlessAndUnderived());
            break;
        case kPSNumberFloat64ComplexType:
            responseMultiplier = PSScalarCreateWithDoubleComplex(1, PSUnitDimensionlessAndUnderived());
            break;
    }
    
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFMutableArrayRef dimensionMultipliers = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    PSScalarRef dimensionMultiplier = PSScalarCreateWithDouble(1, PSUnitDimensionlessAndUnderived());
    for(CFIndex dimIndex = 0; dimIndex<dimensionsCount; dimIndex++) CFArrayAppendValue(dimensionMultipliers, dimensionMultiplier);
    CFRelease(dimensionMultiplier);
    
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryAddValue(parameters, kPSDatasetMultiplyByScalarsDimensionMultipliers, dimensionMultipliers);
    CFDictionaryAddValue(parameters, kPSDatasetMultiplyByScalarsResponseMultiplier, responseMultiplier);
    
    CFRelease(responseMultiplier);
    CFRelease(dimensionMultipliers);
    return parameters;
}

bool PSDatasetMultiplyByScalarsValidateParametersForDataset(PSDatasetRef theDataset, CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetMultiplyByScalarsDimensionMultipliers)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetMultiplyByScalarsResponseMultiplier)) return false;
    
    PSScalarRef multiplier = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetMultiplyByScalarsResponseMultiplier);
    
    if(![multiplier isKindOfClass:[PSScalar class]]) return false;
    
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFArrayRef dimensionMultipliers = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetMultiplyByScalarsDimensionMultipliers);
    if(CFArrayGetCount(dimensionMultipliers)!=dimensionsCount) return false;
    for(CFIndex dimIndex = 0; dimIndex<dimensionsCount; dimIndex++) {
        PSScalarRef multiplier = (PSScalarRef) CFArrayGetValueAtIndex(dimensionMultipliers, dimIndex);
        if(![multiplier isKindOfClass:[PSScalar class]]) return false;
    }
    return true;
}

PSDatasetRef PSDatasetCreateByMultiplyingByScalars(PSDatasetRef theDataset, CFDictionaryRef parameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    
    CFArrayRef dimensionMultipliers = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetMultiplyByScalarsDimensionMultipliers);
    CFIndex dimensionsCount = PSDatasetDimensionsCount(output);
    for(CFIndex dimIndex=0;dimIndex<dimensionsCount;dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(output, dimIndex);
        PSScalarRef dimensionMultiplier = CFArrayGetValueAtIndex(dimensionMultipliers, dimIndex);
        PSDimensionMultiplyByScalar(dimension, dimensionMultiplier,error);
    }

    PSScalarRef responseMultiplier = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetMultiplyByScalarsResponseMultiplier);
    CFIndex dvCount = PSDatasetDependentVariablesCount(output);
    for(CFIndex dvIndex = 0;dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef theDV = PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        PSDependentVariableMultiplyByScalar(theDV, responseMultiplier, error);
        PSPlotRef thePlot = PSDependentVariableGetPlot(theDV);
        PSPlotReset(thePlot);
    }
    

    return output;
}
