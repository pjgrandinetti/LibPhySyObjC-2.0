//
//  PSQuartzDependentVariable.c
//  PhySyQuartz
//
//  Created by Philip J. Grandinetti on 1/11/12.
//  Copyright (c) 2012 PhySy. All rights reserved.
//

#import <LibPhySyObjC/PhySyQuartz.h>
#import <CoreText/CoreText.h>
#import <Cocoa/Cocoa.h>

@implementation PSQuartzDependentVariable

- (void) dealloc
{
    if(self->real1DPaths) CFRelease(self->real1DPaths);
    if(self->imaginary1DPaths) CFRelease(self->imaginary1DPaths);
    if(self->magnitude1DPaths) CFRelease(self->magnitude1DPaths);
    if(self->argument1DPaths) CFRelease(self->argument1DPaths);
    
    if(self->realIntensityImages) CFRelease(self->realIntensityImages);
    if(self->imaginaryIntensityImages) CFRelease(self->imaginaryIntensityImages);
    if(self->magnitudeIntensityImages) CFRelease(self->magnitudeIntensityImages);
    if(self->argumentIntensityImages) CFRelease(self->argumentIntensityImages);
    if(self->realContourImages) CFRelease(self->realContourImages);
    if(self->imaginaryContourImages) CFRelease(self->imaginaryContourImages);
    if(self->magnitudeContourImages) CFRelease(self->magnitudeContourImages);
    if(self->argumentContourImages) CFRelease(self->argumentContourImages);
    [super dealloc];
}


float fetchResponse(const UInt8 *bytePtr, CFIndex memOffset, numberType elementType, complexPart part)
{
    switch (elementType) {
        case kPSNumberFloat32Type: {
            float *responses = (float *) bytePtr;
            return (float) responses[memOffset];
        }
        case kPSNumberFloat64Type: {
            double *responses = (double *) bytePtr;
            return (float) responses[memOffset];
        }
        case kPSNumberFloat32ComplexType: {
            float complex *responses = (float complex *) bytePtr;
            switch(part) {
                case kPSRealPart: {
                    return (float) crealf(responses[memOffset]);
                }
                case kPSImaginaryPart: {
                    return (float) cimagf(responses[memOffset]);
                }
                case kPSMagnitudePart: {
                    return (float) cabsf(responses[memOffset]);
                }
                case kPSArgumentPart: {
                    return (float) cargument(responses[memOffset]);
                }
            }
        }
        case kPSNumberFloat64ComplexType: {
            double complex *responses = (double complex *) bytePtr;
            switch(part) {
                case kPSRealPart: {
                    return (float) creal(responses[memOffset]);
                }
                case kPSImaginaryPart: {
                    return (float) cimag(responses[memOffset]);
                }
                case kPSMagnitudePart: {
                    return (float) cabs(responses[memOffset]);
                }
                case kPSArgumentPart: {
                    return (float) cargument(responses[memOffset]);
                }
            }
        }
    }
    return 0.0;
}

PSQuartzDependentVariableRef PSQuartzDependentVariableCreate(PSDependentVariableRef theDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(theDependentVariable,NULL);
    PSQuartzDependentVariable *object = [PSQuartzDependentVariable alloc];
    object->horizontalIncrement = 1;
    object->verticalIncrement = 1;
    CFIndex componentsCount = PSDependentVariableComponentsCount(theDependentVariable);
    
    object->real1DPaths = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);;
    object->imaginary1DPaths = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);;
    object->magnitude1DPaths = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);;
    object->argument1DPaths = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);;
    
    object->realIntensityImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    object->imaginaryIntensityImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    object->magnitudeIntensityImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    object->argumentIntensityImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    object->realContourImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    object->imaginaryContourImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    object->magnitudeContourImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    object->argumentContourImages = CFArrayCreateMutable(kCFAllocatorDefault, componentsCount, &kCFTypeArrayCallBacks);
    
    for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
        CFArrayAppendValue(object->realIntensityImages, kCFNull);
        CFArrayAppendValue(object->imaginaryIntensityImages, kCFNull);
        CFArrayAppendValue(object->magnitudeIntensityImages, kCFNull);
        CFArrayAppendValue(object->argumentIntensityImages, kCFNull);
        CFArrayAppendValue(object->realContourImages, kCFNull);
        CFArrayAppendValue(object->imaginaryContourImages, kCFNull);
        CFArrayAppendValue(object->magnitudeContourImages, kCFNull);
        CFArrayAppendValue(object->argumentContourImages, kCFNull);
    }
    return (PSQuartzDependentVariableRef) object;
}

void PSQuartzDependentVariableRemoveImages(PSQuartzDependentVariableRef quartzDependentVariable)
{
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,);

    if(quartzDependentVariable->realIntensityImages) {
        CFIndex componentsCount = CFArrayGetCount(quartzDependentVariable->realIntensityImages);
        for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
            CFArraySetValueAtIndex(quartzDependentVariable->real1DPaths, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->imaginary1DPaths, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->magnitude1DPaths, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->argument1DPaths, componentIndex, kCFNull);
            
            CFArraySetValueAtIndex(quartzDependentVariable->realIntensityImages, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->imaginaryIntensityImages, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->magnitudeIntensityImages, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->argumentIntensityImages, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->realContourImages, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->imaginaryContourImages, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->magnitudeContourImages, componentIndex, kCFNull);
            CFArraySetValueAtIndex(quartzDependentVariable->argumentContourImages, componentIndex, kCFNull);
        }
    }
}

static void getRGBValuesFromColorName(CFStringRef color, CGFloat *red, CGFloat *green, CGFloat *blue)
{
    if(CFStringCompare(color, kPSPlotColorBlack, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0;
        *green = 0;
        *blue = 0;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorBlue, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0;
        *green = 0;
        *blue = 1;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorBrown, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0.58823529411765;
        *green = 0.29411764705882;
        *blue = 0;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorCyan, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0;
        *green = 1;
        *blue = 1;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorGreen, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 41/360.;
        *green = 171/360.;
        *blue = 135/360.;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorMagenta, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 0;
        *blue = 1;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorOrange, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 0.5;
        *blue = 0;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorPurple, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 0.5;
        *green = 0;
        *blue = 0.5;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorRed, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 0;
        *blue = 0;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorYellow, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 1;
        *blue = 0;
        return;
    }
    else if(CFStringCompare(color, kPSPlotColorWhite, kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
        *red = 1;
        *green = 1;
        *blue = 1;
        return;
    }
}

static void PSQuartzDependentVariableSetRGBStrokeColor(CGContextRef context, CFStringRef color)
{
    CGFloat red = 0, green = 0, blue = 0;
    getRGBValuesFromColorName(color, &red, &green, &blue);
    CGContextSetRGBStrokeColor(context, red,green,blue,1);
}

#define MIN2( A, B )   ( (A)<(B) ? (A) : (B) )
#define MAX2( A, B )   ( (A)>(B) ? (A) : (B) )
#define MIN3( A, B, C ) ((A) < (B) ? MIN2(A, C) : MIN2(B, C))
#define MAX3( A, B, C ) ((A) > (B) ? MAX2(A, C) : MAX2(B, C))

// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
//        if s == 0, then h = -1 (undefined)
static void RGBtoHSV( float red, float green, float blue, float *hue, float *saturation, float *value)
{
    float min, max, delta;
    min = MIN3( red, green, blue );
    max = MAX3( red, green, blue );
    if(max==min) {*hue = 0.; *saturation = 0.0; *value = 1.0; return;}
    *value = max;                // v
    delta = max - min;
    if( max != 0 )
        *saturation = delta / max;        // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *saturation = 0;
        *hue = -1;
        return;
    }
    if( red == max )
        *hue = ( green - blue ) / delta;        // between yellow & magenta
    else if( green == max )
        *hue = 2 + ( blue - red ) / delta;    // between cyan & yellow
    else
        *hue = 4 + ( red - green ) / delta;    // between magenta & cyan
    *hue *= 60;            // degrees
    if( *hue < 0 )
        *hue += 360;
}

static void HSVtoRGB( float *red, float *green, float *blue, float hue, float saturation, float value )
{
    //    hue += 0;
    
    int i;
    float f, p, q, t;
    if( saturation == 0 ) {
        // achromatic (grey)
        *red = *green = *blue = value;
        return;
    }
    hue /= 60;            // sector 0 to 5
    i = floorf( hue );
    f = hue - i;            // factorial part of h
    p = value * ( 1 - saturation );
    q = value * ( 1 - saturation * f );
    t = value * ( 1 - saturation * ( 1 - f ) );
    switch( i ) {
        case 0:
            *red = value;
            *green = t;
            *blue = p;
            break;
        case 1:
            *red = q;
            *green = value;
            *blue = p;
            break;
        case 2:
            *red = p;
            *green = value;
            *blue = t;
            break;
        case 3:
            *red = p;
            *green = q;
            *blue = value;
            break;
        case 4:
            *red = t;
            *green = p;
            *blue = value;
            break;
        default:        // case 5:
            *red = value;
            *green = p;
            *blue = q;
            break;
    }
}

static void CGHSVtoRGB( CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat hue, CGFloat saturation, CGFloat value )
{
    //    hue += 0;
    
    int i;
    CGFloat f, p, q, t;
    if( saturation == 0 ) {
        // achromatic (grey)
        *red = *green = *blue = value;
        return;
    }
    hue /= 60;            // sector 0 to 5
    i = floor( hue );
    f = hue - i;            // factorial part of h
    p = value * ( 1 - saturation );
    q = value * ( 1 - saturation * f );
    t = value * ( 1 - saturation * ( 1 - f ) );
    switch( i ) {
        case 0:
            *red = value;
            *green = t;
            *blue = p;
            break;
        case 1:
            *red = q;
            *green = value;
            *blue = p;
            break;
        case 2:
            *red = p;
            *green = value;
            *blue = t;
            break;
        case 3:
            *red = p;
            *green = q;
            *blue = value;
            break;
        case 4:
            *red = t;
            *green = p;
            *blue = value;
            break;
        default:        // case 5:
            *red = value;
            *green = p;
            *blue = q;
            break;
    }
}

//typedef struct COLOUR {
//    double r,g,b;
//} COLOUR;
//
//static COLOUR GetColour(double v,double vmin,double vmax)
//{
//    COLOUR c = {1.0,1.0,1.0}; // white
//    double dv;
//
//    if (v < vmin)
//        v = vmin;
//    if (v > vmax)
//        v = vmax;
//    dv = vmax - vmin;
//
//    if (v < (vmin + 0.25 * dv)) {
//        c.r = 0;
//        c.g = 4 * (v - vmin) / dv;
//    } else if (v < (vmin + 0.5 * dv)) {
//        c.r = 0;
//        c.b = 1 + 4 * (vmin + 0.25 * dv - v) / dv;
//    } else if (v < (vmin + 0.75 * dv)) {
//        c.r = 4 * (v - vmin - 0.5 * dv) / dv;
//        c.b = 0;
//    } else {
//        c.g = 1 + 4 * (vmin + 0.75 * dv - v) / dv;
//        c.b = 0;
//    }
//
//    return(c);
//}

static void DrawHorizontalAxisTicMark(CGContextRef context, double hpos, double axisTop, double ticLength)
{
    double vpos = axisTop;
    CGContextBeginPath(context);
    NSColor *foreColor = [NSColor labelColor];
    CGContextSetStrokeColorWithColor(context, foreColor.CGColor);
    CGContextMoveToPoint(context, hpos,vpos);
    vpos = axisTop - ticLength;
    CGContextAddLineToPoint(context,hpos,vpos);
    CGContextStrokePath(context);
}

static void DrawVerticalAxisTicMark(CGContextRef context, double vpos, double axisTop, double ticLength)
{
    double hpos = axisTop;
    CGContextBeginPath(context);
    NSColor *foreColor = [NSColor labelColor];
    CGContextSetStrokeColorWithColor(context, foreColor.CGColor);
    CGContextMoveToPoint(context, hpos,vpos);
    hpos = axisTop - ticLength;
    CGContextAddLineToPoint(context,hpos,vpos);
    CGContextStrokePath(context);
}

static void DrawGridLineAtHorizontalPosition(CGContextRef context, double hpos, double vmin, double vmax)
{
    CGContextBeginPath(context);
    
    if([[[NSAppearance currentAppearance] name] isEqual: NSAppearanceNameAqua]) {
        CGContextSetLineWidth(context,0.5);
        CGContextSetRGBStrokeColor(context,.65,.16,.16,0.5);
    }
    else {
        CGContextSetLineWidth(context,0.5);
        CGContextSetRGBStrokeColor(context,.65,.16,.16,1);
    }
    
    CGContextMoveToPoint(context, hpos,vmin-1);
    CGContextAddLineToPoint(context,hpos,vmax);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context,1.0);
}

static void DrawGridLineAtVerticalPosition(CGContextRef context, double vpos, double hmin, double hmax)
{
    CGContextBeginPath(context);
    
    if([[[NSAppearance currentAppearance] name] isEqual: NSAppearanceNameAqua]) {
        CGContextSetLineWidth(context,0.5);
        CGContextSetRGBStrokeColor(context,.65,.16,.16,0.5);
    }
    else {
        CGContextSetLineWidth(context,0.5);
        CGContextSetRGBStrokeColor(context,.65,.16,.16,1);
    }
    
    CGContextMoveToPoint(context,hmin-1,vpos);
    CGContextAddLineToPoint(context,hmax,vpos);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context,1.0);
}

static void DrawHorizontalAxisTicMarkValue(CGContextRef context,
                                           double value,
                                           double hpos,
                                           double vpos,
                                           CGFloat fontSize,
                                           CGFloat fontHeight)
{
    CFStringRef numberString = PSDoubleComplexCreateStringValueWithFormat(value, CFSTR("%.7g"));
    CGContextSaveGState(context);
    
    NSColor *foreColor = [NSColor labelColor];
    CTFontRef font = CTFontCreateWithName(CFSTR("LucidaGrande"), fontSize, NULL);
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font,foreColor.CGColor };
    CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                              sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, numberString, attr);
    CFRelease(attr);
    
    
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CGRect rect = CTLineGetImageBounds( line,  context );
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
    
    double number_hpos = hpos - rect.size.width/2;
    double number_vpos = vpos - fontHeight;
    CGContextTranslateCTM(context,number_hpos,number_vpos);
    
    CTLineDraw(line, context);
    
    CFRelease(line);
    CFRelease(attrString);
    CFRelease(font);
    CGContextRestoreGState(context);
    CFRelease(numberString);
}

static void DrawVerticalAxisTicMarkValue(CGContextRef context,
                                         double value,
                                         double hpos,
                                         double vpos,
                                         CGFloat fontSize,
                                         CGFloat fontHeight)
{
    CFStringRef numberString = PSDoubleComplexCreateStringValueWithFormat(value, CFSTR("%.7g"));
    CGContextSaveGState(context);
    
    CTFontRef font = CTFontCreateWithName(CFSTR("LucidaGrande"), fontSize, NULL);
    
    NSColor *foreColor = [NSColor labelColor];
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font,foreColor.CGColor };
    CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                              sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, numberString, attr);
    CFRelease(attr);
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CGRect rect = CTLineGetImageBounds( line,  context );
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
    
    double number_hpos = hpos - rect.size.width -fontHeight/2;
    double number_vpos = vpos -fontHeight/3;
    CGContextTranslateCTM(context,number_hpos,number_vpos);
    
    CTLineDraw(line, context);
    
    CFRelease(line);
    CFRelease(attrString);
    CFRelease(font);
    CGContextRestoreGState(context);
    CFRelease(numberString);
}

