//
//  PSTableView.h
//  RMN 2.0
//
//  Created by Philip J. Grandinetti on 3/3/12.
//  Copyright (c) 2012 PhySy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PSTableViewDataSource
- (id)tableView:(NSTableView *)aTableView quantityForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (BOOL)tableView:(NSTableView *)aTableView maintainDimensionalityForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
@end

@protocol PSTableViewDelegate
- (NSMenu *)tableView:(NSTableView *)aTableView menu:(NSMenu *) menu forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (NSString *) quantityForTextField: (id) sender;
@end

@interface PSTableView : NSTableView <NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
    id < NSTableViewDataSource> myDataSource; 
    id < NSTableViewDelegate > myDelegate;
    NSTextView *fieldEditor;
}
@end
