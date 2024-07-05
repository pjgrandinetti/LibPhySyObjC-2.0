//
//  PSDataset.c
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <LibPhySyObjC/PhySyDataset.h>

@implementation PSDataset

- (void) dealloc
{
    if(self->dependentVariables) CFRelease(self->dependentVariables);
    self->dependentVariables = NULL;
    
    if(self->dimensions) CFRelease(self->dimensions);
    self->dimensions = NULL;
    
    if(self->dimensionPrecedence) CFRelease(self->dimensionPrecedence);
    self->dimensionPrecedence = NULL;
    
    if(self->metaData) CFRelease(self->metaData);
    self->metaData = NULL;
    
    if(self->operations) CFRelease(self->operations);
    self->operations = NULL;
    
    if(self->description) CFRelease(self->description);
    self->description = NULL;
    
    [super dealloc];
}


static bool PSDatasetResetFocusCrossSections(PSDatasetRef theDataset, PSIndexArrayRef focusIndexValues)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(theDataset->crossSectionAlongHorizontal) CFRelease(theDataset->crossSectionAlongHorizontal);
    theDataset->crossSectionAlongHorizontal = NULL;
    
    if(theDataset->crossSectionAlongVertical) CFRelease(theDataset->crossSectionAlongVertical);
    theDataset->crossSectionAlongVertical = NULL;
    
    if(theDataset->crossSectionAlongDepth) CFRelease(theDataset->crossSectionAlongDepth);
    theDataset->crossSectionAlongDepth = NULL;
    
    return true;
}

#pragma mark Creators

static bool validateDatasetParameters(CFArrayRef dimensions,
                                      CFArrayRef dependentVariables)
{
    IF_NO_OBJECT_EXISTS_RETURN(dependentVariables,false);
    CFIndex dimensionsCount = 0;
    CFIndex sizeFromDimensions = 0;
    if(dimensions) {
        dimensionsCount = CFArrayGetCount(dimensions);
        for(CFIndex dimIndex=0;dimIndex<dimensionsCount;dimIndex++) {
            id object = CFArrayGetValueAtIndex(dimensions, dimIndex);
            if(![object isKindOfClass:[PSDimension class]]) return false;
        }
        sizeFromDimensions = PSDimensionCalculateSizeFromDimensions(dimensions);
    }
    
    // Validate size and types
    CFIndex dvCount = CFArrayGetCount(dependentVariables);
    if(dvCount == 0) return false;
    for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
        id object = CFArrayGetValueAtIndex(dependentVariables, dvIndex);
        if(![object isKindOfClass:[PSDependentVariable class]]) return false;
        PSDependentVariableRef dependentVariable = (PSDependentVariableRef) object;
        if(sizeFromDimensions != PSDependentVariableSize(dependentVariable)) {
            fprintf(stderr, "**** ERROR - %s - Sizes in dependentVariables and dimensions are different: %ld and %ld\n",__FUNCTION__, PSDependentVariableSize(dependentVariable),sizeFromDimensions);
            return false;
        }
    }
    return true;
}

PSDatasetRef PSDatasetCreateDefault()
{
    // *** Validate input parameters ***
    PSDatasetRef theDataset = (PSDatasetRef) [PSDataset alloc];
    if(theDataset==NULL) return NULL;
    theDataset->description = CFSTR("");
    theDataset->title = CFSTR("");
    theDataset->metaData = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    theDataset->dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    theDataset->dependentVariables = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    theDataset->dimensionPrecedence = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    theDataset->operations = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    theDataset->focus = NULL;
    theDataset->previousFocus = NULL;
    theDataset->crossSectionAlongHorizontal = NULL;
    theDataset->crossSectionAlongVertical = NULL;
    theDataset->crossSectionAlongDepth = NULL;
    theDataset->base64 = true;
    
    return theDataset;
}

PSDependentVariableRef PSDatasetAddDefaultDependentVariable(PSDatasetRef theDataset,
                                                            CFStringRef quantityType,
                                                            numberType elementType,
                                                            CFIndex size)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(quantityType,NULL);
    
    if(NULL==theDataset->dimensions && size<0) return NULL;
    
    if(theDataset->dimensions) {
        CFIndex sizeFromDimensions = PSDimensionCalculateSizeFromDimensions(theDataset->dimensions);
        if(size==kPSDatasetSizeFromDimensions) size = sizeFromDimensions;
        if(size!= sizeFromDimensions) return NULL;
    }
    
    PSDependentVariableRef theDependentVariable = PSDependentVariableCreateDefault(quantityType,
                                                                                   elementType,
                                                                                   size,
                                                                                   theDataset);
    CFArrayAppendValue(theDataset->dependentVariables, theDependentVariable);
    CFRelease(theDependentVariable);
    return theDependentVariable;
}

PSDependentVariableRef PSDatasetAddDefaultDependentVariableWithFillConstant(PSDatasetRef theDataset,
                                                                            CFStringRef quantityType,
                                                                            PSScalarRef fillConstant,
                                                                            CFIndex size)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(quantityType,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(fillConstant,NULL);

    if(NULL==theDataset->dimensions && size<0) return NULL;
    
    if(theDataset->dimensions) {
        CFIndex sizeFromDimensions = PSDimensionCalculateSizeFromDimensions(theDataset->dimensions);
        if(size==kPSDatasetSizeFromDimensions) size = sizeFromDimensions;
        if(size!= sizeFromDimensions) return NULL;
    }
    numberType elementType = PSQuantityGetElementType(fillConstant);
    
    PSDependentVariableRef theDV = PSDependentVariableCreateDefault(quantityType,
                                                                    elementType,
                                                                    size,
                                                                    theDataset);
    CFArrayAppendValue(theDataset->dependentVariables, theDV);
    CFRelease(theDV);

    PSQuantitySetUnit(theDV, PSQuantityGetUnit(fillConstant));
    CFIndex componentsCount = PSDependentVariableComponentsCount(theDV);
    for(CFIndex cIndex=0;cIndex<componentsCount;cIndex++) {
        CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theDV,cIndex);
        switch(elementType) {
            case kPSNumberFloat32Type: {
                float * restrict bytes = (float *) CFDataGetMutableBytePtr(values);
                float value = PSScalarFloatValue(fillConstant);
                for(CFIndex index=0;index<size; index++) bytes[index] = value;
                break;
            }
            case kPSNumberFloat64Type: {
                double * restrict bytes = (double *) CFDataGetMutableBytePtr(values);
                double value = PSScalarDoubleValue(fillConstant);
                for(CFIndex index=0;index<size; index++) bytes[index] = value;
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex * restrict bytes = (float complex *) CFDataGetMutableBytePtr(values);
                float complex value = PSScalarFloatComplexValue(fillConstant);
                for(CFIndex index=0;index<size; index++) bytes[index] = value;
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex * restrict bytes = (double complex *) CFDataGetMutableBytePtr(values);
                double complex value = PSScalarDoubleComplexValue(fillConstant);
                for(CFIndex index=0;index<size; index++) bytes[index] = value;
                break;
            }
        }
    }
    return theDV;
}

PSDatasetRef PSDatasetCreate(CFArrayRef         dimensions,
                             CFArrayRef         dimensionPrecedence,
                             CFArrayRef         dependentVariables,
                             CFArrayRef         tags,
                             CFStringRef        description,
                             CFStringRef        title,
                             PSDatumRef         focus,
                             PSDatumRef         previousFocus,
                             CFDictionaryRef    operations,
                             CFDictionaryRef    metaData)
{
    // *** Validate input parameters ***
    if(!validateDatasetParameters(dimensions, dependentVariables)) return NULL;
    
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariablesCount = CFArrayGetCount(dependentVariables);
    
    if(dimensionPrecedence && CFArrayGetCount(dimensionPrecedence)!=dimensionsCount) dimensionPrecedence = NULL;
    
    if(dimensionPrecedence) {
        for(CFIndex dimensionIndex=0;dimensionIndex<dimensionsCount; dimensionIndex++) {
            CFIndex dimIndex = (CFIndex) CFArrayGetValueAtIndex(dimensionPrecedence, dimensionIndex);
            if(dimIndex>=dimensionsCount || dimIndex < 0) {
                dimensionPrecedence = NULL;
                break;
            }
        }
    }
    
    // *** Initialize object ***
    
    PSDatasetRef newDataset = (PSDatasetRef) [PSDataset alloc];
    if(newDataset==NULL) return NULL;
    
    // *** Setup attributes ***
    newDataset->dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dimensionIndex = 0; dimensionIndex<dimensionsCount; dimensionIndex++) {
        PSDimensionRef oldDimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
        PSDimensionRef dimension = PSDimensionCreateCopy(oldDimension);
        if(dimension==NULL) {
            NSLog(@"what");
        }
        if(dimension) {
            CFArrayAppendValue(newDataset->dimensions, dimension);
            CFRelease(dimension);
        }
    }
    
    
    newDataset->dependentVariables = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
        PSDependentVariableRef dependentVariable = PSDependentVariableCreateCopy((PSDependentVariableRef) CFArrayGetValueAtIndex(dependentVariables, dependentVariableIndex),newDataset);
        PSDependentVariableGetPlot(dependentVariable); // If plot==NULL, then this will instantiate default plot
        if(dependentVariable) {
            CFArrayAppendValue(newDataset->dependentVariables, dependentVariable);
            CFRelease(dependentVariable);
        }
    }
    
    newDataset->dimensionPrecedence = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    if(dimensionPrecedence == NULL) {
        for(CFIndex dimensionIndex = 0; dimensionIndex<dimensionsCount; dimensionIndex++) {
            CFArrayAppendValue(newDataset->dimensionPrecedence, (void *) dimensionIndex);
        }
    }
    else if(CFArrayGetCount(dimensionPrecedence)!=dimensionsCount) {
        for(CFIndex dimensionIndex = 0; dimensionIndex<dimensionsCount; dimensionIndex++) {
            CFArrayAppendValue(newDataset->dimensionPrecedence, (void *) dimensionIndex);
        }
    }
    else {
        for(CFIndex dimensionIndex = 0; dimensionIndex<dimensionsCount; dimensionIndex++) {
            CFArrayAppendValue(newDataset->dimensionPrecedence, (void *) CFArrayGetValueAtIndex(dimensionPrecedence, dimensionIndex));
        }
    }
    
    if(description) newDataset->description = CFStringCreateCopy(kCFAllocatorDefault, description);
    else newDataset->description = CFSTR("");
    
    if(title) newDataset->title = CFStringCreateCopy(kCFAllocatorDefault, title);
    else newDataset->title = CFSTR("");
    
    CFIndex dependentVariableIndex = 0;
    CFIndex componentIndex = 0;
    CFIndex memOffset = 0;
    PSDatumRef testDatum = PSDatasetCreateDatumFromMemOffset(newDataset, dependentVariableIndex, componentIndex, memOffset);
    
    if(focus) {
        if(PSDatumHasSameReducedDimensionalities(focus, testDatum)) newDataset->focus = CFRetain(focus);
        else newDataset->focus = CFRetain(testDatum);
    }
    else newDataset->focus = CFRetain(testDatum);
    
    if(previousFocus) {
        if(PSDatumHasSameReducedDimensionalities(previousFocus, testDatum)) newDataset->previousFocus = CFRetain(previousFocus);
        else newDataset->previousFocus = CFRetain(testDatum);
    }
    else newDataset->previousFocus = CFRetain(testDatum);
    
    newDataset->operations = NULL;
    if(operations) newDataset->operations = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, operations);
    else newDataset->operations = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    newDataset->metaData = NULL;
    if(metaData) newDataset->metaData = CFDictionaryCreateCopy(kCFAllocatorDefault, metaData);
    else newDataset->metaData = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    if(dimensionsCount>1) {
        PSDatumRef focus = PSDatasetGetFocus(newDataset);
        CFIndex memOffset = PSDatumGetMemOffset(focus);
        CFArrayRef dimensions = PSDatasetGetDimensions(newDataset);
        PSIndexArrayRef focusIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions,memOffset);
        if(focusIndexValues) {
            PSDatasetResetFocusCrossSections(newDataset, focusIndexValues);
            CFRelease(focusIndexValues);
        }
    }
    
    return newDataset;
}

PSDatasetRef PSDatasetCreateWithDependentVariable(CFArrayRef              dimensions,
                                                  CFArrayRef              dimensionPrecedence,
                                                  PSDependentVariableRef  dependentVariable,
                                                  CFArrayRef                tags,
                                                  CFStringRef             description,
                                                  CFStringRef             title,
                                                  PSDatumRef              focus,
                                                  PSDatumRef              previousFocus,
                                                  CFDictionaryRef         operations,
                                                  CFDictionaryRef         metaData)
{
    CFMutableArrayRef dependentVariables = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(dependentVariables, dependentVariable);
    PSDatasetRef theDataset = PSDatasetCreate(dimensions,
                                              dimensionPrecedence,
                                              dependentVariables,
                                              tags,
                                              description,
                                              title,
                                              focus,
                                              previousFocus,
                                              operations,
                                              metaData);
    CFRelease(dependentVariables);
    return theDataset;
    
}

PSDatasetRef PSDatasetCreateCopy(PSDatasetRef theDataset)
{
    return PSDatasetCreate(theDataset->dimensions,
                           theDataset->dimensionPrecedence,
                           theDataset->dependentVariables,
                           theDataset->tags,
                           theDataset->description,
                           theDataset->title,
                           theDataset->focus,
                           theDataset->previousFocus,
                           theDataset->operations,
                           theDataset->metaData);
}

PSDatasetRef PSDatasetCreateComplexCopy(PSDatasetRef input)
{
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    CFIndex dependentVariablesCount = CFArrayGetCount(output->dependentVariables);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = CFArrayGetValueAtIndex(output->dependentVariables, dependentVariableIndex);
        if(!PSQuantityIsComplexType(theDependentVariable)) {
            if(PSQuantityGetElementType(theDependentVariable)==kPSNumberFloat32Type) {
                PSDependentVariableSetElementType(theDependentVariable, kPSNumberFloat32ComplexType);
            }
            else {
                PSDependentVariableSetElementType(theDependentVariable, kPSNumberFloat64ComplexType);
            }
        }
    }
    return output;
}

PSDatasetRef PSDatasetCreateByConvertingToNumberType(PSDatasetRef theDataset, numberType elementType)
{
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<CFArrayGetCount(theDataset->dependentVariables); dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = CFArrayGetValueAtIndex(output->dependentVariables, dependentVariableIndex);
        PSDependentVariableSetElementType(theDependentVariable, elementType);
    }
    return output;
}


PSDatasetRef PSDatasetCreateByConvertingLinearToMonotonicDimension(PSDatasetRef theDataset, CFErrorRef *error)
{
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    CFIndex dimIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    PSDimensionRef theDimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
    PSDimensionRef monotonicDimension = PSMonotonicDimensionCreateFromLinear(theDimension);
    
    PSDatasetReplaceDimensionAtIndex(output, dimIndex, monotonicDimension, error);
    CFRelease(monotonicDimension);
    if(*error) {
        CFRelease(output);
        return NULL;
    }
    return output;
}



#pragma mark Accessors
bool PSDatasetHasSameReducedDimensionalities(PSDatasetRef input1, PSDatasetRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(input2,NULL);
    
    CFIndex dimensionsCount1 = 0;
    CFIndex dimensionsCount2 = 0;
    if(input1->dimensions) dimensionsCount1 = CFArrayGetCount(input1->dimensions);
    if(input2->dimensions) dimensionsCount2 = CFArrayGetCount(input2->dimensions);
    if(dimensionsCount1 != dimensionsCount2) return false;
    
    CFIndex dependentVariablesCount1 = 0;
    CFIndex dependentVariablesCount2 = 0;
    if(input1->dependentVariables) dependentVariablesCount1 = CFArrayGetCount(input1->dependentVariables);
    if(input2->dependentVariables) dependentVariablesCount2 = CFArrayGetCount(input2->dependentVariables);
    if(dependentVariablesCount1 != dependentVariablesCount2) return false;
    
    for(CFIndex dependentVariableIndex = 0; dependentVariableIndex<dependentVariablesCount1; dependentVariableIndex++) {
        PSDependentVariableRef dependentVariable1 = (PSDependentVariableRef) CFArrayGetValueAtIndex(input1->dependentVariables, dependentVariableIndex);
        PSDependentVariableRef dependentVariable2 = (PSDependentVariableRef) CFArrayGetValueAtIndex(input2->dependentVariables, dependentVariableIndex);
        if(!PSDependentVariableEqualWithSameReducedDimensionality(dependentVariable1, dependentVariable2)) return false;
    }
    
    for(CFIndex idim = 0; idim<dimensionsCount1; idim++) {
        if(!PSDimensionHasSameReducedDimensionality((PSDimensionRef) CFArrayGetValueAtIndex(input1->dimensions, idim),
                                                    (PSDimensionRef) CFArrayGetValueAtIndex(input2->dimensions, idim))) return false;
    }
    return true;
}

bool PSDatasetHasSameCoordinates(PSDatasetRef input1, PSDatasetRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(input2,NULL);
    
    CFIndex dimensionsCount1 = CFArrayGetCount(input1->dimensions);
    CFIndex dimensionsCount2 = CFArrayGetCount(input2->dimensions);
    if(dimensionsCount1!= dimensionsCount2) return false;
    
    for(CFIndex dimIndex=0;dimIndex<dimensionsCount1; dimIndex++) {
        if(!PSDimensionEqual((PSDimensionRef) CFArrayGetValueAtIndex(input1->dimensions, dimIndex),
                             (PSDimensionRef) CFArrayGetValueAtIndex(input2->dimensions, dimIndex))) {
            return false;
        }
    }
    
    CFIndex dependentVariablesCount1 = CFArrayGetCount(input1->dependentVariables);
    CFIndex dependentVariablesCount2 = CFArrayGetCount(input2->dependentVariables);
    if(dependentVariablesCount1!= dependentVariablesCount2) return false;
    
    return true;
}

CFIndex PSDatasetDependentVariablesCount(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,0);
    return CFArrayGetCount(theDataset->dependentVariables);
}

CFMutableArrayRef PSDatasetGetDependentVariables(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    return theDataset->dependentVariables;
}

PSDependentVariableRef PSDatasetGetDependentVariableAtIndex(PSDatasetRef theDataset,CFIndex dependentVariableIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex dependentVariablesCount = CFArrayGetCount(theDataset->dependentVariables);
    if(dependentVariablesCount==0 || dependentVariableIndex<0 || dependentVariableIndex> dependentVariablesCount-1) return NULL;
    return (PSDependentVariableRef) CFArrayGetValueAtIndex(theDataset->dependentVariables, dependentVariableIndex);
}

CFIndex PSDatasetIndexOfDependentVariable(PSDatasetRef theDataset, PSDependentVariableRef theDependentVariable)
{
    return PSCFArrayIndexOfObject(theDataset->dependentVariables, theDependentVariable);
}

bool PSDatasetSetDependentVariableAtIndex(PSDatasetRef theDataset, CFIndex dependentVariableIndex, PSDependentVariableRef theDependentVariable)
{
    CFIndex sizeFromDimensions = PSDimensionCalculateSizeFromDimensions(theDataset->dimensions);
    if(sizeFromDimensions != PSDependentVariableSize(theDependentVariable)) {
        fprintf(stderr, "**** ERROR - %s - Sizes in dependentVariables and dimensions are different: %ld and %ld\n",__FUNCTION__, PSDependentVariableSize(theDependentVariable),sizeFromDimensions);
        return false;
    }
    
    CFArraySetValueAtIndex(theDataset->dependentVariables, dependentVariableIndex, theDependentVariable);
    return true;
}

