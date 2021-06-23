//
//  PSIndexArray.c
//
//  Created by PhySy Ltd on 10/21/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDataset.h>

@interface PSIndexArray ()
{
@private
    CFMutableDataRef indexes;
}
@end

@implementation PSIndexArray

- (void) dealloc
{
    if(self->indexes) CFRelease(self->indexes);
    self->indexes = NULL;
   [super dealloc];
}

PSIndexArrayRef PSIndexArrayCreate(CFIndex *indexes, CFIndex numValues)
{
    // Initialize object
    
    PSIndexArray *newIndexArray = [PSIndexArray alloc];
    
    // *** Setup attributes ***
    
    newIndexArray->indexes = (CFMutableDataRef) CFDataCreate(kCFAllocatorDefault, (const UInt8 *) indexes, numValues*sizeof(CFIndex));
    return (PSIndexArrayRef) newIndexArray;
}

PSMutableIndexArrayRef PSIndexArrayCreateMutable(CFIndex capacity)
{
    // Initialize object
    
    PSIndexArray *newIndexArray = [PSIndexArray alloc];
    
    // *** Setup attributes ***
    
    newIndexArray->indexes = CFDataCreateMutable(kCFAllocatorDefault, capacity*sizeof(CFIndex));
    CFDataSetLength(newIndexArray->indexes, capacity*sizeof(CFIndex));
    return (PSMutableIndexArrayRef) newIndexArray;
}

static PSIndexArrayRef PSIndexArrayCreateWithParameters(CFDataRef indexes)
{
    PSIndexArray *newIndexArray = [PSIndexArray alloc];
    
    // *** Setup attributes ***
    
    newIndexArray->indexes = (CFMutableDataRef) CFDataCreateCopy(kCFAllocatorDefault, indexes);
    return (PSIndexArrayRef) newIndexArray;
}

static PSMutableIndexArrayRef PSIndexArrayCreateMutableWithParameters(CFMutableDataRef indexes)
{
    PSIndexArray *newIndexArray = [PSIndexArray alloc];
    
    // *** Setup attributes ***
    
    newIndexArray->indexes = CFDataCreateMutableCopy(kCFAllocatorDefault,CFDataGetLength(indexes),indexes);
    return (PSMutableIndexArrayRef) newIndexArray;
}

PSIndexArrayRef PSIndexArrayCreateCopy(PSIndexArrayRef theIndexArray)
{
	return PSIndexArrayCreateWithParameters(theIndexArray->indexes);
}

PSMutableIndexArrayRef PSIndexArrayCreateMutableCopy(PSIndexArrayRef theIndexArray)
{
	return PSIndexArrayCreateMutableWithParameters(theIndexArray->indexes);
}

CFIndex PSIndexArrayGetCount(PSIndexArrayRef theIndexArray)
{
    if(theIndexArray->indexes) return CFDataGetLength(theIndexArray->indexes)/sizeof(CFIndex);
    return 0;
}

CFIndex *PSIndexArrayGetMutableBytePtr(PSIndexArrayRef theIndexArray) {
    if(theIndexArray->indexes)
        return (CFIndex *) CFDataGetMutableBytePtr(theIndexArray->indexes);
    return NULL;
}

CFIndex PSIndexArrayGetValueAtIndex(PSIndexArrayRef theIndexArray, CFIndex index)
{
    if(theIndexArray->indexes) {
        CFIndex *indexes = (CFIndex *) CFDataGetBytePtr(theIndexArray->indexes);
        return indexes[index];
    }
    return kCFNotFound;
}

bool PSIndexArraySetValueAtIndex(PSMutableIndexArrayRef theIndexArray, CFIndex index, CFIndex value)
{
    if(theIndexArray->indexes) {
        CFIndex *indexes = (CFIndex *) CFDataGetBytePtr(theIndexArray->indexes);
        indexes[index] = value;
        return true;
    }
    return false;
}

