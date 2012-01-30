//
//  TPPopupTableView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 30/1/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPPopupTableView.h"

@implementation TPPopupTableView

- (void) keyDown:(NSEvent *)theEvent
{
	// tab key jumps to next key view
	if ([theEvent keyCode] == 48) {
    NSView *next = [self nextKeyView];
    [[self window] makeFirstResponder:next];
    return;
	}
  
  [super keyDown:theEvent];
}

@end
