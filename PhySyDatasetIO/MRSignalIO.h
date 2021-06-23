//
//  MRSignalIO.h
//  RMN 2.0
//
//  Created by Philip on 7/4/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <LibPhySyObjC/PhySyDatasetOperations.h>

/* Define MRSignal part values */
#define REALPART        0
#define IMAGPART        1
#define MAGNITUDEPART   2
#define ARGUMENTPART    3

#define TIME		2
#define FREQ		3

/* Define coordinate units */
#define SECONDS			0
#define MILLISECONDS	1
#define MICROSECONDS	2
#define HZ				4
#define KHZ				5
#define MHZ				6
#define PPM				7


//bool PSDatasetImportMRSignalIsValidURL(CFURLRef url);
//CFIndex PSDatasetImportMRSignalNumberOfDimensionsForURL(CFURLRef url);
PSDatasetRef PSDatasetImportMRSignalCreateSignalWithData(CFDataRef contents, CFStringRef fileName, CFErrorRef *error);
//PSDatasetRef PSDatasetImportMRSignalCreateSignalAtURL(CFURLRef url, CFErrorRef *error);

@class MRDimension;
@class MRPlot;
@class MRDatum;
@interface MRSignal : NSObject <NSCoding,NSCopying> {
	NSMutableData       *bytes;
    int32_t             size;
    
    NSMutableArray      *dimensions;
    
    MRDatum             *focus;
    MRDatum             *previousFocus;
    
    NSString            *responseQuantityNameString;
    NSString            *responseUnitSymbolString;
    NSString            *title;
    NSAttributedString  *comments;
    MRPlot              *plot;
    
    NSMutableArray      *operations;
}

@property int32_t size;
@property(retain) NSMutableData *bytes;
@property(retain) NSMutableArray *dimensions;
@property(copy) MRDatum *focus;
@property(copy) MRDatum *previousFocus;
@property(copy) NSString *responseQuantityNameString;
@property(copy) NSString *responseUnitSymbolString;
@property(copy) NSAttributedString *comments;
@property(copy) NSString *title;
@property(retain) NSMutableArray *operations;
@property(copy) MRPlot *plot;
@property int8_t numberOfDimensions;

@end

@interface MRDatum : NSObject <NSCoding,NSCopying> {
    int8_t numberOfDimensions;
	double complex response;
    NSData *coordinateValues;
}
@property int8_t numberOfDimensions;
@property double complex response;
@property(copy) NSData *coordinateValues;
@property(readonly) double *coordinates;

@end

@interface MRDimension : NSObject  <NSCoding,NSCopying> {
    int32_t npts;
	double  dw;
    double  timeOriginOffset;
    
	double  sfreq;
    double  frequencyOriginOffset;
    double  referenceFrequency;
    double  referencePosition;
    
	int     quantity;
    Byte    unit;
	bool    reverse;
    bool    fftShift;
    bool    periodic;
    PSDimensionalityRef dimensionality;
}
@property int32_t npts;
@property double dw;
@property double timeOriginOffset;
@property Byte unit;
@property int quantity;
@property bool reverse;
@property bool fftShift;
@property bool periodic;

@property double sfreq;
@property double frequencyOriginOffset;
@property double referenceFrequency;
@property double referencePosition;
@property (assign) PSDimensionalityRef dimensionality;

@end

@interface MRAxis : NSObject <NSCoding,NSCopying> {
    MRPlot  *plot;
    
    int8_t  index;
    
    double  min;
    double  max;
    double  majorTicInc;
	int16_t noMinorTics;
    bool    bipolar;
    
    NSString *quantityString;
    NSString *unitSymbolString;
}
@property int8_t  index;
@property double  min;
@property double  max;
@property double  majorTicInc;
@property int16_t noMinorTics;
@property bool    bipolar;
@property(assign) MRPlot   *plot;
@property(retain) NSString *quantityString;
@property(retain) NSString *unitSymbolString;
@property double  minimum;
@property double  maximum;
@property(readonly) double  majorTicIncrement;

@end

@interface MRPlot : NSObject <NSCoding,NSCopying> {
    MRSignal      *signal;
	bool           real;
	bool           imag;
	bool           magnitude;
	bool           argument;
    MRAxis        *responseAxis;
    MRAxis        *prevResponseAxis;
    
    NSMutableArray *xAxes;
    NSMutableArray *prevXAxes;
    
    uint8_t horizontalDimensionIndex;
    uint8_t verticalDimensionIndex;
    uint8_t depthDimensionIndex;
}
@property(assign) MRSignal *signal;
@property bool real;
@property bool imag;
@property bool magnitude;
@property bool argument;

@property(copy) MRAxis *responseAxis;
@property(copy) MRAxis *prevResponseAxis;
@property(retain) NSMutableArray *xAxes;
@property(retain) NSMutableArray *prevXAxes;

@property uint8_t horizontalDimensionIndex;
@property uint8_t verticalDimensionIndex;
@property uint8_t depthDimensionIndex;

@end
