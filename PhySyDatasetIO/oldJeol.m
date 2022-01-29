//
//  PSDatasetImportJOEL.c
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

enum jeol_parameter_list {
    filename,
    title,
    author,
    creation,
    revision,
    content,
    instrument,
    site,
    nodename,
    dimensions,
    format_version,
    storage,
    endian,
    x_format,
    x_curr_points,
    x_start,
    x_stop,
    x_title,
    x_zero_point,
    x_freq_flip,
    x_points,
    x_prescans,
    x_domain,
    x_offset,
    x_freq,
    x_sweep,
    x_resolution,
    solvent,
    temp_get,
    acq_delay,
    digital_filter,
    filter_factor,
    filter_width,
    filter_mode,
    transition_ratio,
    orders,
    factors,
    lock_strength,
    lock_level,
    lock_gain,
    lock_osc_offset,
    lock_phase,
    lock_osc_state,
    x_angle,
    x90,
    x90_hi,
    x90_lo,
    x_90_width,
    x_pulse,
    relaxation_delay,
    scans,
    probe_id,
    iterations,
    field_strength,
    temp_set,
    spin_set,
    spin_get,
    he_level,
    n2_level,
    changer_sample,
    adc_card,
    experiment,
    obs_noise,
    irr_noise,
    tri_noise,
    qua_noise,
    obs_pwidth,
    irr_pwidth,
    tri_pwidth,
    qua_pwidth,
    irr_domain,
    irr_freq,
    recvr_gain,
    irr90,
    tri90,
    qua90,
    irr90_hi,
    qua90_hi,
    irr90_lo,
    tri90_lo,
    qua90_lo,
    irr_offset,
    mod_return,
    total_scans,
    x_acq_duration,
    delay_of_start,
    actual_start_time,
    clipped,
    dc_balanced,
    tri90_hi,
    spin_lock_90,
    spin_lock_attn,
    deut_grad_shim_90,
    deut_grad_shim_attn,
    irr_code,
    lock_state,
    autolock_level,
    sawtooth_range,
    lock_status,
    lock_settle_point,
    lock_achieve_point,
    spin_action,
    spin_state,
    spin_status,
    spin_gas_source,
    temp_action,
    temp_state,
    temp_status,
    temp_comp,
    temp_delay,
    temp_limit_hi,
    temp_limit_lo,
    temp_melting,
    temp_boiling,
    temp_ramp_step,
    temp_ramp_wait,
    temp_ambient,
    sample_action,
    sample_state,
    sample_status,
    autoshim_mode,
    autoshim_delay,
    autoshim_track,
    shim_max_recall,
    shim_names,
    num_scans,
    end_time,
    local_time,
    probe_atn,
    probe_tune,
    probe_match,
    probe_coarse,
    lf_tune_dial,
    lf_match_dial,
    hf_tune_dial,
    hf_match_dial,
    pass_ripple,
    stop_ripple,
    probe_recovery,
    af_delay_ratio,
    version,
    x_acq_time,
    dead_time,
    delay,
    phase_preset,
    unblank_time,
    initial_wait
};

#pragma pack(push)  /* push current alignment to stack */
#pragma pack(1)     /* set alignment to 1 byte boundary */

typedef union
{
    char strin[16];
    int integ;
    double doubl;
    double complx[2];
    int infinity;
} jeol_value;

typedef struct jeol_parameter_header
{
    unsigned int parameter_size;
    unsigned int low_index;
    unsigned int high_index;
    unsigned int total_size;
} jeol_parameter_header;

typedef struct jeol_parameter
{
    unsigned int class_structure;
    unsigned short unit_scaler;
    char units[10];
    jeol_value unit_value;
    int value_type;
    char name[28];
} jeol_parameter;

typedef struct file_info
{
    uint8_t *translate;
    uint32_t *offset_start;
    uint32_t *offset_stop;
    uint8_t *submatrices;
    int32_t submatrix_edge;
    int32_t submatrix_size;
    uint32_t section_spacing;
    uint32_t number_of_data_sections;
    uint64_t data_length;
    uint32_t data_start;
    uint8_t ddn;
    uint8_t data_type;
} file_info;

