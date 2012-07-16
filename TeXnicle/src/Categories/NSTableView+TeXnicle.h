//
//  NSTableView+TeXnicle.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTableView (TeXnicle)

- (void) selectRow:(NSInteger)row;
- (void) selectRowNumber:(NSNumber*)row;

@end