bool PSIndexArrayRemoveValueAtIndex(PSMutableIndexArrayRef theIndexArray, CFIndex index)
{
    if(theIndexArray->indexes) {
        CFIndex *oldIndexes = (CFIndex *) CFDataGetBytePtr(theIndexArray->indexes);
        CFIndex count = PSIndexArrayGetCount(theIndexArray);
        CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, (count-1)*sizeof(CFIndex));
        CFDataSetLength(data, (count-1)*sizeof(CFIndex));
        CFIndex *newIndexes = (CFIndex *) CFDataGetMutableBytePtr(data);
        CFIndex j = 0;
        for(CFIndex i =0; i<count; i++) {
            if(i != index)
                newIndexes[j++] = oldIndexes[i];
        }
        CFRelease(theIndexArray->indexes);
        theIndexArray->indexes = data;
        return true;
    }
    return false;
 
}

void PSIndexArrayRemoveValuesAtIndexes(PSMutableIndexArrayRef theIndexArray, PSIndexSetRef theIndexSet)
{
    if(theIndexArray==NULL) return;
    if(theIndexSet==NULL) return;
    
    CFIndex count = PSIndexSetGetCount(theIndexSet);
    if(count) {
        CFIndex index = PSIndexSetLastIndex(theIndexSet);
        PSIndexArrayRemoveValueAtIndex(theIndexArray, index);
        for(CFIndex i=0; i<count-1; i++) {
            index = PSIndexSetIndexLessThanIndex(theIndexSet, index);
            if(index==kCFNotFound) return;
            PSIndexArrayRemoveValueAtIndex(theIndexArray, index);
        }
    }
}


bool PSIndexArrayContainsIndex(PSIndexArrayRef theIndexArray, CFIndex index)
{
    if(theIndexArray->indexes) {
        CFIndex count = PSIndexArrayGetCount(theIndexArray);
        CFIndex *indexes = (CFIndex *) CFDataGetBytePtr(theIndexArray->indexes);
        for(int32_t i=0;i<count;i++) if(indexes[i] == index) return true;
    }
    return false;
}

bool PSIndexArrayAppendValue(PSMutableIndexArrayRef theIndexArray, CFIndex index)
{
    if(theIndexArray->indexes) {
        CFIndex count = PSIndexArrayGetCount(theIndexArray);
        CFDataIncreaseLength(theIndexArray->indexes, sizeof(CFIndex));
        CFIndex *indexes = (CFIndex *) CFDataGetBytePtr(theIndexArray->indexes);
        indexes[count] = index;
        return true;
    }
    return false;
}

CFStringRef PSIndexArrayCreateBase64String(PSIndexArrayRef theIndexArray, csdmNumericType integerType)
{
    CFIndex *indexes = (CFIndex *) CFDataGetBytePtr(theIndexArray->indexes);
    if(integerType == kCSDMNumberUInt8Type || integerType == kCSDMNumberSInt8Type) {
        CFIndex count = PSIndexArrayGetCount(theIndexArray);
        uint8_t *theIndexes = malloc(count*sizeof(uint8_t));
        for(CFIndex i=0;i<count;i++) theIndexes[i] = indexes[i];
        CFDataRef theData = CFDataCreate(kCFAllocatorDefault, theIndexes, sizeof(uint8_t)*count);
        CFStringRef result = (CFStringRef) [[(NSData *) theData base64EncodedStringWithOptions:0] retain];
        CFRelease(theData);
        free(theIndexes);
        return result;
    }
    if(integerType == kCSDMNumberUInt16Type || integerType == kCSDMNumberSInt16Type) {
        CFIndex count = PSIndexArrayGetCount(theIndexArray);
        uint16_t *theIndexes = malloc(count*sizeof(uint16_t));
        for(CFIndex i=0;i<count;i++) theIndexes[i] = indexes[i];
        CFDataRef theData = CFDataCreate(kCFAllocatorDefault, (const unsigned char *) theIndexes, sizeof(uint16_t)*count);
        CFStringRef result = (CFStringRef) [[(NSData *) theData base64EncodedStringWithOptions:0] retain];
        CFRelease(theData);
        free(theIndexes);
        return result;
    }
    if(integerType == kCSDMNumberUInt32Type || integerType == kCSDMNumberSInt32Type) {
        CFIndex count = PSIndexArrayGetCount(theIndexArray);
        uint32_t *theIndexes = malloc(count*sizeof(uint32_t));
        for(CFIndex i=0;i<count;i++) theIndexes[i] = (uint32_t) indexes[i];
        CFDataRef theData = CFDataCreate(kCFAllocatorDefault, (const unsigned char *) theIndexes, sizeof(uint32_t)*count);
        CFStringRef result = (CFStringRef) [[(NSData *) theData base64EncodedStringWithOptions:0] retain];
        CFRelease(theData);
        free(theIndexes);
        return result;
    }
    if(integerType == kCSDMNumberUInt64Type || integerType == kCSDMNumberSInt64Type) {
        CFIndex count = PSIndexArrayGetCount(theIndexArray);
        uint64_t *theIndexes = malloc(count*sizeof(uint64_t));
        for(CFIndex i=0;i<count;i++) theIndexes[i] = indexes[i];
        CFDataRef theData = CFDataCreate(kCFAllocatorDefault, (const unsigned char *) theIndexes, sizeof(uint64_t)*count);
        CFStringRef result = (CFStringRef) [[(NSData *) theData base64EncodedStringWithOptions:0] retain];
        CFRelease(theData);
        free(theIndexes);
        return result;
    }
    return (CFStringRef) [[(NSData *) theIndexArray->indexes base64EncodedStringWithOptions:0] retain];
}

