//
//  PSDatasetImportUCSF.c
//  RMN
//
//  Created by philip on 1/14/16.
//  Copyright © 2016 PhySy. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

/*
 * parameters for polynomial fitting of transformed baseline.
 */
typedef struct {
    unsigned	solvent_start;
    short		poly_order;
    short		solvent_width;
} NMR_BASE_FIT;

/*
 * region for calculating offest of transformed baseline.
 */
typedef struct {
    unsigned	start, end;
} NMR_BASE_OFFSET;

typedef struct {
    unsigned	start;		/* 1st pt. in coeffs. calculation */
    unsigned short	poly_order;	/* polynomial order */
    unsigned short	npredicted;	/* # of additional points */
    unsigned short	npoints;	/* # of point in coeffs region */
} LP_EXTEND;

typedef struct {
    unsigned	before_start;	/* 1st pt. in downfield coeffs. calc. */
    unsigned	after_start;	/* 1st pt. in upfield coeffs calc. */
    unsigned	first;		/* first pt to be replaced */
    unsigned short	npredicted;	/* length of region replacement. */
    unsigned short	poly_order;	/* polynomial order */
    unsigned short	before_npoints;	/* # of point in coeffs region */
    unsigned short	after_npoints;	/* # of point in coeffs region */
} LP_REPLACE;


/*
 * parameters for apodization.
 */
typedef struct {
    union {
        float	shift;
        float	line_broad;
    }	p1;
    union {
        float	gaussian;
    }	p2;
} NMR_APO_PARAMS;


/*
 * data structure for solvent removal via convolution of fid.
 */
typedef struct {
    short		width;		/* half width of window */
    short		extrapolation;	/* npoints at ends to extrapolate */
} NMR_CONVOLUTION;


/*
 * Processing flags / small bitfields
 */
typedef struct {
    unsigned	fid_convolution : 2;
    unsigned	dc_offset	: 1;
    unsigned	forward_extend	: 1;
    unsigned	backwards_extend: 1;
    unsigned	replace		: 2;
    unsigned	apodization	: 4;
    unsigned	ft_code		: 2;
    unsigned	nfills		: 4;
    unsigned	absolute_value	: 1;
    unsigned	spectrum_reverse: 1;
    unsigned	baseline_offset	: 1;
    unsigned	baseline_fit	: 2;
    unsigned	reserved	: 10;
} NMR_FLAG;

typedef struct {
    unsigned	transformed	: 1;
    unsigned	base_corrected	: 1;
    unsigned	reserved	: 14;
} NMR_PROCESSED;

/*
 * Data structures for version 2 files.
 */
typedef struct {
    char		nucleus[6];
    short		spectral_shift;		/* to left or right shift */
    unsigned	npoints;		/* # of active data points */
    unsigned	size;			/* total size of axis */
    unsigned	bsize;			// # of points per cache block
    float		spectrometer_freq;	// MHz
    float		spectral_width;		// Hz
    float		xmtr_freq;		/* transmitter offset (ppm) */
    float		zero_order;		/* phase corrections */
    float		first_order;
    float		first_pt_scale;		/* scaling for first point */
    NMR_PROCESSED	status;			/* completion flags */
    NMR_FLAG	flags;			/* processing options */
    NMR_CONVOLUTION	conv;			/* FID convolution parameters */
    NMR_APO_PARAMS	apo;			/* apodization parameters */
    LP_EXTEND	forward;		/* FID extension */
    LP_EXTEND	backwards;		/* FID beginning correction */
    LP_REPLACE	replace;		/* FID replacement */
    NMR_BASE_OFFSET	base_offset;		/* baseline offset correction */
    NMR_BASE_FIT	base_fit;
    void		*unused;
} NMR_AXIS;

typedef struct {
    char		ident[10];
    char		naxis;
    char		ncomponents;
    char		encoding;
    char		version;
    char		owner[9];
    char		date[26];
    char		comment[80];
    long		seek_pos;
    char		scratch[40];
    NMR_AXIS	*axis;
} NMR_HEADER;