bool PSDatasetRemoveDependentVariableAtIndex(PSDatasetRef theDataset, CFIndex dependentVariableIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    PSDatumSetComponentIndex(focus, 0);
    PSDatumSetDependentVariableIndex(focus, 0);
    PSDatumSetMemOffset(focus, 0);

    CFIndex dependentVariablesCount = CFArrayGetCount(theDataset->dependentVariables);
    if(dependentVariableIndex<0 || dependentVariableIndex> dependentVariablesCount-1) return false;
    if(dependentVariablesCount==1) return false;
    CFArrayRemoveValueAtIndex(theDataset->dependentVariables, dependentVariableIndex);
    return true;
}


bool PSDatasetAppendDependentVariable(PSDatasetRef theDataset, PSDependentVariableRef theDependentVariable, CFErrorRef *error)
{
    if(CFArrayGetCount(theDataset->dimensions)) {
        CFIndex sizeFromDimensions = PSDimensionCalculateSizeFromDimensions(theDataset->dimensions);
        if(sizeFromDimensions != PSDependentVariableSize(theDependentVariable)) {
            
            if(error) {
                CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("Sizes in dependentVariables and dimensions are different: %ld and %ld"), PSDependentVariableSize(theDependentVariable),sizeFromDimensions);
                *error = PSCFErrorCreate(CFSTR("Cannot append dependent variable"), reason, NULL);
                CFRelease(reason);
            }

            return false;
        }
    }
    
    CFArrayAppendValue(theDataset->dependentVariables, theDependentVariable);
    PSDependentVariableSetDataset(theDependentVariable, theDataset);
    PSDependentVariableSetPlot(theDependentVariable, PSDependentVariableGetPlot(CFArrayGetValueAtIndex(theDataset->dependentVariables, 0)));
    return true;
}


bool PSDatasetIncludeDatasetDependentVariables(PSDatasetRef theDataset, PSDatasetRef datasetToAppend, CFErrorRef *error)
{
    CFIndex dependentVariablesCountToAppend = PSDatasetDependentVariablesCount(datasetToAppend);
    
    for(CFIndex dependentVariableIndex = 0; dependentVariableIndex<dependentVariablesCountToAppend;dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(datasetToAppend, dependentVariableIndex);
        bool result = PSDatasetAppendDependentVariable(theDataset, theDependentVariable, error);
        if(!result) return result;
    }
    return true;
}


PSDatasetRef PSDatasetCreateByIncludingDatasetDependentVariables(PSDatasetRef theDataset, PSDatasetRef datasetToAppend, CFErrorRef *error)
{
    PSDatasetRef copy = PSDatasetCreateCopy(theDataset);
    if(PSDatasetIncludeDatasetDependentVariables(copy,datasetToAppend,error)==false) {
        if(copy) CFRelease(copy);
        return NULL;
    }
    
    CFMutableStringRef newTitle = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppend(newTitle, PSDatasetGetTitle(theDataset));
    CFStringAppend(newTitle, CFSTR(" and "));
    CFStringAppend(newTitle, PSDatasetGetTitle(datasetToAppend));
    PSDatasetSetTitle(copy, newTitle);
    CFRelease(newTitle);
    
    return copy;
}

CFArrayRef PSDatasetGetTags(PSDatasetRef theDataset)
{
    return theDataset->tags;
}

bool PSDatasetSetTags(PSDatasetRef theDataset, CFArrayRef tags)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(tags == theDataset->tags) return true;
    if(theDataset->tags) CFRelease(theDataset->tags);
    if(tags) theDataset->tags = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, tags);
    else theDataset->tags = NULL;
    return true;
}

CFMutableDictionaryRef PSDatasetGetOperations(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    return theDataset->operations;
}

void PSDatasetSetOperations(PSDatasetRef theDataset, CFDictionaryRef operations)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(operations == theDataset->operations) return;
    if(theDataset->operations) CFRelease(theDataset->operations);
    if(operations) theDataset->operations = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, operations);
    else theDataset->operations = NULL;
}

CFDictionaryRef PSDatasetGetMetaData(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    return theDataset->metaData;
}

void PSDatasetSetMetaData(PSDatasetRef theDataset, CFDictionaryRef metaData)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(metaData == theDataset->metaData) return;
    if(theDataset->metaData) CFRelease(theDataset->metaData);
    if(metaData) theDataset->metaData = CFRetain(metaData);
    else theDataset->metaData = NULL;
}

PSDatasetRef PSDatasetGet1DCrossSectionAlongHorizontal(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensions);
    if(dimensionsCount<1) return NULL;
    if(theDataset->crossSectionAlongHorizontal) return theDataset->crossSectionAlongHorizontal;
    
    CFIndex dimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 0);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSIndexArrayRef focusIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
    PSMutableIndexPairSetRef indexPairSet = PSIndexPairSetCreateMutableWithIndexArray(focusIndexValues);
    PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, dimensionIndex);
    theDataset->crossSectionAlongHorizontal = PSDatasetCreateCrossSection(theDataset, indexPairSet, NULL);
    CFRelease(focusIndexValues);
    CFRelease(indexPairSet);
    return theDataset->crossSectionAlongHorizontal;
}

void PSDatasetSet1DCrossSectionAlongHorizontal(PSDatasetRef theDataset, PSDatasetRef crossSection)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(crossSection == theDataset->crossSectionAlongHorizontal) return;
    if(theDataset->crossSectionAlongHorizontal) CFRelease(theDataset->crossSectionAlongHorizontal);
    if(crossSection) theDataset->crossSectionAlongHorizontal = (PSDatasetRef) CFRetain(crossSection);
    else theDataset->crossSectionAlongHorizontal = NULL;
}

PSDatasetRef PSDatasetGet1DCrossSectionAlongVertical(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensions);
    if(dimensionsCount<2) return NULL;
    if(theDataset->crossSectionAlongVertical) return theDataset->crossSectionAlongVertical;
    
    CFIndex dimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 1);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSIndexArrayRef focusIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
    PSMutableIndexPairSetRef indexPairSet = PSIndexPairSetCreateMutableWithIndexArray(focusIndexValues);
    PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, dimensionIndex);
    theDataset->crossSectionAlongVertical = PSDatasetCreateCrossSection(theDataset, indexPairSet, NULL);
    CFRelease(focusIndexValues);
    CFRelease(indexPairSet);
    return theDataset->crossSectionAlongVertical;
}

void PSDatasetSet1DCrossSectionAlongVertical(PSDatasetRef theDataset, PSDatasetRef crossSection)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(crossSection == theDataset->crossSectionAlongVertical) return;
    if(theDataset->crossSectionAlongVertical) CFRelease(theDataset->crossSectionAlongVertical);
    if(crossSection) theDataset->crossSectionAlongVertical = (PSDatasetRef) CFRetain(crossSection);
    else theDataset->crossSectionAlongVertical = NULL;
}

PSDatasetRef PSDatasetGet1DCrossSectionAlongDepth(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensions);
    if(dimensionsCount<3) return NULL;
    
    if(theDataset->crossSectionAlongDepth) return theDataset->crossSectionAlongDepth;
    
    CFIndex dimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 2);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSIndexArrayRef focusIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
    PSMutableIndexPairSetRef indexPairSet = PSIndexPairSetCreateMutableWithIndexArray(focusIndexValues);
    PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, dimensionIndex);
    theDataset->crossSectionAlongDepth = PSDatasetCreateCrossSection(theDataset, indexPairSet, NULL);
    CFRelease(focusIndexValues);
    CFRelease(indexPairSet);
    return theDataset->crossSectionAlongDepth;
}

void PSDatasetSet1DCrossSectionAlongDepth(PSDatasetRef theDataset, PSDatasetRef crossSection)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(crossSection == theDataset->crossSectionAlongDepth) return;
    if(theDataset->crossSectionAlongDepth) CFRelease(theDataset->crossSectionAlongDepth);
    if(crossSection) theDataset->crossSectionAlongDepth = (PSDatasetRef) CFRetain(crossSection);
    else theDataset->crossSectionAlongDepth = NULL;
}

void PSDatasetReset1DCrossSections(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(theDataset->crossSectionAlongHorizontal) CFRelease(theDataset->crossSectionAlongHorizontal);
    theDataset->crossSectionAlongHorizontal = NULL;
    if(theDataset->crossSectionAlongVertical) CFRelease(theDataset->crossSectionAlongVertical);
    theDataset->crossSectionAlongVertical = NULL;
    if(theDataset->crossSectionAlongDepth) CFRelease(theDataset->crossSectionAlongDepth);
    theDataset->crossSectionAlongDepth = NULL;
}
#pragma mark Dataset Focus
PSDatumRef PSDatasetGetFocus(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(NULL==theDataset->focus) {
        CFIndex dependentVariableIndex = 0;
        CFIndex componentIndex = 0;
        CFIndex memOffset = 0;
        theDataset->focus = PSDatasetCreateDatumFromMemOffset(theDataset,
                                                              dependentVariableIndex,
                                                              componentIndex,
                                                              memOffset);
        if(theDataset->crossSectionAlongHorizontal) {
            PSDatumRef focus = PSDatasetGetFocus(theDataset->crossSectionAlongHorizontal);
            PSDatumSetDependentVariableIndex(focus, dependentVariableIndex);
            PSDatumSetComponentIndex(focus, componentIndex);
        }
        if(theDataset->crossSectionAlongVertical) {
            PSDatumRef focus = PSDatasetGetFocus(theDataset->crossSectionAlongVertical);
            PSDatumSetDependentVariableIndex(focus, dependentVariableIndex);
            PSDatumSetComponentIndex(focus, componentIndex);
        }
        if(theDataset->crossSectionAlongDepth) {
            PSDatumRef focus = PSDatasetGetFocus(theDataset->crossSectionAlongDepth);
            PSDatumSetDependentVariableIndex(focus, dependentVariableIndex);
            PSDatumSetComponentIndex(focus, componentIndex);
        }
        
    }
    return theDataset->focus;
}

PSDatumRef PSDatasetGetPreviousFocus(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(NULL==theDataset->previousFocus) {
        CFIndex dependentVariableIndex = 0;
        CFIndex componentIndex = 0;
        CFIndex memOffset = 0;
        theDataset->previousFocus = PSDatasetCreateDatumFromMemOffset(theDataset,
                                                                      dependentVariableIndex,
                                                                      componentIndex,
                                                                      memOffset);
    }
    return theDataset->previousFocus;
}

bool PSDatasetSetFocus(PSDatasetRef theDataset, PSDatumRef newFocus)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(newFocus,false);
    
    if(theDataset->focus == newFocus) return true;
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    if(dimensionsCount != PSDatumCoordinatesCount(newFocus)) return false;
    
    PSDatumRef temp = PSDatasetCreateDatumFromMemOffset(theDataset, 0, 0, 0);
    if(!PSDatumHasSameReducedDimensionalities(temp, newFocus)) {
        CFRelease(temp);
        return false;
    }
    CFRelease(temp);
    
    if(theDataset->focus) {
        PSDatumRef temp = theDataset->previousFocus;
        theDataset->previousFocus = theDataset->focus;
        theDataset->focus = CFRetain(newFocus);
        if(temp) CFRelease(temp);
    }
    else
        theDataset->focus = CFRetain(newFocus);
    
    if(dimensionsCount>1) {
        CFIndex memOffset = PSDatumGetMemOffset(theDataset->focus);
        PSIndexArrayRef focusIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
        if(focusIndexValues) {
            PSDatasetResetFocusCrossSections(theDataset, focusIndexValues);
            CFRelease(focusIndexValues);
        }
    }
    
    if(theDataset->crossSectionAlongHorizontal) {
        CFIndex dVIndex = PSDatumGetDependentVariableIndex(theDataset->focus);
        CFIndex cIndex = PSDatumGetComponentIndex(theDataset->focus);
        PSDatumRef focus = PSDatasetGetFocus(theDataset->crossSectionAlongHorizontal);
        PSDatumSetDependentVariableIndex(focus, dVIndex);
        PSDatumSetComponentIndex(focus, cIndex);
    }
    if(theDataset->crossSectionAlongVertical) {
        CFIndex dVIndex = PSDatumGetDependentVariableIndex(theDataset->focus);
        CFIndex cIndex = PSDatumGetComponentIndex(theDataset->focus);
        PSDatumRef focus = PSDatasetGetFocus(theDataset->crossSectionAlongVertical);
        PSDatumSetDependentVariableIndex(focus, dVIndex);
        PSDatumSetComponentIndex(focus, cIndex);
    }
    if(theDataset->crossSectionAlongDepth) {
        CFIndex dVIndex = PSDatumGetDependentVariableIndex(theDataset->focus);
        CFIndex cIndex = PSDatumGetComponentIndex(theDataset->focus);
        PSDatumRef focus = PSDatasetGetFocus(theDataset->crossSectionAlongDepth);
        PSDatumSetDependentVariableIndex(focus, dVIndex);
        PSDatumSetComponentIndex(focus, cIndex);
    }
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(),
                                         CFSTR("FocusReplaced"),
                                         theDataset,
                                         NULL,
                                         true);
    return true;
}


bool PSDatasetResetFocus(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(theDataset->focus) CFRelease(theDataset->focus);
    theDataset->focus = NULL;
    if(theDataset->crossSectionAlongHorizontal) {
        PSDatasetResetFocus(theDataset->crossSectionAlongHorizontal);
    }
    if(theDataset->crossSectionAlongVertical) {
        PSDatasetResetFocus(theDataset->crossSectionAlongVertical);
    }
    if(theDataset->crossSectionAlongDepth) {
        PSDatasetResetFocus(theDataset->crossSectionAlongDepth);
    }
    
    return true;
}

bool PSDatasetSetPreviousFocus(PSDatasetRef theDataset, PSDatumRef newFocus)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(newFocus,false);
    
    if(theDataset->previousFocus == newFocus) return true;
    if(newFocus==NULL) return false;
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    if(dimensionsCount != PSDatumCoordinatesCount(newFocus)) return false;
    
    PSDatumRef temp = PSDatasetCreateDatumFromMemOffset(theDataset,0,0,0);
    if(!PSDatumHasSameReducedDimensionalities(temp, newFocus)) {
        CFRelease(temp);
        return false;
    }
    CFRelease(temp);
    
    if(theDataset->previousFocus) theDataset->previousFocus = CFRetain(newFocus);
    else theDataset->previousFocus = CFRetain(newFocus);
    
    return true;
}

bool PSDatasetSetReferenceOffsetToZeroAtFocus(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
    
    CFIndex dvCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dimIndex=0;dimIndex<dimensionsCount; dimIndex++) {
        CFIndex coordinateIndex = PSIndexArrayGetValueAtIndex(focusIndexes, dimIndex);
        PSDimensionRef dimension = CFArrayGetValueAtIndex(theDataset->dimensions, dimIndex);
        PSScalarRef focusCoordinate = PSDimensionCreateRelativeCoordinateFromIndex(dimension, coordinateIndex);
        PSDimensionZeroReferenceOffset(dimension);
        PSScalarRef relativeCoordinate = PSDimensionCreateRelativeCoordinateFromIndex(dimension, coordinateIndex);
        PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) relativeCoordinate, -1);
        PSDimensionSetReferenceOffset(dimension, relativeCoordinate);
        
        PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) focusCoordinate, -1);
        for(CFIndex dvIndex=0;dvIndex<dvCount;dvIndex++) {
            PSDependentVariableRef dV = PSDatasetGetDependentVariableAtIndex(theDataset, dvIndex);
            PSPlotRef thePlot = PSDependentVariableGetPlot(dV);
            PSAxisShift(PSPlotAxisAtIndex(thePlot, dimIndex), focusCoordinate, true, error);
        }
        CFRelease(focusCoordinate);
    }
    
    PSDatumRef newFocus = PSDatasetCreateDatumFromMemOffset(theDataset,dvIndex,componentIndex,memOffset);
    PSDatasetSetFocus(theDataset, newFocus);
    CFRelease(newFocus);
    
    dvCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dvIndex=0;dvIndex<dvCount;dvIndex++) {
        PSDependentVariableRef dV = PSDatasetGetDependentVariableAtIndex(theDataset, dvIndex);
        PSPlotSetViewNeedsRegenerated(PSDependentVariableGetPlot(dV), true);
    }
    
    return true;
}

bool PSDatasetMoveReferenceOffsetsToGiveFocusNewCoordinates(PSDatasetRef theDataset,
                                                            CFArrayRef newFocusCoordinates,
                                                            CFErrorRef *error)
{
    if(error) if(*error) return false;
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
    CFArrayRef oldFocusCoordinates = PSDimensionCreateDisplayedCoordinatesFromIndexes(theDataset->dimensions, focusIndexes);
    CFIndex dvCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dimIndex=0;dimIndex<dimensionsCount; dimIndex++) {
        PSDimensionRef dimension = (PSDimensionRef) CFArrayGetValueAtIndex(theDataset->dimensions, dimIndex);
        PSScalarRef currentFocusCoordinate = CFArrayGetValueAtIndex(oldFocusCoordinates, dimIndex);
        PSScalarRef desiredFocusCoordinate = CFArrayGetValueAtIndex(newFocusCoordinates, dimIndex);
        
        double currentFocusIndex = PSDimensionIndexFromDisplayedCoordinate(dimension, currentFocusCoordinate);
        double desiredFocusIndex = PSDimensionIndexFromDisplayedCoordinate(dimension, desiredFocusCoordinate);
        PSScalarRef currentFocusRelativeCoordinate = PSDimensionCreateRelativeCoordinateFromIndex(dimension, currentFocusIndex);
        PSScalarRef desiredFocusRelativeCoordinate = PSDimensionCreateRelativeCoordinateFromIndex(dimension, desiredFocusIndex);
        PSScalarRef relativeCoordinateDifference = PSScalarCreateBySubtracting(desiredFocusRelativeCoordinate, currentFocusRelativeCoordinate, error);
        
        PSScalarRef currentReferenceOffset = PSDimensionGetReferenceOffset(dimension);
        
        PSScalarRef newOffset = PSScalarCreateByAdding(currentReferenceOffset, relativeCoordinateDifference, error);
        PSDimensionSetReferenceOffset(dimension, newOffset);
        
        
        PSScalarRef displayedDifference = PSScalarCreateBySubtracting(desiredFocusCoordinate, currentFocusCoordinate, error);
        for(CFIndex dvIndex=0;dvIndex<dvCount;dvIndex++) {
            PSDependentVariableRef dV = PSDatasetGetDependentVariableAtIndex(theDataset, dvIndex);
            PSPlotRef thePlot = PSDependentVariableGetPlot(dV);
            PSAxisShift(PSPlotAxisAtIndex(thePlot, dimIndex), displayedDifference, true, error);
        }
        
        CFRelease(displayedDifference);
        CFRelease(currentFocusRelativeCoordinate);
        CFRelease(desiredFocusRelativeCoordinate);
        CFRelease(relativeCoordinateDifference);
        CFRelease(newOffset);
    }
    
    CFRelease(oldFocusCoordinates);
    
    if(error) if(*error) return false;

    PSDatumRef newFocus = PSDatasetCreateDatumFromDisplayedCoordinates(theDataset,
                                                                       PSDatumGetDependentVariableIndex(theDataset->focus),
                                                                       PSDatumGetComponentIndex(theDataset->focus),
                                                                       newFocusCoordinates);
    
    PSDatasetSetFocus(theDataset, newFocus);
    CFRelease(newFocus);
    
    dvCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dvIndex=0;dvIndex<dvCount;dvIndex++) {
        PSDependentVariableRef dV = PSDatasetGetDependentVariableAtIndex(theDataset, dvIndex);
        PSPlotSetViewNeedsRegenerated(PSDependentVariableGetPlot(dV), true);
    }

    return true;
}

