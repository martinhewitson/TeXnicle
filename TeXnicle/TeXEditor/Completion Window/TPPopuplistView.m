//
//  TPPopuplistView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
}

- (void)drawRect:(NSRect)dirtyRect {
	// Drawing code here.
	[super drawRect:dirtyRect];
}

- (void) listDoubleClick
{
	if ([delegate respondsToSelector:@selector(userSelectedRow:)]) {
		NSInteger row = [table selectedRow];
		[delegate performSelector:@selector(userSelectedRow:) withObject:@(row)];
	}		
}



@end