static CFIndex findTag(const UInt8 *buffer, CFIndex length, char *tag)
{
    for(CFIndex index = 0; index<length;index++) {
        unsigned long tagLength = strlen(tag);
        char *section_tag = malloc(tagLength+1);
        memcpy(section_tag, &buffer[index],tagLength);
        if(strcmp(tag, section_tag) == 0) {
            free(section_tag);
            return index;
        }
        free(section_tag);
    }
    return kCFNotFound;
}


CFIndex sparkyFileOffsetForMemOffset(CFIndex memOffset,
                                     const CFIndex numberOfDimensions,
                                     const CFIndex *npts,
                                     const bool *fft,
                                     const CFIndex *tileSizes)
{
    CFIndex totalTilesX = ceilf(npts[1]/((float) tileSizes[1]));
    CFIndex totalTilesY = ceilf(npts[0]/((float) tileSizes[0]));
    CFIndex spectrumSizeInTiles = totalTilesX*totalTilesY;
    CFIndex tileSize = tileSizes[0]*tileSizes[1];
    
    CFIndex indexes[numberOfDimensions];
    setIndexesForMemOffset(memOffset, indexes, numberOfDimensions, npts);
    CFIndex sparkyFileOffset=memOffset;
    if(numberOfDimensions==2) {
        // Find tile coordinates
        CFIndex tileCoordX = indexes[1]/tileSizes[1];
        CFIndex tileCoordY = indexes[0]/tileSizes[0];

        // Find coordinates inside tile
        CFIndex insideTileCoordinatesX = indexes[1]%tileSizes[1];
        CFIndex insideTileCoordinatesY = indexes[0]%tileSizes[0];
        
        sparkyFileOffset = tileCoordX*tileSize + tileCoordY*tileSize*totalTilesX;
        sparkyFileOffset += insideTileCoordinatesX + insideTileCoordinatesY*tileSizes[1];
        return sparkyFileOffset;
    }
    return sparkyFileOffset;
}