bool PSDatasetMoveFocusToMaximumMagnitudeResponse(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return false;
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    CFIndex memOffsetMax = 0;
    CFIndex componentIndexMax = 0;
    
    PSDependentVariableFindMaximumForPart(theDependentVariable,
                                          kPSMagnitudePart,
                                          &memOffsetMax,
                                          &componentIndexMax,
                                          error);
    if(error) if(*error) return false;
    PSDatumRef position = PSDatasetCreateDatumFromMemOffset(theDataset,
                                                            dependentVariableIndex,
                                                            componentIndexMax,
                                                            memOffsetMax);
    PSDatasetSetFocus(theDataset, position);
    PSPlotSetViewNeedsRegenerated(PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtFocus(theDataset)), true);
    return true;
}

bool PSDatasetMoveFocusToMinimumMagnitudeResponse(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return false;
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    CFIndex memOffsetMin = 0;
    CFIndex componentIndexMin = 0;
    
    PSDependentVariableFindMinimumForPart(theDependentVariable,
                                          kPSMagnitudePart,
                                          &memOffsetMin,
                                          &componentIndexMin,
                                          error);
    if(error) if(*error) return false;
    PSDatumRef position = PSDatasetCreateDatumFromMemOffset(theDataset,
                                                            dependentVariableIndex,
                                                            componentIndexMin,
                                                            memOffsetMin);
    PSDatasetSetFocus(theDataset, position);
    PSPlotSetViewNeedsRegenerated(PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtFocus(theDataset)), true);
    return true;
}

PSDependentVariableRef PSDatasetGetDependentVariableAtFocus(PSDatasetRef theDataset)
{
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex =PSDatumGetDependentVariableIndex(focus);
    if(dvIndex==kCFNotFound) return NULL;
    return CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
}

PSPlotRef PSDatasetGetPlotAtFocus(PSDatasetRef theDataset)
{
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex =PSDatumGetDependentVariableIndex(focus);
    if(dvIndex==kCFNotFound) return NULL;
    PSDependentVariableRef theDependentVariable = CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
    return PSDependentVariableGetPlot(theDependentVariable);
    
}

bool PSDatasetSetPlotAtFocus(PSDatasetRef theDataset, PSPlotRef thePlot)
{
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex =PSDatumGetDependentVariableIndex(focus);
    if(dvIndex==kCFNotFound) return false;
    PSDependentVariableRef theDependentVariable = CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
    
    return PSDependentVariableSetPlot(theDependentVariable, thePlot);
}


PSDatasetRef PSDatasetCreateHorizontalCrossSectionAtFocus(PSDatasetRef theDataset)
{
    if(PSDatasetDimensionsCount(theDataset)<2) return NULL;

    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    CFErrorRef error = NULL;

    PSScalarRef coordinate = PSDatumGetCoordinateAtIndex(focus, verticalDimensionIndex);
    CFIndex index = PSDimensionClosestIndexToDisplayedCoordinate(PSDatasetVerticalDimension(theDataset), coordinate);
    PSIndexPairSetRef indexPairSet = PSIndexPairSetCreateWithIndexPair(verticalDimensionIndex, index);
    PSDatasetRef crossSection = PSDatasetCreateCrossSection(theDataset, indexPairSet, &error);
    CFRelease(indexPairSet);
    return crossSection;
}

PSDatasetRef PSDatasetCreateVerticalCrossSectionAtFocus(PSDatasetRef theDataset)
{
    if(theDataset==NULL) return NULL;
    if(PSDatasetDimensionsCount(theDataset)<2) return NULL;

    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFErrorRef error = NULL;

    PSScalarRef coordinate = PSDatumGetCoordinateAtIndex(focus, horizontalDimensionIndex);
    
    CFIndex index = PSDimensionClosestIndexToDisplayedCoordinate(PSDatasetHorizontalDimension(theDataset), coordinate);
    PSIndexPairSetRef indexPairSet = PSIndexPairSetCreateWithIndexPair(horizontalDimensionIndex, index);
    PSDatasetRef crossSection = PSDatasetCreateCrossSection(theDataset, indexPairSet, &error);
    CFRelease(indexPairSet);
    return crossSection;
}

PSDatasetRef PSDatasetCreateDepthCrossSectionAtFocus(PSDatasetRef theDataset)
{
    if(theDataset==NULL) return NULL;
    if(PSDatasetDimensionsCount(theDataset)<3) return NULL;
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex depthDimensionIndex = PSDatasetGetDepthDimensionIndex(theDataset);
    CFErrorRef error = NULL;

    PSScalarRef coordinate = PSDatumGetCoordinateAtIndex(focus, depthDimensionIndex);
    
    CFIndex index = PSDimensionClosestIndexToDisplayedCoordinate(PSDatasetDepthDimension(theDataset), coordinate);
    PSIndexPairSetRef indexPairSet = PSIndexPairSetCreateWithIndexPair(depthDimensionIndex, index);
    PSDatasetRef crossSection = PSDatasetCreateCrossSection(theDataset, indexPairSet, &error);
    CFRelease(indexPairSet);
    return crossSection;
}


CFIndex PSDatasetDimensionsCount(PSDatasetRef theDataset)
{
    CFIndex count = 0;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,count);
    if(theDataset->dimensions) count = CFArrayGetCount(theDataset->dimensions);
    return count;
}


CFStringRef PSDatasetGetTitle(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(NULL==theDataset->title) return CFSTR("");
    return theDataset->title;
}

void PSDatasetSetTitle(PSDatasetRef theDataset, CFStringRef title)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(theDataset->title==title) return;
    if(theDataset->title) CFRelease(theDataset->title);
    if(title) theDataset->title = CFRetain(title);
    else theDataset->title = NULL;
}

CFStringRef PSDatasetGetDescription(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    return theDataset->description;
}

void PSDatasetSetDescription(PSDatasetRef theDataset, CFStringRef description)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(theDataset->description==description) return;
    if(theDataset->description) CFRelease(theDataset->description);
    if(description) theDataset->description = CFRetain(description);
    else theDataset->description = NULL;
}

CFArrayRef PSDatasetGetDimensions(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    return theDataset->dimensions;
}

PSDimensionRef PSDatasetGetDimensionAtIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(dimIndex<0 || dimIndex>PSDatasetDimensionsCount(theDataset)-1) {
        return NULL;
    }
    return (PSDimensionRef) CFArrayGetValueAtIndex(theDataset->dimensions,dimIndex);
}

PSUnitRef PSDatasetDimensionUnitAtIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset,dimIndex);
    return PSDimensionGetDisplayedUnit(dimension);
}

CFStringRef PSDatasetDimensionQuantityNameAtIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
    if(dimension) return PSDimensionGetQuantityName(dimension);
    return NULL;
}

CFStringRef PSDatasetDimensionLabelAtIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, dimIndex);
    if(dimension) return PSDimensionGetLabel(dimension);
    return NULL;
}

CFStringRef PSDatasetCreateStringWithDimensionQuantityNameUnitAndIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFStringRef quantityName = PSDatasetDimensionQuantityNameAtIndex(theDataset, dimIndex);
    PSUnitRef unit = PSDatasetDimensionUnitAtIndex(theDataset, dimIndex);
    CFStringRef symbol = PSUnitCopySymbol(unit);
    CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                  NULL,
                                                  CFSTR("%@ - %ld / %@"),
                                                  quantityName,
                                                  dimIndex,symbol);
    CFRelease(symbol);
    return result;
}

CFStringRef PSDatasetCreateStringWithDimensionLabelUnitAndIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFStringRef label = PSDatasetDimensionLabelAtIndex(theDataset, dimIndex);
    if(label) {
        PSUnitRef unit = PSDatasetDimensionUnitAtIndex(theDataset, dimIndex);
        CFStringRef symbol = PSUnitCopySymbol(unit);
        CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                      NULL,
                                                      CFSTR("%@ / %@"),
                                                      label,
                                                      symbol);
        CFRelease(symbol);
        return result;
    }
    return PSDatasetCreateStringWithDimensionQuantityNameUnitAndIndex(theDataset, dimIndex);
}


#pragma mark Dataset Dimensions and Precedence
bool PSDatasetSetDimensions(PSDatasetRef theDataset, CFArrayRef dimensions, CFArrayRef dimensionPrecedence)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(dimensions,false);
    
    // Validate dimensions
    CFIndex dimensionsCount = 0;
    CFIndex sizeFromDimensions = 0;
    if(dimensions) {
        dimensionsCount = CFArrayGetCount(dimensions);
        for(CFIndex dimIndex=0;dimIndex<dimensionsCount;dimIndex++) {
            id object = CFArrayGetValueAtIndex(dimensions, dimIndex);
            if(![object isKindOfClass:[PSDimension class]]) return false;
        }
        sizeFromDimensions = PSDimensionCalculateSizeFromDimensions(dimensions);
    }
    
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);
    if(dvCount>0) {
        for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
            PSDependentVariableRef dependentVariable = CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
            if(sizeFromDimensions != PSDependentVariableSize(dependentVariable)) {
                fprintf(stderr, "**** ERROR - %s - Sizes in dependentVariables and dimensions are different: %ld and %ld\n",__FUNCTION__, PSDependentVariableSize(dependentVariable),sizeFromDimensions);
                return false;
            }
        }
    }
    
    // Validate dimensionPrecedence
    if(dimensionPrecedence && CFArrayGetCount(dimensionPrecedence)!=dimensionsCount) return false;
    if(dimensionPrecedence) {
        for(CFIndex dimIndex=0;dimIndex<dimensionsCount; dimIndex++) {
            CFIndex dimensionIndex = (CFIndex) CFArrayGetValueAtIndex(dimensionPrecedence, dimIndex);
            if(dimensionIndex>=dimensionsCount || dimensionIndex < 0) return false;
        }
    }
    
    theDataset->dimensionPrecedence = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    if(dimensionPrecedence == NULL) {
        for(CFIndex dimIndex = 0; dimIndex<dimensionsCount; dimIndex++) {
            CFArrayAppendValue(theDataset->dimensionPrecedence, (void *) dimIndex);
        }
    }
    else {
        for(CFIndex dimIndex = 0; dimIndex<dimensionsCount; dimIndex++) {
            CFArrayAppendValue(theDataset->dimensionPrecedence, (void *) CFArrayGetValueAtIndex(dimensionPrecedence, dimIndex));
        }
    }
    
    for(CFIndex dimensionIndex = 0; dimensionIndex<dimensionsCount; dimensionIndex++) {
        PSDimensionRef oldDimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, dimensionIndex);
        PSDimensionRef dimension = PSDimensionCreateCopy(oldDimension);
        if(dimension) {
            CFArrayAppendValue(theDataset->dimensions, dimension);
            CFRelease(dimension);
        }
    }
    return true;
}

bool PSDatasetReplaceDimensionAtIndex(PSDatasetRef theDataset,
                                      CFIndex dimIndex,
                                      PSDimensionRef theDimension,
                                      CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    if(dimensionsCount<=0) return false;
    if(dimIndex >= dimensionsCount) {
        if(error) {
            if(error) *error = PSCFErrorCreate(CFSTR("PSDatasetReplaceDimensionAtIndex out of range"), NULL, NULL);
        }
        return false;
    }

    PSDimensionRef oldDimension = (PSDimensionRef) CFArrayGetValueAtIndex(theDataset->dimensions, dimIndex);
    CFIndex oldNpts = PSDimensionGetNpts(oldDimension);
    CFIndex newNpts = PSDimensionGetNpts(theDimension);

    if(newNpts==oldNpts) {
        if(oldDimension == theDimension) return true;
        PSDimensionRef copy = PSDimensionCreateCopy(theDimension);
        CFArraySetValueAtIndex(theDataset->dimensions, dimIndex, copy);
        CFRelease(copy);
        return true;
    }
    
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);
    if(dimensionsCount==1) {
        PSDimensionRef copy = PSDimensionCreateCopy(theDimension);
        CFArraySetValueAtIndex(theDataset->dimensions, dimIndex, copy);
        CFRelease(copy);
        if(newNpts != oldNpts) {
            for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
                PSDependentVariableRef dV = CFArrayGetValueAtIndex(theDataset->dependentVariables,dvIndex);
                PSDependentVariableSetSize(dV, PSDimensionGetNpts(theDimension));
                PSPlotReset(PSDependentVariableGetPlot(dV));
            }
        }
        return true;
    }
    else if(dimensionsCount>1) {
        PSDatumRef focus = PSDatasetGetFocus(theDataset);
        CFIndex memOffset = PSDatumGetMemOffset(focus);
        PSIndexArrayRef focusIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
        char trimSide[2];
        trimSide[0] = 'r';
        
        if(newNpts != oldNpts) {
            if(newNpts>oldNpts) {
                for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
                    PSDependentVariableRef dV = CFArrayGetValueAtIndex(theDataset->dependentVariables,dvIndex);
                    PSDependentVariableFillAlongDimension(dV, theDataset->dimensions, dimIndex, NULL, trimSide, newNpts-oldNpts);
                }
                PSDimensionRef copy = PSDimensionCreateCopy(theDimension);
                CFArraySetValueAtIndex(theDataset->dimensions, dimIndex, copy);
                CFRelease(copy);
            }
            else {
                
                for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
                    PSDependentVariableRef dV = CFArrayGetValueAtIndex(theDataset->dependentVariables,dvIndex);
                    PSDependentVariableTrimAlongDimension(dV, theDataset->dimensions, dimIndex, trimSide, oldNpts-newNpts);
                }
                PSDimensionRef copy = PSDimensionCreateCopy(theDimension);
                CFArraySetValueAtIndex(theDataset->dimensions, dimIndex, copy);
                CFRelease(copy);
            }
        }
        // focusIndexValues
       if(focusIndexValues) {
            PSDatasetResetFocusCrossSections(theDataset,focusIndexValues);
            CFRelease(focusIndexValues);
        }
    }
    
    CFStringRef displayedQuantityName = PSDimensionCopyDisplayedQuantityName(theDimension);
    for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(theDataset->dependentVariables,dvIndex);
        PSAxisRef theAxis = PSPlotAxisAtIndex(PSDependentVariableGetPlot(dV), dimIndex);
        PSAxisReset(theAxis, displayedQuantityName);
    }
    CFRelease(displayedQuantityName);

    return true;
}

bool PSDatasetRemoveDimensionAtIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSMutableIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
    
    CFArrayRemoveValueAtIndex(theDataset->dimensions, dimIndex);
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);
    for(CFIndex dvIndex = 0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(theDataset->dependentVariables,dvIndex);
        PSPlotRef thePlot = PSDependentVariableGetPlot(dV);
        PSPlotRemoveAxisAtIndex(thePlot, dimIndex);
    }
    
    PSIndexArrayRemoveValueAtIndex(focusIndexes, dimIndex);
    
    memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDataset->dimensions, focusIndexes);
    CFRelease(focusIndexes);
    
    PSDatumRef newFocus = PSDatasetCreateDatumFromMemOffset(theDataset, dvIndex, componentIndex, memOffset);
    CFRelease(theDataset->focus);
    theDataset->focus = newFocus;
    
    PSDatasetResetDimensionPrecedence(theDataset);
    
    return true;
}

bool PSDatasetRemoveDimensionsAtIndexes(PSDatasetRef theDataset, PSIndexSetRef dimensionIndexes)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dvIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSMutableIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
    
    PSCFArrayRemoveObjectsAtIndexes(theDataset->dimensions, dimensionIndexes);
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef outputDV = (PSDependentVariableRef) CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
        PSPlotRef outputPlot = PSDependentVariableGetPlot(outputDV);
        PSPlotRemoveAxesAtIndexes(outputPlot, dimensionIndexes);
    }
    
    PSIndexArrayRemoveValuesAtIndexes(focusIndexes,dimensionIndexes);
    
    memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDataset->dimensions, focusIndexes);
    CFRelease(focusIndexes);
    
    PSDatumRef newFocus = PSDatasetCreateDatumFromMemOffset(theDataset, dvIndex, componentIndex, memOffset);
    CFRelease(theDataset->focus);
    theDataset->focus = newFocus;
    
    PSDatasetResetDimensionPrecedence(theDataset);
    return true;
}

void PSDatasetResetDimensionPrecedence(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(theDataset->dimensionPrecedence) CFRelease(theDataset->dimensionPrecedence);
    theDataset->dimensionPrecedence = NULL;
    if(theDataset->dimensions) {
        CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensions);
        theDataset->dimensionPrecedence = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
        for(CFIndex dimensionIndex = 0; dimensionIndex<dimensionsCount; dimensionIndex++) {
            CFArrayAppendValue(theDataset->dimensionPrecedence, (void *) dimensionIndex);
        }
    }
}


CFMutableArrayRef PSDatasetGetDimensionPrecedence(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    return theDataset->dimensionPrecedence;
}

CFIndex PSDatasetGetPrecedenceOfDimensionAtIndex(PSDatasetRef theDataset, CFIndex dimIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,0);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    return (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, dimIndex);
}

CFIndex PSDatasetGetHorizontalDimensionIndex(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,kCFNotFound);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    if(CFArrayGetCount(theDataset->dimensionPrecedence) < 1) return kCFNotFound;
    return (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 0);
}

void PSDatasetSetHorizontalDimensionIndex(PSDatasetRef theDataset, CFIndex horizontalDimensionIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensionPrecedence);
    if(dimensionsCount<2) return;
    
    CFIndex oldHorizontalDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 0);
    if(horizontalDimensionIndex == oldHorizontalDimensionIndex) return;
    
    CFIndex oldPrecedenceOfnewHorizontalDimension =
    CFArrayGetFirstIndexOfValue(theDataset->dimensionPrecedence,
                                CFRangeMake(0, dimensionsCount),
                                (const void *) horizontalDimensionIndex);
    
    // Swap precedences
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 0, (void *) horizontalDimensionIndex);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, oldPrecedenceOfnewHorizontalDimension, (void *) oldHorizontalDimensionIndex);
}

void PSDatasetSetVerticalDimensionIndex(PSDatasetRef theDataset, CFIndex verticalDimensionIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensionPrecedence);
    if(dimensionsCount<2) return;
    
    CFIndex oldVerticalDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 1);
    if(verticalDimensionIndex == oldVerticalDimensionIndex) return;
    
    CFIndex oldPrecedenceOfnewVerticalDimension =
    CFArrayGetFirstIndexOfValue(theDataset->dimensionPrecedence,
                                CFRangeMake(0, dimensionsCount),
                                (const void *) verticalDimensionIndex);
    
    // Swap precedences
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 1, (void *) verticalDimensionIndex);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, oldPrecedenceOfnewVerticalDimension, (void *) oldVerticalDimensionIndex);
}

void PSDatasetSetDepthDimensionIndex(PSDatasetRef theDataset, CFIndex depthDimensionIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensionPrecedence);
    if(dimensionsCount<3) return;
    
    CFIndex oldDepthDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 2);
    if(depthDimensionIndex == oldDepthDimensionIndex) return;
    
    CFIndex oldPrecedenceOfnewDepthDimension =
    CFArrayGetFirstIndexOfValue(theDataset->dimensionPrecedence,
                                CFRangeMake(0, dimensionsCount),
                                (const void *) depthDimensionIndex);
    
    // Swap precedences
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 2, (void *) depthDimensionIndex);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, oldPrecedenceOfnewDepthDimension, (void *) oldDepthDimensionIndex);
}

CFIndex PSDatasetGetVerticalDimensionIndex(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,kCFNotFound);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    if(CFArrayGetCount(theDataset->dimensionPrecedence) < 2) return kCFNotFound;
    return (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 1);
}

