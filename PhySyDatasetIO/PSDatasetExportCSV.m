//
//  PSDatasetExportCSV.c
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>

struct oneD_data {
    int x;
    float responses;
};

void bubbleSort1D(float coordinate[], float responses[], CFIndex n)
{
    for(CFIndex i=0; i<n; i++) {
        for(CFIndex j=0; j<n-1; j++) {
            if(coordinate[j]>coordinate[j+1]) {
                float x_temp = coordinate[j+1];
                coordinate[j+1] = coordinate[j];
                coordinate[j] = x_temp;
                
                float y_temp = responses[j+1];
                responses[j+1] = responses[j];
                responses[j] = y_temp;
            }
        }
    }
}

void bubbleSort2D(float x[], float y[], double responses[], CFIndex n)
{
    for(CFIndex i=0; i<n; i++) {
        for(CFIndex j=0; j<n-1; j++) {
            if(x[j]>x[j+1]) {
                float x_temp = x[j+1];
                x[j+1] = x[j];
                x[j] = x_temp;
                
                float y_temp = y[j+1];
                y[j+1] = y[j];
                y[j] = y_temp;

                float response_temp = responses[j+1];
                responses[j+1] = responses[j];
                responses[j] = response_temp;
            }
        }
    }
}

PSDatasetRef PSDatasetImportCSVCreateSignalWithFileData(CFDataRef contents, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(contents,NULL);
 
    CFStringRef temp = CFStringCreateFromExternalRepresentation (kCFAllocatorDefault,contents,kCFStringEncodingUTF8);
    CFMutableStringRef fileString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
    CFRelease(temp);
    
    
    CFStringFindAndReplace(fileString, CFSTR("\r"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(fileString)), 0);
    CFStringFindAndReplace(fileString, CFSTR("\n\n"), CFSTR("\n"), CFRangeMake(0, CFStringGetLength(fileString)), 0);

    CFArrayRef array = (CFArrayRef) [(NSString *) fileString componentsSeparatedByString:@"\n"];
    CFRelease(fileString);
    
    CFMutableArrayRef mutArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    
    for(CFIndex index = CFArrayGetCount(mutArray)-1; index>=0; index--) {
        CFStringRef lineString = CFArrayGetValueAtIndex(mutArray, index);
        if(CFStringGetLength(lineString) == 0) CFArrayRemoveValueAtIndex(mutArray, index);
        else {
            CFMutableStringRef mutLineString = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(lineString),lineString);
            CFStringTrimWhitespace(mutLineString);
            if(!characterIsDigitOrDecimalPointOrMinus(PSCFStringGetCharacterAtIndex(mutLineString, 0))) CFArrayRemoveValueAtIndex(mutArray, index);
            CFRelease(mutLineString);
               }
        }

    CFStringRef lineString = CFArrayGetValueAtIndex(mutArray, 0);
    CFArrayRef commas = CFStringCreateArrayWithFindResults(kCFAllocatorDefault, lineString, CFSTR(","), CFRangeMake(0, CFStringGetLength(lineString)), 0);
    CFIndex dimensionsCount = CFArrayGetCount(commas);
    CFRelease(commas);
    
    if(dimensionsCount == 1) {
        CFIndex size = CFArrayGetCount(mutArray);
        float *x = malloc(size*sizeof(float));
        float *response = malloc(size*sizeof(float));
        
        for(CFIndex index=0;index<size;index++) {
            CFStringRef lineString = CFArrayGetValueAtIndex(mutArray, index);
            char *cString = CreateCString(lineString);
            if(sscanf(cString,"%f,%f",&x[index],&response[index])!=2) {
                size = index;
                break;
                }
        }
        // Need to sort values to have increasing x values
        bubbleSort1D(x, response, size);
        float x_width = fabs(x[size-1]-x[0]);
        float x_delta = fabs(x[1]-x[0]);
        x_delta = x_width/(size-1);
        CFIndex x_size = size;
        if(x_delta!=0.0) {
            for(CFIndex index=0;index<size;index++) {
                if(x[index+1]<x[index]) {
                    x_size = index+1;
                    break;
                }
            }
            CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
            
            PSScalarRef increment = PSScalarCreateWithFloat(x_delta, NULL);
            PSScalarRef referenceOffset = PSScalarCreateWithFloat(x[0], NULL);
            PSScalarRef originOffset = PSScalarCreateWithFloat(0.0, NULL);
            PSScalarRef inverseOriginOffset = PSScalarCreateWithFloat(0.0, NULL);
            
            PSDimensionRef dimX = PSLinearDimensionCreateDefault(x_size, increment, kPSQuantityDimensionless,kPSQuantityDimensionless);
            PSDimensionSetOriginOffset(dimX, originOffset);
            PSDimensionSetInverseOriginOffset(dimX, inverseOriginOffset);
            PSDimensionSetReferenceOffset(dimX, referenceOffset);
            PSDimensionMakeNiceUnits(dimX);
            
            CFRelease(increment);
            CFRelease(referenceOffset);
            
            CFArrayAppendValue(dimensions, dimX);
            CFRelease(dimX);
            
            CFRelease(originOffset);
            CFRelease(inverseOriginOffset);
            
            CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) response, size*sizeof(float));
            
            PSDependentVariableRef signal = PSDependentVariableCreateWithComponent(NULL,
                                                                                   NULL,
                                                                                   NULL,
                                                                                   NULL,
                                                                                   kPSNumberFloat32Type,
                                                                                   NULL,
                                                                                   values,
                                                                                   NULL,
                                                                                   NULL);
            CFRelease(values);
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
            CFRelease(signal);
            CFRelease(dimensions);
            free(x);
            free(response);
            return dataset;
        }
        free(x);
        free(response);

    }
    else if(dimensionsCount == 2) {
        CFIndex size = CFArrayGetCount(mutArray);
        float *x = malloc(size*sizeof(float));
        float *y = malloc(size*sizeof(float));
        double *response = malloc(size*sizeof(double));
        
        for(CFIndex index=0;index<size;index++) {
            CFStringRef lineString = CFArrayGetValueAtIndex(mutArray, index);
            char *cString = CreateCString(lineString);
            if(sscanf(cString,"%g,%g,%lg",&x[index],&y[index],&response[index])!=3) {
                size = index;
                break;
            }
        }

        float y_width = fabsf(y[size-1]-y[0]);
        float x_width = fabsf(x[size-1]-x[0]);
        float x_delta = (x[1]-x[0]);
        float y_delta = (y[1]-y[0]);
        CFIndex x_size = size;
        CFIndex y_size = size;
        bool x_is_zero_dimension = true;
        if(x_delta>0.0) {
            x_is_zero_dimension = false;
            for(CFIndex index=0;index<size;index++) {
                if(x[index+1]<x[index]) {
                    x_size = index+1;
                    y_size = size/x_size;
                    y_delta = fabs(y[x_size]- y[0]);
                    break;
                }
            }
        }
        else if(x_delta<0.0) {
            x_is_zero_dimension = false;
            for(CFIndex index=0;index<size;index++) {
                if(x[index+1]>x[index]) {
                    x_size = index+1;
                    y_size = size/x_size;
                    y_delta = fabs(y[x_size]- y[0]);
                    break;
                }
            }
        }
        else if(y_delta > 0.0) {
            for(CFIndex index=0;index<size;index++) {
                if(y[index+1]<y[index]) {
                    y_size = index+1;
                    x_size = size/y_size;
                    x_delta = fabs(x[y_size]- x[0]);
                    break;
                }
            }
        }
        else if(y_delta < 0.0) {
            for(CFIndex index=0;index<size;index++) {
                if(y[index+1]>y[index]) {
                    y_size = index+1;
                    x_size = size/y_size;
                    x_delta = fabs(x[y_size]- x[0]);
                    break;
                }
            }
        }

        if(x_size*y_size != size) {
            if(error) {
                CFStringRef desc = CFSTR("Incompatible number of samples.");
                *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                                kPSFoundationErrorDomain,
                                                                0,
                                                                (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                                (const void* const*)&desc,
                                                                1);
            }
            free(x);
            free(y);
            free(response);
            return NULL;

        }
        CFRelease(mutArray);
        CFMutableArrayRef dimensions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        
        PSScalarRef increment = PSScalarCreateWithFloat(x_delta, NULL);
        PSScalarRef referenceOffset = PSScalarCreateWithFloat(x[0], NULL);
        PSScalarRef originOffset = PSScalarCreateWithFloat(0.0, NULL);
        PSScalarRef inverseOriginOffset = PSScalarCreateWithFloat(0.0, NULL);
        
        PSDimensionRef dimX = PSLinearDimensionCreateDefault(x_size, increment, kPSQuantityDimensionless,kPSQuantityDimensionless);
        PSDimensionSetOriginOffset(dimX, originOffset);
        PSDimensionSetInverseOriginOffset(dimX, inverseOriginOffset);
        PSDimensionSetReferenceOffset(dimX, referenceOffset);
        PSDimensionMakeNiceUnits(dimX);

        CFRelease(increment);
        CFRelease(referenceOffset);
        
        increment = PSScalarCreateWithFloat(y_delta, NULL);
        referenceOffset = PSScalarCreateWithFloat(y[0], NULL);
        
        PSDimensionRef dimY = PSLinearDimensionCreateDefault(y_size, increment, kPSQuantityDimensionless,kPSQuantityDimensionless);
        PSDimensionSetOriginOffset(dimY, originOffset);
        PSDimensionSetInverseOriginOffset(dimY, inverseOriginOffset);
        PSDimensionSetReferenceOffset(dimY, referenceOffset);
        PSDimensionMakeNiceUnits(dimY);
        
        if(x_is_zero_dimension) {
            CFArrayAppendValue(dimensions, dimY);
            CFArrayAppendValue(dimensions, dimX);
        }
        else {
            CFArrayAppendValue(dimensions, dimX);
            CFArrayAppendValue(dimensions, dimY);
        }
        CFRelease(increment);
        CFRelease(dimX);
        CFRelease(dimY);
        
        CFRelease(referenceOffset);
        CFRelease(originOffset);
        CFRelease(inverseOriginOffset);
        
        CFDataRef values = CFDataCreate(kCFAllocatorDefault,(const UInt8 *) response, size*sizeof(double));
        PSDependentVariableRef signal = PSDependentVariableCreateWithComponent(NULL,
                                                                               NULL,
                                                                               NULL,
                                                                               NULL,
                                                                               kPSNumberFloat64Type,
                                                                               NULL,
                                                                               values,
                                                                               NULL,
                                                                               NULL);

        
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
        CFRelease(values);
        CFRelease(signal);
        CFRelease(dimensions);
        free(x);
        free(y);
        free(response);
        return dataset;
    }
    CFRelease(mutArray);
    return NULL;
}

