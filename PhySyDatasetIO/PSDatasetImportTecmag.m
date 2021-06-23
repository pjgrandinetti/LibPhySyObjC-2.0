//
//  PSDatasetImportTecmag.c
//  PSDataset
//
//  Created by Philip J. Grandinetti on 10/23/11.
//  Copyright (c) 2011 PhySy Ltd. All rights reserved.
//

#import <stdint.h>

#pragma pack(push)  /* push current alignment to stack */
#pragma pack(1)     /* set alignment to 1 byte boundary */

typedef struct Tecmag
{
	// Number of points and scans in all dimensions:
    
	int32_t npts[4];				// points requested 1D, 2D, 3D, 4D
	int32_t actual_npts[4];			// points completed in each dimension
    // (actual_npts[0] is not really used)
	int32_t acq_points;				// acq_points will be number of points to acquire
    // during one acquisition icon in the sequence
    // (which may be smaller than npts[0])
	int32_t npts_start[4];			// scan or pt on which to start the acquisition
	int32_t scans;					// scans 1D requested
	int32_t actual_scans;			// scans 1D completed
	int32_t dummy_scans;			// number of scans to do prior to collecting actual data
	int32_t repeat_times;			// Number of times to repeat scan
	int32_t sadimension;			// response average dimension
	int32_t samode;					// sets behavior of the response averager for the
    // dimension specified in S.A. Dimension
    
	// Field and frequencies:
	double magnet_field;				// magnet field
	double ob_freq[4];					// observe frequency
	double base_freq[4];				// base frequency
	double offset_freq[4];				// offset from base
	double ref_freq;					// reference frequency for axis calculation 
    // (used to be freqOffset)
	double NMR_frequency;				// absolute NMR frequency
	int16_t obs_channel;				// observe channel defalut = 1;
	char space2[42];
	
	// Spectral width, dwell and filter:
	double sw[4];						// spectral width in Hz
	double dwell[4];					// dwell time in seconds
	double filter;						// filter	
	double experiment_time;				// time for whole experiment
	double acq_time;					// acquisition time - time for acquisition
    
	double last_delay;					// last delay in seconds
	
	int16_t spectrum_direction;			// 1 or -1
	int16_t hardware_sideband;
	int16_t Taps;						// number of taps on receiver filter
	int16_t Type;						// type of filter
	int32_t bDigRec;					// toggle for digital receiver
	int32_t nDigitalCenter;				// number of shift points for digital receiver
	char space3[16];	
	
	
	//	Hardware settings:
	int16_t transmitter_gain;			// transmitter gain
	int16_t receiver_gain;				// receiver gain
	int16_t NumberOfReceivers;			// number of Rx in MultiRx system
	int16_t RG2;						// receiver gain for Rx channel 2	
	double receiver_phase;				// receiver phase
	char space4[4];
	
	// Spinning speed information:
	uint16_t set_spin_rate;				// set spin rate
	uint16_t actual_spin_rate;			// actual spin rate read from the meter
	
	// Lock information:
	int16_t lock_field;					// lock field value (might be Bruker specific)
	int16_t lock_power;					// lock transmitter power
	int16_t lock_gain;					// lock receiver gain
	int16_t lock_phase;					// lock phase	
	double lock_freq_mhz;				// lock frequency in MHz
	double lock_ppm;					// lock ppm
	double H2O_freq_ref;				// H1 freq of H2O
	char space5[16];	
	
	//	VT information:
	double set_temperature;				// non-integer VT
	double actual_temperature;			// non-integer VT
	
	// Shim information:
	double shim_units;					// shim units (used to be SU)	
	int16_t shims[36];					// shim values
	double shim_FWHM;					// full width at half maximum
	
	//	Bruker specific information:
	int16_t HH_dcpl_attn;				// decoupler attenuation 
    // (0..63 or 100..163); receiver gain is above
	int16_t DF_DN;						// decoupler
	int16_t F1_tran_mode[7];			// F1 Pulse transmitter switches
	int16_t dec_BW;						// decoupler BW
	
	char grd_orientation[4];			// gradient orientation
	int32_t LatchLP;					// 990629JMB  values for lacthed LP board
	double grd_Theta;					// 990720JMB  gradient rotation angle Theta
	double grd_Phi;						// 990720JMB  gradient rotation angle Phi
	char space6[264];					// space for the middle
    
	// Time variables 
	int32_t start_time;					// starting time
	int32_t finish_time;				// finishing time
	int32_t elapsed_time;				// projected elapsed time
    // text below and variables above
	
	// Text variables:					// 96 below
	char date[32];						// experiment date
	char nucleus[16];					// nucleus
	char nucleus_2D[16];				// 2D nucleus
	char nucleus_3D[16];				// 3D nucleus
	char nucleus_4D[16];				// 4D nucleus
	char sequence[32];					// sequence name
	char lock_solvent[16];				// Lock solvent
	char lock_nucleus[16];				// Lock nucleus
} Tecmag;


// Grid and Axis Structure	

#define TOTAL_UNIT_TYPES 12

