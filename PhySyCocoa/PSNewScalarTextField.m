//
//  PSNewScalarTextField.m
//  PhySyCalc
//
//  Created by philip on 2/15/18.
//  Copyright © 2018 PhySy ltd. All rights reserved.
//

#import "PhySyFoundation.h"
#import "PSIndexSet.h"
#import "PSNewScalarTextField.h"

@implementation PSNewScalarTextField
@synthesize resizeText;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.resizeText = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(IBAction) undo:(id)sender
{
    [[self undoManager] undo];
}

- (IBAction) redo: (id) sender
{
    [[self undoManager] redo];
}

- (IBAction) clear: (id) sender
{
    [self setObjectValue:@""];
}

- (NSString *) quantity
{
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(titleOfSelectedItem)]) return [(NSPopUpButton *) self.delegate titleOfSelectedItem];
        else if([self.delegate respondsToSelector:@selector(quantityForTextField:)]) return [(id <PSScalarNewTextFieldDelegate>) self.delegate quantityForTextField:self];
    }
    return nil;
}


- (NSArray *) conversionScalarStrings: (PSNewScalarTextField *) textField
{
    CFErrorRef error = NULL;
    PSScalarRef scalar = PSScalarCreateWithCFString((CFStringRef) [textField objectValue], &error);
    if(error) {
        if(scalar) CFRelease(scalar);
        return nil;
    }
    NSArray *strings = (NSArray *) PSScalarCreateArrayOfConversionQuantitiesScalarsAndStringValues(scalar, (CFStringRef) self.quantity, &error);
    if(scalar) CFRelease(scalar);
    return [strings autorelease];
}

- (id) objectValue
{
    return [self stringValue];
}

- (void) setObjectValue:(id<NSCopying>)obj
{
    NSString *objectString = (NSString *) obj;
    if(self.resizeText) {
        float ratio = 2. * self.frame.size.width/self.frame.size.height;
        double fraction = (double)[objectString length]/ratio;
        if(fraction<1.) fraction = 1;
        float fontSize = 0.8*self.frame.size.height/fraction;
        NSFont *newFont = [NSFont fontWithName:[[self font] fontName] size:fontSize];
        [self setFont:newFont];
    }
    [[self undoManager] registerUndoWithTarget:self
                                      selector:@selector(setObjectValue:)
                                        object:(id) [self objectValue]];
    
    [super setObjectValue:objectString];
}

// Set the textfield string using a PSScalar value
- (void) setScalarValue: (PSScalarRef) value
{
    if(value==NULL) return;
    
    CFStringRef stringObjectValue = PSScalarCreateStringValue(value);
    if(stringObjectValue) {
        [self setObjectValue: (NSString *) stringObjectValue];
        CFRelease(stringObjectValue);
    }
}

- (PSScalarRef) scalarValue
{
    PSScalarRef result = NULL;
    CFErrorRef error = NULL;
    CFStringRef stringInTextField = (CFStringRef) [self objectValue];
    result = PSScalarCreateWithCFString(stringInTextField, &error);
    return [result autorelease];
}

// Extract the PSScalar from the string in the textField and make sure it's a validate
// replacement for another PSScalar value
- (PSScalarRef) scalarValueToReplace: (PSScalarRef) value
{
    if(value==NULL) return NULL;
    
    PSScalarRef result = NULL;
    CFErrorRef error = NULL;
    CFStringRef stringInTextField = (CFStringRef) [self objectValue];
    
    if(!PSScalarValidateProposedStringValue(value,stringInTextField, &error)) {
        [self setScalarValue:value];
        NSAlert *alert = [NSAlert alertWithError:(NSError *)error];
        
        
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode)
         {
         }];
    }
    else {
        result = PSScalarCreateWithCFString(stringInTextField, &error);
        [self setScalarValue:result];
    }
    return [result autorelease];
}


- (NSText *) fieldEditor
{
    NSText *fieldEditor = nil;
    NSWindow *window = [self window];
    NSResponder *firstResponder = [window firstResponder];
    
    if ( [firstResponder isKindOfClass:[NSTextView class]] &&
        [window fieldEditor:NO forObject:nil] != nil ) {
        
        NSTextField *field = (NSTextField *)  [(NSTextView *) firstResponder delegate];
        if (field == self) {
            fieldEditor = [window fieldEditor:YES forObject:self];
        }
    }
    else {
        [window makeFirstResponder:self];
        fieldEditor = [window fieldEditor:YES forObject:self];
    }
    return fieldEditor;
}

- (IBAction) deleteBackward:(id)sender
{
    [[self fieldEditor] deleteBackward:sender];
}