PSDatasetRef PSDatasetImportUCSFCreateSignalWithData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    const UInt8 *buffer = CFDataGetBytePtr(contents);
    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL, error);
    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL, error);
    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL, error);
    CFIndex totalFileLengthInBytes = CFDataGetLength(contents);
    
    NMR_HEADER hdr;
    
    // Create NMR meta-data
    CFMutableDictionaryRef sparkyDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFIndex count = 0;
    memcpy(&hdr, &buffer[count],sizeof(NMR_HEADER) - sizeof(NMR_AXIS *));
    
    count += sizeof(NMR_HEADER) - sizeof(NMR_AXIS *) - 4;
    hdr.axis = malloc(hdr.naxis*sizeof(NMR_AXIS));
    
    CFIndex dataLength = 1;
    CFIndex *npts = calloc(sizeof(CFIndex), hdr.naxis);
    bool fft[hdr.naxis];
    CFIndex *tileSizes = calloc(sizeof(CFIndex), hdr.naxis);

    for(CFIndex iAxis=0; iAxis<hdr.naxis; iAxis++) {
        NMR_AXIS axis;
        memcpy(&axis, &buffer[count],sizeof(NMR_AXIS));
        {
            UInt16 datum16;
            datum16 = CFSwapInt32(*((UInt16 *) &(axis.spectral_shift)));
            void *ptr = &datum16;
            axis.spectral_shift = *((int16_t *)ptr);
        }
        
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.size)));
            void *ptr = &datum;
            axis.size = *((int32_t *)ptr);
        }
        
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.bsize)));
            void *ptr = &datum;
            axis.bsize = *((int32_t *)ptr);
        }
        
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.npoints)));
            void *ptr = &datum;
            axis.npoints = *((int32_t *)ptr);
        }
        
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.spectrometer_freq)));
            void *ptr = &datum;
            axis.spectrometer_freq = *((float *)ptr);
        }
        
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.spectral_width)));
            void *ptr = &datum;
            axis.spectral_width = *((float *)ptr);
        }
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.xmtr_freq)));
            void *ptr = &datum;
            axis.xmtr_freq = *((float *)ptr);
        }
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.zero_order)));
            void *ptr = &datum;
            axis.zero_order = *((float *)ptr);
        }
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.first_order)));
            void *ptr = &datum;
            axis.first_order = *((float *)ptr);
        }
        {
            UInt32 datum;
            datum = CFSwapInt32(*((UInt32 *) &(axis.first_pt_scale)));
            void *ptr = &datum;
            axis.first_pt_scale = *((float *)ptr);
        }
        
        hdr.axis[iAxis] = axis;
        npts[iAxis] = axis.npoints;
        fft[iAxis] = false;
        tileSizes[iAxis] = axis.bsize;
        dataLength *= axis.npoints;
        count += 128;
    }
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    for(CFIndex iDim = 0; iDim<hdr.naxis; iDim++) {
        double observe_frequency =hdr.axis[iDim].spectrometer_freq;
        observe_frequency *= 1e7;
        observe_frequency = floor(observe_frequency);
        observe_frequency /= 1e7;
        
        CFStringRef quantityName, inverseQuantityName;
        PSScalarRef increment, originOffset, inverseOriginOffset;

        quantityName = CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityFrequency);
        inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
        PSScalarRef dwell = PSScalarCreateWithDouble(1./hdr.axis[iDim].spectral_width, seconds);
        PSScalarRef temp = PSScalarCreateByRaisingToAPower(dwell, -1, error);
        increment = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 1./(double) hdr.axis[iDim].size);
        CFRelease(temp);
        CFRelease(dwell);
        originOffset = PSScalarCreateWithDouble(observe_frequency, megahertz);
        inverseOriginOffset = PSScalarCreateWithDouble(0.0, seconds);

        PSDimensionRef theDimension = PSLinearDimensionCreateDefault(hdr.axis[iDim].size, increment, quantityName,inverseQuantityName);
        PSDimensionSetInverseOriginOffset(theDimension, inverseOriginOffset);
        PSDimensionSetOriginOffset(theDimension, originOffset);
        PSDimensionSetInverseQuantityName(theDimension, inverseQuantityName);
        
        // Put the rest into NMR meta-data
        
        PSScalarRef sfrequency = PSScalarCreateWithDouble(hdr.axis[iDim].spectrometer_freq, megahertz);
        PSScalarRef referenceFrequency = PSScalarCreateWithDouble(0.0, hertz);
        PSScalarRef referencePosition = PSScalarCreateWithDouble(0.0, hertz);
        
        CFMutableDictionaryRef sparkyDimensionMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFStringRef tempString = PSScalarCreateStringValue(sfrequency);
        CFDictionaryAddValue(sparkyDimensionMetaData, CFSTR("spectrometer frequency"), tempString);
        CFRelease(tempString);
        
        tempString = PSScalarCreateStringValue(referenceFrequency);
        CFDictionaryAddValue(sparkyDimensionMetaData, CFSTR("reference frequency"), tempString);
        CFRelease(tempString);
        
        tempString = PSScalarCreateStringValue(referencePosition);
        CFDictionaryAddValue(sparkyDimensionMetaData, CFSTR("reference position"), tempString);
        CFRelease(tempString);
        
        CFMutableDictionaryRef nmrDimensionMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFDictionaryAddValue(nmrDimensionMetaData, CFSTR("Sparky"), sparkyDimensionMetaData);
        CFRelease(sparkyDimensionMetaData);
        
        tempString = PSScalarCreateStringValue(sfrequency);
        CFDictionaryAddValue(nmrDimensionMetaData, CFSTR("receiver frequency"), tempString);
        CFRelease(tempString);
        
        CFMutableDictionaryRef dimensionMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(dimensionMetaData, CFSTR("NMR"), nmrDimensionMetaData);
        CFRelease(nmrDimensionMetaData);
        
        PSDimensionSetMetaData(theDimension, dimensionMetaData);
        PSDimensionSetMadeDimensionless(theDimension, true);
        
        CFRelease(quantityName);
        CFRelease(inverseQuantityName);
        CFRelease(increment);
        CFRelease(originOffset);
        CFRelease(inverseOriginOffset);
        CFRelease(dimensionMetaData);
        
        PSDimensionMakeNiceUnits(theDimension);
        CFArrayAppendValue(dimensions, theDimension);
        CFRelease(theDimension);
    }
    
    CFMutableDataRef values = CFDataCreateMutable(kCFAllocatorDefault, dataLength*sizeof(float));
    CFDataSetLength(values, dataLength*sizeof(float));
    
    float *response = (float *) CFDataGetMutableBytePtr(values);
    count = 180+hdr.naxis*128;
    UInt8 *bytes = (UInt8 *) (buffer + count);