static bool PSQuartzDependentVariableDrawVerticalAxis(PSDatasetRef theDataset, PSAxisRef axis, CGRect axisRect, CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(axis,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    CGContextSaveGState(context);
    
    PSPlotRef plot = PSAxisGetPlot(axis);
    PSScalarRef majorTicIncrement = PSAxisGetMajorTicIncrement(axis);
    PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) majorTicIncrement);
    double majorTicInc = PSScalarDoubleValue(majorTicIncrement);
    PSScalarRef axisMinimum = PSAxisGetMinimum(axis);
    PSScalarRef axisMaximum = PSAxisGetMaximum(axis);
    
    bool success = true;
    double ymin = PSScalarDoubleValueInUnit(axisMinimum, unit, &success);
    double ymax = PSScalarDoubleValueInUnit(axisMaximum, unit, &success);
    
    CFStringRef label = PSAxisCreateStringWithLabelAndUnit(axis);
    double axisStart = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, axisMinimum, axisRect, error);
    double axisEnd = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, axisMaximum, axisRect, error);
    double vposLower = axisStart;
    double vposUpper = axisEnd;
    if(PSAxisGetReverse(axis)) {
        vposLower = axisEnd;
        vposUpper = axisStart;
    }
    double width = vposUpper - vposLower;
    if(width==0 || isnan(axisStart) || isnan(axisEnd)) {
        if(error) {
            CFStringRef desc = CFSTR("Vertical axis has zero width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        if(label) CFRelease(label);
        return false;
    }
    /*    Set up font info */
    double fontSize = PSPlotGetFontSize(plot);
    
    CGFontRef font = CGFontCreateWithFontName(CFSTR("Lucida Grande"));
    CGContextSetFont(context,font);
    CGContextSetFontSize(context,fontSize);
    CFRelease(font);
    
    CGContextSetTextDrawingMode(context,kCGTextFill);
    int fontheight = fontSize;
    
    int axisTop = axisRect.origin.x + axisRect.size.width - 4;
    int majorTicLength = 2*fontSize/3;
    int minorTicLength = fontSize/3;
    
    /* Draw vertical axis line */
    CGContextSetLineWidth(context,1.0);
    CGContextBeginPath(context);
    
    NSColor *foreColor = [NSColor labelColor];
    CGContextSetStrokeColorWithColor(context, foreColor.CGColor);
    CGContextMoveToPoint(context,axisTop, axisStart);
    CGContextAddLineToPoint(context,axisTop, axisEnd);
    CGContextStrokePath(context);
    
    /* Label Axis */
    {
        CGContextSaveGState(context);
        
        CTFontRef font = CTFontCreateWithName(CFSTR("LucidaGrande"), fontSize, NULL);
        
        CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
        CFTypeRef values[] = { font,foreColor.CGColor };
        CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                                  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, label, attr);
        CFRelease(attr);
        
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGRect rect = CTLineGetImageBounds( line,  context );
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
        
        double hpos = axisRect.origin.x + 2*fontheight;
        double vpos = axisRect.origin.y+axisRect.size.height/2 - rect.size.width/2;
        CGContextTranslateCTM(context,hpos,vpos);
        
        float angle = M_PI/2;
        CGContextRotateCTM(context, angle);
        
        CTLineDraw(line, context);
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(font);
        CGContextRestoreGState(context);
        
    }
    CFRelease(label);
    
    CFIndex nmtics = PSAxisGetNumberOfMinorTics(axis);
    double minorinc = majorTicInc / (double) (nmtics+1.);
    
    double tic;
    double vpos;
    
    /* See if both positive and negative values are present */
    if(((ymax>=0.)&&(ymin<=0.))||((ymax<=0.)&&(ymin>=0.))) {
        int numberForwardTics;
        int numberBackwardsTics;
        if(ymax<ymin) { // reversed
            numberForwardTics = (int) ceil(fabs(ymin)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(ymax)/majorTicInc);
        }
        else {
            numberForwardTics = (int) ceil(fabs(ymax)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(ymin)/majorTicInc);
        }
        
        
        tic = 0.; /* This tic exists! */
        for(int i=0;i<numberForwardTics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
            CFRelease(value);
            if((vpos>vposLower)&&(vpos<vposUpper)) {
                CGContextSetLineWidth(context,1.0);
                DrawVerticalAxisTicMark(context, vpos, axisTop, majorTicLength);
                double hpos = axisTop - majorTicLength;
                DrawVerticalAxisTicMarkValue(context,tic, hpos, vpos, fontSize, fontheight);
            }
            double minortic = tic + minorinc;
            for(int j=0;j<nmtics;j++) {
                PSScalarRef value = PSScalarCreateWithDouble(minortic, unit);
                vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
                CFRelease(value);
                
                if((vpos>vposLower)&&(vpos<vposUpper)) {
                    DrawVerticalAxisTicMark(context, vpos, axisTop, minorTicLength);
                }
                minortic += minorinc;
            }
            tic += majorTicInc;
        }
        tic = 0.;
        for(int i=0;i<numberBackwardsTics;i++) {
            double minortic = tic - minorinc;
            tic -= majorTicInc;
            for(int j=0;j<nmtics;j++) {
                PSScalarRef value = PSScalarCreateWithDouble(minortic, unit);
                vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
                CFRelease(value);
                
                if((vpos>vposLower)&&(vpos<vposUpper)) DrawVerticalAxisTicMark(context, vpos, axisTop, minorTicLength);
                
                minortic -= minorinc;
            }
            
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
            CFRelease(value);
            
            if((vpos>vposLower)&&(vpos<vposUpper)) {
                CGContextSetLineWidth(context,1.0);
                DrawVerticalAxisTicMark(context, vpos, axisTop, majorTicLength);
                double hpos = axisTop - majorTicLength;
                DrawVerticalAxisTicMarkValue(context,tic, hpos, vpos, fontSize, fontheight);
            }
            
        }
    }
    else { /* No zero tic exists */
        // Setup initial tic, and number of tics
        
        float range = fabs(ymax-ymin);
        int n = floorf(log10f(range));
        range = ceilf(range * powf(10,-(double) n)) * powf(10,(double) n);
        
        tic = floorf(ymin/fabs(majorTicInc))*fabs(majorTicInc);
        double ceilTic = ceilf(ymin/fabs(majorTicInc))*fabs(majorTicInc);
        int ntics = fabs(range)/fabs(majorTicInc)+1;
        
        if(ymax<ymin) {
            majorTicInc = - majorTicInc;
            minorinc = - minorinc;
            tic = ceilTic;
        }
        for(int i=0;i<ntics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
            CFRelease(value);
            
            if((vpos>vposLower)&&(vpos<vposUpper)) {
                CGContextSetLineWidth(context,1.0);
                DrawVerticalAxisTicMark(context, vpos, axisTop, majorTicLength);
                double hpos = axisTop - majorTicLength;
                DrawVerticalAxisTicMarkValue(context,tic, hpos, vpos, fontSize, fontheight);
                
            }
            double minortic = tic + minorinc;
            for(int j=0;j<nmtics;j++) {
                PSScalarRef value = PSScalarCreateWithDouble(minortic, unit);
                vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
                CFRelease(value);
                
                if((vpos>vposLower)&&(vpos<vposUpper))  DrawVerticalAxisTicMark(context, vpos, axisTop, minorTicLength);
                
                minortic += minorinc;
            }
            tic += majorTicInc;
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    return true;
}

static bool PSQuartzDependentVariableDrawVerticalAxisGridLinesInSignalRect(PSDatasetRef theDataset, PSAxisRef axis, CGRect signalRect, CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(axis,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    CGContextSaveGState(context);
    
    double axisStart = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, PSAxisGetMinimum(axis), signalRect, error);
    double axisEnd = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, PSAxisGetMaximum(axis), signalRect, error);
    double vposLower = axisStart;
    double vposUpper = axisEnd;
    if(PSAxisGetReverse(axis)) {
        vposLower = axisEnd;
        vposUpper = axisStart;
    }

    PSScalarRef majorTicIncrement = PSAxisGetMajorTicIncrement(axis);
    PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) majorTicIncrement);
    double majorTicInc = PSScalarDoubleValue(majorTicIncrement);
    
    bool success = true;
    double ymin = PSScalarDoubleValueInUnit(PSAxisGetMinimum(axis), unit, &success);
    double ymax = PSScalarDoubleValueInUnit(PSAxisGetMaximum(axis), unit, &success);
    
    double hmax = signalRect.origin.x+signalRect.size.width;
    double hmin = signalRect.origin.x;
    
    double tic;
    double vpos;
    
    /* See if both positive and negative values are present */
    if(((ymax>=0.)&&(ymin<=0.))||((ymax<=0.)&&(ymin>=0.))) {
        int numberForwardTics;
        int numberBackwardsTics;
        if(ymax<ymin) { // reversed
            numberForwardTics = (int) ceil(fabs(ymin)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(ymax)/majorTicInc);
        }
        else {
            numberForwardTics = (int) ceil(fabs(ymax)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(ymin)/majorTicInc);
        }
        
        tic = 0.; /* This tic exists! */
        for(int i=0;i<numberForwardTics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, signalRect, error);
            CFRelease(value);
            
            if((vpos>vposLower)&&(vpos<vposUpper)) DrawGridLineAtVerticalPosition(context, vpos, hmin, hmax);
            tic += majorTicInc;
        }
        tic = 0.;
        for(int i=0;i<numberBackwardsTics;i++) {
            tic -= majorTicInc;
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, signalRect, error);
            CFRelease(value);
            if((vpos>vposLower)&&(vpos<vposUpper)) DrawGridLineAtVerticalPosition(context, vpos, hmin, hmax);
        }
    }
    else { /* No zero tic exists */
        float range = fabs(ymax-ymin);
        int n = floorf(log10f(range));
        range = ceilf(range * powf(10,-(double) n)) * powf(10,(double) n);
        
        tic = floorf(ymin/fabs(majorTicInc))*fabs(majorTicInc);
        double ceilTic = ceilf(ymin/fabs(majorTicInc))*fabs(majorTicInc);
        int ntics = fabs(range)/fabs(majorTicInc)+1;
        
        if(ymax<ymin) {
            majorTicInc = - majorTicInc;
            tic = ceilTic;
        }
        
        for(int i=0;i<ntics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(axis, value, signalRect, error);
            CFRelease(value);
            if((vpos>vposLower)&&(vpos<vposUpper)) DrawGridLineAtVerticalPosition(context, vpos, hmin, hmax);
            tic += majorTicInc;
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    return true;
}


static bool PSQuartzDependentVariableDrawHorizontalAxis(PSDatasetRef theDataset, PSAxisRef axis, CGRect axisRect, CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(axis,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    CGContextSaveGState(context);
    
    PSPlotRef plot = PSAxisGetPlot(axis);
    PSScalarRef majorTicIncrement = PSAxisGetMajorTicIncrement(axis);
    PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) majorTicIncrement);
    double majorTicInc = PSScalarDoubleValue(majorTicIncrement);
    PSScalarRef axisMinimum = PSAxisGetMinimum(axis);
    PSScalarRef axisMaximum = PSAxisGetMaximum(axis);
        bool success = true;
    double xmin = PSScalarDoubleValueInUnit(axisMinimum, unit, &success);
    double xmax = PSScalarDoubleValueInUnit(axisMaximum, unit, &success);
    
    CFStringRef label = PSAxisCreateStringWithLabelAndUnit(axis);
    double axisStart = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, axisMinimum, axisRect, error);
    double axisEnd = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, axisMaximum, axisRect, error);
    double hposLower = axisStart;
    double hposUpper = axisEnd;
    if(PSAxisGetReverse(axis)) {
        hposLower = axisEnd;
        hposUpper = axisStart;
    }
    double width = hposUpper - hposLower;
    if(width==0 || isnan(axisStart) || isnan(axisEnd)) {
        if(error) {
            CFStringRef desc = CFSTR("Horizontal axis has zero width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        if(label) CFRelease(label);
        return false;
    }
    
    /*    Set up font info */
    double fontSize = PSPlotGetFontSize(plot);
    
    CGFontRef font = CGFontCreateWithFontName(CFSTR("Lucida Grande"));
    CGContextSetFont(context,font);
    CGContextSetFontSize(context,fontSize);
    CFRelease(font);
    
    CGContextSetTextDrawingMode(context,kCGTextFill);
    int fontheight = fontSize;
    
    int axisTop = axisRect.size.height - 4;
    int majorTicLength = 2*fontSize/3;
    int minorTicLength = fontSize/3;
    
    /* Draw horizontal axis line */
    CGContextSetLineWidth(context,1.0);
    CGContextBeginPath(context);
    
    NSColor *foreColor = [NSColor labelColor];
    CGContextSetStrokeColorWithColor(context, foreColor.CGColor);
    
    CGContextMoveToPoint(context,hposLower,axisTop);
    CGContextAddLineToPoint(context,hposUpper,axisTop);
    CGContextStrokePath(context);
    
    /* Label Axis */
    {
        CGContextSaveGState(context);
        
        CTFontRef font = CTFontCreateWithName(CFSTR("LucidaGrande"), fontSize, NULL);
        
        CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
        CFTypeRef values[] = { font,foreColor.CGColor };
        CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                                  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, label, attr);
        CFRelease(attr);
        
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGRect rect = CTLineGetImageBounds( line,  context );
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
        
        double hpos = hposLower + width/2-rect.size.width/2;
        double vpos = axisTop-3*fontheight;
        CGContextTranslateCTM(context,hpos,vpos);
        
        CTLineDraw(line, context);
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(font);
        CGContextRestoreGState(context);
        
    }
    CFRelease(label);
    
    CFIndex nmtics = PSAxisGetNumberOfMinorTics(axis);
    double minorinc = majorTicInc / (double) (nmtics+1.);
    
    double tic;
    double hpos;
    
    /* See if both positive and negative values are present */
    if(((xmax>=0.)&&(xmin<=0.))||((xmax<=0.)&&(xmin>=0.))) {
        int numberForwardTics;
        int numberBackwardsTics;
        if(xmax<xmin) { // reversed
            numberForwardTics = (int) ceil(fabs(xmin)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(xmax)/majorTicInc);
        }
        else {
            numberForwardTics = (int) ceil(fabs(xmax)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(xmin)/majorTicInc);
        }
        
        tic = 0.; /* This tic exists! */
        for(int i=0;i<numberForwardTics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
            CFRelease(value);
            if((hpos>hposLower)&&(hpos<hposUpper)) {
                CGContextSetLineWidth(context,1.0);
                DrawHorizontalAxisTicMark(context, hpos, axisTop, majorTicLength);
                double vpos = axisTop - majorTicLength;
                DrawHorizontalAxisTicMarkValue(context, tic, hpos, vpos, fontSize, fontheight);
            }
            double minortic = tic + minorinc;
            for(int j=0;j<nmtics;j++) {
                PSScalarRef value = PSScalarCreateWithDouble(minortic, unit);
                hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
                CFRelease(value);
                
                if((hpos>hposLower)&&(hpos<hposUpper))
                    DrawHorizontalAxisTicMark(context, hpos, axisTop, minorTicLength);
                
                minortic += minorinc;
            }
            tic += majorTicInc;
        }
        tic = 0.;
        for(int i=0;i<numberBackwardsTics;i++) {
            double minortic = tic - minorinc;
            tic -= majorTicInc;
            for(int j=0;j<nmtics;j++) {
                PSScalarRef value = PSScalarCreateWithDouble(minortic, unit);
                hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
                CFRelease(value);
                
                if((hpos>hposLower)&&(hpos<hposUpper)) DrawHorizontalAxisTicMark(context, hpos, axisTop, minorTicLength);
                
                minortic -= minorinc;
            }
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
            CFRelease(value);
            
            if((hpos>hposLower)&&(hpos<hposUpper)) {
                CGContextSetLineWidth(context,1.0);
                DrawHorizontalAxisTicMark(context, hpos, axisTop, majorTicLength);
                double vpos = axisTop - majorTicLength;
                DrawHorizontalAxisTicMarkValue(context, tic, hpos, vpos, fontSize, fontheight);
            }
        }
        
    }
    else { /* No zero tic exists */
        // Setup initial tic, and number of tics
        
        float range = fabs(xmax-xmin);
        int n = floorf(log10f(range));
        range = ceilf(range * powf(10,-(double) n)) * powf(10,(double) n);
        
        tic = floorf(xmin/fabs(majorTicInc))*fabs(majorTicInc);
        double ceilTic = ceilf(xmin/fabs(majorTicInc))*fabs(majorTicInc);
        int ntics = fabs(range)/fabs(majorTicInc)+1;
        
        if(xmax<xmin) {
            majorTicInc = - majorTicInc;
            minorinc = - minorinc;
            tic = ceilTic;
        }
        
        for(int i=0;i<ntics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
            CFRelease(value);
            
            if((hpos>hposLower)&&(hpos<hposUpper)) {
                CGContextSetLineWidth(context,1.0);
                DrawHorizontalAxisTicMark(context, hpos, axisTop, majorTicLength);
                double vpos = axisTop - majorTicLength;
                DrawHorizontalAxisTicMarkValue(context, tic, hpos, vpos, fontSize, fontheight);
            }
            double minortic = tic + minorinc;
            for(int j=0;j<nmtics;j++) {
                PSScalarRef value = PSScalarCreateWithDouble(minortic, unit);
                hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, axisRect, error);
                CFRelease(value);
                
                if((hpos>hposLower)&&(hpos<hposUpper)) DrawHorizontalAxisTicMark(context, hpos, axisTop, minorTicLength);
                
                minortic += minorinc;
            }
            tic += majorTicInc;
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    return true;
}

static bool PSQuartzDependentVariableDrawHorizontalAxisGridLinesInSignalRect(PSDatasetRef theDataset, PSAxisRef axis, CGRect signalRect, CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    CGContextSaveGState(context);
    
    double axisStart = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, PSAxisGetMinimum(axis), signalRect, error);
    double axisEnd = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, PSAxisGetMaximum(axis), signalRect, error);
    double hposLower = axisStart;
    double hposUpper = axisEnd;
    if(PSAxisGetReverse(axis)) {
        hposLower = axisEnd;
        hposUpper = axisStart;
    }

    PSScalarRef majorTicIncrement = PSAxisGetMajorTicIncrement(axis);
    PSUnitRef unit = PSQuantityGetUnit((PSQuantityRef) majorTicIncrement);
    double majorTicInc = PSScalarDoubleValue(majorTicIncrement);
    
    bool success = true;
    double xmin = PSScalarDoubleValueInUnit(PSAxisGetMinimum(axis), unit, &success);
    double xmax = PSScalarDoubleValueInUnit(PSAxisGetMaximum(axis), unit, &success);
    
    double vmax = signalRect.origin.y+signalRect.size.height;
    double vmin = signalRect.origin.y;
    
    double tic;
    double hpos;
    
    /* See if both positive and negative values are present */
    if(((xmax>=0.)&&(xmin<=0.))||((xmax<=0.)&&(xmin>=0.))) {  // axis contains zero
        int numberForwardTics;
        int numberBackwardsTics;
        if(xmax<xmin) { // reversed
            numberForwardTics = (int) ceil(fabs(xmin)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(xmax)/majorTicInc);
        }
        else {
            numberForwardTics = (int) ceil(fabs(xmax)/majorTicInc);
            numberBackwardsTics = (int) ceil(fabs(xmin)/majorTicInc);
        }
        
        tic = 0.; /* This tic exists! */
        for(int i=0;i<numberForwardTics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, signalRect, error);
            CFRelease(value);
            
            if((hpos>hposLower)&&(hpos<hposUpper)) DrawGridLineAtHorizontalPosition(context, hpos, vmin, vmax);
            tic += majorTicInc;
        }
        tic = 0.;
        for(int i=0;i<numberBackwardsTics;i++) {
            tic -= majorTicInc;
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, signalRect, error);
            CFRelease(value);
            
            if((hpos>hposLower)&&(hpos<hposUpper)) DrawGridLineAtHorizontalPosition(context, hpos, vmin, vmax);
        }
    }
    else { /* No zero tic exists */
        
        float range = fabs(xmax-xmin);
        int n = floorf(log10f(range));
        range = ceilf(range * powf(10,-(double) n)) * powf(10,(double) n);
        
        tic = floorf(xmin/fabs(majorTicInc))*fabs(majorTicInc);
        double ceilTic = floorf(xmin/fabs(majorTicInc))*fabs(majorTicInc);
        int ntics = fabs(range)/fabs(majorTicInc)+1;
        
        if(xmax<xmin) {
            majorTicInc = - majorTicInc;
            tic = ceilTic;
        }
        
        for(int i=0;i<ntics;i++) {
            PSScalarRef value = PSScalarCreateWithDouble(tic, unit);
            hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(axis, value, signalRect, error);
            CFRelease(value);
            
            if((hpos>hposLower)&&(hpos<hposUpper)) DrawGridLineAtHorizontalPosition(context, hpos, vmin, vmax);
            tic += majorTicInc;
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    return true;
}


void drawCircle(CGMutablePathRef path, double radius, double hpos, double vpos)
{
    CGRect circleRect;
    circleRect.size.width = 2*radius;
    circleRect.size.height = 2*radius;
    circleRect.origin.x = hpos - radius;
    circleRect.origin.y = vpos - radius;
    CGPathAddEllipseInRect(path,NULL, circleRect);
}

void pathApplyfunction(void * __nullable info,
                               const CGPathElement *  element)
{
    fprintf(stderr, "path element type = %d, x=%lg, y=%lg\n", element->type,element->points->x, element->points->y);
}

void alignToPixel(CGPoint *point, CGContextRef context)
{
    *point = CGContextConvertPointToDeviceSpace(context, *point);
    point->x = nearbyint(point->x);
    point->y = nearbyint(point->y);
    *point = CGContextConvertPointToUserSpace(context, *point);
}

CGPathRef PSQuartzDependentVariablePlot1DCreatePathForCrossSectionThroughFocus(PSDatasetRef theDataset,
                                                                               PSAxisRef coordinateAxis,
                                                                               PSAxisRef responseAxis,
                                                                               complexPart part,
                                                                               CGRect signalRect,
                                                                               CGContextRef context,
                                                                               CFErrorRef *error)
{
#ifdef PhySyDEBUG
    NSLog(@"Entering PSQuartzDependentVariablePlot1DCreatePathForCrossSectionThroughFocus");
#endif
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(coordinateAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(responseAxis,false);
    
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);

    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    // If theDataset is not 1D, then extract the 1D cross-section to be plotted.
    CFRetain(theDependentVariable);
    PSDimensionRef dimension = PSDatasetGetDimensionAtIndex(theDataset, PSAxisGetIndex(coordinateAxis));
    if(PSDatasetDimensionsCount(theDataset)>1) {
        PSIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
        PSMutableIndexPairSetRef indexPairSet = PSIndexPairSetCreateMutableWithIndexArray(focusIndexes);
        CFRelease(focusIndexes);
        
        CFIndex dimIndex = PSAxisGetIndex(coordinateAxis);
        PSIndexPairSetRemoveIndexPairWithIndex(indexPairSet, dimIndex);
        theDependentVariable = PSDependentVariableCreateCrossSection(theDependentVariable,
                                                                     dimensions,
                                                                     indexPairSet, error);
        CFRelease(indexPairSet);
    }
    
    // Converted to 1D cross-section through focus.
    
    bool lines = PSPlotGetLines(thePlot);
    CFIndex hCoordinateIndexMin = PSAxisGetCoordinateIndexClosestToMinimum(coordinateAxis);
    CFIndex hCoordinateIndexMax = PSAxisGetCoordinateIndexClosestToMaximum(coordinateAxis);
    if(hCoordinateIndexMin == hCoordinateIndexMax) {
        CFRelease(theDependentVariable);
        return false;
    }
    
    bool hasNonUniformGrid = PSDimensionHasNonUniformGrid(dimension);
    CFIndex npts = PSDimensionGetNpts(dimension);
    CFIndex hSpan =hCoordinateIndexMax -hCoordinateIndexMin;
    if(hSpan > 4*npts) {
        if(error) {
            CFStringRef desc = CFSTR("Plot limits exceeds 4 times dimension width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            kPSQuartzDependentVariableHorizontalWidthExceeded,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        CFRelease(theDependentVariable);
        return false;
    }
    
    bool coordinateReverse = PSAxisGetReverse(coordinateAxis);
    double horizontalScale = signalRect.size.width/(hCoordinateIndexMax - hCoordinateIndexMin);
    double horizontalOffset = signalRect.origin.x;
    if(coordinateReverse) {
        horizontalOffset += signalRect.size.width;
        horizontalScale = - horizontalScale;
    }
    
    PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);
    PSMutableScalarRef min = (PSMutableScalarRef) PSScalarCreateCopy(PSAxisGetMinimum(responseAxis));
    PSScalarConvertToUnit(min, responseUnit, error);
    double responseMin = PSScalarDoubleValue(min);
    
    PSMutableScalarRef max = (PSMutableScalarRef) PSScalarCreateCopy(PSAxisGetMaximum(responseAxis));
    PSScalarConvertToUnit(max, responseUnit, error);
    double responseMax = PSScalarDoubleValue(max);
    
    double verticalScale = signalRect.size.height/(responseMax - responseMin);
    double verticalOffset = signalRect.origin.y;
    
    double width = horizontalScale*(hCoordinateIndexMax - hCoordinateIndexMin);
    
    double vmax = signalRect.origin.y+signalRect.size.height;
    double vmin = signalRect.origin.y;
    
    bool plotAll = PSPlotGetPlotAll(thePlot);
    
    CFIndex pointsPerPixel = (hCoordinateIndexMax - hCoordinateIndexMin)/fabs(width);
    if(pointsPerPixel<1) pointsPerPixel = 1;
    if(pointsPerPixel > (hCoordinateIndexMax-hCoordinateIndexMin+1)/2) pointsPerPixel = (hCoordinateIndexMax-hCoordinateIndexMin+1)/2;
    if(plotAll) pointsPerPixel = 1;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CFIndex tempIndex = hCoordinateIndexMin;
    memOffset = memOffsetFromIndexes(&tempIndex, 1, &npts);
    float response = PSDependentVariableFloatValueAtMemOffsetForPart(theDependentVariable, componentIndex, memOffset, part);
    double hpos = horizontalOffset;
    double vpos = verticalScale * (response - responseMin) + verticalOffset;
    
    if(vpos>vmax) vpos = vmax;
    if(vpos<vmin) vpos = vmin;
    
    if(hasNonUniformGrid) {
        for(CFIndex i=hCoordinateIndexMin;i<= hCoordinateIndexMax ;i++) {
            PSScalarRef coordinate = PSDimensionCreateDisplayedCoordinateFromIndex(dimension, i);
            response = PSDependentVariableFloatValueAtMemOffsetForPart(theDependentVariable, i, memOffset, part);
            double hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(coordinateAxis, coordinate, signalRect, error);
            vpos = verticalScale * (response - responseMin) + verticalOffset;
            if(vpos>vmax) vpos = vmax;
            if(vpos<vmin) vpos = vmin;
            if(isfinite(hpos)&&isfinite(vpos)) drawCircle(path, 4, hpos, vpos);
            else NSLog(@"infinite hpos or vpos found");
            if(isfinite(hpos)&&isfinite(vpos)) drawCircle(path, 3, hpos, vpos);
            else NSLog(@"infinite hpos or vpos found");
        }
    }
    else {
        if(lines) {
            CFIndex pointsCount = labs(hCoordinateIndexMax - hCoordinateIndexMin + 4);
            CGPoint *points = malloc(sizeof(CGPoint)*pointsCount);
            CFIndex pointIndex = 0;
            points[pointIndex].x = hpos;
            points[pointIndex++].y = vpos;

//            CGPathMoveToPoint(path, NULL, hpos, vpos);
            for(CFIndex i=hCoordinateIndexMin;i<=hCoordinateIndexMax ;i += pointsPerPixel) {
                CFIndex tempIndex = i;
                memOffset = memOffsetFromIndexes(&tempIndex, 1, &npts);
                response = PSDependentVariableFloatValueAtMemOffsetForPart(theDependentVariable, componentIndex, memOffset, part);
                hpos = horizontalScale*(i - hCoordinateIndexMin) + horizontalOffset;
                if(pointsPerPixel>1) {
                    /* Find Maximum and Minimum point within inc. */
                    float minResponseInPixel = response;
                    float maxResponseInPixel = response;
                    for(CFIndex j=i-pointsPerPixel+1;j<=i;j++) {
                        CFIndex tempIndex = j;
                        memOffset = memOffsetFromIndexes(&tempIndex, 1, &npts);
                        float temp = PSDependentVariableFloatValueAtMemOffsetForPart(theDependentVariable, componentIndex, memOffset, part);
                        if(minResponseInPixel<temp&&(j>=hCoordinateIndexMin))
                            minResponseInPixel = temp;
                        if(maxResponseInPixel>temp&&(j>=hCoordinateIndexMin))
                            maxResponseInPixel = temp;
                    }
                    vpos = verticalScale * (minResponseInPixel - responseMin) + verticalOffset;
                    if(vpos>vmax) vpos = vmax;
                    if(vpos<vmin) vpos = vmin;
                    /* PlotView Minimum point within inc. */
                    if(isfinite(hpos)&&isfinite(vpos)) {
                        points[pointIndex].x = hpos;
                        points[pointIndex++].y = vpos;
//                      CGPathAddLineToPoint(path, NULL,hpos,vpos);
                    }
                    else NSLog(@"infinite hpos or vpos found");
                  response = maxResponseInPixel;
                }
                vpos = verticalScale * (response - responseMin) + verticalOffset;
                if(vpos>vmax) vpos = vmax;
                if(vpos<vmin) vpos = vmin;
                if(isfinite(hpos)&&isfinite(vpos)) {
                    points[pointIndex].x = hpos;
                    points[pointIndex++].y = vpos;
//                    CGPathAddLineToPoint(path,NULL,hpos,vpos);
                }
                else NSLog(@"infinite hpos or vpos found");

            }
            hpos = horizontalScale * (hCoordinateIndexMax - hCoordinateIndexMin) + horizontalOffset;
            CFIndex tempIndex = hCoordinateIndexMax;
            memOffset = memOffsetFromIndexes(&tempIndex, 1, &npts);
            response = PSDependentVariableFloatValueAtMemOffsetForPart(theDependentVariable, componentIndex, memOffset, part);
            
            vpos = verticalScale * (response - responseMin) + verticalOffset;
            if(vpos>vmax) vpos = vmax;
            if(vpos<vmin) vpos = vmin;
            if(isfinite(hpos)&&isfinite(vpos)) {
                points[pointIndex].x = hpos;
                points[pointIndex++].y = vpos;
//                    CGPathAddLineToPoint(path,NULL,hpos,vpos);
            }
            else NSLog(@"infinite hpos or vpos found");
            
//            pointsCount = pointIndex - 1;
//            for(CFIndex pointIndex = 0;pointIndex<pointsCount;pointIndex++) {
//                alignToPixel(&points[pointIndex], context);
//            }
            CGPathAddLines(path,NULL,points,pointIndex-1);
            free(points);
        }
        else {
            double radius = 1;
            CGRect circleRect;
            circleRect.size.width = 2*radius;
            circleRect.size.height = 2*radius;
            if(isfinite(hpos)&&isfinite(vpos))  {
                circleRect.origin.x = hpos - radius;
                circleRect.origin.y = vpos - radius;
                CGPathAddEllipseInRect(path,NULL, circleRect);
            }
            else NSLog(@"infinite hpos or vpos found");
            
            for(CFIndex i=hCoordinateIndexMin;i<= hCoordinateIndexMax ;i++) {
                hpos = horizontalScale * (i - hCoordinateIndexMin) + horizontalOffset;
                CFIndex tempIndex = i;
                memOffset = memOffsetFromIndexes(&tempIndex, 1, &npts);
                response = PSDependentVariableFloatValueAtMemOffsetForPart(theDependentVariable,
                                                                           componentIndex,
                                                                           memOffset,
                                                                           part);
                
                vpos = verticalScale * (response - responseMin) + verticalOffset;
                if(vpos>vmax) vpos = vmax;
                if(vpos<vmin) vpos = vmin;
                if(isfinite(hpos)&&isfinite(vpos))  {
                    circleRect.origin.x = hpos - radius;
                    circleRect.origin.y = vpos - radius;
                    CGPathAddEllipseInRect(path,NULL, circleRect);
                }
                else NSLog(@"infinite hpos or vpos found");
            }
        }
    }
    CFRelease(theDependentVariable);
#ifdef PhySyDEBUG
    NSLog(@"Leaving PSQuartzDependentVariablePlot1DCreatePathForCrossSectionThroughFocus");
#endif
    
    // Maybe try CGPathAddLines instead?
//    CGPathApply(path, NULL, pathApplyfunction);
    return path;
}

void countPathElements(void * __nullable info,
                               const CGPathElement *  element)
{
    CFIndex *elementCount = (CFIndex *) info;
    *elementCount = *elementCount + 1;
}

void testFunction(PSDatasetRef theDataset,PSAxisRef coordinateAxis,PSAxisRef responseAxis,complexPart part,CGRect signalRect,CGContextRef context,CFErrorRef *error)
{
    printf("did nothing\n");
}


static bool PSQuartzDependentVariablePlot1DCrossSectionThroughFocus(PSDatasetRef theDataset,
                                                          PSAxisRef coordinateAxis,
                                                          PSAxisRef responseAxis,
                                                          complexPart part,
                                                          CGRect signalRect,
                                                          CGContextRef context,
                                                          CFErrorRef *error)
{
#ifdef PhySyDEBUG
    NSLog(@"Entering PSQuartzDependentVariablePlot1DCrossSectionThroughFocus");
#endif
    if(error) if(*error) return false;
    
    CGPathRef path = PSQuartzDependentVariablePlot1DCreatePathForCrossSectionThroughFocus(theDataset,
                                                                                          coordinateAxis,
                                                                                          responseAxis,
                                                                                          part,
                                                                                          signalRect,
                                                                                          context,
                                                                                          error);
    if(path) {
        
        CFIndex elementCount = 0;
        CGPathApply(path, &elementCount, countPathElements);

        CGContextSaveGState(context);
        CGContextAddPath(context, path);
        CFRelease(path);

        PSDependentVariableRef theDV = PSDatasetGetDependentVariableAtFocus(theDataset);
        PSPlotRef thePlot = PSDependentVariableGetPlot(theDV);
        PSDatumRef focus = PSDatasetGetFocus(theDataset);
        CFIndex componentIndex = PSDatumGetComponentIndex(focus);
        CFStringRef color = PSPlotGetComponentColorAtIndex(thePlot, componentIndex);

        bool darkMode = ![[NSAppearance currentAppearance].name isEqualToString: NSAppearanceNameAqua];
        if(CFStringCompare(color, kPSPlotColorBlack, 0)==kCFCompareEqualTo && darkMode) color = kPSPlotColorWhite;
        if(CFStringCompare(color, kPSPlotColorWhite, 0)==kCFCompareEqualTo && !darkMode) color = kPSPlotColorBlack;
    
        CGFloat red = 0, green = 0, blue = 0;
        getRGBValuesFromColorName(color, &red, &green, &blue);
        if(darkMode) {
            red  = 0.5*red+0.5;
            green = 0.5*green+0.5;
            blue  = 0.5*blue+0.5;
        }
        
        NSColor *foreColor = [NSColor colorWithRed:red green:green blue:blue alpha:1];
        
        CGContextSetStrokeColorWithColor(context, foreColor.CGColor);
        CGContextSetLineWidth(context,1);
        if(elementCount > 10000) CGContextSetLineWidth(context,.5);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextDrawPath(context, kCGPathStroke);
        CGContextRestoreGState(context);
        return true;
    }
   return false;
}




static bool PSQuartzDependentVariableVerticalPlot1DCrossSectionThroughFocus(PSDatasetRef theDataset,
                                                                  PSAxisRef coordinateAxis,
                                                                  PSAxisRef responseAxis,
                                                                  complexPart part,
                                                                  CGRect signalRect,
                                                                  CGContextRef context,
                                                                  CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(coordinateAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(responseAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    CGContextSaveGState(context);
    
    
    CGRect oldRect = signalRect;
    signalRect.origin.x = 0;
    signalRect.origin.y = 0;
    signalRect.size.width = oldRect.size.height;
    signalRect.size.height = oldRect.size.width;
    
    // Shift origin to top left corner, and then rotate clockwise 90 degrees
    double shiftX = oldRect.origin.x;
    double shiftY = oldRect.origin.y;
    
    CGContextTranslateCTM(context,shiftX,shiftY);
    CGContextRotateCTM(context,-M_PI/2);
    CGContextScaleCTM(context,-1,1);
    
    PSQuartzDependentVariablePlot1DCrossSectionThroughFocus(theDataset,
                                                  coordinateAxis,
                                                  responseAxis,
                                                  part,
                                                  signalRect,
                                                  context,
                                                  error);
    CGContextRestoreGState(context);
    if(error) if(*error) return false;
    return true;
}

static bool PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(PSDatasetRef theDataset,
                                                                    PSAxisRef coordinateAxis,
                                                                    PSAxisRef responseAxis,
                                                                    complexPart part,
                                                                    CGRect signalRect,
                                                                    CGContextRef context,
                                                                    CFErrorRef *error)
{
#ifdef PhySyDEBUG
    NSLog(@"Entering PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus");
#endif

    if(error) if(*error) return false;
    return PSQuartzDependentVariablePlot1DCrossSectionThroughFocus(theDataset, coordinateAxis, responseAxis, part, signalRect, context, error);
}

static bool PSQuartzDependentVariableDrawCrossHair(PSDatasetRef theDataset, PSAxisRef horizontalAxis, PSAxisRef verticalAxis, complexPart part,
                                         CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(horizontalAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(verticalAxis,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context,1.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    bool real = PSPlotGetReal(thePlot);
    bool imag = PSPlotGetImag(thePlot);
    
    CGRect rect;
    if(real&&imag) {
        if(part==kPSRealPart) rect = PSPlotGetLeftSignalRect(thePlot);
        else rect = PSPlotGetRightSignalRect(thePlot);
    }
    else rect = PSPlotGetSignalRect(thePlot);
    
    double hpos = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(horizontalAxis,
                                                                         PSDatumGetCoordinateAtIndex(focus, PSAxisGetIndex(horizontalAxis)),
                                                                         rect, error);
    double vpos;
    if(PSAxisGetIndex(verticalAxis) == -1) {
        PSScalarRef response = PSDatumCreateResponse(focus);
        PSScalarRef verticalCoordinate = PSScalarCreateByTakingComplexPart(response, part);
        vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis,
                                                                    verticalCoordinate,
                                                                    rect, error);
        CFRelease(response);
        CFRelease(verticalCoordinate);
    }
    else vpos = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis,
                                                                     PSDatumGetCoordinateAtIndex(focus, PSAxisGetIndex(verticalAxis)),
                                                                     rect, error);
    
    if(hpos>=rect.origin.x+rect.size.width) hpos = rect.origin.x+rect.size.width-1;
    if(vpos>=rect.origin.y+rect.size.height) vpos = rect.origin.y+rect.size.height-1;
    CGPoint cursor = {hpos,vpos};
    
    if(CGRectContainsPoint(rect, cursor)) {
        CGContextSetRGBFillColor(context,0,0,0,1);
        CGContextSetRGBStrokeColor(context,1,1,1,1);
        CGContextSetLineWidth(context,1.5);
        double side = 6;
        double gap = 1;
        CGContextBeginPath(context);
        CGContextMoveToPoint(context,hpos-side-gap,vpos+gap);
        CGContextAddLineToPoint(context,hpos-gap,vpos+gap);
        CGContextAddLineToPoint(context,hpos-gap,vpos+side+gap);
        CGContextAddLineToPoint(context,hpos+gap,vpos+side+gap);
        CGContextAddLineToPoint(context,hpos+gap,vpos+gap);
        CGContextAddLineToPoint(context,hpos+side+gap,vpos+gap);
        CGContextAddLineToPoint(context,hpos+side+gap,vpos-gap);
        CGContextAddLineToPoint(context,hpos+gap,vpos-gap);
        CGContextAddLineToPoint(context,hpos+gap,vpos-side-gap);
        CGContextAddLineToPoint(context,hpos-gap,vpos-side-gap);
        CGContextAddLineToPoint(context,hpos-gap,vpos-gap);
        CGContextAddLineToPoint(context,hpos-side-gap,vpos-gap);
        CGContextAddLineToPoint(context,hpos-side-gap,vpos+gap);
        CGContextDrawPath(context, kCGPathEOFillStroke);
    }
    
    CGContextRestoreGState(context);
    return true;
}

static void ReleaseIntensityPlotData(void *info, const void *data, size_t size)
{
    if(data) free((char *) data);
}

static CGDataProviderRef createRGBIntensityPlotViewSignalProvider(PSQuartzDependentVariableRef quartzDependentVariable,
                                                                  size_t bitsPerComponent,
                                                                  PSDatasetRef theDataset,
                                                                  complexPart part, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,NULL);
    
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex *npts = (CFIndex *) calloc(dimensionsCount, sizeof(CFIndex));
    for(CFIndex idim = 0; idim<dimensionsCount; idim++) {
        PSDimensionRef theDimension = PSDatasetGetDimensionAtIndex(theDataset, idim);
        npts[idim] = PSDimensionGetNpts(theDimension);
    }
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    bool horizontalReverse = PSAxisGetReverse(horizontalAxis);
    bool verticalReverse = PSAxisGetReverse(verticalAxis);

    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    
    CFIndex horizontalMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex horizontalMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    
    CFIndex verticalMin = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMinimum(verticalAxis));
    CFIndex verticalMax = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMaximum(verticalAxis));
    
    numberType elementType = PSQuantityGetElementType(theDependentVariable);
    size_t verticalSize = labs(verticalMax - verticalMin + 1)/quartzDependentVariable->verticalIncrement;
    size_t horizontalSize = labs(horizontalMax - horizontalMin + 1)/quartzDependentVariable->horizontalIncrement;
    
    PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);
    PSMutableScalarRef min = (PSMutableScalarRef) PSScalarCreateCopy(PSAxisGetMinimum(responseAxis));
    PSScalarConvertToUnit(min, responseUnit, error);
    double ymin = PSScalarDoubleValue(min);
    
    PSMutableScalarRef max = (PSMutableScalarRef) PSScalarCreateCopy(PSAxisGetMaximum(responseAxis));
    PSScalarConvertToUnit(max, responseUnit, error);
    double ymax = PSScalarDoubleValue(max);
    
    
    double abs_y_max = fabs(ymax);
    if(fabs(ymin)> abs_y_max) abs_y_max = fabs(ymin);
    
    double ySpan = ymax - ymin;
    
    float brightness = 0.93;
    float saturationDecay = 18;
    bool darkMode = ![[[NSAppearance currentAppearance] name] isEqual: NSAppearanceNameAqua];
    
    CGFloat red = 0, green = 0, blue = 0;
    CFStringRef color = PSPlotGetComponentColorAtIndex(thePlot, componentIndex);
    if(CFStringCompare(color, kPSPlotColorBlack, kCFCompareCaseInsensitive)==kCFCompareEqualTo) color = kPSPlotColorWhite;
    getRGBValuesFromColorName(color, &red, &green, &blue);
    __block float hue, saturation, value;
    RGBtoHSV(red, green, blue, &hue, &saturation, &value);
    
    PSImage2DPlotType plotType = PSPlotGetImage2DPlotTypeAtComponentIndex(thePlot, componentIndex);
    if(plotType == kPSImagePlotTypeSaturation && (red == blue) && (blue == green)) plotType = kPSImagePlotTypeSaturation;
    
    size_t imageSignalSize = horizontalSize*verticalSize*3;
    
    __block unsigned char *dataP = (unsigned char *) malloc(imageSignalSize*2);
    if(dataP == NULL) {
        free(npts);
        return NULL;
    }
    
    PSMutableIndexArrayRef indexValues = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    
    CFArrayRef components = PSDependentVariableGetComponents(theDependentVariable);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    if(PSPlotGetShowImage2DCombineRGB(thePlot)) {
        for(CFIndex cIndex = 0; cIndex<3; cIndex++) {
            CFMutableDataRef componentValues = (CFMutableDataRef) CFArrayGetValueAtIndex(components, cIndex);
            const UInt8 *responsePtr = CFDataGetMutableBytePtr(componentValues);
            dispatch_apply(verticalSize, queue,
                           ^(size_t vIndex) {
                               CFIndex threadIndexes[dimensionsCount];
                               for(CFIndex idim=0; idim<dimensionsCount; idim++)
                                   threadIndexes[idim] = PSIndexArrayGetValueAtIndex(indexValues, idim);
                               if(verticalReverse) {
                                   threadIndexes[verticalDimensionIndex] = verticalMin + vIndex*quartzDependentVariable->verticalIncrement;
                               }
                               else {
                                   threadIndexes[verticalDimensionIndex] = verticalMax - vIndex*quartzDependentVariable->verticalIncrement;
                               }
                               for(CFIndex hIndex = 0; hIndex<horizontalSize; hIndex ++) {
                                   if(horizontalReverse) {
                                       threadIndexes[horizontalDimensionIndex] = horizontalMax - hIndex*quartzDependentVariable->horizontalIncrement;
                                   }
                                   else {
                                       threadIndexes[horizontalDimensionIndex] = horizontalMin + hIndex*quartzDependentVariable->horizontalIncrement;
                                   }
                                   CFIndex memOffset = memOffsetFromIndexes(threadIndexes, dimensionsCount, npts);
                                   float response = fetchResponse(responsePtr, memOffset, elementType, part);
                                   float sy = (response - ymin)/ySpan;
                                   if(sy>1.) sy=1.;
                                   if(sy<0.) sy=0.;
                                   size_t offset = 3*(hIndex + vIndex*horizontalSize) + cIndex;
                                   dataP[offset] = (uint8_t) (sy*255);
                               }
                           }
                           );
        }
    }
    else {
        const UInt8 *responsePtr = CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(theDependentVariable,componentIndex));
        dispatch_apply(verticalSize, queue,
                       ^(size_t vIndex) {
                           CFIndex threadIndexes[dimensionsCount];
                           for(CFIndex idim=0; idim<dimensionsCount; idim++) threadIndexes[idim] = PSIndexArrayGetValueAtIndex(indexValues, idim);
                           if(verticalReverse) {
                               threadIndexes[verticalDimensionIndex] = verticalMin + vIndex*quartzDependentVariable->verticalIncrement;
                           }
                           else {
                               threadIndexes[verticalDimensionIndex] = verticalMax - vIndex*quartzDependentVariable->verticalIncrement;
                           }
                           
                           for(CFIndex hIndex = 0; hIndex<horizontalSize; hIndex ++) {
                               if(horizontalReverse) {
                                   threadIndexes[horizontalDimensionIndex] = horizontalMax - hIndex*quartzDependentVariable->horizontalIncrement;
                               }
                               else {
                                   threadIndexes[horizontalDimensionIndex] = horizontalMin + hIndex*quartzDependentVariable->horizontalIncrement;
                               }
                               float response = fetchResponse(responsePtr, memOffsetFromIndexes(threadIndexes, dimensionsCount, npts), elementType, part);
                               float sy = (response - ymin)/ySpan;
                               if(sy>1.) sy=1.;
                               if(sy<0.) sy=0.;
                               size_t offset = 3*(hIndex + vIndex*horizontalSize);
                               float red, green, blue;
                               
                               switch (plotType) {
                                   case kPSImagePlotTypeHue: {
                                       /*
                                        COLOUR colour = GetColour(sy,0,1);
                                        red = colour.r;
                                        green = colour.g;
                                        blue = colour.b;
                                        */
                                       float satLevel = 1.0-expf(-saturationDecay*fabsf(response)/abs_y_max);
                                       float darkness = brightness;
                                       if(darkMode) darkness = satLevel;
                                       HSVtoRGB( &red, &green, &blue, sy*360, satLevel, darkness);
                                       break;
                                   }
                                   case kPSImagePlotTypeSaturation:
                                       // HSVtoRGB( &red, &green, &blue, hue, 1-sy, value);
                                       red = green = blue = 1-sy;
                                       break;
                                   case kPSImagePlotTypeValue:
                                       HSVtoRGB( &red, &green, &blue, hue, saturation, sy);
                                       break;
                                   case kPSImagePlotTypeBicolor: {
                                       float satLevel = 1.0-expf(-saturationDecay*fabsf(response)/abs_y_max);
                                       if(response>0) {
                                           HSVtoRGB( &red, &green, &blue, hue,satLevel, brightness);
                                       }
                                       else {
                                           HSVtoRGB( &red, &green, &blue, ((int)(hue + 180))%360,satLevel, brightness);
                                       }
                                       break;
                                   }
                               }
                               dataP[offset++] = (uint8_t) (red*255);
                               dataP[offset++] = (uint8_t) (green*255);
                               dataP[offset] = (uint8_t) (blue*255);
                           }
                       }
                       );
    }
    
    CFRelease(indexValues);
    free(npts);
    PSPlotSetImageViewNeedsRegenerated(thePlot, false);
    if(PSPlotGetReal(thePlot)&&PSPlotGetImag(thePlot) && part==kPSRealPart) PSPlotSetImageViewNeedsRegenerated(thePlot, true);
    
    return CGDataProviderCreateWithData(NULL, dataP, imageSignalSize, ReleaseIntensityPlotData);
}

