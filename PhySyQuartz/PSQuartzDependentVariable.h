//
//  PSQuartzDependentVariable.h
//  PhySyQuartz
//
//  Created by Philip J. Grandinetti on 1/11/12.
//  Copyright (c) 2012 PhySy. All rights reserved.
//

#define kPSQuartzDependentVariableHorizontalWidthExceeded     100
#define kPSQuartzDependentVariableVerticalWidthExceeded       101


@interface PSQuartzDependentVariable : NSObject
{
    CFMutableArrayRef real1DPaths;
    CFMutableArrayRef imaginary1DPaths;
    CFMutableArrayRef magnitude1DPaths;
    CFMutableArrayRef argument1DPaths;
    CFMutableArrayRef realIntensityImages;
    CFMutableArrayRef imaginaryIntensityImages;
    CFMutableArrayRef magnitudeIntensityImages;
    CFMutableArrayRef argumentIntensityImages;
    CFMutableArrayRef realContourImages;
    CFMutableArrayRef imaginaryContourImages;
    CFMutableArrayRef magnitudeContourImages;
    CFMutableArrayRef argumentContourImages;
    CFIndex horizontalIncrement;
    CFIndex verticalIncrement;
    CFArrayRef realContourPaths;
    CFArrayRef imaginaryContourPaths;
    CFArrayRef magnitudeContourPaths;
    CFArrayRef argumentContourPaths;
    CGPathRef realStackPlotPath;
    CGPathRef imaginaryStackPlotPath;
    CGPathRef magnitudeStackPlotPath;
    CGPathRef argumentStackPlotPath;
}
@end

typedef PSQuartzDependentVariable *PSQuartzDependentVariableRef;

PSQuartzDependentVariableRef PSQuartzDependentVariableCreate(PSDependentVariableRef theDependentVariable);
void PSQuartzDependentVariableRemoveImages(PSQuartzDependentVariableRef quartzDependentVariable);
bool PSQuartzDependentVariablePlot(PSQuartzDependentVariableRef quartzDependentVariable, PSDatasetRef theDataset, CGRect bounds, CGContextRef context, CFErrorRef *error);
bool PSQuartzDependentVariableStackPlot(PSQuartzDependentVariableRef quartzDependentVariable, PSDatasetRef theDataset, CGRect bounds,float widthPercent,float heightPercent,float rightToLeft, CGContextRef context, CFErrorRef *error);
