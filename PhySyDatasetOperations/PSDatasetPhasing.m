//
//  PSDatasetPhasing.c
//  PSDataset
//
//  Created by Philip J. Grandinetti on 10/23/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetPhasingCreateDefaultParameters(PSDatasetRef theDataset, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(error) if(*error) return NULL;

    PSScalarRef phase = PSScalarCreateWithDouble(0.0, PSUnitForSymbol(CFSTR("rad")));
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSScalarRef shift = NULL;
    if(horizontalDimension) {
        PSUnitRef horizontalInverseUnit = PSDimensionGetRelativeInverseUnit(horizontalDimension);
        shift = PSScalarCreateWithDouble(0.0, horizontalInverseUnit);
    }

    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    PSScalarRef shear = NULL;
    if(verticalDimension) {
        PSUnitRef horizontalDimensionUnit = PSDimensionGetRelativeUnit(horizontalDimension);
        PSUnitRef verticalDimensionUnit = PSDimensionGetRelativeUnit(verticalDimension);
        PSUnitRef productUnit = PSUnitByMultiplying(verticalDimensionUnit, horizontalDimensionUnit, NULL, error);
        shear = PSScalarCreateWithDouble(0.0, productUnit);
    }

    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryAddValue(parameters, kPSDatasetPhasingPhase, phase);
    CFRelease(phase);

    if(shift) {
        CFDictionaryAddValue(parameters, kPSDatasetPhasingShift, shift);
        CFRelease(shift);
    }

    if(shear) {
        CFDictionaryAddValue(parameters, kPSDatasetPhasingShear, shear);
        CFRelease(shear);
    }
    return parameters;
}

bool PSDatasetPhasingValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    

    if(!CFDictionaryContainsKey(parameters, kPSDatasetPhasingPhase)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetPhasingShift)) return false;
    
    PSScalarRef phase = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetPhasingPhase);
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) phase))) return false;
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    
    if(horizontalDimension) {
        PSScalarRef shift = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetPhasingShift);
        if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) shift),
                                                         PSQuantityGetUnitDimensionality((PSQuantityRef) PSDimensionGetInverseOriginOffset(horizontalDimension)))) return false;
    }
    
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    if(verticalDimension) {
        if(!CFDictionaryContainsKey(parameters, kPSDatasetPhasingShear)) return false;
        PSScalarRef shear = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetPhasingShear);
        
        PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
        if(verticalDimension) {
            PSUnitRef horizontalDimensionUnit = PSDimensionGetRelativeUnit(horizontalDimension);
            PSUnitRef verticalDimensionUnit = PSDimensionGetRelativeUnit(verticalDimension);
            PSUnitRef productUnit = PSUnitByMultiplying(verticalDimensionUnit, horizontalDimensionUnit, NULL,error);
            
            if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) shear),
                                                             PSUnitGetDimensionality(productUnit))) return false;
        }

    }
    return true;
}

PSScalarRef PSDatasetPhasingGetPhase(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetPhasingPhase)) return NULL;
    return (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetPhasingPhase);
}

bool PSDatasetPhasingSetPhase(CFMutableDictionaryRef parameters, PSScalarRef phase, PSDatasetRef theDataset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
   	IF_NO_OBJECT_EXISTS_RETURN(phase,false);
   	IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) phase))) return false;
    if(CFDictionaryContainsKey(parameters, kPSDatasetPhasingPhase)) CFDictionaryReplaceValue(parameters, kPSDatasetPhasingPhase, phase);
    else CFDictionaryAddValue(parameters, kPSDatasetPhasingPhase, phase);
    return true;
}

PSScalarRef PSDatasetPhasingGetShift(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetPhasingShift)) return NULL;
    return (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetPhasingShift);
}

bool PSDatasetPhasingSetShift(CFMutableDictionaryRef parameters, PSScalarRef shift, PSDatasetRef theDataset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
   	IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
   	IF_NO_OBJECT_EXISTS_RETURN(shift,false);

    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    if(horizontalDimension) {
        if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) shift),
                                                         PSQuantityGetUnitDimensionality((PSQuantityRef) PSDimensionGetInverseOriginOffset(horizontalDimension)))) return false;
    }
    
    if(CFDictionaryContainsKey(parameters, kPSDatasetPhasingShift)) CFDictionaryReplaceValue(parameters, kPSDatasetPhasingShift, shift);
    else CFDictionaryAddValue(parameters, kPSDatasetPhasingShift, shift);
    return true;
}

PSScalarRef PSDatasetPhasingGetShear(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetPhasingShear)) return NULL;
    return (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetPhasingShear);
}

