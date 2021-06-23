//
//  PSNewScalarTextField.h
//  PhySyCalc
//
//  Created by philip on 2/15/18.
//  Copyright © 2018 PhySy ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PSScalarNewTextFieldDelegate
- (NSString *) quantityForTextField: (id) sender;
- (void) scalarTextField: (id) scalarTextField didCalculateResult:(NSString *)result;
@end

@class PSScalarTextFormatter;
@interface PSNewScalarTextField : NSTextField <NSTextViewDelegate>
{
    PSScalarTextFormatter *formatter;
    BOOL resizeText;
}
@property (assign) BOOL resizeText;

@end


