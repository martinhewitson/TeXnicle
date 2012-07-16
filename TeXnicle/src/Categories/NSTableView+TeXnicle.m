//
//  NSTableView+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSTableView+TeXnicle.h"

@implementation NSTableView (TeXnicle)


- (void) selectRow:(NSInteger)row
{
  [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void) selectRowNumber:(NSNumber*)row
{
  [self selectRowIndexes:[NSIndexSet indexSetWithIndex:[row integerValue]] byExtendingSelection:NO];
}

@end