typedef struct grid_and_axis
{
	double majorTickInc[TOTAL_UNIT_TYPES];		// Increment between major ticks
	
	int16_t minorIntNum[TOTAL_UNIT_TYPES];		// Number of intervals between major ticks 
    // (minor ticks is one less than this)
	int16_t labelPrecision[TOTAL_UNIT_TYPES];	// Number of digits after the decimal point
	
	double gaussPerCentimeter;					// Used for calculation of distance 
    // axis in frequency domain
	int16_t gridLines;							// Number of horizontal grid lines to 
    // be shown in data area 
	int16_t axisUnits;							// Type of units to show - see constants.h
	
	int32_t showGrid;							// Show or hide the grid	
	
	int32_t showGridLabels;						// Show or hide the labels on the grid lines
	
	int32_t adjustOnZoom;						// Adjust the number of ticks and the 
    // precision when zoomed in
	int32_t showDistanceUnits;					// whether to show frequency or distance 
    // units when in frequency domain
	char axisName[32];							// file name of the axis (not used as of 4/10/97)
	
	char space[52];	
	
} grid_and_axis;


typedef struct Tecmag2
{
	// Display Menu flags:
	int32_t real_flag;						// display real data				
	int32_t imag_flag;						// display imaginary data
	int32_t magn_flag;						// display magnitude data
	int32_t axis_visible;					// display axis
	int32_t auto_scale;						// auto scale mode on or off
	int32_t line_display;					// YES for lines, NO for points	
	int32_t show_shim_units;				// display shim units on the data area or not
	
	// Option Menu flags:
	int32_t integral_display;				// integrals turned on? - but not swap area
	int32_t fit_display;					// fits turned on?  - but not swap area
	int32_t show_pivot;						// show pivot point on screen; only used 
    // during interactive phasing
	int32_t label_peaks;					// show labels on the peaks?
	int32_t keep_manual_peaks;				// keep manual peaks when re-applying 
    // peak pick settings?
	int32_t label_peaks_in_units;			// peak label type
	int32_t integral_dc_average;			// use dc average for integral calculation
	int32_t integral_show_multiplier;		// show multiplier on integrals that are scaled
	int32_t int32_tean_space[9];
	
	// Processing flags:
	int32_t all_ffts_done[4];
	int32_t all_phase_done[4];
	
	// Vertical display multipliers:
	double amp;								// amplitude scale factor
	double ampbits;							// resolution of display
	double ampCtl;							// amplitude control value
	int32_t offset;							// vertical offset
	
	grid_and_axis axis_set;					// see Grid and Axis Structure below
    
	int16_t display_units[4];				// display units for swap area
	int32_t ref_point[4];					// for use in frequency offset calcs
	double ref_value[4];					// for use in frequency offset calcs
	int32_t z_start;						// beginning of data display 
    // (range: 0 to 2 * npts[0] - 2)
	int32_t z_end;							// end of data display (range: 0 to 2 * npts[0] - 2)
	int32_t z_select_start;					// beginning of zoom highlight
	int32_t z_select_end;					// end of zoom highlight
	int32_t last_zoom_start;				// last z_select_start - not used yet (4/10/97)
	int32_t last_zoom_end;					// last z_select_end - not used yet (4/10/97)
	int32_t index_2D;						// in 1D window, which 2D record we see
	int32_t index_3D;						// in 1D window, which 3D record we see
	int32_t index_4D;						// in 1D window, which 4D record we see
	
    
	int32_t apodization_done[4];		// masked value showing which processing 
    // has been done to the data; see constants.h for values
	double linebrd[4];					// line broadening value
	double gaussbrd[4];					// gaussian broadening value			
	double dmbrd[4];					// double exponential broadening value
	double sine_bell_shift[4];			// sine bell shift value
	double sine_bell_width[4];			// sine bell width value
	double sine_bell_skew[4];			// sine bell skew value
	int32_t Trapz_point_1[4];			// first trapezoid point for trapezoidal apodization
	int32_t Trapz_point_2[4];			// second trapezoid point for 
    // trapezoidal apodization	
	int32_t Trapz_point_3[4];			// third trapezoid point for trapezoidal 
    // apodization	
	int32_t Trapz_point_4[4];			// fourth trapezoid point for trapezoidal apodization
	double trafbrd[4];					// Traficante-Ziessow broadening value
	int32_t echo_center[4];				// echo center for all dimensions
    
	int32_t data_shift_points;			// number of points to use in 
    // left/right shift operations
	int16_t fft_flag[4];				// fourier transform done?  
    // NO if time domain, YES if frequency domain
	double unused[8];
	int pivot_point[4];					// for interactive phasing
	double cumm_0_phase[4];				// cummulative zero order phase applied
	double cumm_1_phase[4];				// cummulative first order phase applied
	double manual_0_phase;				// used for interactive phasing
	double manual_1_phase;				// used for interactive phasing
	double phase_0_value;				// last zero order phase value 
    // applied (not necessarily equivalent to 
    // cummulative zero order phase)
	double phase_1_value;				// last first order phase value applied 
    // (not necessarily equivalent to cummulative 
    // first order phase)
	double session_phase_0;				// used during interactive phasing
	double session_phase_1;				// used during interactive phasing
	
	int32_t max_index;					// index of max data value
	int32_t min_index;					// index of min data value
	float peak_threshold;				// threshold above which peaks are chosen
	float peak_noise;					// minimum value between two points that are 
    // above the peak threshold to distinguish two 
    // peaks from two points on the same peak
	int16_t integral_dc_points;			// number of points to use in integral 
    // calculation when dc average is used
	int16_t integral_label_type;		// how to label integrals, see constants.h
	float integral_scale_factor;		// scale factor to be used in integral draw
	int32_t auto_integrate_shoulder;	// number of points to determine 
    // where integral is cut off
	double auto_integrate_noise;		// when average of shoulder points is 
    // under this value, cut off integral
	double auto_integrate_threshold;	// threshold above which a peak 
    // is chosen in auto integrate
	int32_t s_n_peak;					// peak to be used for response to noise calculation
	int32_t s_n_noise_start;			// start of noise region for 
    // response to noise calculation
	int32_t s_n_noise_end;				// end of noise region for response to noise calculation
	float s_n_calculated;				// calculated response to noise value 
	
	int32_t Spline_point[14];			// points to be used for 
    // spline baseline fix calculation
	int16_t Spline_point_avr;			// for baseline fix
	int32_t Poly_point[8];				// points for polynomial baseline fix calculation
	int16_t Poly_point_avr;				// for baseline fix
	int16_t Poly_order;					// what order polynomial to use 
	
	// Blank Space:
	char space[610];		
    
	// Text variables:
	char line_simulation_name[32];
	char integral_template_name[32];
	char baseline_template_name[32];	
	char layout_name[32];
	char relax_information_name[32];
	
	char username[32];
	
	char user_string_1[16];
	char user_string_2[16];
	char user_string_3[16];	
	char user_string_4[16];
	
} Tecmag2;