- (IBAction) shiftCursorRight:(id)sender
{
    NSRange selectedRange = [[self fieldEditor] selectedRange];
    
    CFIndex length = [[self stringValue] length];
    selectedRange.length= 0;
    if(selectedRange.location<length) selectedRange.location++;
    [self.fieldEditor setSelectedRange:selectedRange];
    [self.fieldEditor setNeedsDisplay:YES];
}

- (IBAction) shiftCursorLeft:(id)sender
{
    NSRange selectedRange = [[self fieldEditor] selectedRange];
    selectedRange.length= 0;
    if(selectedRange.location>0) selectedRange.location--;
    [self.fieldEditor setSelectedRange:selectedRange];
    [self.fieldEditor setNeedsDisplay:YES];
}

- (IBAction) shiftCursorFullRight:(id)sender
{
    NSRange range;
    range.length = 0;
    range.location = [[self stringValue] length];
    [self.fieldEditor setSelectedRange:range];
    [self.fieldEditor setNeedsDisplay:YES];
}

- (IBAction) shiftCursorFullLeft:(id)sender
{
    NSRange range;
    range.length = 0;
    range.location = 0;
    [self.fieldEditor setSelectedRange:range];
    [self.fieldEditor setNeedsDisplay:YES];
}


- (void) convert: (id) sender
{
    CFErrorRef error = NULL;
    
    NSString *pickerSelectedString = [sender representedObject];
    PSScalarRef pickerScalar = PSScalarCreateWithCFString((CFStringRef) pickerSelectedString, &error);
    
    if(pickerScalar) {
        NSString *record = [NSString stringWithFormat:@"%@ = %@",[self stringValue],pickerSelectedString];
        
        [self setObjectValue:pickerSelectedString];
        
        if([self.delegate respondsToSelector:@selector(scalarTextField:didCalculateResult:)]) return [(id <PSScalarNewTextFieldDelegate>) self.delegate scalarTextField:self didCalculateResult:record];
    }
    else {
        error = NULL;
        if(pickerSelectedString) {
            CFStringRef stringObjectValue = (CFStringRef) [self objectValue];
            PSScalarRef scalar = PSScalarCreateWithCFString(stringObjectValue, &error);
            if(scalar) {
                PSScalarBestConversionForQuantityName((PSMutableScalarRef) scalar, (CFStringRef) pickerSelectedString);
                
                PSScalarConvertToCoherentUnit((PSMutableScalarRef) scalar, &error);

                [self setScalarValue: scalar];
                CFRelease(scalar);
           }
        }

//        PSDimensionalityRef dimensionality = PSDimensionalityForQuantityName((CFStringRef) pickerSelectedString);
//        PSUnitRef unit = PSUnitFindCoherentSIUnitWithDimensionality(dimensionality);
//        CFStringRef stringObjectValue = (CFStringRef) [self objectValue];
//        PSScalarRef scalar = PSScalarCreateWithCFString(stringObjectValue, &error);
//        if(scalar) {
//            PSScalarRef newScalar = PSScalarCreateByConvertingToUnit(scalar, unit, &error);
//            if(newScalar) {
//                [self setScalarValue: newScalar];
//                CFRelease(newScalar);
//            }
//            CFRelease(scalar);
//        }
        
        
        if(error) {
            CFStringRef description = CFErrorCopyDescription(error);
            NSAlert *warning = [[NSAlert alloc] init];
            warning.messageText =@"Strange Syntax Error";
            warning.informativeText = (NSString *) description;
            
            [warning beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode)
             {
             }];
            
            CFRelease(description);
        }
    }
    [self shiftCursorFullRight:self];
}