CFIndex PSDatasetGetDepthDimensionIndex(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,kCFNotFound);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    if(CFArrayGetCount(theDataset->dimensionPrecedence) < 3) return kCFNotFound;
    return (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 2);
}

void PSSDatasetSwapHorizontalAndVerticalDimensionPrecedence(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    if(CFArrayGetCount(theDataset->dimensionPrecedence) < 2) return;
    CFIndex horizontalDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 0);
    CFIndex verticalDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 1);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 0, (void *) verticalDimensionIndex);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 1, (void *) horizontalDimensionIndex);
    
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dependentVariableIndex=0;dependentVariableIndex<dependentVariablesCount;dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        PSPlotSetViewNeedsRegenerated(PSDependentVariableGetPlot(theDependentVariable), true);
    }
}

void PSSDatasetSwapVerticalAndDepthDimensionPrecedence(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    if(CFArrayGetCount(theDataset->dimensionPrecedence) < 3) return;
    CFIndex depthDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 2);
    CFIndex verticalDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 1);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 2, (void *) verticalDimensionIndex);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 1, (void *) depthDimensionIndex);
    
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dependentVariableIndex=0;dependentVariableIndex<dependentVariablesCount;dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        PSPlotSetViewNeedsRegenerated(PSDependentVariableGetPlot(theDependentVariable), true);
    }
}

void PSSDatasetSwapDepthAndHorizontalDimensionPrecedence(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    if(CFArrayGetCount(theDataset->dimensionPrecedence) < 3) return;
    CFIndex depthDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 2);
    CFIndex horizontalDimensionIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 0);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 2, (void *) horizontalDimensionIndex);
    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, 0, (void *) depthDimensionIndex);
    
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dependentVariableIndex=0;dependentVariableIndex<dependentVariablesCount;dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        PSPlotSetViewNeedsRegenerated(PSDependentVariableGetPlot(theDependentVariable), true);
    }
}

PSDimensionRef PSDatasetHorizontalDimension(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    
    CFIndex dimIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 0);
    if(dimIndex<PSDatasetDimensionsCount(theDataset))
        return PSDatasetGetDimensionAtIndex(theDataset,dimIndex);
    return NULL;
}

PSDimensionRef PSDatasetVerticalDimension(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    
    if(PSDatasetDimensionsCount(theDataset)>1) {
        CFIndex dimIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 1);
        if(dimIndex<PSDatasetDimensionsCount(theDataset))
            return PSDatasetGetDimensionAtIndex(theDataset,dimIndex);
    }
    return NULL;
}

PSDimensionRef PSDatasetDepthDimension(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    
    if(PSDatasetDimensionsCount(theDataset)>2) {
        CFIndex dimIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 2);
        if(dimIndex<PSDatasetDimensionsCount(theDataset))
            return PSDatasetGetDimensionAtIndex(theDataset,dimIndex);
    }
    return NULL;
}

CFMutableArrayRef PSDatasetDimensionsMutableCopy(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFMutableArrayRef dimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, theDataset->dimensions);
    
    for(CFIndex index=0;index<CFArrayGetCount(dimensions); index++) {
        PSDimensionRef dimension = (PSDimensionRef) PSDimensionCreateCopy((PSDimensionRef) CFArrayGetValueAtIndex(dimensions, index));
        CFArraySetValueAtIndex(dimensions, index, dimension);
        CFRelease(dimension);
    }
    return dimensions;
}


PSScalarRef PSDatasetCreateResponseFromMemOffset(PSDatasetRef theDataset,
                                                 CFIndex dependentVariableIndex,
                                                 CFIndex componentIndex,
                                                 CFIndex memOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDependentVariableRef theDependentVariable = CFArrayGetValueAtIndex(theDataset->dependentVariables, dependentVariableIndex);
    return PSDependentVariableCreateValueFromMemOffset(theDependentVariable, componentIndex, memOffset);
}

PSScalarRef PSDatasetCreateResponseFromCoordinateIndexes(PSDatasetRef theDataset,
                                                         CFIndex dependentVariableIndex,
                                                         CFIndex componentIndex,
                                                         PSIndexArrayRef theIndexes)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDataset->dimensions, theIndexes);
    return PSDatasetCreateResponseFromMemOffset(theDataset,
                                                dependentVariableIndex,
                                                componentIndex,
                                                memOffset);
    
}

PSScalarRef PSDatasetCreateResponseFromDimensionlessCoordinates(PSDatasetRef theDataset,
                                                                CFIndex dependentVariableIndex,
                                                                CFIndex componentIndex,
                                                                CFArrayRef theCoordinates,
                                                                CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFIndex memOffset = PSDimensionMemOffsetFromDimensionlessCoordinates(theDataset->dimensions, theCoordinates, error);
    return PSDatasetCreateResponseFromMemOffset(theDataset,
                                                dependentVariableIndex,
                                                componentIndex,
                                                memOffset);
}

PSScalarRef PSDatasetCreateResponseFromRelativeCoordinates(PSDatasetRef theDataset,
                                                           CFIndex dependentVariableIndex,
                                                           CFIndex componentIndex,
                                                           CFArrayRef theCoordinates,
                                                           CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex memOffset = PSDimensionMemOffsetFromRelativeCoordinates(theDataset->dimensions, theCoordinates, error);
    return PSDatasetCreateResponseFromMemOffset(theDataset,
                                                dependentVariableIndex,
                                                componentIndex,
                                                memOffset);
}

PSScalarRef PSDatasetCreateResponseFromDisplayedCoordinates(PSDatasetRef theDataset,
                                                            CFIndex dependentVariableIndex,
                                                            CFIndex componentIndex,
                                                            CFArrayRef theCoordinates,
                                                            CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex memOffset = PSDimensionMemOffsetFromDisplayedCoordinates(theDataset->dimensions, theCoordinates);
    return PSDatasetCreateResponseFromMemOffset(theDataset,
                                                dependentVariableIndex,
                                                componentIndex,
                                                memOffset);
}

PSScalarRef PSDatasetCreateResponseFromMemOffsetForPart(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset,
                                                        complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSScalarRef temp = PSDatasetCreateResponseFromMemOffset(theDataset,
                                                            dependentVariableIndex,
                                                            componentIndex,
                                                            memOffset);
    PSScalarRef result = PSScalarCreateByTakingComplexPart(temp, part);
    CFRelease(temp);
    return result;
}

double PSDatasetResponseDoubleValueWithMemOffsetForPart(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset,
                                                        complexPart part)
{
    PSScalarRef response = PSDatasetCreateResponseFromMemOffsetForPart(theDataset,
                                                                       dependentVariableIndex,
                                                                       componentIndex,
                                                                       memOffset,
                                                                       part);
    if(response==NULL) return nan(NULL);
    double value = PSScalarDoubleValue(response);
    CFRelease(response);
    return value;
}

PSScalarRef PSDatasetCreateResponseFromCoordinateIndexesForPart(PSDatasetRef theDataset,
                                                                CFIndex dependentVariableIndex,
                                                                CFIndex componentIndex,
                                                                PSIndexArrayRef theIndexes,
                                                                complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDataset->dimensions, theIndexes);
    return PSDatasetCreateResponseFromMemOffsetForPart(theDataset,
                                                       dependentVariableIndex,
                                                       componentIndex,
                                                       memOffset,
                                                       part);
}

PSScalarRef PSDatasetCreateResponseFromDimensionlessCoordinatesForPart(PSDatasetRef theDataset,
                                                                       CFIndex dependentVariableIndex,
                                                                       CFIndex componentIndex,
                                                                       CFArrayRef theCoordinates,
                                                                       complexPart part,
                                                                       CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    // WARNING ** ignores signalCoordinates
    CFIndex memOffset = PSDimensionMemOffsetFromDimensionlessCoordinates(theDataset->dimensions, theCoordinates, error);
    
    return PSDatasetCreateResponseFromMemOffsetForPart(theDataset,
                                                       dependentVariableIndex,
                                                       componentIndex,
                                                       memOffset,
                                                       part);
}

PSScalarRef PSDatasetCreateResponseFromRelativeCoordinatesForPart(PSDatasetRef theDataset,
                                                                  CFIndex dependentVariableIndex,
                                                                  CFIndex componentIndex,
                                                                  CFArrayRef theCoordinates,
                                                                  complexPart part,
                                                                  CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    // WARNING ** ignores signalCoordinates
    CFIndex memOffset = PSDimensionMemOffsetFromRelativeCoordinates(theDataset->dimensions, theCoordinates, error);
    return PSDatasetCreateResponseFromMemOffsetForPart(theDataset,
                                                       dependentVariableIndex,
                                                       componentIndex,
                                                       memOffset,
                                                       part);
}

PSScalarRef PSDatasetCreateResponseFromDisplayedCoordinatesForPart(PSDatasetRef theDataset,
                                                                   CFIndex dependentVariableIndex,
                                                                   CFIndex componentIndex,
                                                                   CFArrayRef theCoordinates,
                                                                   complexPart part,
                                                                   CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    // WARNING ** ignores signalCoordinates
    CFIndex memOffset = PSDimensionMemOffsetFromDisplayedCoordinates(theDataset->dimensions, theCoordinates);
    if(error) if(*error) return NULL;
    return PSDatasetCreateResponseFromMemOffsetForPart(theDataset,
                                                       dependentVariableIndex,
                                                       componentIndex,
                                                       memOffset,
                                                       part);
}

PSDatumRef PSDatasetCreateDatumFromMemOffset(PSDatasetRef theDataset,
                                             CFIndex dependentVariableIndex,
                                             CFIndex componentIndex,
                                             CFIndex memOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    PSDependentVariableRef theDV = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSScalarRef response = PSDependentVariableCreateValueFromMemOffset(theDV, componentIndex, memOffset);

    if(PSDatasetDimensionsCount(theDataset)>0) {
        CFArrayRef coordinateValues = PSDimensionCreateDisplayedCoordinatesFromMemOffset(theDataset->dimensions,  memOffset);
        PSDatumRef datum = PSDatumCreate(response, coordinateValues, dependentVariableIndex, componentIndex, memOffset);
        if(coordinateValues) CFRelease(coordinateValues);
        if(response) CFRelease(response);
        return datum;
    }
    
    PSDatumRef datum = PSDatumCreate(response, NULL, dependentVariableIndex, componentIndex, memOffset);
    if(response) CFRelease(response);
    return datum;
}

PSDatumRef PSDatasetCreateDatumFromCoordinateIndexes(PSDatasetRef theDataset,
                                                     CFIndex dependentVariableIndex,
                                                     CFIndex componentIndex,
                                                     PSIndexArrayRef theIndexes,
                                                     CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDataset->dimensions, theIndexes);
    
    return PSDatasetCreateDatumFromMemOffset(theDataset, dependentVariableIndex, componentIndex, memOffset);
}

PSDatumRef PSDatasetCreateDatumFromDisplayedCoordinates(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFIndex componentIndex,
                                                        CFArrayRef theCoordinates)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex memOffset = PSDimensionMemOffsetFromDisplayedCoordinates(theDataset->dimensions, theCoordinates);
    return PSDatasetCreateDatumFromMemOffset(theDataset, dependentVariableIndex, componentIndex, memOffset);
}


bool PSDatasetSetCrossSection(PSDatasetRef theDataset,
                              PSIndexPairSetRef indexPairs,
                              PSDatasetRef crossSection,
                              CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    for(CFIndex dvIndex=0; dvIndex<CFArrayGetCount(theDataset->dependentVariables); dvIndex++) {
        PSDependentVariableRef theDependentVariable = (PSDependentVariableRef) CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
        PSDependentVariableRef theCrossSectionSignal = (PSDependentVariableRef) CFArrayGetValueAtIndex(crossSection->dependentVariables, dvIndex);
        PSDependentVariableSetCrossSection(theDependentVariable,
                                           theDataset->dimensions,
                                           indexPairs,
                                           theCrossSectionSignal,
                                           crossSection->dimensions);
        if(error) if(*error) return false;
    }
    return true;
}


bool PSDatasetReplaceHorizontalDimensionWithDimension(PSDatasetRef theDataset, PSDimensionRef theDim, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    
    CFIndex dimIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 0);
    return PSDatasetReplaceDimensionAtIndex(theDataset, dimIndex, theDim, error);
}

bool PSDatasetReplaceVerticalDimensionWithDimension(PSDatasetRef theDataset, PSDimensionRef theDim, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    
    CFIndex dimIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 1);
    return PSDatasetReplaceDimensionAtIndex(theDataset, dimIndex, theDim, error);
}

bool PSDatasetReplaceDepthDimensionWithDimension(PSDatasetRef theDataset, PSDimensionRef theDim, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
    
    CFIndex dimIndex = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, 2);
    return PSDatasetReplaceDimensionAtIndex(theDataset, dimIndex, theDim, error);
}


#pragma mark Strings and Archiving
//
//static void  cswap(float complex *v1, float complex *v2)
//{
//   float complex tmp = *v1;
//   *v1 = *v2;
//   *v2 = tmp;
//}
//
//static void  zswap(double complex *v1, double complex *v2)
//{
//   double complex tmp = *v1;
//   *v1 = *v2;
//   *v2 = tmp;
//}
//
//static void cfftshift(float complex *data, CFIndex count)
//{
//    CFIndex c = (CFIndex) floor((float)count/2);
//    // For odd and for even numbers of element use different algorithm
//    if (count % 2 == 0) {
//        for (CFIndex k = 0; k < c; k++)
//            cswap(&data[k], &data[k+c]);
//    }
//    else {
//        float complex tmp = data[0];
//        for (CFIndex k = 0; k < c; k++) {
//            data[k] = data[c + k + 1];
//            data[c + k + 1] = data[k + 1];
//        }
//        data[c] = tmp;
//    }
//}
//
//static void icfftshift(float complex *data, CFIndex count)
//{
//    CFIndex c = (CFIndex) floor((float)count/2);
//    if (count % 2 == 0) {
//        for (CFIndex k = 0; k < c; k++)
//            cswap(&data[k], &data[k+c]);
//    }
//    else {
//        float complex tmp = data[count - 1];
//        for (CFIndex k = c-1; k >= 0; k--) {
//            data[c + k + 1] = data[k];
//            data[k] = data[c + k];
//        }
//        data[c] = tmp;
//    }
//}
//
//static void zfftshift(double complex *data, CFIndex count)
//{
//    CFIndex c = (CFIndex) floor((float)count/2);
//    // For odd and for even numbers of element use different algorithm
//    if (count % 2 == 0) {
//        for (CFIndex k = 0; k < c; k++)
//            zswap(&data[k], &data[k+c]);
//    }
//    else {
//        double complex tmp = data[0];
//        for (CFIndex k = 0; k < c; k++) {
//            data[k] = data[c + k + 1];
//            data[c + k + 1] = data[k + 1];
//        }
//        data[c] = tmp;
//    }
//}
//
//static void izfftshift(double complex *data, CFIndex count)
//{
//    CFIndex c = (CFIndex) floor((float)count/2);
//    if (count % 2 == 0) {
//        for (CFIndex k = 0; k < c; k++)
//            zswap(&data[k], &data[k+c]);
//    }
//    else {
//        double complex tmp = data[count - 1];
//        for (CFIndex k = c-1; k >= 0; k--) {
//            data[c + k + 1] = data[k];
//            data[k] = data[c + k];
//        }
//        data[c] = tmp;
//    }
//}
//
//void PSDatasetFourierTransformShiftAlongHorizontalDimension(PSDatasetRef input)
//{
//    IF_NO_OBJECT_EXISTS_RETURN(input,);
//    CFIndex dimensionsCount = PSDatasetDimensionsCount(input);
//    if(dimensionsCount<1) return;
//    if(dimensionsCount<1) return;
//
//    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(input);
//
//    CFIndex size = PSDimensionCalculateSizeFromDimensions(PSDatasetGetDimensions(input));
//    CFIndex reducedSize = size/PSDimensionGetNpts(horizontalDimension);
//    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(input);
//    CFIndex *npts = calloc(sizeof(CFIndex), dimensionsCount);
//    bool *fft = calloc(sizeof(bool), dimensionsCount);
//    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
//        PSDimensionRef theDimension = PSDatasetGetDimensionAtIndex(input, idim);
//        npts[idim] = PSDimensionGetNpts(theDimension);
//        fft[idim] = PSDimensionGetFFT(theDimension);
//    }
//    vDSP_Length length = npts[horizontalDimensionIndex];
//    vDSP_Stride stride = strideAlongDimensionIndex(npts, dimensionsCount, horizontalDimensionIndex);
//
//    CFIndex dvCount = PSDatasetDependentVariablesCount(input);
//    double inverseIncrementValue = PSScalarDoubleValueInCoherentUnit(PSDimensionGetInverseIncrement(horizontalDimension));
//    double incrementValue = PSScalarDoubleValueInCoherentUnit(PSDimensionGetIncrement(horizontalDimension));
//    float complex *floatArray = NULL;
//    double complex *doubleArray = NULL;
//    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
//        PSDependentVariableRef theDV = PSDatasetGetDependentVariableAtIndex(input, dvIndex);
//        CFIndex componentsCount = PSDependentVariableComponentsCount(theDV);
//        numberType elementType = PSQuantityGetElementType(theDV);
//        if(elementType==kPSNumberFloat32ComplexType) {
//            if(floatArray == NULL) floatArray = (float complex*) malloc(sizeof(float complex) * length);
//            for(CFIndex cIndex=0; cIndex<componentsCount; cIndex++) {
//                CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theDV, cIndex);
//                float complex *responses = (float complex *) CFDataGetMutableBytePtr(values);
//                for(size_t reducedMemOffset=0;reducedMemOffset<reducedSize; reducedMemOffset++) {
//                    CFIndex indexes[dimensionsCount];
//                    indexes[horizontalDimensionIndex] = 0;
//                    setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes, dimensionsCount, npts, horizontalDimensionIndex);
//                    CFIndex memOffset = memOffsetFromIndexes(indexes,  dimensionsCount, npts);
//                    cblas_ccopy((int) length, &responses[memOffset], (int) stride, floatArray, 1);
//                    icfftshift(floatArray,length);
//                    cblas_ccopy((int) length, floatArray, 1, &responses[memOffset], (int) stride);
//                }
//            }
//        }
//        else {
//            if(doubleArray == NULL) doubleArray = (double complex*) malloc(sizeof(double complex) * length);
//            for(CFIndex cIndex=0; cIndex<componentsCount; cIndex++) {
//                CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theDV, cIndex);
//                double complex *responses = (double complex *) CFDataGetMutableBytePtr(values);
//                for(size_t reducedMemOffset=0;reducedMemOffset<reducedSize; reducedMemOffset++) {
//                    CFIndex indexes[dimensionsCount];
//                    indexes[horizontalDimensionIndex] = 0;
//                    setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes,  dimensionsCount, npts, horizontalDimensionIndex);
//                    CFIndex memOffset = memOffsetFromIndexes(indexes,  dimensionsCount, npts);
//                    cblas_zcopy((int) length, &responses[memOffset], (int) stride, doubleArray, 1);
//                    izfftshift(doubleArray,length);
//                    cblas_zdscal((int) length, incrementValue, doubleArray,1);
//                    cblas_zcopy((int) length, doubleArray, 1,&responses[memOffset], (int) stride);
//                }
//            }
//        }
//    }
//    FREE(fft);
//    FREE(npts);
//    if(floatArray) free(floatArray);
//    if(doubleArray) free(doubleArray);
//
//    return;
//}

