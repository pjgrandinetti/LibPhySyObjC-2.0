//
//  MRSignal.m
//  RMN 2.0
//
//  Created by Philip on 7/4/13.
//  Copyright (c) 2013 PhySyApps. All rights reserved.
//

#include <complex.h>
#import <LibPhySyObjC/PhySyDatasetIO.h>
#import <LibPhySyObjC/MRSignalIO.h>


//bool PSDatasetImportMRSignalIsValidURL(CFURLRef url)
//{
//    bool result = false;
//    CFStringRef extension = CFURLCopyPathExtension(url);
//    if(extension) {
//        if(CFStringCompare(extension, CFSTR("rmn"), 0) == kCFCompareEqualTo) result = true;
//        CFRelease(extension);
//    }
//    return result;
//}
//
//CFIndex PSDatasetImportMRSignalNumberOfDimensionsForURL(CFURLRef url)
//{
//    CFDataRef contents;
//	SInt32 errorCode;
//	CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,url,&contents,NULL,NULL,&errorCode);
//    if(errorCode) return 0;
//    
//    MRSignal *output = [[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *) contents] retain];
//
//    CFIndex numberOfDimensions = output.numberOfDimensions;
//    
//    CFRelease(contents);
//    CFRelease(output);
//    return numberOfDimensions;
//}

PSDatasetRef PSDatasetImportMRSignalCreateSignalWithData(CFDataRef contents, CFStringRef fileName, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    MRSignal *output = [[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *) contents] retain];
    NSArray *mrSignalDimensions = [output dimensions];
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSUnitRef seconds = PSUnitForSymbol(CFSTR("s"));
    PSUnitRef hertz = PSUnitForSymbol(CFSTR("Hz"));
    
    for(MRDimension *dim in mrSignalDimensions) {
        PSDimensionRef dimension = PSLinearDimensionCreateDefault([dim npts],
                                                                  CFAutorelease(PSScalarCreateWithDouble([dim dw], seconds)),
                                                                  CFSTR("time"));
        PSDimensionSetReferenceOffset(dimension, CFAutorelease(PSScalarCreateWithDouble([dim timeOriginOffset], seconds)));
        PSDimensionSetInverseQuantityName(dimension, CFSTR("frequency"));
        PSDimensionSetInverseOriginOffset(dimension, CFAutorelease(PSScalarCreateWithDouble([dim frequencyOriginOffset], hertz)));
        PSDimensionSetInverseReferenceOffset(dimension, CFAutorelease(PSScalarCreateWithDouble([dim referenceFrequency], hertz)));
        PSDimensionSetFFT(dimension, [dim fftShift]);
        PSDimensionSetPeriodic(dimension, [dim periodic]);
        if([dim quantity]==FREQ) PSDimensionInverse(dimension);
        CFArrayAppendValue(dimensions, dimension);
        CFRelease(dimension);
    }
    
    PSDatasetRef theDataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(theDataset, dimensions, NULL);
    CFRelease(dimensions);
    PSDependentVariableRef theDependentVariable = PSDatasetAddDefaultDependentVariable(theDataset,
                                                                                       CFSTR("scalar"),
                                                                                       kPSNumberFloat64ComplexType,
                                                                                       kPSDatasetSizeFromDimensions);
    PSDependentVariableSetComponentAtIndex(theDependentVariable, (CFDataRef) [output bytes], 0);
    
    CFRelease(output);
    return theDataset;
}

@implementation MRSignal
@synthesize bytes;
@synthesize comments;
@synthesize title;
@synthesize operations;
@synthesize responseQuantityNameString;
@synthesize responseUnitSymbolString;
@synthesize plot;
@synthesize dimensions;
@synthesize focus;
@synthesize previousFocus;
@dynamic numberOfDimensions;
@dynamic size;

- (void) dealloc
{
    if(bytes) [bytes release];
    if(comments) [comments release];
    if(dimensions) [dimensions release];
    if(focus) [focus release];
    if(previousFocus) [previousFocus release];
    if(responseQuantityNameString) [responseQuantityNameString release];
    if(responseUnitSymbolString) [responseUnitSymbolString release];
    if(title) [title release];
    if(plot) [plot release];
    if(operations) [operations release];
    [super dealloc];
}

- (int8_t) numberOfDimensions
{
    return [dimensions count];
}