NSString *CreateStringWithScripts2(NSAttributedString *theAttrString)
{
    CFAttributedStringRef attributedString = (CFAttributedStringRef) theAttrString;
    CFIndex length = CFAttributedStringGetLength(attributedString);
    
    // Going to find all the superscript and subscript locations
    PSMutableIndexSetRef scriptLocations = PSIndexSetCreateMutable();
    
    // First find the superscript locations
    PSMutableIndexSetRef superScriptLocations = PSIndexSetCreateMutable();
    CFRange range;
    for(CFIndex loc=0; loc<length; loc++) {
        
        NSDictionary *attributes = [(NSAttributedString *) attributedString attributesAtIndex:loc effectiveRange:(NSRange *) &range];
        NSNumber *value = [attributes valueForKey:@"NSSuperScript"];
        if([value intValue]==1) {
            PSIndexSetAddIndex(superScriptLocations, range.location);
            PSIndexSetAddIndex(scriptLocations, range.location);
            loc += range.length;
        }

//        CFStringRef script =  (CFStringRef) CFAttributedStringGetAttribute (attributedString,loc,kCTSuperscriptAttributeName,&range);
//        if(script) {
//            if(CFStringCompare(script, CFSTR("1"), 0)==kCFCompareEqualTo) {
//                PSIndexSetAddIndex(superScriptLocations, range.location);
//                PSIndexSetAddIndex(scriptLocations, range.location);
//                loc += range.length;
//            }
//        }
    }
    
    // Next find the subscript locations
    for(CFIndex loc=0; loc<length; loc++) {
        NSDictionary *attributes = [(NSAttributedString *) attributedString attributesAtIndex:loc effectiveRange:(NSRange *) &range];
        NSNumber *value = [attributes valueForKey:@"NSSuperScript"];
        if([value intValue]==-1) {
            PSIndexSetAddIndex(scriptLocations, range.location);
            loc += range.length;
        }

//        CFStringRef script =  (CFStringRef) CFAttributedStringGetAttribute (attributedString,loc,kCTSuperscriptAttributeName,&range);
//        if(script) {
//            if(CFStringCompare(script, CFSTR("-1"), 0)==kCFCompareEqualTo) {
//                PSIndexSetAddIndex(scriptLocations, range.location);
//                loc += range.length;
//            }
//        }
    }
    
    // create CFString
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, length, CFAttributedStringGetString(attributedString));
    
    // Start at end of string and insert '^' or '_' at appropriate locations.
    CFIndex lastIndex = PSIndexSetLastIndex(scriptLocations);
    if(lastIndex != kCFNotFound) {
        if(PSIndexSetContainsIndex(superScriptLocations, lastIndex)) CFStringInsert(string, lastIndex, CFSTR("^"));
        else CFStringInsert(string, lastIndex, CFSTR("_"));
        CFIndex nextIndex = PSIndexSetIndexLessThanIndex(scriptLocations, lastIndex);
        while(nextIndex != kCFNotFound) {
            if(PSIndexSetContainsIndex(superScriptLocations, nextIndex)) CFStringInsert(string, nextIndex, CFSTR("^"));
            else CFStringInsert(string, nextIndex, CFSTR("_"));
            nextIndex = PSIndexSetIndexLessThanIndex(scriptLocations, nextIndex);
        }
    }
    
    CFRelease(scriptLocations);
    CFRelease(superScriptLocations);
    return (NSString *) string;
}


