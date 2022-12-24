//
//  PSDatasetImportVarian.c
//  PSDataset
//
//  Created by PhySy on 10/23/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

/* Used at start of each data file (FIDs, spectra, 2D) */
typedef struct VarianFileHeader
{
    int32_t nblocks;	/* number of blocks in file			*/
    int32_t ntraces;	/* number of traces per block		*/
    int32_t np;			/* number of elements per traces	*/
    int32_t ebytes;		/* number of bytes per element		*/
    int32_t tbytes;		/* number of bytes per trace		*/
    int32_t bbytes;		/* number of bytes per block		*/
    int16_t vers_id;	/* software version, file_id status bits */
    int16_t status;		/* status of whole file				*/
    int32_t nblockheaders;	/* number of block headers per block*/
} VarianFileHeader;

typedef struct VarianDatablockheader
/* Each file block contains the following header  */
{
    int16_t scale;		/* scaling factor					*/
    int16_t status;		/* status of data in block			*/
    int16_t index;		/* block index						*/
    int16_t mode;		/* mode of data in block			*/
    int32_t ctcount;	/* completed transients in FIDs		*/
    float lpval;		/* left phase in phase file			*/
    float rpval;		/* right phase in phase file		*/
    float lvl;          /* level drift correction			*/
    float tlt;          /* tilt drift correction			*/
} VarianDatablockheader;


typedef struct VarianHypercomplexHeader
{
    int16_t s_spare1;		/* short word: spare */
    int16_t status;         /* status word for block header */
    int16_t s_spare2;		/* short word: spare */
    int16_t s_spare3;		/* short word: spare */
    int32_t l_spare1;		/* long word: spare */
    float lpval1;           /* 2D-f2 left phase */
    float rpval1;           /* 2D-f2 right phase */
    float f_spare1;         /* float word: spare */
    float f_spare2;         /* float word: spare */
} VarianHypercomplexHeader;

//bool PSDatasetImportVarianIsValidURL(CFURLRef folderURL)
//{
//    CFDictionaryRef properties;
//    SInt32 errorCode;
//    bool result = CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,folderURL,NULL,&properties,NULL,&errorCode);
//    bool fid = false;
//    bool log = false;
//    bool procpar = false;
//    bool text = false;
//    if(result && properties) {
//        CFArrayRef urls = CFDictionaryGetValue(properties, kCFURLFileDirectoryContents);
//        for(CFIndex index=0; index<CFArrayGetCount(urls); index++) {
//            CFStringRef fileName = CFURLCopyLastPathComponent(CFArrayGetValueAtIndex(urls, index));
//            if(CFStringCompare(fileName, CFSTR("fid"), 0)==kCFCompareEqualTo) fid = true;
//            if(CFStringCompare(fileName, CFSTR("log"), 0)==kCFCompareEqualTo) log = true;
//            if(CFStringCompare(fileName, CFSTR("procpar"), 0)==kCFCompareEqualTo) procpar = true;
//            if(CFStringCompare(fileName, CFSTR("text"), 0)==kCFCompareEqualTo) text = true;
//            CFRelease(fileName);
//        }
//    }
//    if(properties) CFRelease(properties);
//    return (fid && procpar);
//}
//
//
//
//
//CFIndex PSDatasetImportVarianNumberOfDimensionsForURL(CFURLRef url)
//{
//    return 0;
//}


