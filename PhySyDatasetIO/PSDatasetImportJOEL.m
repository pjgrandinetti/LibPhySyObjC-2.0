//
//  PSDatasetImportJOEL.c
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Updated by Jay Baltisberger on 2/8/2022
//  Copyright (c) 2022 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>
#define debugging_data 0
#define debugging_data2 0

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
    CFIndex parameter_size;
    CFIndex low_index;
    CFIndex high_index;
    CFIndex total_size;
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
    CFIndex translate[8];
    CFIndex endian;
    CFIndex ddn;
    CFIndex max_dim;
    CFIndex data_type;
    CFIndex number_of_data_sections;
    CFIndex offset_start[8];
    CFIndex offset_stop[8];
    CFIndex data_points[8];
    CFIndex t_range[8];
    CFIndex submatrices[8];
    CFIndex submatrix_edge;
    CFIndex submatrix_size;
    CFIndex section_spacing;
    CFIndex data_start;
    CFIndex annotate_length;
    CFIndex data_length;
    CFIndex annotate_start;
    CFIndex total_size;

    double axis_start[8];
    double axis_stop[8];
    double base_freq[8];
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
    joelUnitPrefix_Yotta, //10^24
    joelUnitPrefix_Zetta, //10^21
    joelUnitPrefix_Exa, //10^18
    joelUnitPrefix_Pecta, //10^15
    joelUnitPrefix_Tera, //10^12
    joelUnitPrefix_G, //10^9
    joelUnitPrefix_M, //10^6
    joelUnitPrefix_K, //10^3
    joelUnitPrefix_None, //10^0
    joelUnitPrefix_m, //10^-3
    joelUnitPrefix_u, //10^-6
    joelUnitPrefix_n, //10^-9
    joelUnitPrefix_p, //10^-12
    joelUnitPrefix_Femto, //10^-15
    joelUnitPrefix_Atto, //10^-18
    joelUnitPrefix_Zepto, //10^-21
} dataUnitPrefix;

#define HINIBBLE(b) (((b) >> 4) & 0x0F)
#define LONIBBLE(b) ((b) & 0x0F)

static CFIndex file_offset(file_info f_info, const CFIndex translated_indexes[])
{
    CFIndex sub_off = 0;
    CFIndex pnt_off = 0;
    CFIndex sub_edge = f_info.submatrix_edge;
    CFIndex sub_size = f_info.submatrix_size;
    CFIndex posi = 0;
    CFIndex sub_mats = 0;
    CFIndex off_start = 0;
    for(CFIndex i=7; i>0; i--) {
        off_start = f_info.offset_start[i];
        sub_mats = f_info.submatrices[i-1];
        posi = translated_indexes[i] + off_start;
        pnt_off = (pnt_off + (posi % sub_edge)) * sub_edge;
        sub_off = (sub_off + (posi / sub_edge)) * sub_mats;
    }
    posi = translated_indexes[0] + f_info.offset_start[0];
    pnt_off += posi % sub_edge;
    sub_off += posi / sub_edge;

    if (debugging_data2) {
        printf("{%4d", (int) translated_indexes[0]);
        for(int8_t i = 1; i < 8; i++) {
            printf(", %4d", (int) translated_indexes[i]);
        }
        printf("} - %d, %d, %d\n", (int) sub_off, (int) sub_size, (int) pnt_off);
    }

// identify as 32 (4 byte) or 64bit (8 byte) using f_info.data_type
    return f_info.data_type * ((sub_off * sub_size) + pnt_off);
}