bool PSIndexArrayAppendValues(PSMutableIndexArrayRef theIndexArray, PSIndexArrayRef arrayToAppend)
{
    if(theIndexArray->indexes) {
        CFMutableDataRef newIndexes = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, theIndexArray->indexes);
        CFDataAppendBytes(newIndexes, CFDataGetBytePtr(arrayToAppend->indexes), CFDataGetLength(arrayToAppend->indexes));
        CFRelease(theIndexArray->indexes);
        theIndexArray->indexes = newIndexes;
        return true;
    }
    return false;
}


bool PSIndexArrayEqual(PSIndexArrayRef input1, PSIndexArrayRef input2)
{
	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    if(CFDataGetLength(input1->indexes) != CFDataGetLength(input2->indexes)) return false;
    CFIndex count = PSIndexArrayGetCount(input1);
    for(CFIndex index = 0; index<count; index++) {
        if(PSIndexArrayGetValueAtIndex(input1, index) != PSIndexArrayGetValueAtIndex(input2, index)) return false;
    }
	return true;
}

CFArrayRef PSIndexArrayCreateCFNumberArray(PSIndexArrayRef theIndexArray)
{
    CFIndex count = PSIndexArrayGetCount(theIndexArray);
    CFMutableArrayRef theArray = CFArrayCreateMutable(kCFAllocatorDefault, count, &kCFTypeArrayCallBacks);
    for(CFIndex i = 0;i<count;i++) {
        CFIndex index = PSIndexArrayGetValueAtIndex(theIndexArray, i);
        CFNumberRef number = PSCFNumberCreateWithCFIndex(index);
        CFArrayAppendValue(theArray, number);
        CFRelease(number);
    }
    return theArray;
}

CFDictionaryRef PSIndexArrayCreatePList(PSIndexArrayRef theIndexArray)
{
    CFMutableDictionaryRef dictionary = nil;
    if(theIndexArray) {
        dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue( dictionary, CFSTR("indexes"), theIndexArray->indexes);
        
	}
	return dictionary;
}

PSIndexArrayRef PSIndexArrayCreateWithPList(CFDictionaryRef dictionary)
{
	if(dictionary==NULL) return NULL;
	return PSIndexArrayCreateWithParameters(CFDictionaryGetValue(dictionary, CFSTR("indexes")));
}


CFDataRef PSIndexArrayCreateData(PSIndexArrayRef theIndexArray)
{
    if(theIndexArray == NULL) return NULL;
    return CFRetain(theIndexArray->indexes);
}

PSIndexArrayRef PSIndexArrayCreateWithData(CFDataRef data)
{
    if(data==nil) return nil;
    return PSIndexArrayCreateWithParameters(data);
}


void PSIndexArrayShow(PSIndexArrayRef theIndexArray)
{
    CFIndex count = PSIndexArrayGetCount(theIndexArray);
    fprintf(stderr, "(");
    for(CFIndex index = 0; index<count; index++)
    {
        fprintf(stderr, "%ld", PSIndexArrayGetValueAtIndex(theIndexArray, index));
        if(index<count-1) fprintf(stderr, ",");
    }
    fprintf(stderr, ")\n");
}

@end