- (MRSignal *) copyWithZone: (NSZone *) zone
{
    MRSignal *copy = [[MRSignal allocWithZone: zone] init];
    copy->size = size;
    copy.bytes = [[bytes mutableCopy] autorelease];
    for(MRDimension *dimension in dimensions) [copy.dimensions addObject:[[dimension copy] autorelease]];
    
    for(id operation in operations) {
        id operationCopy = [operation copy];
        [copy.operations addObject:operationCopy];
        [operationCopy release];
    }
    copy.responseQuantityNameString = responseQuantityNameString;
    copy.responseUnitSymbolString = responseUnitSymbolString;
    copy.title = title;
    copy.comments = comments;
    copy.focus = focus;
    copy.previousFocus = previousFocus;
    copy.plot = plot;
    copy.plot.signal = copy;
	return copy;
}

- (MRSignal *) initWithCoder: (NSCoder *) coder
{
    self = [super init];
    if(self) {
        size                      = [coder decodeInt32ForKey:@"size"];
        bytes                     = [[coder decodeObjectForKey:@"bytes"] retain];
        dimensions                = [[coder decodeObjectForKey:@"dimensions"] retain];
        responseQuantityNameString    = [[coder decodeObjectForKey:@"responseQuantityNameString"] retain];
        responseUnitSymbolString  = [[coder decodeObjectForKey:@"responseUnitSymbolString"] retain];
        title                     = [[coder decodeObjectForKey:@"title"] retain];
        comments                  = [[coder decodeObjectForKey:@"comments"] retain];
        //        operations                = [[coder decodeObjectForKey:@"operations"] retain];
        
        previousFocus             = [[coder decodeObjectForKey:@"previousFocus"] retain];
        focus                     = [[coder decodeObjectForKey:@"focus"] retain];
        plot                      = [[coder decodeObjectForKey:@"plot"] retain];
        plot.signal = self;
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInt64: size forKey: @"size"];
    [coder encodeObject:bytes forKey:@"bytes"];
    [coder encodeObject: dimensions forKey:@"dimensions"];
    [coder encodeObject:responseQuantityNameString forKey:@"responseQuantityNameString"];
    [coder encodeObject:responseUnitSymbolString forKey:@"responseUnitSymbolString"];
    [coder encodeObject:title forKey:@"title"];
    [coder encodeObject:comments forKey:@"comments"];
    //    [coder encodeObject: operations forKey:@"operations"];
    [coder encodeObject:focus forKey:@"focus"];
    [coder encodeObject:previousFocus forKey:@"previousFocus"];
    [coder encodeObject:plot forKey:@"plot"];
}

@end

@implementation MRDimension
@synthesize npts;
@synthesize sfreq;
@synthesize dw;
@synthesize timeOriginOffset;
@synthesize frequencyOriginOffset;

@synthesize referenceFrequency;
@synthesize referencePosition;

@synthesize unit;
@synthesize quantity;
@synthesize reverse;
@synthesize fftShift;
@synthesize periodic;
@dynamic dimensionality;

PSUnitRef getPSUnit(Byte unit)
{
	switch(unit) {
		case SECONDS:
            return PSUnitForSymbol(CFSTR("s"));
			break;
		case MILLISECONDS:
            return PSUnitForSymbol(CFSTR("ms"));
			break;
		case MICROSECONDS:
            return PSUnitForSymbol(CFSTR("us"));
			break;
		case HZ:
            return PSUnitForSymbol(CFSTR("Hz"));
			break;
		case KHZ:
            return PSUnitForSymbol(CFSTR("kHz"));
			break;
		case MHZ:
            return PSUnitForSymbol(CFSTR("MHz"));
			break;
		case PPM:
            return PSUnitForSymbol(CFSTR("ppm"));
			break;
	}
    return NULL;
}

- (MRDimension *) copyWithZone: (NSZone *) zone
{
    MRDimension *copy = [MRDimension allocWithZone: zone];
	copy->npts = npts;
	copy->sfreq = sfreq;
	copy->dw = dw;
    
	copy->timeOriginOffset = timeOriginOffset;
	copy->frequencyOriginOffset = frequencyOriginOffset;
    
    copy->referencePosition = referencePosition;
    copy->referenceFrequency = referenceFrequency;
    
	copy->quantity = quantity;
	copy->unit = unit;
	copy->reverse = reverse;
	copy->periodic = periodic;
	copy->fftShift = fftShift;
    if(dimensionality) copy->dimensionality = dimensionality;
	return copy;
}