bool PSDatasetPhasingSetShear(CFMutableDictionaryRef parameters, PSScalarRef shear, PSDatasetRef theDataset)
{
   	IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
   	IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
   	IF_NO_OBJECT_EXISTS_RETURN(shear,false);

    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    if(NULL==horizontalDimension) return false;
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    if(NULL==verticalDimension) return false;

    if(verticalDimension) {
        PSUnitRef horizontalDimensionUnit = PSDimensionGetRelativeUnit(horizontalDimension);
        PSUnitRef verticalDimensionUnit = PSDimensionGetRelativeUnit(verticalDimension);
        PSUnitRef productUnit = PSUnitByMultiplying(verticalDimensionUnit, horizontalDimensionUnit, NULL, NULL);
        
        if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) shear),
                                                         PSUnitGetDimensionality(productUnit))) return false;
    }
   
    if(CFDictionaryContainsKey(parameters, kPSDatasetPhasingShear)) CFDictionaryReplaceValue(parameters, kPSDatasetPhasingShear, shear);
    else CFDictionaryAddValue(parameters, kPSDatasetPhasingShear, shear);
    return true;
}

bool PSDatasetPhasingSetPhaseWithShiftAndPivot(CFMutableDictionaryRef parameters,
                                               PSScalarRef shift,
                                               PSScalarRef pivotCoordinate,
                                               PSScalarRef pivotCoordinatePhase,
                                               PSDatasetRef theDataset,
                                               CFErrorRef *error)
{
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) pivotCoordinatePhase))) return false;
    
    PSMutableScalarRef product = (PSMutableScalarRef) PSScalarCreateByMultiplying(pivotCoordinate, shift, error);
    if(!PSScalarMultiplyByDimensionlessRealConstant(product, 2*M_PI)) {
        CFRelease(product);
        return false;
    }
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) product))) {
        CFRelease(product);
        return false;
    }
    PSMutableScalarRef phase = (PSMutableScalarRef) PSScalarCreateBySubtracting(pivotCoordinatePhase, product, error);
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) phase))) {
        CFRelease(phase);
        CFRelease(product);
        return false;
    }
    
    CFRelease(product);

    if(!PSScalarConvertToUnit(phase, PSUnitForSymbol(CFSTR("rad")), error)) {
        CFRelease(phase);
        return false;
    }
    const double twoPI = 2.*M_PI;
    double value = fmod(PSScalarDoubleValue(phase),twoPI);
    CFRelease(phase);
    while(value > M_PI) value -= twoPI;
    while(value < -M_PI) value += twoPI;
    phase = (PSMutableScalarRef) PSScalarCreateWithDouble(value, PSUnitForSymbol(CFSTR("rad")));
    
    return PSDatasetPhasingSetPhase(parameters, phase, theDataset);
}