void PSDatasetConvertToCSDM(PSDatasetRef theDataset)
{
    CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensions);
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);

    for(CFIndex dimIndex = 0; dimIndex<dimensionsCount;dimIndex++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(theDataset->dimensions, dimIndex);
        if(PSDimensionGetFFT(theDimension)) {
            CFIndex npts = PSDimensionGetNpts(theDimension);
            CFIndex T = npts*(npts%2==0) + (npts-1)*(npts%2!=0);
            for(CFIndex dvIndex=0;dvIndex<dvCount;dvIndex++) {
                PSDependentVariableRef theDV = CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
                PSDependentVariableShiftAlongDimension(theDV, theDataset->dimensions, dimIndex, -T/2, true, 0);
            }
            for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
                PSDependentVariableRef theDV = CFArrayGetValueAtIndex(theDataset->dependentVariables, dvIndex);
                PSPlotRef thePlot = PSDependentVariableGetPlot(theDV);
                PSAxisRef theAxis = PSPlotAxisAtIndex(thePlot,dimIndex);
                PSAxisSetBipolar(theAxis, false);
                PSAxisSetReverse(theAxis, true);
            }

        }
    }
}

bool PSDatasetGetBase64(PSDatasetRef theDataset)
{
    return theDataset->base64;
}

CFArrayRef PSDatasetCreateCSDMComponentsData(PSDatasetRef theDataset)
{
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, dependentVariablesCount, &kCFTypeArrayCallBacks);
    for(CFIndex dependentVariableIndex =0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = CFArrayGetValueAtIndex(theDataset->dependentVariables, dependentVariableIndex);
        CFDataRef data = PSDependentVariableCreateCSDMComponentsData(theDependentVariable);
        CFArrayAppendValue(array, data);
        CFRelease(data);
    }
    return array;
}

CFDictionaryRef PSDatasetCreateCSDMPList(PSDatasetRef theDataset,
                                         bool readOnly,
                                         bool base64Encoding,
                                         bool external,
                                         PSScalarRef latitude, PSScalarRef longitude, PSScalarRef altitude)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef rootDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    
    CFMutableDictionaryRef csdmDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(rootDictionary, CFSTR("csdm"),csdmDictionary);
    CFRelease(csdmDictionary);
    
    CFDictionarySetValue(csdmDictionary, CFSTR("version"),CFSTR("1.0"));
    
    if(theDataset->description && CFStringGetLength(theDataset->description)>0)
        CFDictionarySetValue(csdmDictionary, CFSTR("description"),theDataset->description);
    
    if(readOnly) {
        CFDictionarySetValue(csdmDictionary, CFSTR("read_only"),kCFBooleanTrue);
    }
    if(theDataset->tags) {
        CFIndex tagsCount = CFArrayGetCount(theDataset->tags);
        if(tagsCount) {
            CFMutableArrayRef csdmTags = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFDictionarySetValue(csdmDictionary, CFSTR("tags"),csdmTags);
            CFRelease(csdmTags);
            
            for(CFIndex tagIndex=0;tagIndex<tagsCount;tagIndex++) {
                CFStringRef tag = CFArrayGetValueAtIndex(theDataset->tags, tagIndex);
                CFArrayAppendValue(csdmTags, tag);
            }
        }
    }
    
    if(theDataset->dependentVariables) {
        CFIndex dependentVariablesCount = CFArrayGetCount(theDataset->dependentVariables);
        if(dependentVariablesCount) {
            CFMutableArrayRef csdmDependentVariables = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFDictionarySetValue(csdmDictionary, CFSTR("dependent_variables"),csdmDependentVariables);
            CFRelease(csdmDependentVariables);
            
            for(CFIndex dependentVariableIndex=0;dependentVariableIndex<dependentVariablesCount;dependentVariableIndex++) {
                PSDependentVariableRef theDependentVariable = CFArrayGetValueAtIndex(theDataset->dependentVariables, dependentVariableIndex);
                
                CFDictionaryRef csdmDependentVariableDictionary = PSDependentVariableCreateCSDMPList(theDependentVariable,
                                                                                                     theDataset->dimensions,
                                                                                                     external,
                                                                                                     base64Encoding);
                CFArrayAppendValue(csdmDependentVariables, csdmDependentVariableDictionary);
                CFRelease(csdmDependentVariableDictionary);
            }
        }
    }
    
    if(theDataset->dimensions) {
        CFIndex dimensionsCount = CFArrayGetCount(theDataset->dimensions);
        if(dimensionsCount) {
            CFMutableArrayRef csdmDimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFDictionarySetValue(csdmDictionary, CFSTR("dimensions"),csdmDimensions);
            CFRelease(csdmDimensions);
            for(CFIndex dimensionIndex=0;dimensionIndex<dimensionsCount;dimensionIndex++) {
                PSDimensionRef theDimension = CFArrayGetValueAtIndex(theDataset->dimensions, dimensionIndex);
                CFDictionaryRef csdmDimensionDictionary = PSDimensionCreateCSDMPList(theDimension);
                CFArrayAppendValue(csdmDimensions, csdmDimensionDictionary);
                CFRelease(csdmDimensionDictionary);
            }
        }
    }
    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    CFDictionarySetValue(csdmDictionary, CFSTR("timestamp"),timestamp);
    
    if(latitude!=NULL && longitude != NULL) {
        
        CFMutableDictionaryRef geographic_coordinate = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFStringRef latitudeString = PSScalarCreateStringValue(latitude);
        CFDictionarySetValue(geographic_coordinate, CFSTR("latitude"),latitudeString);
        CFRelease(latitudeString);
        
        CFStringRef longitudeString = PSScalarCreateStringValue(longitude);
        CFDictionarySetValue(geographic_coordinate, CFSTR("longitude"),longitudeString);
        CFRelease(longitudeString);
        
        if(altitude) {
            CFStringRef altitudeString = PSScalarCreateStringValue(altitude);
            CFDictionarySetValue(geographic_coordinate, CFSTR("altitude"),altitudeString);
            CFRelease(altitudeString);
        }
        
        CFDictionarySetValue(csdmDictionary, CFSTR("geographic_coordinate"),geographic_coordinate);
        CFRelease(geographic_coordinate);
    }
    
    CFMutableDictionaryRef RMNDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    {
        if(NULL == theDataset->dimensionPrecedence) PSDatasetResetDimensionPrecedence(theDataset);
        if(theDataset->dimensionPrecedence) {
            CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
            if(dimensionsCount) {
                CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
                for(CFIndex dimIndex=0;dimIndex<CFArrayGetCount(theDataset->dimensionPrecedence); dimIndex++) {
                    CFIndex index = (CFIndex) CFArrayGetValueAtIndex(theDataset->dimensionPrecedence, dimIndex);
                    CFNumberRef number = PSCFNumberCreateWithCFIndex(index);
                    CFArrayAppendValue(array, number);
                    CFRelease(number);
                }
                CFDictionarySetValue(RMNDictionary, CFSTR("dimension_precedence"),array);
                CFRelease(array);
            }
        }
        
        if(theDataset->focus) {
            CFDictionaryRef plist = PSDatumCreatePList(theDataset->focus);
            CFDictionarySetValue(RMNDictionary, CFSTR("focus"),plist);
            CFRelease(plist);
        }
        
        if(theDataset->previousFocus) {
            CFDictionaryRef plist = PSDatumCreatePList(theDataset->previousFocus);
            CFDictionarySetValue(RMNDictionary, CFSTR("previous_focus"),plist);
            CFRelease(plist);
        }
        
        if(theDataset->operations) {
            if(CFDictionaryGetCount(theDataset->operations)) {
                CFDictionaryRef operationsPropertyList = PSCFDictionaryCreatePListCompatible(theDataset->operations);
                CFDictionarySetValue(RMNDictionary, CFSTR("operations"),operationsPropertyList);
                CFRelease(operationsPropertyList);
            }
        }
        
        if(theDataset->metaData) {
            if(CFDictionaryGetCount(theDataset->metaData)) {
                CFDictionaryRef metaDataPropertyList = PSCFDictionaryCreatePListCompatible(theDataset->metaData);
                CFDictionarySetValue(RMNDictionary, CFSTR("metaData"),metaDataPropertyList);
                CFRelease(metaDataPropertyList);
            }
        }
    }
    
    if(CFDictionaryGetCount(RMNDictionary)) {
        CFMutableDictionaryRef applicationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(csdmDictionary, CFSTR("application"),applicationDictionary);
        CFRelease(applicationDictionary);
        CFDictionaryAddValue(applicationDictionary, CFSTR("com.physyapps.rmn"), RMNDictionary);
    }
    CFRelease(RMNDictionary);
    
    return rootDictionary;
}

PSDatasetRef PSDatasetCreateWithCSDMPList(CFDictionaryRef dictionary, CFArrayRef folderContents, bool *readOnly, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dictionary,NULL);
    
    if(!CFDictionaryContainsKey(dictionary, CFSTR("csdm"))) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot open CSDM file."), CFSTR("No CSDM object found."), NULL);
        return NULL;
    }
    
    CFDictionaryRef csdm = CFDictionaryGetValue(dictionary, CFSTR("csdm"));
    if(CFGetTypeID(csdm)!=CFDictionaryGetTypeID()) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot open CSDM file."), CFSTR("CSDM value is not dictionary."), NULL);
        return NULL;
    }
    
    if(!CFDictionaryContainsKey(csdm, CFSTR("version"))) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot open CSDM file."), CFSTR("No version key found."), NULL);
        return NULL;}
    CFStringRef version = CFDictionaryGetValue(csdm, CFSTR("version"));
    
    if(CFGetTypeID(version)!=CFStringGetTypeID()) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot open CSDM file."), CFSTR("version value is not string."), NULL);
        return NULL;
    }
    
    if(CFStringCompare(version, CFSTR("1.0"), 0)!=kCFCompareEqualTo) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot open CSDM file."), CFSTR("unknown CSDM version."), NULL);
        return NULL;}
    
    CFBooleanRef read_only = kCFBooleanFalse;
    if(CFDictionaryContainsKey(csdm, CFSTR("read_only")))
        read_only = CFDictionaryGetValue(csdm, CFSTR("read_only"));
    if(read_only==NULL) read_only = kCFBooleanFalse;

    if(CFGetTypeID(read_only)!=CFBooleanGetTypeID()) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot open CSDM file."), CFSTR("read_only value is not boolean."), NULL);
        return NULL;
    }
    *readOnly = CFBooleanGetValue(read_only);

    
    PSDatasetRef theDataset = PSDatasetCreateDefault();
    
    theDataset->description = CFSTR("");
    if(CFDictionaryContainsKey(csdm, CFSTR("description")))
        PSDatasetSetDescription(theDataset, CFDictionaryGetValue(csdm, CFSTR("description")));
    
    if(CFDictionaryContainsKey(csdm, CFSTR("tags")))
        PSDatasetSetTags(theDataset, CFDictionaryGetValue(csdm, CFSTR("tags")));

    CFArrayRef csdmDimensions = NULL;
    if(CFDictionaryContainsKey(csdm, CFSTR("dimensions"))) csdmDimensions = CFDictionaryGetValue(csdm, CFSTR("dimensions"));
    CFIndex dimensionsCount = 0;
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, dimensionsCount, &kCFTypeArrayCallBacks);
    if(csdmDimensions) {
        dimensionsCount = CFArrayGetCount(csdmDimensions);
        for(CFIndex index = 0; index<dimensionsCount;index++) {
            CFDictionaryRef csdmDimension = CFArrayGetValueAtIndex(csdmDimensions, index);
            PSDimensionRef dimension = PSDimensionCreateWithCSDMPList(csdmDimension, error);
            if(NULL==dimension) {
                CFRelease(dimensions);
                CFRelease(theDataset);
                return NULL;
            }
            CFArrayAppendValue(dimensions, dimension);
            CFRelease(dimension);
        }
        PSDatasetSetDimensions(theDataset, dimensions, NULL);
    }
    CFRelease(dimensions);

    CFArrayRef csdmDependentVariables = NULL;
    if(CFDictionaryContainsKey(csdm, CFSTR("dependent_variables"))) csdmDependentVariables = CFDictionaryGetValue(csdm, CFSTR("dependent_variables"));
    CFIndex dvCount = 0;
    if(csdmDependentVariables) {
        dvCount = CFArrayGetCount(csdmDependentVariables);
        for(CFIndex dvIndex = 0; dvIndex<dvCount;dvIndex++) {
            CFDictionaryRef csdmDV = CFArrayGetValueAtIndex(csdmDependentVariables, dvIndex);
            PSDependentVariableRef dV = PSDependentVariableCreateWithCSDMPList(csdmDV, theDataset->dimensions, folderContents, theDataset, error);
            
            if(NULL==dV) {
                CFRelease(theDataset);
                return NULL;
            }

            PSDatasetAppendDependentVariable(theDataset, dV, error);
            CFRelease(dV);
            if(error&&*error) {
                CFRelease(theDataset);
                return NULL;
            }

            dV =  PSDatasetGetDependentVariableAtIndex(theDataset, dvIndex);
            PSPlotRef thePlot = PSDependentVariableGetPlot(dV); // If plot==NULL, then this will instantiate default plot
            
            if(dimensionsCount>1) {
                if(PSDimensionHasNonUniformGrid(PSDatasetHorizontalDimension(theDataset)) || PSDimensionHasNonUniformGrid(PSDatasetVerticalDimension(theDataset))) PSPlotSetDimensionsCountDisplayed(thePlot, 1);
            }
            
        }
    }
    
    if(CFDictionaryContainsKey(csdm, CFSTR("application"))) {
        CFDictionaryRef application = CFDictionaryGetValue(csdm, CFSTR("application"));
        
        if(CFDictionaryContainsKey(application, CFSTR("com.physyapps.rmn"))) {
            CFDictionaryRef RMNDictionary = CFDictionaryGetValue(application, CFSTR("com.physyapps.rmn"));
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("dimension_precedence"))) {
                CFArrayRef array = CFDictionaryGetValue(RMNDictionary, CFSTR("dimension_precedence"));
                CFIndex count = CFArrayGetCount(array);
                for(CFIndex index=0; index<count; index++) {
                    CFNumberRef number = CFArrayGetValueAtIndex(array, index);
                    CFIndex dimensionIndex;
                    CFNumberGetValue(number,kCFNumberCFIndexType, &dimensionIndex);
                    CFArraySetValueAtIndex(theDataset->dimensionPrecedence, index, (void *) dimensionIndex);
                }
            }
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("focus"))) {
                PSDatumRef focus = PSDatumCreateWithPList(CFDictionaryGetValue(RMNDictionary, CFSTR("focus")),error);
                if(focus) {
                    PSDatasetSetFocus(theDataset, focus);
                    CFRelease(focus);
                }
            }
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("previous_focus"))) {
                PSDatumRef previousFocus = PSDatumCreateWithPList(CFDictionaryGetValue(RMNDictionary, CFSTR("previous_focus")),error);
                PSDatasetSetPreviousFocus(theDataset, previousFocus);
                CFRelease(previousFocus);
            }
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("operations"))) {
                CFDictionaryRef operations = PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryGetValue(RMNDictionary, CFSTR("operations")),error);
                PSDatasetSetOperations(theDataset,operations);
                 CFRelease(operations);
            }
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("metaData"))) {
                 CFDictionaryRef metaData = PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryGetValue(RMNDictionary, CFSTR("metaData")),error);
                PSDatasetSetMetaData(theDataset, metaData);
                CFRelease(metaData);
            }
        }
    }
    
//    if(dimensionsCount>1) {
//        CFIndex memOffset = PSDatumGetMemOffset(theDataset->focus);
//        PSIndexArrayRef focusIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
//
//        if(focusIndexValues) {
//            PSDatasetResetFocusCrossSections(theDataset, focusIndexValues, error);
//            CFRelease(focusIndexValues);
//        }
//    }
//
    
    return theDataset;
}



PSDatasetRef PSDatasetCreateWithOldDataFormat(CFDataRef data, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(data,NULL);
    
    CFPropertyListFormat format;
    CFDictionaryRef dictionary  = CFPropertyListCreateWithData (kCFAllocatorDefault,data,kCFPropertyListImmutable,&format,error);
    if(dictionary==NULL) return NULL;
    
    PSDatasetRef theDataset = PSDatasetCreateDefault();
    if(theDataset==NULL) {
        CFRelease(dictionary);
        return NULL;
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("dimensions"))) {
        CFArrayRef array = CFDictionaryGetValue(dictionary, CFSTR("dimensions"));
        CFIndex count = CFArrayGetCount(array);
        for(CFIndex index=0; index<count; index++) {
            PSDimensionRef dimension = PSDimensionCreateWithData(CFArrayGetValueAtIndex(array, index),error);
            if(error) {
                if(*error) {
                    CFRelease(dictionary);
                    CFRelease(theDataset);
                    return NULL;
                }
            }
            CFArrayAppendValue(theDataset->dimensions, dimension);
            CFRelease(dimension);
        }
    }
    if(CFDictionaryContainsKey(dictionary, CFSTR("dimensionPrecedence"))) {
        CFArrayRef array = CFDictionaryGetValue(dictionary, CFSTR("dimensionPrecedence"));
        CFIndex count = CFArrayGetCount(array);
        for(CFIndex index=0; index<count; index++) {
            CFNumberRef number = CFArrayGetValueAtIndex(array, index);
            CFIndex dimensionIndex;
            CFNumberGetValue(number,kCFNumberCFIndexType, &dimensionIndex);
            CFArrayAppendValue(theDataset->dimensionPrecedence, (void *) dimensionIndex);
        }
    }
    else PSDatasetResetDimensionPrecedence(theDataset);
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("title")))
        PSDatasetSetTitle(theDataset,CFDictionaryGetValue(dictionary, CFSTR("title")));
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("operations"))) {
        CFMutableDictionaryRef operations = PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryGetValue(dictionary, CFSTR("operations")),error);
        PSDatasetSetOperations(theDataset,operations);
        CFRelease(operations);
    }
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("metaData"))) {
        CFMutableDictionaryRef metaData = PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryGetValue(dictionary, CFSTR("metaData")),error);
        PSDatasetSetMetaData(theDataset, metaData);
        CFRelease(metaData);
    }
    
    CFStringRef quantityName = kPSQuantityDimensionless;
    if(CFDictionaryContainsKey(dictionary, CFSTR("responseQuantity")))
        quantityName = CFDictionaryGetValue(dictionary, CFSTR("responseQuantity"));
    
    CFStringRef variableName = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("responseName")))
        variableName = CFDictionaryGetValue(dictionary, CFSTR("responseName"));
    else if(CFDictionaryContainsKey(dictionary, CFSTR("responseLabel")))
        variableName = CFDictionaryGetValue(dictionary, CFSTR("responseLabel"));
    CFStringRef description = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("description")))
        description = CFDictionaryGetValue(dictionary, CFSTR("description"));
    
    CFMutableArrayRef components = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFMutableArrayRef componentLabels = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    numberType elementType = 0;
    PSUnitRef unit = PSUnitDimensionlessAndUnderived();
    if(CFDictionaryContainsKey(dictionary, CFSTR("signals"))) {
        CFArrayRef signals = CFDictionaryGetValue(dictionary, CFSTR("signals"));
        for(CFIndex componentIndex = 0; componentIndex<CFArrayGetCount(signals); componentIndex++) {
            CFDataRef signalDictionaryData = CFArrayGetValueAtIndex(signals, componentIndex);
            CFPropertyListFormat format;
            CFDictionaryRef signalDictionary  = CFPropertyListCreateWithData (kCFAllocatorDefault,signalDictionaryData,kCFPropertyListImmutable,&format,error);
            if(CFDictionaryContainsKey(signalDictionary, CFSTR("elementType")))
                CFNumberGetValue(CFDictionaryGetValue(signalDictionary, CFSTR("elementType")),kCFNumberIntType,&elementType);
            if(CFDictionaryContainsKey(signalDictionary, CFSTR("unit"))) {
                unit = PSUnitWithData(CFDictionaryGetValue(signalDictionary, CFSTR("unit")), error);
            }
            CFStringRef componentName = NULL;
            if(CFDictionaryContainsKey(signalDictionary, CFSTR("name")))
                componentName = CFDictionaryGetValue(signalDictionary, CFSTR("name"));
            else if(CFDictionaryContainsKey(signalDictionary, CFSTR("label")))
                componentName = CFDictionaryGetValue(signalDictionary, CFSTR("label"));
            else  componentName = CFSTR("");
            CFDataRef componentValues = NULL;
            if(CFDictionaryContainsKey(signalDictionary, CFSTR("values")))
                componentValues = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, CFDictionaryGetValue(signalDictionary, CFSTR("values")));
            
            CFArrayAppendValue(componentLabels, componentName);
            CFArrayAppendValue(components, componentValues);
            if(componentValues) CFRelease(componentValues);
            CFRelease(signalDictionary);
        }
    }
    
    PSPlotRef thePlot = NULL;
    CFIndex componentsCount = CFArrayGetCount(components);
    if(CFDictionaryContainsKey(dictionary, CFSTR("plot"))) {
        thePlot = PSPlotCreateWithOldDataFormat(CFDictionaryGetValue(dictionary, CFSTR("plot")),componentsCount, error);
    }
    CFStringRef newType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("vector_%ld"),componentsCount);
    
    PSDependentVariableRef theDependentVariable = PSDependentVariableCreate(variableName,
                                                                            description,
                                                                            unit,
                                                                            quantityName,
                                                                            newType,
                                                                            elementType,
                                                                            componentLabels,
                                                                            components,
                                                                            thePlot,
                                                                            theDataset);
    if(thePlot) CFRelease(thePlot);
    CFRelease(newType);
    PSDatasetAppendDependentVariable(theDataset, theDependentVariable,error);
    
    if(CFDictionaryContainsKey(dictionary, CFSTR("focus")))
        PSDatasetSetFocus(theDataset, PSDatumCreateWithOldDataFormat(CFDictionaryGetValue(dictionary, CFSTR("focus")),error));
    
    theDataset->previousFocus = NULL;
    if(CFDictionaryContainsKey(dictionary, CFSTR("previousFocus")))
        PSDatasetSetPreviousFocus(theDataset, PSDatumCreateWithOldDataFormat(CFDictionaryGetValue(dictionary, CFSTR("previousFocus")),error));
    
    CFRelease(dictionary);
    
    PSDatasetConvertToCSDM(theDataset);

    return theDataset;
}