#pragma pack(pop)   /* restore original alignment from stack */

#import <LibPhySyObjC/PhySyDatasetIO.h>
//#include "PhySyDataset.h"
//#include "PSDatasetImportTecmag.h"

//bool PSDatasetImportTecmagIsValidURL(CFURLRef url)
//{
//    bool result = false;
//    CFStringRef extension = CFURLCopyPathExtension(url);
//    if(extension) {
//        if(CFStringCompare(extension, CFSTR("tnt"), 0) == kCFCompareEqualTo) result = true;
//        CFRelease(extension);
//    }
//    return result;
//}
//
//CFIndex PSDatasetImportTecmagNumberOfDimensionsForURL(CFURLRef url)
//{
//    CFDataRef contents;
//	SInt32 errorCode;
//	CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,url,&contents,NULL,NULL,&errorCode);
//    if(errorCode) return 0;
//
//    const UInt8 *buffer = CFDataGetBytePtr((CFDataRef) contents);
//    
//    Tecmag *tecmag = malloc(sizeof(struct Tecmag));
//    tecmag = memcpy(tecmag, (buffer+20), sizeof(struct Tecmag));
//    
//    int numberOfDimensions = 0;
//	for(int i=0;i<4;i++) if((tecmag)->actual_npts[i]>1) numberOfDimensions++;
//    CFRelease(contents);
//    return numberOfDimensions;
//}

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

CFStringRef ReadTecmagCreateStringFromBufferIndex(const UInt8 *buffer, CFIndex *index, CFIndex bufferLength)
{
    if(*index>=bufferLength) return NULL;
    
    uint32 lengthOfString = 0;
    memcpy(&lengthOfString, &buffer[*index],4);
    if(lengthOfString+*index > bufferLength) return NULL;
    
    *index +=4;
    char *string = malloc(lengthOfString+1);
    memcpy(string, &buffer[*index],lengthOfString);
    string[lengthOfString] = 0;
    *index += lengthOfString;
    CFStringRef result = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),string);
    free(string);
    return result;
}

CFNumberRef ReadTecmagCreate32BitNumberFromBufferIndex(const UInt8 *buffer, CFIndex *index, CFIndex bufferLength)
{
    if(*index>=bufferLength) return NULL;

    int32_t number = 0;
    memcpy(&number, &buffer[*index],4);
    *index +=4;
    return CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &number);
}

Tecmag *ReadTecmagCreateTecmagStructureFromBufferIndex(const UInt8 *buffer, CFIndex *index, CFIndex bufferLength)
{
    char *tag = malloc(5);
    memcpy(tag, &buffer[*index],4);
    tag[4] = 0;
    *index +=4;
    
    if(strcmp(tag, "TMAG") != 0) {
        free(tag);
        NSLog(@"TMAG tag missing");
        return NULL;
    }
    free(tag);
    
    uint32 tmag_flag = 0;
    memcpy(&tmag_flag, &buffer[*index],4);
    *index +=4;

    if(tmag_flag) {
        uint32 lengthOfTecmagStructure = 0;
        memcpy(&lengthOfTecmagStructure, &buffer[*index],4);
        *index +=4;
        
        Tecmag *tecmag = malloc(sizeof(struct Tecmag));
        tecmag = memcpy(tecmag, (buffer+20), sizeof(struct Tecmag));
        *index += lengthOfTecmagStructure;
        return tecmag;
    }
    NSLog(@"TMAG flag is false");
    return NULL;
}