static bool PSQuartzDependentVariableImagePlot2DCrossSectionThroughFocus(PSQuartzDependentVariableRef quartzDependentVariable,
                                                               PSDatasetRef theDataset,
                                                               complexPart part,
                                                               CGRect signalRect,
                                                               CGContextRef context,
                                                               CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    CGContextSaveGState(context);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    bool viewNeedsRegenerated = PSPlotGetImageViewNeedsRegenerated(thePlot);
    
    CFIndex horizontalMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex horizontalMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    
    CFIndex horizontalNpts = PSDimensionGetNpts(horizontalDimension);
    CFIndex hSpan = (horizontalMax - horizontalMin + 1);
    
    if(hSpan > 4*horizontalNpts) {
        if(error) {
            CFStringRef desc = CFSTR("Plot limits exceeds 4 times dimension width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            kPSQuartzDependentVariableHorizontalWidthExceeded,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    CFIndex verticalNpts = PSDimensionGetNpts(verticalDimension);
    
    CFIndex verticalMin = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMinimum(verticalAxis));
    CFIndex verticalMax = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMaximum(verticalAxis));
    
    CFIndex vSpan = (verticalMax - verticalMin + 1);
    if(vSpan > 4*verticalNpts) {
        if(error) {
            CFStringRef desc = CFSTR("Plot limits exceeds 4 times dimension width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            kPSQuartzDependentVariableVerticalWidthExceeded,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    
    bool plotAll = PSPlotGetPlotAll(thePlot);
    // Reduce number of points displayed to around 1024 x 1024.   Also, need to make sure
    // that increment divdes into range with no remainder.
    quartzDependentVariable->horizontalIncrement = 1;
    quartzDependentVariable->verticalIncrement = 1;
    if(!plotAll) {
        while(hSpan/quartzDependentVariable->horizontalIncrement > 1024) quartzDependentVariable->horizontalIncrement++;
        while(quartzDependentVariable->horizontalIncrement>0 && hSpan%quartzDependentVariable->horizontalIncrement !=0) quartzDependentVariable->horizontalIncrement--;
        if(quartzDependentVariable->horizontalIncrement<1) quartzDependentVariable->horizontalIncrement =1;
        
        while(vSpan/quartzDependentVariable->verticalIncrement > 1024) quartzDependentVariable->verticalIncrement++;
        while(quartzDependentVariable->verticalIncrement>0&&vSpan%quartzDependentVariable->verticalIncrement !=0) quartzDependentVariable->verticalIncrement--;
    }
    size_t width = hSpan/quartzDependentVariable->horizontalIncrement;
    size_t height = vSpan;
    if(quartzDependentVariable->verticalIncrement) height /= quartzDependentVariable->verticalIncrement;
    
    size_t bitsPerComponent = 8, bitsPerPixel = 24;
    size_t bytesPerRow = 3* width;
    
    bool shouldInterpolate = true;
    CGContextSetInterpolationQuality(context,kCGInterpolationNone);
    
    PSScalarRef horizontalIncrement = PSDimensionGetIncrement(horizontalDimension);
    
    PSScalarRef temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(horizontalIncrement, 2.);
    double horizontalWidth = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(horizontalAxis, temp, signalRect, error)
    - PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(horizontalAxis, horizontalIncrement, signalRect, error);
    CFRelease(temp);
    horizontalWidth = fabs(horizontalWidth);
    
    PSScalarRef verticalIncrement = PSDimensionGetIncrement(verticalDimension);
    temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(verticalIncrement, 2.);
    double verticalWidth = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis, temp, signalRect, error)
    - PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis, verticalIncrement, signalRect, error);
    CFRelease(temp);
    verticalWidth = fabs(verticalWidth);
    
    CGRect expandedRect = signalRect;
    
    expandedRect.origin.x -= horizontalWidth/2;
    expandedRect.size.width +=horizontalWidth;
    
    expandedRect.origin.y -= verticalWidth/2;
    expandedRect.size.height +=verticalWidth;
    
    CGColorSpaceRef deviceRGB = CGColorSpaceCreateDeviceRGB();
    
    CFMutableArrayRef images = NULL;
    switch (part) {
        case kPSRealPart:
            images = quartzDependentVariable->realIntensityImages;
            break;
        case kPSImaginaryPart:
            images = quartzDependentVariable->imaginaryIntensityImages;
            break;
        case kPSMagnitudePart:
            images = quartzDependentVariable->magnitudeIntensityImages;
            break;
        case kPSArgumentPart:
            images = quartzDependentVariable->argumentIntensityImages;
            break;
    }
    
    CGImageRef image = (CGImageRef) CFArrayGetValueAtIndex(images, componentIndex);
    if(viewNeedsRegenerated || CFEqual(image, kCFNull)) {
        CGDataProviderRef  imageSignalProvider = createRGBIntensityPlotViewSignalProvider(quartzDependentVariable, bitsPerComponent, theDataset, part, error);
        if(imageSignalProvider == NULL) {
            if(deviceRGB) CFRelease(deviceRGB);
            return true;
        }
        
        image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, deviceRGB, (CGBitmapInfo) kCGImageAlphaNone, imageSignalProvider, NULL, shouldInterpolate, kCGRenderingIntentDefault);
        if(image) {
            CFArraySetValueAtIndex(images, componentIndex, image);
            CFRelease(image);
        }
        CGDataProviderRelease(imageSignalProvider);
        if(image == NULL) {
            if(deviceRGB) CFRelease(deviceRGB);
            return true;
        }
    }
    CGContextClipToRect(context, signalRect);
    
    if(PSPlotGetTransparent(thePlot)) CGContextSetAlpha(context, 0.75);
    else CGContextSetAlpha(context,1.0);
    CGContextDrawImage(context, expandedRect, image);
    
    if(deviceRGB) CFRelease(deviceRGB);
    CGContextRestoreGState(context);
    return true;
}

static bool PSQuartzDependentVariableContourPlot2DCrossSectionThroughFocus(PSQuartzDependentVariableRef quartzDependentVariable,
                                                                 PSDatasetRef theDataset,
                                                                 complexPart part,
                                                                 CGRect signalRect,
                                                                 CGContextRef context,
                                                                 CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    bool viewNeedsRegenerated = PSPlotGetContourViewNeedsRegenerated(thePlot);
    
    CGFloat red = 0, green = 0, blue = 0;
    CFStringRef color = PSPlotGetComponentColorAtIndex(thePlot, componentIndex);
    if(CFStringCompare(color, kPSPlotColorBlack, kCFCompareCaseInsensitive)==kCFCompareEqualTo) color = kPSPlotColorWhite;
    getRGBValuesFromColorName(color, &red, &green, &blue);
    float hue, saturation, value;
    RGBtoHSV(red, green, blue, &hue, &saturation, &value);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);

    
    PSScalarRef horizontalIncrement = PSDimensionGetIncrement(horizontalDimension);
    PSScalarRef temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(horizontalIncrement, 2.);
    double horizontalWidth = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(horizontalAxis, temp, signalRect, error)
    - PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(horizontalAxis, horizontalIncrement, signalRect, error);
    CFRelease(temp);
    
    PSScalarRef verticalIncrement = PSDimensionGetIncrement(verticalDimension);
    temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(verticalIncrement, 2.);
    double verticalWidth = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis, temp, signalRect, error)
    - PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis, verticalIncrement, signalRect, error);
    CFRelease(temp);
    
    
    CFIndex horizontalMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex horizontalMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    CFIndex horizontalNpts = PSDimensionGetNpts(horizontalDimension);
    CFIndex hSpan = (horizontalMax - horizontalMin + 1);
    
    if(hSpan > 4*horizontalNpts) {
        if(error) {
            CFStringRef desc = CFSTR("Plot limits exceeds 4 times dimension width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            kPSQuartzDependentVariableHorizontalWidthExceeded,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    CFIndex verticalNpts = PSDimensionGetNpts(verticalDimension);
    
    CFIndex verticalMin = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMinimum(verticalAxis));
    CFIndex verticalMax = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMaximum(verticalAxis));
    
    CFIndex vSpan = (verticalMax - verticalMin + 1);
    if(vSpan > 4*verticalNpts) {
        if(error) {
            CFStringRef desc = CFSTR("Plot limits exceeds 4 times dimension width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            kPSQuartzDependentVariableVerticalWidthExceeded,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    
    bool plotAll = PSPlotGetPlotAll(thePlot);
    // Reduce number of points displayed to around 256 x 256.   Also, need to make sure
    // that increment divdes into range with no remainder.
    quartzDependentVariable->horizontalIncrement = 1;
    quartzDependentVariable->verticalIncrement = 1;
    if(!plotAll) {
        while(hSpan/quartzDependentVariable->horizontalIncrement > 128) quartzDependentVariable->horizontalIncrement++;
        while(quartzDependentVariable->horizontalIncrement>0 && hSpan%quartzDependentVariable->horizontalIncrement !=0) quartzDependentVariable->horizontalIncrement--;
        if(quartzDependentVariable->horizontalIncrement<1) quartzDependentVariable->horizontalIncrement =1;
        
        while(vSpan/quartzDependentVariable->verticalIncrement > 128) quartzDependentVariable->verticalIncrement++;
        while(quartzDependentVariable->verticalIncrement>0&&vSpan%quartzDependentVariable->verticalIncrement !=0) quartzDependentVariable->verticalIncrement--;
    }
    size_t height = vSpan;
    if(quartzDependentVariable->verticalIncrement) height /= quartzDependentVariable->verticalIncrement;
    
    
    CGRect expandedRect = signalRect;
    expandedRect.size.width +=horizontalWidth;
    expandedRect.size.height +=verticalWidth;
    
    CGContextSaveGState(context);
    
    CGContextClipToRect(context, signalRect);
    
    bool success = true;
    double responseMin = PSScalarDoubleValueInUnit(PSAxisGetMinimum(responseAxis), responseUnit, &success);
    double responseMax = PSScalarDoubleValueInUnit(PSAxisGetMaximum(responseAxis), responseUnit, &success);
    CFIndex numberOfCuts = PSPlotGetNumberOfContourCuts(thePlot)+2;
    double responseInc = (responseMax - responseMin)/(numberOfCuts-1);
    
    PSPlotColoring coloring = PSPlotGetContourPlotColoring(thePlot);
    
    CGContextTranslateCTM(context, signalRect.origin.x, signalRect.origin.y);
    CGContextScaleCTM(context, signalRect.size.width/100., signalRect.size.height/100.);
    CGContextSetLineWidth(context,0.1);
    CGContextSetRGBStrokeColor(context,0,0,0,1);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetShouldAntialias(context,false);
    
    CFArrayRef paths = NULL;
    if(!viewNeedsRegenerated) {
        switch (part) {
            case kPSRealPart:
                paths = quartzDependentVariable->realContourPaths;
                break;
            case kPSImaginaryPart:
                paths = quartzDependentVariable->imaginaryContourPaths;
                break;
            case kPSMagnitudePart:
                paths = quartzDependentVariable->magnitudeContourPaths;
                break;
            case kPSArgumentPart:
                paths = quartzDependentVariable->argumentContourPaths;
                break;
        }
    }
    
    if(NULL==paths) {
        paths = PSQuartzDependentVariableCreatePathsForContourPlot2DCrossSectionThroughFocus(quartzDependentVariable,
                                                                                   theDataset,
                                                                                   part, error);
        switch (part) {
            case kPSRealPart: {
                if(quartzDependentVariable->realContourPaths) CFRelease(quartzDependentVariable->realContourPaths);
                quartzDependentVariable->realContourPaths = paths;
                break;
            }
            case kPSImaginaryPart: {
                if(quartzDependentVariable->imaginaryContourPaths) CFRelease(quartzDependentVariable->imaginaryContourPaths);
                quartzDependentVariable->imaginaryContourPaths = paths;
                break;
            }
            case kPSMagnitudePart: {
                if(quartzDependentVariable->magnitudeContourPaths) CFRelease(quartzDependentVariable->magnitudeContourPaths);
                quartzDependentVariable->magnitudeContourPaths = paths;
                break;
            }
            case kPSArgumentPart: {
                if(quartzDependentVariable->argumentContourPaths) CFRelease(quartzDependentVariable->argumentContourPaths);
                quartzDependentVariable->argumentContourPaths = paths;
                break;
            }
        }
        
        PSPlotSetContourViewNeedsRegenerated(thePlot, false);
        if(PSPlotGetReal(thePlot)&&PSPlotGetImag(thePlot) && part==kPSRealPart) PSPlotSetContourViewNeedsRegenerated(thePlot, true);
    }
    
    numberOfCuts = CFArrayGetCount(paths);
    responseInc = (responseMax - responseMin)/(numberOfCuts-1);
    CFIndex index = 0;
    for(float cut=responseMin;cut<=responseMax;cut+= responseInc) {
        if(coloring == kPSPlotColoringHue) {
            float red, green, blue;
            HSVtoRGB(&red,&green,&blue, (cut-responseMin)/(responseMax-responseMin)*360., 1.0, 1.0);
            if(cut>0) CGContextSetRGBStrokeColor(context,red,green,blue,1);
            CGContextSetRGBStrokeColor(context,red,green,blue,0.5);
            CGContextAddPath (context, CFArrayGetValueAtIndex(paths, index++));
            CGContextDrawPath(context, kCGPathStroke);
        }
        else if(coloring == kPSPlotColoringMonochrome) {
            float red, green, blue;
            HSVtoRGB( &red, &green, &blue,hue,saturation,value);
            if(cut>0) CGContextSetRGBStrokeColor(context,red,green,blue,1);
            CGContextSetRGBStrokeColor(context,red,green,blue,0.5);
            CGContextAddPath (context, CFArrayGetValueAtIndex(paths, index++));
        }
        else if(coloring == kPSPlotColoringBicolor) {
            float red, green, blue;
            if(cut>0) {
                HSVtoRGB( &red, &green, &blue,hue,saturation,value);
            }
            else {
                HSVtoRGB( &red, &green, &blue, ((int)(hue + 180))%360,saturation,value);
            }
            CGContextSetRGBStrokeColor(context,red,green,blue,1);
            CGContextAddPath (context, CFArrayGetValueAtIndex(paths, index++));
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    
    return true;
}

static bool PSQuartzDependentVariablePlot1D(PSDatasetRef theDataset, CGRect bounds, CGContextRef context, CFErrorRef *error)
{
#ifdef PhySyDEBUG
    NSLog(@"Entering PSQuartzDependentVariablePlot1D");
#endif

    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    CFIndex componentsCount = PSDependentVariableComponentsCount(theDependentVariable);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    
    PSPlotUpdateDisplayRects(thePlot, bounds);
    
    bool real = PSPlotGetReal(thePlot);
    bool imag = PSPlotGetImag(thePlot);
    bool magnitude = PSPlotGetMagnitude(thePlot);
    bool argument = PSPlotGetArgument(thePlot);
    
    NSColor *gridColor = [NSColor gridColor];
    CGContextSetStrokeColorWithColor(context, gridColor.CGColor);
    
    if(real && imag) {
        CGRect signalframe = PSPlotGetLeftSignalRect(thePlot);
        CGContextSetLineWidth(context,2.0);
        CGContextStrokeRect(context,signalframe);
        
        signalframe = PSPlotGetRightSignalRect(thePlot);
        CGContextSetLineWidth(context,2.0);
        CGContextStrokeRect(context,signalframe);
    }
    else {
        CGRect signalframe = PSPlotGetSignalRect(thePlot);
        CGContextSetLineWidth(context,2.0);
        CGContextStrokeRect(context,signalframe);
    }
    
    
    if(real && imag) {
        
        if(!PSQuartzDependentVariableDrawVerticalAxis(theDataset, responseAxis, PSPlotGetLeftAxisRect(thePlot), context, error)) return false;
        
        for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
            if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(theDataset, horizontalAxis, responseAxis, kPSRealPart, PSPlotGetLeftSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(theDataset, horizontalAxis, responseAxis, kPSImaginaryPart, PSPlotGetRightSignalRect(thePlot), context, error)) return false;
        }
        if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,responseAxis,kPSRealPart, context, error)) return false;
        if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,responseAxis,kPSImaginaryPart, context, error)) return false;
        
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, PSPlotGetBottomLeftRect(thePlot), context, error)) return false;
        
        if(PSPlotGetShowGrid(thePlot)) {
            if(!PSQuartzDependentVariableDrawHorizontalAxisGridLinesInSignalRect(theDataset, horizontalAxis, PSPlotGetLeftSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableDrawVerticalAxisGridLinesInSignalRect(theDataset, responseAxis, PSPlotGetLeftSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableDrawHorizontalAxisGridLinesInSignalRect(theDataset, horizontalAxis, PSPlotGetRightSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableDrawVerticalAxisGridLinesInSignalRect(theDataset, responseAxis, PSPlotGetRightSignalRect(thePlot), context, error)) return false;
        }
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, PSPlotGetBottomRightRect(thePlot), context, error)) return false;
    }
    else {
        
        if(!PSQuartzDependentVariableDrawVerticalAxis(theDataset, responseAxis, PSPlotGetLeftAxisRect(thePlot), context, error)) return false;
        if(real) {
            for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(theDataset, horizontalAxis, responseAxis, kPSRealPart, PSPlotGetSignalRect(thePlot),context, error)) return false;
                
            }
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,responseAxis,kPSRealPart, context, error)) return false;
        }
        if(imag) {
            for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(theDataset, horizontalAxis, responseAxis, kPSImaginaryPart, PSPlotGetSignalRect(thePlot), context, error)) return false;
            }
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,responseAxis,kPSImaginaryPart, context, error)) return false;
        }
        if(magnitude) {
            for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(theDataset, horizontalAxis, responseAxis, kPSMagnitudePart, PSPlotGetSignalRect(thePlot), context, error)) return false;
            }
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,responseAxis,kPSMagnitudePart, context, error)) return false;
        }
        if(argument) {
            for(CFIndex componentIndex = 0; componentIndex<componentsCount; componentIndex++) {
                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(theDataset, horizontalAxis, responseAxis, kPSArgumentPart, PSPlotGetSignalRect(thePlot), context, error)) return false;
            }
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,responseAxis,kPSArgumentPart, context, error)) return false;
        }
        
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, PSPlotGetBottomRect(thePlot), context, error)) return false;
        if(PSPlotGetShowGrid(thePlot)) {
            if(!PSQuartzDependentVariableDrawVerticalAxisGridLinesInSignalRect(theDataset, responseAxis, PSPlotGetSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableDrawHorizontalAxisGridLinesInSignalRect(theDataset, horizontalAxis, PSPlotGetSignalRect(thePlot), context, error)) return false;
        }
    }
    