CFMutableDictionaryRef PSDatasetPhasingCreateWithPhase(PSScalarRef phase, PSDatasetRef theDataset, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(phase,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(error) if(*error) return NULL;

    CFMutableDictionaryRef parameters = PSDatasetPhasingCreateDefaultParameters(theDataset, error);
    if(PSDatasetPhasingSetPhase(parameters,phase,theDataset)) return parameters;
    CFRelease(parameters);
    return NULL;
}

CFMutableDictionaryRef PSDatasetPhasingCreateWithShift(PSScalarRef shift, PSDatasetRef theDataset, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(shift,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(error) if(*error) return NULL;

    CFMutableDictionaryRef parameters = PSDatasetPhasingCreateDefaultParameters(theDataset, error);
    if(PSDatasetPhasingSetShift(parameters,shift,theDataset)) return parameters;
    CFRelease(parameters);
    return parameters;
}

CFMutableDictionaryRef PSDatasetPhasingCreateWithShear(PSScalarRef shear, PSDatasetRef theDataset, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(shear,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(error) if(*error) return NULL;
    
    CFMutableDictionaryRef parameters = PSDatasetPhasingCreateDefaultParameters(theDataset, error);
    if(PSDatasetPhasingSetShear(parameters,shear,theDataset)) return parameters;
    CFRelease(parameters);
    return NULL;
}

CFMutableDictionaryRef PSDatasetPhasingCreateWithPhaseAndShift(PSScalarRef phase,
                                                               PSScalarRef shift,
                                                               PSDatasetRef theDataset,
                                                               CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(phase,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(shift,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(error) if(*error) return NULL;

    CFMutableDictionaryRef parameters = PSDatasetPhasingCreateDefaultParameters(theDataset, error);
    if(PSDatasetPhasingSetPhase(parameters,phase,theDataset) &&
       PSDatasetPhasingSetShift(parameters,shift,theDataset))
        return parameters;
    CFRelease(parameters);
    return NULL;
}

CFMutableDictionaryRef PSDatasetPhasingCreateWithPhaseShiftAndShear(PSScalarRef phase,
                                                                    PSScalarRef shift,
                                                                    PSScalarRef shear,
                                                                    PSDatasetRef theDataset,
                                                                    CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(phase,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(shift,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(shear,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(error) if(*error) return NULL;

    CFMutableDictionaryRef parameters = PSDatasetPhasingCreateDefaultParameters(theDataset, error);
    if(PSDatasetPhasingSetPhase(parameters,phase,theDataset) &&
       PSDatasetPhasingSetShift(parameters,shift,theDataset) &&
       PSDatasetPhasingSetShear(parameters,shear,theDataset))
        return parameters;
    CFRelease(parameters);
    return NULL;
}

PSScalarRef PSDatasetPhasingCreatePhaseAtHorizontalCoordinate(CFDictionaryRef parameters,
                                                              PSScalarRef horizontalCoordinate,
                                                              CFErrorRef *error)
{
   	IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(error) if(*error) return NULL;

    PSScalarRef phase = PSDatasetPhasingGetPhase(parameters);
    PSScalarRef shift = PSDatasetPhasingGetShift(parameters);

    if(shift==NULL) return CFRetain(phase);
    
    PSMutableScalarRef product = (PSMutableScalarRef) PSScalarCreateByMultiplying(horizontalCoordinate, shift, error);

    if(!PSScalarMultiplyByDimensionlessRealConstant(product, 2*M_PI)) {
        CFRelease(product);
        return NULL;
    }
    if(!PSDimensionalityIsDimensionless(PSQuantityGetUnitDimensionality((PSQuantityRef) product))) {
        CFRelease(product);
        return NULL;
    }
    if(phase) {
        PSScalarRef newPhase = PSScalarCreateByAdding(product, phase, error);
        CFRelease(product);
        return newPhase;
    }
    return product;
}

float sinc(float x)
{
    if(x==0) return 1;
    return sin(x)/x;
}


PSDatasetRef PSDatasetPhasingCreateDatasetByAutoPhasingOrigin(PSDatasetRef theDataset,
                                                              PSScalarRef *phase,
                                                              CFIndex level,
                                                              CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);

    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    CFMutableArrayRef coordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dimIndex = 0; dimIndex<dimensionsCount; dimIndex++) {
        PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
        PSScalarRef minimum = PSDimensionCreateRelativeCoordinateFromIndex(dimension, PSDimensionLowestIndex(dimension));
        if(error) if(*error) return NULL;
        PSScalarRef maximum = PSDimensionCreateRelativeCoordinateFromIndex(dimension, PSDimensionHighestIndex(dimension));
        if(error) {
            if(*error) {
                CFRelease(minimum);
                return NULL;
            }
        }
        PSScalarRef coordinate = PSScalarCreateWithDouble(0.0, PSDimensionGetRelativeUnit(dimension));
        if(!PSDimensionIsRelativeCoordinateInRange(dimension,coordinate,minimum,maximum,error)) {
            if(error) {
                if(*error) CFRelease(*error);
                CFStringRef desc = CFSTR("Origin not in range.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            CFRelease(minimum);
            CFRelease(maximum);
            CFRelease(coordinate);
            return NULL;
        }
        CFArrayAppendValue(coordinates, coordinate);
        CFRelease(minimum);
        CFRelease(maximum);
        CFRelease(coordinate);
    }
    
    *phase = PSDatasetCreateResponseFromRelativeCoordinatesForPart(theDataset,
                                                                   dependentVariableIndex,
                                                                   componentIndex,
                                                                   coordinates,
                                                                   kPSArgumentPart,
                                                                   error);
    PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef)*phase, -1);
    CFRelease(coordinates);
    
    CFMutableDictionaryRef operation = PSDatasetPhasingCreateWithPhase(*phase,theDataset, error);
    
    PSDatasetRef dataset = PSDatasetPhasingCreateDatasetFromDataset(operation, theDataset, level, false, error);
    CFRelease(operation);
    
    PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(dataset, dependentVariableIndex);
    PSPlotRef newPlot = PSDependentVariableGetPlot(dependentVariable);
    PSAxisReset(PSPlotAxisAtIndex(newPlot, -1), PSDependentVariableGetQuantityName(dependentVariable));

    return dataset;
}

PSDatasetRef PSDatasetPhasingCreateDatasetByAutoPhasingFocus(PSDatasetRef theDataset, PSScalarRef *phase, CFIndex level, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    
    *phase = PSDatasetCreateResponseFromMemOffsetForPart(theDataset,
                                                         dependentVariableIndex,
                                                         componentIndex,
                                                         memOffset,
                                                         kPSArgumentPart);
    PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef)*phase, -1);

    CFMutableDictionaryRef operation = PSDatasetPhasingCreateWithPhase(*phase,theDataset, error);
    if(error) if(*error) return NULL;

    PSDatasetRef dataset = PSDatasetPhasingCreateDatasetFromDataset(operation, theDataset, level, false,  error);
    CFRelease(operation);
    if(error) if(*error) return NULL;

    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(dataset);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
        PSDependentVariableRef dependentVariable = PSDatasetGetDependentVariableAtIndex(dataset, dependentVariableIndex);
        PSPlotRef newPlot = PSDependentVariableGetPlot(dependentVariable);
        PSAxisReset(PSPlotAxisAtIndex(newPlot, -1), PSDependentVariableGetQuantityName(dependentVariable));
    }

    return dataset;
}

DSPSplitComplex *createDSPSplitComplexMultiplier(CFArrayRef dimensions,
                                                 CFIndex horizontalDimensionIndex,
                                                 CFIndex verticalDimensionIndex,
                                                 double phase, double shift, double shear, CFIndex size, CFErrorRef *error)
{
    PSDimensionRef horizontalDimension = CFArrayGetValueAtIndex(dimensions, horizontalDimensionIndex);
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    
    // First calculate the phase correction for each response
    DSPSplitComplex *multipliers = malloc(sizeof(struct DSPSplitComplex));
    multipliers->realp = (float *) calloc((size_t) size,sizeof(float));
    multipliers->imagp = (float *) calloc((size_t) size,sizeof(float));
    
    if(shift == 0.0 && shear == 0.0) {
        // Zeroth order only
        DSPSplitComplex *splitPhase = malloc(sizeof(struct DSPSplitComplex));
        float realFill = cos(phase);
        float imagFill = -sin(phase);
        splitPhase->realp = &realFill;
        splitPhase->imagp = &imagFill;
        vDSP_zvfill(splitPhase,multipliers,1,size);
        free(splitPhase);
        return multipliers;
    }
    else if(shear == 0.0) {
        // Zero and  First order only
        __block float *cosine = malloc(sizeof(float)*horizontalDimensionNpts);
        __block float *sine = malloc(sizeof(float)*horizontalDimensionNpts);
        float *coordinates = PSDimensionCreateFloatVectorOfRelativeCoordinates(horizontalDimension);

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(horizontalDimensionNpts, queue,
                       ^(size_t index) {
                           float radians = phase + shift * coordinates[index];
                           cosine[index] = cosf(radians);
                           sine[index] = -sinf(radians);
                       }
                       );
        free(coordinates);
        
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(size, queue,
                       ^(size_t memOffset) {
                           CFIndex index = PSDimensionGetCoordinateIndexFromMemOffset(dimensions,  memOffset, horizontalDimensionIndex);
                           multipliers->realp[memOffset] = cosine[index];
                           multipliers->imagp[memOffset] = sine[index];
                       }
                       );
        
        free(cosine);
        free(sine);
        
        
        return multipliers;
    }
    else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(size, queue,
                       ^(size_t memOffset) {
                           CFArrayRef coordinateValues = PSDimensionCreateRelativeCoordinatesFromMemOffset(dimensions,memOffset);
                           float horizontalCoordinate = PSScalarFloatValue(CFArrayGetValueAtIndex(coordinateValues, horizontalDimensionIndex));
                           float verticalCoordinate = PSScalarFloatValue(CFArrayGetValueAtIndex(coordinateValues, verticalDimensionIndex));
                           float radians = phase + (shift + shear*verticalCoordinate) * horizontalCoordinate;
                           multipliers->realp[memOffset] = cos(radians);
                           multipliers->imagp[memOffset] = -sin(radians);
                           CFRelease(coordinateValues);
                       }
                       );
        return multipliers;
    }
    return multipliers;
}

DSPDoubleSplitComplex *createDSPDoubleSplitComplexMultiplier(CFArrayRef dimensions,
                                                             CFIndex horizontalDimensionIndex,
                                                             CFIndex verticalDimensionIndex,
                                                             double phase, double shift, double shear, CFIndex size, CFErrorRef *error)
{
    PSDimensionRef horizontalDimension = CFArrayGetValueAtIndex(dimensions, horizontalDimensionIndex);
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);

    // First calculate the phase correction for each response
    DSPDoubleSplitComplex *multipliers = malloc(sizeof(struct DSPDoubleSplitComplex));
    multipliers->realp = (double *) calloc((size_t) size,sizeof(double));
    multipliers->imagp = (double *) calloc((size_t) size,sizeof(double));
    
    if(shift == 0.0 && shear == 0.0) {
        // Zeroth order only
        DSPDoubleSplitComplex *splitPhase = malloc(sizeof(struct DSPDoubleSplitComplex));
        double realFill = cos(phase);
        double imagFill = -sin(phase);
        splitPhase->realp = &realFill;
        splitPhase->imagp = &imagFill;
        vDSP_zvfillD(splitPhase,multipliers,1,size);
        free(splitPhase);
    }
    else if(shear == 0.0) {
        __block double *cosine = malloc(sizeof(double)*horizontalDimensionNpts);
        __block double *sine = malloc(sizeof(double)*horizontalDimensionNpts);
        double *coordinates = PSDimensionCreateDoubleVectorOfRelativeCoordinates(horizontalDimension);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(horizontalDimensionNpts, queue,
                       ^(size_t index) {
                           double radians = phase + shift * coordinates[index];
                           cosine[index] = cosf(radians);
                           sine[index] = -sinf(radians);
                       }
                       );
        free(coordinates);

        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(size, queue,
                       ^(size_t memOffset) {
                           PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions,  memOffset);
                           
                           CFIndex index = PSIndexArrayGetValueAtIndex(coordinateIndexes, horizontalDimensionIndex);
                           multipliers->realp[memOffset] = cosine[index];
                           multipliers->imagp[memOffset] = sine[index];
                           CFRelease(coordinateIndexes);
                       }
                       );
        free(cosine);
        free(sine);
        
    }
    else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_apply(size, queue,
                       ^(size_t memOffset) {
                           CFArrayRef coordinateValues = PSDimensionCreateRelativeCoordinatesFromMemOffset(dimensions,   memOffset);
                           double horizontalCoordinate = PSScalarDoubleValue(CFArrayGetValueAtIndex(coordinateValues, horizontalDimensionIndex));
                           double verticalCoordinate = PSScalarDoubleValue(CFArrayGetValueAtIndex(coordinateValues, verticalDimensionIndex));
                           float radians = phase + (shift + shear*verticalCoordinate) * horizontalCoordinate;
                           multipliers->realp[memOffset] = cos(radians);
                           multipliers->imagp[memOffset] = -sin(radians);
                           CFRelease(coordinateValues);
                       }
                       );
    }
    return multipliers;
}