Tecmag2 *ReadTecmagCreateTecmag2StructureFromBufferIndex(const UInt8 *buffer, CFIndex *index, CFIndex bufferLength)
{
    char *tag = malloc(5);
    memcpy(tag, &buffer[*index],4);
    tag[4] = 0;
    *index +=4;
    
    if(strcmp(tag, "TMG2") != 0) {
        free(tag);
        return NULL;
    }
    free(tag);
    
    uint32 tmag_flag = 0;
    memcpy(&tmag_flag, &buffer[*index],4);
    *index +=4;
    if(tmag_flag) {
        uint32 lengthOfTecmag2Structure = 0;
        memcpy(&lengthOfTecmag2Structure, &buffer[*index],4);
        *index +=4;
        
        Tecmag2 *tecmag2 = malloc(sizeof(struct Tecmag2));
        tecmag2 = memcpy(tecmag2, (buffer+*index), sizeof(struct Tecmag2));
        *index += lengthOfTecmag2Structure;
        return tecmag2;
    }
    return NULL;
}


const UInt8 *SetTecmagDataLocationAndNpts(const UInt8 *buffer, CFIndex *index, CFIndex *npts, CFIndex bufferLength)
{
    char *tag = malloc(5);
    memcpy(tag, &buffer[*index],4);
    tag[4] = 0;
    *index +=4;
    if(strcmp(tag, "DATA") != 0) {
        free(tag);
        return NULL;
    }
    free(tag);
    
    uint32 data_flag = 0;
    memcpy(&data_flag, &buffer[*index],4);
    *index +=4;
    if(data_flag) {
        uint32 lengthOfData = 0;
        memcpy(&lengthOfData, &buffer[*index],4);
        *index +=4;
        *npts = lengthOfData;
        *npts = *npts/sizeof(float complex);
        *index += lengthOfData;
        return (const UInt8 *) (buffer + 1056);
    }
    return NULL;
}

CFMutableDictionaryRef CreateTecmagStructureMetaData(Tecmag *tecmag, CFErrorRef *error)
{
    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL, error);
    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL, error);
    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL, error);

    CFMutableDictionaryRef tmagMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFStringRef date = CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *) tecmag->date, strlen(tecmag->date)+1, kCFStringEncodingASCII, false);
    CFDictionaryAddValue(tmagMetaData, CFSTR("date"), date);
    CFRelease(date);
    
    CFStringRef sequence = CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *) tecmag->sequence, strlen(tecmag->sequence)+1, kCFStringEncodingASCII, false);
    CFDictionaryAddValue(tmagMetaData, CFSTR("sequence"), sequence);
    CFRelease(sequence);
    
    CFStringRef lock_solvent = CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *) tecmag->lock_solvent, strlen(tecmag->lock_solvent)+1, kCFStringEncodingASCII, false);
    CFDictionaryAddValue(tmagMetaData, CFSTR("lock solvent"), lock_solvent);
    CFRelease(lock_solvent);
    
    CFNumberRef actual_scans = PSCFNumberCreateWithCFIndex(tecmag->actual_scans);
    CFStringRef temp = PSCFNumberCreateStringValue(actual_scans);
    CFDictionaryAddValue(tmagMetaData, CFSTR("actual scans"), temp);
    CFRelease(temp);
    CFRelease(actual_scans);
    
    CFNumberRef scans = PSCFNumberCreateWithCFIndex(tecmag->scans);
    temp = PSCFNumberCreateStringValue(scans);
    CFDictionaryAddValue(tmagMetaData, CFSTR("scans"), temp);
    CFRelease(temp);
    CFRelease(scans);
    
    CFNumberRef dummy_scans = PSCFNumberCreateWithCFIndex(tecmag->dummy_scans);
    temp = PSCFNumberCreateStringValue(dummy_scans);
    CFDictionaryAddValue(tmagMetaData, CFSTR("dummy scans"), temp);
    CFRelease(temp);
    CFRelease(dummy_scans);
    
    PSScalarRef acquisitionTime = PSScalarCreateWithDouble(tecmag->acq_time, seconds);
    temp = PSScalarCreateStringValue(acquisitionTime);
    CFDictionaryAddValue(tmagMetaData, CFSTR("acquisition time"), temp);
    CFRelease(temp);
    CFRelease(acquisitionTime);
    
    PSScalarRef experiment_time = PSScalarCreateWithDouble(tecmag->experiment_time, seconds);
    temp = PSScalarCreateStringValue(experiment_time);
    CFDictionaryAddValue(tmagMetaData, CFSTR("experiment time"), temp);
    CFRelease(temp);
    CFRelease(experiment_time);
    
    PSScalarRef last_delay = PSScalarCreateWithDouble(tecmag->last_delay, seconds);
    temp = PSScalarCreateStringValue(last_delay);
    CFDictionaryAddValue(tmagMetaData, CFSTR("last delay"), temp);
    CFRelease(temp);
    CFRelease(last_delay);
    
    PSUnitRef radians = PSUnitByParsingSymbol(CFSTR("rad"), NULL, error);
    PSScalarRef receiver_phase = PSScalarCreateWithDouble(tecmag->receiver_phase, radians);
    temp = PSScalarCreateStringValue(receiver_phase);
    CFDictionaryAddValue(tmagMetaData, CFSTR("receiver phase"), temp);
    CFRelease(temp);
    CFRelease(receiver_phase);
    
    PSScalarRef filter = PSScalarCreateWithDouble(tecmag->filter, hertz);
    temp = PSScalarCreateStringValue(filter);
    CFDictionaryAddValue(tmagMetaData, CFSTR("filter"), temp);
    CFRelease(temp);
    CFRelease(filter);
    
    CFNumberRef transmitter_gain = PSCFNumberCreateWithCFIndex(tecmag->transmitter_gain);
    temp = PSCFNumberCreateStringValue(transmitter_gain);
    CFDictionaryAddValue(tmagMetaData, CFSTR("transmitter gain"), temp);
    CFRelease(temp);
    CFRelease(transmitter_gain);
    
    CFNumberRef receiver_gain = PSCFNumberCreateWithCFIndex(tecmag->receiver_gain);
    temp = PSCFNumberCreateStringValue(receiver_gain);
    CFDictionaryAddValue(tmagMetaData, CFSTR("receiver gain"), temp);
    CFRelease(temp);
    CFRelease(receiver_gain);

    return tmagMetaData;
}

