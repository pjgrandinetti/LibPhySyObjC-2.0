//
//  PSIndexPairSet.c
//
//  Created by PhySy Ltd on 10/21/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDataset.h>

@interface PSIndexPairSet ()
{
@private
    CFDataRef indexPairs;
}
@end

@implementation PSIndexPairSet

- (void) dealloc
{
    if(self->indexPairs) CFRelease(self->indexPairs);
    self->indexPairs = NULL;
    [super dealloc];
}

PSIndexPairSetRef PSIndexPairSetCreate()
{
    PSIndexPairSet *newIndexSet = [PSIndexPairSet alloc];
    newIndexSet->indexPairs = NULL;
    return (PSIndexPairSetRef) newIndexSet;
}

PSMutableIndexPairSetRef PSIndexPairSetCreateMutable(void)
{
    PSIndexPairSet *newIndexSet = [PSIndexPairSet alloc];
    newIndexSet->indexPairs = NULL;
    return (PSMutableIndexPairSetRef) newIndexSet;
}

static PSIndexPairSetRef PSIndexPairSetCreateWithParameters(CFDataRef indexPairs)
{
    PSIndexPairSet *newIndexSet = [PSIndexPairSet alloc];
    newIndexSet->indexPairs = CFDataCreateCopy(kCFAllocatorDefault, indexPairs);
    return (PSIndexPairSetRef) newIndexSet;
}

static PSMutableIndexPairSetRef PSIndexPairSetCreateMutableWithParameters(CFDataRef indexPairs)
{
    PSIndexPairSet *newIndexSet = [PSIndexPairSet alloc];
    newIndexSet->indexPairs = CFDataCreateCopy(kCFAllocatorDefault,indexPairs);
    return (PSMutableIndexPairSetRef) newIndexSet;
}

PSIndexPairSetRef PSIndexPairSetCreateCopy(PSIndexPairSetRef theIndexSet)
{
	return PSIndexPairSetCreateWithParameters(theIndexSet->indexPairs);
}

PSMutableIndexPairSetRef PSIndexPairSetCreateMutableCopy(PSIndexPairSetRef theIndexSet)
{
	return PSIndexPairSetCreateMutableWithParameters(theIndexSet->indexPairs);
}

PSMutableIndexPairSetRef PSIndexPairSetCreateMutableWithIndexArray(PSIndexArrayRef indexArray)
{
    PSMutableIndexPairSetRef indexPairSet = PSIndexPairSetCreateMutable();
    for(CFIndex index = 0; index<PSIndexArrayGetCount(indexArray); index++) {
        PSIndexPairSetAddIndexPair(indexPairSet, index, PSIndexArrayGetValueAtIndex(indexArray, index));
    }
    return indexPairSet;
}

PSIndexPairSetRef PSIndexPairSetCreateWithIndexPairArray(PSIndexPair *array, int numValues)
{
    PSIndexPairSet *newIndexSet = [PSIndexPairSet alloc];
    newIndexSet->indexPairs = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) array, numValues*sizeof(PSIndexPair));
    return (PSIndexPairSetRef) newIndexSet;

}

PSIndexPairSetRef PSIndexPairSetCreateWithIndexPair(CFIndex index, CFIndex value)
{
    PSIndexPairSet *newIndexSet = [PSIndexPairSet alloc];
    PSIndexPair indexPair = {index,value};
    // *** Setup attributes ***
    
    newIndexSet->indexPairs = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) &indexPair, sizeof(PSIndexPair));
    return (PSIndexPairSetRef) newIndexSet;
}

PSIndexPairSetRef PSIndexPairSetCreateWithTwoIndexPairs(CFIndex index1, CFIndex value1, CFIndex index2, CFIndex value2)
{
    PSIndexPairSet *newIndexSet = [PSIndexPairSet alloc];
    PSIndexPair indexPair[2] = {index1,value1,index2,value2};
    // *** Setup attributes ***
    
    newIndexSet->indexPairs = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) &indexPair, sizeof(PSIndexPair));
    return (PSIndexPairSetRef) newIndexSet;
}

