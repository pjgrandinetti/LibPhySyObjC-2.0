//
//  PSDatasetApodization.c
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/8/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

CFArrayRef PSDatasetApodizationCreateArrayOfFunctions(void)
{
    CFMutableArrayRef functions = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    // Create Gaussian
    PSDatasetApodizationFunctionRef function = 
    PSDatasetApodizationFunctionCreate(kPSDatasetApodizeGaussian,
                                       PSDatasetApodizeGaussianCreateDefaultFunctionParametersForDataset, 
                                       PSDatasetApodizeGaussianValidateFunctionParametersForDataset, 
                                       PSDatasetApodizeGaussianCreateByApodizing,
                                       PSDatasetApodizeGaussianMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create Exponential
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeExponential,
                                                  PSDatasetApodizeExponentialCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeExponentialValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeExponentialCreateByApodizing,
                                                  PSDatasetApodizeExponentialMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create Stretched Exponential
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeStretchedExponential,
                                                  PSDatasetApodizeStretchedExponentialCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeStretchedExponentialValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeStretchedExponentialCreateByApodizing,
                                                  PSDatasetApodizeStretchedExponentialMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create Sinc
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeSinc,
                                                  PSDatasetApodizeSincCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeSincValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeSincCreateByApodizing,
                                                  PSDatasetApodizeSincMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create RamLak
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeRamLak,
                                                  PSDatasetApodizeRamLakCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeRamLakValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeRamLakCreateByApodizing,
                                                  PSDatasetApodizeRamLakMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create Triangle
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeTriangle,
                                                  PSDatasetApodizeTriangleCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeTriangleValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeTriangleCreateByApodizing,
                                                  PSDatasetApodizeTriangleMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create Cosine
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeCosine,
                                                  PSDatasetApodizeCosineCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeCosineValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeCosineCreateByApodizing,
                                                  PSDatasetApodizeCosineMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create Cosine
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeHamming,
                                                  PSDatasetApodizeHammingCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeHammingValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeHammingCreateByApodizing,
                                                  PSDatasetApodizeHammingMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create TopHat Band Pass
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeTopHatBandPass,
                                                  PSDatasetApodizeTopHatBandPassCreateDefaultFunctionParametersForDataset, 
                                                  PSDatasetApodizeTopHatBandPassValidateFunctionParametersForDataset, 
                                                  PSDatasetApodizeTopHatBandPassCreateByApodizing,
                                                  PSDatasetApodizeTopHatBandPassMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create TopHat Band Stop
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeTopHatBandStop,
                                                  PSDatasetApodizeTopHatBandStopCreateDefaultFunctionParametersForDataset, 
                                                  PSDatasetApodizeTopHatBandStopValidateFunctionParametersForDataset, 
                                                  PSDatasetApodizeTopHatBandStopCreateByApodizing,
                                                  PSDatasetApodizeTopHatBandStopMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create PIETA
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizePIETA,
                                                  PSDatasetApodizePIETACreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizePIETAValidateFunctionParametersForDataset,
                                                  PSDatasetApodizePIETACreateByApodizing,
                                                  PSDatasetApodizePIETAMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    // Create Derivative Convolution
    function = PSDatasetApodizationFunctionCreate(kPSDatasetApodizeDerivative,
                                                  PSDatasetApodizeDerivativeCreateDefaultFunctionParametersForDataset,
                                                  PSDatasetApodizeDerivativeValidateFunctionParametersForDataset,
                                                  PSDatasetApodizeDerivativeCreateByApodizing,
                                                  PSDatasetApodizeDerivativeMinimumNumberOfDimensions);
    CFArrayAppendValue(functions, function);
    CFRelease(function);
    
    return functions;
}

bool PSDatasetApodizationValidateAndUpdateParametersForDataset(CFMutableArrayRef functions,
                                                               PSDatasetRef theDataset, 
                                                               CFMutableDictionaryRef parameters,
                                                               CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    IF_NO_OBJECT_EXISTS_RETURN(functions,false);
    IF_NO_OBJECT_EXISTS_RETURN(theDataset,false);
    CFIndex numberOfDimensions = PSDatasetDimensionsCount(theDataset);
    
    // Remove functions that require more dimensions than dataset has
    for(CFIndex index=CFArrayGetCount(functions)-1;index>=0; index--) {
        PSDatasetApodizationFunctionRef function = (PSDatasetApodizationFunctionRef) CFArrayGetValueAtIndex(functions, index);
        if(numberOfDimensions<PSDatasetApodizationFunctionMinimumNumberOfDimensions(function)) CFArrayRemoveValueAtIndex(functions, index);
    }
    
    for(CFIndex index=0;index<CFArrayGetCount(functions); index++) {
        PSDatasetApodizationFunctionRef function = (PSDatasetApodizationFunctionRef) CFArrayGetValueAtIndex(functions, index);
        CFStringRef functionName = PSDatasetApodizationFunctionGetName(function);
        
        if(CFDictionaryContainsKey(parameters, functionName)) {
            CFMutableDictionaryRef functionParameters = (CFMutableDictionaryRef) CFDictionaryGetValue(parameters, functionName);
            bool valid = false;
            if(functionParameters) valid = PSDatasetApodizationFunctionValidateFunctionParametersForDataset(function, theDataset, functionParameters);
            if(!valid) {
                functionParameters = PSDatasetApodizationFunctionCreateDefaultFunctionParametersForDataset(function, theDataset,error);
                CFDictionarySetValue(parameters, functionName, functionParameters);
                CFRelease(functionParameters);
            }
        }
        else {
            CFMutableDictionaryRef functionParameters = PSDatasetApodizationFunctionCreateDefaultFunctionParametersForDataset(function, theDataset,error);
            CFDictionaryAddValue(parameters, functionName, functionParameters);
            CFRelease(functionParameters);
        }
        
    }
    return true;
}

CFArrayRef PSDatasetApodizationCreateArrayOfFunctionNames(CFArrayRef functions)
{
    IF_NO_OBJECT_EXISTS_RETURN(functions,NULL);
    CFMutableArrayRef result = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for(CFIndex index =0; index<CFArrayGetCount(functions); index++) {
        PSDatasetApodizationFunctionRef function = (PSDatasetApodizationFunctionRef) CFArrayGetValueAtIndex(functions, index);
        CFArrayAppendValue(result, PSDatasetApodizationFunctionGetName(function));
    }
    return result;
}


