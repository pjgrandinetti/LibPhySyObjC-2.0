//
//  PSDependentVariable.m
//
//  Created by PhySy Ltd on 3/15/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <LibPhySyObjC/PhySyDataset.h>
#include <fftw3.h>

@implementation PSDependentVariable

- (void) dealloc
{
    if(self->name) CFRelease(self->name);
    if(self->quantityName) CFRelease(self->quantityName);
    if(self->quantityType) CFRelease(self->quantityType);
    if(self->description) CFRelease(self->description);
    if(self->sparseDimensionIndexes) CFRelease(self->sparseDimensionIndexes);
    if(self->sparseGridVertexes) CFRelease(self->sparseGridVertexes);

    if(self->components) CFRelease(self->components);
    if(self->componentLabels) CFRelease(self->componentLabels);
    if(self->plot) CFRelease(self->plot);
    [super dealloc];
}

// *************   End Define PSDependentVariable Polymorphic functions

/* Designated Creator */
/**************************/

#pragma mark Creators


bool PSDependentVariableIsScalarType(PSDependentVariableRef theDependentVariable)
{
    if(CFStringCompare(theDependentVariable->quantityType, CFSTR("scalar"), 0)==kCFCompareEqualTo) {
        return true;
    }
    return false;
}

bool PSDependentVariableIsVectorType(PSDependentVariableRef theDependentVariable, CFIndex *componentsCount)
{
    CFIndex stringLength = CFStringGetLength(theDependentVariable->quantityType);
    
    if(stringLength>6 && CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("vector"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(theDependentVariable->quantityType);
        sscanf(cString, "vector_%ld",componentsCount);
        free(cString);
        return true;
    }
    return false;
}

bool PSDependentVariableIsPixelType(PSDependentVariableRef theDependentVariable, CFIndex *componentsCount)
{
    CFIndex stringLength = CFStringGetLength(theDependentVariable->quantityType);
    
   if(stringLength>5 && CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("pixel"), CFRangeMake(0,5), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(theDependentVariable->quantityType);
        sscanf(cString, "pixel_%ld",componentsCount);
        free(cString);
        return true;
    }
    return false;
}

bool PSDependentVariableIsMatrixType(PSDependentVariableRef theDependentVariable, CFIndex *m, CFIndex *n)
{
    CFIndex stringLength = CFStringGetLength(theDependentVariable->quantityType);
    
    if(stringLength>6 && CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("matrix"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(theDependentVariable->quantityType);
        sscanf(cString, "matrix_%ld_%ld",n,m);
        free(cString);
        return true;
    }
    return false;
}


bool PSDependentVariableIsSymmetricMatrixType(PSDependentVariableRef theDependentVariable, CFIndex *n)
{
    CFIndex stringLength = CFStringGetLength(theDependentVariable->quantityType);
    
    if(stringLength>16 && CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("symmetric_matrix"), CFRangeMake(0,16), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(theDependentVariable->quantityType);
        sscanf(cString, "symmetric_matrix_%ld",n);
        free(cString);
        return true;
    }
    return false;
}

static CFIndex componentsCountFromQuantityType(CFStringRef quantityType)
{
    CFIndex stringLength = CFStringGetLength(quantityType);
    if(NULL==quantityType) return 1;
    
    if(CFStringCompare(quantityType, CFSTR("scalar"), 0)==kCFCompareEqualTo) {
        return 1;
    }
    else if(stringLength>5 && CFStringCompareWithOptions(quantityType, CFSTR("pixel"), CFRangeMake(0,5), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        CFIndex n;
        sscanf(cString, "pixel_%ld",&n);
        free(cString);
        return n;
    }
    else if(stringLength>6 && CFStringCompareWithOptions(quantityType, CFSTR("vector"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        CFIndex n;
        sscanf(cString, "vector_%ld",&n);
        free(cString);
        return n;
    }
    else if(stringLength>6 && CFStringCompareWithOptions(quantityType, CFSTR("matrix"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        CFIndex n,m;
        sscanf(cString, "matrix_%ld_%ld",&n,&m);
        free(cString);
        return n*m;
    }
    
    else if(stringLength>16 && CFStringCompareWithOptions(quantityType, CFSTR("symmetric_matrix"), CFRangeMake(0,16), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        CFIndex n;
        sscanf(cString, "symmetric_matrix_%ld",&n);
        free(cString);
        return n*(n+1)/2;
    }
    return kCFNotFound;
}

static bool validateDependentVariableParameters(PSUnitRef unit,
                                                CFStringRef quantityName,
                                                CFStringRef quantityType,
                                                CFArrayRef componentLabels,
                                                CFIndex componentsCount)
{
    if(componentLabels) {
        // Check that all objects in componentLabels array are CFString types
        CFIndex componentLabelsCount = CFArrayGetCount(componentLabels);
        if(componentLabelsCount != componentsCount) return false;
        for(CFIndex index = 0; index<componentLabelsCount; index++) {
            CFTypeRef object = CFArrayGetValueAtIndex(componentLabels, index);
            if(CFGetTypeID(object) != CFStringGetTypeID()) return false;
        }
    }
    
    if(quantityName) {
        PSDimensionalityRef quantityNameDimensionality = PSDimensionalityForQuantityName(quantityName);
        PSDimensionalityRef unitDimensionality = PSUnitGetDimensionality(unit);
        if(!PSDimensionalityEqual(quantityNameDimensionality, unitDimensionality)) return false;
    }
    
    CFIndex stringLength = CFStringGetLength(quantityType);
    
    if(CFStringCompare(quantityType, CFSTR("scalar"), 0)==kCFCompareEqualTo) {
        if(componentsCount!=1) return false;
    }
    else if(stringLength>5 && CFStringCompareWithOptions(quantityType, CFSTR("pixel"), CFRangeMake(0,5), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n;
        sscanf(cString, "pixel_%ld",&n);
        free(cString);
        if(n!=componentsCount) return false;
    }
    else if(stringLength>6 && CFStringCompareWithOptions(quantityType, CFSTR("vector"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n;
        sscanf(cString, "vector_%ld",&n);
        free(cString);
        if(n!=componentsCount) return false;
    }
    else if(stringLength>6 && CFStringCompareWithOptions(quantityType, CFSTR("matrix"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n,m;
        sscanf(cString, "matrix_%ld_%ld",&n,&m);
        free(cString);
        if(n*m!=componentsCount) return false;
    }

    else if(stringLength>16 && CFStringCompareWithOptions(quantityType, CFSTR("symmetric_matrix"), CFRangeMake(0,16), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n;
        sscanf(cString, "symmetric_matrix_%ld",&n);
        free(cString);
        if(n*(n+1)/2!=componentsCount) return false;
    }
    return true;
}

PSDependentVariableRef PSDependentVariableCreateWithComponentsNoCopy(CFStringRef name,
                                                                     CFStringRef description,
                                                                     PSUnitRef unit,
                                                                     CFStringRef quantityName,
                                                                     CFStringRef quantityType,
                                                                     numberType elementType,
                                                                     CFArrayRef componentLabels,
                                                                     CFArrayRef components,
                                                                     PSPlotRef plot,
                                                                     PSDataset *theDataset)
{
    CFIndex componentsCount = 0;
    if(components) {
        // Check that all objects in components array are CFData types
        componentsCount = CFArrayGetCount(components);
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFTypeRef object = CFArrayGetValueAtIndex(components, index);
            if(CFGetTypeID(object) != CFDataGetTypeID()) return NULL;
        }
    }
    
    if(components) {
        // Check that all CFData objects have same length
        componentsCount = CFArrayGetCount(components);
        if(componentsCount) {
            CFDataRef values = CFArrayGetValueAtIndex(components, 0);
            CFIndex length = CFDataGetLength(values);
            for(CFIndex index = 0; index<componentsCount; index++) {
                CFDataRef values = CFArrayGetValueAtIndex(components, index);
                if(length != CFDataGetLength(values)) return NULL;
            }
        }
    }
    
    if(!validateDependentVariableParameters(unit,
                                            quantityName,
                                            quantityType,
                                            componentLabels,
                                            componentsCount)) return NULL;
    
    // Initialize object
    PSDependentVariable *theDependentVariable = [PSDependentVariable alloc];
    
    theDependentVariable->elementType = elementType;
    
    // If unit is NULL, then make this dimensionless and underived
    if(unit) theDependentVariable->unit = unit;
    else theDependentVariable->unit = PSUnitDimensionlessAndUnderived();
    
    if(NULL==quantityName) theDependentVariable->quantityName = CFRetain(PSUnitGuessQuantityName(theDependentVariable->unit));
    else theDependentVariable->quantityName = CFRetain(quantityName);

    theDependentVariable->quantityType = CFRetain(quantityType);
    if(name) theDependentVariable->name = CFRetain(name);
    if(description) theDependentVariable->description = CFRetain(description);

    theDependentVariable->components = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index = 0; index<componentsCount; index++) {
        CFArrayAppendValue(theDependentVariable->components, CFArrayGetValueAtIndex(components, index));
    }
    
    theDependentVariable->componentLabels  = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    if(componentLabels) {
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFStringRef label = CFStringCreateCopy(kCFAllocatorDefault, CFArrayGetValueAtIndex(componentLabels, index));
            CFArrayAppendValue(theDependentVariable->componentLabels, label);
            CFRelease(label);
        }
    }
    else {
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFStringRef name = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("component-%ld"),index);
            CFArrayAppendValue(theDependentVariable->componentLabels, name);
            CFRelease(name);
        }
    }
    
    theDependentVariable->metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    theDependentVariable->dataset = theDataset;
    if(plot && theDataset) {
        theDependentVariable->plot = PSPlotCreateCopyForDependentVariable(plot,theDependentVariable);
        CFArrayRef dimensions = PSDatasetGetDimensions(theDependentVariable->dataset);
        CFIndex dimensionCount = CFArrayGetCount(dimensions);
        if(dimensionCount>1) {
            PSDimensionRef horizontal = PSDatasetHorizontalDimension(theDataset);
            PSDimensionRef vertical = PSDatasetVerticalDimension(theDataset);
            if(PSDimensionHasNonUniformGrid(horizontal) || PSDimensionHasNonUniformGrid(vertical)) PSPlotSetDimensionsCountDisplayed(theDependentVariable->plot, 1);
        }
    }
    else theDependentVariable->plot = NULL;

    return (PSDependentVariableRef) theDependentVariable;
}
PSDependentVariableRef PSDependentVariableCreate(CFStringRef name,
                                                 CFStringRef description,
                                                 PSUnitRef unit,
                                                 CFStringRef quantityName,
                                                 CFStringRef quantityType,
                                                 numberType elementType,
                                                 CFArrayRef componentLabels,
                                                 CFArrayRef components,
                                                 PSPlotRef plot,
                                                 PSDataset *theDataset)
{
    CFIndex componentsCount = 0;
    if(components) {
        // Check that all objects in components array are CFData types
        componentsCount = CFArrayGetCount(components);
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFTypeRef object = CFArrayGetValueAtIndex(components, index);
            if(CFGetTypeID(object) != CFDataGetTypeID()) return NULL;
        }
    }
    
    if(components) {
        // Check that all CFData objects have same length
        componentsCount = CFArrayGetCount(components);
        if(componentsCount) {
            CFDataRef values = CFArrayGetValueAtIndex(components, 0);
            CFIndex length = CFDataGetLength(values);
            for(CFIndex index = 0; index<componentsCount; index++) {
                CFDataRef values = CFArrayGetValueAtIndex(components, index);
                if(length != CFDataGetLength(values)) return NULL;
            }
        }
    }
    
    if(!validateDependentVariableParameters(unit,
                                            quantityName,
                                            quantityType,
                                            componentLabels,
                                            componentsCount)) return NULL;
    
    // Initialize object
    PSDependentVariable *theDependentVariable = [PSDependentVariable alloc];
    
    theDependentVariable->elementType = elementType;
    theDependentVariable->quantityType = CFRetain(quantityType);
    if(name) theDependentVariable->name = CFRetain(name);
    if(description) theDependentVariable->description = CFRetain(description);
    
    // If unit is NULL, then make this dimensionless and underived
    if(unit) theDependentVariable->unit = unit;
    else theDependentVariable->unit = PSUnitDimensionlessAndUnderived();
    
    if(NULL==quantityName) theDependentVariable->quantityName = CFRetain(PSUnitGuessQuantityName(theDependentVariable->unit));
    else theDependentVariable->quantityName = CFRetain(quantityName);

    theDependentVariable->components = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index = 0; index<componentsCount; index++) {
        CFDataRef theComponent = CFArrayGetValueAtIndex(components, index);
        CFMutableDataRef values = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, theComponent);
        CFArrayAppendValue(theDependentVariable->components, values);
        CFRelease(values);
    }
    
    theDependentVariable->componentLabels  = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    if(componentLabels) {
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFStringRef label = CFStringCreateCopy(kCFAllocatorDefault, CFArrayGetValueAtIndex(componentLabels, index));
            CFArrayAppendValue(theDependentVariable->componentLabels, label);
            CFRelease(label);
        }
    }
    else {
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFStringRef name = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("component-%ld"),index);
            CFArrayAppendValue(theDependentVariable->componentLabels, name);
        }
    }

    theDependentVariable->metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    theDependentVariable->dataset = theDataset;
    if(plot && theDataset) {
        theDependentVariable->plot = PSPlotCreateCopyForDependentVariable(plot,theDependentVariable);
        CFArrayRef dimensions = PSDatasetGetDimensions(theDependentVariable->dataset);
        CFIndex dimensionCount = CFArrayGetCount(dimensions);
        if(dimensionCount>1) {
            PSDimensionRef horizontal = PSDatasetHorizontalDimension(theDataset);
            PSDimensionRef vertical = PSDatasetVerticalDimension(theDataset);
            if(PSDimensionHasNonUniformGrid(horizontal) || PSDimensionHasNonUniformGrid(vertical)) PSPlotSetDimensionsCountDisplayed(theDependentVariable->plot, 1);
        }
    }
    else theDependentVariable->plot = NULL;

    return (PSDependentVariableRef) theDependentVariable;
}

PSDependentVariableRef PSDependentVariableCreateWithSize(CFStringRef name,
                                                         CFStringRef description,
                                                         PSUnitRef unit,
                                                         CFStringRef quantityName,
                                                         CFStringRef quantityType,
                                                         numberType elementType,
                                                         CFArrayRef componentLabels,
                                                         CFIndex size,
                                                         PSPlotRef plot,
                                                         PSDataset *theDataset)
{
    CFIndex componentsCount = componentsCountFromQuantityType(quantityType);
    if(componentsCount == kCFNotFound) return NULL;

    if(!validateDependentVariableParameters(unit,
                                            quantityName,
                                            quantityType,
                                            componentLabels,
                                            componentsCount)) return NULL;
    
    // Initialize object
    PSDependentVariable *theDependentVariable = [PSDependentVariable alloc];
    
    theDependentVariable->elementType = elementType;
    theDependentVariable->quantityType = CFRetain(quantityType);
    if(name) theDependentVariable->name = CFRetain(name);
    else theDependentVariable->name = CFSTR("");
    if(description) theDependentVariable->description = CFRetain(description);
    else theDependentVariable->description = CFSTR("");

    // If unit is NULL, then make this dimensionless and underived
    if(unit) theDependentVariable->unit = unit;
    else theDependentVariable->unit = PSUnitDimensionlessAndUnderived();
    
    if(NULL==quantityName) theDependentVariable->quantityName = CFRetain(PSUnitGuessQuantityName(theDependentVariable->unit));
    else theDependentVariable->quantityName = CFRetain(quantityName);

    theDependentVariable->components = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index = 0; index<componentsCount; index++) {
        CFMutableDataRef values = CFDataCreateMutable(kCFAllocatorDefault, 0);
        CFDataSetLength(values, size*PSNumberTypeElementSize(elementType));
        CFArrayAppendValue(theDependentVariable->components, values);
        CFRelease(values);
    }
    
    theDependentVariable->componentLabels  = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    if(componentLabels) {
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFStringRef label = CFStringCreateCopy(kCFAllocatorDefault, CFArrayGetValueAtIndex(componentLabels, index));
            CFArrayAppendValue(theDependentVariable->componentLabels, label);
            CFRelease(label);
        }
    }
    else {
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFStringRef name = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("component-%ld"),index);
            CFArrayAppendValue(theDependentVariable->componentLabels, name);
            CFRelease(name);
        }
    }
    
    theDependentVariable->metaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    theDependentVariable->dataset = theDataset;
    if(plot && theDataset) {
        theDependentVariable->plot = PSPlotCreateCopyForDependentVariable(plot,theDependentVariable);
        CFArrayRef dimensions = PSDatasetGetDimensions(theDependentVariable->dataset);
        CFIndex dimensionCount = CFArrayGetCount(dimensions);
        if(dimensionCount>1) {
            PSDimensionRef horizontal = PSDatasetHorizontalDimension(theDataset);
            PSDimensionRef vertical = PSDatasetVerticalDimension(theDataset);
            if(PSDimensionHasNonUniformGrid(horizontal) || PSDimensionHasNonUniformGrid(vertical)) PSPlotSetDimensionsCountDisplayed(theDependentVariable->plot, 1);
        }
    }
    else theDependentVariable->plot = NULL;
    
    return (PSDependentVariableRef) theDependentVariable;
}

PSDependentVariableRef PSDependentVariableCreateDefault(CFStringRef quantityType,
                                                        numberType elementType,
                                                        CFIndex size,
                                                        PSDataset *theDataset)
{
    return PSDependentVariableCreateWithSize(NULL, NULL, NULL, NULL, quantityType, elementType, NULL, size, NULL, theDataset);
}


PSDependentVariableRef PSDependentVariableCreateWithComponent(CFStringRef name,
                                                              CFStringRef description,
                                                              PSUnitRef unit,
                                                              CFStringRef quantityName,
                                                              numberType elementType,
                                                              CFArrayRef componentLabels,
                                                              CFDataRef component,
                                                              PSPlotRef plot,
                                                              PSDataset *theDataset)
{
    CFMutableArrayRef components = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(components, component);
    PSDependentVariableRef theDependentVariable = PSDependentVariableCreate(name,
                                                                            description,
                                                                            unit,
                                                                            quantityName,
                                                                            CFSTR("scalar"),
                                                                            elementType,
                                                                            componentLabels,
                                                                            components,
                                                                            plot,
                                                                            theDataset);
    CFRelease(components);
    return theDependentVariable;
}


PSDependentVariableRef PSDependentVariableCreateCopy(PSDependentVariableRef theDependentVariable, PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    return PSDependentVariableCreate(theDependentVariable->name,
                                     theDependentVariable->description,
                                     theDependentVariable->unit,
                                     theDependentVariable->quantityName,
                                     theDependentVariable->quantityType,
                                     theDependentVariable->elementType,
                                     theDependentVariable->componentLabels,
                                     theDependentVariable->components,
                                     theDependentVariable->plot,
                                     theDataset);
}

PSDependentVariableRef PSDependentVariableCreateComplexCopy(PSDependentVariableRef theDependentVariable, PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);

    PSDependentVariableRef newDependentVariable = PSDependentVariableCreateCopy(theDependentVariable, theDataset);
    if(!PSQuantityIsComplexType(newDependentVariable)) {
        if(PSQuantityGetElementType(newDependentVariable)==kPSNumberFloat32Type) {
            PSDependentVariableSetElementType(newDependentVariable, kPSNumberFloat32ComplexType);
        }
        else {
            PSDependentVariableSetElementType(newDependentVariable, kPSNumberFloat64ComplexType);
        }
    }
    return newDependentVariable;
}


#pragma mark Accessors

CFDictionaryRef PSDependentVariableGetMetaData(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    return theDependentVariable->metaData;
}

void PSDependentVariableSetMetaData(PSDependentVariableRef theDependentVariable, CFDictionaryRef metaData)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,);
    if(metaData == theDependentVariable->metaData) return;
    if(theDependentVariable->metaData) CFRelease(theDependentVariable->metaData);
    if(metaData) theDependentVariable->metaData = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, metaData);
    else theDependentVariable->metaData = NULL;
}


PSDataset *PSDependentVariableGetDataset(PSDependentVariableRef theDependentVariable)
{
    return theDependentVariable->dataset;
}

void PSDependentVariableSetDataset(PSDependentVariableRef theDependentVariable, PSDataset *theDataset)
{
    if(theDependentVariable->dataset == theDataset) return;
    theDependentVariable->dataset = theDataset;
    if(theDependentVariable->plot) CFRelease(theDependentVariable->plot);
    theDependentVariable->plot = NULL;
}

PSPlotRef PSDependentVariableGetPlot(PSDependentVariableRef theDependentVariable)
{
    if(NULL==theDependentVariable) return NULL;
    if(theDependentVariable->plot) return theDependentVariable->plot;
    if(theDependentVariable->dataset) {
        theDependentVariable->plot = PSPlotCreateWithDependentVariable(theDependentVariable);
        
        CFArrayRef dimensions = PSDatasetGetDimensions(theDependentVariable->dataset);
        CFIndex dimensionCount = CFArrayGetCount(dimensions);
        if(dimensionCount>1) {
            PSDimensionRef horizontal = PSDatasetHorizontalDimension(theDependentVariable->dataset);
            PSDimensionRef vertical = PSDatasetVerticalDimension(theDependentVariable->dataset);
            if(PSDimensionHasNonUniformGrid(horizontal) || PSDimensionHasNonUniformGrid(vertical)) PSPlotSetDimensionsCountDisplayed(theDependentVariable->plot, 1);
        }
        return theDependentVariable->plot;
    }
    return NULL;
}

bool PSDependentVariableSetPlot(PSDependentVariableRef theDependentVariable, PSPlotRef thePlot)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    PSPlotRef newPlot = PSPlotCreateCopyForDependentVariable(thePlot, theDependentVariable);
    if(theDependentVariable->plot) CFRelease(theDependentVariable->plot);
    theDependentVariable->plot = newPlot;
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(),
                                         CFSTR("PlotReplaced"),
                                         thePlot,
                                         NULL,
                                         true);
    return true;
}


CFIndex PSDependentVariableComponentsCount(PSDependentVariableRef theDependentVariable)
{
    if(NULL==theDependentVariable) return 0;
    return CFArrayGetCount(theDependentVariable->components);
}

CFMutableArrayRef PSDependentVariableGetComponents(PSDependentVariableRef theDependentVariable)
{
    return theDependentVariable->components;
}

CFMutableArrayRef PSDependentVariableCopyComponents(PSDependentVariableRef theDependentVariable)
{
    CFMutableArrayRef copy = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    for(CFIndex componentIndex = 0;componentIndex<componentsCount;componentIndex++) {
        CFDataRef component = CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef componentCopy = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, component);
        CFArrayAppendValue(copy, componentCopy);
        CFRelease(componentCopy);
    }
    return copy;
}

CFMutableDataRef PSDependentVariableGetComponentAtIndex(PSDependentVariableRef theDependentVariable, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    return (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
}

bool PSDependentVariableSetComponentAtIndex(PSDependentVariableRef theDependentVariable,
                                            CFDataRef component,
                                            CFIndex componentIndex)
{
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentIndex<0 || componentIndex> componentsCount-1) return false;
    CFDataRef componentToReplace = CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    if(CFDataGetLength(component)!=CFDataGetLength(componentToReplace)) return false;
    CFArraySetValueAtIndex(theDependentVariable->components, componentIndex, component);
    return true;
}

static void updateForComponentCountChange(PSDependentVariableRef theDependentVariable)
{
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("vector"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        CFStringRef newType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("vector_%ld"),componentsCount);
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = newType;
    }
    else if(CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("pixel"), CFRangeMake(0,5), 0)==kCFCompareEqualTo) {
        CFStringRef newType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("pixel_%ld"),componentsCount);
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = newType;
    }
    
    else if(CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("symmetric_matrix"), CFRangeMake(0,16), 0)==kCFCompareEqualTo) {
        // For both matrix and symmetric_matrix there seems to be no choice here but to convert to a vector.
        CFStringRef newType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("vector_%ld"),componentsCount);
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = newType;
    }
    else if(CFStringCompareWithOptions(theDependentVariable->quantityType, CFSTR("matrix"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        CFStringRef newType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("vector_%ld"),componentsCount);
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = newType;
    }
    
    PSPlotSetViewNeedsRegenerated(theDependentVariable->plot,true);
    //    if(theDependentVariable->dataset) {
    //        PSDatasetResetFocus(theDependentVariable->dataset, NULL);
    //    }
}

bool PSDependentVariableInsertComponentAtIndex(PSDependentVariableRef theDependentVariable, CFDataRef component, CFIndex componentIndex)
{
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentIndex<0 || componentIndex> CFArrayGetCount(theDependentVariable->components)) return false;
    if(componentsCount==0 && theDependentVariable->dataset) {
        CFIndex length = PSDimensionCalculateSizeFromDimensions(PSDatasetGetDimensions(theDependentVariable->dataset))*PSQuantityElementSize(theDependentVariable);
        if(CFDataGetLength(component)!=length) return false;
    }
    else {
        CFDataRef firstComponent = CFArrayGetValueAtIndex(theDependentVariable->components, 0);
        if(CFDataGetLength(component)!=CFDataGetLength(firstComponent)) return false;
    }
    CFArrayInsertValueAtIndex(theDependentVariable->components, componentIndex, component);
    if(theDependentVariable->plot) {
        bool showImage2DCombineRGB = PSPlotGetShowImage2DCombineRGB(theDependentVariable->plot);
        PSPlotInsertComponentColorAtIndex(theDependentVariable->plot, componentIndex, kPSPlotColorBlack);
        PSPlotInsertImage2DPlotTypeAtComponentIndex(theDependentVariable->plot, kPSImagePlotTypeHue, componentIndex);
        PSPlotSetShowImage2DCombineRGB(theDependentVariable->plot,showImage2DCombineRGB);
    }
   updateForComponentCountChange(theDependentVariable);
    return true;
}

bool PSDependentVariableRemoveComponentAtIndex(PSDependentVariableRef theDependentVariable, CFIndex componentIndex)
{
    if(componentIndex<0 || componentIndex> CFArrayGetCount(theDependentVariable->components)-1) return false;
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==1) return false;
    
    CFArrayRemoveValueAtIndex(theDependentVariable->components, componentIndex);
    CFArrayRemoveValueAtIndex(theDependentVariable->componentLabels, componentIndex);
    if(theDependentVariable->plot) {
        bool showImage2DCombineRGB = PSPlotGetShowImage2DCombineRGB(theDependentVariable->plot);
        PSPlotRemoveComponentColorAtIndex(theDependentVariable->plot, componentIndex);
        PSPlotRemoveImage2DPlotTypeAtComponentIndex(theDependentVariable->plot, componentIndex);
        PSPlotSetShowImage2DCombineRGB(theDependentVariable->plot,showImage2DCombineRGB);
    }
    updateForComponentCountChange(theDependentVariable);
    return true;
}


