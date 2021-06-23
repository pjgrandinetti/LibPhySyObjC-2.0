//
//  PSTableView.m
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/3/12.
//  Copyright (c) 2012 PhySy. All rights reserved.
//

#import "PhySyFoundation.h"
#import <LibPhySyObjC/PSTableView.h>
#import <LibPhySyObjC/PSScalarTextField.h>

@implementation PSTableView

-(void)dealloc
{
    [myDelegate release];
    [myDataSource release];
    [super dealloc];
}

- (void)setDataSource:(id < NSTableViewDataSource >)anObject
{
    myDataSource = [anObject retain];
    [super setDataSource:self];
}

- (void)setDelegate:(id < NSTableViewDelegate >)anObject
{
    myDelegate = [anObject retain];
    [super setDelegate:self];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [myDelegate tableView:aTableView shouldEditTableColumn:aTableColumn row:rowIndex];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [myDataSource numberOfRowsInTableView:aTableView];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id objectValue = [myDataSource tableView:aTableView objectValueForTableColumn:aTableColumn row:rowIndex];
    if(objectValue) {
        if([objectValue isKindOfClass:[PSScalar class]]) {
            CFStringRef stringValue = PSScalarCreateStringValue((PSScalarRef) objectValue);
            return [(NSString *) stringValue autorelease];
        }
    }
    return objectValue;
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id previousObject = [myDataSource tableView:aTableView objectValueForTableColumn:aTableColumn row:rowIndex];
    if(previousObject) {        
        if([previousObject isKindOfClass:[PSScalar class]]) {
            if([(id <PSTableViewDataSource>) myDataSource tableView:aTableView 
                               maintainDimensionalityForTableColumn:aTableColumn 
                                                                row:rowIndex]) {
                CFErrorRef error=NULL;
                if(!PSScalarValidateProposedStringValue((PSScalarRef) previousObject,(CFStringRef) anObject, &error)) {
                    NSAlert *alert = [NSAlert alertWithError:(NSError *)error];
                    [alert beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode){}];
                    CFRelease(error);
                    return;
                }
            }
        }
    }
    return [myDataSource tableView:aTableView setObjectValue:anObject forTableColumn:aTableColumn row:rowIndex];
}

- (id < NSPasteboardWriting >)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    if([myDelegate respondsToSelector:@selector(tableView: pasteboardWriterForRow:)]) {
        return [myDataSource tableView:tableView pasteboardWriterForRow:row];    
    }
    return nil;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if([myDelegate respondsToSelector:@selector(tableView: willDisplayCell: forTableColumn: row:)]) {
        [myDelegate tableView:aTableView willDisplayCell:aCell forTableColumn:aTableColumn row:rowIndex];
    }
}

- (NSArray *) conversionUnits: (NSTextView *) textField forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSArray *result = nil;
    CFErrorRef error = NULL;
    PSScalarRef scalar = PSScalarCreateWithCFString((CFStringRef) [textField string], &error);
    if(scalar) {
        if(self.delegate) {
            if([self.delegate respondsToSelector:@selector(titleOfSelectedItem)]) {
                result = (NSArray *) PSUnitCreateArrayForQuantity((CFStringRef) [(NSPopUpButton *) self.delegate titleOfSelectedItem]);
                if(result) return [result autorelease];
            }
            else if([self.delegate respondsToSelector:@selector(quantityForTextField:)]) {
                result = (NSArray *) PSUnitCreateArrayForQuantity((CFStringRef) [(id <PSTableViewDataSource>) myDataSource tableView:self quantityForTableColumn: aTableColumn row:rowIndex]);
                if(result) return [result autorelease];
            }
        }
        result = (NSArray *) PSUnitCreateArrayOfConversionUnits(PSQuantityGetUnit((PSQuantityRef) scalar));
        if(result) [result autorelease];
    }
    return result;
}

- (void) convert: (id) sender
{
    CFErrorRef error = NULL;
    
    NSString *pickerSelectedString = [sender representedObject];
    PSScalarRef pickerScalar = PSScalarCreateWithCFString((CFStringRef) pickerSelectedString, &error);

    if(pickerScalar) {
        [fieldEditor setString:pickerSelectedString];
    }
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    if([myDelegate respondsToSelector:@selector(tableView: menu: forTableColumn: row:)]) {
        long row = -1, col = -1;
        NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        row = [self rowAtPoint:where];
        col = [self columnAtPoint:where];
        NSTableColumn *theColumn = [[self tableColumns] objectAtIndex:col];
        
        return [(id <PSTableViewDelegate>) myDelegate tableView:self menu:[super menuForEvent:theEvent] forTableColumn:theColumn row:row];
    }
    return nil;
}

- (NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex
{
    /* Command Click */
    CFIndex editedRow = [self editedRow];
    CFIndex editedColumn = [self editedColumn];
    fieldEditor = view;
   
    id objectValue = [myDataSource tableView:self objectValueForTableColumn: [[self tableColumns] objectAtIndex:editedColumn] row:editedRow];
    if(objectValue) {
        if([objectValue isKindOfClass:[PSScalar class]]) {
            CFErrorRef error = NULL;
            NSArray *results = (NSArray *) PSScalarCreateArrayOfConversionQuantitiesScalarsAndStringValues((PSScalarRef) objectValue, NULL, &error);

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
                        NSAttributedString *title = CreateAttributedStringWithSciptsWithNSFont(stringObject, [NSFont menuFontOfSize:0],NSTextAlignmentRight);
                        [item setAttributedTitle:title];
                        [title release];
                    }
                }
                [menu addItem:[NSMenuItem separatorItem]];
                [menu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
                [menu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
                [menu addItemWithTitle:@"Paste" action:@selector(copy:) keyEquivalent:@"v"];
                CFRelease(results);
                return menu;
            }
        }
    }
    
    return menu;
}


@end
