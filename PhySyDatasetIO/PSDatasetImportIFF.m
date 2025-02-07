//
//  PSDatasetImportIFF.c
//  RMN
//
//  Created by philip on 5/18/14.
//  Copyright (c) 2014 PhySy. All rights reserved.
//

#import <CoreAudio/CoreAudioTypes.h>
#import <LibPhySyObjC/PhySyDatasetIO.h>

typedef struct _Chunk
{
	char  chunkID[4];
	uint32_t size;
	char  data[];
} Chunk;

typedef struct _IFFHeader
{
	char  chunkID[4];
	uint32_t size;
	char typeID[4];
	char  data[];
} IFFHeader;

typedef struct _WAVEFormatChunk {
	char chunkID[4];  // String: must be "fmt "
	uint32_t size;
	uint16_t compressionCode;
	uint16_t numberOfChannels;
	uint32_t sampleRate;
	uint32_t averageBytesPerSecond;
	uint16_t blockAlign;
	uint16_t significantBitsPerSample;
} WAVEFormatChunk;

typedef struct _WAVE {
	char chunkID[4];  // Must be "RIFF"
	uint32_t size;
	char typeID[4]; // Must be "WAVE"
    WAVEFormatChunk format;
    Chunk snd;
} Wave;



bool PSDatasetImportIFFIsValidURL(CFURLRef url)
{
    bool result = false;
    CFStringRef extension = CFURLCopyPathExtension(url);
    if(extension) {
        if(CFStringCompare(extension, CFSTR("iff"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) result = true;
        CFRelease(extension);
    }
    return result;
}

#define WAVE_FORMAT_PCM 1;
#define WAVE_FORMAT_IEEE_FLOAT 3;

CFDataRef PSDatasetCreateWaveDataWithDataset(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDimensionRef horizontalDimenion = PSDatasetHorizontalDimension(theDataset);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);

    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    PSAxisRef horizontalAxis = PSPlotAxisAtIndex(thePlot, horizontalDimensionIndex);
    PSScalarRef minimum = PSAxisGetMinimum(horizontalAxis);
    PSScalarRef maximum = PSAxisGetMaximum(horizontalAxis);
    CFIndex low = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimenion, minimum);
    CFIndex high = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimenion, maximum);

    CFIndex dimIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    uint32_t npts = (uint32_t) PSDimensionGetNpts(horizontalDimenion);
    
    PSScalarRef increment = PSDimensionGetIncrement(horizontalDimenion);
    uint32_t sampleRate = (uint32_t) fabs(1./PSScalarDoubleValueInCoherentUnit(increment));
    uint16_t numberOfChannels = (uint16_t) PSDatasetDependentVariablesCount(theDataset);
    uint32_t bitsPerSample = 16;

    uint32_t size = npts*numberOfChannels*(bitsPerSample/8) + 48;

    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, size);
    CFDataSetLength(data, size);
    Wave *wave  = (Wave *) CFDataGetBytePtr(data);

    wave->chunkID[0] = 'R';
    wave->chunkID[1] = 'I';
    wave->chunkID[2] = 'F';
    wave->chunkID[3] = 'F';
    
    wave->size = size + 44;

    wave->typeID[0] = 'W';
    wave->typeID[1] = 'A';
    wave->typeID[2] = 'V';
    wave->typeID[3] = 'E';

    wave->format.chunkID[0] = 'f';
    wave->format.chunkID[1] = 'm';
    wave->format.chunkID[2] = 't';
    wave->format.chunkID[3] = ' ';
    wave->format.size = 16;
    wave->format.compressionCode = WAVE_FORMAT_PCM;
    wave->format.numberOfChannels = numberOfChannels;
    wave->format.sampleRate = sampleRate;
    wave->format.averageBytesPerSecond = sampleRate * numberOfChannels * bitsPerSample/8;
    wave->format.blockAlign = numberOfChannels * bitsPerSample/8;
    wave->format.significantBitsPerSample = bitsPerSample;

    wave->snd.chunkID[0] = 'd';
    wave->snd.chunkID[1] = 'a';
    wave->snd.chunkID[2] = 't';
    wave->snd.chunkID[3] = 'a';
    
    wave->snd.size = npts*numberOfChannels*(bitsPerSample/8);
    PSMutableIndexArrayRef indexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    CFIndex *indexes = PSIndexArrayGetMutableBytePtr(indexValues);

    int16_t *buffer = (int16_t *) wave->snd.data;
    
    CFIndex memOffsetMax;
    CFIndex componentIndexMax;
    
    double max = fabs(PSDependentVariableFindMaximumForPart(theDependentVariable, kPSRealPart, &memOffsetMax, &componentIndexMax, error));
    double min = fabs(PSDependentVariableFindMinimumForPart(theDependentVariable, kPSRealPart, &memOffsetMax, &componentIndexMax, error));

    if(max<min) max = min;
    
    for(CFIndex iChannel=0;iChannel<numberOfChannels; iChannel++) {
        for(CFIndex index=low;index<high;index++) {
            indexes[dimIndex] = index;
            CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
            double response = PSDependentVariableDoubleValueAtMemOffsetForPart(theDependentVariable,
                                                                               iChannel,
                                                                               memOffset,
                                                                               kPSRealPart)/max;
            
            buffer[memOffset*numberOfChannels+iChannel] = (int16_t) (response*16384);
        }
    }
    CFRelease(indexValues);
    return data;
}