static CFIndex data_fill_recursion(file_info f_info,
                                   CFIndex indexes[],
                                   CFIndex nth_loop,
                                    const UInt8 buffer[],
                                    CFMutableDataRef component,
                                    CFArrayRef dimensions)
{
    
    if (nth_loop >= 0) {
        CFIndex current_loop = nth_loop;
        if (f_info.t_range[current_loop]>0) {
            nth_loop--;
            CFIndex loop_stop = f_info.t_range[current_loop] +
                                f_info.offset_start[current_loop];
            for(indexes[current_loop] = f_info.offset_start[current_loop];
                indexes[current_loop] <= loop_stop;
                indexes[current_loop]++) {
                    data_fill_recursion(f_info, indexes, nth_loop, buffer, component, dimensions);
            }
        } else {
            indexes[current_loop] = 0;
            nth_loop--;
            data_fill_recursion(f_info, indexes, nth_loop, buffer, component, dimensions);
        }
    } else {

        CFIndex do_print = 0;
        if (debugging_data) {
            for(CFIndex i = 0; i < f_info.max_dim; i++) {
                CFIndex maxPos = f_info.offset_stop[i];
                if ( f_info.offset_start[i] == indexes[i] ) do_print += 1;
                if (maxPos>0) {
                    if ( maxPos == indexes[i] ) do_print += 1;
                    CFIndex maxPos2 = (maxPos+1)/2;
                    if ( maxPos2 == indexes[i] ) do_print += 1;
                }
            }
        }

        CFIndex translated_indexes[8] = {0,0,0,0,0,0,0,0};
        CFIndex posi = 0;
        for(CFIndex i=0; i<8; i++) {
            CFIndex k = f_info.translate[i]-1;
            posi = (CFIndex) indexes[i];
            translated_indexes[k] = posi;
        }

        if (debugging_data) {
            if ( f_info.max_dim==do_print) {
                printf("{%4d", (int) indexes[0]);
                for(int8_t i = 1; i < f_info.max_dim; i++) {
                    printf(", %4d", (int) indexes[i]);
                }
                printf("} -> ");
                printf("{%4d", (int) translated_indexes[0]);
                for(int8_t i = 1; i < f_info.max_dim; i++) {
                    printf(", %4d", (int) translated_indexes[i]);
                }
                printf("} ");
            }
        }

        CFIndex jeol_position = file_offset(f_info, translated_indexes);
        if (debugging_data) {
            if ( f_info.max_dim==do_print) {
                printf(" : %11d\t%11d\t",(int) jeol_position,
                       (int) (jeol_position/f_info.data_type));
                printf(" :\t");
            }
        }

        jeol_position += f_info.data_start;
// JOEL saves responses as double complex.  We're going to convert it back to float complex
        double complex value = 0.0;

        if ( 4==f_info.data_type ) {
// This part added to handle 32 bit floating point data
            for(CFIndex i=0; i<f_info.number_of_data_sections; i++) {
                if (jeol_position<(f_info.data_length+f_info.data_start)) {
                    UInt32 temp = 0;
                    if(f_info.endian == 0) temp = CFSwapInt32(*((UInt32 *) &(buffer[jeol_position])));
                    else temp = *((UInt32 *) &(buffer[jeol_position]));
                    float temp_float = *((float *) &temp);
                    if (i%2) {
                        value -= ((double) temp_float)*I;
                    } else {
                        value += ((double) temp_float);
                    }
// Seems to be a problem if the number of datasections is >2 for hypercomplex data
                    if (i<f_info.number_of_data_sections) {
                        jeol_position += f_info.section_spacing;
                    }
                }
            }
        } else {
// Normal import for 64 bit floating point data
            for(CFIndex i=0; i<f_info.number_of_data_sections; i++) {
                if (jeol_position<(f_info.data_length+f_info.data_start)) {
                    UInt64 temp = 0;
                    if(f_info.endian == 0) temp = CFSwapInt64(*((UInt64 *) &(buffer[jeol_position])));
                    else temp = *((UInt64 *) &(buffer[jeol_position]));
                    if (i%2) {
                        value -= (*((double *)&temp))*I;
                    } else {
                        value += (*((double *)&temp));
                    }
// Seems to be a problem if the number of datasections is >2 for hypercomplex data
                    if (i<f_info.number_of_data_sections) {
                        jeol_position += f_info.section_spacing;
                    }
                }
            }
        }

        PSIndexArrayRef coordinateIndexes = PSIndexArrayCreate(translated_indexes, 8);
        CFIndex memOffset = PSDimensionMemOffsetFromCoordinateIndexes(dimensions, coordinateIndexes);
        float complex *responses = (float complex *) CFDataGetMutableBytePtr(component);
        responses[memOffset] = (float complex) value;

        if (debugging_data) {
            if ( f_info.max_dim==do_print) {
                printf("%lf\t%lfI\n",creal(value),cimag(value));
                printf("Initial Memory Offset: %d -> {", (int) memOffset);
                printf("%4d", (int) PSIndexArrayGetValueAtIndex(coordinateIndexes, 0));
                for(CFIndex i = 1; i < f_info.max_dim; i++) {
                    printf(", %4d", (int) PSIndexArrayGetValueAtIndex(coordinateIndexes, i));
                }
                printf("}\n");
            }
        }
        CFRelease(coordinateIndexes);
    }
    return 1;
}