CFStringRef CreateTecmagSEQCCommentString(const UInt8 *buffer, CFIndex *index, CFIndex bufferLength)
{
    char *tag = malloc(5);
    memcpy(tag, &buffer[*index],4);
    tag[4] = 0;
    *index +=4;
    if(strcmp(tag, "SEQC") != 0) {
        free(tag);
        return NULL;
    }
    free(tag);
 
    return ReadTecmagCreateStringFromBufferIndex(buffer, index, bufferLength);
}

CFMutableDictionaryRef CreateTecmagPSEQMetaData(const UInt8 *buffer, CFIndex *index, CFIndex bufferLength)
{
    char *tag = malloc(5);
    memcpy(tag, &buffer[*index],4);
    tag[4] = 0;
    *index +=4;
    if(strcmp(tag, "PSEQ") != 0) {
        free(tag);
        return NULL;
    }
    free(tag);

    uint32 pseq_flag = 0;
    memcpy(&pseq_flag, &buffer[*index],4);
    *index +=4;
    if(pseq_flag) {
        CFMutableDictionaryRef sequenceMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

        char *sequenceID = malloc(9);
        memcpy(sequenceID, &buffer[*index],8);
        sequenceID[8] = 0;
        *index +=8;
        CFStringRef stringValue = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%s"),sequenceID);
        CFDictionaryAddValue(sequenceMetaData, CFSTR("sequenceID"), stringValue);
        CFRelease(stringValue);
        free(sequenceID);
        
        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index, bufferLength);
        CFDictionaryAddValue(sequenceMetaData, CFSTR("sequence file name"), stringValue);
        CFRelease(stringValue);
        
        CFIndex bin114Count = findTag(buffer, bufferLength, "1.14 BIN");
        CFIndex bin115Count = findTag(buffer, bufferLength, "1.15 BIN");
        CFIndex bin116Count = findTag(buffer, bufferLength, "1.16 BIN");
        CFIndex bin117Count = findTag(buffer, bufferLength, "1.17 BIN");
        CFIndex bin118Count = findTag(buffer, bufferLength, "1.18 BIN");
        
        //            if(bin114Count!=kCFNotFound || bin115Count!=kCFNotFound || bin116Count!=kCFNotFound
        //               || bin117Count!=kCFNotFound || bin118Count!=kCFNotFound) {
        if(/* DISABLES CODE */ (false)) {
            CFIndex entry_bytes = 60;
            
            if(bin118Count!=kCFNotFound) {
                *index += 8;   //  Unknown purpose bytes
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(sequenceMetaData, CFSTR("email address"), stringValue);
                CFRelease(stringValue);
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(sequenceMetaData, CFSTR("pseq string2"), stringValue);
                CFRelease(stringValue);
            }
            
            CFNumberRef numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
            CFIndex numberOfFields = PSCFNumberCFIndexValue(numberValue);
            CFDictionaryAddValue(sequenceMetaData, CFSTR("number of fields"), numberValue);
            CFRelease(numberValue);
            
            numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
            CFDictionaryAddValue(sequenceMetaData, CFSTR("number of events"), numberValue);
            CFRelease(numberValue);
            
            CFMutableArrayRef sequenceFields = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFDictionaryAddValue(sequenceMetaData, CFSTR("sequence fields"), sequenceFields);
            CFRelease(sequenceFields);
            for(CFIndex fieldIndex = 0; fieldIndex<numberOfFields; fieldIndex++) {
                CFMutableDictionaryRef fieldMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFArrayAppendValue(sequenceFields, fieldMetaData);
                CFRelease(fieldMetaData);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFIndex numberOfLocalEvents = PSCFNumberCFIndexValue(numberValue);
                CFDictionaryAddValue(fieldMetaData, CFSTR("number of local events"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(fieldMetaData, CFSTR("address"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(fieldMetaData, CFSTR("bit length"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(fieldMetaData, CFSTR("icon library type"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(fieldMetaData, CFSTR("visible flag"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(fieldMetaData, CFSTR("private data"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(fieldMetaData, CFSTR("group"), numberValue);
                CFRelease(numberValue);
                
                CFMutableArrayRef sequenceEvents = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
                CFDictionaryAddValue(fieldMetaData, CFSTR("sequence events"), sequenceEvents);
                CFRelease(sequenceEvents);
                
                for(CFIndex eventIndex = 0; eventIndex<numberOfLocalEvents; eventIndex++) {
                    CFMutableDictionaryRef eventMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                    CFArrayAppendValue(sequenceEvents, eventMetaData);
                    CFRelease(eventMetaData);
                    
                    if(eventIndex==0) {
                        
                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer,index,bufferLength);
                        CFDictionaryAddValue(eventMetaData, CFSTR("default"), stringValue);
                        CFRelease(stringValue);
                        
                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                        CFDictionaryAddValue(eventMetaData, CFSTR("label"), stringValue);
                        CFRelease(stringValue);
                        
                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer,index,bufferLength);
                        CFDictionaryAddValue(eventMetaData, CFSTR("field"), stringValue);
                        CFRelease(stringValue);
                        
                        *index += entry_bytes - 4;
                    }
                    else {
                        for(CFIndex bytes = 1; bytes<=entry_bytes/4; bytes++) {
                            uint32 nameLength = 0;
                            memcpy(&nameLength, &buffer[*index],4);
                            *index +=4;
                            if(nameLength>0) {
                                switch (bytes) {
                                    case 1:
                                    {
                                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                        CFDictionaryAddValue(eventMetaData, CFSTR("Setting"), stringValue);
                                        CFRelease(stringValue);
                                    }
                                        break;
                                    case 2:
                                    {
                                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                        CFDictionaryAddValue(eventMetaData, CFSTR("GradWaveTbl"), stringValue);
                                        CFRelease(stringValue);
                                    }
                                        break;
                                    case 4:
                                    {
                                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                        CFDictionaryAddValue(eventMetaData, CFSTR("PhaseTbl"), stringValue);
                                        CFRelease(stringValue);
                                    }
                                        break;
                                    case 6:
                                    case 8:
                                    {
                                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                        CFDictionaryAddValue(eventMetaData, CFSTR("Delay_Branch_GradAmpTbl"), stringValue);
                                        CFRelease(stringValue);
                                    }
                                        break;
                                    case 10:
                                    {
                                        stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                        CFDictionaryAddValue(eventMetaData, CFSTR("DelayTbl"), stringValue);
                                        CFRelease(stringValue);
                                    }
                                        break;
                                    case 15:
                                    {
                                        switch (nameLength) {
                                            case 1:
                                            {
                                                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                                CFDictionaryAddValue(eventMetaData, CFSTR("acq_pnts_Hz"), stringValue);
                                                CFRelease(stringValue);
                                                
                                                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                                CFDictionaryAddValue(eventMetaData, CFSTR("sweep"), stringValue);
                                                CFRelease(stringValue);
                                                
                                                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                                CFDictionaryAddValue(eventMetaData, CFSTR("filter"), stringValue);
                                                CFRelease(stringValue);
                                                
                                                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                                CFDictionaryAddValue(eventMetaData, CFSTR("dwell_sec"), stringValue);
                                                CFRelease(stringValue);
                                                
                                                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                                                CFDictionaryAddValue(eventMetaData, CFSTR("acq_tm_sec"), stringValue);
                                                CFRelease(stringValue);
                                                
                                                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                                                CFDictionaryAddValue(eventMetaData, CFSTR("dash_link"), numberValue);
                                                CFRelease(numberValue);
                                                
                                                *index += 2;
                                                
                                            }
                                                break;
                                                
                                            default:
                                                break;
                                        }
                                    }
                                        break;
                                    default:
                                        break;
                                }
                            }
                            
                            
                        }
                        
                    }
                }
                
                
            }
            
            
            // skip past unknown table
            uint32 tableLength = 0;
            memcpy(&tableLength, &buffer[*index],4);
            *index +=4;
            *index += tableLength*4;
            
            uint32 num_vars = 0;
            memcpy(&num_vars, &buffer[*index],4);
            *index +=4;
            
            CFMutableArrayRef tables = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            CFDictionaryAddValue(sequenceMetaData, CFSTR("tables"), tables);
            CFRelease(tables);
            
            for(CFIndex varsIndex = 0; varsIndex<num_vars; varsIndex++) {
                
                CFMutableDictionaryRef tableMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFArrayAppendValue(tables, tableMetaData);
                CFRelease(tableMetaData);
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("name"), stringValue);
                CFRelease(stringValue);
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFRange range = CFStringFind(stringValue, CFSTR("\r\n"), 0);
                CFArrayRef tableArray = NULL;
                if(range.location == kCFNotFound) {
                    tableArray = CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault, stringValue, CFSTR(" "));
                }
                else {
                    tableArray = CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault, stringValue, CFSTR("\r\n"));
                }
                CFRelease(stringValue);
                
                CFDictionaryAddValue(tableMetaData, CFSTR("values"), tableArray);
                CFRelease(tableArray);
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("increment operation"), stringValue);
                CFRelease(stringValue);
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("increment value"), stringValue);
                CFRelease(stringValue);
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("increment scheme"), stringValue);
                CFRelease(stringValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("repeat Time"), numberValue);
                CFRelease(numberValue);
                
                stringValue = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("table type"), stringValue);
                CFRelease(stringValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("dimension"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("steps per 360 cycle"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index,bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("use as increment list"), numberValue);
                CFRelease(numberValue);
                
                numberValue = ReadTecmagCreate32BitNumberFromBufferIndex(buffer, index, bufferLength);
                CFDictionaryAddValue(tableMetaData, CFSTR("value type"), numberValue);
                CFRelease(numberValue);
                
                *index += 12;  // skip 3 integers
                
                uint32 sz = 0;
                memcpy(&sz, &buffer[*index],4);
                *index +=4;
                *index += sz;
                
                sz = 0;
                memcpy(&sz, &buffer[*index],4);
                *index +=4;
                *index += sz;
                
                sz = 0;
                memcpy(&sz, &buffer[*index],4);
                *index +=4;
                *index += sz;
                
                if(bin116Count!=kCFNotFound || bin118Count!=kCFNotFound) *index += 8;  // skip 2 integers
                else  *index += 4;
                
                int32_t unkn = 0;
                memcpy(&unkn, &buffer[*index],4);
                if(unkn==0) *index +=4;
                
            }
            
            uint32 flag = 0;
            memcpy(&flag, &buffer[*index],4);
            *index +=4;
            numberValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &flag);
            CFDictionaryAddValue(sequenceMetaData, CFSTR("flag"), numberValue);
            CFRelease(numberValue);
            
            if(flag) {
                
                CFStringRef theSectionName = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                
                uint32 numberOfEntries = 0;
                memcpy(&numberOfEntries, &buffer[*index],4);
                *index +=4;
                
                CFMutableArrayRef settingsMetaData = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
                CFDictionaryAddValue(sequenceMetaData, theSectionName, settingsMetaData);
                CFRelease(settingsMetaData);
                CFRelease(theSectionName);
                
                for(CFIndex indexOfEntry=0; indexOfEntry<numberOfEntries; indexOfEntry++) {
                    CFStringRef theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFArrayAppendValue(settingsMetaData, theString);
                    CFRelease(theString);
                }
                
                numberOfEntries = 0;
                memcpy(&numberOfEntries, &buffer[*index],4);
                *index +=4;
                
                CFMutableArrayRef entries = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
                CFDictionaryAddValue(sequenceMetaData, CFSTR("entries"), entries);
                CFRelease(entries);
                
                for(CFIndex indexOfEntry=0; indexOfEntry<numberOfEntries; indexOfEntry++) {
                    CFMutableDictionaryRef entryMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                    CFArrayAppendValue(entries, entryMetaData);
                    CFRelease(entryMetaData);
                    
                    CFStringRef theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFDictionaryAddValue(entryMetaData, CFSTR("string1"), theString);
                    CFRelease(theString);
                    
                    *index += 4;     // unknown word
                    
                    theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFDictionaryAddValue(entryMetaData, CFSTR("string2"), theString);
                    CFRelease(theString);
                    
                    *index += 4;     // unknown word
                    
                    theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFDictionaryAddValue(entryMetaData, CFSTR("string3"), theString);
                    CFRelease(theString);
                    
                    theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFDictionaryAddValue(entryMetaData, CFSTR("string4"), theString);
                    CFRelease(theString);
                    
                    theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFDictionaryAddValue(entryMetaData, CFSTR("string5"), theString);
                    CFRelease(theString);
                    
                    if(bin116Count!=kCFNotFound) *index += 4;
                    else *index += 8;
                    
                    theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFDictionaryAddValue(entryMetaData, CFSTR("string6"), theString);
                    CFRelease(theString);
                    
                    theString = ReadTecmagCreateStringFromBufferIndex(buffer, index,bufferLength);
                    CFDictionaryAddValue(entryMetaData, CFSTR("string7"), theString);
                    CFRelease(theString);
                    
                    if(bin116Count!=kCFNotFound) *index += 12;
                    else *index += 16;
                    
                }
            }
        }
    }
    
    return NULL;
}

PSDatasetRef PSDatasetImportTecmagCreateWithFileData(CFDataRef contents, CFErrorRef *error)
{
    IF_NO_OBJECT_EXISTS_RETURN(contents,NULL);
    if(error) if(*error) return NULL;
    CFIndex totalFileLength = CFDataGetLength(contents);
    if(totalFileLength == 0) return NULL;
    const UInt8 *buffer = CFDataGetBytePtr(contents);

    PSUnitRef hertz = PSUnitByParsingSymbol(CFSTR("Hz"), NULL, error);
    PSUnitRef megahertz = PSUnitByParsingSymbol(CFSTR("MHz"), NULL, error);
    PSUnitRef seconds = PSUnitByParsingSymbol(CFSTR("s"), NULL, error);
    
    CFIndex count = 0;
    char *tntTag = malloc(5);
    memcpy(tntTag, &buffer[count],4);
    tntTag[4] = 0;
    if(strcmp(tntTag, "TNT1") != 0) {
        free(tntTag);
        return NULL;
    }
    free(tntTag);

    count = 0;
    char *versionID = malloc(9);
    memcpy(versionID, &buffer[count],8);
    versionID[8] = 0;
    CFStringRef versionIDString = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),versionID);
    free(versionID);
    
    count = 8;
    Tecmag *tecmag = ReadTecmagCreateTecmagStructureFromBufferIndex(buffer, &count, totalFileLength);
    if(NULL==tecmag) {
        CFRelease(versionIDString);
        if(error) {
            CFStringRef desc = CFSTR("Error reading tecmag structure.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }

        return NULL;
    }
    
    CFIndex size = 0;
    const UInt8 *data  = SetTecmagDataLocationAndNpts(buffer, &count, &size, totalFileLength);
    if(NULL==data) {
        if(error) {
            CFStringRef desc = CFSTR("Error reading tecmag data.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        if(tecmag) free(tecmag);
        
        CFRelease(versionIDString);
        return NULL;
    }

    Tecmag2 *tecmag2 = ReadTecmagCreateTecmag2StructureFromBufferIndex(buffer, &count, totalFileLength);
    if(NULL==tecmag2) {
        if(error) {
            CFStringRef desc = CFSTR("Error reading tecmag2 structure.");
            *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                            kPSFoundationErrorDomain,
                                                            0,
                                                            (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                            (const void* const*)&desc,
                                                            1);
        }
        if(tecmag) free(tecmag);

        CFRelease(versionIDString);
        return NULL;
    }
    
    // Essential structures read
    
    // Create NMR meta-data
    CFMutableDictionaryRef tecmagDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(tecmagDatasetMetaData, CFSTR("versionID"), versionIDString);
    CFRelease(versionIDString);
    
    CFMutableDictionaryRef tmagMetaData = CreateTecmagStructureMetaData(tecmag, error);
    CFDictionaryAddValue(tecmagDatasetMetaData, CFSTR("tmag"), tmagMetaData);
    CFRelease(tmagMetaData);
    int numberOfDimensions = 0;
    for(int i=0;i<4;i++) if(tecmag->actual_npts[i]>1) numberOfDimensions++;
    
    if(numberOfDimensions==0) numberOfDimensions = 1;
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    for(CFIndex iDim = 0; iDim<numberOfDimensions; iDim++) {
        double observe_frequency =tecmag->ob_freq[iDim];
        observe_frequency *= 1e7;
        observe_frequency = floor(observe_frequency);
        observe_frequency /= 1e7;
        
        CFStringRef quantityName, inverseQuantityName;
        PSScalarRef increment, originOffset, inverseOriginOffset;
        if(tecmag2 && tecmag2->fft_flag[iDim]) {
            quantityName = CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityFrequency);
            inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            PSScalarRef dwell = PSScalarCreateWithDouble(tecmag->dwell[iDim], seconds);
            PSScalarRef temp = PSScalarCreateByRaisingToAPower(dwell, -1, error);
            increment = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 1./(double) tecmag->actual_npts[iDim]);
            CFRelease(temp);
            CFRelease(dwell);
            originOffset = PSScalarCreateWithDouble(observe_frequency, megahertz);
            inverseOriginOffset = PSScalarCreateWithDouble(0.0, seconds);
        }
        else {
            quantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
            increment = PSScalarCreateWithDouble(tecmag->dwell[iDim], seconds);
            originOffset = PSScalarCreateWithDouble(0.0, seconds);
            inverseOriginOffset = PSScalarCreateWithDouble(observe_frequency, megahertz);
        }
        
        PSDimensionRef theDimension = PSLinearDimensionCreateDefault(tecmag->actual_npts[iDim], increment, quantityName);
        PSDimensionSetOriginOffset(theDimension, originOffset);
        PSDimensionSetInverseOriginOffset(theDimension, inverseOriginOffset);
        PSDimensionSetInverseQuantityName(theDimension, inverseQuantityName);
        if(!PSScalarIsZero(PSDimensionGetInverseOriginOffset(theDimension))) {
            PSDimensionSetInverseMadeDimensionless(theDimension, true);
        }
        PSDimensionMakeNiceUnits(theDimension);
        CFArrayAppendValue(dimensions, theDimension);
        CFRelease(theDimension);
    }
    
    PSDatasetRef theDataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(theDataset, dimensions, NULL);
    CFRelease(dimensions);

    PSDependentVariableRef theDependentVariable = PSDatasetAddDefaultDependentVariable(theDataset, CFSTR("scalar"),kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
    
    CFIndex sizeFromDimensions = PSDependentVariableSize(theDependentVariable);
    CFMutableDataRef values = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataAppendBytes(values, data, size*sizeof(float complex));
    if(sizeFromDimensions != size) CFDataSetLength(values, sizeFromDimensions*sizeof(float complex));
    PSDependentVariableSetComponentAtIndex(theDependentVariable, values, 0);
    CFRelease(values);
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    PSPlotReset(thePlot);
    PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);

    CFMutableDictionaryRef nmrDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(nmrDatasetMetaData, CFSTR("Tecmag"), tecmagDatasetMetaData);
    CFRelease(tecmagDatasetMetaData);
    
    CFMutableDictionaryRef datasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(datasetMetaData, CFSTR("NMR"), nmrDatasetMetaData);
    CFRelease(nmrDatasetMetaData);
    
    PSUnitRef kelvin = PSUnitByParsingSymbol(CFSTR("K"), NULL, error);
    PSScalarRef metaCoordinate = PSScalarCreateWithDouble(tecmag->actual_temperature, kelvin);
    CFDictionaryAddValue(datasetMetaData, kPSQuantityTemperature, metaCoordinate);
    CFRelease(metaCoordinate);
    
    PSUnitRef tesla = PSUnitByParsingSymbol(CFSTR("T"), NULL, error);
    metaCoordinate = PSScalarCreateWithDouble(tecmag->magnet_field, tesla);
    CFDictionaryAddValue(datasetMetaData, kPSQuantityMagneticFluxDensity, metaCoordinate);
    CFRelease(metaCoordinate);
    
    PSDatasetSetMetaData(theDataset, datasetMetaData);
    CFRelease(datasetMetaData);
    
    free(tecmag);
    free(tecmag2);
    
    return theDataset;
}