//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_apply(dataLength, queue,
//                   ^(size_t memOffset) {
//                       CFIndex sparkyOffset = sparkyFileOffsetForMemOffset(memOffset, hdr.naxis, npts, tileSizes);
//                       CFIndex byteOffset = sparkyOffset * sizeof(UInt32);
//                       UInt32 datum = CFSwapInt32(*((UInt32 *) &(bytes[byteOffset])));
//                       void *ptr = &datum;
//                       int32_t real = *((float *)ptr);
//                       response[memOffset] = real;
//                   }
//                   );
    
    for(CFIndex memOffset=0;memOffset<dataLength;memOffset++) {
        CFIndex sparkyOffset = sparkyFileOffsetForMemOffset(memOffset, hdr.naxis, npts, fft, tileSizes);
        CFIndex byteOffset = sparkyOffset * sizeof(UInt32);
        UInt32 datum = CFSwapInt32(*((UInt32 *) &(bytes[byteOffset])));
        void *ptr = &datum;
        int32_t real = *((float *)ptr);
        
//        CFStringRef string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%d"),real);
//        CFRange range = CFStringFind(string, CFSTR("-122"), 0);
//        if(range.location != kCFNotFound && range.location==0) {
//            UInt32 datum = CFSwapInt32(*((UInt32 *) &(bytes[byteOffset+4])));
//            void *ptr = &datum;
//            int32_t real = *((float *)ptr);
//            CFStringRef string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%d"),real);
//            CFRange range = CFStringFind(string, CFSTR("-140"), 0);
//            if(range.location != kCFNotFound && range.location==0) {
//                printf("memoffset=%ld with %d\n",memOffset,real);
//            }
//        }
        response[memOffset] = real;
    }
    
    free(hdr.axis);
    free(npts);
    free(tileSizes);
    
    CFMutableDictionaryRef nmrDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(nmrDatasetMetaData, CFSTR("Sparky"), sparkyDatasetMetaData);
    CFRelease(sparkyDatasetMetaData);
    
    CFMutableDictionaryRef datasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(datasetMetaData, CFSTR("NMR"), nmrDatasetMetaData);
    CFRelease(nmrDatasetMetaData);
    
    PSDatasetRef theDataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(theDataset, dimensions, NULL);
    PSDatasetSetMetaData(theDataset, datasetMetaData);
    PSDependentVariableRef theDependentVariable = PSDatasetAddDefaultDependentVariable(theDataset, CFSTR("scalar"), kPSNumberFloat32Type, kPSDatasetSizeFromDimensions);
    PSDependentVariableSetComponentAtIndex(theDependentVariable, values, 0);
    CFRelease(values);

    CFRelease(datasetMetaData);
    CFRelease(dimensions);
    
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    PSPlotReset(thePlot);
    PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);

    return theDataset;
    
}