#pragma mark Dataset Process Operations
PSDatasetRef PSDatasetCreateByMultiplyingDependentVariablesByScalar(PSDatasetRef input, PSScalarRef scalar, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    for(CFIndex dvIndex=0; dvIndex<CFArrayGetCount(output->dependentVariables); dvIndex++) {
        PSDependentVariableMultiplyByScalar(CFArrayGetValueAtIndex(output->dependentVariables, dvIndex), scalar,error);
    }
    return output;
}


PSDatasetRef PSDatasetCreateByConjugating(PSDatasetRef input, CFIndex level, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    CFIndex dependentVariablesCount = CFArrayGetCount(output->dependentVariables);
    
    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = dependentVariablesCount;
    PSDatumRef focus = PSDatasetGetFocus(output);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    
    CFIndex componentIndex = -1;
    if(level>1) componentIndex = PSDatumGetComponentIndex(focus);
    
    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
        PSDependentVariableConjugate(CFArrayGetValueAtIndex(output->dependentVariables, dvIndex), componentIndex);
    }
    
    return output;
}

PSDatasetRef PSDatasetCreateByZeroingPart(PSDatasetRef input, complexPart part, CFIndex level, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    CFIndex dependentVariablesCount = CFArrayGetCount(output->dependentVariables);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(output->dimensions);
    
    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = dependentVariablesCount;
    PSDatumRef focus = PSDatasetGetFocus(output);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    CFIndex componentIndex = -1;
    if(level>1) componentIndex = PSDatumGetComponentIndex(focus);
    
    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
        PSDependentVariableZeroPartInRange(CFArrayGetValueAtIndex(output->dependentVariables, dvIndex), componentIndex,CFRangeMake(0,size),part);
    }
    
    return output;
}



PSDatasetRef PSDatasetCreateByTakingComplexPart(PSDatasetRef input, complexPart part, CFIndex level, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    CFIndex dependentVariablesCount = CFArrayGetCount(output->dependentVariables);
    
    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = dependentVariablesCount;
    PSDatumRef focus = PSDatasetGetFocus(output);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    CFIndex componentIndex = -1;
    if(level>1) componentIndex = PSDatumGetComponentIndex(focus);
    
    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
        PSDependentVariableTakeComplexPart(CFArrayGetValueAtIndex(output->dependentVariables, dvIndex), componentIndex, part);
    }
    return output;
}


PSDatasetRef PSDatasetCreateByShiftingAlongDimension(PSDatasetRef theDataset,
                                                     CFIndex dimensionIndex,
                                                     CFIndex shift,
                                                     bool wrap,
                                                     bool shiftCoord,
                                                     CFIndex level,
                                                     CFErrorRef *error)
{
if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    PSDimensionRef theDimension = (PSDimensionRef) CFArrayGetValueAtIndex(theDataset->dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(theDimension)) return NULL;
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    
    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = CFArrayGetCount(output->dependentVariables);
    PSDatumRef focus = PSDatasetGetFocus(output);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    
    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
        
        PSDependentVariableShiftAlongDimension(CFArrayGetValueAtIndex(output->dependentVariables, dvIndex),
                                               output->dimensions,
                                               dvIndex,
                                               shift,
                                               wrap,
                                               level);
    }
    
    PSDimensionRef newDimension = (PSDimensionRef) CFArrayGetValueAtIndex(output->dimensions, dimensionIndex);
    
    if(shiftCoord) {
        PSScalarRef relativeShift = PSScalarCreateByMultiplyingByDimensionlessRealConstant(PSDimensionGetIncrement(newDimension), shift);
        PSScalarRef newReferenceOffset = PSScalarCreateByAdding(relativeShift, PSDimensionGetReferenceOffset(newDimension), error);
        
        PSDimensionSetReferenceOffset(newDimension, newReferenceOffset);
        CFRelease(newReferenceOffset);
        
        PSScalarRef displayedShift = PSDimensionCreateIncrementInDisplayedCoordinate(theDimension);
        PSScalarMultiplyByDimensionlessRealConstant((PSMutableScalarRef) displayedShift, -shift);
        
        for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
            PSPlotRef thePlot = PSDependentVariableGetPlot(CFArrayGetValueAtIndex(output->dependentVariables, dvIndex));
            PSAxisRef axis = PSPlotAxisAtIndex(thePlot, dimensionIndex);
            PSScalarRef plotMinimum = PSScalarCreateByAdding(displayedShift, PSAxisGetMinimum(axis), error);
            PSScalarRef plotMaximum = PSScalarCreateByAdding(displayedShift, PSAxisGetMaximum(axis), error);
            PSAxisSetMinimum(axis, plotMinimum, true, error);
            CFRelease(plotMinimum);
            PSAxisSetMaximum(axis, plotMaximum, true, error);
            CFRelease(plotMaximum);
            PSPlotSetViewNeedsRegenerated(thePlot, true);
        }
    }
    return output;
}




PSDatasetRef PSDatasetCreateByReversingAlongDimension(PSDatasetRef theDataset,
                                                      CFIndex level,
                                                      CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(output);
    
    CFIndex lowerDVIndex = 0;
    CFIndex upperDVIndex = CFArrayGetCount(output->dependentVariables);
    PSDatumRef focus = PSDatasetGetFocus(output);
    if(level>0) {
        lowerDVIndex = PSDatumGetDependentVariableIndex(focus);
        upperDVIndex = lowerDVIndex+1;
    }
    
    for(CFIndex dvIndex=lowerDVIndex; dvIndex<upperDVIndex; dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSDependentVariableReverseAlongDimension(dV,
                                                 theDataset->dimensions,
                                                 horizontalDimensionIndex,
                                                 level);
    }
    
    return output;
}

PSDatasetRef PSDatasetCreateByAddingParsedExpression(PSDatasetRef input, CFStringRef expression, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(expression,NULL);
    if(CFStringGetLength(expression)==0) return NULL;
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    PSDatumRef focus = PSDatasetGetFocus(output);
    CFIndex dvIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableAddParsedExpression((PSDependentVariableRef) CFArrayGetValueAtIndex(output->dependentVariables, dvIndex),
                                           output->dimensions,
                                           expression,
                                           error);
    
    for(CFIndex dvIndex=0; dvIndex<CFArrayGetCount(output->dependentVariables); dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSPlotRef thePlot = PSDependentVariableGetPlot(dV);
        PSPlotUpdateAxes(thePlot, error);
    }
    return output;
}

#pragma mark Dataset Create Operations

PSDatasetRef PSDatasetCreateByAppending(PSDatasetRef dataset1, PSDatasetRef dataset2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dataset1,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(dataset2,NULL);
    
    CFIndex dimCount = PSDatasetDimensionsCount(dataset1);
    if(dimCount!=PSDatasetDimensionsCount(dataset2)) {
        if(error) {
            CFStringRef desc = CFSTR("Cannot append because number of dimensions are unequal");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
    }
    for(CFIndex idim = 0; idim<dimCount; idim++) {
        PSDimensionRef dim1 = PSDatasetGetDimensionAtIndex(dataset1, idim);
        PSDimensionRef dim2 = PSDatasetGetDimensionAtIndex(dataset2, idim);
        CFStringRef reason = NULL;
        if(!PSLinearDimensionHasIdenticalIncrement(dim1, dim2,&reason)) {
            if(error) {
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&reason,
                                                                1);
            }
            if(reason) CFRelease(reason);
            return NULL;
        }
    }
    PSDatasetRef output = PSDatasetCreateCopy(dataset1);
    CFIndex dvCount = CFArrayGetCount(output->dependentVariables);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableRef dV1 = CFArrayGetValueAtIndex(output->dependentVariables,dvIndex);
        PSDependentVariableRef dV2 = CFArrayGetValueAtIndex(dataset2->dependentVariables,dvIndex);
        PSDependentVariableAppend(dV1,dV2,error);
    });
    
    PSDimensionRef lastDimension1 = PSDatasetGetDimensionAtIndex(output,dimCount-1);
    PSDimensionRef lastDimension2 = PSDatasetGetDimensionAtIndex(dataset2,dimCount-1);
    PSDimensionSetNpts(lastDimension1, PSDimensionGetNpts(lastDimension1)+ PSDimensionGetNpts(lastDimension2));
    CFMutableStringRef newTitle = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppend(newTitle, PSDatasetGetTitle(output));
    CFStringAppend(newTitle, CFSTR(" + "));
    CFStringAppend(newTitle, PSDatasetGetTitle(dataset2));
    PSDatasetSetTitle(output, newTitle);
    CFRelease(newTitle);
    return output;
}

PSDatasetRef PSDatasetCreateByAdding(PSDatasetRef dataset1, PSDatasetRef dataset2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dataset1,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(dataset2,NULL);
    
    if(PSDatasetDimensionsCount(dataset1)!=PSDatasetDimensionsCount(dataset2)) {
        if(error) {
            CFStringRef desc = CFSTR("Cannot add because number of dimensions are unequal");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
    }
    
    for(CFIndex idim = 0; idim<PSDatasetDimensionsCount(dataset1); idim++) {
        PSDimensionRef dim1 = PSDatasetGetDimensionAtIndex(dataset1, idim);
        PSDimensionRef dim2 = PSDatasetGetDimensionAtIndex(dataset2, idim);
        CFStringRef reason = NULL;
        if(!PSDimensionHasIdenticalSampling(dim1, dim2,&reason)) {
            if(error) {
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&reason,
                                                                1);
            }
            if(reason) CFRelease(reason);
            return NULL;
        }
    }
    
    PSDatasetRef output = PSDatasetCreateCopy(dataset1);
    CFIndex dvCount = CFArrayGetCount(output->dependentVariables);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableRef dV1 = CFArrayGetValueAtIndex(output->dependentVariables,dvIndex);
        PSDependentVariableRef dV2 = CFArrayGetValueAtIndex(dataset2->dependentVariables,dvIndex);
        PSDependentVariableAdd(dV1, dV2, error);
    });
    
    CFMutableStringRef newTitle = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppend(newTitle, PSDatasetGetTitle(output));
    CFStringAppend(newTitle, CFSTR(" + "));
    CFStringAppend(newTitle, PSDatasetGetTitle(dataset2));
    PSDatasetSetTitle(output, newTitle);
    CFRelease(newTitle);
    return output;
}

PSDatasetRef PSDatasetCreateBySubtracting(PSDatasetRef dataset1, PSDatasetRef dataset2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dataset1,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(dataset2,NULL);
    
    if(PSDatasetDimensionsCount(dataset1)!=PSDatasetDimensionsCount(dataset2)) {
        if(error) {
            CFStringRef desc = CFSTR("Cannot subtract because number of dimensions are unequal");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
    }
    
    for(CFIndex idim = 0; idim<PSDatasetDimensionsCount(dataset1); idim++) {
        PSDimensionRef dim1 = PSDatasetGetDimensionAtIndex(dataset1, idim);
        PSDimensionRef dim2 = PSDatasetGetDimensionAtIndex(dataset2, idim);
        CFStringRef reason = NULL;
        if(!PSDimensionHasIdenticalSampling(dim1, dim2,&reason)) {
            if(error) {
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&reason,
                                                                1);
            }
            if(reason) CFRelease(reason);
            return NULL;
        }
    }
    
    PSDatasetRef output = PSDatasetCreateCopy(dataset1);
    CFIndex dvCount = CFArrayGetCount(output->dependentVariables);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableRef dV1 = CFArrayGetValueAtIndex(output->dependentVariables,dvIndex);
        PSDependentVariableRef dV2 = CFArrayGetValueAtIndex(dataset2->dependentVariables,dvIndex);
        PSDependentVariableSubtract(dV1, dV2, error);
    });
    
    CFMutableStringRef newTitle = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppend(newTitle, PSDatasetGetTitle(output));
    CFStringAppend(newTitle, CFSTR(" - "));
    CFStringAppend(newTitle, PSDatasetGetTitle(dataset2));
    PSDatasetSetTitle(output, newTitle);
    CFRelease(newTitle);
    return output;
}

PSDatasetRef PSDatasetCreateByMultiplying(PSDatasetRef dataset1, PSDatasetRef dataset2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dataset1,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(dataset2,NULL);
    
    if(PSDatasetDimensionsCount(dataset1)!=PSDatasetDimensionsCount(dataset2)) {
        if(error) {
            CFStringRef desc = CFSTR("Cannot multiply because number of dimensions are unequal");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
    }
    
    for(CFIndex idim = 0; idim<PSDatasetDimensionsCount(dataset1); idim++) {
        PSDimensionRef dim1 = PSDatasetGetDimensionAtIndex(dataset1, idim);
        PSDimensionRef dim2 = PSDatasetGetDimensionAtIndex(dataset2, idim);
        CFStringRef reason = NULL;
        if(!PSDimensionHasIdenticalSampling(dim1, dim2,&reason)) {
            if(error) {
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&reason,
                                                                1);
            }
            if(reason) CFRelease(reason);
            return NULL;
        }
    }
    
    PSDatasetRef output = PSDatasetCreateCopy(dataset1);
    CFIndex dvCount = CFArrayGetCount(output->dependentVariables);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableRef dV1=CFArrayGetValueAtIndex(output->dependentVariables,dvIndex);
        PSDependentVariableRef dV2=CFArrayGetValueAtIndex(dataset2->dependentVariables,dvIndex);
        PSDependentVariableMultiply(dV1, dV2, error);
    });
    
    CFMutableStringRef newTitle = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppend(newTitle, PSDatasetGetTitle(output));
    CFStringAppend(newTitle, CFSTR(" • "));
    CFStringAppend(newTitle, PSDatasetGetTitle(dataset2));
    PSDatasetSetTitle(output, newTitle);
    CFRelease(newTitle);
    return output;
}

PSDatasetRef PSDatasetCreateByCombiningMagnitudeWithArgument(PSDatasetRef magnitude, PSDatasetRef argument, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(magnitude,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(argument,NULL);
    CFIndex dvCount = CFArrayGetCount(magnitude->dependentVariables);
    
    if(dvCount != CFArrayGetCount(argument->dependentVariables)) return NULL;
    PSDatasetRef output = PSDatasetCreateCopy(magnitude);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableRef magnitudeVariable = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSDependentVariableRef argumentVariable = CFArrayGetValueAtIndex(argument->dependentVariables, dvIndex);
        PSDependentVariableCombineMagnitudeWithArgument(magnitudeVariable, argumentVariable);
    });
    return output;
}

PSDatasetRef PSDatasetCreateByTransposingDimensions(PSDatasetRef input, CFIndex dimensionIndex1, CFIndex dimensionIndex2, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    CFIndex dvCount = CFArrayGetCount(input->dependentVariables);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSDependentVariableTransposeDimensions(dV, output->dimensions, dimensionIndex1, dimensionIndex2);
    });
    
    CFArrayExchangeValuesAtIndices(output->dimensions, dimensionIndex1, dimensionIndex2);
    
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef inputVariable = CFArrayGetValueAtIndex(input->dependentVariables, dvIndex);
        PSPlotRef inputPlot = PSDependentVariableGetPlot(inputVariable);
        PSAxisRef axis1 = PSPlotAxisAtIndex(inputPlot, dimensionIndex1);
        PSAxisRef axis2 = PSPlotAxisAtIndex(inputPlot, dimensionIndex2);
        
        PSDependentVariableRef outputVariable = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSPlotRef outputPlot = PSDependentVariableGetPlot(outputVariable);
        PSPlotReplaceAxisAtIndex(outputPlot, dimensionIndex1, axis2);
        PSPlotReplaceAxisAtIndex(outputPlot, dimensionIndex2, axis1);
    }
    
    return output;
}

PSDatasetRef PSDatasetCreateByProjectingOutDimension(PSDatasetRef input,
                                                     CFIndex lowerIndex,
                                                     CFIndex upperIndex,
                                                     CFIndex dimIndex,
                                                     CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    CFIndex dvCount = CFArrayGetCount(input->dependentVariables);
    PSDatasetRef output = PSDatasetCreateCopy(input);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSDependentVariableProjectOutDimension(dV,
                                               output->dimensions,
                                               lowerIndex,
                                               upperIndex,
                                               dimIndex,
                                               error);
    });
    
    PSDatasetRemoveDimensionAtIndex(output,  dimIndex);
    
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef inputDV = (PSDependentVariableRef) CFArrayGetValueAtIndex(input->dependentVariables, dvIndex);
        PSDependentVariableRef outputDV = (PSDependentVariableRef) CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSPlotRef inputPlot = PSDependentVariableGetPlot(inputDV);
        PSPlotRef outputPlot = PSDependentVariableGetPlot(outputDV);
        PSPlotSetComponentColors(outputPlot, PSPlotGetComponentColors(inputPlot));
        PSPlotReset(outputPlot);
    }
    PSDatumRef focus = PSDatasetGetFocus(input);
    CFIndex inputDVIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex inputComponentIndex = PSDatumGetComponentIndex(focus);
    CFIndex inputFocusMemOffset = PSDatumGetMemOffset(focus);
    PSMutableIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(input->dimensions, inputFocusMemOffset);
    PSIndexArrayRemoveValueAtIndex(focusIndexes, dimIndex);
    CFIndex focusMemOffset = PSDimensionMemOffsetFromCoordinateIndexes(output->dimensions, focusIndexes);
    CFRelease(focusIndexes);
    PSDatumRef outputFocus = PSDatasetCreateDatumFromMemOffset(output, inputDVIndex, inputComponentIndex, focusMemOffset);
    PSDatasetSetFocus(output, outputFocus);
    CFRelease(outputFocus);
    return output;
}