- (MRDimension *) initWithCoder: (NSCoder *) coder
{
    self = [super init];
    if(self) {
        npts                  = [coder decodeInt32ForKey:@"npts"];
        dw                    = [coder decodeDoubleForKey:@"dw"];
        timeOriginOffset      = [coder decodeDoubleForKey:@"timeOriginOffset"];
        
        fftShift              = [coder decodeBoolForKey:@"fftShift"];
        frequencyOriginOffset = [coder decodeDoubleForKey:@"frequencyOriginOffset"];
        
        unit                  = [coder decodeIntForKey:@"unit"];
        reverse               = [coder decodeBoolForKey:@"reverse"];
        quantity              = [coder decodeIntForKey:@"quantity"];
        
        dimensionality        =  PSUnitGetDimensionality(getPSUnit(unit));
        
        sfreq                 = [coder decodeDoubleForKey:@"sfreq"];
        referenceFrequency    = [coder decodeDoubleForKey:@"referenceFrequency"];
        referencePosition     = [coder decodeDoubleForKey:@"referencePosition"];
        
        
        if([coder containsValueForKey:@"periodic"]) {
            periodic = [coder decodeBoolForKey:@"periodic"];
        }
        else periodic = false;
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInt64: npts forKey: @"npts"];
    [coder encodeDouble: dw forKey: @"dw"];
    [coder encodeDouble: timeOriginOffset forKey: @"timeOriginOffset"];
    
    [coder encodeBool: periodic forKey: @"periodic"];
    [coder encodeBool: fftShift forKey: @"fftShift"];
    [coder encodeDouble: frequencyOriginOffset forKey: @"frequencyOriginOffset"];
    
    [coder encodeInt: unit forKey:@"unit"];
    [coder encodeBool: reverse forKey:@"reverse"];
    [coder encodeInt: quantity forKey:@"quantity"];
    
    [coder encodeDouble: sfreq forKey: @"sfreq"];
    [coder encodeDouble: referenceFrequency forKey: @"referenceFrequency"];
    [coder encodeDouble: referencePosition forKey: @"referencePosition"];
}

@end

@implementation MRDatum
@synthesize numberOfDimensions;
@synthesize response;
@synthesize coordinateValues;
@dynamic coordinates;

- (void) dealloc
{
    if(coordinateValues) [coordinateValues release];
    [super dealloc];
}

- (MRDatum *) copyWithZone: (NSZone *) zone
{
    MRDatum *copy = [[MRDatum allocWithZone: zone] init];
    copy->numberOfDimensions = numberOfDimensions;
    copy->response = response;
    copy->coordinateValues = [coordinateValues copy];
	return copy;
}

- (MRDatum *) initWithCoder: (NSCoder *) coder
{
    self = [super init];
    if(self) {
        numberOfDimensions  = [coder decodeIntForKey:@"numberOfDimensions"];
        response            = [coder decodeDoubleForKey:@"responseReal"] + I*[coder decodeDoubleForKey:@"responseImag"];
        coordinateValues    = [[coder decodeObjectForKey:@"coordinateValues"] retain];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInt: numberOfDimensions forKey: @"numberOfDimensions"];
    [coder encodeDouble: creal(response) forKey: @"responseReal"];
    [coder encodeDouble: cimag(response) forKey: @"responseImag"];
    [coder encodeObject: coordinateValues forKey: @"coordinateValues"];
}


@end


@implementation MRAxis
@synthesize index;
@synthesize min;
@synthesize max;
@synthesize majorTicInc;
@synthesize noMinorTics;
@synthesize bipolar;
@synthesize plot;

@dynamic quantityString;
@dynamic unitSymbolString;

- (MRAxis *) copyWithZone: (NSZone *) zone
{
    MRAxis *copy = [[[self class] allocWithZone: zone] init];
    copy.plot = plot;
    copy.index = index;
    copy.min = min;
    copy.max = max;
    copy.bipolar = bipolar;
    copy.majorTicInc = majorTicInc;
    copy.noMinorTics = noMinorTics;
    copy.quantityString = quantityString;
    copy.unitSymbolString = unitSymbolString;
	return copy;
}
- (MRAxis *) initWithCoder: (NSCoder *) coder
{
    self = [super init];
    if(self) {
        index            = [coder decodeIntForKey:@"index"];
        min              = [coder decodeDoubleForKey:@"min"];
        max              = [coder decodeDoubleForKey:@"max"];
        majorTicInc      = [coder decodeDoubleForKey:@"majorTicInc"];
        noMinorTics      = [coder decodeIntForKey:@"noMinorTics"];
        bipolar          = [coder decodeBoolForKey:@"bipolar"];
        quantityString   = [[coder decodeObjectForKey:@"quantityString"] retain];
        unitSymbolString = [[coder decodeObjectForKey:@"unitSymbolString"] retain];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInt:index forKey: @"index"];
    [coder encodeDouble: min forKey: @"min"];
    [coder encodeDouble: max forKey: @"max"];
    [coder encodeDouble: majorTicInc forKey: @"majorTicInc"];
    [coder encodeInt:noMinorTics forKey:@"noMinorTics"];
    [coder encodeBool:bipolar forKey:@"bipolar"];
    [coder encodeObject:quantityString forKey:@"quantityString"];
    [coder encodeObject:unitSymbolString forKey:@"unitSymbolString"];
}