CFIndex PSDependentVariableSize(PSDependentVariableRef theDependentVariable)
{
    if(NULL==theDependentVariable) return 0;
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(0==componentsCount) return 0;
    
    CFDataRef values = CFArrayGetValueAtIndex(theDependentVariable->components, 0);
    CFIndex length = CFDataGetLength(values);

    return length/PSNumberTypeElementSize(theDependentVariable->elementType);
}

bool PSDependentVariableSetSize(PSDependentVariableRef theDependentVariable, CFIndex size)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(0==componentsCount) return false;
    
    CFIndex oldSize = PSDependentVariableSize(theDependentVariable);
    CFIndex newLength = size*PSNumberTypeElementSize(theDependentVariable->elementType);
    if(size < oldSize) {
        for(CFIndex index = 0; index<componentsCount; index++) {
            CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, index);
            CFDataSetLength(values, newLength);
        }
        return true;
    }
    
    for(CFIndex index = 0; index<componentsCount; index++) {
        CFDataRef values = CFArrayGetValueAtIndex(theDependentVariable->components, index);
        CFMutableDataRef newValues = CFDataCreateMutableCopy(kCFAllocatorDefault,
                                                             newLength,
                                                             values);
        CFDataSetLength(newValues, newLength);
        CFArraySetValueAtIndex(theDependentVariable->components, index, newValues);
        CFRelease(newValues);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *bytes = (float *) CFDataGetMutableBytePtr(newValues);
                vDSP_vclr(&bytes[oldSize], 1, size-oldSize);
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *) CFDataGetMutableBytePtr(newValues);
                vDSP_vclrD(&bytes[oldSize], 1, size-oldSize);
              break;
            }
            case kPSNumberFloat32ComplexType: {
                float *bytes = (float *) CFDataGetMutableBytePtr(newValues);
                vDSP_vclr(&bytes[2*oldSize], 2, size-oldSize);
                vDSP_vclr(&bytes[2*oldSize+1], 2, size-oldSize);
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double  *bytes = ( double *) CFDataGetMutableBytePtr(newValues);
                vDSP_vclrD(&bytes[2*oldSize], 2, size-oldSize);
                vDSP_vclrD(&bytes[2*oldSize+1], 2, size-oldSize);
                break;
            }
        }
    }
    return true;
}

CFStringRef PSDependentVariableGetName(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    if(theDependentVariable->name) return theDependentVariable->name;
    return CFSTR("");
}

void PSDependentVariableSetName(PSDependentVariableRef theDependentVariable, CFStringRef name)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,);
    if(theDependentVariable->name == name) return;
    if(theDependentVariable->name) CFRelease(theDependentVariable->name);
    theDependentVariable->name = CFRetain(name);
}

CFStringRef PSDependentVariableGetDescription(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    if(theDependentVariable->description) return theDependentVariable->description;
    return CFSTR("");
}

void PSDependentVariableSetDescription(PSDependentVariableRef theDependentVariable, CFStringRef description)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,);
    if(theDependentVariable->description == description) return;
    if(theDependentVariable->description) CFRelease(theDependentVariable->description);
    theDependentVariable->description = CFRetain(description);
}

CFStringRef PSDependentVariableGetQuantityType(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    return theDependentVariable->quantityType;
}

bool PSDependentVariableSetQuantityType(PSDependentVariableRef theDependentVariable, CFStringRef quantityType)
{
    CFIndex stringLength = CFStringGetLength(quantityType);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(CFStringCompare(quantityType, CFSTR("scalar"), 0)==kCFCompareEqualTo) {
        if(componentsCount!=1) return false;
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = CFRetain(quantityType);
        PSPlotSetShowImage2DCombineRGB(theDependentVariable->plot, false);
        return true;
    }
    else if(stringLength>5 && CFStringCompareWithOptions(quantityType, CFSTR("pixel"), CFRangeMake(0,5), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n;
        sscanf(cString, "pixel_%ld",&n);
        free(cString);
        if(n!=componentsCount) return false;
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = CFRetain(quantityType);
        return true;
    }
    else if(stringLength>6 && CFStringCompareWithOptions(quantityType, CFSTR("vector"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n;
        sscanf(cString, "vector_%ld",&n);
        free(cString);
        if(n!=componentsCount) return false;
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = CFRetain(quantityType);
        PSPlotSetShowImage2DCombineRGB(theDependentVariable->plot, false);
        return true;
    }
    else if(stringLength>6 && CFStringCompareWithOptions(quantityType, CFSTR("matrix"), CFRangeMake(0,6), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n,m;
        sscanf(cString, "matrix_%ld_%ld",&n,&m);
        free(cString);
        if(n*m!=componentsCount) return false;
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = CFRetain(quantityType);
        PSPlotSetShowImage2DCombineRGB(theDependentVariable->plot, false);
        return true;
    }
    
    else if(stringLength>16 && CFStringCompareWithOptions(quantityType, CFSTR("symmetric_matrix"), CFRangeMake(0,16), 0)==kCFCompareEqualTo) {
        char *cString = CreateCString(quantityType);
        long n;
        sscanf(cString, "symmetric_matrix_%ld",&n);
        free(cString);
        if(n*(n+1)/2!=componentsCount) return false;
        CFRelease(theDependentVariable->quantityType);
        theDependentVariable->quantityType = CFRetain(quantityType);
        PSPlotSetShowImage2DCombineRGB(theDependentVariable->plot, false);
        return true;
    }
    return false;
}

CFArrayRef PSDependentVariableCreateArrayOfQuantityTypes(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    
    CFMutableArrayRef quantityTypes = CFArrayCreateMutable(kCFAllocatorDefault, 0,&kCFTypeArrayCallBacks);
    
    if(componentsCount==1) CFArrayAppendValue(quantityTypes, CFSTR("scalar"));
    
    CFStringRef vectorType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("vector_%ld"),componentsCount);
    CFArrayAppendValue(quantityTypes, vectorType);
    CFRelease(vectorType);
    
    CFStringRef pixelType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("pixel_%ld"),componentsCount);
    CFArrayAppendValue(quantityTypes, pixelType);
    CFRelease(pixelType);

    for(CFIndex n=0;n<componentsCount;n++) {
        float fn= n;
        if(fn*(fn+1)/2== (float) componentsCount) {
            CFStringRef symmetricMatrixType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("symmetric_matrix_%ld"),n);
            CFArrayAppendValue(quantityTypes, symmetricMatrixType);
            CFRelease(symmetricMatrixType);
        }
    }
    
    for(CFIndex n=0;n<componentsCount;n++) {
        for(CFIndex m=0;m<componentsCount;m++) {
            float fn= n;
            float fm= m;
            if(fn*fm== (float) componentsCount) {
                CFStringRef matrixType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("matrix_%ld_%ld"),m,n);
                CFArrayAppendValue(quantityTypes, matrixType);
                CFRelease(matrixType);
            }
        }
    }
    return quantityTypes;
}

CFStringRef PSDependentVariableGetQuantityName(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    return theDependentVariable->quantityName;
}

bool PSDependentVariableSetQuantityName(PSDependentVariableRef theDependentVariable, CFStringRef quantityName)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    
    if(PSDimensionalityForQuantityName(quantityName)) {
        if(theDependentVariable->quantityName == quantityName) return true;
        
        if(validateDependentVariableParameters(theDependentVariable->unit,
                                                        quantityName,
                                                        theDependentVariable->quantityType,
                                                        theDependentVariable->componentLabels,
                                               PSDependentVariableComponentsCount(theDependentVariable))) {
            if(theDependentVariable->quantityName) CFRelease(theDependentVariable->quantityName);
            theDependentVariable->quantityName = CFRetain(quantityName);
            return true;

        }

        
    }
    return false;
}


CFStringRef PSDependentVariableCreateComponentLabelForIndex(PSDependentVariableRef theDependentVariable,
                                                            CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFMutableStringRef label = CFStringCreateMutable(kCFAllocatorDefault, 0);
    if(theDependentVariable->name) {
        CFStringAppend(label, theDependentVariable->name);
        CFStringAppend(label, CFSTR(" : "));
    }
    if(theDependentVariable->componentLabels) {
        CFStringRef componentName = CFArrayGetValueAtIndex(theDependentVariable->componentLabels, componentIndex);
        CFStringAppend(label, componentName);
    }
    return label;
}

CFStringRef PSDependentVariableGetComponentLabelAtIndex(PSDependentVariableRef theDependentVariable, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    return CFArrayGetValueAtIndex(theDependentVariable->componentLabels, componentIndex);
}

bool PSDependentVariableSetComponentLabelAtIndex(PSDependentVariableRef theDependentVariable, CFStringRef label, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    if(componentIndex<0 || componentIndex> CFArrayGetCount(theDependentVariable->components)-1) return false;
    CFArraySetValueAtIndex(theDependentVariable->componentLabels, componentIndex, label);
    return true;
}

numberType PSDependentVariableGetElementType(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,kCFNotFound);
    return theDependentVariable->elementType;
}

bool PSDependentVariableSetElementType(PSDependentVariableRef theDependentVariable, numberType elementType)
{
    if(theDependentVariable->elementType == elementType) return true;
    if(theDependentVariable->components == NULL) return false;
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    size_t newNumberOfBytes = size*PSNumberTypeElementSize(elementType);
    for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
        CFMutableDataRef oldValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef newValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *old = (float *) CFDataGetMutableBytePtr(oldValues);
                switch (elementType) {
                    case kPSNumberFloat32Type:
                        // Should never get here
                        break;
                    case kPSNumberFloat64Type: {
                        double *new = (double *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *new = (float complex *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *new = (double complex *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64Type: {
                double *old = (double *) CFDataGetMutableBytePtr(oldValues);
                switch (elementType) {
                    case kPSNumberFloat32Type: {
                        float *new = (float *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat64Type:
                        // Should never get here
                        break;
                    case kPSNumberFloat32ComplexType: {
                        float complex *new = (float complex *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *new = (double complex *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *old = (float complex *) CFDataGetMutableBytePtr(oldValues);
                switch (elementType) {
                    case kPSNumberFloat32Type: {
                        float *new = (float *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *new = (double *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat32ComplexType:
                        // Should never get here
                        break;
                    case kPSNumberFloat64ComplexType: {
                        double complex *new = (double complex *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *old = (double complex *) CFDataGetMutableBytePtr(oldValues);
                switch (elementType) {
                    case kPSNumberFloat32Type: {
                        float *new = (float *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *new = (double *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *new = (float complex *) malloc(newNumberOfBytes);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           new[memOffset] = old[memOffset];
                                       }
                                       );
                        CFDataAppendBytes(newValues, (void *) new, newNumberOfBytes);
                        free(new);
                        break;
                    }
                    case kPSNumberFloat64ComplexType:
                        // Should never get here
                        break;
                }
                break;
            }
        }
        
        CFArraySetValueAtIndex(theDependentVariable->components, componentIndex, newValues);
        CFRelease(newValues);
    }
    
    theDependentVariable->elementType = elementType;
    if(!PSQuantityIsComplexType(theDependentVariable)) {
        PSPlotSetImag(theDependentVariable->plot, false);
        PSPlotSetMagnitude(theDependentVariable->plot, false);
        PSPlotSetArgument(theDependentVariable->plot, false);
    }

    return true;
}

bool PSDependentVariableSetValues(PSDependentVariableRef theDependentVariable, CFIndex componentIndex, CFDataRef values)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 || componentIndex<0 || componentIndex >=componentsCount)  return false;
    
    if(componentsCount) {
        CFDataRef values = CFArrayGetValueAtIndex(theDependentVariable->components, 0);
        CFIndex length = CFDataGetLength(values);
        if(length != CFDataGetLength(values)) return false;
    }
    
    CFMutableDataRef oldValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    if(oldValues == values) return true;
    
    CFMutableDataRef newValues = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, values);
    CFArraySetValueAtIndex(theDependentVariable->components, componentIndex, newValues);
    CFRelease(newValues);
    return true;
}

float PSDependentVariableFloatValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                               CFIndex componentIndex,
                                               CFIndex memOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(size==0||componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    
    memOffset = memOffset%size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float *output = (float *) CFDataGetBytePtr(values);
            return output[memOffset];
        }
        case kPSNumberFloat64Type: {
            double *output = (double *) CFDataGetBytePtr(values);
            return (float) output[memOffset];
        }
        case kPSNumberFloat32ComplexType: {
            float complex *output = (float complex *) CFDataGetBytePtr(values);
            return (float) output[memOffset];
        }
        case kPSNumberFloat64ComplexType: {
            double complex *output = (double complex *) CFDataGetBytePtr(values);
            return (float) output[memOffset];
        }
    }
    
    return nan(NULL);
}

double PSDependentVariableDoubleValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                 CFIndex componentIndex,
                                                 CFIndex memOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(size==0 || componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    
    memOffset = memOffset%size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float *output = (float *) CFDataGetBytePtr(values);
            return (double) output[memOffset];
        }
        case kPSNumberFloat64Type: {
            double *output = (double *) CFDataGetBytePtr(values);
            return (double) output[memOffset];
        }
        case kPSNumberFloat32ComplexType: {
            float complex *output = (float complex *) CFDataGetBytePtr(values);
            return (double) output[memOffset];
        }
        case kPSNumberFloat64ComplexType: {
            double complex *output = (double complex *) CFDataGetBytePtr(values);
            return (double) output[memOffset];
        }
    }
    
    return nan(NULL);
}

float complex PSDependentVariableFloatComplexValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                              CFIndex componentIndex,
                                                              CFIndex memOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(size==0||componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    
    memOffset = memOffset%size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float *output = (float *) CFDataGetBytePtr(values);
            return (float complex) output[memOffset];
        }
        case kPSNumberFloat64Type: {
            double *output = (double *) CFDataGetBytePtr(values);
            return (float complex) output[memOffset];
        }
        case kPSNumberFloat32ComplexType: {
            float complex *output = (float complex *) CFDataGetBytePtr(values);
            return (float complex) output[memOffset];
        }
        case kPSNumberFloat64ComplexType: {
            double complex *output = (double complex *) CFDataGetBytePtr(values);
            return (float complex) output[memOffset];
        }
    }
    
    return nan(NULL);
}

double complex PSDependentVariableDoubleComplexValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                                CFIndex componentIndex,
                                                                CFIndex memOffset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(size == 0|| componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    
    memOffset = memOffset%size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float *output = (float *) CFDataGetBytePtr(values);
            return (double complex) output[memOffset];
        }
        case kPSNumberFloat64Type: {
            double *output = (double *) CFDataGetBytePtr(values);
            return (double complex) output[memOffset];
        }
        case kPSNumberFloat32ComplexType: {
            float complex *output = (float complex *) CFDataGetBytePtr(values);
            return (double complex) output[memOffset];
        }
        case kPSNumberFloat64ComplexType: {
            double complex *output = (double complex *) CFDataGetBytePtr(values);
            return (double complex) output[memOffset];
        }
    }
    
    return nan(NULL);
}

double PSDependentVariableDoubleValueAtMemOffsetForPart(PSDependentVariableRef theDependentVariable,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset,
                                                        complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(size==0||componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    
    memOffset = memOffset%size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float *output = (float *) CFDataGetBytePtr(values);
            return (double) output[memOffset];
        }
        case kPSNumberFloat64Type: {
            double *output = (double *) CFDataGetBytePtr(values);
            return (double) output[memOffset];
        }
        case kPSNumberFloat32ComplexType: {
            float complex *output = (float complex *) CFDataGetBytePtr(values);
            switch (part) {
                case kPSRealPart:
                    return crealf(output[memOffset]);
                case kPSImaginaryPart:
                    return cimagf(output[memOffset]);
                case kPSMagnitudePart:
                    return cabsf(output[memOffset]);
                case kPSArgumentPart:
                    return cargument(output[memOffset]);
            }
        }
        case kPSNumberFloat64ComplexType: {
            double complex *output = (double complex *) CFDataGetBytePtr(values);
            switch (part) {
                case kPSRealPart:
                    return creal(output[memOffset]);
                case kPSImaginaryPart:
                    return cimag(output[memOffset]);
                case kPSMagnitudePart:
                    return cabs(output[memOffset]);
                case kPSArgumentPart:
                    return cargument(output[memOffset]);
            }
        }
    }
    
    return nan(NULL);
}

float PSDependentVariableFloatValueAtMemOffsetForPart(PSDependentVariableRef theDependentVariable,
                                                      CFIndex componentIndex,
                                                      CFIndex memOffset,
                                                      complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(size==0||componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    
    memOffset = memOffset%size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float *output = (float *) CFDataGetBytePtr(values);
            return (float) output[memOffset];
        }
        case kPSNumberFloat64Type: {
            double *output = (double *) CFDataGetBytePtr(values);
            return (float) output[memOffset];
        }
        case kPSNumberFloat32ComplexType: {
            float complex *output = (float complex *) CFDataGetBytePtr(values);
            switch (part) {
                case kPSRealPart:
                    return crealf(output[memOffset]);
                case kPSImaginaryPart:
                    return cimagf(output[memOffset]);
                case kPSMagnitudePart:
                    return cabsf(output[memOffset]);
                case kPSArgumentPart:
                    return cargument(output[memOffset]);
            }
        }
        case kPSNumberFloat64ComplexType: {
            double complex *output = (double complex *) CFDataGetBytePtr(values);
            switch (part) {
                case kPSRealPart:
                    return (float) creal(output[memOffset]);
                case kPSImaginaryPart:
                    return (float) cimag(output[memOffset]);
                case kPSMagnitudePart:
                    return (float) cabs(output[memOffset]);
                case kPSArgumentPart:
                    return (float) cargument(output[memOffset]);
            }
        }
    }
    
    return nan(NULL);
}



PSScalarRef PSDependentVariableCreateValueFromMemOffset(PSDependentVariableRef theDependentVariable,
                                                        CFIndex componentIndex,
                                                        CFIndex memOffset)
{
    if(NULL==theDependentVariable) return NULL;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(size==0||componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return NULL;
    
    memOffset = memOffset % size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float *bytes = (float *) CFDataGetMutableBytePtr(values);
            return PSScalarCreateWithFloat(bytes[memOffset], theDependentVariable->unit);
        }
        case kPSNumberFloat64Type: {
            double *bytes = (double *) CFDataGetMutableBytePtr(values);
            return PSScalarCreateWithDouble(bytes[memOffset], theDependentVariable->unit);
        }
        case kPSNumberFloat32ComplexType: {
            float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
            return PSScalarCreateWithFloatComplex(bytes[memOffset], theDependentVariable->unit);
        }
        case kPSNumberFloat64ComplexType: {
            double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
            return PSScalarCreateWithDoubleComplex(bytes[memOffset], theDependentVariable->unit);
        }
    }
    
    return NULL;
}

bool PSDependentVariableSetValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                            CFIndex componentIndex,
                                            CFIndex memOffset,
                                            PSScalarRef value,
                                            CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 || componentIndex<0 || componentIndex >=componentsCount)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) theDependentVariable, (PSQuantityRef) value)) {
        if(error) {
            CFStringRef desc = CFSTR("Set Value, Incompatible Dimensionalities.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    
    //    if(size==0 && memOffset==0) {
    //        for(CFIndex index=0;index<componentsCount;index++) {
    //            CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, index);
    //
    //            CFDataSetLength(values, PSNumberTypeElementSize(theDependentVariable->elementType));
    //            size = PSDependentVariableSize(theDependentVariable);
    //        }
    //    }
    if(size==0) return false;
    
    
    
    
    memOffset = memOffset % size;
    if(memOffset<0) memOffset += size;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            float number =  PSScalarFloatValueInUnit(value, theDependentVariable->unit, NULL);
            float *bytes = (float *) CFDataGetMutableBytePtr(values);
            bytes[memOffset] = number;
            break;
        }
        case kPSNumberFloat64Type: {
            double number =  PSScalarDoubleValueInUnit(value, theDependentVariable->unit, NULL);
            double *bytes = (double *) CFDataGetMutableBytePtr(values);
            bytes[memOffset] = number;
            break;
        }
        case kPSNumberFloat32ComplexType: {
            float complex number =  PSScalarDoubleComplexValueInUnit(value, theDependentVariable->unit, NULL);
            float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
            bytes[memOffset] = number;
            break;
        }
        case kPSNumberFloat64ComplexType: {
            double complex number =  PSScalarDoubleComplexValueInUnit(value, theDependentVariable->unit, NULL);
            double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
            bytes[memOffset] = number;
            break;
        }
    }
    
    return true;
}


double PSDependentVariableComponentFindMaximumForPart(PSDependentVariableRef theDependentVariable,
                                                      CFIndex componentIndex,
                                                      complexPart part,
                                                      CFIndex *memOffsetMax,
                                                      CFErrorRef *error)
{
    if(error) if(*error) return nan(NULL);
    
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 || componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    double max = -DBL_MAX;
    *memOffsetMax = 0;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (part) {
        case kPSRealPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_maxvi (bytes,1,&value,&position,size);
                    *memOffsetMax = position;
                    max = value;
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_maxviD (bytes,1,&value,&position,size);
                    *memOffsetMax = position;
                    max = value;
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_maxvi (bytes,2,&value,&position,size);
                    *memOffsetMax = position/2;
                    max = value;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_maxviD(bytes,2,&value,&position,size);
                    *memOffsetMax = position/2;
                    max = value;
                    break;
                }
            }
            break;
        }
        case kPSImaginaryPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type:
                case kPSNumberFloat64Type:
                    break;
                case kPSNumberFloat32ComplexType: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_maxvi (&bytes[1],2,&value,&position,size);
                    *memOffsetMax = position/2;
                    max = value;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_maxviD(&bytes[1],2,&value,&position,size);
                    *memOffsetMax = position/2;
                    max = value;
                    break;
                }
            }
            break;
        }
        case kPSMagnitudePart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) bytes[memOffset];
                        if(value > max) {
                            max=value;
                            *memOffsetMax = memOffset;
                        }
                    }
                    
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) bytes[memOffset];
                        if(value > max) {
                            max=value;
                            *memOffsetMax = memOffset;
                        }
                    }
                    
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cabsf(bytes[memOffset]);
                        if(value > max) {
                            max=value;
                            *memOffsetMax = memOffset;
                        }
                    }
                    
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cabs(bytes[memOffset]);
                        if(value > max) {
                            max=value;
                            *memOffsetMax = memOffset;
                        }
                    }
                    
                    break;
                }
            }
            break;
        }
        case kPSArgumentPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type:
                case kPSNumberFloat64Type:
                    break;
                case kPSNumberFloat32ComplexType: {
                    float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cargument(bytes[memOffset]);
                        if(value > max) {
                            max=value;
                            *memOffsetMax = memOffset;
                        }
                    }
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cargument(bytes[memOffset]);
                        if(value > max) {
                            max=value;
                            *memOffsetMax = memOffset;
                        }
                    }
                    
                    break;
                }
            }
        }
            
    }
    if(max > DBL_MAX) {
        max = DBL_MAX;
        if(error) {
            CFStringRef desc = CFSTR("Infinite number found.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
    }
    return max;
}

double PSDependentVariableFindMaximumForPart(PSDependentVariableRef theDependentVariable,
                                             complexPart part,
                                             CFIndex *memOffsetMax,
                                             CFIndex *componentIndexMax,
                                             CFErrorRef *error)
{
    if(error) if(*error) return nan(NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    double max = -DBL_MAX;
    *memOffsetMax = 0;
    *componentIndexMax = 0;
    
    CFIndex componentCount = CFArrayGetCount(theDependentVariable->components);
    for(CFIndex componentIndex=0;componentIndex<componentCount; componentIndex++) {
        CFIndex componentMemOffset = 0;
        double componentMax = PSDependentVariableComponentFindMaximumForPart(theDependentVariable,
                                                                             componentIndex,
                                                                             part,
                                                                             &componentMemOffset,
                                                                             error);

        if(componentMax>max) {
            *memOffsetMax = componentMemOffset;
            *componentIndexMax = componentIndex;
            max = componentMax;
        }
    }
    return max;
}


double PSDependentVariableComponentFindMinimumForPart(PSDependentVariableRef theDependentVariable,
                                                      CFIndex componentIndex,
                                                      complexPart part,
                                                      CFIndex *memOffsetMin,
                                                      CFErrorRef *error)
{
    if(error) if(*error) return nan(NULL);
    
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 || componentIndex<0 || componentIndex >=componentsCount)  return nan(NULL);
    
    double min = DBL_MAX;
    *memOffsetMin = 0;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (part) {
        case kPSRealPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_minvi(bytes,1,&value,&position,size);
                    *memOffsetMin = position;
                    min=value;
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_minviD (bytes,1,&value,&position,size);
                    *memOffsetMin = position;
                    min=value;
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_minvi (bytes,2,&value,&position,size);
                    *memOffsetMin = position/2;
                    min=value;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_minviD(bytes,2,&value,&position,size);
                    *memOffsetMin = position/2;
                    min=value;
                    break;
                }
            }
            break;
        }
        case kPSImaginaryPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type:
                case kPSNumberFloat64Type:
                    break;
                case kPSNumberFloat32ComplexType: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_minvi (&bytes[1],2,&value,&position,size);
                    *memOffsetMin = position/2;
                    min=value;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_minviD(&bytes[1],2,&value,&position,size);
                    *memOffsetMin = position/2;
                    min=value;
                    break;
                }
            }
            break;
        }
        case kPSMagnitudePart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) bytes[memOffset];
                        if(value < min) {
                            min=value;
                            *memOffsetMin = memOffset;
                        }
                    }
                    
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) bytes[memOffset];
                        if(value < min) {
                            min=value;
                            *memOffsetMin = memOffset;
                        }
                    }
                    
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cabs(bytes[memOffset]);
                        if(value < min) {
                            min=value;
                            *memOffsetMin = memOffset;
                        }
                    }
                    
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cabs(bytes[memOffset]);
                        if(value < min) {
                            min=value;
                            *memOffsetMin = memOffset;
                        }
                    }
                    
                    break;
                }
            }
            break;
        }
        case kPSArgumentPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type:
                case kPSNumberFloat64Type:
                    break;
                case kPSNumberFloat32ComplexType: {
                    float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cargument(bytes[memOffset]);
                        if(value < min) {
                            min=value;
                            *memOffsetMin = memOffset;
                        }
                    }
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cargument(bytes[memOffset]);
                        if(value < min) {
                            min=value;
                            *memOffsetMin = memOffset;
                        }
                    }
                    
                    break;
                }
            }
        }
            
    }
    
    if(min == DBL_MAX) {
        if(error) {
            CFStringRef desc = CFSTR("Infinite number found.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
    }
    return min;
}

double PSDependentVariableFindMinimumForPart(PSDependentVariableRef theDependentVariable,
                                             complexPart part,
                                             CFIndex *memOffsetMin,
                                             CFIndex *componentIndexMin,
                                             CFErrorRef *error)

{
    if(error) if(*error) return nan(NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,nan(NULL));
    double min = DBL_MAX;
    *memOffsetMin = 0;
    *componentIndexMin = 0;
    
    CFIndex componentCount = CFArrayGetCount(theDependentVariable->components);
    for(CFIndex componentIndex=0;componentIndex<componentCount; componentIndex++) {
        CFIndex componentMemOffset = 0;
        double componentMin = PSDependentVariableComponentFindMinimumForPart(theDependentVariable,
                                                              componentIndex,
                                                              part,
                                                              &componentMemOffset,
                                                              error);

        if(componentMin<min) {
            *memOffsetMin = componentMemOffset;
            *componentIndexMin = componentIndex;
            min = componentMin;
        }
    }
    return min;
}

CFArrayRef PSDependentVariableComponentCreateArrayWithMinAndMaxForPart(PSDependentVariableRef theDependentVariable,
                                                                       CFIndex componentIndex,
                                                                       complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return NULL;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    double min = DBL_MAX;
    double max = -DBL_MAX;
    
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (part) {
        case kPSRealPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_maxvi (bytes,1,&value,&position,size);
                    max = value;
                    vDSP_minvi (bytes,1,&value,&position,size);
                    min = value;
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_maxviD (bytes,1,&value,&position,size);
                    max = value;
                    vDSP_minviD (bytes,1,&value,&position,size);
                    min = value;
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_maxvi (bytes,2,&value,&position,size);
                    max = value;
                    vDSP_minvi (bytes,2,&value,&position,size);
                    min = value;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_maxviD(bytes,2,&value,&position,size);
                    max = value;
                    vDSP_minviD(bytes,2,&value,&position,size);
                    min = value;
                    break;
                }
            }
            break;
        }
        case kPSImaginaryPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type:
                case kPSNumberFloat64Type:
                    break;
                case kPSNumberFloat32ComplexType: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    float value;
                    vDSP_Length position;
                    vDSP_maxvi (&bytes[1],2,&value,&position,size);
                    max = value;
                    vDSP_minvi (&bytes[1],2,&value,&position,size);
                    min = value;
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    double value;
                    vDSP_Length position;
                    vDSP_maxviD(&bytes[1],2,&value,&position,size);
                    max = value;
                    vDSP_minviD(&bytes[1],2,&value,&position,size);
                    min = value;
                    break;
                }
            }
            break;
        }
        case kPSMagnitudePart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *bytes = (float *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) bytes[memOffset];
                        if(value > max) max=value;
                        if(value < min) min=value;
                    }
                    
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *bytes = (double *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) bytes[memOffset];
                        if(value > max) max=value;
                        if(value < min) min=value;
                    }
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cabs(bytes[memOffset]);
                        if(value > max) max=value;
                        if(value < min) min=value;
                    }
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cabs(bytes[memOffset]);
                        if(value > max) max=value;
                        if(value < min) min=value;
                    }
                    break;
                }
            }
            break;
        }
        case kPSArgumentPart: {
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type:
                case kPSNumberFloat64Type:
                    break;
                case kPSNumberFloat32ComplexType: {
                    float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cargument(bytes[memOffset]);
                        if(value > max) max=value;
                        if(value < min) min=value;
                    }
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                    for(CFIndex memOffset=0;memOffset<size;memOffset++) {
                        double value = (double) cargument(bytes[memOffset]);
                        if(value > max) max=value;
                        if(value < min) min=value;
                    }
                    
                    break;
                }
            }
        }
            
    }
    
    if(max >= DBL_MAX) {
        max = DBL_MAX;
    }
    if(min <= -DBL_MAX) {
        min = -DBL_MAX;
    }
    
    PSUnitRef unit = theDependentVariable->unit;
    if(part==kPSArgumentPart) unit = PSUnitForSymbol(CFSTR("rad"));
    
    if(isinf(min)) min = -DBL_MAX;
    if(isinf(max)) max = DBL_MAX;
    PSScalarRef minimum = PSScalarCreateWithDouble(min,unit);
    PSScalarRef maximum = PSScalarCreateWithDouble(max,unit);
    
    PSScalarRef scalarValues[2];
    scalarValues[0] = minimum;
    scalarValues[1] = maximum;
    
    CFArrayRef result = CFArrayCreate(kCFAllocatorDefault,(CFTypeRef *) scalarValues,2,&kCFTypeArrayCallBacks);
    CFRelease(minimum);
    CFRelease(maximum);
    return result;
}