#ifdef PhySyDEBUG
    NSLog(@"Leaving PSQuartzDependentVariablePlot1D");
#endif

    return true;
}

static bool PSQuartzDependentVariablePlot2D(PSQuartzDependentVariableRef quartzDependentVariable, PSDatasetRef theDataset, CGRect bounds, CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    
    PSPlotUpdateDisplayRects(thePlot, bounds);
    
    bool real = PSPlotGetReal(thePlot);
    bool imag = PSPlotGetImag(thePlot);
    bool magnitude = PSPlotGetMagnitude(thePlot);
    bool argument = PSPlotGetArgument(thePlot);
    NSColor *gridColor = [NSColor gridColor];
    CGContextSetStrokeColorWithColor(context, gridColor.CGColor);
    CGContextSetLineWidth(context,2.0);
    
    if(real && imag) {
        CGRect signalframe = PSPlotGetLeftSignalRect(thePlot);
        CGContextStrokeRect(context,signalframe);
        
        signalframe = PSPlotGetRightSignalRect(thePlot);
        CGContextStrokeRect(context,signalframe);
    }
    else {
        CGRect signalframe = PSPlotGetSignalRect(thePlot);
        CGContextStrokeRect(context,signalframe);
    }
    
    if(real && imag) {
        if(PSPlotGetShowImagePlot(thePlot)) {
            if(!PSQuartzDependentVariableImagePlot2DCrossSectionThroughFocus(quartzDependentVariable,
                                                                   theDataset, kPSRealPart,
                                                                   PSPlotGetLeftSignalRect(thePlot),
                                                                   context, error)) return false;
            
            if(!PSQuartzDependentVariableImagePlot2DCrossSectionThroughFocus(quartzDependentVariable,
                                                                   theDataset, kPSImaginaryPart,
                                                                   PSPlotGetRightSignalRect(thePlot),
                                                                   context, error)) return false;
            
        }
        if(PSPlotGetShowContourPlot(thePlot)) {
            if(!PSQuartzDependentVariableContourPlot2DCrossSectionThroughFocus(quartzDependentVariable,
                                                                     theDataset, kPSRealPart,
                                                                     PSPlotGetLeftSignalRect(thePlot),
                                                                     context, error)) return false;
            
            if(!PSQuartzDependentVariableContourPlot2DCrossSectionThroughFocus(quartzDependentVariable,
                                                                     theDataset, kPSImaginaryPart,
                                                                     PSPlotGetRightSignalRect(thePlot),
                                                                     context, error)) return false;
        }
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, PSPlotGetBottomLeftRect(thePlot), context, error)) return false;
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, PSPlotGetBottomRightRect(thePlot), context, error)) return false;
        
        if(!PSQuartzDependentVariableDrawVerticalAxis(theDataset, verticalAxis, PSPlotGetLeftAxisRect(thePlot), context, error)) return false;
        
        
        if(PSPlotGetShowGrid(thePlot)) {
            if(!PSQuartzDependentVariableDrawHorizontalAxisGridLinesInSignalRect(theDataset, horizontalAxis, PSPlotGetLeftSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableDrawVerticalAxisGridLinesInSignalRect(theDataset, verticalAxis, PSPlotGetLeftSignalRect(thePlot), context, error)) return false;
            
            if(!PSQuartzDependentVariableDrawHorizontalAxisGridLinesInSignalRect(theDataset, horizontalAxis, PSPlotGetRightSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableDrawVerticalAxisGridLinesInSignalRect(theDataset, verticalAxis, PSPlotGetRightSignalRect(thePlot), context, error)) return false;
        }
        
        if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,verticalAxis,kPSRealPart, context, error)) return false;
        if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,verticalAxis,kPSImaginaryPart, context, error)) return false;
        
        PSDatasetRef horizontalCrossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
        PSDependentVariableRef crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(horizontalCrossSection, dependentVariableIndex);
        CFIndex componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
        PSAxisRef coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
        if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, horizontalAxis, error)) return false;
        PSDatumSetDependentVariableIndex(PSDatasetGetFocus(horizontalCrossSection), dependentVariableIndex);
        for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
            PSDatumSetComponentIndex(PSDatasetGetFocus(horizontalCrossSection), componentCSIndex);
            if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(horizontalCrossSection,
                                                                        coordinateAxis,
                                                                        responseAxis,
                                                                        kPSRealPart,
                                                                        PSPlotGetTopLeftRect(thePlot),
                                                                        context, error)) return false;
            
            if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(horizontalCrossSection,
                                                                        coordinateAxis,
                                                                        responseAxis,
                                                                        kPSImaginaryPart,
                                                                        PSPlotGetTopRightRect(thePlot),
                                                                        context, error)) return false;
        }
        
        
        PSDatasetRef verticalCrossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
        crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(verticalCrossSection, dependentVariableIndex);
        componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
        
        coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
        if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, verticalAxis, error)) return false;
        PSDatumSetDependentVariableIndex(PSDatasetGetFocus(verticalCrossSection), dependentVariableIndex);
        for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
            PSDatumSetComponentIndex(PSDatasetGetFocus(verticalCrossSection), componentCSIndex);

            if(!PSQuartzDependentVariableVerticalPlot1DCrossSectionThroughFocus(verticalCrossSection,
                                                                      coordinateAxis,
                                                                      responseAxis,
                                                                      kPSRealPart,
                                                                      PSPlotGetMiddleRect(thePlot),
                                                                      context, error)) return false;
            
            if(!PSQuartzDependentVariableVerticalPlot1DCrossSectionThroughFocus(verticalCrossSection,
                                                                      coordinateAxis,
                                                                      responseAxis,
                                                                      kPSImaginaryPart,
                                                                      PSPlotGetRightRect(thePlot),
                                                                      context, error)) return false;
        }
        
    }
    else {
        if(real) {
            if(PSPlotGetShowImagePlot(thePlot))
                if(!PSQuartzDependentVariableImagePlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSRealPart,
                                                                       PSPlotGetSignalRect(thePlot),
                                                                       context, error)) return false;
            
            if(PSPlotGetShowContourPlot(thePlot))
                if(!PSQuartzDependentVariableContourPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSRealPart,
                                                                         PSPlotGetSignalRect(thePlot),
                                                                         context, error)) return false;
            
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,verticalAxis,kPSRealPart, context, error)) return false;
            
            PSDatasetRef horizontalCrossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
            PSDependentVariableRef crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(horizontalCrossSection, dependentVariableIndex);
            CFIndex componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            PSAxisRef coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, horizontalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(horizontalCrossSection), dependentVariableIndex);
            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(horizontalCrossSection), componentCSIndex);
                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(horizontalCrossSection,
                                                                            coordinateAxis,
                                                                            responseAxis,
                                                                            kPSRealPart,
                                                                            PSPlotGetTopRect(thePlot),
                                                                            context, error)) return false;
            }
            
            
            PSDatasetRef verticalCrossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
            crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(verticalCrossSection, dependentVariableIndex);
            componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, verticalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(verticalCrossSection), dependentVariableIndex);

            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(verticalCrossSection), componentCSIndex);
                if(!PSQuartzDependentVariableVerticalPlot1DCrossSectionThroughFocus(verticalCrossSection,
                                                                          coordinateAxis,
                                                                          responseAxis,
                                                                          kPSRealPart,
                                                                          PSPlotGetRightRect(thePlot),
                                                                          context, error)) return false;
            }
            
        }
        
        if(imag) {
            if(PSPlotGetShowImagePlot(thePlot))
                if(!PSQuartzDependentVariableImagePlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSImaginaryPart,
                                                                       PSPlotGetSignalRect(thePlot),
                                                                       context, error)) return false;
            if(PSPlotGetShowContourPlot(thePlot))
                if(!PSQuartzDependentVariableContourPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSImaginaryPart,
                                                                         PSPlotGetSignalRect(thePlot),
                                                                         context, error)) return false;
            
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,verticalAxis,kPSImaginaryPart, context, error)) return false;
            
            PSDatasetRef horizontalCrossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
            PSDependentVariableRef crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(horizontalCrossSection, dependentVariableIndex);
            CFIndex componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            PSAxisRef coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, horizontalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(horizontalCrossSection), dependentVariableIndex);
            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(horizontalCrossSection), componentCSIndex);

                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(horizontalCrossSection,
                                                                            coordinateAxis,
                                                                            responseAxis,
                                                                            kPSImaginaryPart,
                                                                            PSPlotGetTopRect(thePlot),
                                                                            context, error)) return false;
            }
            PSDatasetRef verticalCrossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
            crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(verticalCrossSection, dependentVariableIndex);
            componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, verticalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(verticalCrossSection), dependentVariableIndex);
            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(verticalCrossSection), componentCSIndex);

                if(!PSQuartzDependentVariableVerticalPlot1DCrossSectionThroughFocus(verticalCrossSection,
                                                                          coordinateAxis,
                                                                          responseAxis,
                                                                          kPSImaginaryPart,
                                                                          PSPlotGetRightRect(thePlot),
                                                                          context, error)) return false;
            }
        }
        
        if(magnitude) {
            if(PSPlotGetShowImagePlot(thePlot))
                if(!PSQuartzDependentVariableImagePlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSMagnitudePart,
                                                                       PSPlotGetSignalRect(thePlot),
                                                                       context, error)) return false;
            if(PSPlotGetShowContourPlot(thePlot))
                if(!PSQuartzDependentVariableContourPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSMagnitudePart,
                                                                         PSPlotGetSignalRect(thePlot),
                                                                         context, error)) return false;
            
            
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,verticalAxis,kPSMagnitudePart, context, error)) return false;
            
            PSDatasetRef horizontalCrossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
            
            PSDependentVariableRef crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(horizontalCrossSection, dependentVariableIndex);
            CFIndex componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            PSAxisRef coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, horizontalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(horizontalCrossSection), dependentVariableIndex);
            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(horizontalCrossSection), componentCSIndex);

                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(horizontalCrossSection,
                                                                            coordinateAxis,
                                                                            responseAxis,
                                                                            kPSMagnitudePart,
                                                                            PSPlotGetTopRect(thePlot),
                                                                            context, error)) return false;
            }
            
            PSDatasetRef verticalCrossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
            crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(verticalCrossSection, dependentVariableIndex);
            componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, verticalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(verticalCrossSection), dependentVariableIndex);
            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(verticalCrossSection), componentCSIndex);

                if(!PSQuartzDependentVariableVerticalPlot1DCrossSectionThroughFocus(verticalCrossSection,
                                                                          coordinateAxis,
                                                                          responseAxis,
                                                                          kPSMagnitudePart,
                                                                          PSPlotGetRightRect(thePlot),
                                                                          context, error)) return false;
            }
        }
        
        if(argument) {
            if(PSPlotGetShowImagePlot(thePlot))
                if(!PSQuartzDependentVariableImagePlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSArgumentPart,
                                                                       PSPlotGetSignalRect(thePlot),
                                                                       context, error)) return false;
            if(PSPlotGetShowContourPlot(thePlot))
                if(!PSQuartzDependentVariableContourPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSArgumentPart,
                                                                         PSPlotGetSignalRect(thePlot),
                                                                         context, error)) return false;
            
            if(!PSQuartzDependentVariableDrawCrossHair(theDataset,horizontalAxis,verticalAxis,kPSArgumentPart, context, error)) return false;
            
            PSDatasetRef horizontalCrossSection = PSDatasetGet1DCrossSectionAlongHorizontal(theDataset);
            
            PSDependentVariableRef crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(horizontalCrossSection, dependentVariableIndex);
            CFIndex componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            PSAxisRef coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, horizontalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(horizontalCrossSection), dependentVariableIndex);
            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(horizontalCrossSection), componentCSIndex);

                if(!PSQuartzDependentVariableHorizontalPlot1DCrossSectionThroughFocus(horizontalCrossSection,
                                                                            coordinateAxis,
                                                                            responseAxis,
                                                                            kPSArgumentPart,
                                                                            PSPlotGetTopRect(thePlot),
                                                                            context, error))return false;
            }
            
            PSDatasetRef verticalCrossSection = PSDatasetGet1DCrossSectionAlongVertical(theDataset);
            crossSectionDependentVariable = PSDatasetGetDependentVariableAtIndex(verticalCrossSection, dependentVariableIndex);
            componentsCSCount = PSDependentVariableComponentsCount(crossSectionDependentVariable);
            coordinateAxis = PSPlotHorizontalAxis(PSDependentVariableGetPlot(crossSectionDependentVariable));
            
            if(!PSAxisTakeParametersFromOtherAxis(coordinateAxis, verticalAxis, error)) return false;
            PSDatumSetDependentVariableIndex(PSDatasetGetFocus(verticalCrossSection), dependentVariableIndex);
            for(CFIndex componentCSIndex = 0; componentCSIndex<componentsCSCount; componentCSIndex++) {
                PSDatumSetComponentIndex(PSDatasetGetFocus(verticalCrossSection), componentCSIndex);

                if(!PSQuartzDependentVariableVerticalPlot1DCrossSectionThroughFocus(verticalCrossSection,
                                                                          coordinateAxis,
                                                                          responseAxis,
                                                                          kPSArgumentPart,
                                                                          PSPlotGetRightRect(thePlot),
                                                                          context, error)) return false;
            }
        }
        
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, PSPlotGetBottomRect(thePlot), context, error)) return false;
        if(!PSQuartzDependentVariableDrawVerticalAxis(theDataset, verticalAxis, PSPlotGetLeftAxisRect(thePlot), context, error)) return false;
        
        if(PSPlotGetShowGrid(thePlot)) {
            if(!PSQuartzDependentVariableDrawHorizontalAxisGridLinesInSignalRect(theDataset, horizontalAxis, PSPlotGetSignalRect(thePlot), context, error)) return false;
            if(!PSQuartzDependentVariableDrawVerticalAxisGridLinesInSignalRect(theDataset, verticalAxis, PSPlotGetSignalRect(thePlot), context, error)) return false;
        }
    }
    return true;
}

