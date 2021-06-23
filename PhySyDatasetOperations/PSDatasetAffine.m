//
//  PSDatasetAffine.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 4/5/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetTranslateCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    {
        PSUnitRef unit = PSDimensionGetDisplayedUnit(horizontalDimension);
        PSScalarRef translation = PSScalarCreateWithDouble(0.0, unit);
        CFDictionaryAddValue(parameters, kPSDatasetTranslation, translation);
        CFRelease(translation);
    }
    {
        PSScalarRef maximumTranslation = PSScalarCreateByMultiplyingByDimensionlessRealConstant(PSDimensionGetIncrement(horizontalDimension), PSDimensionGetNpts(horizontalDimension));
        CFDictionaryAddValue(parameters, kPSDatasetTranslationMaximum, maximumTranslation);
        CFRelease(maximumTranslation);
    }
    
    return parameters;
}

bool PSDatasetTranslateValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetTranslation)) return false;
    PSScalarRef translation = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetTranslation);
    PSUnitRef unit = PSDimensionGetDisplayedUnit(PSDatasetHorizontalDimension(theDataset));
    return PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(unit), PSQuantityGetUnitDimensionality((PSQuantityRef) translation));
}


PSDatasetRef PSDatasetCreateByTranslating(PSDatasetRef theDataset,
                                          PSScalarRef translation,
                                          CFIndex level,
                                          CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(translation,NULL);
    if(PSScalarDoubleValue(translation) == 0.0) {
        return (PSDatasetRef) CFRetain(theDataset);
    }
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    
    if(!PSDimensionHasSameReducedDimensionality(horizontalDimension, verticalDimension)) {
        if(error) {
            CFStringRef desc = CFSTR("Horizontal and Vertical Dimension units must have same dimensionality.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return NULL;
    }
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnit(PSDimensionGetDisplayedUnit(horizontalDimension), NULL);
    double horizontalIncrement = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(horizontalDimension), coherentUnit, NULL);
    double shift = -PSScalarDoubleValueInUnit(translation, coherentUnit, NULL)/horizontalIncrement;
    double integralPart;
    modf(shift, &integralPart);
    
    vImage_AffineTransform_Double transform = {1.0f, 0.0f, 0.0f, 1.0f, -integralPart, 0.0f};
    return PSDatasetCreateByApplyingAffineTransform(theDataset, transform, level, error);
    
}

CFMutableDictionaryRef PSDatasetShearCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFErrorRef error = NULL;
    PSScalarRef shearAngle = PSScalarCreateWithCFString(CFSTR("0.0°"), &error);
    CFDictionaryAddValue(parameters, kPSDatasetShearAngle, shearAngle);
    CFRelease(shearAngle);
    
    return parameters;
}

bool PSDatasetShearValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetShearAngle)) return false;
    PSScalarRef shearAngle = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetShearAngle);
    PSUnitRef unit = PSUnitForSymbol(CFSTR("°"));
    bool success = true;
    double angle = PSScalarDoubleValueInUnit(shearAngle, unit, &success);
    if(!success) return false;
    if(angle>90) {
        shearAngle = PSScalarCreateWithDouble(90, unit);
        CFDictionarySetValue(parameters,kPSDatasetShearAngle , shearAngle);
        CFRelease(shearAngle);
    }
    else if(angle<-90) {
        shearAngle = PSScalarCreateWithDouble(-90, unit);
        CFDictionarySetValue(parameters,kPSDatasetShearAngle , shearAngle);
        CFRelease(shearAngle);
    }
    return true;
}

PSDatasetRef PSDatasetCreateByShearing(PSDatasetRef theDataset,
                                       PSScalarRef shearAngle,
                                       CFIndex level,
                                       CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    if(PSScalarDoubleValue(shearAngle) == 0.0) {
        return (PSDatasetRef) CFRetain(theDataset);
    }
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    
    if(!PSDimensionHasSameReducedDimensionality(horizontalDimension, verticalDimension)) return NULL;
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnit(PSDimensionGetRelativeUnit(horizontalDimension), NULL);
    
    PSScalarRef origin = PSScalarCreateWithDouble(0.0, coherentUnit);
    
    double verticalOriginIndex = PSDimensionGetNpts(verticalDimension) - 1 - PSDimensionIndexFromRelativeCoordinate(verticalDimension, origin);
    PSUnitRef unit = PSUnitForSymbol(CFSTR("rad"));
    double angle = PSScalarDoubleValueInUnit(shearAngle, unit, NULL);
    double shearFactorValue = -tan(angle);
    
    PSScalarRef horizontalSampling = PSDimensionGetIncrement(horizontalDimension);
    PSScalarRef verticalSampling = PSDimensionGetIncrement(verticalDimension);
    PSScalarRef ratio = PSScalarCreateByDividing(verticalSampling, horizontalSampling, error);
    shearFactorValue *= PSScalarDoubleValue(ratio);
    CFRelease(ratio);
    
    vImage_AffineTransform_Double transform = {
        1.0f, 0.0f,
        shearFactorValue, 1.0f,
        -shearFactorValue*verticalOriginIndex, 0
    };
    return PSDatasetCreateByApplyingAffineTransform(theDataset, transform, level, error);
}