#pragma pack(pop)   /* restore original alignment from stack */

typedef enum dataAxisType {
    joelNone = 0,
    joelReal,
    joelTPPI,
    joelComplex,
    joelRealComplex,
    joelEnvelope
} dataAxisType;

typedef enum dataFormat {
    joelVoid = 0,
    joelOne_D,
    joelTwo_D,
    joelThree_D,
    joelFour_D,
    joelFive_D,
    joelSix_D,
    joelSeven_D,
    joelEight_D,
    joelVoid1,
    joelVoid2,
    joelVoid3,
    joelSmall_Two_D,
    joelSmall_Three_D,
    joelSmall_Four_D
} dataFormat;

typedef enum dataUnitBase {
    joelUnit_None = 0,
    joelUnit_Abundance,
    joelUnit_Ampere,
    joelUnit_Candela,
    joelUnit_dC,
    joelUnit_Coulomb,
    joelUnit_deg,
    joelUnit_Electronvolt,
    joelUnit_Farad,
    joelUnit_Sievert,
    joelUnit_Gram,
    joelUnit_Gray,
    joelUnit_Henry,
    joelUnit_Hz,
    joelUnit_Kelvin,
    joelUnit_Joule,
    joelUnit_Liter,
    joelUnit_Lumen,
    joelUnit_Lux,
    joelUnit_Meter,
    joelUnit_Mole,
    joelUnit_Newton,
    joelUnit_Ohm,
    joelUnit_Pascal,
    joelUnit_Percent,
    joelUnit_Point,
    joelUnit_ppm,
    joelUnit_Radian,
    joelUnit_s,
    joelUnit_Siemens,
    joelUnit_Steradian,
    joelUnit_T,
    joelUnit_Volt,
    joelUnit_Watt,
    joelUnit_Weber,
    joelUnit_dB,
    joelUnit_Dalton,
    joelUnit_Thompson,
    joelUnit_Ugeneric,
    joelUnit_LPercent,
    joelUnit_PPT,
    joelUnit_PPB,
    joelUnit_Index
} dataUnitBase;

typedef enum dataUnitPrefix {
    joelUnitPrefix_Yotta,
    joelUnitPrefix_Zetta,
    joelUnitPrefix_Exa,
    joelUnitPrefix_Pecta,
    joelUnitPrefix_Tera,
    joelUnitPrefix_G,
    joelUnitPrefix_M,
    joelUnitPrefix_K,
    joelUnitPrefix_None,
    joelUnitPrefix_m,
    joelUnitPrefix_u,
    joelUnitPrefix_n,
    joelUnitPrefix_p,
    joelUnitPrefix_Femto,
    joelUnitPrefix_Atto,
    joelUnitPrefix_Zepto,
} dataUnitPrefix;


#define HINIBBLE(b) (((b) >> 4) & 0x0F)
#define LONIBBLE(b) ((b) & 0x0F)

static uint32_t file_offset(file_info f_info, const CFIndex position[])
{
    uint32_t pos[8] = {0,0,0,0,0,0,0,0};
    uint32_t posi = 0;
    uint32_t sub_off = 0;
    uint32_t pnt_off = 0;
    
    for (int i=0; i<f_info.ddn; i++) {
        int k = f_info.translate[i]-1;
        posi = (uint32_t) position[i];
        pos[k] = posi;
    }
    
    uint32_t sub_edge = f_info.submatrix_edge;
    uint32_t sub_size = f_info.submatrix_size;
    uint32_t sub_mats;
    uint32_t off_start;
    for (int i=(f_info.ddn-1); i>=1; i--) {
        off_start = f_info.offset_start[i];
        sub_mats = f_info.submatrices[i-1];
        posi = pos[i] + off_start;
        pnt_off = (pnt_off + (posi % sub_edge)) * sub_edge;
        sub_off = (sub_off + (posi / sub_edge)) * sub_mats;
    }
    posi = pos[0] + f_info.offset_start[0];
    pnt_off += posi % sub_edge;
    sub_off += posi / sub_edge;
// THIS is the spot we need to identify as 32 (4 byte) or 64bit (8 byte)
// using f_info.data_type
    return f_info.data_type * ((sub_off * sub_size) + pnt_off);
}