PSDatasetRef PSDatasetCreateKeepingOneDependentVariable(PSDatasetRef theDataset,
                                                        CFIndex dependentVariableIndex,
                                                        CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);
    if(dependentVariableIndex<0 || dependentVariableIndex>=dvCount) return NULL;
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);
    for(CFIndex dvIndex=dvCount-1;dvIndex>dependentVariableIndex;dvIndex--)
            PSDatasetRemoveDependentVariableAtIndex(output, dvIndex);
    for(CFIndex dvIndex=0;dvIndex<dependentVariableIndex;dvIndex++)
            PSDatasetRemoveDependentVariableAtIndex(output, 0);
    return output;
}

PSDatasetRef PSDatasetCreateKeepingOneComponent(PSDatasetRef theDataset,
                                                CFIndex dependentVariableIndex,
                                                CFIndex componentIndex,
                                                CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);
    if(dependentVariableIndex<0 || dependentVariableIndex>=dvCount) return NULL;
    
    PSDependentVariableRef theDV = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    CFIndex componentsCount = PSDependentVariableComponentsCount(theDV);
    if(componentIndex<0 || componentIndex>=componentsCount) return NULL;
    
    PSDatasetRef output = PSDatasetCreateKeepingOneDependentVariable(theDataset,
                                                                     dependentVariableIndex,
                                                                     error);
    theDV = PSDatasetGetDependentVariableAtIndex(output, 0);
    for(CFIndex cIndex=componentsCount-1;cIndex>componentIndex;cIndex--)
        PSDependentVariableRemoveComponentAtIndex(theDV, cIndex);
    for(CFIndex cIndex=0;cIndex<componentIndex;cIndex++)
        PSDependentVariableRemoveComponentAtIndex(theDV, 0);

    return output;
}

PSDatasetRef PSDatasetCreateCrossSection(PSDatasetRef input,
                                         PSIndexPairSetRef indexPairs,
                                         CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    CFIndex dvCount = CFArrayGetCount(input->dependentVariables);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount, queue,^(size_t dvIndex) {
        PSDependentVariableCrossSection(CFArrayGetValueAtIndex(output->dependentVariables, dvIndex),
                                        output->dimensions,
                                        indexPairs,
                                        error);
    });
    PSIndexSetRef dimensionIndexes = PSIndexPairSetCreateIndexSetOfIndexes(indexPairs);
    PSDatasetRemoveDimensionsAtIndexes(output, dimensionIndexes);
    
    CFStringRef newTitle = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@%@"),PSDatasetGetTitle(input),CFSTR("-crossSection"));
    PSDatasetSetTitle(output, newTitle);
    CFRelease(newTitle);
    return output;
}

PSDatasetRef PSDatasetCreateByInterleavingAlongDimension(PSDatasetRef dataset1,
                                                         PSDatasetRef dataset2,
                                                         CFIndex interleavedDimensionIndex,
                                                         CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dataset1,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(dataset2,NULL);
    PSDimensionRef theDimension1 = CFArrayGetValueAtIndex(dataset1->dimensions, interleavedDimensionIndex);
    PSDimensionRef theDimension2 = CFArrayGetValueAtIndex(dataset2->dimensions, interleavedDimensionIndex);
    if(PSDimensionHasNonUniformGrid(theDimension1)) return NULL;
    if(PSDimensionHasNonUniformGrid(theDimension2)) return NULL;
    
    CFIndex dvCount1 = CFArrayGetCount(dataset1->dependentVariables);
    CFIndex dvCount2 = CFArrayGetCount(dataset1->dependentVariables);
    if(dvCount1 != dvCount2) return NULL;
    
    PSScalarRef increment1 = PSDimensionGetIncrement(theDimension1);
    PSScalarRef increment2 = PSDimensionGetIncrement(theDimension2);
    
    if(PSScalarCompare(increment1, increment2) != kPSCompareEqualTo) return NULL;
    
    double interval = PSScalarDoubleValue(increment1);
    bool success = true;
    double referenceOffset1 = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(theDimension1), PSQuantityGetUnit(increment1), &success);
    double referenceOffset2 = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(theDimension2), PSQuantityGetUnit(increment1), &success);
    
    double referenceOffsetDifference = fabs(referenceOffset2 - referenceOffset1);
    if(PSCompareDoubleValuesLoose(referenceOffsetDifference, interval/2) != kPSCompareEqualTo) return NULL;
    
    PSDatasetRef dataset1st = dataset1;
    PSDatasetRef dataset2nd = dataset2;
    PSDimensionRef dimension1st = theDimension1;
    PSDimensionRef dimension2nd = theDimension2;
    if(referenceOffset2<referenceOffset1) {
        dataset1st = dataset2;
        dataset2nd = dataset1;
        dimension1st = theDimension2;
        dimension2nd = theDimension1;
    }
    PSDatasetRef output = PSDatasetCreateCopy(dataset1st);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(dvCount1, queue,^(size_t dvIndex) {
        PSDependentVariableRef dv1 = CFArrayGetValueAtIndex(output->dependentVariables,dvIndex);
        PSDependentVariableRef dv2 = CFArrayGetValueAtIndex(dataset2nd->dependentVariables,dvIndex);
        PSDependentVariableInterleaveAlongDimension(dv1,dv2,output->dimensions,interleavedDimensionIndex,error);
    });
    
    PSDimensionRef newDimension = PSDimensionCreateCopy(dimension1st);
    PSDimensionSetNpts(newDimension, PSDimensionGetNpts(dimension1st)*2);
    PSScalarRef increment = PSScalarCreateByMultiplyingByDimensionlessRealConstant(PSDimensionGetIncrement(newDimension), 0.5);
    PSDimensionSetIncrement(newDimension, increment);
    CFRelease(increment);
    CFArraySetValueAtIndex(output->dimensions, interleavedDimensionIndex, newDimension);
    
    CFMutableStringRef newTitle = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppend(newTitle, PSDatasetGetTitle(dataset1st));
    CFStringAppend(newTitle, CFSTR(" + "));
    CFStringAppend(newTitle, PSDatasetGetTitle(dataset2nd));
    
    PSDatasetSetTitle(output, newTitle);
    if(newTitle) CFRelease(newTitle);
    
    PSDatasetSetHorizontalDimensionIndex(output, interleavedDimensionIndex);
    return output;
}

CFArrayRef PSDatasetCreateBySeparatingInterleavedSignalsAlongDimension(PSDatasetRef theDataset, CFIndex dimensionIndex, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    PSDimensionRef theDimension = CFArrayGetValueAtIndex(theDataset->dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(theDimension)) return NULL;
    
    CFIndex oldNpts = PSDimensionGetNpts(theDimension);
    if(oldNpts%2 != 0) {
        if(error) {
            CFStringRef desc = CFSTR("Operation requires even number of samples along dimension.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        
        return NULL;
        
    }
    
    PSDatasetRef odd = PSDatasetCreateCopy(theDataset);
    PSDatasetSetTitle(odd,CFSTR("odd"));
    PSDatasetRef even = PSDatasetCreateCopy(theDataset);
    PSDatasetSetTitle(even,CFSTR("even"));
    CFIndex dvCount = CFArrayGetCount(theDataset->dependentVariables);
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(theDataset->dependentVariables,dvIndex);
        PSDependentVariableRef oddDV = CFArrayGetValueAtIndex(odd->dependentVariables,dvIndex);
        PSDependentVariableRef evenDV = CFArrayGetValueAtIndex(even->dependentVariables,dvIndex);
        PSDependentVariableSeparateInterleavedSignalsAlongDimension(dV,
                                                                    theDataset->dimensions,
                                                                    dimensionIndex,
                                                                    oddDV,evenDV,
                                                                    error);
    }
    
    theDimension = CFArrayGetValueAtIndex(odd->dimensions, dimensionIndex);
    PSDimensionSetNpts(theDimension, oldNpts/2);
    PSScalarRef increment = PSDimensionGetIncrement(theDimension);
    PSScalarRef newReferenceOffset = PSScalarCreateByAdding(PSDimensionGetReferenceOffset(theDimension), increment,error);
    PSScalarRef newIncrement = PSScalarCreateByMultiplyingByDimensionlessRealConstant(increment, 2);
    PSDimensionSetReferenceOffset(theDimension, newReferenceOffset);
    PSDimensionSetIncrement(theDimension, newIncrement);
    CFRelease(newReferenceOffset);
    CFRelease(newIncrement);
    
    theDimension = CFArrayGetValueAtIndex(even->dimensions, dimensionIndex);
    PSDimensionSetNpts(theDimension, oldNpts/2);
    newIncrement = PSScalarCreateByMultiplyingByDimensionlessRealConstant(PSDimensionGetIncrement(theDimension), 2);
    PSDimensionSetIncrement(theDimension, newIncrement);
    CFRelease(newIncrement);
    
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef oddDV = CFArrayGetValueAtIndex(odd->dependentVariables, dvIndex);
        PSDependentVariableRef evenDV = CFArrayGetValueAtIndex(even->dependentVariables, dvIndex);
        
        PSPlotReset(PSDependentVariableGetPlot(oddDV));
        PSPlotReset(PSDependentVariableGetPlot(evenDV));
    }
    
    PSDatasetRef datasets[2] = {even,odd};
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **) datasets, 2, &kCFTypeArrayCallBacks);
    CFRelease(odd);
    CFRelease(even);
    
    return array;
}

PSDatasetRef PSDatasetCreateByAppendingValuesAlongVerticalOntoHorizontalDimension(PSDatasetRef theDataset, CFStringRef title, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    if(PSDimensionHasNonUniformGrid(horizontalDimension)) return NULL;
    
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    if(PSDimensionHasNonUniformGrid(verticalDimension)) return NULL;
    
    PSScalarRef horizontalIncrement = PSDimensionGetIncrement(horizontalDimension);
    PSScalarRef verticalIncrement = PSDimensionGetIncrement(verticalDimension);
    
    CFIndex verticalNpts = PSDimensionGetNpts(verticalDimension);
    PSMutableScalarRef temp = PSScalarCreateMutableCopy(verticalIncrement);
    PSScalarMultiplyByDimensionlessRealConstant(temp, 1./verticalNpts);
    
    if(!PSQuantityHasSameDimensionality(verticalIncrement, horizontalIncrement)) {
        CFRelease(temp);
        if(error) {
            CFStringRef desc = CFSTR("Append, Incompatible dimensionalities.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        
        return NULL;
    }
    
    CFRelease(temp);
    
    CFIndex oldNpts = PSDimensionGetNpts(horizontalDimension);
    CFIndex newNpts = PSDimensionGetNpts(horizontalDimension)*PSDimensionGetNpts(verticalDimension);
    
    CFMutableArrayRef newDimensions = PSDatasetDimensionsMutableCopy(theDataset);
    PSDimensionRef newHorizontalDimension = CFArrayGetValueAtIndex(newDimensions, horizontalDimensionIndex);
    PSDimensionSetNpts(newHorizontalDimension, newNpts);
    CFMutableArrayRef newDimensionPrecedence = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, theDataset->dimensionPrecedence);
    
    CFArrayRemoveValueAtIndex(newDimensions, verticalDimensionIndex);
    CFArrayRemoveValueAtIndex(newDimensionPrecedence, verticalDimensionIndex);
    
    CFIndex newHorizontalDimensionIndex = horizontalDimensionIndex;
    if(verticalDimensionIndex<horizontalDimensionIndex) newHorizontalDimensionIndex--;
    
    
    PSDatasetRef newDataset =  PSDatasetCreate(newDimensions,
                                               newDimensionPrecedence,
                                               theDataset->dependentVariables,
                                               theDataset->tags,
                                               theDataset->description,
                                               title,
                                               NULL,
                                               NULL,
                                               NULL,
                                               theDataset->metaData);
    
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dependentVariableIndex = 0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
        PSDependentVariableRef oldDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        PSDependentVariableRef newDependentVariable = PSDatasetGetDependentVariableAtIndex(newDataset, dependentVariableIndex);
        CFIndex componentsCount = PSDependentVariableComponentsCount(oldDependentVariable);
        CFIndex size = PSDependentVariableSize(oldDependentVariable);
        for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
            for(CFIndex memOffset = 0; memOffset < size; memOffset++) {
                PSScalarRef response = PSDependentVariableCreateValueFromMemOffset(oldDependentVariable, componentIndex, memOffset);
                PSIndexArrayRef oldIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(theDataset->dimensions, memOffset);
                CFIndex verticalCoordinateIndex = PSIndexArrayGetValueAtIndex(oldIndexes, verticalDimensionIndex);
                CFIndex newHorizontalCoordinateIndex = PSIndexArrayGetValueAtIndex(oldIndexes, horizontalDimensionIndex);
                newHorizontalCoordinateIndex += verticalCoordinateIndex*oldNpts;
                
                PSMutableIndexArrayRef newIndexes = PSIndexArrayCreateMutableCopy(oldIndexes);
                PSIndexArrayRemoveValueAtIndex(newIndexes, verticalDimensionIndex);
                PSIndexArraySetValueAtIndex(newIndexes, newHorizontalDimensionIndex, newHorizontalCoordinateIndex);
                
                CFIndex newMemOffset = PSDimensionMemOffsetFromCoordinateIndexes(newDimensions, newIndexes);
                PSDependentVariableSetValueAtMemOffset(newDependentVariable, componentIndex, newMemOffset, response, error);
                
                CFRelease(newIndexes);
                CFRelease(oldIndexes);
                CFRelease(response);
            }
        }
        PSPlotReset(PSDependentVariableGetPlot(newDependentVariable));
    }
    
    CFRelease(newDimensions);
    CFRelease(newDimensionPrecedence);
    return newDataset;
}

PSDatasetRef PSDatasetCreateBySeparatingAppendedValuesIntoNewDimension(PSDatasetRef theDataset,
                                                                       PSDimensionRef newDimension,
                                                                       CFStringRef title,
                                                                       CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    if(PSDimensionHasNonUniformGrid(horizontalDimension)) return NULL;
    if(PSDimensionHasNonUniformGrid(newDimension)) return NULL;
    
    
    CFIndex horizontalNpts = PSDimensionGetNpts(horizontalDimension);
    CFIndex newDimensionNpts = PSDimensionGetNpts(newDimension);
    CFIndex newDimensionIndex = horizontalDimensionIndex + 1;
    
    if(horizontalNpts%newDimensionNpts == 0 && horizontalNpts>newDimensionNpts) {
        CFMutableArrayRef newDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, theDataset->dimensions);
        PSDimensionRef newHorizontalDimension = PSDimensionCreateCopy((PSDimensionRef) CFArrayGetValueAtIndex(newDimensions, horizontalDimensionIndex));
        PSDimensionSetNpts(newHorizontalDimension, PSDimensionGetNpts(horizontalDimension)/PSDimensionGetNpts(newDimension));
        
        CFArraySetValueAtIndex(newDimensions, horizontalDimensionIndex, newHorizontalDimension);
        if(newDimensionIndex==CFArrayGetCount(newDimensions)) CFArrayAppendValue(newDimensions, newDimension);
        else CFArrayInsertValueAtIndex(newDimensions, newDimensionIndex, newDimension);
        
        CFMutableArrayRef newDimensionPrecedence = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, theDataset->dimensionPrecedence);
        CFArrayAppendValue(newDimensionPrecedence, (void *) CFArrayGetCount(newDimensions)-1);
        
        PSDatumRef focus = PSDatasetGetFocus(theDataset);
        PSDatasetRef newDataset = PSDatasetCreate(newDimensions,
                                                  newDimensionPrecedence,
                                                  theDataset->dependentVariables,
                                                  theDataset->tags,
                                                  theDataset->description,
                                                  title,
                                                  focus,
                                                  theDataset->previousFocus,
                                                  theDataset->operations,
                                                  theDataset->metaData);
        
        CFRelease(newDimensions);
        CFRelease(newDimensionPrecedence);
        
        CFIndex dependentVariablesCount = CFArrayGetCount(newDataset->dependentVariables);
        for(CFIndex dependentVariableIndex=0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
            PSPlotRef newPlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(newDataset, dependentVariableIndex));
            PSPlotReset(newPlot);
        }
        
        return newDataset;
    }
    
    return (PSDatasetRef) CFRetain(theDataset);
}

PSDatasetRef PSDatasetCreateByTrimingAlongDimension(PSDatasetRef theDataset,
                                                     CFIndex dimensionIndex,
                                                     char* trimSide,
                                                     CFIndex lengthPerSide)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);

    PSDimensionRef trimDimension = (PSDimensionRef) CFArrayGetValueAtIndex(theDataset->dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(trimDimension)) return NULL;
    
    // Code lines below must be identical to code in PSDependentVariableTrimAlongDimension()
    CFIndex oldTrimDimensionNpts = PSDimensionGetNpts(trimDimension);
    CFIndex newTrimDimensionNpts = oldTrimDimensionNpts - lengthPerSide;
    if(trimSide[0]=='b') newTrimDimensionNpts -= lengthPerSide;
    CFIndex deltaNpts = oldTrimDimensionNpts - newTrimDimensionNpts;
    CFIndex preTrimPoints = 0;
    if(trimSide[0]=='l') preTrimPoints = deltaNpts;
    else if(trimSide[0]=='b') preTrimPoints = deltaNpts/2;

    if(newTrimDimensionNpts==0) return NULL;
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);

    CFIndex dvCount = PSDatasetDependentVariablesCount(output);
    for(CFIndex dvIndex=0;dvIndex<dvCount;dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSDependentVariableTrimAlongDimension(dV,output->dimensions,dimensionIndex,trimSide,lengthPerSide);
    }
    

    trimDimension = (PSDimensionRef) CFArrayGetValueAtIndex(output->dimensions, dimensionIndex);
    PSDimensionSetNpts(trimDimension, newTrimDimensionNpts);
    bool complexFFT = PSDimensionGetFFT(trimDimension);
    switch (trimSide[0]) {
        case 'l':{
            if(complexFFT) {
                bool success = true;
                PSUnitRef unit = PSDimensionGetRelativeUnit(trimDimension);
                double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(trimDimension),unit, &success);
                double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(trimDimension), unit, &success);
                referenceOffset += lengthPerSide*increment/2;
                PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
                PSDimensionSetReferenceOffset(trimDimension,temp);
                CFRelease(temp);
            }
            else {
                bool success = true;
                PSUnitRef unit = PSDimensionGetRelativeUnit(trimDimension);
                double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(trimDimension),unit, &success);
                double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(trimDimension), unit, &success);
                referenceOffset += lengthPerSide*increment;
                PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
                PSDimensionSetReferenceOffset(trimDimension,temp);
                CFRelease(temp);
            }
            break;
        }
        case 'r': {
            if(complexFFT) {
                bool success = true;
                PSUnitRef unit = PSDimensionGetRelativeUnit(trimDimension);
                double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(trimDimension),unit, &success);
                double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(trimDimension), unit, &success);
                referenceOffset -= lengthPerSide*increment/2;
                PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
                PSDimensionSetReferenceOffset(trimDimension,temp);
                CFRelease(temp);
            }
            break;
        }
        case 'b':
        {
            if(complexFFT) break;
            bool success = true;
            PSUnitRef unit = PSDimensionGetRelativeUnit(trimDimension);
            double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(trimDimension),unit, &success);
            double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(trimDimension), unit, &success);
            referenceOffset += lengthPerSide*increment;
            PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
            PSDimensionSetReferenceOffset(trimDimension,temp);
            CFRelease(temp);
            break;
        }
    }
    
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        CFStringRef displayedQuantityName = PSDimensionCopyDisplayedQuantityName(trimDimension);
        PSPlotRef newPlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(output, dvIndex));
        PSAxisReset(PSPlotAxisAtIndex(newPlot, dimensionIndex), displayedQuantityName);
        CFRelease(displayedQuantityName);
    }
    return output;
}


