//
//  PhySyCocoa.h
//  PhySy
//
//  Created by Philip J. Grandinetti on 1/23/12.
//  Copyright (c) 2012 PhySy. All rights reserved.
//

#ifndef PhySyCocoa_h
#define PhySyCocoa_h


#import <LibPhySyObjC/PhySyDatasetOperations.h>

@protocol DatasetViewDatasetSource
- (PSDatasetRef) dataset;
- (IBAction) showDimensionParametersController: (id) sender;
- (IBAction) showPlotParametersController: (id) sender;
- (IBAction) showDependentVariableParametersController: (id) sender;
- (IBAction) showDatasetParametersController: (id) sender;
- (void) setTransparent:(BOOL)transparent;
@end


@protocol PSDatasetController
- (PSDatasetRef) dataset;
- (NSProgressIndicator *) progressIndicator;
- (void) setDataset: (PSDatasetRef) dataset;
- (IBAction) selectHorizontalDimension:(id)sender;
- (IBAction) selectVerticalDimension:(id)sender;
- (IBAction) selectDepthDimension:(id)sender;
@end

@protocol PSDatasetOperationsSource
- (CFMutableDictionaryRef) operations;
@end

@protocol ModalController
- (IBAction) setModal: (BOOL) modal;
- (BOOL) modal;
@end

#endif
