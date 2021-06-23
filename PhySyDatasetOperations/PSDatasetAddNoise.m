//
//  PSDatasetAddNoise.c
//  PSDataset
//
//  Created by Philip J. Grandinetti on 10/22/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

bool PSDatasetAddNoiseValidateForDataset(PSScalarRef noise, PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(noise,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtFocus(theDataset);
    PSDimensionalityRef responseDimensionality = PSQuantityGetUnitDimensionality(theDependentVariable);
    if(PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) noise),
                                                    responseDimensionality)) return true;
    return false;
}


#define RANDOM_MAX 2147483647

static float gaussianNoise(float standardDeviation)
{
    static int iset=0;
    static float gset;
    if  (iset == 0) {
        float r,v1,v2;
        do {
            v1=2.0*(random()/(float) RANDOM_MAX)-1.0;
            v2=2.0*(random()/(float) RANDOM_MAX)-1.0;
            r=v1*v1+v2*v2;
        } while (r >= 1.0);
        float fac=sqrt(-2.0*log(r)/r);
        gset=v1*fac;
        iset=1;
        return v2*fac*standardDeviation;
    } else {
        iset=0;
        return gset*standardDeviation;
    }
}

PSDatasetRef PSDatasetCreateByAddingNoise(PSDatasetRef theDataset,
                                          PSScalarRef noise,
                                          CFIndex level,
                                          CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(PSScalarDoubleValue(noise)==0) return (PSDatasetRef) CFRetain(theDataset);
    
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtFocus(theDataset);
    bool success = true;
    double standardDeviation = PSScalarDoubleValueInUnit(noise, PSQuantityGetUnit(theDependentVariable), &success);
    if(!success) return (PSDatasetRef) CFRetain(theDataset);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    PSDependentVariableRef outputDependentVariable = PSDatasetGetDependentVariableAtFocus(output);
    size_t size = PSDependentVariableSize(outputDependentVariable);
    
    srandom((unsigned)time ( NULL ));
    
    CFIndex componentsCount = PSDependentVariableComponentsCount(outputDependentVariable);
    switch (PSQuantityGetElementType(outputDependentVariable)) {
        case kPSNumberFloat32Type: {
            for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                float *new = (float *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(outputDependentVariable,componentIndex));
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] += gaussianNoise(standardDeviation);
                               }
                               );
            }
            break;
        }
        case kPSNumberFloat64Type: {
            for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                double *new = (double *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(outputDependentVariable,componentIndex));

                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] += gaussianNoise(standardDeviation);
                               }
                               );
            }
            break;
        }
        case kPSNumberFloat32ComplexType: {
            for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                float complex *new = (float complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(outputDependentVariable,componentIndex));

                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] += gaussianNoise(standardDeviation)+I*gaussianNoise(standardDeviation);
                               }
                               );
            }
            break;
        }
        case kPSNumberFloat64ComplexType: {
            for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                double complex *new = (double complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(outputDependentVariable,componentIndex));

                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] += gaussianNoise(standardDeviation)+I*gaussianNoise(standardDeviation);
                               }
                               );
            }
            break;
        }
    }
    return output;
}