CFStringRef PSDatasetCreateCSVString(PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    
    CFMutableStringRef output = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFArrayRef dimensions = PSDatasetGetDimensions(theDataset);
    CFIndex dimensionsCount = CFArrayGetCount(dimensions);
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(theDataset);
    CFIndex size = PSDimensionCalculateSizeFromDimensions(dimensions);
    for(CFIndex memOffset = 0; memOffset <size; memOffset++) {
        
        CFArrayRef coordinateValues = PSDimensionCreateDisplayedCoordinatesFromMemOffset(dimensions,  memOffset);

        for(CFIndex idim=0;idim<dimensionsCount; idim++) {
            PSScalarRef coordinate = CFArrayGetValueAtIndex(coordinateValues, idim);
            CFStringRef stringValue = PSScalarCreateStringValue(coordinate);
            if(idim>0) CFStringAppendFormat(output,NULL,CFSTR(",%@"),stringValue);
            else CFStringAppendFormat(output, NULL, CFSTR("%@"), stringValue);
            CFRelease(stringValue);
        }
        
        for(CFIndex dependentVariableIndex = 0; dependentVariableIndex<dependentVariablesCount;dependentVariableIndex++) {
            PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(theDataset, dependentVariableIndex);
            CFIndex componentsCount = PSDependentVariableComponentsCount(theDependentVariable);
            PSPlotRef thePlot = PSDependentVariableGetPlot(theDependentVariable);
            bool real = PSPlotGetReal(thePlot);
            bool imag = PSPlotGetImag(thePlot);
            bool magnitude = PSPlotGetMagnitude(thePlot);
            bool argument = PSPlotGetArgument(thePlot);

            if(real){
                for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                    PSScalarRef response = PSDatasetCreateResponseFromMemOffset(theDataset, dependentVariableIndex, componentIndex, memOffset);
                    float complex value = PSScalarFloatComplexValue(response);
                    CFStringRef stringValue = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%.7g"),crealf(value));
                    CFStringAppendFormat(output, NULL, CFSTR(",%@"), stringValue);
                    CFRelease(stringValue);
                    CFRelease(response);
                }
            }
            if(imag){
                for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                    PSScalarRef response = PSDatasetCreateResponseFromMemOffset(theDataset, dependentVariableIndex, componentIndex, memOffset);
                    float complex value = PSScalarFloatComplexValue(response);
                    CFStringRef stringValue = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%.7g"),cimagf(value));
                    CFStringAppendFormat(output, NULL, CFSTR(",%@"), stringValue);
                    CFRelease(stringValue);
                    CFRelease(response);
                }
            }
            if(magnitude){
                for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                    PSScalarRef response = PSDatasetCreateResponseFromMemOffset(theDataset, dependentVariableIndex, componentIndex, memOffset);
                    float complex value = PSScalarFloatComplexValue(response);
                    CFStringRef stringValue = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%.7g"),cabs(value));
                    CFStringAppendFormat(output, NULL, CFSTR(",%@"), stringValue);
                    CFRelease(stringValue);
                    CFRelease(response);
                }
            }
            if(argument){
                for(CFIndex componentIndex=0; componentIndex<componentsCount; componentIndex++) {
                    PSScalarRef response = PSDatasetCreateResponseFromMemOffset(theDataset, dependentVariableIndex, componentIndex, memOffset);
                    float complex value = PSScalarFloatComplexValue(response);
                    CFStringRef stringValue = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%.7g"),cargument(value));
                    CFStringAppendFormat(output, NULL, CFSTR(",%@"), stringValue);
                    CFRelease(stringValue);
                    CFRelease(response);
                }
            }
        }
        CFStringAppend(output, CFSTR("\n"));
        CFRelease(coordinateValues);
    }
    return output;
}