static uint32_t data_fill_recursion(uint32_t t_range[],
                                    file_info f_info,
                                    CFIndex indexes[],
                                    int8_t nth_loop,
                                    const UInt8 buffer[],
                                    uint8_t endian,
                                    CFMutableDataRef component,
                                    CFArrayRef dimensions)
{
    
    if (nth_loop>=0) {
        int8_t current_loop = nth_loop;
        if (t_range[current_loop]>0) {
            nth_loop--;
            for (indexes[current_loop]=0; indexes[current_loop]<=t_range[current_loop]; indexes[current_loop]++) {
                data_fill_recursion(t_range, f_info, indexes, nth_loop, buffer, endian, component, dimensions);
            }
        } else {
            nth_loop--;
            data_fill_recursion(t_range, f_info, indexes, nth_loop, buffer, endian, component, dimensions);
        }
    } else {
        uint32_t jeol_position = file_offset(f_info,indexes) + f_info.data_start;
        
        // JOEL saves responses as double complex.  We're going to convert it back to float complex
        double complex value = 0.0;
        
        if ( 4==f_info.data_type ) {
            // This part added to handle 32 bit floating point data
            for (int i=0; i<f_info.number_of_data_sections; i++) {
                if (jeol_position<(f_info.data_length+f_info.data_start)) {
                    UInt32 temp = 0;
                    if(endian == 0) temp = CFSwapInt32(*((UInt32 *) &(buffer[jeol_position])));
                    else temp = *((UInt32 *) &(buffer[jeol_position]));
                    float temp_float = *((float *) &temp);
                    if (i%2) {
                        value += ((double) temp_float)*I;
                    } else {
                        value += ((double) temp_float);
                    }
                    if (i<f_info.number_of_data_sections) {
                        jeol_position += f_info.section_spacing;
                    }
                }
            }
        }
        else {
            for (int i=0; i<f_info.number_of_data_sections; i++) {
                if (jeol_position<(f_info.data_length+f_info.data_start)) {
                    UInt64 temp = 0;
                    if(endian == 0) temp = CFSwapInt64(*((UInt64 *) &(buffer[jeol_position])));
                    else temp = *((UInt64 *) &(buffer[jeol_position]));
                    if (i%2) {
                        value += (*((double *)&temp))*I;
                    } else {
                        value += (*((double *)&temp));
                    }
                    if (i<f_info.number_of_data_sections) {
                        jeol_position += f_info.section_spacing;
                    }
                }
            }
        }
        
        CFDataRef indexData = CFDataCreate(kCFAllocatorDefault, (const UInt8 *) indexes, 8*sizeof(int32_t));
        PSIndexArrayRef coordinateIndexes = PSIndexArrayCreateWithData(indexData);
        CFRelease(indexData);
        CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, coordinateIndexes);
        float complex *responses = (float complex *) CFDataGetMutableBytePtr(component);
        responses[memOffset] = (float complex) value;
        CFRelease(coordinateIndexes);
    }
    return 1;
}