CFArrayRef PSDependentVariableCreateArrayWithMinAndMaxForPart(PSDependentVariableRef theDependentVariable,
                                                              complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentCount = CFArrayGetCount(theDependentVariable->components);
    if(componentCount<1) return NULL;
    
    CFArrayRef array = PSDependentVariableComponentCreateArrayWithMinAndMaxForPart(theDependentVariable, 0, part);
    PSScalarRef minimum = CFRetain(CFArrayGetValueAtIndex(array, 0));
    PSScalarRef maximum = CFRetain(CFArrayGetValueAtIndex(array, 1));
    CFRelease(array);
    
    for(CFIndex componentIndex=1;componentIndex<componentCount; componentIndex++) {
        CFArrayRef array = PSDependentVariableComponentCreateArrayWithMinAndMaxForPart(theDependentVariable,
                                                                                       componentIndex,
                                                                                       part);
        if(PSScalarCompare(minimum, CFArrayGetValueAtIndex(array, 0)) == kPSCompareGreaterThan) {
            CFRelease(minimum);
            minimum = CFRetain(CFArrayGetValueAtIndex(array, 0));
        }
        if(PSScalarCompare(maximum, CFArrayGetValueAtIndex(array, 1)) == kPSCompareLessThan) {
            CFRelease(maximum);
            maximum = CFRetain(CFArrayGetValueAtIndex(array, 1));
        }
        CFRelease(array);
    }
    
    PSScalarRef values[2];
    values[0] = minimum;
    values[1] = maximum;
    
    CFArrayRef result = CFArrayCreate(kCFAllocatorDefault,(CFTypeRef *) values,2,&kCFTypeArrayCallBacks);
    CFRelease(minimum);
    CFRelease(maximum);
    return result;
}



#pragma mark Operations on Values

bool PSDependentVariableConvertToUnit(PSDependentVariableRef theDependentVariable,
                                      PSUnitRef unit,
                                      CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    if(!PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(theDependentVariable->unit),PSUnitGetDimensionality(unit))) {
        if(error==NULL) return false;
        CFStringRef desc = CFSTR("Convert to Unit, Incompatible Dimensionalities.");
        *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                        kPSFoundationErrorDomain,
                                                        0,
                                                        (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                        (const void* const*)&desc,
                                                        1);
        return false;
    }
    double conversion = PSUnitConversion(theDependentVariable->unit,unit);
    theDependentVariable->unit = unit;
    
    for(CFIndex componentIndex = 0; componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        switch(theDependentVariable->elementType) {
            case kPSNumberFloat32Type:  {
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= conversion;
                               }
                               );
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= conversion;
                               }
                               );
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= conversion;
                               }
                               );
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= conversion;
                               }
                               );
                break;
            }
        }
    }
    return false;
}

bool PSDependentVariableSetValuesToZero(PSDependentVariableRef theDependentVariable,
                                        CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 ||  componentIndex >=componentsCount)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(componentIndex>=0) {
        lowerCIndex = componentIndex;
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                vDSP_vclr(bytes, 1, size);
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                vDSP_vclrD(bytes, 1, size);
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float  *bytes = (float  *) CFDataGetMutableBytePtr(values);
                vDSP_vclr(&bytes[0], 2, size);
                vDSP_vclr(&bytes[1], 2, size);
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double  *bytes = (double  *) CFDataGetMutableBytePtr(values);
                vDSP_vclrD(&bytes[0], 2, size);
                vDSP_vclrD(&bytes[1], 2, size);
                break;
            }
        }
    }
    return true;
}


bool PSDependentVariableTakeAbsoluteValue(PSDependentVariableRef theDependentVariable, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 ||  componentIndex >=componentsCount)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(componentIndex>=0) {
        lowerCIndex = componentIndex;
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                vDSP_vabs (bytes,1,bytes,1,size);
                return true;
            }
            case kPSNumberFloat64Type:{
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                vDSP_vabsD(bytes,1,bytes,1,size);
                return true;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                DSPSplitComplex *splitComplex = malloc(sizeof(struct DSPSplitComplex));
                splitComplex->realp = (float *) calloc((size_t) size,sizeof(float));
                splitComplex->imagp = (float *) calloc((size_t) size,sizeof(float));
                vDSP_ctoz((DSPComplex *) bytes,2,splitComplex,1,size);
                
                vDSP_zvabs(splitComplex,1,splitComplex->realp,1,size);
                vDSP_ztoc(splitComplex,1,(DSPComplex *) bytes,2,size);
                
                free(splitComplex->realp);
                free(splitComplex->imagp);
                free(splitComplex);
                PSDependentVariableSetElementType(theDependentVariable, kPSNumberFloat32Type);
                return true;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                DSPDoubleSplitComplex *splitComplex = malloc(sizeof(struct DSPDoubleSplitComplex));
                splitComplex->realp = (double *) calloc((size_t) size,sizeof(double));
                splitComplex->imagp = (double *) calloc((size_t) size,sizeof(double));
                vDSP_ctozD((DSPDoubleComplex *) bytes,2,splitComplex,1,size);
                
                vDSP_zvabsD(splitComplex,1,splitComplex->realp,1,size);
                
                vDSP_ztocD(splitComplex,1,(DSPDoubleComplex *) bytes,2,size);
                
                free(splitComplex->realp);
                free(splitComplex->imagp);
                free(splitComplex);
                PSDependentVariableSetElementType(theDependentVariable, kPSNumberFloat64Type);
                return true;
            }
        }
    }
    return false;
}

bool PSDependentVariableZeroPartInRange(PSDependentVariableRef theDependentVariable,
                                        CFIndex componentIndex,
                                        CFRange range,
                                        complexPart part)
{
    
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 || componentIndex >=componentsCount)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    if(range.location+range.length > size) return false;

    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(componentIndex>=0) {
        lowerCIndex = componentIndex;
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type:  {
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                if(part==kPSRealPart || part==kPSMagnitudePart) vDSP_vclr((float *)&bytes[range.location],1,range.length);
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                if(part==kPSRealPart || part==kPSMagnitudePart) vDSP_vclrD((double *)&bytes[range.location],1,range.length);
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                switch (part) {
                    case kPSRealPart:
                        vDSP_vclr((float *)&bytes[range.location],2,(vDSP_Length) range.length);
                        break;
                    case kPSImaginaryPart: {
                        float *vector = (float *) bytes;
                        vDSP_vclr((float *)&vector[range.location+1],2,(vDSP_Length) range.length);
                        break;
                    }
                    case kPSMagnitudePart:
                        vDSP_vclr((float *)&bytes[range.location],1,2*range.length);
                        break;
                    case kPSArgumentPart: {
                        DSPSplitComplex *splitComplex = malloc(sizeof(struct DSPSplitComplex));
                        splitComplex->realp = (float *) calloc((size_t) size,sizeof(float));
                        splitComplex->imagp = (float *) calloc((size_t) size,sizeof(float));
                        vDSP_ctoz((DSPComplex *) &bytes[range.location],2,splitComplex,1,range.length);
                        
                        vDSP_zvabs(splitComplex,1,(float *)&bytes[range.location],2,range.length);
                        float *vector = (float *) bytes;
                        vDSP_vclr((float *)&vector[range.location+1],2,range.length);
                        free(splitComplex->imagp);
                        free(splitComplex->realp);
                        free(splitComplex);
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                switch (part) {
                    case kPSRealPart:
                        vDSP_vclrD((double *)&bytes[range.location],2,range.length);
                        break;
                    case kPSImaginaryPart: {
                        double *vector = (double *) bytes;
                        vDSP_vclrD((double *)&vector[range.location+1],2,range.length);
                        break;
                    }
                    case kPSMagnitudePart:
                        vDSP_vclrD((double *)&bytes[range.location],1,2*range.length);
                        break;
                    case kPSArgumentPart: {
                        DSPDoubleSplitComplex *splitComplex = malloc(sizeof(struct DSPDoubleSplitComplex));
                        splitComplex->realp = (double *) calloc((size_t) size,sizeof(double));
                        splitComplex->imagp = (double *) calloc((size_t) size,sizeof(double));
                        vDSP_ctozD((DSPDoubleComplex *) &bytes[range.location],2,splitComplex,1,range.length);
                        vDSP_zvabsD(splitComplex,1,(double *)&bytes[range.location],2,range.length);
                        double *vector = (double *) bytes;
                        vDSP_vclrD((double *) &vector[range.location+1],2,size);
                        free(splitComplex->imagp);
                        free(splitComplex->realp);
                        free(splitComplex);
                        break;
                    }
                }
                break;
            }
        }
    }
    return true;
}

bool PSDependentVariableMultiplyValuesByDimensionlessComplexConstant(PSDependentVariableRef theDependentVariable,
                                                                     CFIndex componentIndex,
                                                                     double complex constant)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(componentIndex>=0) {
        lowerCIndex = componentIndex;
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type:  {
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * constant;
                               }
                               );
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * constant;
                               }
                               );
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * constant;
                               }
                               );
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * constant;
                               }
                               );
                break;
            }
        }
    }
    return true;
}


bool PSDependentVariableTakeComplexPart(PSDependentVariableRef theDependentVariable, CFIndex componentIndex, complexPart part)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 || componentIndex >=componentsCount)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    CFRange range = {0,size-1};
  
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type:
        case kPSNumberFloat64Type:
            switch (part) {
                case kPSRealPart:
                    return true;
                case kPSImaginaryPart:
                    PSDependentVariableZeroPartInRange(theDependentVariable, componentIndex, range, kPSRealPart);
                    break;
                case kPSMagnitudePart:
                    PSDependentVariableTakeAbsoluteValue(theDependentVariable, componentIndex);
                    break;
                case kPSArgumentPart:
                    PSDependentVariableZeroPartInRange(theDependentVariable, componentIndex,  range, kPSRealPart);
                    break;
            }
            break;
        case kPSNumberFloat32ComplexType:
            switch (part) {
                case kPSRealPart:
                    PSDependentVariableZeroPartInRange(theDependentVariable, componentIndex, range, kPSImaginaryPart);
                    break;
                case kPSImaginaryPart:
                    PSDependentVariableMultiplyValuesByDimensionlessComplexConstant(theDependentVariable, componentIndex, -I);
                    PSDependentVariableZeroPartInRange(theDependentVariable, componentIndex, range, kPSImaginaryPart);
                    break;
                case kPSMagnitudePart:
                    PSDependentVariableTakeAbsoluteValue(theDependentVariable, componentIndex);
                    break;
                case kPSArgumentPart: {
                    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
                    
                    for(CFIndex memOffset=0; memOffset<size; memOffset++) {
                        float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                        bytes[memOffset] = cargument(bytes[memOffset]);
                    }
                    break;
                }
            }
            break;
        case kPSNumberFloat64ComplexType:
            switch (part) {
                case kPSRealPart:
                    PSDependentVariableZeroPartInRange(theDependentVariable, componentIndex, range, kPSImaginaryPart);
                    break;
                case kPSImaginaryPart:
                    PSDependentVariableMultiplyValuesByDimensionlessComplexConstant(theDependentVariable, componentIndex, -I);
                    PSDependentVariableZeroPartInRange(theDependentVariable, componentIndex, range, kPSImaginaryPart);
                    break;
                case kPSMagnitudePart:
                    PSDependentVariableTakeAbsoluteValue(theDependentVariable, componentIndex);
                    break;
                case kPSArgumentPart: {
                    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
                    for(CFIndex memOffset=0; memOffset<size; memOffset++) {
                        double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                        bytes[memOffset] = cargument(bytes[memOffset]);
                    }
                    break;
                }
            }
            break;
    }
    
    if(componentIndex<0) {
        if(theDependentVariable->elementType == kPSNumberFloat32ComplexType) PSDependentVariableSetElementType(theDependentVariable, kPSNumberFloat32Type);
        else if(theDependentVariable->elementType == kPSNumberFloat64ComplexType) PSDependentVariableSetElementType(theDependentVariable, kPSNumberFloat64Type);
    }
    return true;
}


bool PSDependentVariableConjugate(PSDependentVariableRef theDependentVariable, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 ||  componentIndex >=componentsCount)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(componentIndex>=0) {
        lowerCIndex = componentIndex;
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type:
            case kPSNumberFloat64Type:
                return true;
            case kPSNumberFloat32ComplexType: {
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                DSPSplitComplex *splitComplex = malloc(sizeof(struct DSPSplitComplex));
                splitComplex->realp = (float *) calloc((size_t) size,sizeof(float));
                splitComplex->imagp = (float *) calloc((size_t) size,sizeof(float));
                vDSP_ctoz((DSPComplex *) bytes,2,splitComplex,1,size);
                
                vDSP_zvconj(splitComplex,1,splitComplex,1,size);
                vDSP_ztoc(splitComplex,1,(DSPComplex *) bytes,2,size);
                
                free(splitComplex->realp);
                free(splitComplex->imagp);
                free(splitComplex);
                
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                DSPDoubleSplitComplex *splitComplex = malloc(sizeof(struct DSPDoubleSplitComplex));
                splitComplex->realp = (double *) calloc((size_t) size,sizeof(double));
                splitComplex->imagp = (double *) calloc((size_t) size,sizeof(double));
                vDSP_ctozD((DSPDoubleComplex *) bytes,2,splitComplex,1,size);
                
                vDSP_zvconjD(splitComplex,1,splitComplex,1,size);
                
                vDSP_ztocD(splitComplex,1,(DSPDoubleComplex *) bytes,2,size);
                
                free(splitComplex->realp);
                free(splitComplex->imagp);
                free(splitComplex);
                break;
            }
        }
    }
    return true;
    
}


bool PSDependentVariableMultiplyValuesByDimensionlessRealConstant(PSDependentVariableRef theDependentVariable,
                                                                  CFIndex componentIndex,
                                                                  double constant)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 || componentIndex >=componentsCount)  return false;
    
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(componentIndex>=0) {
        lowerCIndex = componentIndex;
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type:  {
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= constant;
                               }
                               );
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= constant;
                               }
                               );
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= constant;
                               }
                               );
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] *= constant;
                               }
                               );
                break;
            }
        }
    }
    return true;
}

bool PSDependentVariableAddScalarToValueAtMemOffset(PSDependentVariableRef theDependentVariable,
                                                    CFIndex componentIndex,
                                                    CFIndex memOffset,
                                                    PSScalarRef theScalar,
                                                    CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    if(size==0||componentsCount==0 ||  componentIndex >=componentsCount)  return false;
    
    if(!PSQuantityHasSameReducedDimensionality(theDependentVariable,theScalar)) {
        if(error) {
            CFStringRef desc = CFSTR("Add to Memory, Incompatible Dimensionalities.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    
    memOffset = memOffset%size;
    if(memOffset<0) memOffset += size;
    
    PSUnitRef unit = PSQuantityGetUnit(theDependentVariable);
    
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(componentIndex>=0) {
        lowerCIndex = componentIndex;
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex cIndex = lowerCIndex;cIndex<upperCIndex;cIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float number =  PSScalarFloatValueInUnit(theScalar, unit, NULL);
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                bytes[memOffset] += number;
                break;
            }
            case kPSNumberFloat64Type: {
                double number =  PSScalarDoubleValueInUnit(theScalar, unit, NULL);
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                bytes[memOffset] += number;
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex number =  PSScalarDoubleComplexValueInUnit(theScalar, unit, NULL);
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                bytes[memOffset] += number;
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex number =  PSScalarDoubleComplexValueInUnit(theScalar, unit, NULL);
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                bytes[memOffset] += number;
                break;
            }
        }
    }
    return true;
}

bool PSDependentVariableMultiplyByScalar(PSDependentVariableRef theDependentVariable,
                                         PSScalarRef theScalar,
                                         CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theScalar,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0)  return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    
    double unit_multiplier = 1;
    
    PSUnitRef newUnit = PSUnitByMultiplyingWithoutReducing(PSQuantityGetUnit(theDependentVariable), PSQuantityGetUnit(theScalar), &unit_multiplier, error);
    PSQuantitySetUnit(theDependentVariable, newUnit);
    if(theDependentVariable->quantityName) CFRelease(theDependentVariable->quantityName);
    CFStringRef quantityName = PSUnitGuessQuantityName(newUnit);
    theDependentVariable->quantityName = CFStringCreateCopy(kCFAllocatorDefault, quantityName);

    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        
        switch(theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *bytes = (float *) CFDataGetMutableBytePtr(values);
                switch (PSQuantityGetElementType((PSQuantityRef) theScalar)) {
                    case kPSNumberFloat32Type: {
                        float scalarValue = PSScalarFloatValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double scalarValue = PSScalarDoubleValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex scalarValue = PSScalarFloatComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex scalarValue = PSScalarDoubleComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }            }
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *) CFDataGetMutableBytePtr(values);
                switch (PSQuantityGetElementType((PSQuantityRef) theScalar)) {
                    case kPSNumberFloat32Type: {
                        float scalarValue = PSScalarFloatValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double scalarValue = PSScalarDoubleValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex scalarValue = PSScalarFloatComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex scalarValue = PSScalarDoubleComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }            }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
                switch (PSQuantityGetElementType((PSQuantityRef) theScalar)) {
                    case kPSNumberFloat32Type: {
                        float scalarValue = PSScalarFloatValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double scalarValue = PSScalarDoubleValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex scalarValue = PSScalarFloatComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex scalarValue = PSScalarDoubleComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }            }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
                switch (PSQuantityGetElementType((PSQuantityRef) theScalar)) {
                    case kPSNumberFloat32Type: {
                        float scalarValue = PSScalarFloatValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double scalarValue = PSScalarDoubleValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex scalarValue = PSScalarFloatComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex scalarValue = PSScalarDoubleComplexValue(theScalar);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes[memOffset] = bytes[memOffset]*scalarValue*unit_multiplier;
                                       }
                                       );
                        break;
                    }
                        
                }
                break;
            }
        }
    }
    return true;
}


bool PSDependentVariableRaiseValuesToAPower(PSDependentVariableRef theDependentVariable, int power, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0)  return false;
    if(error) if(*error) return false;
    CFIndex size = PSDependentVariableSize(theDependentVariable);
    
    double unit_multiplier = 1;
    PSUnitRef unit = PSUnitByRaisingToAPower(theDependentVariable->unit, power, &unit_multiplier, error);
    theDependentVariable->unit = unit;
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        switch(theDependentVariable->elementType) {
            case kPSNumberFloat32Type:{
                float *bytes = (float *)  CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = pow(bytes[memOffset],power)*unit_multiplier;
                               }
                               );
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes = (double *)  CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = pow(bytes[memOffset],power)*unit_multiplier;
                               }
                               );
                break;
            }
            case kPSNumberFloat32ComplexType:{
                float complex *bytes = (float complex *)  CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = cpow(bytes[memOffset],power)*unit_multiplier;
                               }
                               );
                break;
            }
            case kPSNumberFloat64ComplexType:{
                double complex *bytes = (double complex *)  CFDataGetMutableBytePtr(values);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = cpow(bytes[memOffset],power)*unit_multiplier;
                               }
                               );
                break;
            }
        }
        
    }
    return true;
    
}


#pragma mark Operations requiring two DependentVariable