NSAttributedString *CreateAttributedStringWithSciptsWithNSFont2(NSString *theString, NSFont *font, NSTextAlignment alignment)
{
    NSUInteger length = [theString length];
    NSMutableString *string = [theString mutableCopy];
    
    CFArrayRef superScriptRangeArray = CFStringCreateArrayWithFindResults(kCFAllocatorDefault,
                                                                          (CFMutableStringRef) string,
                                                                          CFSTR("^"),
                                                                          CFRangeMake(0, length),
                                                                          0);
    CFArrayRef subScriptRangeArray = CFStringCreateArrayWithFindResults(kCFAllocatorDefault,
                                                                        (CFMutableStringRef) string,
                                                                        CFSTR("_"),
                                                                        CFRangeMake(0, length),
                                                                        0);
    // Find length of superscripts
    if(superScriptRangeArray) {
        CFIndex superScriptCount = CFArrayGetCount(superScriptRangeArray);
        for(CFIndex index=0;index<superScriptCount; index++) {
            CFRange *rangePtr = (CFRange *) CFArrayGetValueAtIndex(superScriptRangeArray, index);
            CFIndex count = 0;
            for(CFIndex location = rangePtr->location+1; location<length;location++) {
                UniChar character = [string characterAtIndex:location];
                if(character<'0'|| character>'9') break;
                count++;
            }
            rangePtr->length = count+1;
        }
    }
    
    
    // subscripts can only have length of 1 (excluding '_' character)
    if(subScriptRangeArray) {
        CFIndex subScriptCount = CFArrayGetCount(subScriptRangeArray);
        for(CFIndex index=0;index<subScriptCount; index++) {
            CFRange *rangePtr = (CFRange *) CFArrayGetValueAtIndex(subScriptRangeArray, index);
            rangePtr->length = 2;
        }
    }
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:alignment];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,style,NSParagraphStyleAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    
    // create super and subscripts including the '^' and '_' characters, for now
    if(superScriptRangeArray) {
        [attributedString beginEditing];
        CGFloat fontSize = [font pointSize];
        NSFont *newFont = [NSFont fontWithName:[font fontName] size:fontSize-2];
        
        CFIndex scriptCount = CFArrayGetCount(superScriptRangeArray);
        for(CFIndex index=0;index<scriptCount; index++) {
            CFRange *rangePtr = (CFRange *) CFArrayGetValueAtIndex(superScriptRangeArray, index);
            NSRange scriptRange = {rangePtr->location,rangePtr->length};
            [attributedString addAttribute:NSFontAttributeName value:newFont range:scriptRange];
            [attributedString addAttribute:NSSuperscriptAttributeName value:@"1" range:scriptRange];
        }
        [attributedString endEditing];
    }
    
    if(subScriptRangeArray) {
        [attributedString beginEditing];
        CGFloat fontSize = [font pointSize];
        NSFont *newFont = [NSFont fontWithName:[font fontName] size:fontSize-2];
        
        CFIndex scriptCount = CFArrayGetCount(subScriptRangeArray);
        for(CFIndex index=0;index<scriptCount; index++) {
            CFRange *rangePtr = (CFRange *) CFArrayGetValueAtIndex(subScriptRangeArray, index);
            NSRange scriptRange = {rangePtr->location,rangePtr->length};
            [attributedString addAttribute:NSFontAttributeName value:newFont range:scriptRange];
            [attributedString addAttribute:NSSuperscriptAttributeName value:@"-1" range:scriptRange];
        }
        [attributedString endEditing];
    }
    
    // Delete '^' and '_' characters
    
    CFMutableStringRef mutableString = CFAttributedStringGetMutableString((CFMutableAttributedStringRef) attributedString);
    CFStringFindAndReplace(mutableString,
                           CFSTR("^"),
                           CFSTR(""),
                           CFRangeMake(0, CFStringGetLength(mutableString)),
                           0);
    
    CFStringFindAndReplace(mutableString,
                           CFSTR("_"),
                           CFSTR(""),
                           CFRangeMake(0, CFStringGetLength(mutableString)),
                           0);
    
    NSString *check = CreateStringWithScripts2(attributedString);
    if(CFStringCompare((CFStringRef) theString, (CFStringRef) check, 0)!=kCFCompareEqualTo) {
        NSLog(@"mismatch %@ and %@", theString, check);
    }
    
    if(check) [check release];
    if(style) [style release];
    if(superScriptRangeArray) CFRelease(superScriptRangeArray);
    if(subScriptRangeArray) CFRelease(subScriptRangeArray);
    if(string) CFRelease(string);
    return attributedString;
}

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    if([replacementString isEqualToString:@","]) return NO;
    if([replacementString isEqualToString:@"!"]) return NO;
    if([replacementString isEqualToString:@"@"]) return NO;
    if([replacementString isEqualToString:@"~"]) return NO;
    if([replacementString isEqualToString:@"#"]) return NO;
    if([replacementString isEqualToString:@"$"]) return NO;
    if([replacementString isEqualToString:@"{"]) return NO;
    if([replacementString isEqualToString:@"}"]) return NO;
    
    if([replacementString isEqualToString:@"'"]) return NO;
    if([replacementString isEqualToString:@"\""]) return NO;
    if([replacementString isEqualToString:@"\\"]) return NO;
    if([replacementString isEqualToString:@":"]) return NO;
    if([replacementString isEqualToString:@";"]) return NO;
    if([replacementString isEqualToString:@"?"]) return NO;
    if([replacementString isEqualToString:@">"]) return NO;
    if([replacementString isEqualToString:@"<"]) return NO;
    if([replacementString isEqualToString:@"~"]) return NO;
    if([replacementString isEqualToString:@"`"]) return NO;
    if([replacementString isEqualToString:@"|"]) return NO;
    
    if([replacementString isEqualToString:@"="]) {
        [self calculate:self];
        return NO;
    }
    
    return YES;
}