CFDataRef PSIndexPairSetGetIndexPairs(PSIndexPairSetRef theIndexSet)
{
    return theIndexSet->indexPairs;
}

CFIndex PSIndexPairSetValueForIndex(PSIndexPairSetRef theIndexSet, CFIndex index)
{
    CFIndex count = PSIndexPairSetGetCount(theIndexSet);
    PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
    for(CFIndex i=0;i<count; i++) {
        if(indexPairs[i].index == index) return indexPairs[i].value;
    }
    return kCFNotFound;
}

PSIndexArrayRef PSIndexPairSetCreateIndexArrayOfValues(PSIndexPairSetRef theIndexSet)
{
    CFIndex count = PSIndexPairSetGetCount(theIndexSet);
    PSMutableIndexArrayRef values = PSIndexArrayCreateMutable(count);
    PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
    for(CFIndex index=0;index<PSIndexPairSetGetCount(theIndexSet); index++) {
        PSIndexArraySetValueAtIndex(values, index, indexPairs[index].value);
    }
    return values;
}

PSIndexSetRef PSIndexPairSetCreateIndexSetOfIndexes(PSIndexPairSetRef theIndexSet)
{
    PSMutableIndexSetRef indexes = PSIndexSetCreateMutable();
    PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
    for(CFIndex index=0;index<PSIndexPairSetGetCount(theIndexSet); index++) {
        PSIndexSetAddIndex(indexes, indexPairs[index].index);
    }
    return indexes;
}

PSIndexPair *PSIndexPairSetGetBytePtr(PSIndexPairSetRef theIndexSet)
{
    if(theIndexSet->indexPairs)
        return (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
    return NULL;
}

CFIndex PSIndexPairSetGetCount(PSIndexPairSetRef theIndexSet)
{
    if(theIndexSet->indexPairs) return CFDataGetLength(theIndexSet->indexPairs)/sizeof(PSIndexPair);
    return 0;
}

PSIndexPair PSIndexPairSetFirstIndex(PSIndexPairSetRef theIndexSet)
{
    if(theIndexSet->indexPairs) {
        PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
        return indexPairs[0];
    }
    PSIndexPair result = {kCFNotFound,0};
    return result;
}

PSIndexPair PSIndexPairSetLastIndex(PSIndexPairSetRef theIndexSet)
{
    if(theIndexSet->indexPairs) {
        CFIndex count = PSIndexPairSetGetCount(theIndexSet);
        PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
        return indexPairs[count-1];
    }
    PSIndexPair result = {kCFNotFound,0};
    return result;
}

PSIndexPair PSIndexPairSetIndexPairLessThanIndexPair(PSIndexPairSetRef theIndexSet, PSIndexPair indexPair)
{
    PSIndexPair noResult = {kCFNotFound,0};
    if(theIndexSet==NULL || theIndexSet->indexPairs == NULL) return noResult;
    CFIndex count = PSIndexPairSetGetCount(theIndexSet);
    PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
    for(CFIndex i=count-1; i>=0;i--) {
        if(indexPairs[i].index<indexPair.index) return indexPairs[i];
    }
    return noResult;
}

bool PSIndexPairSetContainsIndex(PSIndexPairSetRef theIndexSet, CFIndex index)
{
    if(theIndexSet->indexPairs) {
        CFIndex count = PSIndexPairSetGetCount(theIndexSet);
        PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
        for(int32_t i=0;i<count;i++)
            if(indexPairs[i].index == index) return true;
    }
    return false;
}

bool PSIndexPairSetContainsIndexPair(PSIndexPairSetRef theIndexSet, PSIndexPair indexPair)
{
    if(theIndexSet->indexPairs) {
        CFIndex count = PSIndexPairSetGetCount(theIndexSet);
        PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
        for(int32_t i=0;i<count;i++)
            if(indexPairs[i].index == indexPair.index && indexPairs[i].value == indexPair.value) return true;
    }
    return false;
}

bool PSIndexPairSetRemoveIndexPairWithIndex(PSMutableIndexPairSetRef theIndexSet, CFIndex index)
{
    if(!PSIndexPairSetContainsIndex(theIndexSet, index)) return false;

    CFIndex count = PSIndexPairSetGetCount(theIndexSet);
    if(count<1) return false;
    
    PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
    
    PSIndexPair newIndexPairs[count-1];
    CFIndex i = 0;
    for(CFIndex j = 0; j < count; j++) {
        if(indexPairs[j].index != index) {
            newIndexPairs[i++] = indexPairs[j];
        }
    }
    CFRelease(theIndexSet->indexPairs);
    
    theIndexSet->indexPairs = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) newIndexPairs, (count-1)*sizeof(PSIndexPair));
    return true;
}