bool PSDependentVariableAppend(PSDependentVariableRef theDependentVariable,
                               PSDependentVariableRef appendedVariable,
                               CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(appendedVariable,false);
    if(error) if(*error) return false;
    if(!PSQuantityHasSameReducedDimensionality(theDependentVariable, appendedVariable)) {
        if(error) {
            CFStringRef desc = CFSTR("Block Append Error: Incompatible Dimensionalities.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    if(theDependentVariable->elementType != appendedVariable->elementType) {
        if(error) {
            CFStringRef desc = CFSTR("Block Append Error: Incompatible numeric types.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    
    CFIndex componentsCount1 = CFArrayGetCount(theDependentVariable->components);
    CFIndex componentsCount2 = CFArrayGetCount(appendedVariable->components);
    if(componentsCount1==0 || componentsCount2==0)  return false;
    if(componentsCount1!=componentsCount2 && componentsCount1 != 1) return false;
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount1;componentIndex++) {
        CFMutableDataRef destValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef srcValues = (CFMutableDataRef) CFArrayGetValueAtIndex(appendedVariable->components, componentIndex*(componentsCount2!=1));
        CFDataAppendBytes(destValues, CFDataGetBytePtr(srcValues), CFDataGetLength(srcValues));
    }
    return true;
}

bool PSDependentVariableAdd(PSDependentVariableRef input1,
                            PSDependentVariableRef input2,
                            CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    CFIndex componentsCount1 = CFArrayGetCount(input1->components);
    CFIndex componentsCount2 = CFArrayGetCount(input2->components);
    if(componentsCount1==0 || componentsCount2==0)  return false;
    if(componentsCount1!=componentsCount2 && componentsCount1 != 1) return false;
    if(input1==input2) {
        PSDependentVariableMultiplyValuesByDimensionlessRealConstant(input1, -1, 2.);
        return true;
    }

    for(CFIndex componentIndex=0;componentIndex<componentsCount1;componentIndex++) {
        CFMutableDataRef input1Values = (CFMutableDataRef) CFArrayGetValueAtIndex(input1->components, componentIndex);
        CFMutableDataRef input2Values = (CFMutableDataRef) CFArrayGetValueAtIndex(input2->components, componentIndex*(componentsCount2!=1));
        
        CFIndex size = PSDependentVariableSize(input1);
        if(size != PSDependentVariableSize(input2)) {
            if(error) {
                CFStringRef desc = CFSTR("Incompatible component sizes for addition.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            return false;
        }
        if(!PSQuantityHasSameReducedDimensionality(input1,input2)) {
            if(error) {
                CFStringRef desc = CFSTR("DV Add, Incompatible Dimensionalities.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            return false;
        }
        switch (input1->elementType) {
            case kPSNumberFloat32Type: {
                float *bytes1 = (float *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes1 = (double *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes1 = (float complex *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes1 = (double complex *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] + bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
        }
    }
    return true;
}


bool PSDependentVariableSubtract(PSDependentVariableRef input1,
                                 PSDependentVariableRef input2,
                                 CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    CFIndex componentsCount1 = CFArrayGetCount(input1->components);
    CFIndex componentsCount2 = CFArrayGetCount(input1->components);
    if(componentsCount1==0 || componentsCount2==0)  return false;
    if(componentsCount1!=componentsCount2 && componentsCount1 != 1) return false;

    
    for(CFIndex componentIndex=0;componentIndex<componentsCount1;componentIndex++) {
        CFMutableDataRef input1Values = (CFMutableDataRef) CFArrayGetValueAtIndex(input1->components, componentIndex);
        CFMutableDataRef input2Values = (CFMutableDataRef) CFArrayGetValueAtIndex(input2->components, componentIndex*(componentsCount2!=1));
        
        CFIndex size = PSDependentVariableSize(input1);
        if(size != PSDependentVariableSize(input2)) {
            if(error) {
                CFStringRef desc = CFSTR("Incompatible component sizes for addition.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            return false;
        }
        if(!PSQuantityHasSameReducedDimensionality(input1,input2)) {
            if(error) {
                CFStringRef desc = CFSTR("DV Sub, Incompatible Dimensionalities.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            return false;
        }
        switch (input1->elementType) {
            case kPSNumberFloat32Type: {
                float *bytes1 = (float *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes1 = (double *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes1 = (float complex *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes1 = (double complex *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] = bytes1[memOffset] - bytes2[memOffset];
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
        }
    }
    return true;
}

bool PSDependentVariableMultiply(PSDependentVariableRef input1,
                                 PSDependentVariableRef input2,
                                 CFErrorRef *error)
{
    if(error) if(*error) return false;
    
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    if(input1==input2) {
        return PSDependentVariableRaiseValuesToAPower(input1, 2, error);
    }
    
    CFIndex componentsCount1 = CFArrayGetCount(input1->components);
    CFIndex componentsCount2 = CFArrayGetCount(input2->components);
    if(componentsCount1==0 || componentsCount2==0)  return false;
    if(componentsCount1!=componentsCount2 && componentsCount1 != 1) return false;

    if(PSDependentVariableSize(input1) != PSDependentVariableSize(input2)) {
        if(error) {
            CFStringRef desc = CFSTR("Incompatible Block Sizes.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    
    CFIndex size = PSDependentVariableSize(input1);
    double unit_multiplier = 1;
    input1->unit = PSUnitByMultiplying(input1->unit, input2->unit, &unit_multiplier, error);
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount1;componentIndex++) {
        CFMutableDataRef input1Values = (CFMutableDataRef) CFArrayGetValueAtIndex(input1->components, componentIndex);
        CFMutableDataRef input2Values = (CFMutableDataRef) CFArrayGetValueAtIndex(input2->components, componentIndex*(componentsCount2!=1));
        
        switch (input1->elementType) {
            case kPSNumberFloat32Type: {
                float *bytes1 = (float *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64Type: {
                double *bytes1 = (double *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *bytes1 = (float complex *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetMutableBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *bytes1 = (double complex *) CFDataGetMutableBytePtr(input1Values);
                switch (input2->elementType) {
                    case kPSNumberFloat32Type: {
                        float *bytes2 = (float *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double *bytes2 = (double *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex *bytes2 = (float complex *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex *bytes2 = (double complex *) CFDataGetBytePtr(input2Values);
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                        dispatch_apply(size, queue,
                                       ^(size_t memOffset) {
                                           bytes1[memOffset] *= bytes2[memOffset] * unit_multiplier;
                                       }
                                       );
                        break;
                    }
                }
                break;
            }
        }
    }
    return true;
}

bool PSDependentVariableCombineMagnitudeWithArgument(PSDependentVariableRef magnitude, PSDependentVariableRef argument)
{
    IF_NO_OBJECT_EXISTS_RETURN(magnitude,false);
    IF_NO_OBJECT_EXISTS_RETURN(argument,false);
    CFIndex componentsCount1 = CFArrayGetCount(magnitude->components);
    CFIndex componentsCount2 = CFArrayGetCount(argument->components);
    if(componentsCount1==0 || componentsCount2==0)  return false;
    if(componentsCount1!=componentsCount2 && componentsCount1 != 1) return false;

    if(PSQuantityIsComplexType(magnitude) || PSQuantityIsComplexType(argument)) return false;
    numberType finalType = PSQuantityBestComplexElementType(magnitude, argument);
    PSDependentVariableSetElementType(magnitude, finalType);
    
    CFIndex size = PSDependentVariableSize(magnitude);
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount1;componentIndex++) {
        CFMutableDataRef resultValues = (CFMutableDataRef) CFArrayGetValueAtIndex(magnitude->components, componentIndex);
        CFMutableDataRef argumentValues = (CFMutableDataRef) CFArrayGetValueAtIndex(argument->components, componentIndex*(componentsCount2!=1));
        
        if(PSQuantityGetElementType(argument) == kPSNumberFloat32Type) {
            float *phase = (float *) CFDataGetBytePtr(argumentValues);
            if(PSQuantityGetElementType(argument) == kPSNumberFloat32ComplexType) {
                float complex *bytes = (float complex *) CFDataGetBytePtr(resultValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * (cosf(phase[memOffset]) + I*sinf(phase[memOffset])) ;
                               }
                               );
            }
            else {
                double complex *bytes = (double complex *) CFDataGetBytePtr(resultValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * (cosf(phase[memOffset]) + I*sinf(phase[memOffset])) ;
                               }
                               );
            }
        }
        else {
            double *phase = (double *) CFDataGetBytePtr(argumentValues);
            if(PSQuantityGetElementType(argument) == kPSNumberFloat32ComplexType) {
                float complex *bytes = (float complex *) CFDataGetBytePtr(resultValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * (cos(phase[memOffset]) + I*sin(phase[memOffset])) ;
                               }
                               );
            }
            else {
                double complex *bytes = (double complex *) CFDataGetBytePtr(resultValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   bytes[memOffset] = bytes[memOffset] * (cos(phase[memOffset]) + I*sin(phase[memOffset])) ;
                               }
                               );
            }
        }
        
    }
    return true;
}


#pragma mark Operations requiring dimensions

/*
 @functiongroup Operations requiring dimensions
 */

CFArrayRef PSDependentVariableCreateMomentAnalysis(PSDependentVariableRef theDependentVariable,
                                                   CFArrayRef dimensions,
                                                   CFRange coordinateIndexRange,
                                                   CFIndex componentIndex)
{
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount>1) return NULL;
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount>1) return NULL;
    
    CFIndex lowerLimit = coordinateIndexRange.location;
    CFIndex upperLimit = lowerLimit + coordinateIndexRange.length - 1;
    PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, 0);
    PSScalarRef increment = PSDimensionCreateIncrementInDisplayedCoordinate(theDimension);
    
    PSScalarConvertToUnit((PSMutableScalarRef) increment, PSDimensionGetDisplayedUnit(theDimension), NULL);
    double dx = PSScalarDoubleValue(increment);
    CFRelease(increment);
    
    CFMutableArrayRef moments = CFArrayCreateMutable(kCFAllocatorDefault, coordinateIndexRange.length, &kCFTypeArrayCallBacks);
    CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    
    switch (theDependentVariable->elementType) {
        case kPSNumberFloat32Type: {
            double *coordinates = PSDimensionCreateDoubleVectorOfDisplayedCoordinates(theDimension);
            float *bytes = (float *) CFDataGetMutableBytePtr(values);
            
            long double integral = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++)
                integral += bytes[coordinateIndex]*dx;
            
            double multiplier = 1;
            PSUnitRef integralUnit = PSUnitByMultiplying(PSQuantityGetUnit(theDependentVariable), PSDimensionGetDisplayedUnit(theDimension), &multiplier, NULL);
            PSScalarRef integralValue = PSScalarCreateWithDouble(integral*multiplier, integralUnit);
            CFArrayAppendValue(moments, integralValue);
            
            long double mean = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++)
                mean += bytes[coordinateIndex] * coordinates[coordinateIndex] * dx;
            mean = mean/integral;
            
            PSScalarRef meanValue = PSScalarCreateWithDouble(mean, PSDimensionGetDisplayedUnit(theDimension));
            CFArrayAppendValue(moments, meanValue);
            CFRelease(meanValue);
            
            long double variance = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                long double difference = (coordinates[coordinateIndex] - mean);
                variance += bytes[coordinateIndex] * difference * difference * dx;
            }
            variance = variance/integral;
            multiplier = 1;
            PSUnitRef varianceUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), 2, &multiplier, NULL);
            
            PSScalarRef varianceValue = PSScalarCreateWithDouble(variance*multiplier, varianceUnit);
            CFArrayAppendValue(moments, varianceValue);
            CFRelease(varianceValue);
            
            for(CFIndex momentIndex = 3;momentIndex<coordinateIndexRange.length; momentIndex++) {
                long double moment = 0;
                for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                    long double difference = (coordinates[coordinateIndex] - mean)/sqrtl(variance);
                    long double power = powl(difference,(long double) momentIndex);
                    moment += power * bytes[coordinateIndex]*dx;
                }
                moment = moment/integral;
                
                double multiplier = 1;
                PSUnitRef momentUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), (double) momentIndex, &multiplier, NULL);
                if(isnan((double) moment*multiplier)||isinf((double) moment*multiplier)) break;
                
                PSScalarRef momentValue = PSScalarCreateWithDouble(moment*multiplier, momentUnit);
                CFArrayAppendValue(moments, momentValue);
                CFRelease(momentValue);
            }
            break;
        }
        case kPSNumberFloat64Type: {
            double *coordinates = PSDimensionCreateDoubleVectorOfDisplayedCoordinates(theDimension);
            double *bytes = (double *) CFDataGetMutableBytePtr(values);
            
            long double integral = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++)
                integral += bytes[coordinateIndex]*dx;
            
            double multiplier = 1;
            PSUnitRef integralUnit = PSUnitByMultiplying(PSQuantityGetUnit(theDependentVariable), PSDimensionGetDisplayedUnit(theDimension), &multiplier, NULL);
            PSScalarRef integralValue = PSScalarCreateWithDouble(integral*multiplier, integralUnit);
            CFArrayAppendValue(moments, integralValue);
            
            long double mean = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++)
                mean += bytes[coordinateIndex] * coordinates[coordinateIndex] * dx;
            mean = mean/integral;
            
            PSScalarRef meanValue = PSScalarCreateWithDouble(mean, PSDimensionGetDisplayedUnit(theDimension));
            CFArrayAppendValue(moments, meanValue);
            CFRelease(meanValue);
            
            long double variance = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                long double difference = (coordinates[coordinateIndex] - mean);
                variance += bytes[coordinateIndex] * difference * difference * dx;
            }
            variance = variance/integral;
            multiplier = 1;
            PSUnitRef varianceUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), 2, &multiplier, NULL);

            PSScalarRef varianceValue = PSScalarCreateWithDouble(variance*multiplier, varianceUnit);
            CFArrayAppendValue(moments, varianceValue);
            CFRelease(varianceValue);
            
            for(CFIndex momentIndex = 3;momentIndex<coordinateIndexRange.length; momentIndex++) {
                long double moment = 0;
                for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                    long double difference = (coordinates[coordinateIndex] - mean)/sqrtl(variance);
                    long double power = powl(difference,(long double) momentIndex);
                    moment += power * bytes[coordinateIndex]*dx;
                }
                moment = moment/integral;
                
                double multiplier = 1;
                PSUnitRef momentUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), (double) momentIndex, &multiplier, NULL);
                
                if(isnan((double) moment*multiplier)||isinf((double) moment*multiplier)) break;

                PSScalarRef momentValue = PSScalarCreateWithDouble(moment*multiplier, momentUnit);
                CFArrayAppendValue(moments, momentValue);
                CFRelease(momentValue);
            }
            break;
        }
        case kPSNumberFloat32ComplexType: {
            double *coordinates = PSDimensionCreateDoubleVectorOfDisplayedCoordinates(theDimension);
            float complex *bytes = (float complex *) CFDataGetMutableBytePtr(values);
            
            long double integralReal = 0;
            long double integralImag = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                integralReal += creal(bytes[coordinateIndex])*dx;
                integralImag += cimag(bytes[coordinateIndex])*dx;
            }
            
            double multiplier = 1;
            PSUnitRef integralUnit = PSUnitByMultiplying(PSQuantityGetUnit(theDependentVariable), PSDimensionGetDisplayedUnit(theDimension), &multiplier, NULL);
            PSScalarRef integralValue = PSScalarCreateWithDouble((integralReal+I*integralImag)*multiplier, integralUnit);
            CFArrayAppendValue(moments, integralValue);
            
            long double meanReal = 0;
            long double meanImag = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                meanReal += creal(bytes[coordinateIndex]) * coordinates[coordinateIndex] * dx;
                meanImag += cimag(bytes[coordinateIndex]) * coordinates[coordinateIndex] * dx;
            }
            meanReal = meanReal/integralReal;
            meanImag = meanImag/integralImag;
            
            PSScalarRef meanValue = PSScalarCreateWithDoubleComplex(meanReal+I*meanImag, PSDimensionGetDisplayedUnit(theDimension));
            CFArrayAppendValue(moments, meanValue);
            CFRelease(meanValue);
            
            long double varianceReal = 0;
            long double varianceImag = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                long double differenceReal = (coordinates[coordinateIndex] - meanReal);
                long double differenceImag = (coordinates[coordinateIndex] - meanImag);
                varianceReal += creal(bytes[coordinateIndex]) * differenceReal * differenceReal * dx;
                varianceImag += creal(bytes[coordinateIndex]) * differenceImag * differenceImag * dx;
            }
            varianceReal = varianceReal/integralReal;
            varianceImag = varianceImag/integralImag;
            multiplier = 1;
            PSUnitRef varianceUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), 2, &multiplier, NULL);
            
            PSScalarRef varianceValue = PSScalarCreateWithDoubleComplex((varianceReal+I*varianceImag)*multiplier, varianceUnit);
            CFArrayAppendValue(moments, varianceValue);
            CFRelease(varianceValue);
            
            for(CFIndex momentIndex = 3;momentIndex<coordinateIndexRange.length; momentIndex++) {
                long double momentReal = 0;
                long double momentImag = 0;
                for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                    long double differenceReal = (coordinates[coordinateIndex] - meanReal)/sqrtl(varianceReal);
                    long double differenceImag = (coordinates[coordinateIndex] - meanImag)/sqrtl(varianceImag);
                    long double powerReal = powl(differenceReal,(long double) momentIndex);
                    long double powerImag = powl(differenceImag,(long double) momentIndex);
                    momentReal += powerReal * creal(bytes[coordinateIndex]) * dx;
                    momentImag += powerImag * creal(bytes[coordinateIndex]) * dx;
                }
                momentReal = momentReal/integralReal;
                momentImag = momentImag/integralImag;
                
                double multiplier = 1;
                PSUnitRef momentUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), (double) momentIndex, &multiplier, NULL);
                if(isnan((double) momentReal*multiplier)||isinf((double) momentReal*multiplier)) break;
                if(isnan((double) momentImag*multiplier)||isinf((double) momentImag*multiplier)) break;
                
                PSScalarRef momentValue = PSScalarCreateWithDoubleComplex((momentReal+I*momentImag)*multiplier, momentUnit);
                CFArrayAppendValue(moments, momentValue);
                CFRelease(momentValue);
                
            }
            break;
        }
        case kPSNumberFloat64ComplexType: {
            double *coordinates = PSDimensionCreateDoubleVectorOfDisplayedCoordinates(theDimension);
            double complex *bytes = (double complex *) CFDataGetMutableBytePtr(values);
            
            long double integralReal = 0;
            long double integralImag = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                integralReal += creal(bytes[coordinateIndex])*dx;
                integralImag += cimag(bytes[coordinateIndex])*dx;
            }
            
            double multiplier = 1;
            PSUnitRef integralUnit = PSUnitByMultiplying(PSQuantityGetUnit(theDependentVariable), PSDimensionGetDisplayedUnit(theDimension), &multiplier, NULL);
            PSScalarRef integralValue = PSScalarCreateWithDouble((integralReal+I*integralImag)*multiplier, integralUnit);
            CFArrayAppendValue(moments, integralValue);
            
            long double meanReal = 0;
            long double meanImag = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                meanReal += creal(bytes[coordinateIndex]) * coordinates[coordinateIndex] * dx;
                meanImag += cimag(bytes[coordinateIndex]) * coordinates[coordinateIndex] * dx;
            }
            meanReal = meanReal/integralReal;
            meanImag = meanImag/integralImag;
            
            PSScalarRef meanValue = PSScalarCreateWithDoubleComplex(meanReal+I*meanImag, PSDimensionGetDisplayedUnit(theDimension));
            CFArrayAppendValue(moments, meanValue);
            CFRelease(meanValue);
            
            long double varianceReal = 0;
            long double varianceImag = 0;
            for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                long double differenceReal = (coordinates[coordinateIndex] - meanReal);
                long double differenceImag = (coordinates[coordinateIndex] - meanImag);
                varianceReal += creal(bytes[coordinateIndex]) * differenceReal * differenceReal * dx;
                varianceImag += creal(bytes[coordinateIndex]) * differenceImag * differenceImag * dx;
            }
            varianceReal = varianceReal/integralReal;
            varianceImag = varianceImag/integralImag;
            multiplier = 1;
            PSUnitRef varianceUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), 2, &multiplier, NULL);
            
            PSScalarRef varianceValue = PSScalarCreateWithDoubleComplex((varianceReal+I*varianceImag)*multiplier, varianceUnit);
            CFArrayAppendValue(moments, varianceValue);
            CFRelease(varianceValue);
            
            for(CFIndex momentIndex = 3;momentIndex<coordinateIndexRange.length; momentIndex++) {
                long double momentReal = 0;
                long double momentImag = 0;
                for(CFIndex coordinateIndex = lowerLimit; coordinateIndex<=upperLimit;coordinateIndex++) {
                    long double differenceReal = (coordinates[coordinateIndex] - meanReal)/sqrtl(varianceReal);
                    long double differenceImag = (coordinates[coordinateIndex] - meanImag)/sqrtl(varianceImag);
                    long double powerReal = powl(differenceReal,(long double) momentIndex);
                    long double powerImag = powl(differenceImag,(long double) momentIndex);
                    momentReal += powerReal * creal(bytes[coordinateIndex]) * dx;
                    momentImag += powerImag * creal(bytes[coordinateIndex]) * dx;
                }
                momentReal = momentReal/integralReal;
                momentImag = momentImag/integralImag;
                
                double multiplier = 1;
                PSUnitRef momentUnit = PSUnitByRaisingToAPower(PSDimensionGetDisplayedUnit(theDimension), (double) momentIndex, &multiplier, NULL);
                if(isnan((double) momentReal*multiplier)||isinf((double) momentReal*multiplier)) break;
                if(isnan((double) momentImag*multiplier)||isinf((double) momentImag*multiplier)) break;
                
                PSScalarRef momentValue = PSScalarCreateWithDoubleComplex((momentReal+I*momentImag)*multiplier, momentUnit);
                CFArrayAppendValue(moments, momentValue);
                CFRelease(momentValue);
                
            }
            break;
        }
    }
    return moments;
}


bool PSDependentVariableShiftAlongDimension(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFIndex dimensionIndex,
                                            CFIndex shift,
                                            bool wrap,
                                            CFIndex level)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex *npts = (CFIndex *) calloc(dimensionsCount,sizeof(CFIndex));
    bool *fft = (bool *) calloc(dimensionsCount,sizeof(bool));
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, idim);
        npts[idim] = PSDimensionGetNpts(theDimension);
        fft[idim] = PSDimensionGetFFT(theDimension);
    }
    bool left = shift<0;
    bool nowrap = !wrap;
    CFIndex absShift = labs(shift);
    
    CFMutableArrayRef components = PSDependentVariableCopyComponents(theDependentVariable);
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(level>1) {
        lowerCIndex = PSDatumGetComponentIndex(PSDatasetGetFocus(theDependentVariable->dataset));
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex componentIndex=lowerCIndex;componentIndex<upperCIndex;componentIndex++) {
        CFMutableDataRef values = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        
        CFMutableDataRef outputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(components, componentIndex);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *old = (float *) CFDataGetMutableBytePtr(values);
                float *new = (float *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, npts);
                                   indexes[dimensionIndex] += shift;
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   new[newMemOffset] = old[memOffset];
                                   if(nowrap) {
                                       if(left) {
                                           if(indexes[dimensionIndex] >= npts[dimensionIndex] - absShift) new[newMemOffset] = 0;
                                       }
                                       else {
                                           if(indexes[dimensionIndex] <= absShift) new[newMemOffset] = 0;
                                       }
                                   }
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64Type: {
                double *old = (double *) CFDataGetMutableBytePtr(values);
                double *new = (double *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, npts);
                                   indexes[dimensionIndex] += shift;
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   new[newMemOffset] = old[memOffset];
                                   if(nowrap) {
                                       if(left) {
                                           if(indexes[dimensionIndex] >= npts[dimensionIndex] - absShift) new[newMemOffset] = 0;
                                       }
                                       else {
                                           if(indexes[dimensionIndex] <= absShift) new[newMemOffset] = 0;
                                       }
                                   }
                               }
                               );
                
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *old = (float complex *) CFDataGetMutableBytePtr(values);
                float complex *new = (float complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, npts);
                                   indexes[dimensionIndex] += shift;
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   new[newMemOffset] = old[memOffset];
                                   if(nowrap) {
                                       if(left) {
                                           if(indexes[dimensionIndex] >= npts[dimensionIndex] - absShift) new[newMemOffset] = 0;
                                       }
                                       else {
                                           if(indexes[dimensionIndex] <= absShift) new[newMemOffset] = 0;
                                       }
                                   }
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *old = (double complex *) CFDataGetMutableBytePtr(values);
                double complex *new = (double complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(size, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, npts);
                                   indexes[dimensionIndex] += shift;
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   new[newMemOffset] = old[memOffset];
                                   if(nowrap) {
                                       if(left) {
                                           if(indexes[dimensionIndex] >= npts[dimensionIndex] - absShift) new[newMemOffset] = 0;
                                       }
                                       else {
                                           if(indexes[dimensionIndex] <= absShift) new[newMemOffset] = 0;
                                       }
                                   }
                               }
                               );
                
                break;
            }
        }
    }
    
    FREE(npts);
    FREE(fft);
    CFRelease(theDependentVariable->components);
    theDependentVariable->components = components;
    return true;
}


bool PSDependentVariableAddParsedExpression(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFStringRef expression,
                                            CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount != 0) return false;
    size_t size = PSDimensionCalculateSizeFromDimensions(dimensions);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex componentIndex = 0;
    
    for(CFIndex memOffset = 0; memOffset<size; memOffset++) {
        CFMutableStringRef express = CFStringCreateMutableCopy(kCFAllocatorDefault,
                                                               CFStringGetLength(expression),
                                                               expression);
        
        PSScalarRef response = PSDependentVariableCreateValueFromMemOffset(theDependentVariable, componentIndex, memOffset);
        CFStringRef value = PSScalarCreateStringValue(response);
        CFStringRef valueInParentheses = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("(%@)"),value);
        CFAutorelease(response);
        CFStringFindAndReplace(express, CFSTR("$r"), valueInParentheses, CFRangeMake(0,CFStringGetLength(express)), 0);
        CFAutorelease(value);
        CFAutorelease(valueInParentheses);
        
        CFArrayRef coordinates = PSDimensionCreateDisplayedCoordinatesFromMemOffset(dimensions, memOffset);
        for(CFIndex index = 0;index<dimensionsCount; index++) {
            CFStringRef variable = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("$%ld"),index);
            CFStringRef value = PSScalarCreateStringValue(CFArrayGetValueAtIndex(coordinates, index));
            CFStringRef valueInParentheses = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("(%@)"),value);
            CFStringFindAndReplace(express, variable, valueInParentheses, CFRangeMake(0,CFStringGetLength(express)), 0);
            CFAutorelease(variable);
            CFAutorelease(value);
            CFAutorelease(valueInParentheses);
        }
        CFAutorelease(coordinates);
        
        PSScalarRef result = PSScalarCreateWithCFString(express, error);
        
        
        if(result) {
            if(memOffset==0) {
                theDependentVariable->unit = PSQuantityGetUnit(result);
            }
            
            PSDependentVariableSetValueAtMemOffset(theDependentVariable, componentIndex, memOffset, result, error);
            CFAutorelease(result);
        }
        
        CFAutorelease(express);
        
        if(error) if(*error) {
            return false;
        }
        
    }
    return true;
}

