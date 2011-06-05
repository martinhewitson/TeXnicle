//
//  TPPopuplistView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/5/10.
//  Copyright 2010 BOBsoft. All rights reserved.
//

#import "TPPopuplistView.h"


@implementation TPPopuplistView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code here.
	}
	return self;
}

- (void) awakeFromNib
{
	[table setDoubleAction:@selector(listDoubleClick)];
	NSScrollView *sv = [table enclosingScrollView];
	NSScroller *vs = [sv verticalScroller];
	[vs setControlSize:NSSmallControlSize];
}

- (void) dealloc
{
	[self setDelegate:nil];
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
	// Drawing code here.
	[super drawRect:dirtyRect];
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (BOOL) becomeFirstResponder
{
	return YES;
}

- (void) listDoubleClick
{
	if ([delegate respondsToSelector:@selector(userSelectedRow:)]) {
		NSInteger row = [table selectedRow];
		[delegate performSelector:@selector(userSelectedRow:) withObject:[NSNumber numberWithInteger:row]];
	}		
}

- (void) keyDown:(NSEvent *)theEvent
{
//	NSLog(@"Key down on list %@", theEvent);
	
	// escape key dismisses the window
	if ([theEvent keyCode] == 53) {
		if ([delegate respondsToSelector:@selector(dismiss)]) {
			[delegate performSelector:@selector(dismiss)];
		}
	}
	
	// user hit enter
	if ([theEvent keyCode] == 36) {
		if ([delegate respondsToSelector:@selector(userSelectedRow:)]) {
			NSInteger row = [table selectedRow];
			[delegate performSelector:@selector(userSelectedRow:) withObject:[NSNumber numberWithInteger:row]];
		}		
	}
	
}


@end
