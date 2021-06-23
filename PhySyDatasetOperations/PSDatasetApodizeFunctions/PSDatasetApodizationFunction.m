//
//  PSDatasetApodizationFunction.c
//  PhySyDataset
//
//  Created by Philip J. Grandinetti on 3/12/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetOperations.h>

@implementation PSDatasetApodizationFunction

- (void) dealloc
{
    if(self->name) CFRelease(self->name);
    [super dealloc];
}

PSDatasetApodizationFunctionRef PSDatasetApodizationFunctionCreate(CFStringRef name,
                                                                   CreateDefaultFunctionParametersForDataset createDefaultFunctionParametersForDataset,
                                                                   ValidateFunctionParametersForDataset validateFunctionParametersForDataset,
                                                                   CreateDatasetByApodizing createDatasetByApodizing,
                                                                   MinimumDimensionsCount minimumDimensionsCount)
{
    PSDatasetApodizationFunctionRef operation = (PSDatasetApodizationFunctionRef) [PSDatasetApodizationFunction alloc];
    
    operation->name = CFRetain(name);
    operation->createDefaultFunctionParametersForDataset = createDefaultFunctionParametersForDataset;
    operation->validateFunctionParametersForDataset = validateFunctionParametersForDataset;
    operation->createDatasetByApodizing = createDatasetByApodizing;
    operation->minimumDimensionsCount = minimumDimensionsCount;
    return operation;
}

CFIndex PSDatasetApodizationFunctionMinimumNumberOfDimensions(PSDatasetApodizationFunctionRef theApodizationFunction)
{
    return theApodizationFunction->minimumDimensionsCount();
}

bool PSDatasetApodizationFunctionValidateFunctionParametersForDataset(PSDatasetApodizationFunctionRef theApodizationFunction, 
                                                              PSDatasetRef theDataset, 
                                                              CFMutableDictionaryRef functionParameters)
{
    return theApodizationFunction->validateFunctionParametersForDataset(theDataset,functionParameters);
}

CFMutableDictionaryRef PSDatasetApodizationFunctionCreateDefaultFunctionParametersForDataset(PSDatasetApodizationFunctionRef theApodizationFunction, PSDatasetRef theDataset, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    return theApodizationFunction->createDefaultFunctionParametersForDataset(theDataset, error);
}

CFStringRef PSDatasetApodizationFunctionGetName(PSDatasetApodizationFunctionRef theApodizationFunction)
{
    return theApodizationFunction->name;
}

PSDatasetRef PSDatasetApodizationFunctionCreateDatasetByApodizing(PSDatasetApodizationFunctionRef theApodizationFunction, 
                                                                  PSDatasetRef theDataset, 
                                                                  CFMutableDictionaryRef functionParameters,
                                                                  CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    
    PSDatasetRef result = theApodizationFunction->createDatasetByApodizing(theDataset, functionParameters,error);
    
    CFIndex dependentVariablesCount = PSDatasetDependentVariablesCount(result);
    for(CFIndex dependentVariableIndex=0; dependentVariableIndex<dependentVariablesCount; dependentVariableIndex++) {
        PSDependentVariableRef theDependentVariable = PSDatasetGetDependentVariableAtIndex(result, dependentVariableIndex);
        PSPlotRef newPlot = PSDependentVariableGetPlot(theDependentVariable);
        PSAxisReset(PSPlotGetResponseAxis(newPlot), PSDependentVariableGetQuantityName(theDependentVariable));
    }

    return result;

}

@end
