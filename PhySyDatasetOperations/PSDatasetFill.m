//
//  PSDatasetFill.c
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 11/7/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFMutableDictionaryRef PSDatasetFillCreateDefaultParametersForDataset(PSDatasetRef theDataset)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    int side = kPSDatasetFillRightSide;
    CFNumberRef theFillSide = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &side);
    CFDictionaryAddValue(parameters, kPSDatasetFillSide, theFillSide);
    CFRelease(theFillSide);
    
    CFIndex horizontalNpts = PSDimensionGetNpts(PSDatasetHorizontalDimension(theDataset));
    CFIndex fillLengthPerSide = horizontalNpts;
    do {
        fillLengthPerSide++;
    } while(!IsPowerOfTwo(fillLengthPerSide));
    fillLengthPerSide -= horizontalNpts;

    CFNumberRef fillLength = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &fillLengthPerSide);
    CFDictionaryAddValue(parameters, kPSDatasetFillLengthPerSide, fillLength);
    CFRelease(fillLength);
    
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    CFMutableArrayRef fillConstants = CFArrayCreateMutable(kCFAllocatorDefault, dependentVariablesCount, &kCFTypeArrayCallBacks);
    CFDictionaryAddValue(parameters, kPSDatasetFillConstants, fillConstants);
    CFRelease(fillConstants);
    for(CFIndex dependentVariableIndex=0;dependentVariableIndex<dependentVariablesCount;dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);
        PSScalarRef fillConstant = PSScalarCreateWithDoubleComplex(0.0, responseUnit);
        CFArrayAppendValue(fillConstants, fillConstant);
        CFRelease(fillConstant);
    }
    return parameters;
}

PSScalarRef PSDatasetFillGetFillConstantAtIndex(CFDictionaryRef parameters, CFIndex dependentVariableIndex)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFillConstants)) return NULL;
    CFArrayRef fillConstants = (CFArrayRef) CFDictionaryGetValue(parameters, kPSDatasetFillConstants);
    
    return CFArrayGetValueAtIndex(fillConstants, dependentVariableIndex);
}

CFArrayRef PSDatasetFillGetFillConstants(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,NULL);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFillConstants)) return NULL;
    return CFDictionaryGetValue(parameters, kPSDatasetFillConstants);
}

bool PSDatasetFillSetFillConstant(PSDatasetRef theDataset,
                                  CFIndex dependentVariableIndex,
                                  CFMutableDictionaryRef parameters,
                                  PSScalarRef fillConstant,
                                  CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    
    PSDimensionalityRef responseDimensionality = PSQuantityGetUnitDimensionality(theDependentVariable);
    if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality(fillConstant),
                                                     responseDimensionality)) {
        if(error) {
            CFStringRef desc = CFSTR("Fill constant and response have different dimensionalities.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }

    if(CFDictionaryContainsKey(parameters, kPSDatasetFillConstants)) {
        CFMutableArrayRef fillConstants = (CFMutableArrayRef) CFDictionaryGetValue(parameters, kPSDatasetFillConstants);
        CFArraySetValueAtIndex(fillConstants, dependentVariableIndex, fillConstant);
        return true;
    }
    
    return false;
}

CFIndex PSDatasetFillGetFillLengthPerSide(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,0);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFillLengthPerSide)) return 0;
    CFNumberRef fillLengthPerSide = CFDictionaryGetValue(parameters, kPSDatasetFillLengthPerSide);
    if(fillLengthPerSide) {
        CFIndex fillLength;
        CFNumberGetValue(fillLengthPerSide, kCFNumberNSIntegerType, &fillLength);
        return fillLength;
    }
    return 0;

}

bool PSDatasetFillSetFillLengthPerSide(CFMutableDictionaryRef parameters, CFIndex fillLengthPerSide, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    if(fillLengthPerSide<0) return false;
    
    CFNumberRef theFillLength = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &fillLengthPerSide);
    if(theFillLength) {
        bool containskey = CFDictionaryContainsKey(parameters, kPSDatasetFillLengthPerSide);
        if(containskey) {
            CFDictionaryReplaceValue(parameters, kPSDatasetFillLengthPerSide, theFillLength);
        }
        else CFDictionaryAddValue(parameters, kPSDatasetFillLengthPerSide, theFillLength);
        CFRelease(theFillLength);
        return true;
    }
    return false;
}

fillSide PSDatasetFillGetSide(CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,0);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFillSide)) return 0;
    CFNumberRef theFillSide = CFDictionaryGetValue(parameters, kPSDatasetFillSide);
    if(theFillSide) {
        int sideIndex;
        CFNumberGetValue(theFillSide, kCFNumberIntType, &sideIndex);
        fillSide side = sideIndex;
        return side;
    }
    return 0;
}

bool PSDatasetFillSetFillSide(CFMutableDictionaryRef parameters, fillSide side, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    if(side != kPSDatasetFillBothSides && side != kPSDatasetFillLeftSide && side != kPSDatasetFillRightSide) return false;
    
    CFNumberRef theFillSide = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &side);
    if(theFillSide) {
        bool containskey = CFDictionaryContainsKey(parameters, kPSDatasetFillSide);
        if(containskey) {
            CFDictionaryReplaceValue(parameters, kPSDatasetFillSide, theFillSide);
        }
        else CFDictionaryAddValue(parameters, kPSDatasetFillSide, theFillSide);
        CFRelease(theFillSide);
        return true;
    }
    return false;
}


bool PSDatasetFillValidateForDataset(PSDatasetRef theDataset,CFDictionaryRef parameters)
{
    IF_NO_OBJECT_EXISTS_RETURN(parameters,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFillConstants)) return false;
    if(!CFDictionaryContainsKey(parameters, kPSDatasetFillSide)) return false;

    CFNumberRef theFillSide = CFDictionaryGetValue(parameters, kPSDatasetFillSide);
    fillSide side;
    CFNumberGetValue(theFillSide, kCFNumberIntType, &side);
    if(side != kPSDatasetFillBothSides && side != kPSDatasetFillLeftSide && side != kPSDatasetFillRightSide) return false;


    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    for(CFIndex dependentVariableIndex=0;dependentVariableIndex<dependentVariablesCount;dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
        PSDimensionalityRef responseDimensionality = PSQuantityGetUnitDimensionality(theDependentVariable);
        PSScalarRef fillConstant = PSDatasetFillGetFillConstantAtIndex(parameters, dependentVariableIndex);
        if(!PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality((PSQuantityRef) fillConstant),
                                                         responseDimensionality)) return false;
    }
    return true;
}


PSDatasetRef PSDatasetFillCreateDatasetFromDataset(CFDictionaryRef parameters, PSDatasetRef input, CFErrorRef *error)
{
    if(error) if(*error) return NULL;

    char fillSide[2];
    switch(PSDatasetFillGetSide(parameters)) {
        case kPSDatasetFillLeftSide:
            fillSide[0] = 'l';
            break;
        case kPSDatasetFillRightSide:
            fillSide[0] = 'r';
            break;
        case kPSDatasetFillBothSides:
            fillSide[0] = 'b';
            break;
    }
    CFIndex dimIndex = PSDatasetGetHorizontalDimensionIndex(input);
    CFArrayRef fillConstants = PSDatasetFillGetFillConstants(parameters);
    CFIndex lengthPerSide = PSDatasetFillGetFillLengthPerSide(parameters);
    PSDatasetRef dataset = PSDatasetCreateByFillingAlongDimensions(input,
                                                                   dimIndex,
                                                                   fillConstants,
                                                                   fillSide,
                                                                   lengthPerSide);
    return dataset;
}