PSDatasetRef PSDatasetImportIFFCreateSignalWithData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IFFHeader *iffHeader = (IFFHeader *) CFDataGetBytePtr((CFDataRef) contents);
    
    if (strncmp(iffHeader->chunkID, "RIFF", 4) == 0) {
        if (strncmp(iffHeader->typeID, "WAVE", 4) == 0) {
            WAVEFormatChunk *waveFormatChunk = NULL;
            Chunk *dataChunk = NULL;
            CFIndex index = 0;
            while(index<iffHeader->size-4) {
                Chunk *chunk = (Chunk *)&iffHeader->data[index];
                if (strncmp(chunk->chunkID, "fmt ", 4) == 0) waveFormatChunk = (WAVEFormatChunk *) chunk;
                if (strncmp(chunk->chunkID, "data", 4) == 0) dataChunk = (Chunk *) chunk;
                index += chunk->size+8;
            }
            if(NULL==dataChunk) return NULL;
            if(NULL==waveFormatChunk) return NULL;
            if(waveFormatChunk->compressionCode != 1) return NULL;
            CFIndex bitsPerSample = 8*waveFormatChunk->averageBytesPerSecond/waveFormatChunk->numberOfChannels/waveFormatChunk->sampleRate;

            
            CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            PSUnitRef hertz = PSUnitForParsedSymbol(CFSTR("Hz"), NULL, error);
            PSUnitRef seconds = PSUnitForParsedSymbol(CFSTR("s"), NULL, error);
            
            CFStringRef quantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            CFStringRef inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
            PSScalarRef increment = PSScalarCreateWithDouble(1./waveFormatChunk->sampleRate, seconds);
            PSScalarRef originOffset = PSScalarCreateWithDouble(0.0, seconds);
            PSScalarRef inverseOriginOffset = PSScalarCreateWithDouble(0.0, hertz);
            
            CFIndex npts = dataChunk->size/waveFormatChunk->numberOfChannels/(bitsPerSample/8);
            
            PSDimensionRef dim = PSLinearDimensionCreateDefault(npts, increment, quantityName,inverseQuantityName);
            PSDimensionSetInverseQuantityName(dim, inverseQuantityName);
            PSDimensionSetOriginOffset(dim, originOffset);
            PSDimensionSetInverseOriginOffset(dim, inverseOriginOffset);
            
            CFRelease(quantityName);
            CFRelease(inverseQuantityName);
            CFRelease(increment);
            CFRelease(originOffset);
            CFRelease(inverseOriginOffset);
            
            PSDimensionMakeNiceUnits(dim);
            CFArrayAppendValue(dimensions, dim);
            CFRelease(dim);
            
            CFMutableArrayRef components = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFMutableArrayRef labels = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            
            for(CFIndex iChannel=0;iChannel<waveFormatChunk->numberOfChannels; iChannel++) {
                CFMutableDataRef channelValues = CFDataCreateMutable(kCFAllocatorDefault, npts*sizeof(float));
                CFDataSetLength(channelValues, npts*sizeof(float));
                
                float *channelResponses = (float *) CFDataGetMutableBytePtr(channelValues);
                if(bitsPerSample == 8) {
                    uint8_t *theData = (uint8_t *) dataChunk->data;
                    for(CFIndex index = 0; index<npts; index++) {
                        channelResponses[index] = (float) ((uint8_t) theData[index]) - 128.;
                    }
                }
                else if(bitsPerSample == 16) {
                    int16_t *theData = (int16_t *) dataChunk->data;
                    for(CFIndex index = 0; index<npts; index++) {
                        channelResponses[index] = (float) ((int16_t) theData[index*waveFormatChunk->numberOfChannels+iChannel]);
                    }
                }
            

                
                CFStringRef label = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("channel %ld"),iChannel);
                
                CFArrayAppendValue(labels, label);
                CFRelease(label);
                CFArrayAppendValue(components, channelValues);
                CFRelease(channelValues);
            }
            CFStringRef quantityType = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("vector_%d"),waveFormatChunk->numberOfChannels);

            PSDependentVariableRef signal =  PSDependentVariableCreate(NULL,
                                                                       NULL,
                                                                       NULL,
                                                                       NULL,
                                                                       quantityType,
                                                                       kPSNumberFloat32Type,
                                                                       labels,
                                                                       components,
                                                                       NULL,
                                                                       NULL);
            CFRelease(labels);
            CFRelease(components);
            CFRelease(quantityType);

            PSDatasetRef dataset = PSDatasetCreateWithDependentVariable(dimensions,
                                                                        NULL,
                                                                        signal,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL);

            
            CFRelease(dimensions);
            CFRelease(signal);
            
            PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(dataset, 0);
            PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
            PSPlotReset(thePlot);
            PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);
            PSPlotSetDefaultColorForComponents(thePlot);

            PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
            PSAxisSetBipolar(responseAxis, false);
            PSAxisReset(responseAxis, NULL);
            
            return dataset;
        }
        
    }
    

    return NULL;
}