bool PSDatasetPhaseDataset(PSDatasetRef theDataset,
                           PSScalarRef thePhase,
                           PSScalarRef theShift,
                           PSScalarRef theShear,
                           CFIndex level,
                           CFErrorRef *error)
{
    if(thePhase==NULL && theShift == NULL && theShear == NULL) return false;
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);

    double phase = 0;
    if(thePhase) {
        if(PSScalarDoubleValue(thePhase)!=0) {
            PSUnitRef rad = PSUnitForSymbol(CFSTR("rad"));
            phase = PSScalarDoubleValueInUnit(thePhase,rad, NULL);
        }
    }
    double shift = 0;
    if(theShift) {
        if(PSScalarDoubleValue(theShift)!=0) {
            double multiplier = 1;
            PSUnitRef unit = PSUnitByMultiplying(PSQuantityGetUnit(theShift), PSDimensionGetRelativeUnit(horizontalDimension), &multiplier, error);
            if(error) if(*error) return false;
            if(!PSUnitIsDimensionless(unit)) return false;
            PSUnitFindCoherentSIUnit(unit, &multiplier);
            shift = PSScalarDoubleValue(theShift) * multiplier * 2 * M_PI;
        }
    }
    double shear = 0;
    if(theShear) {
        if(PSScalarDoubleValue(theShear)!=0 && verticalDimension) {
            double multiplier = 1;
            PSUnitRef unit = PSUnitByMultiplying(PSQuantityGetUnit((PSQuantityRef) theShear), PSDimensionGetRelativeUnit(horizontalDimension), &multiplier, error);
            if(error) if(*error) return false;
            
            unit = PSUnitByMultiplying(unit, PSDimensionGetRelativeUnit(verticalDimension), &multiplier, error);
            if(error) if(*error) return false;
            
            if(!PSDimensionalityIsDimensionless(PSUnitGetDimensionality(unit))) return false;
            shear = PSScalarDoubleValue(theShear) * multiplier * 2 * M_PI;
        }
    }
    
    if(phase==0 && shift==0 && shear==0) return false;
    
    CFMutableArrayRef dimensions = PSDatasetDimensionsMutableCopy(theDataset);
    size_t size = PSDimensionCalculateSizeFromDimensions(dimensions);
    
    // First calculate the phase correction for each response
    DSPSplitComplex *floatMultipliers = NULL;
    DSPDoubleSplitComplex *doubleMultipliers = NULL;
    
    CFIndex dvCount = PSDatasetDependentVariablesCount(theDataset);
    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = dvCount;
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);

    PSIndexPairSetRef indexPairSet = NULL;
    if(level>2) {
        CFIndex memOffset = PSDatumGetMemOffset(focus);
        CFIndex verticalCoordinateIndex = PSDimensionGetCoordinateIndexFromMemOffset(dimensions, memOffset, verticalDimensionIndex);
        indexPairSet = PSIndexPairSetCreateWithIndexPair(verticalDimensionIndex, verticalCoordinateIndex);
        size = size/PSDimensionGetNpts(verticalDimension);
        CFArrayRemoveValueAtIndex(dimensions, verticalDimensionIndex);
    }
    
    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
        PSDependentVariableRef outputDV = PSDatasetGetDependentVariableAtIndex(theDataset, dvIndex);
        CFIndex componentsCount = PSDependentVariableComponentsCount(outputDV);
        CFIndex lowerCIndex = 0;
        CFIndex upperCIndex = componentsCount;
        if(level>1) {
            lowerCIndex = componentIndex;
            upperCIndex = lowerCIndex+1;
        }
        
        PSDependentVariableRef workingDV = outputDV;
        if(level>2) {
            workingDV = PSDependentVariableCreateCrossSection(outputDV, PSDatasetGetDimensions(theDataset), indexPairSet, error);
        }

        if(PSQuantityGetElementType(outputDV)==kPSNumberFloat32ComplexType) {
            // Now multiply phase correction onto component values
            for(CFIndex cIndex=lowerCIndex; cIndex<upperCIndex; cIndex++) {
                CFMutableDataRef component = PSDependentVariableGetComponentAtIndex(workingDV,cIndex);
                float complex *responses = (float complex *) CFDataGetMutableBytePtr(component);
                if(NULL==floatMultipliers) floatMultipliers = createDSPSplitComplexMultiplier(dimensions, horizontalDimensionIndex,verticalDimensionIndex, phase, shift, shear, size, error);

                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   responses[memOffset] *= floatMultipliers->realp[memOffset] + I * floatMultipliers->imagp[memOffset];
                               }
                               );
            }
        }
        else {
            for(CFIndex cIndex=lowerCIndex; cIndex<upperCIndex; cIndex++) {
                CFMutableDataRef component = PSDependentVariableGetComponentAtIndex(outputDV,cIndex);
                double complex *responses = (double complex *) CFDataGetMutableBytePtr(component);
                if(NULL==doubleMultipliers) doubleMultipliers = createDSPDoubleSplitComplexMultiplier(dimensions, horizontalDimensionIndex,verticalDimensionIndex, phase, shift, shear, size, error);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   responses[memOffset] *= doubleMultipliers->realp[memOffset] + I * doubleMultipliers->imagp[memOffset];
                               }
                               );
            }
        }
        
        if(level>2) {
            PSDependentVariableSetCrossSection(outputDV, PSDatasetGetDimensions(theDataset), indexPairSet, workingDV, dimensions);
            CFRelease(workingDV);
        }
    }
    
    CFRelease(dimensions);
    if(floatMultipliers) {
        free(floatMultipliers->realp);
        free(floatMultipliers->imagp);
        free(floatMultipliers);
    }
    if(doubleMultipliers) {
        free(doubleMultipliers->realp);
        free(doubleMultipliers->imagp);
        free(doubleMultipliers);
    }
    PSDatasetReset1DCrossSections(theDataset);
    return true;
}