bool PSQuartzDependentVariablePlot(PSQuartzDependentVariableRef quartzDependentVariable,
                         PSDatasetRef theDataset,
                         CGRect bounds,
                         CGContextRef context,
                         CFErrorRef *error)
{
#ifdef PhySyDEBUG
    NSLog(@"Entering PSQuartzDependentVariablePlot");
#endif

    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    
    bool success = false;
    if(PSPlotGetDimensionsDisplayedCount(thePlot)==1 || PSDimensionHasNonUniformGrid(horizontalDimension)
       || PSDimensionHasNonUniformGrid(verticalDimension)) success = PSQuartzDependentVariablePlot1D(theDataset, bounds, context, error);
    else success = PSQuartzDependentVariablePlot2D(quartzDependentVariable, theDataset, bounds, context, error);

#ifdef PhySyDEBUG
    NSLog(@"Leaving PSQuartzDependentVariablePlot");
#endif
    return success;
}

static CFArrayRef PSQuartzDependentVariableCreatePathsForContourPlot2DCrossSectionThroughFocus(PSQuartzDependentVariableRef quartzDependentVariable,
                                                                                     PSDatasetRef theDataset,
                                                                                     complexPart part,
                                                                                     CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,NULL);
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,NULL);
    
    CGRect signalRect;
    signalRect.origin.x = 0;
    signalRect.origin.y = 0;
    signalRect.size.width = 100;
    signalRect.size.height = 100;
    
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);

    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    bool horizontalReverse = PSAxisGetReverse(horizontalAxis);
    bool verticalReverse = PSAxisGetReverse(verticalAxis);

    PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);

    PSScalarRef horizontalIncrement = PSDimensionGetIncrement(horizontalDimension);
    PSScalarRef temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(horizontalIncrement, 2.);
    double horizontalWidth = PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(horizontalAxis, temp, signalRect, error)
    - PSAxisHorizontalViewCoordinateFromAxisCoordinateInRect(horizontalAxis, horizontalIncrement, signalRect, error);
    CFRelease(temp);
    
    PSScalarRef verticalIncrement = PSDimensionGetIncrement(verticalDimension);
    temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(verticalIncrement, 2.);
    double verticalWidth = PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis, temp, signalRect, error)
    - PSAxisVerticalViewCoordinateFromAxisCoordinateInRect(verticalAxis, verticalIncrement, signalRect, error);
    CFRelease(temp);
    
    CGRect expandedRect = signalRect;
    expandedRect.size.width +=fabs(horizontalWidth);
    expandedRect.size.height +=fabs(verticalWidth);
    
    
    CFIndex hCoordinateIndexMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex hCoordinateIndexMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    
    CFIndex vCoordinateIndexMin = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMinimum(verticalAxis));
    CFIndex vCoordinateIndexMax = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMaximum(verticalAxis));
    
    bool success = true;
    
    double responseMin = PSScalarDoubleValueInUnit(PSAxisGetMinimum(responseAxis), responseUnit, &success);
    double responseMax = PSScalarDoubleValueInUnit(PSAxisGetMaximum(responseAxis), responseUnit, &success);
    CFIndex numberOfCuts = PSPlotGetNumberOfContourCuts(thePlot)+2;
    double responseInc = (responseMax - responseMin)/(numberOfCuts-1);
    if(responseInc==0.0) numberOfCuts = 1;
    
    bool plotAll = PSPlotGetPlotAll(thePlot);
    
    // Reduce number of points displayed to around 1024 x 1024.   Also, need to make sure
    // that increment divdes into range with no remainder.
    quartzDependentVariable->horizontalIncrement = 1;
    if(!plotAll) {
        while((hCoordinateIndexMax - hCoordinateIndexMin + 1)/quartzDependentVariable->horizontalIncrement > 1024) quartzDependentVariable->horizontalIncrement++;
        while(quartzDependentVariable->horizontalIncrement>0 && (hCoordinateIndexMax - hCoordinateIndexMin + 1)%quartzDependentVariable->horizontalIncrement !=0) quartzDependentVariable->horizontalIncrement--;
        if(quartzDependentVariable->horizontalIncrement<1) quartzDependentVariable->horizontalIncrement =1;
        
        while((vCoordinateIndexMax - vCoordinateIndexMin + 1)/quartzDependentVariable->verticalIncrement > 1024) quartzDependentVariable->verticalIncrement++;
        while(quartzDependentVariable->verticalIncrement>0 && (vCoordinateIndexMax - vCoordinateIndexMin + 1)%quartzDependentVariable->verticalIncrement !=0) quartzDependentVariable->verticalIncrement--;
        if(quartzDependentVariable->verticalIncrement<1) quartzDependentVariable->verticalIncrement =1;
    }
    
    float hstep = (float) (expandedRect.size.width)/(float) (hCoordinateIndexMax-hCoordinateIndexMin+1);
    float vstep = (float) (expandedRect.size.height)/(float)  (vCoordinateIndexMax - vCoordinateIndexMin+1);
    float hposOffset = expandedRect.origin.x;
    float vposOffset = expandedRect.origin.y;

    if(horizontalReverse) {
        hstep = -hstep;
        hposOffset += expandedRect.size.width;
    }
    
    if(verticalReverse) {
        vstep = -vstep;
        vposOffset += expandedRect.size.height;
    }
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    
    PSIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);

    numberType elementType = PSQuantityGetElementType(theDependentVariable);
    
    CFMutableArrayRef paths = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    for(CFIndex cutIndex = 0; cutIndex<numberOfCuts; cutIndex++) {
        CGMutablePathRef path = CGPathCreateMutable();
        CFArrayAppendValue(paths, path);
        CFRelease(path);
    }
    
    UInt8 *responses = CFDataGetMutableBytePtr(PSDependentVariableGetComponentAtIndex(theDependentVariable,componentIndex));
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(numberOfCuts, queue,
                   ^(size_t cutIndex) {
                       CGMutablePathRef path = (CGMutablePathRef) CFArrayGetValueAtIndex(paths, cutIndex);
                       PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutableCopy(focusIndexes);
                       
                       double cut = responseMin + cutIndex*responseInc;
                       
                       for(CFIndex vIndex = vCoordinateIndexMin; vIndex<=vCoordinateIndexMax; vIndex += quartzDependentVariable->verticalIncrement) {
                           for(CFIndex hIndex = hCoordinateIndexMin; hIndex<=hCoordinateIndexMax; hIndex += quartzDependentVariable->horizontalIncrement) {
                               
                               PSIndexArraySetValueAtIndex(indexValues, horizontalDimensionIndex, hIndex);
                               PSIndexArraySetValueAtIndex(indexValues, verticalDimensionIndex, vIndex);
                               CFIndex memOffset1 = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
                               float response1 = fetchResponse(responses, memOffset1, elementType, part);
                               
                               PSIndexArraySetValueAtIndex(indexValues, horizontalDimensionIndex, hIndex+quartzDependentVariable->horizontalIncrement);
                               CFIndex memOffset2 = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
                               float response2 = fetchResponse(responses, memOffset2, elementType, part);
                               
                               PSIndexArraySetValueAtIndex(indexValues, verticalDimensionIndex, vIndex+quartzDependentVariable->verticalIncrement);
                               CFIndex memOffset4 = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
                               float response4 = fetchResponse(responses, memOffset4, elementType, part);
                               
                               PSIndexArraySetValueAtIndex(indexValues, horizontalDimensionIndex, hIndex);
                               CFIndex memOffset3 = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
                               float response3 = fetchResponse(responses, memOffset3, elementType, part);
                               
                               bool A, B, C, D;
                               A = B = C = D = false;
                               float hposA = hposOffset;
                               float vposA = vposOffset;
                               float hposB = hposOffset;
                               float vposB = vposOffset;
                               float hposC = hposOffset;
                               float vposC = vposOffset;
                               float hposD = hposOffset;
                               float vposD = vposOffset;
                               
                               if(response1!=response2) {
                                   float min=response1;
                                   float max=response2;
                                   if(response1>response2) {
                                       max=response1;
                                       min=response2;
                                   }
                                   if((cut<=max)&&(cut>=min)) {
                                       A = true;
                                       hposA += hstep * ((cut - response1)/(response2-response1) + hIndex - hCoordinateIndexMin);
                                       vposA += vstep * (vIndex - vCoordinateIndexMin);
                                   }
                               }
                               if(response1!=response3) {
                                   float min=response1;
                                   float max=response3;
                                   if(response1>response3) {
                                       max=response1;
                                       min=response3;
                                   }
                                   if((cut<=max)&&(cut>=min)) {
                                       B = true;
                                       hposB += (float) hstep * (hIndex - hCoordinateIndexMin);
                                       vposB += vstep * ((cut - response1)/(response3-response1) + vIndex - vCoordinateIndexMin);
                                   }
                               }
                               if(response3!=response4) {
                                   float min=response3;
                                   float max=response4;
                                   if(response3>response4) {
                                       max=response3;
                                       min=response4;
                                   }
                                   if((cut<=max)&&(cut>=min)) {
                                       C = true;
                                       hposC += hstep * ((cut - response3)/(response4-response3) + hIndex - hCoordinateIndexMin);
                                       vposC += (float) vstep * (vIndex - vCoordinateIndexMin + 1);
                                   }
                               }
                               if(response2!=response4) {
                                   float min=response2;
                                   float max=response4;
                                   if(response2>response4) {
                                       max=response2;
                                       min=response4;
                                   }
                                   if((cut<=max)&&(cut>=min)) {
                                       D = true;
                                       hposD += (float) hstep * (hIndex - hCoordinateIndexMin + 1);
                                       vposD +=  vstep * ((cut - response2)/(response4-response2) + vIndex - vCoordinateIndexMin);
                                   }
                               }
                               
                               if(A&&B&&C&&D) {
                                   /* Find the shortest length and make sure all points are connected */
                                   float AB = (hposA-hposB)*(hposA-hposB) + (vposA-vposB)*(vposA-vposB);
                                   float DA = (hposA-hposD)*(hposA-hposD) + (vposA-vposD)*(vposA-vposD);
                                   float BC = (hposB-hposC)*(hposB-hposC) + (vposB-vposC)*(vposB-vposC);
                                   float CD = (hposC-hposD)*(hposC-hposD) + (vposC-vposD)*(vposC-vposD);
                                   if(AB<DA){
                                       if(AB<BC) {
                                           CGPathMoveToPoint(path, NULL, hposA,vposA);
                                           CGPathAddLineToPoint(path, NULL,hposB,vposB);
                                           CGPathMoveToPoint(path, NULL, hposC,vposC);
                                           CGPathAddLineToPoint(path, NULL,hposD,vposD);
                                       }
                                       else {
                                           CGPathMoveToPoint(path, NULL, hposB,vposB);
                                           CGPathAddLineToPoint(path, NULL,hposC,vposC);
                                           CGPathMoveToPoint(path, NULL, hposA,vposA);
                                           CGPathAddLineToPoint(path, NULL,hposD,vposD);
                                       }
                                   }
                                   else {
                                       if(CD<DA) {
                                           CGPathMoveToPoint(path, NULL, hposC,vposC);
                                           CGPathAddLineToPoint(path, NULL,hposD,vposD);
                                           CGPathMoveToPoint(path, NULL, hposA,vposA);
                                           CGPathAddLineToPoint(path, NULL,hposB,vposB);
                                       }
                                       else {
                                           CGPathMoveToPoint(path, NULL, hposA,vposA);
                                           CGPathAddLineToPoint(path, NULL,hposD,vposD);
                                           CGPathMoveToPoint(path, NULL, hposB,vposB);
                                           CGPathAddLineToPoint(path, NULL,hposC,vposC);
                                       }
                                   }
                               }
                               else if((A&&B)||(A&&C)||(A&&D)||(B&&C)||(B&&D)||(C&&D)) {
                                   if(A&&B) {
                                       CGPathMoveToPoint(path, NULL,hposA,vposA);
                                       CGPathAddLineToPoint(path, NULL,hposB,vposB);
                                   }
                                   else if(A&&C) {
                                       CGPathMoveToPoint(path, NULL,hposA,vposA);
                                       CGPathAddLineToPoint(path, NULL,hposC,vposC);
                                   }
                                   else if(A&&D) {
                                       CGPathMoveToPoint(path, NULL,hposA,vposA);
                                       CGPathAddLineToPoint(path, NULL,hposD,vposD);
                                   }
                                   else if(B&&C) {
                                       CGPathMoveToPoint(path, NULL,hposB,vposB);
                                       CGPathAddLineToPoint(path, NULL,hposC,vposC);
                                   }
                                   else if(B&&D) {
                                       CGPathMoveToPoint(path, NULL,hposB,vposB);
                                       CGPathAddLineToPoint(path, NULL,hposD,vposD);
                                   }
                                   else if(C&&D) {
                                       CGPathMoveToPoint(path, NULL,hposC,vposC);
                                       CGPathAddLineToPoint(path, NULL,hposD,vposD);
                                   }
                               }
                           }
                       }
                       CFRelease(indexValues);
                   });
    
    CFRelease(focusIndexes);
    return paths;
}