PSDatasetRef PSDatasetImportJOELCreateSignalWithData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    const UInt8 *buffer = CFDataGetBytePtr((CFDataRef) contents);
    
    CFMutableDictionaryRef jeolDatasetMetaData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    char file_identifier[9];
    memcpy(file_identifier, &buffer[0],8);

    uint8_t host_endian = (*(uint16_t *)"\0\xff" < 0x100);

    file_info f_info;
    uint8_t temp;
    memcpy(&temp, &buffer[8],1);
    f_info.endian = (CFIndex) temp;

    uint8_t major_version;
    memcpy(&major_version, &buffer[9],1);

    uint16_t minor_version;
    memcpy(&minor_version, &buffer[10],2);

    // *** Number of Dimensions
    uint8_t data_dimension_number;
    memcpy(&data_dimension_number, &buffer[12],1);

    uint8_t data_dimension_exist[8];
    memcpy(&temp, &buffer[13],1);
    for(CFIndex i=0; i<8; i++) {
        data_dimension_exist[7-i] = (temp & ( 1 << i )) >> i;
    }

    memcpy(&temp, &buffer[14],1);
    if ( 1 == (temp>>6) ) {
        f_info.data_type = 4;
    } else {
        f_info.data_type = 8;
    }
    uint8_t temp2 = temp<<2;
    temp = temp2>>2;
    dataFormat data_format = temp;

    uint8_t instrument;
    memcpy(&instrument, &buffer[15],1);
    CFStringRef stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%ud"),instrument);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("instrument"), stringValue);
    CFRetain(stringValue);
    
    uint8_t translate[8];
    memcpy(translate, &buffer[16],8);
    for(CFIndex i=0; i<8; i++) {
        f_info.translate[i] = (CFIndex) translate[i];
    }

    uint8_t data_axis_type[8];
    memcpy(data_axis_type, &buffer[24],8);

    int8_t data_unit_prefix[8];
    int8_t data_unit_power[8];
    uint8_t data_unit[8];
    int8_t temp_prefix;
    for(CFIndex i=0; i<8; i++) {
        uint8_t temp;
        memcpy(&temp, &buffer[32+2*i],1);
        temp_prefix = (int8_t) HINIBBLE(temp);
        if (temp_prefix>7) temp_prefix -= 16;
        data_unit_prefix[i] = -3*temp_prefix;
        data_unit_power[i] = LONIBBLE(temp);
        memcpy(&temp, &buffer[33+2*i],1);
        data_unit[i] = temp;
    }
    
    char title[124];
    memcpy(title, &buffer[48],124);

    uint8_t data_axis_ranged[4];
    memcpy(data_axis_ranged, &buffer[172],4);

// All of the JEOL Header data is in Big Endian and needs to be swapped
// for a Little Endian program (i.e. Mac)
    uint32_t data_points[8];
    memcpy(data_points, &buffer[176],32);
    if (debugging_data) printf("Data Points: {");
    for(CFIndex i = 0; i<8; i++) {
        data_points[i] = CFSwapInt32(*((UInt32 *) &(data_points[i])));
        f_info.data_points[i] = (CFIndex) data_points[i];
        if (debugging_data) {
            if (i<7) printf("%d, ", (int) f_info.data_points[i]); else printf("%d}\n", (int) f_info.data_points[7]);
        }
    }

    uint32_t data_offset_start[8];
    memcpy(data_offset_start, &buffer[208],32);
    for(CFIndex i = 0; i<8; i++) {
        data_offset_start[i] = CFSwapInt32(*((UInt32 *) &(data_offset_start[i])));
        f_info.offset_start[i] = (CFIndex) data_offset_start[i];
    }

    uint32_t data_offset_stop[8];
    memcpy(data_offset_stop, &buffer[240],32);
    for(CFIndex i = 0; i<8; i++) {
        data_offset_stop[i] = CFSwapInt32(*((UInt32 *) &(data_offset_stop[i])));
        f_info.offset_stop[i] = (CFIndex) data_offset_stop[i];
    }

    uint32_t t_range[8];
    if (debugging_data) printf("Translated Range: {");
    for(CFIndex i = 0; i<8; i++) {
        uint8_t t_dim = f_info.translate[i]-1;
        t_range[i] = data_offset_stop[t_dim] - data_offset_start[t_dim];
        if (debugging_data) {
            if (i<7) printf("%u, ",t_range[i]); else printf("%u}\n",t_range[7]);
        }
        f_info.t_range[i] = (CFIndex) t_range[i];
    }

    double data_axis_start[8];
    for(CFIndex i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[272+8*i])));
        data_axis_start[i] = *((double *)&temp);
    }
    
    double data_axis_stop[8];
    for(CFIndex i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[336+8*i])));
        data_axis_stop[i] = *((double *)&temp);
    }