PSDatasetRef PSDatasetImportVarianCreateSignalWithFolderData(CFDataRef fidData,
                                                             CFDataRef logData,
                                                             CFDataRef procparData,
                                                             CFDataRef textData,
                                                             CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    bool fid = false;
    bool log = false;
    bool procpar = false;
    bool text = false;
    
    if(fidData) fid = true;
        if(logData) log = true;
    if(procparData) procpar = true;
    if(textData) text = true;
    
    if(!procpar) return NULL;
    if(!fid) return NULL;
    
    CFMutableDictionaryRef varianDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFStringRef temp = NULL;
    
    if(log) {
        temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,logData,kCFStringEncodingUTF8);
        CFMutableStringRef logString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
        CFRelease(temp);
        CFDictionaryAddValue(varianDatasetMetaData, CFSTR("log"), logString);
        CFRelease(logString);
    }
    
    CFMutableStringRef textString = NULL;
    if(text) {
        temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,textData,kCFStringEncodingUTF8);
        textString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
        CFRelease(temp);
        CFDictionaryAddValue(varianDatasetMetaData, CFSTR("text"), textString);
    }
    
    temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,procparData,kCFStringEncodingUTF8);
    CFMutableStringRef procparString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
    CFRelease(temp);
    
    CFStringFindAndReplace(procparString, CFSTR("\r"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(procparString)), 0);
    CFStringFindAndReplace(procparString, CFSTR("\n\n"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(procparString)), 0);

    CFArrayRef array = (CFArrayRef) [(NSString *) procparString componentsSeparatedByString:@"\n"];
    CFRelease(procparString);
    
    CFMutableDictionaryRef procparDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    double sw =  0.0;
    double sw1 = 0.0;
    double sfrq = 0.0;
    for(CFIndex index=0; index<CFArrayGetCount(array); index++) {
        CFStringRef line = CFArrayGetValueAtIndex(array, index);
        CFArrayRef lineArray = (CFArrayRef) [(NSString *) line componentsSeparatedByString:@" "];
        if(CFArrayGetCount(lineArray) == 11) {
            
            CFStringRef key = CFArrayGetValueAtIndex(lineArray, 0);
            
            if(CFStringGetLength(key)) {
                CFMutableDictionaryRef parameterDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                
                
                //                    int subType = CFStringGetIntValue(CFArrayGetValueAtIndex(lineArray, 1));
                int basicType = CFStringGetIntValue(CFArrayGetValueAtIndex(lineArray, 2));
                
                CFDictionaryAddValue(parameterDictionary, CFSTR("subType"), CFArrayGetValueAtIndex(lineArray, 1));
                CFDictionaryAddValue(parameterDictionary, CFSTR("basicType"), CFArrayGetValueAtIndex(lineArray, 2));
                CFDictionaryAddValue(parameterDictionary, CFSTR("maxValue"), CFArrayGetValueAtIndex(lineArray, 3));
                CFDictionaryAddValue(parameterDictionary, CFSTR("minValue"), CFArrayGetValueAtIndex(lineArray, 4));
                CFDictionaryAddValue(parameterDictionary, CFSTR("stepSize"), CFArrayGetValueAtIndex(lineArray, 5));
                CFDictionaryAddValue(parameterDictionary, CFSTR("gGroup"), CFArrayGetValueAtIndex(lineArray, 6));
                CFDictionaryAddValue(parameterDictionary, CFSTR("dGroup"), CFArrayGetValueAtIndex(lineArray, 7));
                CFDictionaryAddValue(parameterDictionary, CFSTR("protection"), CFArrayGetValueAtIndex(lineArray, 8));
                CFDictionaryAddValue(parameterDictionary, CFSTR("active"), CFArrayGetValueAtIndex(lineArray, 9));
                CFDictionaryAddValue(parameterDictionary, CFSTR("intptr"), CFArrayGetValueAtIndex(lineArray, 10));
                
                index++;
                line = CFArrayGetValueAtIndex(array, index);
                CFMutableStringRef mutLine = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, line);
                CFStringTrimWhitespace(mutLine);
                lineArray = (CFArrayRef) [(NSString *) mutLine componentsSeparatedByString:@" "];
                int numberOfValues = CFStringGetIntValue(CFArrayGetValueAtIndex(lineArray, 0));
                if(basicType==1) {
                    CFMutableArrayRef values = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, lineArray);
                    CFArrayRemoveValueAtIndex(values, 0);
                    CFDictionaryAddValue(parameterDictionary, CFSTR("values"), values);
                    CFRelease(values);
                }
                else if(basicType == 2 && numberOfValues == 1) {
                    CFMutableArrayRef values = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
                    CFStringTrim(mutLine, CFSTR("1 "));
                    CFArrayAppendValue(values, mutLine);
                    CFDictionaryAddValue(parameterDictionary, CFSTR("values"), values);
                    CFRelease(values);
                }
                else if(basicType == 2 && numberOfValues>1) {
                    CFMutableArrayRef values = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, lineArray);
                    CFArrayRemoveValueAtIndex(values, 0);
                    for(CFIndex jndex = 1;jndex<numberOfValues; jndex++) {
                        index++;
                        line = CFArrayGetValueAtIndex(array, index);
                        CFArrayAppendValue(values, line);
                    }
                    CFDictionaryAddValue(parameterDictionary, CFSTR("values"), values);
                    CFRelease(values);
                }
                
                CFRelease(mutLine);
                index++;
                line = CFArrayGetValueAtIndex(array, index);
                lineArray = (CFArrayRef) [(NSString *) line componentsSeparatedByString:@" "];
                CFDictionaryAddValue(parameterDictionary, CFSTR("lastLine"), CFArrayGetValueAtIndex(lineArray, 0));
                
                
                
                if(CFStringCompare(key, CFSTR("sfrq"), 0)==kCFCompareEqualTo) {
                    sfrq = CFStringGetDoubleValue(CFArrayGetValueAtIndex(CFDictionaryGetValue(parameterDictionary, CFSTR("values")), 0));
                }
                if(CFStringCompare(key, CFSTR("sw"), 0)==kCFCompareEqualTo) {
                    sw = CFStringGetDoubleValue(CFArrayGetValueAtIndex(CFDictionaryGetValue(parameterDictionary, CFSTR("values")), 0));
                }
                if(CFStringCompare(key, CFSTR("sw1"), 0)==kCFCompareEqualTo) {
                    sw1 = CFStringGetDoubleValue(CFArrayGetValueAtIndex(CFDictionaryGetValue(parameterDictionary, CFSTR("values")), 0));
                }
                CFDictionaryAddValue(procparDictionary, key, parameterDictionary);
                CFRelease(parameterDictionary);
            }
            
        }
        else index++;
    }
    
    CFDictionaryAddValue(varianDatasetMetaData, CFSTR("procpar"), procparDictionary);
    CFRelease(procparDictionary);
    
    const UInt8 *buffer = CFDataGetBytePtr(fidData);
    VarianFileHeader *fileHeader = malloc(sizeof(struct VarianFileHeader));
    fileHeader = memcpy(fileHeader, (buffer), sizeof(struct VarianFileHeader));
    
    fileHeader->nblocks = CFSwapInt32(*((UInt32 *) &(fileHeader->nblocks)));
    fileHeader->ntraces = CFSwapInt32(*((UInt32 *) &(fileHeader->ntraces)));
    fileHeader->np = CFSwapInt32(*((UInt32 *) &(fileHeader->np)));
    fileHeader->ebytes = CFSwapInt32(*((UInt32 *) &(fileHeader->ebytes)));
    fileHeader->tbytes = CFSwapInt32(*((UInt32 *) &(fileHeader->tbytes)));
    fileHeader->bbytes = CFSwapInt32(*((UInt32 *) &(fileHeader->bbytes)));
    fileHeader->vers_id = CFSwapInt16(*((UInt16 *) &(fileHeader->vers_id)));
    fileHeader->status = CFSwapInt16(*((UInt16 *) &(fileHeader->status)));
    fileHeader->nblockheaders = CFSwapInt32(*((UInt32 *) &(fileHeader->nblockheaders)));
    
    bool dataIsHyperComplex = fileHeader->status & 0x20;
    bool dataIs32BitFloat = fileHeader->status & 0x08;
    bool dataIsPresent = fileHeader->status & 0x01;
    bool dataIsSpectrum = fileHeader->status & 0x02;
    bool dataIsComplex = fileHeader->status & 0x10;
    bool dataIs32Bit = fileHeader->status & 0x04;
    
    bool dataAcqPar = fileHeader->status & 0x80;
    bool dataSecnd = fileHeader->status & 0x100;
    bool dataTransf = fileHeader->status & 0x200;
    bool dataNP = fileHeader->status & 0x800;
    bool dataNF = fileHeader->status & 0x1000;
    bool dataNI = fileHeader->status & 0x2000;
    bool dataNI2 = fileHeader->status & 0x4000;
    
    VarianDatablockheader *blockHeader = malloc(sizeof(struct VarianDatablockheader));
    blockHeader = memcpy(blockHeader, (buffer+sizeof(struct VarianFileHeader)), sizeof(struct VarianDatablockheader));
    blockHeader->scale = CFSwapInt16(*((UInt16 *) &(blockHeader->scale)));
    blockHeader->status = CFSwapInt16(*((UInt16 *) &(blockHeader->status)));
    blockHeader->index = CFSwapInt16(*((UInt16 *) &(blockHeader->index)));
    blockHeader->mode = CFSwapInt16(*((UInt16 *) &(blockHeader->mode)));
    blockHeader->ctcount = CFSwapInt32(*((UInt32 *) &(blockHeader->ctcount)));
    blockHeader->lpval = CFSwapInt32(*((UInt32 *) &(blockHeader->lpval)));
    blockHeader->rpval = CFSwapInt32(*((UInt32 *) &(blockHeader->rpval)));
    
    int32_t lvlTemp = CFSwapInt32(*((UInt32 *) &(blockHeader->lvl)));
    void *ptr = &lvlTemp;
    blockHeader->lvl = *((float *)ptr);
    
    int32_t tltTemp = CFSwapInt32(*((UInt32 *) &(blockHeader->tlt)));
    ptr = &tltTemp;
    blockHeader->tlt = *((float *)ptr);
    
    VarianHypercomplexHeader *hypercomplexBlockHeader = NULL;
    if(dataIsHyperComplex) {
        hypercomplexBlockHeader = malloc(sizeof(struct VarianHypercomplexHeader));
        hypercomplexBlockHeader = memcpy(hypercomplexBlockHeader, (buffer+sizeof(struct VarianFileHeader) + sizeof(struct VarianDatablockheader)), sizeof(struct VarianHypercomplexHeader));
        hypercomplexBlockHeader->s_spare1 =CFSwapInt16(*((UInt16 *) &(hypercomplexBlockHeader->s_spare1)));
        hypercomplexBlockHeader->status =CFSwapInt16(*((UInt16 *) &(hypercomplexBlockHeader->status)));
        hypercomplexBlockHeader->s_spare2 =CFSwapInt16(*((UInt16 *) &(hypercomplexBlockHeader->s_spare2)));
        hypercomplexBlockHeader->s_spare3 =CFSwapInt16(*((UInt16 *) &(hypercomplexBlockHeader->s_spare3)));
        hypercomplexBlockHeader->l_spare1 =CFSwapInt32(*((UInt32 *) &(hypercomplexBlockHeader->l_spare1)));
        
        int32_t temp32 = CFSwapInt32(*((UInt32 *) &(hypercomplexBlockHeader->lpval1)));
        void *ptr = &temp32;
        hypercomplexBlockHeader->lpval1 = *((float *)ptr);
        
        temp32 = CFSwapInt32(*((UInt32 *) &(hypercomplexBlockHeader->rpval1)));
        ptr = &temp32;
        hypercomplexBlockHeader->rpval1 = *((float *)ptr);
        
        temp32 = CFSwapInt32(*((UInt32 *) &(hypercomplexBlockHeader->f_spare1)));
        ptr = &temp32;
        hypercomplexBlockHeader->f_spare1 = *((float *)ptr);
        
        temp32 = CFSwapInt32(*((UInt32 *) &(hypercomplexBlockHeader->f_spare2)));
        ptr = &temp32;
        hypercomplexBlockHeader->f_spare2 = *((float *)ptr);
    }
    
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    PSUnitRef xUnits = PSUnitForSymbol(CFSTR("s"));
    PSUnitRef inverseXUnits = PSUnitForSymbol(CFSTR("Hz"));
    PSUnitRef megahertz = PSUnitForSymbol(CFSTR("MHz"));
    
    
    CFIndex npt0 =fileHeader->np/2;
    CFIndex npt1 =fileHeader->nblocks;
    CFIndex size = npt1* npt0;
    
    // First dimension
    PSScalarRef increment = PSScalarCreateWithDouble(1./sw, xUnits);
    PSScalarRef originOffset = PSScalarCreateWithDouble(0., xUnits);
    PSScalarRef inverseOriginOffset = PSScalarCreateWithDouble(sfrq, megahertz);
    
    PSDimensionRef dim = PSLinearDimensionCreateDefault(npt0, increment, kPSQuantityTime,kPSQuantityFrequency);
    PSDimensionSetOriginOffset(dim, originOffset);
    PSDimensionSetInverseMadeDimensionless(dim, true);
    
    if(NULL==dim) {
        if(hypercomplexBlockHeader) free(hypercomplexBlockHeader);
        if(blockHeader) free(blockHeader);
        if(fileHeader) free(fileHeader);
        if(textString) CFRelease(textString);
        return NULL;
    }
    
    CFRelease(increment);
    CFRelease(originOffset);
    CFRelease(inverseOriginOffset);
    PSDimensionMakeNiceUnits(dim);
    CFArrayAppendValue(dimensions, dim);
    CFRelease(dim);
    
    
    if(fileHeader->nblocks>1) {
        // Second Dimension
        PSScalarRef increment = PSScalarCreateWithDouble(1./sw1, xUnits);
        PSScalarRef originOffset = PSScalarCreateWithDouble(0., xUnits);
        PSScalarRef inverseOriginOffset = PSScalarCreateWithDouble(0.0, inverseXUnits);
        
        PSDimensionRef dim = PSLinearDimensionCreateDefault(npt1, increment, kPSQuantityTime,kPSQuantityFrequency);
        PSDimensionSetInverseQuantityName(dim, kPSQuantityFrequency);
        PSDimensionSetOriginOffset(dim, originOffset);
        PSDimensionSetInverseOriginOffset(dim, inverseOriginOffset);
        PSDimensionSetInverseMadeDimensionless(dim, true);
        
        if(NULL==dim) {
            if(hypercomplexBlockHeader) free(hypercomplexBlockHeader);
            if(blockHeader) free(blockHeader);
            if(fileHeader) free(fileHeader);
            if(textString) CFRelease(textString);
            return NULL;
        }
        CFRelease(increment);
        CFRelease(originOffset);
        CFRelease(inverseOriginOffset);
        PSDimensionMakeNiceUnits(dim);
        CFArrayAppendValue(dimensions, dim);
        CFRelease(dim);
    }
    
    float complex data[size];
    
    CFIndex memOffset = sizeof(struct VarianFileHeader);
    
    for(CFIndex index1=0;index1<npt1;index1++) {
        memOffset += sizeof(struct VarianDatablockheader);
        for(CFIndex index0 = 0; index0<npt0; index0++) {
            UInt32 datum = CFSwapInt32(*((UInt32 *) &(buffer[memOffset])));
            void *ptr = &datum;
            float realPart;
            if(dataIs32BitFloat) realPart = *((float *)ptr);
            else realPart =  (float) *((int32_t *)ptr);
            
            memOffset  += fileHeader->ebytes;
            
            datum = CFSwapInt32(*((UInt32 *) &(buffer[memOffset])));
            ptr = &datum;
            float imagPart;
            if(dataIs32BitFloat) imagPart = *((float *)ptr);
            else imagPart =  (float) *((int32_t *)ptr);
            
            memOffset  += fileHeader->ebytes;
            
            data[index0 + index1*npt0] = realPart + I*imagPart;
        }
    }
    
    PSDatasetRef dataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(dataset, dimensions, NULL);
    CFRelease(dimensions);

    PSDependentVariableRef dependentVariable = PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
    CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) data, sizeof(float complex)*size);
    PSDependentVariableSetComponentAtIndex(dependentVariable, values, 0);
    PSDependentVariableSetQuantityName(dependentVariable, kPSQuantityDimensionless);
    CFRelease(values);
    
    PSDatasetSetMetaData(dataset, varianDatasetMetaData);
    CFRelease(varianDatasetMetaData);

    PSDatasetSetDescription(dataset, textString);
    
    if(textString) CFRelease(textString);
    if(fileHeader) free(fileHeader);
    if(blockHeader) free(blockHeader);
    if(hypercomplexBlockHeader) free(hypercomplexBlockHeader);

    return dataset;
}