- (NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex
{
    /* Command Click */
    id<NSTextViewDelegate> delegate = [view delegate];
    NSArray *results = [self conversionScalarStrings:(PSNewScalarTextField *) delegate];
    
    if(results) {
        CFIndex count = [results count];
        NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
        for(CFIndex index=0; index<count; index++) {
            NSString *stringObject = nil;
            id object = [results objectAtIndex:index];
            if([object isKindOfClass:[PSScalar class]]) {
                stringObject = (NSString *) PSScalarCreateStringValue((PSScalarRef) object);
            }
            else if([object isKindOfClass:[NSString class]]) {
                stringObject = (NSString *) object;
            }
            if(stringObject) {
                NSMenuItem *item = [menu addItemWithTitle:stringObject action:@selector(convert:) keyEquivalent:@""];
                [item setRepresentedObject:stringObject];
                NSAttributedString *title = CreateAttributedStringWithSciptsWithNSFont2(stringObject, [NSFont menuFontOfSize:0],NSTextAlignmentRight);
                [item setAttributedTitle:title];
                [title release];
            }
        }
        [menu addItem:[NSMenuItem separatorItem]];
        [menu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
        [menu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
        [menu addItemWithTitle:@"Paste" action:@selector(copy:) keyEquivalent:@"v"];
        return menu;
    }
    return menu;
}

- (IBAction) calculate: (id) sender
{
    NSString *stringObjectValue = [self objectValue];
    if([stringObjectValue length] == 0) return;
    
    CFErrorRef error = NULL;
    NSString *newStringObject = nil;
    
    bool finalUnitKnown = [stringObjectValue containsString:@".."];
    
    PSScalarRef result = PSScalarCreateWithCFString((CFStringRef) stringObjectValue, &error);
    if(result) {
        
        CFStringRef quantityName = PSUnitGuessQuantityName(PSQuantityGetUnit(result));
        if(quantityName&&!finalUnitKnown) {
            PSScalarBestConversionForQuantityName((PSMutableScalarRef) result, quantityName);
        }

        
        newStringObject = (NSString *)PSScalarCreateStringValue(result);
        if(newStringObject) {
            [self setObjectValue:newStringObject];
            if(![stringObjectValue isEqualToString:newStringObject]) {
                NSString *record = [NSString stringWithFormat:@"%@ = %@",stringObjectValue,newStringObject];
                if([self.delegate respondsToSelector:@selector(scalarTextField:didCalculateResult:)]) {
                    [newStringObject release];
                    return [(id <PSScalarNewTextFieldDelegate>) self.delegate scalarTextField:self didCalculateResult:record];
                }
            }
            
            [newStringObject release];
            [self shiftCursorFullRight:self];
        }
        else {
            if(error) {
                CFStringRef description = CFErrorCopyDescription(error);
                NSAlert *warning = [[NSAlert alloc] init];
                warning.messageText =@"Syntax Error";
                warning.informativeText = (NSString *) description;
                
                [warning beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode)
                 {
                 }];
                
                CFRelease(description);
            }
        }
        
    }
    else {
        if(NULL == error) {
            CFStringRef desc = CFSTR("Syntax Error");
            error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault,
                                                           kPSFoundationErrorDomain,
                                                           0,
                                                           (const void* const*)&kCFErrorLocalizedDescriptionKey,
                                                           (const void* const*)&desc,
                                                           1);
            
        }
        CFStringRef description = CFErrorCopyDescription(error);
        
        NSAlert *warning = [[NSAlert alloc] init];
        warning.messageText =@"Syntax Error";
        warning.informativeText = (NSString *) description;
        
        [warning beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode)
         {
         }];
        
        CFRelease(description);
    }
}


- (bool) convertToUnit: (PSUnitRef) unit
{
    PSScalarRef scalar = [self scalarValue];
    CFErrorRef error = NULL;
    if(PSScalarConvertToUnit((PSMutableScalarRef) scalar, unit, &error)) {
        [self setScalarValue:scalar];
        return true;
    }
    return false;
}



- (IBAction) doubleClick:(id) sender
{
    {
        NSRange selectedRange = [[self fieldEditor] selectedRange];
        NSString *string = [[[self fieldEditor] string] substringWithRange:selectedRange];
        if([string isEqualToString:@"("] ) {
            NSString *fullString = [[self fieldEditor] string];
            for(CFIndex index = selectedRange.location; index<[fullString length]; index++) {
                unichar character = [fullString characterAtIndex:index];
                if(character == ')') {
                    NSLog(@"found match");
                }
            }
        }
    }
}

- (void) keyUp:(NSEvent *)theEvent
{
    unsigned short keyCode = [theEvent keyCode];
    if(keyCode == 71) [self clear:self];
}

- (BOOL) containsText
{
    if([[self objectValue] length] >0) return YES;
    return NO;
}

- (NSArray *) equivalentUnits: (PSNewScalarTextField *) textField
{
    NSArray *result = nil;
    CFErrorRef error = NULL;
    PSScalarRef scalar = PSScalarCreateWithCFString((CFStringRef) [textField objectValue],&error);
    if(scalar) {
        result = (NSArray *) PSUnitCreateArrayOfEquivalentUnits(PSQuantityGetUnit((PSQuantityRef) scalar));
        if(result)
            [result autorelease];
    }
    return result;
}





@end