void PSDependentVariableTransposeDimensions(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFIndex dimensionIndex1,
                                            CFIndex dimensionIndex2)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    if(dimensionsCount<2) return ;
    if(dimensionIndex1>dimensionsCount-1) return ;
    if(dimensionIndex2>dimensionsCount-1) return ;
    if(dimensionIndex1 == dimensionIndex2) return;
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    
    CFMutableArrayRef newComponents = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    if(dimensionsCount==2) {
        CFIndex npts[dimensionsCount];
        bool fft[dimensionsCount];
        for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
            PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, idim);
            npts[idim] = PSDimensionGetNpts(theDimension);
            fft[idim] = PSDimensionGetFFT(theDimension);
        }

        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFMutableDataRef inputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
            CFMutableDataRef outputValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
            CFDataSetLength(outputValues, size*PSNumberTypeElementSize(theDependentVariable->elementType));

            CFArrayAppendValue(newComponents, outputValues);
            CFRelease(outputValues);
            
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *old = (float *) CFDataGetBytePtr(inputValues);
                    float *new = (float *) CFDataGetBytePtr(outputValues);
                    if(dimensionIndex1 <dimensionIndex2)
                        vDSP_mtrans(old,1,new,1,npts[dimensionIndex1],npts[dimensionIndex2]);
                    else vDSP_mtrans(old,1,new,1,npts[dimensionIndex2],npts[dimensionIndex1]);
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *old = (double *) CFDataGetBytePtr(inputValues);
                    double *new = (double *) CFDataGetBytePtr(outputValues);
                    if(dimensionIndex1 <dimensionIndex2)
                        vDSP_mtransD(old,1,new,1,npts[dimensionIndex1],npts[dimensionIndex2]);
                    else vDSP_mtransD(old,1,new,1,npts[dimensionIndex2],npts[dimensionIndex1]);
                    break;
                }
                    
                case kPSNumberFloat32ComplexType: {
                    float *old = (float *) CFDataGetBytePtr(inputValues);
                    float *new = (float *) CFDataGetBytePtr(outputValues);
                    if(dimensionIndex1 <dimensionIndex2)
                        vDSP_mtrans(old,2,new,2,npts[dimensionIndex1],npts[dimensionIndex2]);
                    else vDSP_mtrans(old,2,new,2,npts[dimensionIndex2],npts[dimensionIndex1]);
                    
                    if(dimensionIndex1 <dimensionIndex2)
                        vDSP_mtrans(&old[1],2,&new[1],2,npts[dimensionIndex1],npts[dimensionIndex2]);
                    else vDSP_mtrans(&old[1],2,&new[1],2,npts[dimensionIndex2],npts[dimensionIndex1]);
                    
                    break;
                }
                    
                case kPSNumberFloat64ComplexType: {
                    double *old = (double *) CFDataGetBytePtr(inputValues);
                    double *new = (double *) CFDataGetBytePtr(outputValues);
                    if(dimensionIndex1 <dimensionIndex2)
                        vDSP_mtransD(old,2,new,2,npts[dimensionIndex1],npts[dimensionIndex2]);
                    else vDSP_mtransD(old,2,new,2,npts[dimensionIndex2],npts[dimensionIndex1]);
                    
                    if(dimensionIndex1 <dimensionIndex2)
                        vDSP_mtransD(&old[1],2,&new[1],2,npts[dimensionIndex1],npts[dimensionIndex2]);
                    else vDSP_mtransD(&old[1],2,&new[1],2,npts[dimensionIndex2],npts[dimensionIndex1]);
                    
                    break;
                }
            }
        }
    }
    else {
        CFIndex srcNpts[dimensionsCount];
        bool srcFFT[dimensionsCount];
        for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
            PSDimensionRef theDimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, idim);
            srcNpts[idim] = PSDimensionGetNpts(theDimension);
            srcFFT[idim] = PSDimensionGetFFT(theDimension);
        }
        CFIndex dstNpts[dimensionsCount];
        bool dstFFT[dimensionsCount];
        for(int index = 0; index<dimensionsCount;index++) {
            dstNpts[index] = srcNpts[index];
            dstFFT[index] = srcNpts[index];
        }
        CFIndex temp = dstNpts[dimensionIndex1];
        dstNpts[dimensionIndex1] = dstNpts[dimensionIndex2];
        dstNpts[dimensionIndex2] = temp;

        bool btemp = dstFFT[dimensionIndex1];
        dstFFT[dimensionIndex1] = dstFFT[dimensionIndex2];
        dstFFT[dimensionIndex2] = btemp;

        CFIndex srcIndexes[dimensionsCount];
        CFIndex dstIndexes[dimensionsCount];
        CFIndex size = PSDependentVariableSize(theDependentVariable);
        
        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFMutableDataRef inputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
            CFMutableDataRef outputValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
            CFDataSetLength(outputValues, size*PSNumberTypeElementSize(theDependentVariable->elementType));
            CFArrayAppendValue(newComponents, outputValues);
            CFRelease(outputValues);
            
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *src = (float *) CFDataGetBytePtr(inputValues);
                    float *dst = (float *) CFDataGetBytePtr(outputValues);
                    
                    for(CFIndex srcMemOffset = 0; srcMemOffset<size; srcMemOffset++) {
                        setIndexesForMemOffset(srcMemOffset,srcIndexes, dimensionsCount, srcNpts);
                        for(int index = 0; index<dimensionsCount;index++) dstIndexes[index] = srcIndexes[index];
                        
                        CFIndex temp = dstIndexes[dimensionIndex1];
                        dstIndexes[dimensionIndex1] = dstIndexes[dimensionIndex2];
                        dstIndexes[dimensionIndex2] = temp;
                        CFIndex destMemOffset = memOffsetFromIndexes(dstIndexes, dimensionsCount, dstNpts);
                        
                        dst[destMemOffset] = src[srcMemOffset];
                    }
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *src = (double *) CFDataGetBytePtr(inputValues);
                    double *dst = (double *) CFDataGetBytePtr(outputValues);
                    
                    CFIndex size = PSDependentVariableSize(theDependentVariable);
                    for(CFIndex srcMemOffset = 0; srcMemOffset<size; srcMemOffset++) {
                        setIndexesForMemOffset(srcMemOffset,srcIndexes, dimensionsCount, srcNpts);
                        for(int index = 0; index<dimensionsCount;index++) dstIndexes[index] = srcIndexes[index];
                        
                        CFIndex temp = dstIndexes[dimensionIndex1];
                        dstIndexes[dimensionIndex1] = dstIndexes[dimensionIndex2];
                        dstIndexes[dimensionIndex2] = temp;
                        CFIndex destMemOffset = memOffsetFromIndexes(dstIndexes, dimensionsCount, dstNpts);
                        
                        dst[destMemOffset] = src[srcMemOffset];
                    }
                    break;
                }
                    
                case kPSNumberFloat32ComplexType: {
                    float complex *src = (float complex *) CFDataGetBytePtr(inputValues);
                    float complex *dst = (float complex *) CFDataGetBytePtr(outputValues);
                    
                    CFIndex size = PSDependentVariableSize(theDependentVariable);
                    for(CFIndex srcMemOffset = 0; srcMemOffset<size; srcMemOffset++) {
                        setIndexesForMemOffset(srcMemOffset,srcIndexes, dimensionsCount, srcNpts);
                        for(int index = 0; index<dimensionsCount;index++) dstIndexes[index] = srcIndexes[index];
                        
                        CFIndex temp = dstIndexes[dimensionIndex1];
                        dstIndexes[dimensionIndex1] = dstIndexes[dimensionIndex2];
                        dstIndexes[dimensionIndex2] = temp;
                        CFIndex destMemOffset = memOffsetFromIndexes(dstIndexes, dimensionsCount, dstNpts);
                        
                        dst[destMemOffset] = src[srcMemOffset];
                    }
                    break;
                }
                    
                case kPSNumberFloat64ComplexType: {
                    double complex *src = (double complex *) CFDataGetBytePtr(inputValues);
                    double complex *dst = (double complex *) CFDataGetBytePtr(outputValues);
                    
                    for(CFIndex srcMemOffset = 0; srcMemOffset<size; srcMemOffset++) {
                        setIndexesForMemOffset(srcMemOffset,srcIndexes, dimensionsCount, srcNpts);
                        for(int index = 0; index<dimensionsCount;index++) dstIndexes[index] = srcIndexes[index];
                        
                        CFIndex temp = dstIndexes[dimensionIndex1];
                        dstIndexes[dimensionIndex1] = dstIndexes[dimensionIndex2];
                        dstIndexes[dimensionIndex2] = temp;
                        CFIndex destMemOffset = memOffsetFromIndexes(dstIndexes, dimensionsCount, dstNpts);
                        
                        dst[destMemOffset] = src[srcMemOffset];
                    }
                    break;
                }
            }
        }
        
    }
    
    CFRelease(theDependentVariable->components);
    theDependentVariable->components = newComponents;
}

bool PSDependentVariableInterleaveAlongDimension(PSDependentVariableRef input1,
                                                 PSDependentVariableRef input2,
                                                 CFArrayRef dimensions,
                                                 CFIndex interleavedDimensionIndex,
                                                 CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    if(PSDependentVariableSize(input1) != PSDependentVariableSize(input2)) return false;
    CFIndex componentsCount1 = CFArrayGetCount(input1->components);
    CFIndex componentsCount2 = CFArrayGetCount(input2->components);
    if(componentsCount1!=componentsCount2) return false;
    if(componentsCount1 == 0) return false;
    
    //    if(!PSDependentVariableHaveSameMetaCoordinates(signal1, signal2)) return NULL;
    PSDimensionRef theDimension = (PSDimensionRef) CFArrayGetValueAtIndex(dimensions, interleavedDimensionIndex);
    if(PSDimensionHasNonUniformGrid(theDimension)) return false;
    
    numberType elementType = PSQuantityBestElementType(input1, input2);
    
    PSDimensionRef newDimension = PSDimensionCreateCopy(theDimension);
    PSDimensionSetNpts(newDimension, PSDimensionGetNpts(theDimension)*2);
    CFMutableArrayRef newDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, dimensions);
    CFArraySetValueAtIndex(newDimensions, interleavedDimensionIndex, newDimension);
    CFRelease(newDimension);
    
    CFMutableArrayRef crossSectionDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, dimensions);
    CFArrayRemoveValueAtIndex(crossSectionDimensions, interleavedDimensionIndex);
    
    CFIndex newSize = PSDimensionCalculateSizeFromDimensions(newDimensions);
    
    PSDependentVariableRef output = PSDependentVariableCreateWithSize(input1->name,
                                                                      input1->description,
                                                                      input1->unit,
                                                                      input1->quantityName,
                                                                      input1->quantityType,
                                                                      elementType,
                                                                      input1->componentLabels,
                                                                      newSize,NULL, NULL);
    
    for(CFIndex index = 0;index<PSDimensionGetNpts(theDimension); index++) {
        
        PSIndexPairSetRef indexPair = PSIndexPairSetCreateWithIndexPair(interleavedDimensionIndex,index);
        PSDependentVariableRef crossSection1 = PSDependentVariableCreateCrossSection(input1,dimensions,indexPair,error);
        CFRelease(indexPair);
        
        indexPair = PSIndexPairSetCreateWithIndexPair(interleavedDimensionIndex, 2*index);
        PSDependentVariableSetCrossSection(output, newDimensions, indexPair, crossSection1, crossSectionDimensions);
        CFRelease(indexPair);
        
        CFRelease(crossSection1);
        
        indexPair = PSIndexPairSetCreateWithIndexPair(interleavedDimensionIndex,index);
        PSDependentVariableRef crossSection2 = PSDependentVariableCreateCrossSection(input2, dimensions, indexPair, error);
        CFRelease(indexPair);
        
        indexPair = PSIndexPairSetCreateWithIndexPair(interleavedDimensionIndex,2*index+1);
        PSDependentVariableSetCrossSection(output, newDimensions, indexPair, crossSection2, crossSectionDimensions);
        CFRelease(indexPair);
        
        CFRelease(crossSection2);
    }
    CFRelease(newDimensions);
    CFRelease(crossSectionDimensions);
    
    CFRelease(input1->components);
    input1->components = output->components;
    CFRetain(input1->components);
    CFRelease(output);
    return true;
}




bool PSDependentVariableProjectOutDimension(PSDependentVariableRef theDependentVariable,
                                            CFArrayRef dimensions,
                                            CFIndex lowerIndex,
                                            CFIndex upperIndex,
                                            CFIndex dimIndex,
                                            CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex projectionDimensionsCount = dimensionsCount - 1;
    if(projectionDimensionsCount<0) return false;
    
    if(projectionDimensionsCount==0) {
        CFIndex size = 1;
        CFMutableArrayRef newComponents = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFIndex reducedSize = upperIndex - lowerIndex + 1;
        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFMutableDataRef outputValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
            CFDataSetLength(outputValues, size*PSNumberTypeElementSize(theDependentVariable->elementType));
            CFArrayAppendValue(newComponents, outputValues);
            CFRelease(outputValues);
            for(CFIndex reducedIndex = 0; reducedIndex<reducedSize; reducedIndex++) {
                CFIndex coordinateIndex = reducedIndex + lowerIndex;
                PSScalarRef theScalar = PSDependentVariableCreateValueFromMemOffset(theDependentVariable,
                                                                                componentIndex,
                                                                                coordinateIndex);
                switch (theDependentVariable->elementType) {
                    case kPSNumberFloat32Type: {
                        float number =  PSScalarFloatValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        float *bytes = (float *) CFDataGetMutableBytePtr(outputValues);
                        bytes[0] += number;
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double number =  PSScalarDoubleValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        double *bytes = (double *) CFDataGetMutableBytePtr(outputValues);
                        bytes[0] += number;
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex number =  PSScalarDoubleComplexValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        float complex *bytes = (float complex *) CFDataGetMutableBytePtr(outputValues);
                        bytes[0] += number;
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex number =  PSScalarDoubleComplexValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        double complex *bytes = (double complex *) CFDataGetMutableBytePtr(outputValues);
                        bytes[0] += number;
                        break;
                    }
                }
                CFRelease(theScalar);
            }
        }
        CFRelease(theDependentVariable->components);
        theDependentVariable->components = newComponents;
        return true;
    }
    
    if(projectionDimensionsCount==1) {
        CFIndex size = PSDimensionGetNpts((PSDimensionRef) CFArrayGetValueAtIndex(dimensions, 1-dimIndex));
        CFMutableArrayRef newComponents = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

        
        // Add theDependentVariable into Projection
        CFIndex reducedSize = upperIndex - lowerIndex + 1;
        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFMutableDataRef outputValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
            CFDataSetLength(outputValues, size*PSNumberTypeElementSize(theDependentVariable->elementType));
            CFArrayAppendValue(newComponents, outputValues);
            CFRelease(outputValues);

            for(CFIndex reducedIndex = 0; reducedIndex<reducedSize; reducedIndex++) {
                CFIndex projectedOutCoordinateIndex = reducedIndex + lowerIndex;
                
                // Create coordinateIndexes for theDependentVariable
                PSMutableIndexArrayRef coordinateIndexes = PSIndexArrayCreateMutable(dimensionsCount);
                
                PSIndexArraySetValueAtIndex(coordinateIndexes, dimIndex, projectedOutCoordinateIndex);
                for(CFIndex projectionCoordinateIndex = 0; projectionCoordinateIndex<size; projectionCoordinateIndex++) {
                    PSIndexArraySetValueAtIndex(coordinateIndexes, 1-dimIndex, projectionCoordinateIndex);
                    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, coordinateIndexes);
                    PSScalarRef theScalar = PSDependentVariableCreateValueFromMemOffset(theDependentVariable,
                                                                                        componentIndex,
                                                                                        memOffset);
                    switch (theDependentVariable->elementType) {
                        case kPSNumberFloat32Type: {
                            float number =  PSScalarFloatValueInUnit(theScalar, theDependentVariable->unit, NULL);
                            float *bytes = (float *) CFDataGetMutableBytePtr(outputValues);
                            bytes[projectionCoordinateIndex] += number;
                            break;
                        }
                        case kPSNumberFloat64Type: {
                            double number =  PSScalarDoubleValueInUnit(theScalar, theDependentVariable->unit, NULL);
                            double *bytes = (double *) CFDataGetMutableBytePtr(outputValues);
                            bytes[projectionCoordinateIndex] += number;
                            break;
                        }
                        case kPSNumberFloat32ComplexType: {
                            float complex number =  PSScalarDoubleComplexValueInUnit(theScalar, theDependentVariable->unit, NULL);
                            float complex *bytes = (float complex *) CFDataGetMutableBytePtr(outputValues);
                            bytes[projectionCoordinateIndex] += number;
                            break;
                        }
                        case kPSNumberFloat64ComplexType: {
                            double complex number =  PSScalarDoubleComplexValueInUnit(theScalar, theDependentVariable->unit, NULL);
                            double complex *bytes = (double complex *) CFDataGetMutableBytePtr(outputValues);
                            bytes[projectionCoordinateIndex] += number;
                            break;
                        }
                    }
                    CFRelease(theScalar);
                }
                CFRelease(coordinateIndexes);
            }
        }
        
        CFRelease(theDependentVariable->components);
        theDependentVariable->components = newComponents;
        return true;
    }
    
    // Setup array of dimension for crossSection signal
    CFMutableArrayRef projectionDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, dimensions);
    CFArrayRemoveValueAtIndex(projectionDimensions, dimIndex);
    CFIndex projectionSize = PSDimensionCalculateSizeFromDimensions(projectionDimensions);
    CFMutableArrayRef newComponents = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    // Set up theDataset index.   Rest will come from cross-section
    // Create index array for mapping between dataset dimensionIndexes and self dimensionIndexes
    CFIndex *indexMap = calloc(projectionDimensionsCount, sizeof(CFIndex));
    CFIndex index = 0;
    for(CFIndex idim = 0; idim<dimensionsCount; idim++)
        if(dimIndex!=idim) indexMap[index++] = idim;
    
    // Fill Projection Dataset
    CFIndex reducedSize = upperIndex - lowerIndex + 1;
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef outputValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
        CFDataSetLength(outputValues, projectionSize*PSNumberTypeElementSize(theDependentVariable->elementType));
        CFArrayAppendValue(newComponents, outputValues);
        CFRelease(outputValues);

        for(CFIndex reducedIndex = 0; reducedIndex<reducedSize; reducedIndex++) {
            CFIndex projectedOutCoordinateIndex = reducedIndex + lowerIndex;
            
            PSMutableIndexArrayRef coordinateIndexes = PSIndexArrayCreateMutable(dimensionsCount);
            PSIndexArraySetValueAtIndex(coordinateIndexes, dimIndex, projectedOutCoordinateIndex);
            for(CFIndex memOffset = 0; memOffset<projectionSize; memOffset++) {
                // Setup projection dataset indexes
                PSIndexArrayRef signalCoordinateIndexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(projectionDimensions, memOffset);
                
                for(CFIndex idim = 0; idim<projectionDimensionsCount; idim++) {
                    PSIndexArraySetValueAtIndex(coordinateIndexes, indexMap[idim], PSIndexArrayGetValueAtIndex(signalCoordinateIndexValues, idim));
                }
                
                // Add from theDataset to projection
                PSScalarRef theScalar = PSDependentVariableCreateValueFromMemOffset(theDependentVariable,
                                                                                componentIndex,
                                                                                PSDimensionMemOffsetFromCoordinateIndexes(dimensions, coordinateIndexes));
                
                switch (theDependentVariable->elementType) {
                    case kPSNumberFloat32Type: {
                        float number =  PSScalarFloatValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        float *bytes = (float *) CFDataGetMutableBytePtr(outputValues);
                        bytes[memOffset] += number;
                        break;
                    }
                    case kPSNumberFloat64Type: {
                        double number =  PSScalarDoubleValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        double *bytes = (double *) CFDataGetMutableBytePtr(outputValues);
                        bytes[memOffset] += number;
                        break;
                    }
                    case kPSNumberFloat32ComplexType: {
                        float complex number =  PSScalarDoubleComplexValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        float complex *bytes = (float complex *) CFDataGetMutableBytePtr(outputValues);
                        bytes[memOffset] += number;
                        break;
                    }
                    case kPSNumberFloat64ComplexType: {
                        double complex number =  PSScalarDoubleComplexValueInUnit(theScalar, theDependentVariable->unit, NULL);
                        double complex *bytes = (double complex *) CFDataGetMutableBytePtr(outputValues);
                        bytes[memOffset] += number;
                        break;
                    }
                }
                CFRelease(theScalar);
                CFRelease(signalCoordinateIndexValues);
            }
            
            CFRelease(coordinateIndexes);
        }
    }
    
    free(indexMap);
    
    CFRelease(projectionDimensions);
    CFRelease(theDependentVariable->components);
    theDependentVariable->components = newComponents;
    return true;
}

bool PSDependentVariableCrossSection(PSDependentVariableRef theDependentVariable,
                                     CFArrayRef theDependentVariableDimensions,
                                     PSIndexPairSetRef indexPairs,
                                     CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    CFIndex allDimensionsCount = CFArrayGetCount(theDependentVariableDimensions);
    CFIndex crossSectionDimensionsCount = allDimensionsCount - PSIndexPairSetGetCount(indexPairs);
    if(crossSectionDimensionsCount> allDimensionsCount || crossSectionDimensionsCount<0) return false;
    if(crossSectionDimensionsCount == allDimensionsCount) return true;
    if(crossSectionDimensionsCount == 0) {
        CFIndex size = 1;
        CFMutableArrayRef newComponents = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

        PSIndexArrayRef coordinateIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
        CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDependentVariableDimensions, coordinateIndexes);
        
        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFMutableDataRef crossSectionValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
            CFDataSetLength(crossSectionValues, size*PSNumberTypeElementSize(theDependentVariable->elementType));
            CFArrayAppendValue(newComponents, crossSectionValues);
            CFRelease(crossSectionValues);

            CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
            
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                    float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                    double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                    float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                    double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
            }
        }
        
        CFRelease(theDependentVariable->components);
        theDependentVariable->components = newComponents;
        return true;
    }
    
    CFIndex crossSectionSize = 1;
    CFIndex signalCoordinateIndexes[allDimensionsCount];
    CFIndex signalNpts[allDimensionsCount];
    bool signalFFT[allDimensionsCount];
    CFIndex crossSectionNpts[crossSectionDimensionsCount];
    bool crossSectionFFT[crossSectionDimensionsCount];
    CFIndex stride[allDimensionsCount];
    CFIndex iCrossDim = 0;
    
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(theDependentVariableDimensions, idim);
        signalNpts[idim] = PSDimensionGetNpts(theDimension);
        signalFFT[idim] = PSDimensionGetFFT(theDimension);
        signalCoordinateIndexes[idim] = 0;
        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
            crossSectionSize *= signalNpts[idim];
            crossSectionFFT[iCrossDim] = signalFFT[idim];
            crossSectionNpts[iCrossDim++] = signalNpts[idim];
        }
        else signalCoordinateIndexes[idim] = PSIndexPairSetValueForIndex(indexPairs, idim);
    }
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        stride[idim] =  strideAlongDimensionIndex(signalNpts, allDimensionsCount, idim);
    }
    CFMutableArrayRef newComponents = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef crossSectionValues = CFDataCreateMutable(kCFAllocatorDefault, 0);
        CFDataSetLength(crossSectionValues, crossSectionSize*PSNumberTypeElementSize(theDependentVariable->elementType));
        CFArrayAppendValue(newComponents, crossSectionValues);
        CFRelease(crossSectionValues);
        
        CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
            case kPSNumberFloat64Type: {
                
                double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                        }
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
        }
    }
    CFRelease(theDependentVariable->components);
    theDependentVariable->components = newComponents;
    return true;

}


PSDependentVariableRef PSDependentVariableReverseAlongDimension(PSDependentVariableRef theDependentVariable,
                                                                CFArrayRef dimensions,
                                                                CFIndex dimensionIndex,
                                                                CFIndex level)
{

    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    PSDependentVariableRef output = theDependentVariable;
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    PSDatumRef focus = PSDatasetGetFocus(theDependentVariable->dataset);
    PSDimensionRef reversedDimension = CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    CFIndex size = PSDependentVariableSize(output);
    
    CFIndex reducedSize = size/PSDimensionGetNpts(reversedDimension);
    
    CFIndex *npts = calloc(sizeof(CFIndex), dimensionsCount);
    bool *fft = calloc(sizeof(bool), dimensionsCount);
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions,idim);
        npts[idim] = PSDimensionGetNpts(theDimension);
        fft[idim] = PSDimensionGetFFT(theDimension);
    }
    vDSP_Length length = npts[dimensionIndex];
    vDSP_Stride stride = strideAlongDimensionIndex(npts, dimensionsCount, dimensionIndex);
    
    CFIndex lowerCIndex = 0;
    CFIndex upperCIndex = componentsCount;
    if(level>1) {
        lowerCIndex = PSDatumGetComponentIndex(focus);
        upperCIndex = lowerCIndex+1;
    }
    
    for(CFIndex componentIndex=lowerCIndex;componentIndex<upperCIndex;componentIndex++) {
        CFMutableDataRef outputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(output->components, componentIndex);
        
        switch (output->elementType) {
            case kPSNumberFloat32Type: {
                float *responses = (float *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(reducedSize, queue,
                               ^(size_t reducedMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   indexes[dimensionIndex] = 0;
                                   setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes, dimensionsCount, npts, dimensionIndex);
                                   CFIndex memOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   vDSP_vrvrs(&responses[memOffset],stride,length);
                               }
                               );
                break;
            }
            case kPSNumberFloat64Type: {
                double *responses = (double *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(reducedSize, queue,
                               ^(size_t reducedMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   indexes[dimensionIndex] = 0;
                                   setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes, dimensionsCount, npts, dimensionIndex);
                                   CFIndex memOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   vDSP_vrvrsD(&responses[memOffset],stride,length);
                               }
                               );
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *responses = (float complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(reducedSize, queue,
                               ^(size_t reducedMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   indexes[dimensionIndex] = 0;
                                   setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes, dimensionsCount, npts, dimensionIndex);
                                   CFIndex memOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   float *values = (float *) &responses[memOffset];
                                   vDSP_vrvrs(&values[0],2*stride,length);
                                   vDSP_vrvrs(&values[1],2*stride,length);
                               }
                               );
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *responses = (double complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(reducedSize, queue,
                               ^(size_t reducedMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   indexes[dimensionIndex] = 0;
                                   setIndexesForReducedMemOffsetIgnoringDimension(reducedMemOffset, indexes, dimensionsCount, npts, dimensionIndex);
                                   CFIndex memOffset = memOffsetFromIndexes(indexes, dimensionsCount, npts);
                                   double *values = (double *) &responses[memOffset];
                                   vDSP_vrvrsD(&values[0],2*stride,length);
                                   vDSP_vrvrsD(&values[1],2*stride,length);
                               }
                               );
            }
                break;
        }
    }
    
    if(fft[dimensionIndex]&&npts[dimensionIndex]%2==0)     PSDependentVariableShiftAlongDimension(theDependentVariable,dimensions,dimensionIndex,1,true,level);

    FREE(npts);
    FREE(fft);
    
    

    return output;
}


bool PSDependentVariableSetValueAtCoordinateIndexes(PSDependentVariableRef theDependentVariable,
                                                    CFIndex componentIndex,
                                                    CFArrayRef dimensions,
                                                    PSIndexArrayRef theIndexes,
                                                    PSScalarRef value,
                                                    CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(value,false);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount==0 ||  componentIndex<0 || componentIndex >=componentsCount)  return false;
    
    CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
    return PSDependentVariableSetValueAtMemOffset(theDependentVariable,
                                                  componentIndex,
                                                  memOffset,
                                                  value,
                                                  error);
}

