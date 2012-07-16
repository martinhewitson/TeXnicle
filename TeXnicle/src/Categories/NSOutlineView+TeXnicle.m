//
//  NSOutlineView+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSOutlineView+TeXnicle.h"

@implementation NSOutlineView (TeXnicle)

- (void) selectItem:(id)item
{
	NSInteger row = [self rowForItem:item];
	[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];	
}

- (void) selectItems:(NSArray*)items
{
	NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
	for (id item in items) {
		NSInteger row = [self rowForItem:item];
		[indices addIndex:row];
	}
	[self selectRowIndexes:indices byExtendingSelection:NO];
}

- (id)selectedItem
{
  NSArray *items = [self selectedItems];
  if ([items count]>0) {
    return [items objectAtIndex:0];
  }
  return nil;
}

- (NSArray*)selectedItems
{
	NSMutableArray *items = [NSMutableArray array];
	NSIndexSet *indices = [self selectedRowIndexes];
	NSUInteger row = [indices firstIndex];
	if (row != NSNotFound) {		
		[items addObject:[self itemAtRow:row]];
		while ((row = [indices indexGreaterThanIndex:row]) != NSNotFound) {
			[items addObject:[self itemAtRow:row]];
		}		
	}
	return items;
}

@end