// these also need to be endian swapped depending on what happens in the functions
    uint16_t creation_data;
    memcpy(&creation_data, &buffer[400],2);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%ud"),creation_data);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("creation_data"), stringValue);
    CFRelease(stringValue);

    uint16_t creation_time;
    memcpy(&creation_time, &buffer[402],2);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%ud"),creation_time);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("creation_time"), stringValue);
    CFRelease(stringValue);
    
    uint16_t revision_data;
    memcpy(&revision_data, &buffer[404],2);

    uint16_t revision_time;
    memcpy(&revision_time, &buffer[406],2);

    char node_name[16];
    memcpy(node_name, &buffer[408],16);

    char site[128];
    memcpy(site, &buffer[424],128);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),site);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("site"), stringValue);
    CFRelease(stringValue);
    
    char author[128];
    memcpy(author, &buffer[552],128);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),author);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("author"), stringValue);
    CFRelease(stringValue);
    
    char comment[128];
    memcpy(comment, &buffer[680],128);
    stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%s"),comment);
    CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("comment"), stringValue);
    CFRelease(stringValue);
    
    char data_axis_title1[32];
    memcpy(data_axis_title1, &buffer[808],32);

    char data_axis_title2[32];
    memcpy(data_axis_title2, &buffer[840],32);

    char data_axis_title3[32];
    memcpy(data_axis_title3, &buffer[872],32);

    char data_axis_title4[32];
    memcpy(data_axis_title4, &buffer[904],32);

    char data_axis_title5[32];
    memcpy(data_axis_title5, &buffer[936],32);

    char data_axis_title6[32];
    memcpy(data_axis_title6, &buffer[968],32);

    char data_axis_title7[32];
    memcpy(data_axis_title7, &buffer[1000],32);

    char data_axis_title8[32];
    memcpy(data_axis_title8, &buffer[1032],32);

    double base_freq[8];
    for(CFIndex i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[1064+8*i])));
        base_freq[i] = *((double *)&temp);

        stringValue = CFStringCreateWithFormat (kCFAllocatorDefault,NULL,CFSTR("%g"),base_freq[i]);
        CFDictionaryAddValue(jeolDatasetMetaData, CFSTR("base_freq"), stringValue);
        CFRelease(stringValue);
    }
    
