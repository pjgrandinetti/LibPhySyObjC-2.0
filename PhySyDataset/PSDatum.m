//
//  PSDatum.c
//
//  Created by PhySy Ltd on 10/6/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDataset.h>

@implementation PSDatum

- (void) dealloc
{
    if(self->coordinates) CFRelease(self->coordinates);
    self->coordinates = NULL;

    [super dealloc];
}

/* Designated Creator */
/**************************/

bool PSDatumEqual(PSDatumRef input1, PSDatumRef input2)
{
	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    if(input1 == input2) return true;
    
	if(!PSScalarEqual((PSScalarRef) input1, (PSScalarRef) input2)) return false;
    if(CFArrayGetCount(input1->coordinates) != CFArrayGetCount(input2->coordinates)) return false;
    CFIndex coordinateCount = CFArrayGetCount(input1->coordinates);
    for(CFIndex idim = 0; idim<coordinateCount; idim++) {
        if(PSScalarCompare((PSScalarRef) CFArrayGetValueAtIndex(input1->coordinates, idim),
                          (PSScalarRef) CFArrayGetValueAtIndex(input2->coordinates, idim))!=kPSCompareEqualTo) return false;
    }
	return true;
}

PSDatumRef PSDatumCreate(PSScalarRef theScalar,
                         CFArrayRef coordinates,
                         CFIndex dependentVariableIndex,
                         CFIndex componentIndex,
                         CFIndex memOffset)
{
    if(NULL==theScalar) return NULL;
    
    // Initialize object
    PSDatum *newDatum = [PSDatum alloc];
    
    // *** Setup attributes ***
    newDatum->elementType = PSQuantityGetElementType(theScalar);
    newDatum->unit = PSQuantityGetUnit(theScalar);
    newDatum->value = PSScalarGetValue(theScalar);

    // Optional Attributes
    if(coordinates) newDatum->coordinates = CFArrayCreateCopy(kCFAllocatorDefault, coordinates);
    newDatum->dependentVariableIndex = dependentVariableIndex;
    newDatum->componentIndex = componentIndex;
    newDatum->memOffset = memOffset;

    return (PSDatumRef) newDatum;
}


PSDatumRef PSDatumCopy(PSDatumRef theDatum)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDatum, NULL);
    
    PSScalarRef response = PSDatumCreateResponse(theDatum);

    PSDatumRef copy = PSDatumCreate(response,
                                    theDatum->coordinates,
                                    theDatum->dependentVariableIndex,
                                    theDatum->componentIndex,
                                    theDatum->memOffset);
    CFRelease(response);
    return copy;
}

bool PSDatumHasSameReducedDimensionalities(PSDatumRef input1, PSDatumRef input2)
{
    IF_NO_OBJECT_EXISTS_RETURN(input1, false);
    IF_NO_OBJECT_EXISTS_RETURN(input2, false);

    CFIndex coordinateCount1 = 0;
    CFIndex coordinateCount2 = 0;
    if(input1->coordinates) coordinateCount1 = CFArrayGetCount(input1->coordinates);
    if(input2->coordinates) coordinateCount2 = CFArrayGetCount(input2->coordinates);
    if(coordinateCount1 != coordinateCount2) return false;
    if((input1->dependentVariableIndex==input2->dependentVariableIndex) && !PSQuantityHasSameReducedDimensionality((PSQuantityRef) input1,(PSQuantityRef) input2)) return false;
    
    for(CFIndex idim = 0; idim<coordinateCount1; idim++) {
        if(!PSQuantityHasSameReducedDimensionality((PSQuantityRef) CFArrayGetValueAtIndex(input1->coordinates, idim), 
                          (PSQuantityRef) CFArrayGetValueAtIndex(input2->coordinates, idim))) return false;
    }
	return true;
}

CFIndex PSDatumGetComponentIndex(PSDatumRef theDatum)
{
    if(NULL==theDatum) return kCFNotFound;
    return theDatum->componentIndex;
}

void PSDatumSetComponentIndex(PSDatumRef theDatum, CFIndex componentIndex)
{
    if(theDatum) theDatum->componentIndex = componentIndex;
}

CFIndex PSDatumGetDependentVariableIndex(PSDatumRef theDatum)
{
    if(NULL==theDatum) return kCFNotFound;
    return theDatum->dependentVariableIndex;
}

void PSDatumSetDependentVariableIndex(PSDatumRef theDatum, CFIndex dependentVariableIndex)
{
    if(theDatum) theDatum->dependentVariableIndex = dependentVariableIndex;
}

CFIndex PSDatumGetMemOffset(PSDatumRef theDatum)
{
    if(NULL==theDatum) return kCFNotFound;
    return theDatum->memOffset;
}

void PSDatumSetMemOffset(PSDatumRef theDatum, CFIndex memOffset)
{
    if(theDatum) theDatum->memOffset = memOffset;
}


PSScalarRef PSDatumGetCoordinateAtIndex(PSDatumRef theDatum, CFIndex index)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDatum, NULL);
    if(index==-1) return (PSScalarRef) theDatum;
    IF_NO_OBJECT_EXISTS_RETURN(theDatum->coordinates, NULL);
    return CFArrayGetValueAtIndex(theDatum->coordinates, index);
}

PSScalarRef PSDatumCreateResponse(PSDatumRef theDatum)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDatum, NULL);
    return PSScalarCreateCopy((PSScalarRef) theDatum);
}

CFIndex PSDatumCoordinatesCount(PSDatumRef theDatum)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDatum, 0);
    if(theDatum->coordinates) return CFArrayGetCount(theDatum->coordinates);
    return 0;
}



