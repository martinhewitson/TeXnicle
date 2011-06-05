//
//  TPSearchField.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/01/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "TPSearchField.h"


@implementation TPSearchField

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (BOOL) becomeFirstResponder
{
	return YES;
}

- (void) keyDown:(NSEvent *)theEvent
{
	
	// escape key dismisses the window
	if ([theEvent keyCode] == 53) {
		if ([[self delegate] respondsToSelector:@selector(dismiss)]) {
			[[self delegate] performSelector:@selector(dismiss)];
		}
	}
		
}


@end