// need to consider if Mac was ever Big endian (host_endian==1 instead of 0)
// how do we fix things that are little endian and need to be made big
// versus big that need to be little
// basically EVERYTHING in the Header section is stored BIG endian and needs
// to be switched on a LITTLE endian machine (like a Mac for now)
    double zero_point[8];
    for(CFIndex i = 0; i<8; i++) {
        UInt64 temp = CFSwapInt64(*((UInt64 *) &(buffer[1128])));
        if(1==host_endian) {
            temp = CFSwapInt64(*((UInt64 *) &(buffer[1128])));
        }
        zero_point[i] = *((double *)&temp);
    }
    
    uint8_t reversed[8];
    memcpy(reversed, &buffer[1192],8);

    uint8_t reserved[3];
    memcpy(&reserved, &buffer[1200],3);

    uint8_t annotation_ok;
    memcpy(&annotation_ok, &buffer[1203],1);

    uint32_t history_used;
    memcpy(&history_used, &buffer[1204],4);
    history_used = CFSwapInt32(*((UInt32 *) &(history_used)));
    
    uint32_t history_length;
    memcpy(&history_length, &buffer[1208],4);
    history_length = CFSwapInt32(*((UInt32 *) &(history_length)));
    
    uint32_t param_start;
    memcpy(&param_start, &buffer[1212],4);
    param_start = CFSwapInt32(*((UInt32 *) &(param_start)));

    uint32_t param_length;
    memcpy(&param_length, &buffer[1216],4);
    param_length = CFSwapInt32(*((UInt32 *) &(param_length)));
    
    uint32_t list_start[8];
    memcpy(list_start, &buffer[1220],32);
    for(CFIndex i = 0; i<8; i++) list_start[i] = CFSwapInt32(*((UInt32 *) &(list_start[i])));
    
    uint32_t list_length[8];
    memcpy(list_length, &buffer[1252],32);
    for(CFIndex i = 0 ;i<8; i++) list_length[i] = CFSwapInt32(*((UInt32 *) &(list_length[i])));
    
    uint32_t data_start;
    memcpy(&data_start, &buffer[1284],4);
    data_start = CFSwapInt32(*((UInt32 *) &(data_start)));
    
    uint64_t data_length;
    memcpy(&data_length, &buffer[1288],8);
    data_length = CFSwapInt64(*((UInt64 *) &(data_length)));
    
    uint64_t context_start;
    memcpy(&context_start, &buffer[1296],8);
    context_start = CFSwapInt64(*((UInt64 *) &(context_start)));
    
    uint32_t context_length;
    memcpy(&context_length, &buffer[1304],4);
    context_length = CFSwapInt32(*((UInt32 *) &(context_length)));
    
    uint64_t annote_start;
    memcpy(&annote_start, &buffer[1308],8);
    annote_start = CFSwapInt64(*((UInt64 *) &(annote_start)));
    
    uint32_t annote_length;
    memcpy(&annote_length, &buffer[1316],4);
    annote_length = CFSwapInt32(*((UInt32 *) &(annote_length)));
    
    uint64_t total_size;
    memcpy(&total_size, &buffer[1320],8);
    total_size = CFSwapInt64(*((UInt64 *) &(total_size)));
    
    uint8_t unit_location[8];
    memcpy(unit_location, &buffer[1328],8);

    uint8_t compound_units1[12];    /* 2 12-byte unit structures */
    memcpy(compound_units1, &buffer[1336],12);

    uint8_t compound_units2[12];
    memcpy(compound_units2, &buffer[1348],12);
    
    CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    PSUnitRef hertz = PSUnitForParsedSymbol(CFSTR("Hz"), NULL, error);
    PSUnitRef megahertz = PSUnitForParsedSymbol(CFSTR("MHz"), NULL, error);
    PSUnitRef seconds = PSUnitForParsedSymbol(CFSTR("s"), NULL, error);
    PSUnitRef ppm = PSUnitForParsedSymbol(CFSTR("ppm"), NULL, error);
    CFIndex size = 1;

    for(CFIndex idim = 0; idim<data_dimension_number; idim++) {
        CFIndex npts = data_points[idim];
        CFIndex tdim = 0;
        for(CFIndex i = 0; i<8; i++) {
            if (idim == translate[i]-1) {
                tdim = i;
                break;
            }
        }
        CFIndex actual_npts = t_range[tdim];
        double unit_power = pow(10, data_unit_prefix[idim]);
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
        double initialValue = data_axis_start[idim];
        double dwellTime = (finalValue - initialValue)/((double)(actual_npts));
        if (debugging_data) printf("%lf - %lf - %lf\n",finalValue,initialValue,dwellTime);
        if(dwellTime<0) {
            dwellTime = fabs(dwellTime);
            reverse = true;
        }
        if(data_unit[idim] == joelUnit_s) {
            quantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityFrequency);
            increment = PSScalarCreateWithDouble(dwellTime, seconds);
            originOffset = PSScalarCreateWithDouble(initialValue, seconds);
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
            double ref_offset = (initialValue+finalValue+dwellTime)/2.0;
            ref_offset -= dwellTime * (double)(npts-actual_npts);
            if (debugging_data) {
                printf("%lf\t%u\t%lf\n",dwellTime,(int)data_offset_start[tdim],ref_offset);
            }
            referenceOffset = PSScalarCreateWithDouble(ref_offset, ppm);
            PSScalarMultiply((PSMutableScalarRef) referenceOffset, originOffset, error);
            PSScalarConvertToUnit((PSMutableScalarRef) referenceOffset, hertz, error);
            inverseOriginOffset = PSScalarCreateWithDouble(0.0, seconds);
            inverseReferenceOffset = PSScalarCreateWithDouble(0.0, seconds);
            madeDimensionless = true;
            ftFlag = true;
        }
        else { // Assume that if main unit is not [s] or [ppm] that it has to be [Hz]
            quantityName = CFStringCreateCopy(kCFAllocatorDefault, kPSQuantityFrequency);
            inverseQuantityName = CFStringCreateCopy(kCFAllocatorDefault,kPSQuantityTime);
            originOffset = PSScalarCreateWithDouble(base_freq[idim], megahertz);
            double ref_offset = unit_power * (initialValue+finalValue+dwellTime)/2.0;
            dwellTime *= unit_power; // make sure dwellTime is in Hz units
            increment = PSScalarCreateWithDouble(dwellTime, hertz);
            ref_offset -= dwellTime * (double)(npts-actual_npts-data_offset_start[tdim]);
            if (debugging_data) {
                printf("%lf\t%u\t%lf\n",dwellTime,(int)data_offset_start[tdim],ref_offset);
            }
            referenceOffset = PSScalarCreateWithDouble(ref_offset, hertz);
            inverseOriginOffset = PSScalarCreateWithDouble(0.0, seconds);
            inverseReferenceOffset = PSScalarCreateWithDouble(0.0, seconds);
            ftFlag = true;
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
        
        PSDimensionRef dim = PSLinearDimensionCreateDefault(data_points[idim], increment, quantityName,inverseQuantityName);
        
        PSDimensionSetInverseQuantityName(dim,inverseQuantityName);
        PSDimensionSetOriginOffset(dim, originOffset);
        PSDimensionSetInverseOriginOffset(dim,inverseOriginOffset);
        PSDimensionSetReferenceOffset(dim, referenceOffset);
        PSDimensionSetInverseReferenceOffset(dim, inverseReferenceOffset);
        PSDimensionSetMetaData(dim, dimensionMetaData);
        PSDimensionSetFFT(dim, ftFlag);
        PSDimensionSetPeriodic(dim, periodic);
        PSDimensionSetInversePeriodic(dim, inverseReverse);
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
    
    for(CFIndex i=0; i<8; i++) {
        f_info.submatrices[i] = 0;
    }
    f_info.submatrix_edge = 8;
    f_info.submatrix_size = 8;

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
    for(CFIndex i=0; i<8; i++) {
        f_info.submatrices[i] = f_info.data_points[i]/f_info.submatrix_edge;
    }
    
    f_info.number_of_data_sections = 1;
    for(CFIndex i=0; i<8; i++) {
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

    if (debugging_data) printf("Data sections: %u\n", (uint32_t) f_info.number_of_data_sections);
    
    CFIndex indexes[8] = {0,0,0,0,0,0,0,0};
    CFIndex nth_loop = 7;
    f_info.section_spacing = (CFIndex) data_length;
    f_info.section_spacing /= (CFIndex) f_info.number_of_data_sections;
    f_info.data_start = data_start;
    f_info.data_length = data_length;
    f_info.ddn = data_dimension_number;
    f_info.max_dim = 0;
    if (debugging_data) {
        for(CFIndex i=0; i<8; i++) {
            if (f_info.translate[i]==f_info.ddn) f_info.max_dim = i+1;
        }
    }

    PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(dataset, 0);
    data_fill_recursion(f_info, indexes, nth_loop, buffer,
                        PSDependentVariableGetComponentAtIndex(theDependentVariable, 0),
                        PSDatasetGetDimensions(dataset));

    // Reverse dataset along Frequency Dimensions and
    // set Plot parameters in final imported dataset
    for(CFIndex dimIndex=0;dimIndex<PSDatasetDimensionsCount(dataset);dimIndex++) {
        PSDimensionRef theDimension = PSDatasetGetDimensionAtIndex(dataset, dimIndex);
        bool fftFlag = PSDimensionGetFFT(theDimension);
        CFIndex dvCount = PSDatasetDependentVariablesCount(dataset);
        for(CFIndex dvIndex=0; dvIndex<dvCount; dvIndex++) {
            PSDependentVariableRef dV = PSDatasetGetDependentVariableAtIndex(dataset, dvIndex);
            PSPlotRef thePlot = PSDependentVariableGetPlot(dV);
            PSPlotReset(thePlot);
            PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), true);
            PSAxisRef theCoordinateAxis = PSPlotAxisAtIndex(thePlot, dimIndex);
            PSAxisSetReverse(theCoordinateAxis, false);
            if(fftFlag) {
                PSAxisSetBipolar(PSPlotGetResponseAxis(thePlot), false);
                PSAxisSetReverse(theCoordinateAxis, true);
                PSDependentVariableReverseAlongDimension(dV, PSDatasetGetDimensions(dataset), dimIndex, 0);
                }
            }
    }

    return dataset;
}