static bool PSQuartzDependentVariableStackPlot2D(PSQuartzDependentVariableRef quartzDependentVariable,
                                       PSDatasetRef theDataset,
                                       CGRect bounds,
                                       double widthPercent,
                                       double heightPercent,
                                       bool rightToLeft,
                                       CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);

    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    
    bool horizontalAxisReverse = PSAxisGetReverse(horizontalAxis);
    bool verticalAxisReverse = PSAxisGetReverse(verticalAxis);
    
    bool fliphorizonalAxis = rightToLeft;
    if(horizontalAxisReverse) fliphorizonalAxis = !rightToLeft;

    double responseMin = PSScalarDoubleValue(PSAxisGetMinimum(responseAxis));
    double responseMax = PSScalarDoubleValue(PSAxisGetMaximum(responseAxis));
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    
    PSPlotUpdateDisplayRects(thePlot, bounds);
    
    bool real = PSPlotGetReal(thePlot);
    bool imag = PSPlotGetImag(thePlot);
    bool magnitude = PSPlotGetMagnitude(thePlot);
    bool argument = PSPlotGetArgument(thePlot);
    float red = 0;
    float green = 0;
    float blue = 1;
    NSAppearance *currentAppearance = [NSAppearance currentAppearance];
    if (@available(*, macOS 10.14)) {
        if(![currentAppearance.name isEqualToString: NSAppearanceNameAqua]) {
            red  = 0.5*red+0.5;
            green = 0.5*green+0.5;
            blue  = 0.5*blue+0.5;
        }
    }
    
    if(real && imag) {
        CGRect signalframe = PSPlotGetLeftSignalRect(thePlot);
        CGContextSetLineWidth(context,2.0);
        CGContextSetRGBStrokeColor(context,red,green,blue,0.1);
        CGContextStrokeRect(context,signalframe);
        
        signalframe = PSPlotGetRightSignalRect(thePlot);
        CGContextSetLineWidth(context,2.0);
        CGContextSetRGBStrokeColor(context,red,green,blue,0.1);
        CGContextStrokeRect(context,signalframe);
    }
    else {
        CGRect signalframe = PSPlotGetSignalRect(thePlot);
        CGContextSetLineWidth(context,2.0);
        CGContextSetRGBStrokeColor(context,red,green,blue,0.1);
        CGContextStrokeRect(context,signalframe);
    }
    
    
    
    if(real && imag) {
        
        if(!PSQuartzDependentVariableStackPlot2DCrossSectionThroughFocus(quartzDependentVariable,
                                                               theDataset, kPSRealPart,widthPercent,heightPercent,rightToLeft,
                                                               PSPlotGetLeftSignalRect(thePlot),
                                                               context, error)) return false;
        
        if(!PSQuartzDependentVariableStackPlot2DCrossSectionThroughFocus(quartzDependentVariable,
                                                               theDataset, kPSImaginaryPart,widthPercent,heightPercent,rightToLeft,
                                                               PSPlotGetRightSignalRect(thePlot),
                                                               context, error)) return false;
        
        CGRect bottomLeftRect = PSPlotGetBottomLeftRect(thePlot);
        if(fliphorizonalAxis) {
            bottomLeftRect.origin.x +=  - (bottomLeftRect.size.width*widthPercent/100. - bottomLeftRect.size.width);
        }
        bottomLeftRect.size.width *= widthPercent/100.;
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, bottomLeftRect, context, error)) return false;
        
        CGRect bottomRightRect = PSPlotGetBottomRightRect(thePlot);
        if((!rightToLeft&&horizontalAxisReverse&&!verticalAxisReverse) || (rightToLeft&&!horizontalAxisReverse&&verticalAxisReverse)) {
            bottomRightRect.origin.x +=  - (bottomRightRect.size.width*widthPercent/100. - bottomRightRect.size.width);
        }
        bottomRightRect.size.width *= widthPercent/100.;
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, bottomRightRect, context, error)) return false;
        
        CGRect leftAxisRect = PSPlotGetLeftAxisRect(thePlot);
        float sliceheight = (float) heightPercent * leftAxisRect.size.height/100.;
        float verticalScale = sliceheight/(responseMax - responseMin);
        
        leftAxisRect.size.height *= (1-heightPercent/100.);
        leftAxisRect.origin.y += -verticalScale*responseMin;
        
        
        if(!PSQuartzDependentVariableDrawVerticalAxis(theDataset, verticalAxis, leftAxisRect, context, error)) return false;
        
    }
    else {
        if(real) {
            if(!PSQuartzDependentVariableStackPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSRealPart,widthPercent,heightPercent,rightToLeft,
                                                                   PSPlotGetSignalRect(thePlot),
                                                                   context, error)) return false;
        }
        
        if(imag) {
            if(!PSQuartzDependentVariableStackPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSImaginaryPart,widthPercent,heightPercent,rightToLeft,
                                                                   PSPlotGetSignalRect(thePlot),
                                                                   context, error)) return false;
            
        }
        
        if(magnitude) {
            if(!PSQuartzDependentVariableStackPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSMagnitudePart,widthPercent,heightPercent,rightToLeft,
                                                                   PSPlotGetSignalRect(thePlot),
                                                                   context, error)) return false;
            
        }
        
        if(argument) {
            if(PSPlotGetShowStackPlot(thePlot))
                if(!PSQuartzDependentVariableStackPlot2DCrossSectionThroughFocus(quartzDependentVariable, theDataset, kPSArgumentPart,widthPercent,heightPercent,rightToLeft,
                                                                       PSPlotGetSignalRect(thePlot),
                                                                       context, error)) return false;
        }
        
        CGRect bottomRect = PSPlotGetBottomRect(thePlot);
        if(fliphorizonalAxis) {
            bottomRect.origin.x +=  - (bottomRect.size.width*widthPercent/100. - bottomRect.size.width);
        }
        bottomRect.size.width *= widthPercent/100.;
        
        CGRect leftAxisRect = PSPlotGetLeftAxisRect(thePlot);
        float sliceheight = (float) heightPercent * leftAxisRect.size.height/100.;
        float verticalScale = sliceheight/(responseMax - responseMin);
        
        leftAxisRect.size.height *= (1-heightPercent/100.);
        leftAxisRect.origin.y += -verticalScale*responseMin;
        
        if(!PSQuartzDependentVariableDrawHorizontalAxis(theDataset, horizontalAxis, bottomRect, context, error)) return false;
        if(!PSQuartzDependentVariableDrawVerticalAxis(theDataset, verticalAxis, leftAxisRect, context, error)) return false;
        
    }
    
    return true;
}