PSDatasetRef PSDatasetCreateByFillingAlongDimensions(PSDatasetRef theDataset,
                                                     CFIndex dimensionIndex,
                                                     CFArrayRef fillConstants,
                                                     char *fillSide,
                                                     CFIndex lengthPerSide)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    PSDimensionRef fillDimension = (PSDimensionRef) CFArrayGetValueAtIndex(theDataset->dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(fillDimension)) return NULL;
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);

    CFIndex dvCount = PSDatasetDependentVariablesCount(output);
    for(CFIndex dvIndex=0;dvIndex<dvCount;dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSScalarRef fillConstant = CFArrayGetValueAtIndex(fillConstants, dvIndex);
        PSDependentVariableFillAlongDimension(dV,output->dimensions,dimensionIndex,fillConstant,fillSide,lengthPerSide);
    }
    
    // Code lines below must be identical to code in PSDependentVariableFillAlongDimension()
    CFIndex oldFillDimensionNpts = PSDimensionGetNpts(fillDimension);
    CFIndex newFillDimensionNpts = oldFillDimensionNpts + lengthPerSide;
    if(fillSide[0]=='b') newFillDimensionNpts += lengthPerSide;
    CFIndex deltaNpts = newFillDimensionNpts - oldFillDimensionNpts;
    CFIndex prefillPoints = 0;
    if(fillSide[0]=='l') prefillPoints = deltaNpts;
    else if(fillSide[0]=='b') prefillPoints = deltaNpts/2;
    
    fillDimension = (PSDimensionRef) CFArrayGetValueAtIndex(output->dimensions, dimensionIndex);
    PSDimensionSetNpts(fillDimension, newFillDimensionNpts);
    bool complexFFT = PSDimensionGetFFT(fillDimension);
    switch (fillSide[0]) {
        case 'l':{
            if(complexFFT) {
                bool success = true;
                PSUnitRef unit = PSDimensionGetRelativeUnit(fillDimension);
                double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(fillDimension),unit, &success);
                double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(fillDimension), unit, &success);
                referenceOffset -= lengthPerSide*increment/2;
                PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
                PSDimensionSetReferenceOffset(fillDimension,temp);
                CFRelease(temp);
            }
            else {
                bool success = true;
                PSUnitRef unit = PSDimensionGetRelativeUnit(fillDimension);
                double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(fillDimension),unit, &success);
                double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(fillDimension), unit, &success);
                referenceOffset -= lengthPerSide*increment;
                PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
                PSDimensionSetReferenceOffset(fillDimension,temp);
                CFRelease(temp);
            }
            break;
        }
        case 'r': {
            if(complexFFT) {
                bool success = true;
                PSUnitRef unit = PSDimensionGetRelativeUnit(fillDimension);
                double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(fillDimension),unit, &success);
                double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(fillDimension), unit, &success);
                referenceOffset += lengthPerSide*increment/2;
                PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
                PSDimensionSetReferenceOffset(fillDimension,temp);
                CFRelease(temp);
            }
           break;
        }
        case 'b':
        {
            if(complexFFT) break;
            bool success = true;
            PSUnitRef unit = PSDimensionGetRelativeUnit(fillDimension);
            double referenceOffset = PSScalarDoubleValueInUnit(PSDimensionGetReferenceOffset(fillDimension),unit, &success);
            double increment = PSScalarDoubleValueInUnit(PSDimensionGetIncrement(fillDimension), unit, &success);
            referenceOffset -= lengthPerSide*increment;
            PSScalarRef temp = PSScalarCreateWithDouble(referenceOffset, unit);
            PSDimensionSetReferenceOffset(fillDimension,temp);
            CFRelease(temp);
            break;
        }
    }
    
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        CFStringRef displayedQuantityName = PSDimensionCopyDisplayedQuantityName(fillDimension);
        PSPlotRef newPlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(output, dvIndex));
        PSAxisReset(PSPlotAxisAtIndex(newPlot, dimensionIndex), displayedQuantityName);
        CFRelease(displayedQuantityName);
    }
    return output;
}

PSDatasetRef PSDatasetCreateByRepeatingAlongDimension(PSDatasetRef theDataset, CFIndex dimensionIndex, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    PSDimensionRef theDimension = (PSDimensionRef) CFArrayGetValueAtIndex(theDataset->dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(theDimension)) return NULL;
    
    PSDatasetRef output = PSDatasetCreateCopy(theDataset);

    CFIndex dvCount = CFArrayGetCount(output->dependentVariables);
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef dV = CFArrayGetValueAtIndex(output->dependentVariables, dvIndex);
        PSDependentVariableRepeatAlongDimension(dV, output->dimensions, dimensionIndex);
    }

    PSDimensionRef repeatDimension = (PSDimensionRef) CFArrayGetValueAtIndex(output->dimensions, dimensionIndex);
    PSDimensionSetNpts(repeatDimension, PSDimensionGetNpts(repeatDimension)*2);
    
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        CFStringRef displayedQuantityName = PSDimensionCopyDisplayedQuantityName(repeatDimension);
        PSPlotRef newPlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(output, dvIndex));
        PSAxisReset(PSPlotAxisAtIndex(newPlot, dimensionIndex), displayedQuantityName);
        CFRelease(displayedQuantityName);
    }
    return output;

}

PSDatasetRef PSDatasetCreateByRepeatingIntoNewDimension(PSDatasetRef theDataset, PSDimensionRef newDimension, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    CFMutableArrayRef dependentVariables = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<CFArrayGetCount(theDataset->dependentVariables); dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDependentVariableCreateByRepeatingIntoNewDimension((PSDependentVariableRef)
                                                                                                           CFArrayGetValueAtIndex(theDataset->dependentVariables,
                                                                                                                                  dependentVariableIndex),
                                                                                                           theDataset->dimensions,
                                                                                                           newDimension);
        CFArrayAppendValue(dependentVariables, theDependentVariable);
        CFRelease(theDependentVariable);
    }
    
    CFMutableArrayRef newDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, theDataset->dimensions);
    CFArrayAppendValue(newDimensions, newDimension);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    
    PSDatasetRef newDataset = PSDatasetCreate(newDimensions,
                                              theDataset->dimensionPrecedence,
                                              dependentVariables,
                                              theDataset->tags,
                                              theDataset->description,
                                              theDataset->title,
                                              focus,
                                              theDataset->previousFocus,
                                              theDataset->operations,
                                              theDataset->metaData);
    
    CFRelease(dependentVariables);
    CFRelease(newDimensions);
    
    if(PSDatasetDimensionsCount(newDataset)>1){
        CFIndex dependentVariablesCount = CFArrayGetCount(newDataset->dependentVariables);
        for(CFIndex dependentVariableIndex=0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
            PSPlotRef newPlot = PSDependentVariableGetPlot(PSDatasetGetDependentVariableAtIndex(newDataset, dependentVariableIndex));
            PSPlotSetDimensionsCountDisplayed(newPlot, 2);
        }
    }
    return newDataset;
}


PSDatasetRef PSDatasetCreateByScalingHorizontalAndVerticalDimensions(PSDatasetRef input,
                                                                     CFIndex newHorizontalNpts,
                                                                     CFIndex newVerticalNpts,
                                                                     CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    PSDatumRef focus = PSDatasetGetFocus(input);
    CFIndex focusDependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex focusComponentIndex = PSDatumGetComponentIndex(focus);
    
    CFArrayRef oldDimensions = PSDatasetGetDimensions(input);
    CFIndex dimensionsCount = PSDatasetDimensionsCount(input);
    if(dimensionsCount<2) return NULL;
    
    CFMutableArrayRef newDimensions = PSDatasetDimensionsMutableCopy(input);
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(input);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(input);
    
    PSDimensionRef newHorizontalDimension = CFArrayGetValueAtIndex(newDimensions, horizontalDimensionIndex);
    PSDimensionSetNpts(newHorizontalDimension, newHorizontalNpts);
    
    PSDimensionRef newVerticalDimension = CFArrayGetValueAtIndex(newDimensions, verticalDimensionIndex);
    PSDimensionSetNpts(newVerticalDimension, newVerticalNpts);
    
    CFIndex *oldNpts = calloc(sizeof(CFIndex), dimensionsCount);
    CFIndex *newNpts = calloc(sizeof(CFIndex), dimensionsCount);
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef oldDimension = CFArrayGetValueAtIndex(oldDimensions, idim);
        PSDimensionRef newDimension = CFArrayGetValueAtIndex(newDimensions, idim);
        oldNpts[idim] = PSDimensionGetNpts(oldDimension);
        newNpts[idim] = PSDimensionGetNpts(newDimension);
    }
    
    PSMutableIndexSetRef dimensionIndexSet = PSIndexSetCreateMutable();
    PSIndexSetAddIndex(dimensionIndexSet, horizontalDimensionIndex);
    PSIndexSetAddIndex(dimensionIndexSet, verticalDimensionIndex);
    
    CFArrayRef oldCrossSectionDimensions = PSCFArrayCreateWithObjectsAtIndexes(oldDimensions, dimensionIndexSet);
    CFArrayRef newCrossSectionDimensions = PSCFArrayCreateWithObjectsAtIndexes(newDimensions, dimensionIndexSet);
    CFMutableArrayRef depthDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, PSDatasetGetDimensions(input));
    PSCFArrayRemoveObjectsAtIndexes(depthDimensions, dimensionIndexSet);
    CFIndex reducedSize = PSDimensionCalculateSizeFromDimensions(depthDimensions);
    CFRelease(depthDimensions);
    
    PSDatasetRef output = PSDatasetCreateCopy(input);
    PSMutableIndexArrayRef coordinateIndexes = PSIndexArrayCreateMutable(dimensionsCount);
    PSIndexArraySetValueAtIndex(coordinateIndexes, horizontalDimensionIndex, 0);
    PSIndexArraySetValueAtIndex(coordinateIndexes, verticalDimensionIndex, 0);

    CFIndex dvCount = PSDatasetDependentVariablesCount(output);
    for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
        PSDependentVariableRef oldDependentVariable = PSDatasetGetDependentVariableAtIndex(input, dvIndex);
        PSDependentVariableRef newDependentVariable = PSDatasetGetDependentVariableAtIndex(output, dvIndex);
        PSDependentVariableSetSize(newDependentVariable, reducedSize*newHorizontalNpts*newVerticalNpts);
        
        for(CFIndex reducedMemOffset = 0; reducedMemOffset < reducedSize; reducedMemOffset++) {
            setIndexesForReducedMemOffsetIgnoringDimensions(reducedMemOffset, PSIndexArrayGetMutableBytePtr(coordinateIndexes), dimensionsCount, oldNpts, dimensionIndexSet);
            
            PSMutableIndexPairSetRef indexPairSet = PSIndexPairSetCreateMutableWithIndexArray(coordinateIndexes);
            PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, horizontalDimensionIndex);
            PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, verticalDimensionIndex);
            
            PSDependentVariableRef oldCrossSection = PSDependentVariableCreateCrossSection(oldDependentVariable,oldDimensions,indexPairSet, error);
            PSDependentVariableRef newCrossSection = PSDependentVariableCreateCrossSection(newDependentVariable,newDimensions,indexPairSet, error);
            
            vImagePixelCount oldHeight = oldNpts[verticalDimensionIndex];
            vImagePixelCount oldWidth = oldNpts[horizontalDimensionIndex];
            vImagePixelCount newHeight = newNpts[verticalDimensionIndex];
            vImagePixelCount newWidth = newNpts[horizontalDimensionIndex];
            CFMutableArrayRef transposeDimensions = NULL;
            if(horizontalDimensionIndex > verticalDimensionIndex) {
                transposeDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 2, newCrossSectionDimensions);
                PSDependentVariableTransposeDimensions(oldCrossSection, oldCrossSectionDimensions, 0, 1);
                CFArrayExchangeValuesAtIndices(transposeDimensions,0,1);
            }
            
            CFMutableArrayRef oldCrossSectionComponents = PSDependentVariableGetComponents(oldCrossSection);
            CFMutableArrayRef newCrossSectionComponents = PSDependentVariableGetComponents(newCrossSection);
            CFIndex componentsCount = CFArrayGetCount(oldCrossSectionComponents);
            for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                CFMutableDataRef oldCrossSectionComponent = (CFMutableDataRef) CFArrayGetValueAtIndex(oldCrossSectionComponents, componentIndex);
                CFMutableDataRef newCrossSectionComponent = (CFMutableDataRef) CFArrayGetValueAtIndex(newCrossSectionComponents, componentIndex);
                
                switch (PSQuantityGetElementType(oldDependentVariable)) {
                    case kPSNumberFloat32Type: {
                        float *oldBytes = (float *) CFDataGetBytePtr(oldCrossSectionComponent);
                        float *newBytes = (float *) CFDataGetBytePtr(newCrossSectionComponent);
                        vImage_Buffer in = {oldBytes,oldHeight,oldWidth,oldWidth*sizeof(float)};
                        vImage_Buffer out = {newBytes,newHeight,newWidth,newWidth*sizeof(float)};
                        
                        vImage_AffineTransform transform = {(float) newWidth/(float) oldWidth, 0.0f, 0.0f, (float) newHeight/(float) oldHeight, 0.0f, 0.0f};
                        vImageAffineWarp_PlanarF(&in,&out, NULL,&transform,0,kvImageBackgroundColorFill);
                        break;
                    }
                        
                    case kPSNumberFloat32ComplexType: {
                        float complex *oldBytes = (float complex *) CFDataGetMutableBytePtr(oldCrossSectionComponent);
                        size_t size = PSDependentVariableSize(oldCrossSection);
                        DSPSplitComplex *oldSplitComplex = malloc(sizeof(struct DSPSplitComplex));
                        oldSplitComplex->realp = (float *) calloc((size_t) size,sizeof(float));
                        oldSplitComplex->imagp = (float *) calloc((size_t) size,sizeof(float));
                        vDSP_ctoz((DSPComplex *) oldBytes,2,oldSplitComplex,1,size);
                        
                        float complex *newBytes = (float complex *) CFDataGetMutableBytePtr(newCrossSectionComponent);
                        size = PSDependentVariableSize(newCrossSection);
                        DSPSplitComplex *newSplitComplex = malloc(sizeof(struct DSPSplitComplex));
                        newSplitComplex->realp = (float *) calloc((size_t) size,sizeof(float));
                        newSplitComplex->imagp = (float *) calloc((size_t) size,sizeof(float));
                        vDSP_ctoz((DSPComplex *) newBytes,2,newSplitComplex,1,size);
                        
                        vImage_Buffer inReal = {oldSplitComplex->realp,oldHeight,oldWidth,oldWidth*sizeof(float)};
                        vImage_Buffer outReal = {newSplitComplex->realp,newHeight,newWidth,newWidth*sizeof(float)};
                        vImageScale_PlanarF(&inReal,&outReal, NULL,kvImageHighQualityResampling);
                        
                        vImage_Buffer inImag = {oldSplitComplex->imagp,oldHeight,oldWidth,oldWidth*sizeof(float)};
                        vImage_Buffer outImag = {newSplitComplex->imagp,newHeight,newWidth,newWidth*sizeof(float)};
                        vImageScale_PlanarF(&inImag,&outImag, NULL,kvImageHighQualityResampling);
                        
                        free(oldSplitComplex->realp);
                        free(oldSplitComplex->imagp);
                        free(oldSplitComplex);
                        
                        vDSP_ztoc(newSplitComplex,1,(DSPComplex *) newBytes,2,size);
                        
                        free(newSplitComplex->realp);
                        free(newSplitComplex->imagp);
                        free(newSplitComplex);
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        // This code doesn't work - Why?
                        double *oldBytes = (double *) CFDataGetBytePtr(oldCrossSectionComponent);
                        double *newBytes = (double *) CFDataGetBytePtr(newCrossSectionComponent);
                        vImage_Buffer in = {oldBytes,oldHeight,oldWidth,oldWidth*sizeof(double)};
                        vImage_Buffer out = {newBytes,newHeight,newWidth,newWidth*sizeof(double)};
                        
                        vImage_AffineTransform_Double transform = {(double) newWidth/(double) oldWidth, 0.0f, 0.0f, (double) newHeight/(double) oldHeight, 0.0f, 0.0f};
                        vImageAffineWarpD_PlanarF(&in,&out, NULL,&transform,0,kvImageBackgroundColorFill);
                        break;
                    }
                    case kPSNumberFloat64ComplexType:
                        break;
                }
            }
            if(horizontalDimensionIndex > verticalDimensionIndex) {
                PSDependentVariableTransposeDimensions(newCrossSection, transposeDimensions, 0, 1);
            }
            if(transposeDimensions) CFRelease(transposeDimensions);
            
            PSDependentVariableSetCrossSection(newDependentVariable, newDimensions, indexPairSet, newCrossSection, newCrossSectionDimensions);
            CFRelease(indexPairSet);
            CFRelease(newCrossSection);
        }
    }
    CFRelease(coordinateIndexes);
    CFRelease(output->dimensions);
    output->dimensions = newDimensions;
    
    newHorizontalDimension = PSDatasetHorizontalDimension(output);
    PSMutableScalarRef increment = PSScalarCreateMutableCopy(PSDimensionGetIncrement(newHorizontalDimension));
    PSScalarMultiplyByDimensionlessRealConstant(increment, (double) oldNpts[horizontalDimensionIndex] / (double) newNpts[horizontalDimensionIndex]);
    PSDimensionSetIncrement(newHorizontalDimension, increment);
    CFRelease(increment);
    
    newVerticalDimension = PSDatasetVerticalDimension(output);
    increment = PSScalarCreateMutableCopy(PSDimensionGetIncrement(newVerticalDimension));
    PSScalarMultiplyByDimensionlessRealConstant(increment, (double) oldNpts[verticalDimensionIndex] / (double) newNpts[verticalDimensionIndex]);
    PSDimensionSetIncrement(newVerticalDimension, increment);
    CFRelease(increment);
    
    FREE(oldNpts);
    FREE(newNpts);

    focus = PSDatasetGetFocus(output);
    PSDatumSetDependentVariableIndex(focus, focusDependentVariableIndex);
    PSDatumSetComponentIndex(focus, focusComponentIndex);
    
    if(newCrossSectionDimensions) CFRelease(newCrossSectionDimensions);
    if(oldCrossSectionDimensions) CFRelease(oldCrossSectionDimensions);
    return output;
}

CFArrayRef PSDatasetCreateMomentAnalysis(PSDatasetRef theDataset, CFRange coordinateIndexRange)
{
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtFocus(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex focusComponentIndex = PSDatumGetComponentIndex(focus);
    CFIndex dimensionsCount = PSDatasetDimensionsCount(theDataset);
    if(dimensionsCount>1) return NULL;
    return PSDependentVariableCreateMomentAnalysis(theDependentVariable,
                                                   theDataset->dimensions,
                                                   coordinateIndexRange,
                                                   focusComponentIndex);
}
@end