CFDictionaryRef PSDatumCreatePList(PSDatumRef theDatum)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDatum, NULL);
    
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    
    CFNumberRef number = PSCFNumberCreateWithCFIndex(theDatum->dependentVariableIndex);
    CFDictionarySetValue(dictionary, CFSTR("dependent_variable_index"), number);
    CFRelease(number);
    
    number = PSCFNumberCreateWithCFIndex(theDatum->componentIndex);
    CFDictionarySetValue(dictionary, CFSTR("component_index"), number);
    CFRelease(number);
    
    number = PSCFNumberCreateWithCFIndex(theDatum->memOffset);
    CFDictionarySetValue(dictionary, CFSTR("mem_offset"), number);
    CFRelease(number);
    
    CFStringRef stringValue = PSScalarCreateStringValue((PSScalarRef) theDatum);
    if(stringValue) {
        CFDictionarySetValue( dictionary, CFSTR("response"), stringValue);
        CFRelease(stringValue);
    }
    
    if(theDatum->coordinates) {
        CFIndex coordinatesCount = CFArrayGetCount(theDatum->coordinates);
        CFMutableArrayRef coordinates = CFArrayCreateMutable(kCFAllocatorDefault, coordinatesCount, &kCFTypeArrayCallBacks);
        for(CFIndex index =0; index<coordinatesCount; index++) {
            CFStringRef stringValue = PSScalarCreateStringValue(CFArrayGetValueAtIndex(theDatum->coordinates, index));
            CFArrayAppendValue(coordinates, stringValue);
            CFRelease(stringValue);
        }
        CFDictionarySetValue(dictionary, CFSTR("coordinates"),coordinates);
        CFRelease(coordinates);
    }
	return dictionary;
}



PSDatumRef PSDatumCreateWithPList(CFDictionaryRef dictionary, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(dictionary, NULL);
    
    CFIndex dependentVariableIndex = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("dependent_variable_index")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("dependent_variable_index")),kCFNumberCFIndexType,&dependentVariableIndex);
    else return NULL;
    
    CFIndex componentIndex = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("component_index")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("component_index")),kCFNumberCFIndexType,&componentIndex);
    else return NULL;
    
    CFIndex memOffset = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("mem_offset")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("mem_offset")),kCFNumberCFIndexType,&memOffset);
    else return NULL;
    
    
    CFMutableArrayRef coordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    if(CFDictionaryContainsKey (dictionary,CFSTR("coordinates"))) {
        CFMutableArrayRef stringValues = (CFMutableArrayRef) CFDictionaryGetValue(dictionary, CFSTR("coordinates"));
        CFIndex coordinatesCount = CFArrayGetCount(stringValues);
        for(CFIndex index=0;index<coordinatesCount;index++) {
            CFStringRef stringValue = CFArrayGetValueAtIndex(stringValues, index);
            PSScalarRef coordinate = PSScalarCreateWithCFString(stringValue,error);
            CFArrayAppendValue(coordinates, coordinate);
            CFRelease(coordinate);
        }
    }

    PSScalarRef response = NULL;
    if(CFDictionaryContainsKey (dictionary,CFSTR("response"))) {
        response = PSScalarCreateWithCFString(CFDictionaryGetValue(dictionary, CFSTR("response")),error);
    }
    
	PSDatumRef datum = PSDatumCreate(response, coordinates, dependentVariableIndex, componentIndex, memOffset);
    if(response) CFRelease(response);
    if(coordinates) CFRelease(coordinates);
    return datum;
}

PSDatumRef PSDatumCreateWithOldDataFormat(CFDataRef data, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(data, NULL);
    CFPropertyListFormat format;
    CFDictionaryRef dictionary  = CFPropertyListCreateWithData(kCFAllocatorDefault,data,kCFPropertyListImmutable,&format,error);
    IF_NO_OBJECT_EXISTS_RETURN(dictionary, NULL);
    
    CFIndex componentIndex = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("signalIndex")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("signalIndex")),kCFNumberCFIndexType,&componentIndex);
    
    CFIndex memOffset = 0;
    if(CFDictionaryContainsKey(dictionary, CFSTR("memOffset")))
        CFNumberGetValue(CFDictionaryGetValue(dictionary, CFSTR("memOffset")),kCFNumberCFIndexType,&memOffset);
    
    CFMutableArrayRef coordinates = NULL;
    if(CFDictionaryContainsKey (dictionary,CFSTR("coordinates"))) {
        coordinates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        CFMutableArrayRef array = (CFMutableArrayRef) CFDictionaryGetValue(dictionary, CFSTR("coordinates"));
        CFIndex count = CFArrayGetCount(array);
        for(CFIndex index=0; index<count; index++) {
            CFDataRef coordinateData = CFArrayGetValueAtIndex(array, index);
            PSScalarRef coordinate = PSScalarCreateWithData(coordinateData, error);
            CFArrayAppendValue(coordinates, coordinate);
            CFRelease(coordinate);
        }
    }
    
    PSScalarRef response = NULL;
    if(CFDictionaryContainsKey (dictionary,CFSTR("response")))
        response = PSScalarCreateWithData(CFDictionaryGetValue(dictionary, CFSTR("response")), error);
    
    PSDatumRef datum = PSDatumCreate(response,
                                     coordinates,
                                     0,
                                     componentIndex,
                                     memOffset);

    
    if(response) CFRelease(response);
    if(coordinates) CFRelease(coordinates);
    CFRelease(dictionary);
    return datum;
}


@end