CFMutableDictionaryRef PSDatasetRotateCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFErrorRef error = NULL;
    PSScalarRef rotateAngle = PSScalarCreateWithCFString(CFSTR("0.0°"), &error);
    CFDictionaryAddValue(parameters, kPSDatasetRotateAngle, rotateAngle);
    CFRelease(rotateAngle);
    
    return parameters;
}

bool PSDatasetRotateValidateAndUpdateParametersForDataset(PSDatasetRef theDataset, CFMutableDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetRotateAngle)) return false;
    PSScalarRef RotateAngle = (PSScalarRef) CFDictionaryGetValue(parameters, kPSDatasetRotateAngle);
    PSUnitRef unit = PSUnitForSymbol(CFSTR("°"));
    bool success = true;
    double angle = PSScalarDoubleValueInUnit(RotateAngle, unit, &success);
    if(!success) return false;
    if(angle>198) {
        RotateAngle = PSScalarCreateWithDouble(198, unit);
        CFDictionarySetValue(parameters,kPSDatasetRotateAngle , RotateAngle);
        CFRelease(RotateAngle);
    }
    else if(angle<-198) {
        RotateAngle = PSScalarCreateWithDouble(-198, unit);
        CFDictionarySetValue(parameters,kPSDatasetRotateAngle , RotateAngle);
        CFRelease(RotateAngle);
    }
    return true;
}

PSDatasetRef PSDatasetCreateByRotating(PSDatasetRef theDataset,
                                       PSScalarRef rotateAngle,
                                       CFIndex level,
                                       CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    PSUnitRef radians = PSUnitForSymbol(CFSTR("rad"));
    double angle = PSScalarDoubleValueInUnit(rotateAngle,radians,NULL);
    double cosine = cos(angle);
    double sine = sin(angle);
    double oneMinusCosine = 1-cosine;
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    
    if(!PSDimensionHasSameReducedDimensionality(horizontalDimension, verticalDimension)) return NULL;
    PSUnitRef coherentUnit = PSUnitFindCoherentSIUnit(PSDimensionGetRelativeUnit(horizontalDimension), NULL);
    
    PSScalarRef origin = PSScalarCreateWithDouble(0.0, coherentUnit);
    double verticalOriginIndex = PSDimensionGetNpts(verticalDimension) - 1 - PSDimensionIndexFromRelativeCoordinate(verticalDimension, origin);
    
    double horizontalOriginIndex = PSDimensionIndexFromRelativeCoordinate(horizontalDimension, origin);
    vImage_AffineTransform_Double transform = {
        cosine, sine,
        -sine, cosine,
        horizontalOriginIndex*oneMinusCosine+verticalOriginIndex*sine , -horizontalOriginIndex*sine + verticalOriginIndex*oneMinusCosine
    };
    return PSDatasetCreateByApplyingAffineTransform(theDataset, transform, level, error);
}

vImage_AffineTransform Convert_vImage_AffineTransform_Double_to_Float(vImage_AffineTransform_Double transform)
{
    vImage_AffineTransform transform_float = {
        (float) transform.a, (float) transform.b, (float) transform.c, (float) transform.d, 
        (float) transform.tx, (float) transform.ty
    };
    return transform_float;
}