PSDatasetRef PSDatasetPhasingCreateDatasetFromDataset(CFDictionaryRef parameters,
                                                      PSDatasetRef input,
                                                      CFIndex level,
                                                      bool adjustOffset,
                                                      CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    if(error) if(*error) return NULL;
    
    PSScalarRef thePhase = PSDatasetPhasingGetPhase(parameters);
    PSScalarRef theShift = PSDatasetPhasingGetShift(parameters);
    PSScalarRef theShear = PSDatasetPhasingGetShear(parameters);
    
    if(thePhase==NULL && theShift == NULL && theShear == NULL) return (PSDatasetRef) CFRetain(input);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(input);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(input);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(input);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(input);

    double phase = 0;
    if(thePhase) {
        if(PSScalarDoubleValue(thePhase)!=0) {
            PSUnitRef rad = PSUnitForSymbol(CFSTR("rad"));
            bool success = true;
            phase = PSScalarDoubleValueInUnit(thePhase,rad, &success);
        }
    }
    double shift = 0;
    if(theShift) {
        if(PSScalarDoubleValue(theShift)!=0) {
            double multiplier = 1;
            PSUnitRef unit = PSUnitByMultiplying(PSQuantityGetUnit((PSQuantityRef) theShift), PSDimensionGetRelativeUnit(horizontalDimension), &multiplier, error);
            if(error) if(*error) return NULL;
            
            if(!PSDimensionalityIsDimensionless(PSUnitGetDimensionality(unit))) return (PSDatasetRef) CFRetain(input);
            PSUnitFindCoherentSIUnit(unit, &multiplier);
            shift = PSScalarDoubleValue(theShift) * multiplier * 2 * M_PI;
        }
    }
    double shear = 0;
    if(theShear) {
        if(PSScalarDoubleValue(theShear)!=0 && verticalDimension) {
            double multiplier = 1;
            PSUnitRef unit = PSUnitByMultiplying(PSQuantityGetUnit((PSQuantityRef) theShear), PSDimensionGetRelativeUnit(horizontalDimension), &multiplier, error);
            if(error) if(*error) return NULL;

            unit = PSUnitByMultiplying(unit, PSDimensionGetRelativeUnit(verticalDimension), &multiplier, error);
            if(error) if(*error) return NULL;

            if(!PSDimensionalityIsDimensionless(PSUnitGetDimensionality(unit))) return (PSDatasetRef) CFRetain(input);
            shear = PSScalarDoubleValue(theShear) * multiplier * 2 * M_PI;
        }
    }
    
    if(phase==0 && shift==0 && shear==0) return (PSDatasetRef) CFRetain(input);
    
    PSDatasetRef output = PSDatasetCreateComplexCopy(input);
    CFArrayRef dimensions = PSDatasetGetDimensions(output);
    size_t size = PSDimensionCalculateSizeFromDimensions(dimensions);

    // First calculate the phase correction for each response
    DSPSplitComplex *floatMultipliers = NULL;
    DSPDoubleSplitComplex *doubleMultipliers = NULL;
    CFIndex dvCount = PSDatasetDependentVariablesCount(output);

    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = dvCount;
    PSDatumRef focus = PSDatasetGetFocus(output);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    
    CFIndex componentIndex = -1;
    if(level>1) componentIndex = PSDatumGetComponentIndex(focus);
    
    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
    
        PSDependentVariableRef outputDV = PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        CFIndex componentsCount = PSDependentVariableComponentsCount(outputDV);
        CFIndex lowerCIndex = 0;
        CFIndex upperCIndex = componentsCount;
        if(componentIndex>=0) {
            lowerCIndex = componentIndex;
            upperCIndex = lowerCIndex+1;
        }

        if(PSQuantityGetElementType(outputDV)==kPSNumberFloat32ComplexType) {
            
            // Now multiply phase correction onto component values

            for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
                CFMutableDataRef component = PSDependentVariableGetComponentAtIndex(outputDV,cIndex);
                float complex *responses = (float complex *) CFDataGetMutableBytePtr(component);
                if(NULL==floatMultipliers) floatMultipliers = createDSPSplitComplexMultiplier(dimensions,
                                                                                              horizontalDimensionIndex,
                                                                                              verticalDimensionIndex,
                                                                                              phase, shift, shear, size, error);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   responses[memOffset] *= floatMultipliers->realp[memOffset] + I * floatMultipliers->imagp[memOffset];
                               }
                               );
            }
        }
        else {
            for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
                CFMutableDataRef component = PSDependentVariableGetComponentAtIndex(outputDV,cIndex);
                double complex *responses = (double complex *) CFDataGetMutableBytePtr(component);
                if(NULL==doubleMultipliers) doubleMultipliers = createDSPDoubleSplitComplexMultiplier(dimensions,
                                                                                                      horizontalDimensionIndex,
                                                                                                      verticalDimensionIndex,
                                                                                                      phase, shift, shear, size, error);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   responses[memOffset] *= doubleMultipliers->realp[memOffset] + I * doubleMultipliers->imagp[memOffset];
                               }
                               );

            }
        }
    }
    
    if(floatMultipliers) {
        free(floatMultipliers->realp);
        free(floatMultipliers->imagp);
        free(floatMultipliers);
    }
    if(doubleMultipliers) {
        free(doubleMultipliers->realp);
        free(doubleMultipliers->imagp);
        free(doubleMultipliers);
    }

    // Shift inverse Reference Offset by shift amount
    //
    if(adjustOffset) {
        horizontalDimension = PSDatasetHorizontalDimension(output);
        PSScalarRef inverseReferenceOffset = PSDimensionGetInverseReferenceOffset(horizontalDimension);
        if(PSDimensionGetMadeDimensionless(horizontalDimension)) {
            PSScalarRef newInverseReferenceOffset = PSScalarCreateByAdding(inverseReferenceOffset, theShift, error);
            PSDimensionSetInverseReferenceOffset(horizontalDimension, newInverseReferenceOffset);
            CFRelease(newInverseReferenceOffset);
        }
        else {
            PSScalarRef newInverseReferenceOffset = PSScalarCreateByAdding(inverseReferenceOffset, theShift, error);
            PSDimensionSetInverseReferenceOffset(horizontalDimension, newInverseReferenceOffset);
            CFRelease(newInverseReferenceOffset);
        }
    }
    
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef outputDV = PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        CFStringRef quantityName = PSDependentVariableGetQuantityName(outputDV);
        PSPlotRef thePlot = PSDependentVariableGetPlot(outputDV);
        PSAxisReset(PSPlotGetResponseAxis(thePlot), quantityName);
    }
    return output;
}