bool PSDependentVariableSetCrossSection(PSDependentVariableRef theDependentVariable,
                                        CFArrayRef theDependentVariableDimensions,
                                        PSIndexPairSetRef indexPairs,
                                        PSDependentVariableRef theCrossSection,
                                        CFArrayRef theCrossSectionDimensions)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theCrossSection,false);
    if(theDependentVariable == theCrossSection) return true;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariableDimensions,false);
    IF_NO_OBJECT_EXISTS_RETURN(indexPairs,false);
    IF_NO_OBJECT_EXISTS_RETURN(theCrossSectionDimensions,false);
    
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    
    CFIndex allDimensionsCount = CFArrayGetCount(theDependentVariableDimensions);
    CFIndex crossSectionDimensionsCount = allDimensionsCount - PSIndexPairSetGetCount(indexPairs);
    if(crossSectionDimensionsCount != CFArrayGetCount(theCrossSectionDimensions)) return false;
    
    if(crossSectionDimensionsCount == 0) {
        PSIndexArrayRef coordinateIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
        CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDependentVariableDimensions, coordinateIndexes);
        
        for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
            CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
            CFMutableDataRef crossSectionValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theCrossSection->components, componentIndex);
            
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                    float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] = crossSectionBytes[0];
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                    double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] = crossSectionBytes[0];
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                    float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] = crossSectionBytes[0];
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                    double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] = crossSectionBytes[0];
                    break;
                }
            }
        }
        return true;
    }
    
    CFIndex crossSectionSize = 1;
    CFIndex signalCoordinateIndexes[allDimensionsCount];
    CFIndex signalNpts[allDimensionsCount];
    bool signalFFT[allDimensionsCount];
    CFIndex crossSectionNpts[crossSectionDimensionsCount];
    bool crossSectionFFT[crossSectionDimensionsCount];
    CFIndex stride[allDimensionsCount];
    CFIndex iCrossDim = 0;
    
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(theDependentVariableDimensions, idim);
        signalNpts[idim] = PSDimensionGetNpts(theDimension);
        signalFFT[idim] = PSDimensionGetFFT(theDimension);
        signalCoordinateIndexes[idim] = 0;
        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
            crossSectionSize *= signalNpts[idim];
            crossSectionFFT[iCrossDim] = signalFFT[idim];
            crossSectionNpts[iCrossDim++] = signalNpts[idim];
        }
        else signalCoordinateIndexes[idim] = PSIndexPairSetValueForIndex(indexPairs, idim);
    }
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        stride[idim] =  strideAlongDimensionIndex(signalNpts, allDimensionsCount, idim);
    }
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef crossSectionValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theCrossSection->components, componentIndex);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] = crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
            case kPSNumberFloat64Type: {
                double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                        }
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] = crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] = crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] = crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
        }
    }
    return true;
}

bool PSDependentVariableAddInCrossSection(PSDependentVariableRef theDependentVariable,
                                          CFArrayRef theDependentVariableDimensions,
                                          PSIndexPairSetRef indexPairs,
                                          PSDependentVariableRef theCrossSection,
                                          CFArrayRef theCrossSectionDimensions)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theCrossSection,false);
    if(theDependentVariable == theCrossSection) return true;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariableDimensions,false);
    IF_NO_OBJECT_EXISTS_RETURN(indexPairs,false);
    IF_NO_OBJECT_EXISTS_RETURN(theCrossSectionDimensions,false);
    
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    
    CFIndex allDimensionsCount = CFArrayGetCount(theDependentVariableDimensions);
    CFIndex crossSectionDimensionsCount = allDimensionsCount - PSIndexPairSetGetCount(indexPairs);
    if(crossSectionDimensionsCount != CFArrayGetCount(theCrossSectionDimensions)) return false;
    
    if(crossSectionDimensionsCount == 0) {
        PSIndexArrayRef coordinateIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
        CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDependentVariableDimensions, coordinateIndexes);
        
        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
            CFMutableDataRef crossSectionValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theCrossSection->components, componentIndex);
            
            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                    float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] += crossSectionBytes[0];
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                    double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] += crossSectionBytes[0];
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                    float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] += crossSectionBytes[0];
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                    double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    signalBytes[memOffset] += crossSectionBytes[0];
                    break;
                }
            }
        }
        return true;
    }
    
    CFIndex crossSectionSize = 1;
    CFIndex signalCoordinateIndexes[allDimensionsCount];
    CFIndex signalNpts[allDimensionsCount];
    bool signalFFT[allDimensionsCount];
    CFIndex crossSectionNpts[crossSectionDimensionsCount];
    bool crossSectionFFT[crossSectionDimensionsCount];
    CFIndex stride[allDimensionsCount];
    CFIndex iCrossDim = 0;
    
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(theDependentVariableDimensions, idim);
        signalNpts[idim] = PSDimensionGetNpts(theDimension);
        signalFFT[idim] = PSDimensionGetFFT(theDimension);
        signalCoordinateIndexes[idim] = 0;
        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
            crossSectionSize *= signalNpts[idim];
            crossSectionFFT[iCrossDim] = signalFFT[idim];
            crossSectionNpts[iCrossDim++] = signalNpts[idim];
        }
        else signalCoordinateIndexes[idim] = PSIndexPairSetValueForIndex(indexPairs, idim);
    }
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        stride[idim] =  strideAlongDimensionIndex(signalNpts, allDimensionsCount, idim);
    }
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef crossSectionValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theCrossSection->components, componentIndex);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] += crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
            case kPSNumberFloat64Type: {
                double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                        }
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] += crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] += crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes,  crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    signalBytes[signalMemOffset] += crossSectionBytes[crossSectionMemOffset];
                }
                break;
            }
        }
    }
    return true;
}



PSDependentVariableRef PSDependentVariableCreateCrossSection(PSDependentVariableRef theDependentVariable,
                                                             CFArrayRef theDependentVariableDimensions,
                                                             PSIndexPairSetRef indexPairs,
                                                             CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    CFIndex allDimensionsCount = CFArrayGetCount(theDependentVariableDimensions);
    CFIndex crossSectionDimensionsCount = allDimensionsCount - PSIndexPairSetGetCount(indexPairs);
    if(crossSectionDimensionsCount> allDimensionsCount || crossSectionDimensionsCount<0) return NULL;
    if(crossSectionDimensionsCount == allDimensionsCount) return PSDependentVariableCreateCopy(theDependentVariable, NULL);
    if(crossSectionDimensionsCount == 0) {
        PSIndexArrayRef coordinateIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
        CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(theDependentVariableDimensions, coordinateIndexes);
        
        PSDependentVariableRef theCrossSection = PSDependentVariableCreateWithSize(theDependentVariable->name,
                                                                                   theDependentVariable->description,
                                                                                   theDependentVariable->unit,
                                                                                   theDependentVariable->quantityName,
                                                                                   theDependentVariable->quantityType,
                                                                                   theDependentVariable->elementType,
                                                                                   theDependentVariable->componentLabels,
                                                                                   1,NULL,NULL);

        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
            CFMutableDataRef crossSectionValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theCrossSection->components, componentIndex);

            switch (theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                    float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                    double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                    float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                    double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                    crossSectionBytes[0] = signalBytes[memOffset];
                    break;
                }
            }
        }
        return theCrossSection;
    }
    
    CFIndex crossSectionSize = 1;
    CFIndex signalCoordinateIndexes[allDimensionsCount];
    CFIndex signalNpts[allDimensionsCount];
    bool signalFFT[allDimensionsCount];
    CFIndex crossSectionNpts[crossSectionDimensionsCount];
    bool crossSectionFFT[crossSectionDimensionsCount];
    CFIndex stride[allDimensionsCount];
    CFIndex iCrossDim = 0;
    
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        PSDimensionRef theDimension = CFArrayGetValueAtIndex(theDependentVariableDimensions, idim);
        signalNpts[idim] = PSDimensionGetNpts(theDimension);
        signalFFT[idim] = PSDimensionGetFFT(theDimension);
        signalCoordinateIndexes[idim] = 0;
        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
            crossSectionSize *= signalNpts[idim];
            crossSectionFFT[iCrossDim] = signalFFT[idim];
            crossSectionNpts[iCrossDim++] = signalNpts[idim];
        }
        else signalCoordinateIndexes[idim] = PSIndexPairSetValueForIndex(indexPairs, idim);
    }
    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
        stride[idim] =  strideAlongDimensionIndex(signalNpts, allDimensionsCount, idim);
    }
    
    PSDependentVariableRef theCrossSection = PSDependentVariableCreateWithSize(theDependentVariable->name,
                                                                               theDependentVariable->description,
                                                                               theDependentVariable->unit,
                                                                               theDependentVariable->quantityName,
                                                                               theDependentVariable->quantityType,
                                                                               theDependentVariable->elementType,
                                                                               theDependentVariable->componentLabels,
                                                                               crossSectionSize, NULL,NULL);
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef crossSectionValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theCrossSection->components, componentIndex);

        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *signalBytes = (float *) CFDataGetBytePtr(dependentVariableValues);
                float *crossSectionBytes = (float *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
            case kPSNumberFloat64Type: {
                
                double *signalBytes = (double *) CFDataGetBytePtr(dependentVariableValues);
                double *crossSectionBytes = (double *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim)) {
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                        }
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes, allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *signalBytes = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                float complex *crossSectionBytes = (float complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes,  allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *signalBytes = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                double complex *crossSectionBytes = (double complex *) CFDataGetMutableBytePtr(crossSectionValues);
                for(CFIndex crossSectionMemOffset = 0; crossSectionMemOffset<crossSectionSize; crossSectionMemOffset++) {
                    CFIndex crossSectionCoordinateIndexes[crossSectionDimensionsCount];
                    setIndexesForMemOffset(crossSectionMemOffset, crossSectionCoordinateIndexes, crossSectionDimensionsCount, crossSectionNpts);
                    CFIndex iCrossDim = 0;
                    for(CFIndex idim = 0; idim<allDimensionsCount; idim++) {
                        if(!PSIndexPairSetContainsIndex(indexPairs, idim))
                            signalCoordinateIndexes[idim] = crossSectionCoordinateIndexes[iCrossDim++];
                    }
                    CFIndex signalMemOffset = memOffsetFromIndexes(signalCoordinateIndexes,  allDimensionsCount, signalNpts);
                    crossSectionBytes[crossSectionMemOffset] = signalBytes[signalMemOffset];
                }
                break;
            }
        }
    }
    return theCrossSection;
    
}

bool PSDependentVariableSeparateInterleavedSignalsAlongDimension(PSDependentVariableRef input,
                                                                 CFArrayRef dimensions,
                                                                 CFIndex dimensionIndex,
                                                                 PSDependentVariableRef odd,
                                                                 PSDependentVariableRef even,
                                                                 CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(input,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(odd,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(even,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    CFIndex componentsCount = CFArrayGetCount(input->components);
    CFIndex oddComponentsCount = CFArrayGetCount(odd->components);
    CFIndex evenComponentsCount = CFArrayGetCount(even->components);
    if(componentsCount == 0 || componentsCount!=oddComponentsCount || componentsCount != evenComponentsCount) return NULL;
    
    PSDimensionRef theDimension =  CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(theDimension)) return NULL;
    
    PSDimensionRef newDimension = PSDimensionCreateCopy(theDimension);
    
    PSDimensionSetNpts(newDimension, PSDimensionGetNpts(newDimension)/2);
    
    CFMutableArrayRef newDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, dimensions);
    CFArraySetValueAtIndex(newDimensions, dimensionIndex, newDimension);
    CFRelease(newDimension);
    CFIndex newSize = PSDimensionCalculateSizeFromDimensions(newDimensions);
    
    PSDependentVariableSetSize(odd, newSize);
    PSDependentVariableSetSize(even, newSize);

    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex oldSize = PSDimensionCalculateSizeFromDimensions(dimensions);
    CFIndex *oldNpts = calloc(sizeof(CFIndex), dimensionsCount);
    CFIndex *newNpts = calloc(sizeof(CFIndex), dimensionsCount);
    bool *oldFFT = calloc(sizeof(bool), dimensionsCount);
    bool *newFFT = calloc(sizeof(bool), dimensionsCount);

    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef oldDimension = CFArrayGetValueAtIndex(dimensions, idim);
        PSDimensionRef newDimension = CFArrayGetValueAtIndex(newDimensions, idim);
        oldNpts[idim] = PSDimensionGetNpts(oldDimension);
        newNpts[idim] = PSDimensionGetNpts(newDimension);
        oldFFT[idim] = PSDimensionGetFFT(oldDimension);
        newFFT[idim] = PSDimensionGetFFT(newDimension);
    }
    CFRelease(newDimensions);
    
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef inputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(input->components, componentIndex);
        CFMutableDataRef oddValues = (CFMutableDataRef) CFArrayGetValueAtIndex(odd->components, componentIndex);
        CFMutableDataRef evenValues = (CFMutableDataRef) CFArrayGetValueAtIndex(even->components, componentIndex);
        
        switch (input->elementType) {
            case kPSNumberFloat32Type: {
                float *old = (float *) CFDataGetMutableBytePtr(inputValues);
                float *newOdd = (float *) CFDataGetMutableBytePtr(oddValues);
                float *newEven = (float *) CFDataGetMutableBytePtr(evenValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, oldNpts);
                                   if(indexes[dimensionIndex]%2==0) {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                       newEven[reducedMemOffset] = old[memOffset];
                                   }
                                   else {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes , dimensionsCount, newNpts);
                                       newOdd[reducedMemOffset] = old[memOffset];
                                   }
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64Type: {
                double *old = (double *) CFDataGetMutableBytePtr(inputValues);
                double *newOdd = (double *) CFDataGetMutableBytePtr(oddValues);
                double *newEven = (double *) CFDataGetMutableBytePtr(evenValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, oldNpts);
                                   if(indexes[dimensionIndex]%2==0) {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                       newEven[reducedMemOffset] = old[memOffset];
                                   }
                                   else {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                       newOdd[reducedMemOffset] = old[memOffset];
                                   }
                               }
                               );
                
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *old = (float complex *) CFDataGetMutableBytePtr(inputValues);
                float complex *newOdd = (float complex *) CFDataGetMutableBytePtr(oddValues);
                float complex *newEven = (float complex *) CFDataGetMutableBytePtr(evenValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, oldNpts);
                                   if(indexes[dimensionIndex]%2==0) {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes,dimensionsCount, newNpts);
                                       newEven[reducedMemOffset] = old[memOffset];
                                   }
                                   else {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes,dimensionsCount, newNpts);
                                       newOdd[reducedMemOffset] = old[memOffset];
                                   }
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *old = (double complex *) CFDataGetMutableBytePtr(inputValues);
                double complex *newOdd = (double complex *) CFDataGetMutableBytePtr(oddValues);
                double complex *newEven = (double complex *) CFDataGetMutableBytePtr(evenValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes,dimensionsCount, oldNpts);
                                   if(indexes[dimensionIndex]%2==0) {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes,dimensionsCount, newNpts);
                                       newEven[reducedMemOffset] = old[memOffset];
                                   }
                                   else {
                                       indexes[dimensionIndex] /=2;
                                       CFIndex reducedMemOffset = memOffsetFromIndexes(indexes,dimensionsCount, newNpts);
                                       newOdd[reducedMemOffset] = old[memOffset];
                                   }
                               }
                               );
                
                break;
                
            }
        }
    }
    
    FREE(oldNpts);
    FREE(newNpts);
    FREE(oldFFT);
    FREE(newFFT);
    return true;
}

bool PSDependentVariableTrimAlongDimension(PSDependentVariableRef theDependentVariable,
                                           CFMutableArrayRef dimensions,
                                           CFIndex dimensionIndex,
                                           char *trimSide,
                                           CFIndex lengthPerSide)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount == 0) return NULL;
    PSDimensionRef trimDimension = CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(trimDimension)) return NULL;
    
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex *oldNpts = calloc(sizeof(CFIndex), dimensionsCount);
    CFIndex *newNpts = calloc(sizeof(CFIndex), dimensionsCount);
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef oldDimension = CFArrayGetValueAtIndex(dimensions, idim);
        oldNpts[idim] = PSDimensionGetNpts(oldDimension);
        newNpts[idim] = oldNpts[idim];
    }
    
    // Code lines below must be identical to code in PSDependentVariableFillAlongDimension()
    CFIndex oldTrimDimensionNpts = PSDimensionGetNpts(trimDimension);
    CFIndex newTrimDimensionNpts = oldTrimDimensionNpts - lengthPerSide;
    if(trimSide[0]=='b') newTrimDimensionNpts -= lengthPerSide;
    CFIndex deltaNpts = oldTrimDimensionNpts - newTrimDimensionNpts;
    CFIndex preTrimPoints = 0;
    if(trimSide[0]=='l') preTrimPoints = deltaNpts;
    else if(trimSide[0]=='b') preTrimPoints = deltaNpts/2;
    
    newNpts[dimensionIndex] = newTrimDimensionNpts;
    
    CFIndex newSize = newTrimDimensionNpts*PSDependentVariableSize(theDependentVariable)/oldTrimDimensionNpts;
    
    PSDependentVariableRef output = PSDependentVariableCreateWithSize(theDependentVariable->name,
                                                                      theDependentVariable->description,
                                                                      theDependentVariable->unit,
                                                                      theDependentVariable->quantityName,
                                                                      theDependentVariable->quantityType,
                                                                      theDependentVariable->elementType,
                                                                      theDependentVariable->componentLabels,
                                                                      newSize,
                                                                      NULL,
                                                                      NULL);
    for(CFIndex cIndex=0;cIndex<componentsCount;cIndex++) {
        CFMutableDataRef inputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, cIndex);
        CFMutableDataRef outputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(output->components, cIndex);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type:{
                float *old = (float *) CFDataGetMutableBytePtr(inputValues);
                float *new = (float *) CFDataGetMutableBytePtr(outputValues);
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t newMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(newMemOffset, indexes, dimensionsCount, newNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                   indexes[dimensionIndex] += preTrimPoints;
                                   
                                   CFIndex oldMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, oldNpts);
                                   new[newMemOffset] = old[oldMemOffset];
                               }
                               );
                break;
            }
            case kPSNumberFloat64Type: {
                double *old = (double *) CFDataGetMutableBytePtr(inputValues);
                double *new = (double *) CFDataGetMutableBytePtr(outputValues);
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t newMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(newMemOffset, indexes, dimensionsCount, newNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                   indexes[dimensionIndex] += preTrimPoints;
                                   
                                   CFIndex oldMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, oldNpts);
                                   new[newMemOffset] = old[oldMemOffset];
                               }
                               );
                break;
            }
            case kPSNumberFloat32ComplexType:{
                float complex *old = (float complex *) CFDataGetMutableBytePtr(inputValues);
                float complex *new = (float complex *) CFDataGetMutableBytePtr(outputValues);
                
                DSPSplitComplex *splitOutput = malloc(sizeof(struct DSPSplitComplex));
                splitOutput->realp = (float *) calloc((size_t) newSize,sizeof(float));
                splitOutput->imagp = (float *) calloc((size_t) newSize,sizeof(float));
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t newMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(newMemOffset, indexes, dimensionsCount, newNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                   indexes[dimensionIndex] += preTrimPoints;

                                   CFIndex oldMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, oldNpts);
                                   splitOutput->realp[newMemOffset] = creal(old[oldMemOffset]);
                                   splitOutput->imagp[newMemOffset] = cimag(old[oldMemOffset]);
                               }
                               );
                
                vDSP_ztoc(splitOutput,1,(DSPComplex *) new,2,newSize);
                free(splitOutput->realp);
                free(splitOutput->imagp);
                free(splitOutput);
                
                break;
            }
            case kPSNumberFloat64ComplexType:{
                double complex *old = (double complex *) CFDataGetMutableBytePtr(inputValues);
                double complex *new = (double complex *) CFDataGetMutableBytePtr(outputValues);
                
                DSPDoubleSplitComplex *splitOutput = malloc(sizeof(struct DSPDoubleSplitComplex));
                splitOutput->realp = (double *) calloc((size_t) newSize,sizeof(double));
                splitOutput->imagp = (double *) calloc((size_t) newSize,sizeof(double));
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t newMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(newMemOffset, indexes, dimensionsCount, newNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                   indexes[dimensionIndex] += preTrimPoints;
                                   
                                   CFIndex oldMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, oldNpts);
                                   splitOutput->realp[newMemOffset] = creal(old[oldMemOffset]);
                                   splitOutput->imagp[newMemOffset] = cimag(old[oldMemOffset]);
                               }
                               );
                
                vDSP_ztocD(splitOutput,1,(DSPDoubleComplex *) new,2,newSize);
                free(splitOutput->realp);
                free(splitOutput->imagp);
                free(splitOutput);
                
                break;
            }
        }
    }
    free(oldNpts);
    free(newNpts);
    
    CFRelease(theDependentVariable->components);
    theDependentVariable->components = (CFMutableArrayRef) CFRetain(output->components);
    CFRelease(output);
    return true;
}

bool PSDependentVariableFillAlongDimension(PSDependentVariableRef theDependentVariable,
                                           CFMutableArrayRef dimensions,
                                           CFIndex dimensionIndex,
                                           PSScalarRef theFillConstant,
                                           char *fillSide,
                                           CFIndex lengthPerSide)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount == 0) return NULL;
    PSDimensionRef fillDimension = CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(fillDimension)) return NULL;
    
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex oldSize = PSDependentVariableSize(theDependentVariable);
    CFIndex *oldNpts = calloc(sizeof(CFIndex), dimensionsCount);
    CFIndex *newNpts = calloc(sizeof(CFIndex), dimensionsCount);
    bool *oldFFT = calloc(sizeof(bool), dimensionsCount);
    bool *newFFT = calloc(sizeof(bool), dimensionsCount);

    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef oldDimension = CFArrayGetValueAtIndex(dimensions, idim);
        oldNpts[idim] = PSDimensionGetNpts(oldDimension);
        newNpts[idim] = oldNpts[idim];
        oldFFT[idim] = PSDimensionGetFFT(oldDimension);
        newFFT[idim] = oldFFT[idim];
        oldFFT[idim] = false;
        newFFT[idim] = false;
    }
    
    // Code lines below must be identical to code in PSDependentVariableFillAlongDimension()
    CFIndex oldFillDimensionNpts = PSDimensionGetNpts(fillDimension);
    CFIndex newFillDimensionNpts = oldFillDimensionNpts + lengthPerSide;
    if(fillSide[0]=='b') newFillDimensionNpts += lengthPerSide;
    CFIndex deltaNpts = newFillDimensionNpts - oldFillDimensionNpts;
    CFIndex prefillPoints = 0;
    if(fillSide[0]=='l') prefillPoints = deltaNpts;
    else if(fillSide[0]=='b') prefillPoints = deltaNpts/2;

    newNpts[dimensionIndex] = newFillDimensionNpts;
    
    bool success = true;
    double complex fillConstant = 0;
    if(theFillConstant)
        fillConstant = PSScalarDoubleComplexValueInUnit(theFillConstant, PSQuantityGetUnit(theDependentVariable), &success);
    
    CFIndex newSize = newFillDimensionNpts*PSDependentVariableSize(theDependentVariable)/oldFillDimensionNpts;
    
    PSDependentVariableRef output = PSDependentVariableCreateWithSize(theDependentVariable->name,
                                                                      theDependentVariable->description,
                                                                      theDependentVariable->unit,
                                                                      theDependentVariable->quantityName,
                                                                      theDependentVariable->quantityType,
                                                                      theDependentVariable->elementType,
                                                                      theDependentVariable->componentLabels,
                                                                      newSize,
                                                                      NULL,
                                                                      NULL);
    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef inputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef outputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(output->components, componentIndex);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type:{
                float *old = (float *) CFDataGetMutableBytePtr(inputValues);
                float *new = (float *) CFDataGetMutableBytePtr(outputValues);
                float fill = fillConstant;
                vDSP_vfill(&fill,new,1,newSize);
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t oldMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(oldMemOffset, indexes, dimensionsCount, oldNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                    indexes[dimensionIndex] += prefillPoints;
                                   
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[oldMemOffset];
                               }
                               );
                break;
            }
            case kPSNumberFloat64Type: {
                double *old = (double *) CFDataGetMutableBytePtr(inputValues);
                double *new = (double *) CFDataGetMutableBytePtr(outputValues);
                double fill = fillConstant;
                vDSP_vfillD(&fill,new,1,newSize);
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t oldMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(oldMemOffset, indexes, dimensionsCount, oldNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                   indexes[dimensionIndex] += prefillPoints;
                                   
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[oldMemOffset];
                               }
                               );
                break;
            }
            case kPSNumberFloat32ComplexType:{
                float complex *old = (float complex *) CFDataGetMutableBytePtr(inputValues);
                float complex *new = (float complex *) CFDataGetMutableBytePtr(outputValues);
                float realFill = creal(fillConstant);
                float imagFill = cimag(fillConstant);
                
                DSPSplitComplex *splitOutput = malloc(sizeof(struct DSPSplitComplex));
                splitOutput->realp = (float *) calloc((size_t) newSize,sizeof(float));
                splitOutput->imagp = (float *) calloc((size_t) newSize,sizeof(float));
                
                DSPSplitComplex *splitFill = malloc(sizeof(struct DSPSplitComplex));
                splitFill->realp = &realFill;
                splitFill->imagp = &imagFill;
                vDSP_zvfill (splitFill,splitOutput,1,newSize);
                free(splitFill);
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t oldMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(oldMemOffset, indexes, dimensionsCount, oldNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                   indexes[dimensionIndex] += prefillPoints;
                                   
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   splitOutput->realp[newMemOffset] = creal(old[oldMemOffset]);
                                   splitOutput->imagp[newMemOffset] = cimag(old[oldMemOffset]);
                               }
                               );
                
                vDSP_ztoc(splitOutput,1,(DSPComplex *) new,2,newSize);
                free(splitOutput->realp);
                free(splitOutput->imagp);
                free(splitOutput);
                
                break;
            }
            case kPSNumberFloat64ComplexType:{
                double complex *old = (double complex *) CFDataGetMutableBytePtr(inputValues);
                double complex *new = (double complex *) CFDataGetMutableBytePtr(outputValues);
                double realFill = creal(fillConstant);
                double imagFill = cimag(fillConstant);
                
                DSPDoubleSplitComplex *splitOutput = malloc(sizeof(struct DSPDoubleSplitComplex));
                splitOutput->realp = (double *) calloc((size_t) newSize,sizeof(double));
                splitOutput->imagp = (double *) calloc((size_t) newSize,sizeof(double));
                
                DSPDoubleSplitComplex *splitFill = malloc(sizeof(struct DSPDoubleSplitComplex));
                splitFill->realp = &realFill;
                splitFill->imagp = &imagFill;
                vDSP_zvfillD (splitFill,splitOutput,1,newSize);
                free(splitFill);
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t oldMemOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(oldMemOffset, indexes, dimensionsCount, oldNpts);
                                   // indexes now contains values with old size
                                   // next shift indexes to work with new size
                                   indexes[dimensionIndex] += prefillPoints;
                                   
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   splitOutput->realp[newMemOffset] = creal(old[oldMemOffset]);
                                   splitOutput->imagp[newMemOffset] = cimag(old[oldMemOffset]);
                               }
                               );
                
                vDSP_ztocD(splitOutput,1,(DSPDoubleComplex *) new,2,newSize);
                free(splitOutput->realp);
                free(splitOutput->imagp);
                free(splitOutput);
                
                break;
            }
        }
    }
    FREE(oldNpts);
    FREE(newNpts);
    FREE(oldFFT);
    FREE(newFFT);

    CFRelease(theDependentVariable->components);
    theDependentVariable->components = (CFMutableArrayRef) CFRetain(output->components);
    CFRelease(output);
    return true;
}