@end

@implementation MRPlot
@synthesize signal;
@synthesize real;
@synthesize imag;
@synthesize magnitude;
@synthesize argument;
@synthesize responseAxis;
@synthesize prevResponseAxis;
@synthesize xAxes;
@synthesize prevXAxes;

@synthesize horizontalDimensionIndex;
@synthesize verticalDimensionIndex;
@synthesize depthDimensionIndex;

- (void) dealloc
{
    if(responseAxis) [responseAxis release];
    if(xAxes) [xAxes release];
    if(prevResponseAxis) [prevResponseAxis release];
    if(prevXAxes) [prevXAxes release];
    [super dealloc];
}

- (MRPlot *) copyWithZone: (NSZone *) zone
{
    MRPlot *copy = [[[self class] allocWithZone: zone] init];
    copy.signal = signal;
    
    copy.real = real;
    copy.imag = imag;
    copy.magnitude = magnitude;
    copy.horizontalDimensionIndex = horizontalDimensionIndex;
    copy.verticalDimensionIndex = verticalDimensionIndex;
    copy.depthDimensionIndex = depthDimensionIndex;
    
    copy.responseAxis = responseAxis;
    copy.responseAxis.plot = copy;
    
    copy.prevResponseAxis = prevResponseAxis;
    copy.prevResponseAxis.plot = copy;
    
    for(int8_t idim = 0;idim<signal.numberOfDimensions; idim++) {
        MRAxis *axis = [[xAxes objectAtIndex:idim] copy];
        axis.plot = copy;
        [copy.xAxes addObject:axis];
        [axis release];
        
        axis = [[prevXAxes objectAtIndex:idim] copy];
        axis.plot = copy;
        [copy.prevXAxes addObject:axis];
        [axis release];
    }
	return copy;
}

- (MRPlot *) initWithCoder: (NSCoder *) coder
{
    self = [super init];
    if(self) {
        horizontalDimensionIndex  = [coder decodeIntForKey:@"horizontalDimensionIndex"];
        verticalDimensionIndex  = [coder decodeIntForKey:@"verticalDimensionIndex"];
        depthDimensionIndex  = [coder decodeIntForKey:@"depthDimensionIndex"];
        real              = [coder decodeBoolForKey:@"real"];
        imag              = [coder decodeBoolForKey:@"imag"];
        magnitude         = [coder decodeBoolForKey:@"magnitude"];
        argument         = [coder decodeBoolForKey:@"argument"];
        responseAxis      = [[coder decodeObjectForKey:@"responseAxis"] retain];
        prevResponseAxis  = [[coder decodeObjectForKey:@"prevResponseAxis"] retain];
        xAxes             = [[coder decodeObjectForKey:@"xAxes"] retain];
        prevXAxes         = [[coder decodeObjectForKey:@"prevXAxes"] retain];
        
        responseAxis.plot = self;
        prevResponseAxis.plot = self;
        for(int8_t idim = 0;idim<signal.numberOfDimensions; idim++) {
            MRAxis *axis = [xAxes objectAtIndex:idim];
            axis.plot = self;
            
            axis = [prevXAxes objectAtIndex:idim];
            axis.plot = self;
        }
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInt: horizontalDimensionIndex forKey:@"horizontalDimensionIndex"];
    [coder encodeInt: verticalDimensionIndex forKey:@"verticalDimensionIndex"];
    [coder encodeInt: depthDimensionIndex forKey:@"depthDimensionIndex"];
    [coder encodeBool:real forKey:@"real"];
    [coder encodeBool:imag forKey:@"imag"];
    [coder encodeBool:magnitude forKey:@"magnitude"];
    [coder encodeBool:argument forKey:@"argument"];
    [coder encodeObject:responseAxis forKey:@"responseAxis"];
    [coder encodeObject:prevResponseAxis forKey:@"prevResponseAxis"];
    [coder encodeObject:xAxes forKey:@"xAxes"];
    [coder encodeObject:prevXAxes forKey:@"prevXAxes"];
}

@end

