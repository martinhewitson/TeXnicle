//
//  NSOutlineView+TeXnicle.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSOutlineView (TeXnicle)

- (void) selectItem:(id)item;
- (void) selectItems:(NSArray*)items;
- (id)selectedItem;
- (NSArray*)selectedItems;

@end