PSDatasetRef PSDatasetCreateByApplyingAffineTransform(PSDatasetRef theDataset,
                                                      vImage_AffineTransform_Double transform,
                                                      CFIndex level,
                                                      CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDatumRef originalFocus = PSDatasetGetFocus(theDataset);
    CFIndex focusDependentVariableIndex = PSDatumGetDependentVariableIndex(originalFocus);
    CFIndex focusComponentIndex = PSDatumGetComponentIndex(originalFocus);

    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    
    CFIndex dimensionsCount = PSDatasetDimensionsCount(output);
    CFIndex *npts = calloc(sizeof(CFIndex), dimensionsCount);
    bool *fft = calloc(sizeof(bool), dimensionsCount);
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef theDimension = PSDatasetGetDimensionAtIndex(output, idim);
        npts[idim] = PSDimensionGetNpts(theDimension);
        fft[idim] = PSDimensionGetFFT(theDimension);
    }
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(output);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(output);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(output);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(output);
    
    PSMutableIndexSetRef dimensionIndexSet = PSIndexSetCreateMutable();
    PSIndexSetAddIndex(dimensionIndexSet, horizontalDimensionIndex);
    PSIndexSetAddIndex(dimensionIndexSet, verticalDimensionIndex);
    
    CFArrayRef dimensions = PSDatasetGetDimensions(output);
    CFArrayRef crossSectionDimensions = PSCFArrayCreateWithObjectsAtIndexes(dimensions, dimensionIndexSet);
    CFMutableArrayRef depthDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, dimensions);
    PSCFArrayRemoveObjectsAtIndexes(depthDimensions, dimensionIndexSet);
    CFIndex reducedSize = PSDimensionCalculateSizeFromDimensions(depthDimensions);
    CFRelease(depthDimensions);
    
    if(!PSDimensionHasSameReducedDimensionality(horizontalDimension, verticalDimension)) {
        FREE(npts);
        FREE(fft);
        CFRelease(dimensionIndexSet);
        CFRelease(crossSectionDimensions);
        // **** CREATE and RETURN informative ERROR here
        return NULL;
    }
    CFIndex dvCount = PSDatasetDependentVariablesCount(output);
    
    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = dvCount;
    PSDatumRef focus = PSDatasetGetFocus(output);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    
    PSMutableIndexArrayRef coordinateIndexes = PSIndexArrayCreateMutable(dimensionsCount);
    PSIndexArraySetValueAtIndex(coordinateIndexes, horizontalDimensionIndex, 0);
    PSIndexArraySetValueAtIndex(coordinateIndexes, verticalDimensionIndex, 1);

    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {

        PSDependentVariableRef dV = PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        
        for(CFIndex reducedMemOffset = 0; reducedMemOffset < reducedSize; reducedMemOffset++) {
            
            setIndexesForReducedMemOffsetIgnoringDimensions(reducedMemOffset, PSIndexArrayGetMutableBytePtr(coordinateIndexes), dimensionsCount, npts, dimensionIndexSet);
            
            PSMutableIndexPairSetRef indexPairSet = PSIndexPairSetCreateMutableWithIndexArray(coordinateIndexes);
            PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, horizontalDimensionIndex);
            PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, verticalDimensionIndex);
            PSDependentVariableRef crossSection = PSDependentVariableCreateCrossSection(dV,dimensions,indexPairSet, error);
            
            vImagePixelCount height = npts[verticalDimensionIndex];
            vImagePixelCount width = npts[horizontalDimensionIndex];
            CFMutableArrayRef transposeDimensions = NULL;
            if(horizontalDimensionIndex > verticalDimensionIndex) {
                transposeDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 2, crossSectionDimensions);
                PSDependentVariableTransposeDimensions(crossSection, transposeDimensions, 0, 1);
                CFArrayExchangeValuesAtIndices(transposeDimensions,0,1);
            }
            
            CFIndex componentsCount = PSDependentVariableComponentsCount(crossSection);
            CFIndex lowerCIndex = 0;
            CFIndex upperCIndex = componentsCount;
            if(level>1) {
                lowerCIndex = PSDatumGetComponentIndex(focus);
                upperCIndex = lowerCIndex+1;
            }
            for(CFIndex componentIndex = lowerCIndex; componentIndex<upperCIndex;componentIndex++) {
                switch (PSQuantityGetElementType(dV)) {
                    case kPSNumberFloat32Type: {
                        vImage_AffineTransform transform_float = Convert_vImage_AffineTransform_Double_to_Float(transform);
                        float *outbytes = (float *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(crossSection,componentIndex));
                        size_t size = PSDependentVariableSize(crossSection);
                        float *inbytes = (float *) calloc((size_t) size, sizeof(float));
                        memcpy(inbytes, outbytes, size*sizeof(float));
                        vImage_Buffer in = {inbytes,height,width,width*sizeof(float)};
                        vImage_Buffer out = {outbytes,height,width,width*sizeof(float)};
                        vImageAffineWarp_PlanarF(&in,&out, NULL,&transform_float,0,kvImageBackgroundColorFill|kvImageHighQualityResampling|kvImageDoNotTile);
                        free(inbytes);
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *outbytes = (double *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(crossSection,componentIndex));
                        size_t size = PSDependentVariableSize(crossSection);
                        double *inbytes = (double *) calloc((size_t) size, sizeof(double));
                        memcpy(inbytes, outbytes, size*sizeof(float));
                        vImage_Buffer in = {inbytes,height,width,width*sizeof(double)};
                        vImage_Buffer out = {outbytes,height,width,width*sizeof(double)};
                        vImageAffineWarpD_PlanarF(&in,&out, NULL,&transform,0,kvImageBackgroundColorFill|kvImageHighQualityResampling|kvImageDoNotTile);
                        free(inbytes);
                        break;
                    }
                        
                    case kPSNumberFloat32ComplexType: {
                        vImage_AffineTransform transform_float = Convert_vImage_AffineTransform_Double_to_Float(transform);
                        float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(crossSection,componentIndex));
                        size_t size = PSDependentVariableSize(crossSection);
                        DSPSplitComplex *splitComplex = malloc(sizeof(struct DSPSplitComplex));
                        splitComplex->realp = (float *) calloc((size_t) size,sizeof(float));
                        splitComplex->imagp = (float *) calloc((size_t) size,sizeof(float));
                        vDSP_ctoz((DSPComplex *) crossSectionBytes,2,splitComplex,1,size);
                        
                        DSPSplitComplex *new = malloc(sizeof(struct DSPSplitComplex));
                        new->realp = (float *) calloc((size_t) size,sizeof(float));
                        new->imagp = (float *) calloc((size_t) size,sizeof(float));
                        
                        vImage_Buffer realIn = {splitComplex->realp, height, width, width*sizeof(float)};
                        vImage_Buffer realOut = {new->realp, height, width, width*sizeof(float)};
                        vImageAffineWarp_PlanarF(&realIn,&realOut,NULL,&transform_float,0,kvImageBackgroundColorFill|kvImageHighQualityResampling);
                        
                        vImage_Buffer imagIn = {splitComplex->imagp,height, width, width*sizeof(float)};
                        vImage_Buffer imagOut = {new->imagp,height, width, width*sizeof(float)};
                        vImageAffineWarp_PlanarF(&imagIn,&imagOut,NULL,&transform_float,0,kvImageBackgroundColorFill|kvImageHighQualityResampling|kvImageDoNotTile);
                        
                        free(splitComplex->realp);
                        free(splitComplex->imagp);
                        free(splitComplex);
                        
                        crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(crossSection,componentIndex));
                        vDSP_ztoc(new,1,(DSPComplex *) crossSectionBytes,2,size);
                        
                        free(new->realp);
                        free(new->imagp);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(crossSection,componentIndex));
                        size_t size = PSDependentVariableSize(crossSection);
                        DSPDoubleSplitComplex *splitComplex = malloc(sizeof(struct DSPDoubleSplitComplex));
                        splitComplex->realp = (double *) calloc((size_t) size,sizeof(double));
                        splitComplex->imagp = (double *) calloc((size_t) size,sizeof(double));
                        vDSP_ctozD((DSPDoubleComplex *) crossSectionBytes,2,splitComplex,1,size);
                        
                        DSPDoubleSplitComplex *new = malloc(sizeof(struct DSPDoubleSplitComplex));
                        new->realp = (double *) calloc((size_t) size,sizeof(double));
                        new->imagp = (double *) calloc((size_t) size,sizeof(double));
                        
                        vImage_Buffer realIn = {splitComplex->realp, height, width, width*sizeof(double)};
                        vImage_Buffer realOut = {new->realp, height, width, width*sizeof(double)};
                        vImageAffineWarpD_PlanarF(&realIn,&realOut,NULL,&transform,0,kvImageBackgroundColorFill|kvImageHighQualityResampling|kvImageDoNotTile);
                        
                        vImage_Buffer imagIn = {splitComplex->imagp,height, width, width*sizeof(double)};
                        vImage_Buffer imagOut = {new->imagp,height, width, width*sizeof(double)};
                        vImageAffineWarpD_PlanarF (&imagIn,&imagOut,NULL,&transform,0,kvImageBackgroundColorFill|kvImageHighQualityResampling|kvImageDoNotTile);
                        
                        free(splitComplex->realp);
                        free(splitComplex->imagp);
                        free(splitComplex);
                        
                        crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(crossSection,componentIndex));
                        vDSP_ztocD(new,1,(DSPDoubleComplex *) crossSectionBytes,2,size);
                        
                        free(new->realp);
                        free(new->imagp);
                        free(new);
                        break;
                    }
                }
            }
            if(horizontalDimensionIndex > verticalDimensionIndex) {
                PSDependentVariableTransposeDimensions(crossSection, transposeDimensions, 0, 1);
            }
            
            if(transposeDimensions) CFRelease(transposeDimensions);
            
            PSDependentVariableSetCrossSection(dV, PSDatasetGetDimensions(output), indexPairSet, crossSection, crossSectionDimensions);
            CFRelease(indexPairSet);
            CFRelease(crossSection);
            
        }
    }
    CFRelease(coordinateIndexes);

    
    FREE(fft);
    FREE(npts);

    focus = PSDatasetGetFocus(output);
    PSDatumSetDependentVariableIndex(focus, focusDependentVariableIndex);
    PSDatumSetComponentIndex(focus, focusComponentIndex);

    if(crossSectionDimensions) CFRelease(crossSectionDimensions);
    return output;
}