PSDatasetRef PSDatasetPhasingAutoPhaseCreateDatasetFromDataset(PSDatasetRef input, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    
    PSDatumRef focus = PSDatasetGetFocus(input);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef inputDependentVariable = PSDatasetGetDependentVariableAtIndex(input, dependentVariableIndex);
    if(!PSQuantityIsComplexType(inputDependentVariable)) return (PSDatasetRef) CFRetain(input);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(input);
    CFIndex horizontalDimensionNpts = PSDimensionGetNpts(horizontalDimension);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    PSDependentVariableRef outputDependentVariable = PSDatasetGetDependentVariableAtIndex(output, dependentVariableIndex);
    size_t size = PSDependentVariableSize(outputDependentVariable);
    CFIndex componentsCount = PSDependentVariableComponentsCount(outputDependentVariable);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(output);
    CFArrayRef dimensions = PSDatasetGetDimensions(output);
    
    switch (PSQuantityGetElementType(outputDependentVariable)) {
        case kPSNumberFloat32Type:
        case kPSNumberFloat64Type:
            break;
        case kPSNumberFloat32ComplexType: {
            DSPSplitComplex *multipliers = malloc(sizeof(struct DSPSplitComplex));
            multipliers->realp = (float *) calloc((size_t) size,sizeof(float));
            multipliers->imagp = (float *) calloc((size_t) size,sizeof(float));
            
            CFIndex memOffset = PSDatumGetMemOffset(PSDatasetGetFocus(output));
            PSMutableIndexArrayRef theIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
            for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                __block float *cosine = malloc(sizeof(float)*horizontalDimensionNpts);
                __block float *sine = malloc(sizeof(float)*horizontalDimensionNpts);
                for(CFIndex index=0; index<horizontalDimensionNpts; index++) {
                    PSIndexArraySetValueAtIndex(theIndexes, horizontalDimensionIndex, index);
                    PSScalarRef response = PSDatasetCreateResponseFromCoordinateIndexes(output, dependentVariableIndex, componentIndex, theIndexes);
                    double argument = PSScalarArgumentValue(response);
                    CFRelease(response);
                    cosine[index] = cosf(argument);
                    sine[index] = sinf(argument);
                }
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions,  memOffset);
                                   CFIndex index = PSIndexArrayGetValueAtIndex(coordinateIndexes, horizontalDimensionIndex);
                                   multipliers->realp[memOffset] = cosine[index];
                                   multipliers->imagp[memOffset] = sine[index];
                                   CFRelease(coordinateIndexes);
                               }
                               );
                free(cosine);
                free(sine);
                
                float complex *responses = (float complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(outputDependentVariable,componentIndex));
                DSPSplitComplex *dsc = malloc(sizeof(struct DSPSplitComplex));
                dsc->realp = (float *) calloc((size_t) size,sizeof(float));
                dsc->imagp = (float *) calloc((size_t) size,sizeof(float));
                vDSP_ctoz((DSPComplex *) responses,2,dsc,1,size);
                
                vDSP_zvmul(multipliers,1,dsc,1,dsc,1,size,1);
                vDSP_ztoc(dsc,1,(DSPComplex *) responses,2,size);
                
                free(dsc->realp);
                free(dsc->imagp);
                free(dsc);
            }
            free(multipliers->realp);
            free(multipliers->imagp);
            free(multipliers);
            break;
        }
        case kPSNumberFloat64ComplexType: {
            DSPDoubleSplitComplex *multipliers = malloc(sizeof(struct DSPDoubleSplitComplex));
            multipliers->realp = (double *) calloc((size_t) size,sizeof(double));
            multipliers->imagp = (double *) calloc((size_t) size,sizeof(double));
            CFIndex memOffset = PSDatumGetMemOffset(PSDatasetGetFocus(output));
            PSMutableIndexArrayRef theIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
            for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                __block double *cosine = malloc(sizeof(double)*horizontalDimensionNpts);
                __block double *sine = malloc(sizeof(double)*horizontalDimensionNpts);
                for(CFIndex index=0; index<horizontalDimensionNpts; index++) {
                    PSIndexArraySetValueAtIndex(theIndexes, horizontalDimensionIndex, index);
                    PSScalarRef response = PSDatasetCreateResponseFromCoordinateIndexes(output, dependentVariableIndex, componentIndex, theIndexes);
                    double argument = PSScalarArgumentValue(response);
                    CFRelease(response);
                    cosine[index] = cosf(argument);
                    sine[index] = sinf(argument);
                }
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   PSIndexArrayRef coordinateIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions,  memOffset);
                                   CFIndex index = PSIndexArrayGetValueAtIndex(coordinateIndexes, horizontalDimensionIndex);
                                   multipliers->realp[memOffset] = cosine[index];
                                   multipliers->imagp[memOffset] = sine[index];
                                   CFRelease(coordinateIndexes);
                               }
                               );
                free(cosine);
                free(sine);
                
                double complex *responses = (double complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(outputDependentVariable,componentIndex));

                DSPDoubleSplitComplex *dsc = malloc(sizeof(struct DSPDoubleSplitComplex));
                dsc->realp = (double *) calloc((size_t) size,sizeof(double));
                dsc->imagp = (double *) calloc((size_t) size,sizeof(double));
                vDSP_ctozD((DSPDoubleComplex *) responses,2,dsc,1,size);
                
                vDSP_zvmulD(multipliers,1,dsc,1,dsc,1,size,1);
                
                vDSP_ztocD(dsc,1,(DSPDoubleComplex *) responses,2,size);
                
                free(dsc->realp);
                free(dsc->imagp);
                free(dsc);
            }
            free(multipliers->realp);
            free(multipliers->imagp);
            free(multipliers);
            break;
        }
    }
    
    return output;
}