bool PSQuartzDependentVariableStackPlot(PSQuartzDependentVariableRef quartzDependentVariable, PSDatasetRef theDataset, CGRect bounds,float widthPercent,float heightPercent,float rightToLeft, CGContextRef context, CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    IF_NO_OBJECT_EXISTS_RETURN(thePlot,false);
    
    if(PSPlotGetDimensionsDisplayedCount(thePlot) == 1) return false;
    else return PSQuartzDependentVariableStackPlot2D(quartzDependentVariable, theDataset, bounds,widthPercent,heightPercent,rightToLeft , context, error);
    return false;
}

static bool PSQuartzDependentVariableStackPlot2DCrossSectionThroughFocus(PSQuartzDependentVariableRef quartzDependentVariable,
                                                               PSDatasetRef theDataset,
                                                               complexPart part,
                                                               double widthPercent,
                                                               double heightPercent,
                                                               bool rightToLeft,
                                                               CGRect signalRect,
                                                               CGContextRef context,
                                                               CFErrorRef *error)
{
    if(error) if(*error) return false;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    IF_NO_OBJECT_EXISTS_RETURN(quartzDependentVariable,false);
    IF_NO_OBJECT_EXISTS_RETURN(context,false);
    
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);

    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    
    PSScalarRef horizontalIncrement = PSDimensionGetIncrement(horizontalDimension);
    PSScalarRef temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(horizontalIncrement, 2.);
    CFRelease(temp);
    
    PSScalarRef verticalIncrement = PSDimensionGetIncrement(verticalDimension);
    temp = PSScalarCreateByMultiplyingByDimensionlessRealConstant(verticalIncrement, 2.);
    CFRelease(temp);
    
    CFIndex horizontalMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex horizontalMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    CFIndex horizontalNpts = PSDimensionGetNpts(horizontalDimension);
    CFIndex hSpan = (horizontalMax - horizontalMin + 1);
    
    if(hSpan > 4*horizontalNpts) {
        if(error) {
            CFStringRef desc = CFSTR("Plot limits exceeds 4 times dimension width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            kPSQuartzDependentVariableHorizontalWidthExceeded,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    CFIndex verticalNpts = PSDimensionGetNpts(verticalDimension);
    
    CFIndex verticalMin = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMinimum(verticalAxis));
    CFIndex verticalMax = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMaximum(verticalAxis));
    
    CFIndex vSpan = (verticalMax - verticalMin + 1);
    if(vSpan > 4*verticalNpts) {
        if(error) {
            CFStringRef desc = CFSTR("Plot limits exceeds 4 times dimension width.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            kPSQuartzDependentVariableVerticalWidthExceeded,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        return false;
    }
    
    bool plotAll = PSPlotGetPlotAll(thePlot);
    // Reduce number of points displayed to around 128 x 128.   Also, need to make sure
    // that increment divdes into range with no remainder.
    quartzDependentVariable->horizontalIncrement = 1;
    quartzDependentVariable->verticalIncrement = 1;
    if(!plotAll) {
        while(hSpan/quartzDependentVariable->horizontalIncrement > 128) quartzDependentVariable->horizontalIncrement++;
        while(quartzDependentVariable->horizontalIncrement>0 && hSpan%quartzDependentVariable->horizontalIncrement !=0) quartzDependentVariable->horizontalIncrement--;
        if(quartzDependentVariable->horizontalIncrement<1) quartzDependentVariable->horizontalIncrement =1;
        
        while(vSpan/quartzDependentVariable->verticalIncrement > 128) quartzDependentVariable->verticalIncrement++;
        while(quartzDependentVariable->verticalIncrement>0&&vSpan%quartzDependentVariable->verticalIncrement !=0) quartzDependentVariable->verticalIncrement--;
    }
    size_t height = vSpan;
    if(quartzDependentVariable->verticalIncrement) height /= quartzDependentVariable->verticalIncrement;
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, signalRect);
    
    CFIndex hCoordinateIndexMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex hCoordinateIndexMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    float plotwidth = signalRect.size.width;
    float scalingFactor = 1;
    float slicewidth = (float) widthPercent * plotwidth/100.;
    float horizontalScale = slicewidth/(hCoordinateIndexMax - hCoordinateIndexMin);
    // To keep stack plot algorithm working (otherwise we get move to nan coordinates) need horizontal scale to be greater than one.
    // so we scale the signalRect up in size before calling StackPlot, and then scale the
    // drawing back to the view rect.
    while(horizontalScale<1.) {
        scalingFactor += 0.1;
        horizontalScale = slicewidth*scalingFactor/(hCoordinateIndexMax - hCoordinateIndexMin);
    };
    
    CGContextSetLineWidth(context,scalingFactor);
    // then increase to improve hidden plot appearance.
    scalingFactor *=  5;
    
    
    //    bool viewNeedsRegenerated = PSPlotGetStackViewNeedsRegenerated(thePlot);
    CGContextScaleCTM(context,1./scalingFactor,1./scalingFactor);
    signalRect.origin.x *= scalingFactor;
    signalRect.origin.y *= scalingFactor;
    signalRect.size.height *= scalingFactor;
    signalRect.size.width *= scalingFactor;
    
    if(PSPlotGetHiddenStackPlot(thePlot)) {
        HiddenStackPlotContext(quartzDependentVariable,
                               theDataset,
                               part,
                               signalRect,
                               widthPercent,
                               heightPercent,
                               rightToLeft,
                               context,
                               error);
    }
    else {
        StackPlotContext(quartzDependentVariable,
                         theDataset,
                         part,
                         signalRect,
                         widthPercent,
                         heightPercent,
                         rightToLeft,
                         context,
                         error);
    }
    
    
    
    PSPlotSetStackViewNeedsRegenerated(thePlot, false);
    if(PSPlotGetReal(thePlot)&&PSPlotGetImag(thePlot) && part==kPSRealPart) PSPlotSetStackViewNeedsRegenerated(thePlot, true);
    CGContextRestoreGState(context);
    return true;
}

static bool HiddenStackPlotContext(PSQuartzDependentVariableRef quartzDependentVariable,
                                   PSDatasetRef theDataset,
                                   complexPart part,
                                   CGRect signalRect,
                                   float widthPercent,
                                   float heightPercent,
                                   bool rightToLeft,
                                   CGContextRef context,
                                   CFErrorRef *error)
{
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);

    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    
    PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);
    
    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    
    CFIndex hCoordinateIndexMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex hCoordinateIndexMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    
    CFIndex vCoordinateIndexMin = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMinimum(verticalAxis));
    CFIndex vCoordinateIndexMax = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMaximum(verticalAxis));
    
    bool success = true;
    double responseMin = PSScalarDoubleValueInUnit(PSAxisGetMinimum(responseAxis), responseUnit, &success);
    double responseMax = PSScalarDoubleValueInUnit(PSAxisGetMaximum(responseAxis), responseUnit, &success);
    
    float plotwidth = signalRect.size.width;
    float plotheight = signalRect.size.height;
    float slicewidth = (float) widthPercent * plotwidth/100.;
    float sliceheight = (float) heightPercent * plotheight/100.;
    float verticalScale = sliceheight/(responseMax - responseMin);
    float horizontalScale = slicewidth/(hCoordinateIndexMax - hCoordinateIndexMin);
    float verticalOffset = signalRect.origin.y;
    double horizontalOffset = signalRect.origin.x;
    float deltah = (plotwidth - slicewidth)/(double) (vCoordinateIndexMax-vCoordinateIndexMin);
    float deltav = (plotheight- sliceheight)/(double) (vCoordinateIndexMax-vCoordinateIndexMin);
    CFIndex verticalIncrement = 1;
    CFIndex horizontalIncrement = 1;

    bool horizontalReverse = PSAxisGetReverse(horizontalAxis);
    float hposSign = 1;
    if(horizontalReverse) {
        horizontalOffset += signalRect.size.width;
        hposSign = -1;
    }
    
    bool verticalReverse = PSAxisGetReverse(verticalAxis);
    
    PSIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    
    numberType elementType = PSQuantityGetElementType(theDependentVariable);
    PSPlotColoring coloring = PSPlotGetStackPlotColoring(thePlot);
    CGFloat red = 0, green = 0, blue = 0;
    CGFloat alpha = 1;
    CFStringRef color = PSPlotGetComponentColorAtIndex(thePlot, componentIndex);
    
    if(![[[NSAppearance currentAppearance] name] isEqual: NSAppearanceNameAqua]) {
        if(CFStringCompare(color, kPSPlotColorBlack, kCFCompareCaseInsensitive)==kCFCompareEqualTo) color = kPSPlotColorWhite;
    }
    getRGBValuesFromColorName(color, &red, &green, &blue);
    
    NSAppearance *currentAppearance = [NSAppearance currentAppearance];
    if (@available(*, macOS 10.14)) {
        if(![currentAppearance.name isEqualToString:  NSAppearanceNameAqua]) {
            red  = 0.5*red+0.5;
            green = 0.5*green+0.5;
            blue  = 0.5*blue+0.5;
        }
    }
    
    float hue, saturation, value;
    RGBtoHSV(red, green, blue, &hue, &saturation, &value);
    CGContextSetRGBStrokeColor(context,red,green,blue,1);
    
    int size = plotwidth + horizontalIncrement +1;
    float vposHiddenMax[size];
    float vposHiddenMin[size];
    float vy[size];
    bool visible[size];
    
    for(CFIndex j=1;j<=plotwidth;j++) {
        vposHiddenMin[j] = (vCoordinateIndexMax-vCoordinateIndexMin)*deltav + verticalScale*(responseMax - responseMin);
        vposHiddenMax[j] = -vposHiddenMin[j];
        visible[j]=true;
    }
    
    PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutableCopy(focusIndexes);
    CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theDependentVariable, componentIndex);
    UInt8 *responsePtr =CFDataGetMutableBytePtr(values);

    /* 1. plot first slice since nothing hides it */
    CFIndex vIndex = vCoordinateIndexMin;
    // vIndexHorizontalShift is the number of pixel shift to right or left based on vIndex
    float vIndexHorizontalShift = (vIndex-vCoordinateIndexMin) * deltah;
    if(rightToLeft)  vIndexHorizontalShift = (vCoordinateIndexMax-vIndex) * deltah;
    
    /* 2. Interpolate first slice, find position of every pixel, and set equal to hidden region */
    PSIndexArraySetValueAtIndex(indexValues, verticalDimensionIndex, vIndex);
    for(float pixelIndex=0; pixelIndex<slicewidth; pixelIndex++) {
        CFIndex hpos = pixelIndex + vIndexHorizontalShift;
        vy[hpos] = 0;
        vposHiddenMin[hpos] = vy[hpos];
        vposHiddenMax[hpos] = vy[hpos];
        visible[hpos]=true;
    }
    
    for(CFIndex vIndex=vCoordinateIndexMin;vIndex<=vCoordinateIndexMax;vIndex += verticalIncrement) {
        CFIndex index = vIndex;
        if(verticalReverse) index = vCoordinateIndexMax + vCoordinateIndexMin -vIndex;
       CFIndex vIndexHorizontalShift = (vIndex-vCoordinateIndexMin) * deltah;
        if(rightToLeft)  vIndexHorizontalShift = (vCoordinateIndexMax-vIndex) * deltah;
        CFIndex vIndexVerticalShift = (vIndex-vCoordinateIndexMin) * deltav;
        
        CFIndex lasthpos = vIndexHorizontalShift;
        for(CFIndex hIndex =hCoordinateIndexMin;hIndex<hCoordinateIndexMax;hIndex+= horizontalIncrement) {
            PSIndexArraySetValueAtIndex(indexValues, horizontalDimensionIndex, hIndex);
            PSIndexArraySetValueAtIndex(indexValues, verticalDimensionIndex, index);
            CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
            float response = fetchResponse(responsePtr, memOffset, elementType, part);
            
            PSIndexArraySetValueAtIndex(indexValues, horizontalDimensionIndex, hIndex+horizontalIncrement);
            PSIndexArraySetValueAtIndex(indexValues, verticalDimensionIndex, index);
            memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
            float responseNext = fetchResponse(responsePtr, memOffset, elementType, part);
            
            if(coloring == kPSPlotColoringHue) {
                CGHSVtoRGB(&red, &green, &blue, (response-responseMin)/(responseMax-responseMin)*360., 1.0, 1.0);
                if(response<0) alpha = 0.5;
            }
            else if(coloring == kPSPlotColoringBicolor) {
                if(response>0) {
                    CGHSVtoRGB( &red, &green, &blue,hue,saturation,value);
                }
                else {
                    CGHSVtoRGB( &red, &green, &blue, ((int)(hue + 180))%360,saturation,value);
                }
            }
            else if(coloring == kPSPlotColoringMonochrome) {
                if(response<0) alpha = 0.5;
            }
            CGContextSetRGBStrokeColor(context,red,green,blue,1);
            
            CFIndex hpos =     horizontalScale*(hIndex - hCoordinateIndexMin) + vIndexHorizontalShift;
            CFIndex hposNext = horizontalScale*(hIndex + horizontalIncrement - hCoordinateIndexMin) + vIndexHorizontalShift;
            
            if(hposNext>=size) hposNext = size-1;

            for(CFIndex ihpos=hpos;ihpos<=hposNext;ihpos++) {
                float factor = (float) (ihpos-hpos) / (float)  (hposNext - hpos);
                if(hposNext==hpos) {
                    factor = 0;
                }
                
                float interpResponse = response + factor * (responseNext - response);
                
                vy[ihpos] = verticalScale * (interpResponse - responseMin) + vIndexVerticalShift;
                
                if(vy[ihpos]<vposHiddenMax[ihpos]&&vy[ihpos]>vposHiddenMin[ihpos]) visible[ihpos]=false;            // This point is hidden
                else {                                     // This point is visible, and is either below or above the hidden region
                    visible[ihpos]=true;
                    if(vy[ihpos]<=vposHiddenMin[ihpos]) vposHiddenMin[ihpos] = vy[ihpos];                // This point is below the hidden region
                    if(vy[ihpos]>=vposHiddenMax[ihpos]) vposHiddenMax[ihpos] = vy[ihpos];                // This point is above the hidden region
                }
            }
            
            
            if(visible[hpos]) { /* This point is visible */
                if(hIndex==hCoordinateIndexMin) {
                    CGContextMoveToPoint(context, horizontalOffset + (CGFloat) hpos*hposSign, vy[hpos]+ verticalOffset);        /* Move to first point in slice */
                }
                else {
                    if(visible[lasthpos]) { /* The last point was visible */
                        /* Make sure everything in between was visible */
                        bool vis = visible[lasthpos];
                        for(CFIndex index = lasthpos;index<=hpos;index++) vis *= visible[index];
                        if(vis) {
                            CGContextAddLineToPoint(context,horizontalOffset + (CGFloat) hpos*hposSign, vy[hpos]+ verticalOffset);
                            if(coloring != kPSPlotColoringMonochrome) {
                                CGContextStrokePath(context);
                                CGContextMoveToPoint(context,horizontalOffset + (CGFloat) hpos*hposSign, vy[hpos]+ verticalOffset);
                            }
                        }
                        else {
                            CFIndex ihpos = lasthpos;
                            while(visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                                ihpos++;
                                if(ihpos>=hposNext) break;
                            }
                            
                            CGContextMoveToPoint(context,horizontalOffset + (CGFloat) lasthpos*hposSign, vy[lasthpos]+ verticalOffset);
                            CGContextAddLineToPoint(context, horizontalOffset + (CGFloat) ihpos*hposSign, vy[ihpos]+ verticalOffset);
                            
                            while(!visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                                ihpos++;
                                if(ihpos>=hposNext) break;
                            }
                            
                            CGContextMoveToPoint(context,horizontalOffset + (CGFloat) (ihpos-1)*hposSign, vy[ihpos-1]+ verticalOffset);
                            CGContextAddLineToPoint(context, horizontalOffset + (CGFloat) hpos*hposSign, vy[hpos]+ verticalOffset);
                            if(coloring != kPSPlotColoringMonochrome) {
                                CGContextStrokePath(context);
                                CGContextMoveToPoint(context, horizontalOffset + (CGFloat) hpos*hposSign, vy[hpos]+ verticalOffset);
                            }
                        }
                    }
                    else { /* The last point was hidden */
                        CFIndex ihpos = lasthpos;
                        while(!visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                            ihpos++;
                            if(ihpos>=hposNext) break;
                        }
                        CGContextMoveToPoint(context,horizontalOffset + (CGFloat) (ihpos-1)*hposSign, vy[ihpos-1]+ verticalOffset);
                        CGContextAddLineToPoint(context, horizontalOffset + (CGFloat) hpos*hposSign, vy[hpos]+ verticalOffset);
                        if(coloring != kPSPlotColoringMonochrome) {
                            CGContextStrokePath(context);
                            CGContextMoveToPoint(context,horizontalOffset + (CGFloat) hpos*hposSign, vy[hpos]+ verticalOffset);
                        }
                        
                    }
                }
            }
            else { /* This point is hidden */
                if(visible[lasthpos]) { /* The last point was visible */
                    CFIndex ihpos = lasthpos;
                    while(visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                        ihpos++;
                        if(ihpos>=hposNext) break;
                    }
                    CGContextAddLineToPoint(context,horizontalOffset +  (CGFloat) (ihpos-1)*hposSign, vy[ihpos-1]+ verticalOffset);
                    if(coloring != kPSPlotColoringMonochrome) {
                        CGContextStrokePath(context);
                        CGContextMoveToPoint(context, horizontalOffset + (CGFloat) (ihpos-1)*hposSign, vy[ihpos-1]+ verticalOffset);
                    }
                }
            }
            lasthpos = hpos;
            if(lasthpos>=size) lasthpos = size-1;
            
            /* Do it again one last time for the last point */
            
            if(visible[hposNext]) { /* This point is visible */
                if(visible[lasthpos]) { /* The last point was visible */
                    /* Make sure everything in between was visible */
                    bool vis = visible[lasthpos];
                    for(CFIndex index = lasthpos;index<=hposNext;index++) vis *= visible[index];
                    if(vis) {
                        CGContextAddLineToPoint(context, (CGFloat) hposNext*hposSign + horizontalOffset, vy[hposNext]+ verticalOffset);
                        if(coloring != kPSPlotColoringMonochrome) {
                            CGContextStrokePath(context);
                            CGContextMoveToPoint(context, (CGFloat) hposNext*hposSign + horizontalOffset, vy[hposNext]+ verticalOffset);
                        }
                    }
                    else {
                        CFIndex ihpos = lasthpos;
                        while(visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                            ihpos++;
                            if(ihpos>=hposNext) break;
                        }
                        CGContextMoveToPoint(context, (CGFloat) lasthpos*hposSign + horizontalOffset, vy[lasthpos]+ verticalOffset);
                        CGContextAddLineToPoint(context, (CGFloat) ihpos*hposSign + horizontalOffset, vy[ihpos]+ verticalOffset);
                        
                        while(!visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                            ihpos++;
                            if(ihpos>=hposNext) break;
                        }
                        CGContextMoveToPoint(context, (CGFloat) (ihpos-1)*hposSign + horizontalOffset, vy[ihpos-1]+ verticalOffset);
                        CGContextAddLineToPoint(context,(CGFloat) hposNext*hposSign + horizontalOffset, vy[hposNext]+ verticalOffset);
                        if(coloring != kPSPlotColoringMonochrome) {
                            CGContextStrokePath(context);
                            CGContextMoveToPoint(context,(CGFloat) hposNext*hposSign + horizontalOffset, vy[hposNext]+ verticalOffset);
                        }
                    }
                }
                else { /* The last point was hidden */
                    CFIndex ihpos = lasthpos;
                    while(!visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                        ihpos++;
                        if(ihpos>=hposNext) break;
                    }
                    CGContextMoveToPoint(context, (CGFloat) (ihpos-1)*hposSign + horizontalOffset, vy[ihpos-1]+ verticalOffset);
                    CGContextAddLineToPoint(context,(CGFloat)  hposNext*hposSign + horizontalOffset, vy[hposNext]+ verticalOffset);
                    if(coloring != kPSPlotColoringMonochrome) {
                        CGContextStrokePath(context);
                        CGContextMoveToPoint(context,(CGFloat)  hposNext*hposSign + horizontalOffset, vy[hposNext]+ verticalOffset);
                    }
                }
            }
            else { /* This point is hidden */
                if(visible[lasthpos]) { /* The last point was visible */
                    CFIndex ihpos = lasthpos;
                    while(visible[ihpos]) { /* Find last visible pixel and draw line to it. */
                        ihpos++;
                        if(ihpos>=hposNext) break;
                    }
                    CGContextAddLineToPoint(context,(CGFloat) (ihpos-1)*hposSign + horizontalOffset, vy[ihpos-1]+ verticalOffset);
                    if(coloring != kPSPlotColoringMonochrome) {
                        CGContextStrokePath(context);
                        CGContextMoveToPoint(context,(CGFloat) (ihpos-1)*hposSign + horizontalOffset, vy[ihpos-1]+ verticalOffset);
                    }
                }
            }
        }
        CGContextStrokePath(context);
    }
    return true;
}