bool PSIndexPairSetAddIndexPair(PSMutableIndexPairSetRef theIndexSet, CFIndex index, CFIndex value)
{
    int32_t i = 0;
    CFIndex count = 0;
    PSIndexPair indexPair = {index, value};

    if(theIndexSet->indexPairs) {
        count = PSIndexPairSetGetCount(theIndexSet);
        PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexSet->indexPairs);
        for(i=0;i<count;i++) {
            if(indexPairs[i].index == indexPair.index) return false;
            if(indexPairs[i].index>indexPair.index) break;
        }
        PSIndexPair *newIndexPairs = malloc((count+1)*sizeof(PSIndexPair));
        for(int32_t j = 0;j<count+1; j++) {
            if(j<i) newIndexPairs[j] = indexPairs[j];
            else if(j==i) newIndexPairs[j] = indexPair;
            else newIndexPairs[j] = indexPairs[j-1];
        }
        CFRelease(theIndexSet->indexPairs);
        theIndexSet->indexPairs = CFDataCreate(CFGetAllocator(theIndexSet), (const UInt8 *) newIndexPairs,(count+1)*sizeof(PSIndexPair));
        free(newIndexPairs);
        return true;
    }
    theIndexSet->indexPairs = CFDataCreate(CFGetAllocator(theIndexSet), (const UInt8 *) &indexPair, sizeof(PSIndexPair));
    return true;
}

bool PSIndexPairSetEqual(PSIndexPairSetRef input1, PSIndexPairSetRef input2)
{
	IF_NO_OBJECT_EXISTS_RETURN(input1,false);
	IF_NO_OBJECT_EXISTS_RETURN(input2,false);
    
    if(CFDataGetLength(input1->indexPairs) != CFDataGetLength(input2->indexPairs)) return false;
    if(!CFEqual(input1->indexPairs, input2->indexPairs)) return false;
	return true;
}

CFDictionaryRef PSIndexPairSetCreatePList(PSIndexPairSetRef theIndexSet)
{
    CFMutableDictionaryRef dictionary = nil;
    if(theIndexSet) {
        dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue( dictionary, CFSTR("indexPairs"), theIndexSet->indexPairs);
        
	}
	return dictionary;
}

PSIndexPairSetRef PSIndexPairSetCreateWithPList(CFDictionaryRef dictionary)
{
	if(dictionary==NULL) return NULL;
	return PSIndexPairSetCreateWithParameters(CFDictionaryGetValue(dictionary, CFSTR("indexPairs")));
}


CFDataRef PSIndexPairSetCreateData(PSIndexPairSetRef theIndexSet)
{
    if(theIndexSet == NULL) return NULL;
    return CFRetain(theIndexSet->indexPairs);
}

PSIndexPairSetRef PSIndexPairSetCreateWithData(CFDataRef data)
{
    if(data==nil) return nil;
    return PSIndexPairSetCreateWithParameters(data);
}

void PSIndexPairSetShow(PSIndexPairSetRef theIndexPairSet)
{
    PSIndexPair *indexPairs = (PSIndexPair *) CFDataGetBytePtr(theIndexPairSet->indexPairs);
    CFIndex count = PSIndexPairSetGetCount(theIndexPairSet);
    fprintf(stderr,"(");
    for(CFIndex index=0; index<count; index++) {
        fprintf(stderr, "(%ld,%ld)",indexPairs[index].index, indexPairs[index].value);
        if(index!=count-1)     fprintf(stderr,",");
    }
    fprintf(stderr,")\n");
}

@end

