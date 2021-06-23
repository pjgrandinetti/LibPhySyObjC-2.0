//
//  PSScalarTextField.h
//  PhySy
//
//  Created by Philip J. Grandinetti on 1/16/12.
//  Copyright (c) 2012 PhySy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PSScalarTextFieldDelegate
- (NSString *) quantityForTextField: (id) sender;
- (void) scalarTextField: (id) scalarTextField didCalculateResult:(NSString *)result;
@end

@class PSScalarTextFormatter;
@interface PSScalarTextField : NSTextField <NSTextViewDelegate>
{
    PSScalarTextFormatter *formatter;
    BOOL resizeText;
}

@property (assign) BOOL resizeText;

- (PSScalarRef) scalarValueToReplace: (PSScalarRef) value;
- (PSScalarRef) scalarValue;
- (void) setScalarValue: (PSScalarRef) value;
- (IBAction) shiftCursorFullRight:(id)sender;
- (IBAction) shiftCursorFullLeft:(id)sender;
- (BOOL) containsText;
- (IBAction) calculate: (id) sender;
- (IBAction) clear: (id) sender;
- (IBAction) deleteBackward:(id)sender;
- (bool) convertToUnit: (PSUnitRef) unit;
- (IBAction) doubleClick:(id) sender;


NSAttributedString *CreateAttributedStringWithSciptsWithNSFont(NSString *theString, NSFont *font, NSTextAlignment alignment);
NSString *CreateStringWithScripts(NSAttributedString *theAttrString);
@end
