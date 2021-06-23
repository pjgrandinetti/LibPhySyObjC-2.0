//
//  PSDatasetApodizationFunction.h
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 3/12/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#define kPSDatasetApodizationFunctionValues CFSTR("kPSDatasetApodizationFunctionValues")
#define kPSDatasetApodizationFunctionNames CFSTR("kPSDatasetApodizationFunctionNames")

/*!
 @typedef CreateDefaultFunctionParametersForDataset
 @param theDataset the Dataset
 @param error an error
 */
typedef CFMutableDictionaryRef (*CreateDefaultFunctionParametersForDataset)(PSDatasetRef theDataset, CFErrorRef *error);

/*!
 @typedef ValidateParametersForDataset
 */
typedef bool (*ValidateFunctionParametersForDataset)(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);

/*!
 @typedef NumberOfApodizationParameters
 */
typedef PSDatasetRef (*CreateDatasetByApodizing)(PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);

/*!
 @typedef MinimumNumberOfDimensions
 */
typedef CFIndex (*MinimumDimensionsCount)(void);

@interface PSDatasetApodizationFunction : NSObject {
    CFStringRef name;
    CreateDefaultFunctionParametersForDataset createDefaultFunctionParametersForDataset;
    ValidateFunctionParametersForDataset validateFunctionParametersForDataset;
    CreateDatasetByApodizing createDatasetByApodizing;
    MinimumDimensionsCount minimumDimensionsCount;
}
@end

typedef PSDatasetApodizationFunction *PSDatasetApodizationFunctionRef;

PSDatasetApodizationFunctionRef PSDatasetApodizationFunctionCreate(CFStringRef functionName,
                                                                   CreateDefaultFunctionParametersForDataset createDefaultFunctionParametersForDataset,
                                                                   ValidateFunctionParametersForDataset validateFunctionParametersForDataset,
                                                                   CreateDatasetByApodizing createDatasetByApodizing,
                                                                   MinimumDimensionsCount minimumDimensionsCount);

CFIndex PSDatasetApodizationFunctionMinimumNumberOfDimensions(PSDatasetApodizationFunctionRef theApodizationFunction);

bool PSDatasetApodizationFunctionValidateFunctionParametersForDataset(PSDatasetApodizationFunctionRef theApodizationFunction, PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters);
CFMutableDictionaryRef PSDatasetApodizationFunctionCreateDefaultFunctionParametersForDataset(PSDatasetApodizationFunctionRef theApodizationFunction, PSDatasetRef theDataset, CFErrorRef *error);

CFStringRef PSDatasetApodizationFunctionGetName(PSDatasetApodizationFunctionRef theApodizationFunction);
CFIndex PSDatasetApodizationFunctionGetMinimumNumberOfDimensions(PSDatasetApodizationFunctionRef theApodizationFunction);

PSDatasetRef PSDatasetApodizationFunctionCreateDatasetByApodizing(PSDatasetApodizationFunctionRef theApodizationFunction, PSDatasetRef theDataset, CFMutableDictionaryRef functionParameters, CFErrorRef *error);