void PSDependentVariableRepeatAlongDimension(PSDependentVariableRef theDependentVariable,
                                             CFArrayRef dimensions,
                                             CFIndex dimensionIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount == 0) return;
    PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, dimensionIndex);
    if(PSDimensionHasNonUniformGrid(theDimension)) return;
    
    PSDimensionRef newDimension = PSDimensionCreateCopy(theDimension);
    PSDimensionSetNpts(newDimension, PSDimensionGetNpts(newDimension)*2);
    
    CFMutableArrayRef newDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, dimensions);
    CFArraySetValueAtIndex(newDimensions, dimensionIndex, newDimension);
    CFRelease(newDimension);
    
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex oldSize = PSDimensionCalculateSizeFromDimensions(dimensions);
    CFIndex *oldNpts = calloc(sizeof(CFIndex), dimensionsCount);
    CFIndex *newNpts = calloc(sizeof(CFIndex), dimensionsCount);
    
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef oldDimension = CFArrayGetValueAtIndex(dimensions, idim);
        PSDimensionRef newDimension = CFArrayGetValueAtIndex(newDimensions, idim);
        oldNpts[idim] = PSDimensionGetNpts(oldDimension);
        newNpts[idim] = PSDimensionGetNpts(newDimension);
    }
    CFIndex newSize = PSDimensionCalculateSizeFromDimensions(newDimensions);
    CFRelease(newDimensions);

    for(CFIndex componentIndex =0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef inputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef outputValues = CFDataCreateMutable(kCFAllocatorDefault, newSize*PSQuantityElementSize(theDependentVariable));
        CFDataSetLength(outputValues, newSize*PSQuantityElementSize(theDependentVariable));
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *old = (float *) CFDataGetMutableBytePtr(inputValues);
                float *new = (float *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, oldNpts);
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                                   indexes[dimensionIndex] += oldNpts[dimensionIndex];
                                   newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64Type: {
                double *old = (double *) CFDataGetMutableBytePtr(inputValues);
                double *new = (double *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, oldNpts);
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                                   indexes[dimensionIndex] += oldNpts[dimensionIndex];
                                   newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                               }
                               );
                
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *old = (float complex *) CFDataGetMutableBytePtr(inputValues);
                float complex *new = (float complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, oldNpts);
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                                   indexes[dimensionIndex] += oldNpts[dimensionIndex];
                                   newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *old = (double complex *) CFDataGetMutableBytePtr(inputValues);
                double complex *new = (double complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(oldSize, queue,
                               ^(size_t memOffset) {
                                   CFIndex indexes[dimensionsCount];
                                   setIndexesForMemOffset(memOffset, indexes, dimensionsCount, oldNpts);
                                   CFIndex newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                                   indexes[dimensionIndex] += oldNpts[dimensionIndex];
                                   newMemOffset = memOffsetFromIndexes(indexes, dimensionsCount, newNpts);
                                   new[newMemOffset] = old[memOffset];
                               }
                               );
                
                break;
            }
        }
        CFArraySetValueAtIndex(theDependentVariable->components, componentIndex, outputValues);
        CFRelease(outputValues);
    }
    free(oldNpts);
    free(newNpts);
}


PSDependentVariableRef PSDependentVariableCreateByRepeatingIntoNewDimension(PSDependentVariableRef theDependentVariable,
                                                                            CFArrayRef dimensions,
                                                                            PSDimensionRef newDimension)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount == 0) return NULL;

    CFIndex oldSize = PSDimensionCalculateSizeFromDimensions(dimensions);
    CFMutableArrayRef newDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, dimensions);
    CFArrayAppendValue(newDimensions, newDimension);
    CFIndex newSize = PSDimensionCalculateSizeFromDimensions(newDimensions);
    
    PSDependentVariableRef output = PSDependentVariableCreateWithSize(theDependentVariable->name,
                                                                      theDependentVariable->description,
                                                                      theDependentVariable->unit,
                                                                      theDependentVariable->quantityName,
                                                                      theDependentVariable->quantityType,
                                                                      theDependentVariable->elementType,
                                                                      theDependentVariable->componentLabels,
                                                                      newSize,NULL,NULL);

    for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
        CFMutableDataRef inputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFMutableDataRef outputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(output->components, componentIndex);
        
        switch (theDependentVariable->elementType) {
            case kPSNumberFloat32Type: {
                float *old = (float *) CFDataGetMutableBytePtr(inputValues);
                float *new = (float *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] = old[memOffset%oldSize];
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64Type: {
                double *old = (double *) CFDataGetMutableBytePtr(inputValues);
                double *new = (double *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] = old[memOffset%oldSize];
                               }
                               );
                
                break;
            }
            case kPSNumberFloat32ComplexType: {
                float complex *old = (float complex *) CFDataGetMutableBytePtr(inputValues);
                float complex *new = (float complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] = old[memOffset%oldSize];
                               }
                               );
                
                break;
            }
            case kPSNumberFloat64ComplexType: {
                double complex *old = (double complex *) CFDataGetMutableBytePtr(inputValues);
                double complex *new = (double complex *) CFDataGetMutableBytePtr(outputValues);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_apply(newSize, queue,
                               ^(size_t memOffset) {
                                   new[memOffset] = old[memOffset%oldSize];
                               }
                               );
                
                break;
            }
        }
    }
    
    CFRelease(newDimensions);
    
    return output;
}



#pragma mark Strings and Archiving


CFStringRef PSDependentVariableCreateStringWithQuantityNameAndUnit(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    
    CFStringRef result = NULL;
    PSUnitRef theUnit = PSQuantityGetUnit(theDependentVariable);
    if(PSUnitIsDimensionlessAndUnderived(theUnit)) {
        if(theDependentVariable->quantityName)
            result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                              NULL,
                                              CFSTR("%@"),
                                              theDependentVariable->quantityName);
        else result = CFSTR("");
    }
    else {
        CFStringRef symbol = PSUnitCopySymbol(theUnit);
        result = CFStringCreateWithFormat(kCFAllocatorDefault,
                                          NULL,
                                          CFSTR("%@ / %@"),
                                          theDependentVariable->quantityName,
                                          symbol);
        CFRelease(symbol);
    }
    return result;
}


CFArrayRef PSDependentVariableCreateUnPackedSparseComponentsArray(numberType elementType,
                                                                  CFArrayRef components,
                                                                  CFArrayRef dimensions,
                                                                  PSIndexSetRef sparseDimensionIndexes,
                                                                  CFArrayRef sparseGridVertexes)
{
    CFIndex sizeFromAllDimensions = PSDimensionCalculateSizeFromDimensions(dimensions);
    CFIndex componentsCount = CFArrayGetCount(components);
    CFStringRef quantityType = CFStringCreateWithFormat(kCFAllocatorDefault, 0, CFSTR("vector_%ld"),componentsCount);
    
    PSDependentVariableRef output = PSDependentVariableCreateWithSize(NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      quantityType,
                                                                      elementType,
                                                                      NULL,
                                                                      sizeFromAllDimensions, NULL,NULL);
    output->sparseDimensionIndexes = CFRetain(sparseDimensionIndexes);
    output->sparseGridVertexes = CFRetain(sparseGridVertexes);
    
    // Number of fully sampled subgrids
    CFIndex sparseVertexesCount = CFArrayGetCount(sparseGridVertexes);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex sparseDimensionsCount = PSIndexSetGetCount(sparseDimensionIndexes);
    if(sparseDimensionsCount<dimensionsCount) {
        CFMutableArrayRef crossSectionDimensions = CFArrayCreateMutableCopy(kCFAllocatorDefault, dimensionsCount, dimensions);
        PSCFArrayRemoveObjectsAtIndexes(crossSectionDimensions, sparseDimensionIndexes);
        CFIndex elementSize = PSNumberTypeElementSize(elementType);
        CFIndex sizeFromCrossSectionDimensions = PSDimensionCalculateSizeFromDimensions(crossSectionDimensions);
        CFIndex byteSizeOfCrossSection = sizeFromCrossSectionDimensions*elementSize;
        
        
        CFIndex memOffset = 0;
        for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
            CFMutableArrayRef newComponents = CFArrayCreateMutable(kCFAllocatorDefault,0,&kCFTypeArrayCallBacks);
            for(CFIndex componentIndex = 0; componentIndex<componentsCount;componentIndex++) {
                CFDataRef values = CFArrayGetValueAtIndex(components, componentIndex);
                const UInt8 *bytes = CFDataGetBytePtr(values);
                CFDataRef crossSectionValues = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, &(bytes[memOffset]), sizeFromCrossSectionDimensions, kCFAllocatorNull);
                CFArrayAppendValue(newComponents,crossSectionValues);
                CFRelease(crossSectionValues);
            }
            PSDependentVariableRef crossSectionSignal = PSDependentVariableCreateWithComponentsNoCopy(NULL,
                                                                                                      NULL,
                                                                                                      NULL,
                                                                                                      NULL,
                                                                                                      quantityType,
                                                                                                      elementType,
                                                                                                      NULL,
                                                                                                      newComponents, NULL,NULL);
            
            CFRelease(newComponents);
            PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(sparseGridVertexes, iVertex);
            PSDependentVariableSetCrossSection(output, dimensions, indexPairs, crossSectionSignal, crossSectionDimensions);
            CFRelease(crossSectionSignal);
            memOffset += byteSizeOfCrossSection;
        }
        CFRelease(crossSectionDimensions);
    }
    else {
        for(CFIndex componentIndex = 0; componentIndex<componentsCount;componentIndex++) {
            CFDataRef values = CFArrayGetValueAtIndex(components, componentIndex);
            CFDataRef outputValues = CFArrayGetValueAtIndex(output->components, componentIndex);
            
            switch(elementType) {
                case kPSNumberFloat32Type: {
                    float *src = (float *) CFDataGetBytePtr(values);
                    float *dest = (float *) CFDataGetBytePtr(outputValues);
                    CFIndex srcOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex destOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        srcOffset++;
                    }
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *src = (double *) CFDataGetBytePtr(values);
                    double *dest = (double *) CFDataGetBytePtr(outputValues);
                    CFIndex srcOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex destOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        srcOffset++;
                    }
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *src = (float complex *) CFDataGetBytePtr(values);
                    float complex *dest = (float complex *) CFDataGetBytePtr(outputValues);
                    CFIndex srcOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex destOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        srcOffset++;
                    }
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *src = (double complex *) CFDataGetBytePtr(values);
                    double complex *dest = (double complex *) CFDataGetBytePtr(outputValues);
                    CFIndex srcOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex destOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        srcOffset++;
                    }
                    break;
                }
                    
            }
        }
    }
    
    CFArrayRef unpackedComponets = CFRetain(output->components);
    CFRelease(output);
    CFRelease(quantityType);
    return unpackedComponets;
}

CFArrayRef PSDependentVariableCreatePackedSparseComponentsArray(PSDependentVariableRef theDependentVariable,
                                                                CFArrayRef dimensions)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(dimensions,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable->sparseDimensionIndexes,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable->sparseGridVertexes,NULL);
    
    CFErrorRef error = NULL;
    CFIndex componentCount = CFArrayGetCount(theDependentVariable->components);
    
    PSDependentVariableRef output = PSDependentVariableCreateWithSize(theDependentVariable->name,
                                                                      theDependentVariable->description,
                                                                      theDependentVariable->unit,
                                                                      theDependentVariable->quantityName,
                                                                      theDependentVariable->quantityType,
                                                                      theDependentVariable->elementType,
                                                                      theDependentVariable->componentLabels,
                                                                      0,NULL,NULL);
    
    CFIndex sparseVertexesCount = CFArrayGetCount(theDependentVariable->sparseGridVertexes);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex sparseDimensionsCount = PSIndexSetGetCount(theDependentVariable->sparseDimensionIndexes);
    if(sparseDimensionsCount<dimensionsCount) {
        for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
            PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(theDependentVariable->sparseGridVertexes, iVertex);
            PSDependentVariableRef crossSection = PSDependentVariableCreateCrossSection(theDependentVariable,
                                                                                        dimensions,
                                                                                        indexPairs,
                                                                                        &error);
            PSDependentVariableAppend(output, crossSection, &error);
            CFRelease(crossSection);
        }
    }
    else {
        PSDependentVariableSetSize(output, sparseVertexesCount);
        for(CFIndex componentIndex = 0; componentIndex<componentCount; componentIndex++) {
            CFMutableDataRef dependentVariableValues = (CFMutableDataRef) CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
            CFMutableDataRef outputValues = (CFMutableDataRef) CFArrayGetValueAtIndex(output->components, componentIndex);
            
            switch(theDependentVariable->elementType) {
                case kPSNumberFloat32Type: {
                    float *src = (float *) CFDataGetBytePtr(dependentVariableValues);
                    float *dest = (float *) CFDataGetBytePtr(outputValues);
                    CFIndex destOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(theDependentVariable->sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex srcOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        destOffset++;
                    }
                    break;
                }
                case kPSNumberFloat64Type: {
                    double *src = (double *) CFDataGetBytePtr(dependentVariableValues);
                    double *dest = (double *) CFDataGetBytePtr(outputValues);
                    CFIndex destOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(theDependentVariable->sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex srcOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        destOffset++;
                    }
                    break;
                }
                case kPSNumberFloat32ComplexType: {
                    float complex *src = (float complex *) CFDataGetBytePtr(dependentVariableValues);
                    float complex *dest = (float complex *) CFDataGetBytePtr(outputValues);
                    CFIndex destOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(theDependentVariable->sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex srcOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        destOffset++;
                    }
                    break;
                }
                case kPSNumberFloat64ComplexType: {
                    double complex *src = (double complex *) CFDataGetBytePtr(dependentVariableValues);
                    double complex *dest = (double complex *) CFDataGetBytePtr(outputValues);
                    CFIndex destOffset = 0;
                    for(CFIndex iVertex = 0;iVertex<sparseVertexesCount;iVertex++) {
                        PSIndexPairSetRef indexPairs = CFArrayGetValueAtIndex(theDependentVariable->sparseGridVertexes, iVertex);
                        PSIndexArrayRef theIndexes = PSIndexPairSetCreateIndexArrayOfValues(indexPairs);
                        CFIndex srcOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, theIndexes);
                        dest[destOffset] = src[srcOffset];
                        destOffset++;
                    }
                    break;
                }
                    
            }
        }
    }
    CFArrayRef components = CFRetain(output->components);
    if(error) CFRelease(error);
    CFRelease(output);
    return components;
}


CFStringRef PSDependentVariableCreateBase64String(PSDependentVariableRef theDependentVariable, CFIndex componentIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFDataRef values = CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
    return (CFStringRef) [[(NSData *) values base64EncodedStringWithOptions:0] retain];
}

CFArrayRef createCFNumberArray(CFDataRef values, numberType elementType)
{
    IF_NO_OBJECT_EXISTS_RETURN(values,NULL);
    
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFIndex length = CFDataGetLength(values);
    CFIndex size = length/PSNumberTypeElementSize(elementType);
    switch (elementType) {
        case kPSNumberFloat32Type: {
            float *bytes = (float *) CFDataGetBytePtr(values);
            for(CFIndex memOffset=0; memOffset<size;memOffset++) {
                CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloat32Type, &bytes[memOffset]);
                CFArrayAppendValue(array, number);
                CFRelease(number);
            }
            break;
        }
        case kPSNumberFloat64Type: {
            double *bytes = (double *) CFDataGetBytePtr(values);
            for(CFIndex memOffset=0; memOffset<size;memOffset++) {
                CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloat64Type, &bytes[memOffset]);
                CFArrayAppendValue(array, number);
                CFRelease(number);
            }
            break;
        }
        case kPSNumberFloat32ComplexType: {
            float *bytes = (float *) CFDataGetBytePtr(values);
            for(CFIndex memOffset=0; memOffset<2*size;memOffset++) {
                CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloat32Type, &bytes[memOffset]);
                CFArrayAppendValue(array, number);
                CFRelease(number);
            }
            break;
        }
        case kPSNumberFloat64ComplexType: {
            double *bytes = (double *) CFDataGetBytePtr(values);
            for(CFIndex memOffset=0; memOffset<size;memOffset++) {
                CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloat64Type, &bytes[memOffset]);
                CFArrayAppendValue(array, number);
                CFRelease(number);
            }
            break;
        }
    }
    
    return array;
    
}

CFArrayRef PSDependentVariableCreateCSDMComponentsArray(PSDependentVariableRef theDependentVariable,
                                                        CFArrayRef dimensions,
                                                        bool base64Encoding)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    if(componentsCount == 0) return NULL;

    CFMutableArrayRef componentsArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    if(theDependentVariable->sparseDimensionIndexes) {
        CFArrayRef packedComponents = PSDependentVariableCreatePackedSparseComponentsArray(theDependentVariable, dimensions);
        if(base64Encoding) {
            for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
                CFDataRef values = CFArrayGetValueAtIndex(packedComponents, componentIndex);
                CFStringRef base64String = (CFStringRef) [[(NSData *) values base64EncodedStringWithOptions:0] retain];
                CFArrayAppendValue(componentsArray, base64String);
                CFRelease(base64String);
            }
        }
        else {
            for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
                CFDataRef values = CFArrayGetValueAtIndex(packedComponents, componentIndex);
                CFArrayRef numberArray = createCFNumberArray(values, theDependentVariable->elementType);
                CFArrayAppendValue(componentsArray, numberArray);
                CFRelease(numberArray);
            }
        }
        CFRelease(packedComponents);
    }
    else {
        if(base64Encoding) {
            for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
                CFDataRef values = CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
                CFStringRef base64String = (CFStringRef) [[(NSData *) values base64EncodedStringWithOptions:0] retain];
                CFArrayAppendValue(componentsArray, base64String);
                CFRelease(base64String);
            }
        }
        else {
            for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
                CFDataRef values = CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
                CFArrayRef numberArray = createCFNumberArray(values, theDependentVariable->elementType);
                CFArrayAppendValue(componentsArray, numberArray);
                CFRelease(numberArray);
            }
        }
    }
    return componentsArray;
}

CFDataRef PSDependentVariableCreateCSDMComponentsData(PSDependentVariableRef theDependentVariable)
{
    CFMutableDataRef components = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFIndex componentsCount = CFArrayGetCount(theDependentVariable->components);
    
    if(theDependentVariable->sparseDimensionIndexes) {
        CFArrayRef dimensions = PSDatasetGetDimensions(theDependentVariable->dataset);
        CFArrayRef packedComponents = PSDependentVariableCreatePackedSparseComponentsArray(theDependentVariable, dimensions);
        for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
            CFDataRef component = CFArrayGetValueAtIndex(packedComponents, componentIndex);
            CFDataAppendBytes(components, CFDataGetBytePtr(component), CFDataGetLength(component));
        }
        CFRelease(packedComponents);
        return components;
    }

    for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
        CFDataRef component = CFArrayGetValueAtIndex(theDependentVariable->components, componentIndex);
        CFDataAppendBytes(components, CFDataGetBytePtr(component), CFDataGetLength(component));
    }
    return components;
}


CFDictionaryRef PSDependentVariableCreateCSDMPList(PSDependentVariableRef theDependentVariable,
                                                   CFArrayRef dimensions,
                                                   bool external,
                                                   bool base64Encoding)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    
    CFMutableDictionaryRef dependentVariableDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    
    if(external) CFDictionarySetValue(dependentVariableDictionary, CFSTR("type"),CFSTR("external"));
    else CFDictionarySetValue(dependentVariableDictionary, CFSTR("type"),CFSTR("internal"));
    if(theDependentVariable->name) CFDictionarySetValue(dependentVariableDictionary, CFSTR("name"),theDependentVariable->name);
    
    if(theDependentVariable->description && CFStringGetLength(theDependentVariable->description)) CFDictionarySetValue(dependentVariableDictionary, CFSTR("description"),theDependentVariable->description);
    
    if(PSUnitDimensionlessAndUnderived() != PSQuantityGetUnit(theDependentVariable)) {
        CFStringRef unitString = PSUnitCopySymbol(PSQuantityGetUnit(theDependentVariable));
        CFDictionarySetValue(dependentVariableDictionary, CFSTR("unit"),unitString);
        CFRelease(unitString);
    }
    
    if(theDependentVariable->quantityName)
        CFDictionarySetValue(dependentVariableDictionary, CFSTR("quantity_name"),theDependentVariable->quantityName);
    
    if(!external&&base64Encoding) CFDictionarySetValue(dependentVariableDictionary, CFSTR("encoding"),CFSTR("base64"));
    
    switch(theDependentVariable->elementType) {
        case kPSNumberFloat32Type:
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("numeric_type"),CFSTR("float32"));
            break;
        case kPSNumberFloat64Type:
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("numeric_type"),CFSTR("float64"));
            break;
        case kPSNumberFloat32ComplexType:
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("numeric_type"),CFSTR("complex64"));
            break;
        case kPSNumberFloat64ComplexType:
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("numeric_type"),CFSTR("complex128"));
            break;
    }
    CFDictionarySetValue(dependentVariableDictionary, CFSTR("quantity_type"),theDependentVariable->quantityType);
    
    if(theDependentVariable->components) {
        CFMutableArrayRef componentLabels = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFIndex totalLength = 0;
        for(CFIndex index = 0; index<CFArrayGetCount(theDependentVariable->components); index++) {
            CFStringRef componentLabel = CFArrayGetValueAtIndex(theDependentVariable->componentLabels, index);
            totalLength += CFStringGetLength(componentLabel);
            CFArrayAppendValue(componentLabels, componentLabel);
        }
        if(totalLength)
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("component_labels"),componentLabels);
        CFRelease(componentLabels);
        
        if(theDependentVariable->sparseDimensionIndexes) {
            CFMutableDictionaryRef sparseSampling = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("sparse_sampling"),sparseSampling);
            CFRelease(sparseSampling);
            CFArrayRef sparseDimensionIndexes = PSIndexSetCreateCFNumberArray(theDependentVariable->sparseDimensionIndexes);
            CFDictionarySetValue(sparseSampling, CFSTR("dimension_indexes"),sparseDimensionIndexes);
            CFRelease(sparseDimensionIndexes);
            
            
            
            CFArrayRef dimensions = PSDatasetGetDimensions(theDependentVariable->dataset);
            CFIndex dimensionsCount = CFArrayGetCount(dimensions);
            csdmNumericType unsigned_int_type = kCSDMNumberUInt8Type;
            CFStringRef unsigned_int_type_string = CFSTR("uint8");
            for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
                PSDimensionRef theDimension = CFArrayGetValueAtIndex(dimensions, idim);
                CFIndex coordinatesCount = PSDimensionGetNpts(theDimension);
                if(coordinatesCount>255) {
                    unsigned_int_type = kCSDMNumberUInt16Type;
                    unsigned_int_type_string = CFSTR("uint16");
                }
                if(coordinatesCount>65535) {
                    unsigned_int_type = kCSDMNumberUInt32Type;
                    unsigned_int_type_string = CFSTR("uint32");
                }
                if(coordinatesCount>4294967296) {
                    unsigned_int_type = kCSDMNumberUInt64Type;
                    unsigned_int_type_string = CFSTR("uint64");
                }
            }
            CFDictionarySetValue(sparseSampling, CFSTR("unsigned_integer_type"),unsigned_int_type_string);

            PSIndexPairSetRef indexPairSet = CFArrayGetValueAtIndex(theDependentVariable->sparseGridVertexes, 0);
            
            PSMutableIndexArrayRef coordinateIndexes = (PSMutableIndexArrayRef) PSIndexPairSetCreateIndexArrayOfValues(indexPairSet);
            
            CFIndex numberOfVertexes = CFArrayGetCount(theDependentVariable->sparseGridVertexes);
            for(CFIndex iVertex =1; iVertex<numberOfVertexes; iVertex++) {
                indexPairSet = CFArrayGetValueAtIndex(theDependentVariable->sparseGridVertexes, iVertex);
                PSIndexArrayRef indexPairArray = PSIndexPairSetCreateIndexArrayOfValues(indexPairSet);
                PSIndexArrayAppendValues(coordinateIndexes, indexPairArray);
                CFRelease(indexPairArray);
            }
            
            if(base64Encoding) {
                CFStringRef sparseGridVertexesString = PSIndexArrayCreateBase64String(coordinateIndexes, unsigned_int_type);
                CFDictionarySetValue(sparseSampling, CFSTR("sparse_grid_vertexes"),sparseGridVertexesString);
                CFRelease(sparseGridVertexesString);
                CFDictionarySetValue(sparseSampling, CFSTR("encoding"),CFSTR("base64"));
            }
            else {
                CFArrayRef sparseGridVertexes = PSIndexArrayCreateCFNumberArray(coordinateIndexes);
                CFDictionarySetValue(sparseSampling, CFSTR("sparse_grid_vertexes"),sparseGridVertexes);
                CFRelease(sparseGridVertexes);
            }
            CFRelease(coordinateIndexes);
        }
    }
    
    if(theDependentVariable->components) {
        if(external) {
            PSDatasetRef theDataset = PSDependentVariableGetDataset(theDependentVariable);
            CFIndex dependentVariableIndex = PSDatasetIndexOfDependentVariable(theDataset, theDependentVariable);

            CFStringRef fileName = CFStringCreateWithFormat(kCFAllocatorDefault, 0, PSDependentVariableComponentsFileName,dependentVariableIndex);
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("components_url"),fileName);
            CFRelease(fileName);
        }
        else {
            CFArrayRef componentsArray = PSDependentVariableCreateCSDMComponentsArray(theDependentVariable,
                                                                                      dimensions,
                                                                                      base64Encoding);
            CFDictionarySetValue(dependentVariableDictionary, CFSTR("components"),componentsArray);
            CFRelease(componentsArray);
        }
    }
    
    CFMutableDictionaryRef applicationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(dependentVariableDictionary, CFSTR("application"),applicationDictionary);
    CFRelease(applicationDictionary);
    
    CFMutableDictionaryRef RMNDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(applicationDictionary, CFSTR("com.physyapps.rmn"), RMNDictionary);
    CFRelease(RMNDictionary);
    {
        if(theDependentVariable->metaData) {
            if(CFDictionaryGetCount(theDependentVariable->metaData)) {
                CFDictionaryRef metaDataPropertyList = PSCFDictionaryCreatePListCompatible(theDependentVariable->metaData);
                CFDictionarySetValue(RMNDictionary, CFSTR("metaData"),metaDataPropertyList);
                CFRelease(metaDataPropertyList);
            }
        }

        if(theDependentVariable->plot) {
            CFDictionaryRef plist = PSPlotCreatePList(theDependentVariable->plot);
            CFDictionarySetValue(RMNDictionary, CFSTR("plot"),plist);
            CFRelease(plist);
        }
    }
    return dependentVariableDictionary;
}