static bool StackPlotContext(PSQuartzDependentVariableRef quartzDependentVariable,
                             PSDatasetRef theDataset,
                             complexPart part,
                             CGRect signalRect,
                             float widthPercent,
                             float heightPercent,
                             bool rightToLeft,
                             CGContextRef context,
                             CFErrorRef *error)
{
    PSDimensionRef horizontalDimension = PSDatasetHorizontalDimension(theDataset);
    PSDimensionRef verticalDimension = PSDatasetVerticalDimension(theDataset);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    PSDatumRef focus = PSDatasetGetFocus(theDataset);
    CFIndex dependentVariableIndex = PSDatumGetDependentVariableIndex(focus);
    CFIndex componentIndex = PSDatumGetComponentIndex(focus);
    CFIndex memOffset = PSDatumGetMemOffset(focus);
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);

    PSAxisRef horizontalAxis = PSPlotHorizontalAxis(thePlot);
    PSAxisRef verticalAxis = PSPlotVerticalAxis(thePlot);
    PSAxisRef responseAxis = PSPlotGetResponseAxis(thePlot);
    
    PSUnitRef responseUnit = PSQuantityGetUnit(theDependentVariable);

    CFIndex horizontalDimensionIndex = PSDatasetGetHorizontalDimensionIndex(theDataset);
    CFIndex verticalDimensionIndex = PSDatasetGetVerticalDimensionIndex(theDataset);
    
    CFIndex hCoordinateIndexMin = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMinimum(horizontalAxis));
    CFIndex hCoordinateIndexMax = PSDimensionClosestIndexToDisplayedCoordinate(horizontalDimension, PSAxisGetMaximum(horizontalAxis));
    
    CFIndex vCoordinateIndexMin = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMinimum(verticalAxis));
    CFIndex vCoordinateIndexMax = PSDimensionClosestIndexToDisplayedCoordinate(verticalDimension, PSAxisGetMaximum(verticalAxis));
    
    bool success = true;
    double responseMin = PSScalarDoubleValueInUnit(PSAxisGetMinimum(responseAxis), responseUnit, &success);
    double responseMax = PSScalarDoubleValueInUnit(PSAxisGetMaximum(responseAxis), responseUnit, &success);
    
    float plotwidth = signalRect.size.width;
    float plotheight = signalRect.size.height;
    float slicewidth = (float) widthPercent * plotwidth/100.;
    float sliceheight = (float) heightPercent * plotheight/100.;
    float verticalScale = sliceheight/(responseMax - responseMin);
    float horizontalScale = slicewidth/(hCoordinateIndexMax - hCoordinateIndexMin);
    float verticalOffset = signalRect.origin.y;
    double horizontalOffset = signalRect.origin.x;
    float deltah = (plotwidth - slicewidth)/(double) (vCoordinateIndexMax-vCoordinateIndexMin);
    float deltav = (plotheight- sliceheight)/(double) (vCoordinateIndexMax-vCoordinateIndexMin);
    
    CFIndex verticalIncrement = 1;
    CFIndex horizontalIncrement = 1;
    PSIndexArrayRef focusIndexes = PSDimensionCreateCoordinateIndexesFromMemOffset(dimensions, memOffset);
    
    numberType elementType = PSQuantityGetElementType(theDependentVariable);
    PSPlotColoring coloring = PSPlotGetStackPlotColoring(thePlot);
    CGFloat red = 0, green = 0, blue = 0;
    CGFloat alpha = 1;
    CFStringRef color = PSPlotGetComponentColorAtIndex(thePlot, componentIndex);
    
    if(![[[NSAppearance currentAppearance] name] isEqual: NSAppearanceNameAqua]) {
        if(CFStringCompare(color, kPSPlotColorBlack, kCFCompareCaseInsensitive)==kCFCompareEqualTo) color = kPSPlotColorWhite;
    }
    getRGBValuesFromColorName(color, &red, &green, &blue);
    float hue, saturation, value;
    RGBtoHSV(red, green, blue, &hue, &saturation, &value);
    CGContextSetRGBStrokeColor(context,red,green,blue,1);
    
    CFMutableDataRef values = PSDependentVariableGetComponentAtIndex(theDependentVariable, componentIndex);
    UInt8 *responsePtr =CFDataGetMutableBytePtr(values);
    
    bool horizontalReverse = PSAxisGetReverse(horizontalAxis);
    float hposSign = 1;
    if(horizontalReverse) {
        horizontalOffset += signalRect.size.width;
        hposSign = -1;
    }
    bool verticalReverse = PSAxisGetReverse(verticalAxis);

    // vIndexHorizontalShift is the number of pixel shift to right or left based on vIndex
    CFIndex vIndex = vCoordinateIndexMin;
    float vIndexHorizontalShift = (vIndex-vCoordinateIndexMin) * deltah;
    if(rightToLeft)  vIndexHorizontalShift = (vCoordinateIndexMax-vIndex) * deltah;
    
    // vIndexHorizontalShift is the number of pixel shift up based on vIndex
    
    PSMutableIndexArrayRef indexValues = PSIndexArrayCreateMutableCopy(focusIndexes);
    
    for(CFIndex vIndex = vCoordinateIndexMin; vIndex<=vCoordinateIndexMax; vIndex += verticalIncrement) {
        CFIndex index = vIndex;
        if(verticalReverse) index = vCoordinateIndexMax + vCoordinateIndexMin -vIndex;
        CFIndex vIndexHorizontalShift = (vIndex-vCoordinateIndexMin) * deltah;
        if(rightToLeft)  vIndexHorizontalShift = (vCoordinateIndexMax-vIndex) * deltah;
        float vIndexVerticalShift = (vIndex-vCoordinateIndexMin) * deltav;
        for(CFIndex hIndex = hCoordinateIndexMin; hIndex<=hCoordinateIndexMax; hIndex += horizontalIncrement) {
            PSIndexArraySetValueAtIndex(indexValues, horizontalDimensionIndex, hIndex);
            PSIndexArraySetValueAtIndex(indexValues, verticalDimensionIndex, index);
            CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, indexValues);
            float response = fetchResponse(responsePtr, memOffset, elementType, part);
            if(coloring == kPSPlotColoringHue) {
                CGHSVtoRGB(&red, &green, &blue, (response-responseMin)/(responseMax-responseMin)*360., 1.0, 1.0);
                if(response<0) alpha = 0.5;
            }
            else if(coloring == kPSPlotColoringBicolor) {
                if(response>0) {
                    CGHSVtoRGB( &red, &green, &blue,hue,saturation,value);
                }
                else {
                    CGHSVtoRGB( &red, &green, &blue, ((int)(hue + 180))%360,saturation,value);
                }
            }
            else if(coloring == kPSPlotColoringMonochrome) {
                if(response<0) alpha = 0.5;
            }
            CGContextSetRGBStrokeColor(context,red,green,blue,1);
            
            float vpos = verticalScale * (response - responseMin) + vIndexVerticalShift;
            float hpos = horizontalScale*(hIndex - hCoordinateIndexMin)  + vIndexHorizontalShift;
            
            if(hIndex==hCoordinateIndexMin) {
                CGContextMoveToPoint(context, hpos*hposSign + horizontalOffset, vpos + verticalOffset);        /* Move to first point in slice */
            }
            else {
                CGContextAddLineToPoint(context,hpos*hposSign + horizontalOffset,vpos + verticalOffset);
                if(coloring != kPSPlotColoringMonochrome) {
                    CGContextStrokePath(context);
                    CGContextMoveToPoint(context,hpos*hposSign + horizontalOffset,vpos + verticalOffset);
                }
            }
            
        }
    }
    CGContextStrokePath(context);
    return true;
}




@end