PSDatasetRef PSDatasetImportJOELCreateSignalWithData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    const UInt8 *buffer = CFDataGetBytePtr((CFDataRef) contents);
    
    CFMutableDictionaryRef jeolDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    char file_identifier[8];
    int32_t count = 0;
    memcpy(file_identifier, &buffer[count],8);

    uint8_t endian;
    count = 8;
    memcpy(&endian, &buffer[count],1);

    uint8_t major_version;
    count = 9;
    memcpy(&major_version, &buffer[count],1);

    uint16_t minor_version;
    count = 10;
    memcpy(&minor_version, &buffer[count],2);

    // *** Number of Dimensions
    uint8_t data_dimension_number;
    count = 12;
    memcpy(&data_dimension_number, &buffer[count],1);

    uint8_t data_dimension_exist;
    count = 13;
    memcpy(&data_dimension_exist, &buffer[count],1);
    
    file_info f_info;

    // *** Important value for importing data
    uint8_t temp;
    count = 14;
    memcpy(&temp, &buffer[count],1);
    if ( 1 == (temp>>6) ) {
        f_info.data_type = 4;
    } else {
        f_info.data_type = 8;
    }
    uint8_t temp2 = temp<<2;
    temp = temp2>>2;
    dataFormat data_format = temp;

    uint8_t instrument;
    count = 15;
    memcpy(&instrument, &buffer[count],1);
    CFStringRef stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%ud"),instrument);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("instrument"), stringValue);
    CFRetain(stringValue);
    
    uint8_t translate[8];
    count = 16;
    memcpy(translate, &buffer[count],8);
    f_info.translate = translate;

    uint8_t data_axis_type[8];
    count = 24;
    memcpy(data_axis_type, &buffer[count],8);

    int8_t data_unit_prefix[8];
    int8_t data_unit_power[8];
    uint8_t data_unit[8];
    count = 32;
    for(int8_t i=0;i<8;i++) {
        uint8_t temp;
        memcpy(&temp, &buffer[count],1);
        count ++;
        data_unit_prefix[i] = HINIBBLE(temp);
        data_unit_power[i] = LONIBBLE(temp);
        memcpy(&data_unit[i], &buffer[count],1);
        uint8_t test = data_unit[i];
        count ++;
    }
    
    char title[124];
    count = 48;
    memcpy(title, &buffer[count],124);

    uint8_t data_axis_ranged[4];
    count = 172;
    memcpy(data_axis_ranged, &buffer[count],4);

    // *** data_points holds the npts for each dimension
    // These need byte swap to correct endian
    uint32_t data_points[8];
    count = 176;
    memcpy(data_points, &buffer[count],32);
    for(int8_t i = 0 ;i<8; i++) data_points[i] = CFSwapInt32(*((UInt32 *) &(data_points[i])));
    
    // These need byte swap to correct endian
    uint32_t data_offset_start[8];
    count = 208;
    memcpy(data_offset_start, &buffer[count],32);
    for(int8_t i = 0 ;i<8; i++) data_offset_start[i] = CFSwapInt32(*((UInt32 *) &(data_offset_start[i])));
    f_info.offset_start = data_offset_start;
    
    // These need byte swap to correct endian
    uint32_t data_offset_stop[8];
    count = 240;
    memcpy(data_offset_stop, &buffer[count],32);
    for(int8_t i = 0 ;i<8; i++) data_offset_stop[i] = CFSwapInt32(*((UInt32 *) &(data_offset_stop[i])));
    f_info.offset_stop = data_offset_stop;
    
    // *** data_points holds the first coordinate value for each dimension
    // These need byte swap to correct endian
    double data_axis_start[8];
    count = 272;
    for(int8_t i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[count])));
        data_axis_start[i] = *((double *)&temp);
        count += 8;
    }
    
    // *** data_points holds the last coordinate value for each dimension
    // These need byte swap to correct endian
    double data_axis_stop[8];
    count = 336;
    for(int8_t i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[count])));
        data_axis_stop[i] = *((double *)&temp);
        count += 8;
    }
    
    uint16_t creation_data;
    count = 400;
    memcpy(&creation_data, &buffer[count],2);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%ud"),creation_data);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("creation_data"), stringValue);
    CFRelease(stringValue);

    uint16_t creation_time;
    count = 402;
    memcpy(&creation_time, &buffer[count],2);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%ud"),creation_time);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("creation_time"), stringValue);
    CFRelease(stringValue);
    
    uint16_t revision_data;
    count = 404;
    memcpy(&revision_data, &buffer[count],2);

    uint16_t revision_time;
    count = 406;
    memcpy(&revision_time, &buffer[count],2);

    char node_name[16];
    count = 408;
    memcpy(node_name, &buffer[count],16);

    char site[128];
    count = 424;
    memcpy(site, &buffer[count],128);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),site);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("site"), stringValue);
    CFRelease(stringValue);
    
    char author[128];
    count = 552;
    memcpy(author, &buffer[count],128);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),author);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("author"), stringValue);
    CFRelease(stringValue);
    
    char comment[128];
    count = 680;
    memcpy(comment, &buffer[count],128);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),comment);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("comment"), stringValue);
    CFRelease(stringValue);
    
    char data_axis_title1[32];
    count = 808;
    memcpy(data_axis_title1, &buffer[count],32);

    char data_axis_title2[32];
    count = 840;
    memcpy(data_axis_title2, &buffer[count],32);

    char data_axis_title3[32];
    count = 872;
    memcpy(data_axis_title3, &buffer[count],32);

    char data_axis_title4[32];
    count = 904;
    memcpy(data_axis_title4, &buffer[count],32);

    char data_axis_title5[32];
    count = 936;
    memcpy(data_axis_title5, &buffer[count],32);

    char data_axis_title6[32];
    count = 968;
    memcpy(data_axis_title6, &buffer[count],32);

    char data_axis_title7[32];
    count = 1000;
    memcpy(data_axis_title7, &buffer[count],32);

    char data_axis_title8[32];
    count = 1032;
    memcpy(data_axis_title8, &buffer[count],32);

    // *** data_points holds the spectrometer frequency for each dimension
    // These need byte swap to correct endian
    double base_freq[8];
    count = 1064;
    for(int8_t i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[count])));
        base_freq[i] = *((double *)&temp);
        count += 8;
        
        stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%g"),base_freq[i]);
        CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("base_freq"), stringValue);
        CFRelease(stringValue);
        
    }
    
    // These need byte swap to correct endian
    double zero_point[8];
    count = 1128;
    for(int8_t i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[count])));
        if(endian == 0) {
            temp = CFSwapInt64(*((UInt64 *) &(buffer[count])));
        }
        zero_point[i] = *((double *)&temp);
        count += 8;
    }
    
    uint8_t reversed[8];
    count = 1192;
    memcpy(reversed, &buffer[count],8);

    uint8_t reserved[3];
    count = 1200;
    memcpy(&reserved, &buffer[count],3);

    uint8_t annotation_ok;
    count = 1203;
    memcpy(&annotation_ok, &buffer[count],1);

    // These need byte swap to correct endian
    uint32_t history_used;
    count = 1204;
    memcpy(&history_used, &buffer[count],4);
    history_used = CFSwapInt32(*((UInt32 *) &(history_used)));
    
    // These need byte swap to correct endian
    uint32_t history_length;
    count = 1208;
    memcpy(&history_length, &buffer[count],4);
    history_length = CFSwapInt32(*((UInt32 *) &(history_length)));
    
    // These need byte swap to correct endian
    uint32_t param_start;
    count = 1212;
    memcpy(&param_start, &buffer[count],4);

    // These need byte swap to correct endian
    uint32_t param_length;
    count = 1216;
    memcpy(&param_length, &buffer[count],4);
    param_length = CFSwapInt32(*((UInt32 *) &(param_length)));
    
    // These need byte swap to correct endian
    uint32_t list_start[8];
    count = 1220;
    memcpy(list_start, &buffer[count],32);
    for(int8_t i = 0 ;i<8; i++) list_start[i] = CFSwapInt32(*((UInt32 *) &(list_start[i])));
    
    // These need byte swap to correct endian
    uint32_t list_length[8];
    count = 1252;
    memcpy(list_length, &buffer[count],32);
    for(int8_t i = 0 ;i<8; i++) list_length[i] = CFSwapInt32(*((UInt32 *) &(list_length[i])));
    
    // These need byte swap to correct endian
    uint32_t data_start;
    count = 1284;
    memcpy(&data_start, &buffer[count],4);
    data_start = CFSwapInt32(*((UInt32 *) &(data_start)));
    
    // These need byte swap to correct endian
    uint64_t data_length;
    count = 1288;
    memcpy(&data_length, &buffer[count],8);
    data_length = CFSwapInt64(*((UInt64 *) &(data_length)));
    
    // These need byte swap to correct endian
    uint64_t context_start;
    count = 1296;
    memcpy(&context_start, &buffer[count],8);
    context_start = CFSwapInt64(*((UInt64 *) &(context_start)));
    
    // These need byte swap to correct endian
    uint32_t context_length;
    count = 1304;
    memcpy(&context_length, &buffer[count],4);
    context_length = CFSwapInt32(*((UInt32 *) &(context_length)));
    
    // These need byte swap to correct endian
    uint64_t annote_start;
    count = 1308;
    memcpy(&annote_start, &buffer[count],8);
    annote_start = CFSwapInt64(*((UInt64 *) &(annote_start)));
    
    // These need byte swap to correct endian
    uint32_t annote_length;
    count = 1316;
    memcpy(&annote_length, &buffer[count],4);
    annote_length = CFSwapInt32(*((UInt32 *) &(annote_length)));
    
    // These need byte swap to correct endian
    uint64_t total_size;
    count = 1320;
    memcpy(&total_size, &buffer[count],8);
    total_size = CFSwapInt64(*((UInt64 *) &(total_size)));
    
    uint8_t unit_location[8];
    count = 1328;
    memcpy(unit_location, &buffer[count],8);

    uint8_t extended_units1[12];    /* 2 12-byte unit structures */
    count = 1336;
    memcpy(extended_units1, &buffer[count],12);

    uint8_t extended_units2[12];
    count = 1348;
    memcpy(extended_units2, &buffer[count],12);
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSUnitRef hertz = PSUnitForParsedSymbol(CFSTR("Hz"), NULL, error);
    PSUnitRef megahertz = PSUnitForParsedSymbol(CFSTR("MHz"), NULL, error);
    PSUnitRef seconds = PSUnitForParsedSymbol(CFSTR("s"), NULL,error);
    PSUnitRef ppm = PSUnitForParsedSymbol(CFSTR("ppm"), NULL,error);
    CFIndex size = 1;
    for(CFIndex idim = 0; idim<data_dimension_number; idim++) {
        CFIndex npts = data_points[idim];
        size *= npts;
        bool ftFlag = false;
        bool periodic = false;
        bool reverse = false;
        bool inverseReverse = false;
        bool madeDimensionless = false;
        bool inverseMadeDimensionless = false;
        CFStringRef quantityName, inverseQuantityName;
        PSScalarRef increment, originOffset, referenceOffset, inverseOriginOffset, inverseReferenceOffset;
        double finalValue = data_axis_stop[idim];
        double intialValue = data_axis_start[idim];
        double dwellTime = (finalValue - intialValue)/(npts-1);
        if(dwellTime<0) {
            dwellTime = fabs(dwellTime);
            reverse = true;
        }
        if(data_unit[idim] == joelUnit_s) {
            quantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
            increment = PSScalarCreateWithDouble(dwellTime, seconds);
            originOffset = PSScalarCreateWithDouble(intialValue, seconds);
            referenceOffset = PSScalarCreateWithDouble(0.0, seconds);
            inverseOriginOffset = PSScalarCreateWithDouble(base_freq[idim], megahertz);
            inverseReferenceOffset = PSScalarCreateWithDouble(0.0, hertz);
        }
        else if(data_unit[idim] == joelUnit_ppm) {
            quantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
            inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            originOffset = PSScalarCreateWithDouble(base_freq[idim], megahertz);
            increment = PSScalarCreateWithDouble(dwellTime, ppm);
            PSScalarMultiply((PSMutableScalarRef) increment, originOffset, error);
            PSScalarConvertToUnit((PSMutableScalarRef) increment, hertz, error);
            referenceOffset = PSScalarCreateWithDouble(intialValue, ppm);
            PSScalarMultiply((PSMutableScalarRef) referenceOffset, originOffset, error);
            PSScalarConvertToUnit((PSMutableScalarRef) referenceOffset, hertz, error);
            inverseOriginOffset = PSScalarCreateWithDouble(0.0, seconds);
            inverseReferenceOffset = PSScalarCreateWithDouble(0.0, seconds);
            madeDimensionless = true;
        }
        else {
            quantityName = CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityFrequency);
            inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            PSScalarRef dwell = PSScalarCreateWithDouble(dwellTime, seconds);
            PSScalarRef temp = PSScalarCreateByRaisingToAPower(dwell, -1, error);
            increment = PSScalarCreateByMultiplyingByDimensionlessRealConstant(temp, 1./(double) npts);
            CFRelease(temp);
            CFRelease(dwell);
            originOffset = PSScalarCreateWithDouble(base_freq[idim], megahertz);
            referenceOffset = PSScalarCreateWithDouble(intialValue, hertz);
            inverseOriginOffset = PSScalarCreateWithDouble(0.0, seconds);
            inverseReferenceOffset = PSScalarCreateWithDouble(0.0, seconds);
        }
        
        // Put the rest into NMR meta-data
        PSScalarRef sfreq = PSScalarCreateWithDouble(base_freq[idim], megahertz);
        PSScalarRef referenceFrequency = PSScalarCreateWithDouble(0.0, hertz);
        PSScalarRef referencePosition = PSScalarCreateWithDouble(0.0, hertz);
        
        CFMutableDictionaryRef jeolDimensionMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFStringRef temp = PSScalarCreateStringValue(sfreq);
        CFDictionaryAddValue(jeolDimensionMetaData, CFSTR("spectrometer frequency"), temp);
        CFRelease(temp);
        
        temp = PSScalarCreateStringValue(referenceFrequency);
        CFDictionaryAddValue(jeolDimensionMetaData, CFSTR("reference frequency"), temp);
        CFRelease(temp);
        
        temp = PSScalarCreateStringValue(referencePosition);
        CFDictionaryAddValue(jeolDimensionMetaData, CFSTR("reference position"), temp);
        CFRelease(temp);
        
        CFMutableDictionaryRef nmrDimensionMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFDictionaryAddValue(nmrDimensionMetaData, CFSTR("JOEL"), jeolDimensionMetaData);
        CFRelease(jeolDimensionMetaData);
        
        temp = PSScalarCreateStringValue(sfreq);
        CFDictionaryAddValue(nmrDimensionMetaData, CFSTR("receiver frequency"), temp);
        CFRelease(temp);
        
        CFMutableDictionaryRef dimensionMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(dimensionMetaData, CFSTR("NMR"), nmrDimensionMetaData);
        CFRelease(nmrDimensionMetaData);
        
        PSDimensionRef dim = PSLinearDimensionCreateDefault(data_points[idim], increment, quantityName);
        
        PSDimensionSetInverseQuantityName(dim,inverseQuantityName);
        PSDimensionSetOriginOffset(dim, originOffset);
        PSDimensionSetInverseOriginOffset(dim,inverseOriginOffset);
        PSDimensionSetReferenceOffset(dim, referenceOffset);
        PSDimensionSetInverseReferenceOffset(dim, inverseReferenceOffset);
        PSDimensionSetMetaData(dim, dimensionMetaData);
        PSDimensionSetFFT(dim, ftFlag);
        PSDimensionSetPeriodic(dim, true);
        PSDimensionSetMadeDimensionless(dim, madeDimensionless);
        PSDimensionSetInverseMadeDimensionless(dim, inverseMadeDimensionless);

        PSDimensionMakeNiceUnits(dim);
        CFRelease(quantityName);
        CFRelease(inverseQuantityName);
        CFRelease(increment);
        CFRelease(originOffset);
        CFRelease(inverseOriginOffset);
        CFRelease(dimensionMetaData);
        
        CFArrayAppendValue(dimensions, dim);
        CFRelease(dim);
    }
    
    
    CFMutableDictionaryRef nmrDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(nmrDatasetMetaData, CFSTR("JEOL"), jeolDatasetMetaData);
    CFRelease(jeolDatasetMetaData);

    CFMutableDictionaryRef datasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(datasetMetaData, CFSTR("NMR"), nmrDatasetMetaData);
    CFRelease(nmrDatasetMetaData);

    PSDatasetRef dataset = PSDatasetCreateDefault();
    PSDatasetSetDimensions(dataset, dimensions, NULL);
    CFRelease(dimensions);
    PSDatasetAddDefaultDependentVariable(dataset, CFSTR("scalar"), kPSNumberFloat32ComplexType, kPSDatasetSizeFromDimensions);
    PSDatasetSetMetaData(dataset, datasetMetaData);
    CFRelease(datasetMetaData);
    
    uint8_t submatrices[8] = {0,0,0,0,0,0,0,0};
    f_info.submatrices = submatrices;
    f_info.submatrix_edge = 8;
    f_info.submatrix_size = 8;

    uint32_t t_range[8];
    for (int i=0;i<8; i++) t_range[i] = f_info.offset_stop[i] - f_info.offset_start[i];
    
    switch (data_format) {
        case joelOne_D: {
            f_info.submatrix_edge = 8;
            f_info.submatrix_size = 8;
            break;
        }
        case joelTwo_D: {
            f_info.submatrix_edge = 32;
            f_info.submatrix_size = 1024;
            break;
        }
        case joelThree_D: {
            f_info.submatrix_edge = 8;
            f_info.submatrix_size = 512;
            break;
        }
        case joelFour_D: {
            f_info.submatrix_edge = 8;
            f_info.submatrix_size = 4096;
            break;
        }
        case joelFive_D: {
            f_info.submatrix_edge = 4;
            f_info.submatrix_size = 1024;
            break;
        }
        case joelSix_D: {
            f_info.submatrix_edge = 4;
            f_info.submatrix_size = 4096;
            break;
        }
            
        case joelSeven_D: {
            f_info.submatrix_edge = 2;
            f_info.submatrix_size = 128;
            break;
        }
            
        case joelEight_D: {
            f_info.submatrix_edge = 2;
            f_info.submatrix_size = 256;
            break;
        }
            
        case joelSmall_Two_D: {
            f_info.submatrix_edge = 4;
            f_info.submatrix_size = 16;
            break;
        }
            
        case joelSmall_Three_D: {
            f_info.submatrix_edge = 4;
            f_info.submatrix_size = 64;
            break;
        }
            
        case joelSmall_Four_D: {
            f_info.submatrix_edge = 4;
            f_info.submatrix_size = 256;
            break;
        }
        default:
            break;
        
    }
    for (int i=0; i<8; i++) f_info.submatrices[i] = data_points[i]/f_info.submatrix_edge;
    
    f_info.number_of_data_sections = 1;
    for (int i=0; i<8; i++) {
        switch (data_axis_type[i]) {
            case joelRealComplex:
            case joelEnvelope: {
                if (0==i) f_info.number_of_data_sections *= 2;
            } break;
                
            case joelComplex: {
                f_info.number_of_data_sections *= 2;
            } break;
                
            case joelReal:
            case joelNone:
            case joelTPPI:
            default: {
            } break;
        }
        
    }
    
    CFIndex indexes[8];
    for (int i=0; i<8; i++) indexes[i] = 0;
    
    f_info.section_spacing = (uint32_t) data_length/2;
    f_info.data_start = data_start;
    f_info.data_length = data_length;
    f_info.ddn = data_dimension_number;
    int8_t nth_loop = 7;
    
    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(dataset, 0);
    data_fill_recursion(t_range, f_info, indexes, nth_loop, buffer, endian,
                        PSDependentVariableGetComponentAtIndex(theDependentVariable, 0),
                        PSDatasetGetDimensions(dataset));
    
    
    PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
    PSPlotReset(thePlot);
    PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);

    return dataset;
}