PSDependentVariableRef PSDependentVariableCreateWithCSDMPList(CFDictionaryRef dependentVariableDictionary,
                                                              CFArrayRef dimensions,
                                                              CFArrayRef folderContents,
                                                              PSDatasetRef theDataset,
                                                              CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dependentVariableDictionary,NULL);
    
    
    if(!CFDictionaryContainsKey(dependentVariableDictionary, CFSTR("type"))) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("No type key found."), NULL);
        return NULL;
    }

    CFStringRef type = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("type"));
    if((CFStringCompare(type, CFSTR("internal"), 0)!=kCFCompareEqualTo)&&(CFStringCompare(type, CFSTR("external"), 0)!=kCFCompareEqualTo)) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("illegal type key found."), NULL);
        return NULL;
    }
    if(!CFDictionaryContainsKey(dependentVariableDictionary, CFSTR("quantity_type"))) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("No quantity_type key found."), NULL);
        return NULL;
    }
    CFStringRef quantity_type = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("quantity_type"));
    CFIndex componentsCount = componentsCountFromQuantityType(quantity_type);
    if(componentsCount==kCFNotFound) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("illegal quantity_type key found."), NULL);
        return NULL;
    }
    
    CFArrayRef componentsArray = NULL;
    if(CFStringCompare(type, CFSTR("internal"), 0)==kCFCompareEqualTo) {
        if(!CFDictionaryContainsKey(dependentVariableDictionary, CFSTR("components"))) {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("No components key found."), NULL);
            return NULL;
        }

        componentsArray = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("components"));
        if(componentsCount != CFArrayGetCount(componentsArray)) {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("Components count from quantity_type and inconsistent with components array are inconsistent."), NULL);
            return NULL;
        }
    }
    CFStringRef csdm_components_url = NULL;
    if(CFStringCompare(type, CFSTR("external"), 0)==kCFCompareEqualTo) {
        if(!CFDictionaryContainsKey(dependentVariableDictionary, CFSTR("components_url"))) {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("No components_url key found."), NULL);
            return NULL;
        }
        csdm_components_url = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("components_url"));
    }


    if(!CFDictionaryContainsKey(dependentVariableDictionary, CFSTR("numeric_type"))) {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("No numeric_type key found."), NULL);
        return NULL;
    }

    CFStringRef numeric_type = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("numeric_type"));
    csdmNumericType elementType;
    if(CFStringCompare(numeric_type, CFSTR("uint8"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberUInt8Type;
    else if(CFStringCompare(numeric_type, CFSTR("uint16"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberUInt16Type;
    else if(CFStringCompare(numeric_type, CFSTR("uint32"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberUInt32Type;
    else if(CFStringCompare(numeric_type, CFSTR("uint64"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberUInt64Type;
    else if(CFStringCompare(numeric_type, CFSTR("int8"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberSInt8Type;
    else if(CFStringCompare(numeric_type, CFSTR("int16"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberSInt16Type;
    else if(CFStringCompare(numeric_type, CFSTR("int32"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberSInt32Type;
    else if(CFStringCompare(numeric_type, CFSTR("int64"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberSInt64Type;
    else if(CFStringCompare(numeric_type, CFSTR("float32"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberFloat32Type;
    else if(CFStringCompare(numeric_type, CFSTR("float64"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberFloat64Type;
    else if(CFStringCompare(numeric_type, CFSTR("complex64"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberComplex64Type;
    else if(CFStringCompare(numeric_type, CFSTR("complex128"), 0)==kCFCompareEqualTo) elementType = kCSDMNumberComplex128Type;
    else {
        if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("illegal numeric_type key found."), NULL);
        return NULL;
    }
    
    CFStringRef name = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("name"));
    CFStringRef description = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("description"));
    CFStringRef unitString = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("unit"));
    PSUnitRef unit = PSUnitDimensionlessAndUnderived();
    if(unitString) {
        double unit_multiplier = 1;
        unit = PSUnitForParsedSymbol(unitString, &unit_multiplier, error);
        if(unit==NULL) return NULL;
    }

    

    CFStringRef quantity_name = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("quantity_name"));

    CFArrayRef component_labels = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("component_labels"));
    if(NULL==component_labels) component_labels = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("component_names"));
    CFDictionaryRef sparse_sampling = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("sparse_sampling"));
    CFStringRef encoding = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("encoding"));
    if(NULL==encoding) encoding = CFSTR("none");
    bool base64 = (CFStringCompare(encoding, CFSTR("base64"), 0)==kCFCompareEqualTo);
    
    PSMutableIndexSetRef sparseDimensionIndexes = NULL;
    CFMutableArrayRef sparseGridVertexes = NULL;
    if(sparse_sampling) {
        
        CFStringRef unsigned_integer_type = CFDictionaryGetValue(sparse_sampling, CFSTR("unsigned_integer_type"));
        csdmNumericType unsignedIntType;
        if(CFStringCompare(unsigned_integer_type, CFSTR("uint8"), 0)==kCFCompareEqualTo) unsignedIntType = kCSDMNumberUInt8Type;
        else if(CFStringCompare(unsigned_integer_type, CFSTR("uint16"), 0)==kCFCompareEqualTo) unsignedIntType = kCSDMNumberUInt16Type;
        else if(CFStringCompare(unsigned_integer_type, CFSTR("uint32"), 0)==kCFCompareEqualTo) unsignedIntType = kCSDMNumberUInt32Type;
        else if(CFStringCompare(unsigned_integer_type, CFSTR("uint64"), 0)==kCFCompareEqualTo) unsignedIntType = kCSDMNumberUInt64Type;
        else {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("illegal unsigned_integer_type key found."), NULL);
            return NULL;
        }

        CFArrayRef numbers = CFDictionaryGetValue(sparse_sampling, CFSTR("dimension_indexes"));
        CFIndex numberSparseDimensions = CFArrayGetCount(numbers);
        // Copy numbers array over to sparseDimensionIndexes array
        sparseDimensionIndexes = PSIndexSetCreateMutable();
        for(CFIndex index = 0;index<numberSparseDimensions;index++) {
            CFNumberRef dimensionIndex = CFArrayGetValueAtIndex(numbers, index);
            PSIndexSetAddIndex(sparseDimensionIndexes, PSCFNumberCFIndexValue(dimensionIndex));
        }
        
        // Get vertexes
        CFDataRef vertexData = NULL;
        CFStringRef sparse_encoding = CFDictionaryGetValue(sparse_sampling, CFSTR("encoding"));

        if(sparse_encoding && CFStringCompare(sparse_encoding, CFSTR("base64"), 0)==kCFCompareEqualTo) {
            CFStringRef base64Vertexes = CFDictionaryGetValue(sparse_sampling, CFSTR("sparse_grid_vertexes"));
            vertexData = (CFDataRef) [[NSData alloc] initWithBase64EncodedString:(NSString *) base64Vertexes options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
        else {
            CFArrayRef numbers = CFDictionaryGetValue(sparse_sampling, CFSTR("sparse_grid_vertexes"));
            vertexData = PSCFDataCreateFromNSNumberArray(numbers, unsignedIntType);
        }
        
        // Sparse Grid Vertex is set of coordinate indexes from each sparse dimension
        // Create IndexPair structures of dimension index and coordinate index
        // for each sparse dimension, and put them into an IndexPairSet
        // Pack IndexPairSets into array
        
        
        int64_t count = CFDataGetLength(vertexData)/CSDMNumberTypeElementSize(unsignedIntType)/numberSparseDimensions;
        sparseGridVertexes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFIndex *sparseDimensionIndexesPtr = PSIndexSetGetBytePtr(sparseDimensionIndexes);

        if(unsignedIntType == kCSDMNumberUInt8Type) {
            uint8_t *indexes = (uint8_t *) CFDataGetBytePtr(vertexData);
            uint8_t offset = 0;
            for(uint8_t index = 0; index<count; index++) { // Loop over sparse vertexes
                PSMutableIndexPairSetRef sparseGridVertex = PSIndexPairSetCreateMutable();
                for(uint8_t dimIndex = 0; dimIndex<numberSparseDimensions;dimIndex++){
                    uint8_t sparseDimensionIndex = sparseDimensionIndexesPtr[dimIndex];
                    uint8_t coordinateIndex = indexes[offset];
                    PSIndexPairSetAddIndexPair(sparseGridVertex, sparseDimensionIndex, coordinateIndex);
                    offset++;
                }
                CFArrayAppendValue(sparseGridVertexes, sparseGridVertex);
                CFRelease(sparseGridVertex);
            }
        }
        else if(unsignedIntType == kCSDMNumberUInt16Type)
        {
            uint16_t *indexes = (uint16_t *) CFDataGetBytePtr(vertexData);
            uint16_t offset = 0;
            for(uint16_t index = 0; index<count; index++) { // Loop over sparse vertexes
                PSMutableIndexPairSetRef sparseGridVertex = PSIndexPairSetCreateMutable();
                for(uint16_t dimIndex = 0; dimIndex<numberSparseDimensions;dimIndex++){
                    uint16_t sparseDimensionIndex = sparseDimensionIndexesPtr[dimIndex];
                    uint16_t coordinateIndex = indexes[offset];
                    PSIndexPairSetAddIndexPair(sparseGridVertex, sparseDimensionIndex, coordinateIndex);
                    offset++;
                }
                CFArrayAppendValue(sparseGridVertexes, sparseGridVertex);
                CFRelease(sparseGridVertex);
            }
        }
        else if(unsignedIntType == kCSDMNumberUInt32Type)
        {
            uint32_t *indexes = (uint32_t *) CFDataGetBytePtr(vertexData);
            uint32_t offset = 0;
            for(uint32_t index = 0; index<count; index++) { // Loop over sparse vertexes
                PSMutableIndexPairSetRef sparseGridVertex = PSIndexPairSetCreateMutable();
                for(uint32_t dimIndex = 0; dimIndex<numberSparseDimensions;dimIndex++){
                    uint32_t sparseDimensionIndex = (uint32_t) sparseDimensionIndexesPtr[dimIndex];
                    uint32_t coordinateIndex = indexes[offset];
                    PSIndexPairSetAddIndexPair(sparseGridVertex, sparseDimensionIndex, coordinateIndex);
                    offset++;
                }
                CFArrayAppendValue(sparseGridVertexes, sparseGridVertex);
                CFRelease(sparseGridVertex);
            }
        }
        else if(unsignedIntType == kCSDMNumberUInt64Type)
        {
            int64_t *indexes = (int64_t *) CFDataGetBytePtr(vertexData);
            int64_t offset = 0;
            for(int64_t index = 0; index<count; index++) { // Loop over sparse vertexes
                PSMutableIndexPairSetRef sparseGridVertex = PSIndexPairSetCreateMutable();
                for(int64_t dimIndex = 0; dimIndex<numberSparseDimensions;dimIndex++){
                    int64_t sparseDimensionIndex = sparseDimensionIndexesPtr[dimIndex];
                    int64_t coordinateIndex = indexes[offset];
                    PSIndexPairSetAddIndexPair(sparseGridVertex, sparseDimensionIndex, coordinateIndex);
                    offset++;
                }
                CFArrayAppendValue(sparseGridVertexes, sparseGridVertex);
                CFRelease(sparseGridVertex);
            }
        }
        
        CFRelease(vertexData);
    }
    
    
    csdmNumericType originalType = elementType;
    
    CFMutableArrayRef components = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    if(CFStringCompare(type, CFSTR("internal"), 0) == kCFCompareEqualTo) {
        componentsCount = CFArrayGetCount(componentsArray);
        if(base64) {
            for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
                CFStringRef base64String = CFArrayGetValueAtIndex(componentsArray, componentIndex);
                CFDataRef componentData = (CFDataRef) [[NSData alloc] initWithBase64EncodedString:(NSString *) base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                switch(originalType) {
                    case kCSDMNumberUInt8Type:
                    case kCSDMNumberUInt16Type:
                    case kCSDMNumberUInt32Type:
                    case kCSDMNumberUInt64Type:
                    case kCSDMNumberSInt8Type:
                    case kCSDMNumberSInt16Type:
                    case kCSDMNumberSInt32Type:
                    case kCSDMNumberSInt64Type: {
                        CFDataRef temp = PSCFDataCreateFromCSDMNumericTypeData(componentData, originalType, kPSNumberFloat32Type);
                        CFRelease(componentData);
                        componentData = temp;
                        elementType = kCSDMNumberFloat32Type;
                    }
                        break;
                    default:
                        break;
                }
                
                CFArrayAppendValue(components, componentData);
                CFRelease(componentData);
            }
        }
        else {
            for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
                CFArrayRef numbers = CFArrayGetValueAtIndex(componentsArray, componentIndex);
                switch(originalType) {
                    case kCSDMNumberUInt8Type:
                    case kCSDMNumberUInt16Type:
                    case kCSDMNumberUInt32Type:
                    case kCSDMNumberUInt64Type:
                    case kCSDMNumberSInt8Type:
                    case kCSDMNumberSInt16Type:
                    case kCSDMNumberSInt32Type:
                    case kCSDMNumberSInt64Type: {
                        elementType = kCSDMNumberFloat32Type;
                    }
                        break;
                    default:
                        break;
                }
                
                CFDataRef componentData = PSCFDataCreateFromNSNumberArray(numbers, elementType);
                CFArrayAppendValue(components, componentData);
                CFRelease(componentData);
            }
        }
    }
    else if(CFStringCompare(type, CFSTR("external"), 0) == kCFCompareEqualTo) {
        NSCharacterSet *set = [NSCharacterSet URLFragmentAllowedCharacterSet];
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:[(NSString *) csdm_components_url stringByAddingPercentEncodingWithAllowedCharacters:set]];
        
        NSURL *dataFileURL = [urlComponents URL];
        if(nil==urlComponents.scheme) urlComponents.scheme = @"file";
        
        NSData *fileData = nil;
        if([urlComponents.scheme isEqualToString:@"file"]) {
            NSString *folderName = [[[(NSArray *) folderContents objectAtIndex:0] URLByDeletingLastPathComponent] absoluteString];
            NSURLComponents *folderURLComponents = [NSURLComponents componentsWithString:folderName];
            NSString *absolutePath = [[[folderURLComponents.path stringByAppendingPathComponent:urlComponents.path] stringByStandardizingPath] stringByAddingPercentEncodingWithAllowedCharacters:set];
            
            fileData = [[NSFileManager defaultManager] contentsAtPath: absolutePath];
            
            // This shouldn't be necessary
            if(fileData==NULL) {
                for(NSURL *url in (NSArray *) folderContents) {
                    NSURLComponents *allowedURL = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
                    NSString *allowedPath = [allowedURL.path stringByAddingPercentEncodingWithAllowedCharacters:set];

                    if([allowedPath isEqualToString:absolutePath]) {
                        dataFileURL = url;
                        NSError *fileError = nil;
                        fileData = [NSData dataWithContentsOfURL:dataFileURL options:NSDataReadingUncached error:&fileError];

                        break;
                    }
                }
                }
        }
        else {
            NSError *fileError = nil;
            fileData = [NSData dataWithContentsOfURL:dataFileURL options:NSDataReadingUncached error:&fileError];
        }
        
        if(NULL==fileData) {
            if(error) *error = PSCFErrorCreate(CFSTR("Cannot read dependent variable object."), CFSTR("Could not find or open external data file."), NULL);
            return NULL;
        }
        CFIndex fileByteSize = [fileData length];
        int typeSize = CSDMNumberTypeElementSize(elementType);
        
        CFIndex numberPoints = PSDimensionCalculateSizeFromDimensions(dimensions);
        if(sparseDimensionIndexes) {
            numberPoints = PSDimensionCalculateSizeFromDimensionsIgnoreDimensions(dimensions, sparseDimensionIndexes)*CFArrayGetCount(sparseGridVertexes);
        }

        for(CFIndex componentIndex=0;componentIndex<componentsCount;componentIndex++) {
            CFIndex componentByteSize = typeSize*numberPoints;
            NSRange range = {componentIndex*componentByteSize,componentByteSize};
            NSData *componentData = [[fileData subdataWithRange:range] retain];
            
            switch(originalType) {
                case kCSDMNumberUInt8Type:
                case kCSDMNumberUInt16Type:
                case kCSDMNumberUInt32Type:
                case kCSDMNumberUInt64Type:
                case kCSDMNumberSInt8Type:
                case kCSDMNumberSInt16Type:
                case kCSDMNumberSInt32Type:
                case kCSDMNumberSInt64Type: {
                    CFDataRef temp = PSCFDataCreateFromCSDMNumericTypeData((CFDataRef) componentData, originalType, kPSNumberFloat32Type);
                    CFRelease(componentData);
                    componentData = (NSData*) temp;
                    elementType = kCSDMNumberFloat32Type;
                }
                    break;
                default:
                    break;
            }
            
            CFArrayAppendValue(components, componentData);
            CFRelease(componentData);

        }
        // Set base64 to true so it becomes default value in case file is re-saved as csdf.
        base64 = true;
    }
    
    CFArrayRef unpackedComponents = NULL;
    if(sparse_sampling) {
        unpackedComponents = PSDependentVariableCreateUnPackedSparseComponentsArray(elementType,
                                                                                    components,
                                                                                    dimensions,
                                                                                    sparseDimensionIndexes,
                                                                                    sparseGridVertexes);
        CFRelease(components);
        components = (CFMutableArrayRef) unpackedComponents;
    }
    
    CFDictionaryRef plotDict = NULL;
    CFDictionaryRef metaData = NULL;
    if(CFDictionaryContainsKey(dependentVariableDictionary, CFSTR("application"))) {
        CFDictionaryRef application = CFDictionaryGetValue(dependentVariableDictionary, CFSTR("application"));
        
        if(CFDictionaryContainsKey(application, CFSTR("com.physyapps.rmn"))) {
            CFDictionaryRef RMNDictionary = CFDictionaryGetValue(application, CFSTR("com.physyapps.rmn"));
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("plot")))
                plotDict = CFDictionaryGetValue(RMNDictionary, CFSTR("plot"));
            
            
            if(CFDictionaryContainsKey(RMNDictionary, CFSTR("metaData"))) {
                metaData = PSCFDictionaryCreateWithPListCompatibleDictionary(CFDictionaryGetValue(RMNDictionary, CFSTR("metaData")),error);
            }
            
        }
    }

    PSDependentVariableRef theDependentVariable = PSDependentVariableCreate(name,
                                                                            description,
                                                                            unit,
                                                                            quantity_name,
                                                                            quantity_type,
                                                                            elementType,
                                                                            component_labels,
                                                                            components,
                                                                            NULL,
                                                                            theDataset);
    CFRelease(components);

    
    if(plotDict) {
        theDependentVariable->plot = PSPlotCreateWithPList(plotDict, theDependentVariable, error);
    }
    else {
        theDependentVariable->plot =  PSPlotCreateWithDependentVariable(theDependentVariable);

    }
    
    if(sparseDimensionIndexes && sparseGridVertexes) {
        theDependentVariable->sparseDimensionIndexes = sparseDimensionIndexes;
        theDependentVariable->sparseGridVertexes = sparseGridVertexes;
    }
    PSDependentVariableSetMetaData(theDependentVariable, metaData);
    if(metaData) CFRelease(metaData);
    
    return theDependentVariable;
}


#pragma mark Tests

bool PSDependentVariableEqualWithSameReducedDimensionality(PSDependentVariableRef input1, PSDependentVariableRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    if(input1 == input2) return true;
    if(CFStringCompare(input1->name, input2->name, 0)!=kCFCompareEqualTo) return false;
    if(CFStringCompare(input1->quantityName, input2->quantityName, 0)!=kCFCompareEqualTo) return false;
    if(CFStringCompare(input1->quantityType, input2->quantityType, 0)!=kCFCompareEqualTo) return false;
    if(CFStringCompare(input1->description, input2->description, 0)!=kCFCompareEqualTo) return false;
    if(!PSQuantityHasSameReducedDimensionality(input1, input2)) return false;
    if(input1->elementType != input2->elementType) return false;
    CFIndex componentCount1 = CFArrayGetCount(input1->components);
    CFIndex componentsCount2 = CFArrayGetCount(input2->components);
    if(componentCount1 != componentsCount2) return false;
    CFIndex namesCount1 = CFArrayGetCount(input1->componentLabels);
    CFIndex namesCount2 = CFArrayGetCount(input2->componentLabels);
    if(namesCount1 != namesCount2) return false;
    
    for(CFIndex componentIndex=0;componentIndex<componentCount1;componentIndex++) {
        CFDataRef values1 = CFArrayGetValueAtIndex(input1->components, componentIndex);
        CFDataRef values2 = CFArrayGetValueAtIndex(input2->components, componentIndex);
        if(CFDataGetLength(values1) != CFDataGetLength(values2)) return false;
    }
    
    for(CFIndex componentIndex=0;componentIndex<componentCount1;componentIndex++) {
        CFStringRef label1 = CFArrayGetValueAtIndex(input1->componentLabels, componentIndex);
        CFStringRef label2 = CFArrayGetValueAtIndex(input2->componentLabels, componentIndex);
        if(CFStringCompare(label1, label2, 0)!=kCFCompareEqualTo) return false;
    }
    
    for(CFIndex componentIndex=0;componentIndex<componentCount1;componentIndex++) {
        CFDataRef values1 = CFArrayGetValueAtIndex(input1->components, componentIndex);
        CFDataRef values2 = CFArrayGetValueAtIndex(input2->components, componentIndex);
        if(!CFEqual(values1,values2)) return false;
    }
    
    if(input1->sparseDimensionIndexes && input2->sparseDimensionIndexes==NULL) return false;
    if(input2->sparseDimensionIndexes && input1->sparseDimensionIndexes==NULL) return false;
    
    if(input1->sparseGridVertexes && input2->sparseGridVertexes==NULL) return false;
    if(input2->sparseGridVertexes && input1->sparseGridVertexes==NULL) return false;
    
    if(input1->sparseDimensionIndexes==NULL && input2->sparseDimensionIndexes==NULL) return true;
    
    if(input1->sparseDimensionIndexes) {
        if(!PSIndexSetEqual(input1->sparseDimensionIndexes, input2->sparseDimensionIndexes)) return false;
        CFIndex sparseVertexCount1 = CFArrayGetCount(input1->sparseGridVertexes);
        CFIndex sparseVertexCount2 = CFArrayGetCount(input2->sparseGridVertexes);
        if(sparseVertexCount1!=sparseVertexCount2) return false;
        for(CFIndex iVertex=0;iVertex<sparseVertexCount1;iVertex++) {
            PSIndexPairSetRef indexPairs1 = CFArrayGetValueAtIndex(input1->sparseGridVertexes, iVertex);
            PSIndexPairSetRef indexPairs2 = CFArrayGetValueAtIndex(input2->sparseGridVertexes, iVertex);
            if(!PSIndexPairSetEqual(indexPairs1, indexPairs2)) return false;
        }
    }
    return true;
}


bool PSDependentVariableEqual(PSDependentVariableRef input1, PSDependentVariableRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1,false);
    IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    if(input1 == input2) return true;
    if(CFStringCompare(input1->name, input2->name, 0)!=kCFCompareEqualTo) return false;
    if(CFStringCompare(input1->quantityName, input2->quantityName, 0)!=kCFCompareEqualTo) return false;
    if(CFStringCompare(input1->quantityType, input2->quantityType, 0)!=kCFCompareEqualTo) return false;
    if(CFStringCompare(input1->description, input2->description, 0)!=kCFCompareEqualTo) return false;
    if(input1->unit != input2->unit) return false;
    if(input1->elementType != input2->elementType) return false;
    CFIndex componentCount1 = CFArrayGetCount(input1->components);
    CFIndex componentsCount2 = CFArrayGetCount(input2->components);
    if(componentCount1 != componentsCount2) return false;
    CFIndex namesCount1 = CFArrayGetCount(input1->componentLabels);
    CFIndex namesCount2 = CFArrayGetCount(input2->componentLabels);
    if(namesCount1 != namesCount2) return false;
    
    for(CFIndex componentIndex=0;componentIndex<componentCount1;componentIndex++) {
        CFDataRef values1 = CFArrayGetValueAtIndex(input1->components, componentIndex);
        CFDataRef values2 = CFArrayGetValueAtIndex(input2->components, componentIndex);
        if(CFDataGetLength(values1) != CFDataGetLength(values2)) return false;
    }
    
    for(CFIndex componentIndex=0;componentIndex<componentCount1;componentIndex++) {
        CFStringRef label1 = CFArrayGetValueAtIndex(input1->componentLabels, componentIndex);
        CFStringRef label2 = CFArrayGetValueAtIndex(input2->componentLabels, componentIndex);
        if(CFStringCompare(label1, label2, 0)!=kCFCompareEqualTo) return false;
    }
    
    for(CFIndex componentIndex=0;componentIndex<componentCount1;componentIndex++) {
        CFDataRef values1 = CFArrayGetValueAtIndex(input1->components, componentIndex);
        CFDataRef values2 = CFArrayGetValueAtIndex(input2->components, componentIndex);
        if(!CFEqual(values1,values2)) return false;
    }
    
    if(input1->sparseDimensionIndexes && input2->sparseDimensionIndexes==NULL) return false;
    if(input2->sparseDimensionIndexes && input1->sparseDimensionIndexes==NULL) return false;
    
    if(input1->sparseGridVertexes && input2->sparseGridVertexes==NULL) return false;
    if(input2->sparseGridVertexes && input1->sparseGridVertexes==NULL) return false;
    
    if(input1->sparseDimensionIndexes==NULL && input2->sparseDimensionIndexes==NULL) return true;
    
    if(input1->sparseDimensionIndexes) {
        if(!PSIndexSetEqual(input1->sparseDimensionIndexes, input2->sparseDimensionIndexes)) return false;
        CFIndex sparseVertexCount1 = CFArrayGetCount(input1->sparseGridVertexes);
        CFIndex sparseVertexCount2 = CFArrayGetCount(input2->sparseGridVertexes);
        if(sparseVertexCount1!=sparseVertexCount2) return false;
        for(CFIndex iVertex=0;iVertex<sparseVertexCount1;iVertex++) {
            PSIndexPairSetRef indexPairs1 = CFArrayGetValueAtIndex(input1->sparseGridVertexes, iVertex);
            PSIndexPairSetRef indexPairs2 = CFArrayGetValueAtIndex(input2->sparseGridVertexes, iVertex);
            if(!PSIndexPairSetEqual(indexPairs1, indexPairs2)) return false;
        }
    }
    return true;
}


@end


