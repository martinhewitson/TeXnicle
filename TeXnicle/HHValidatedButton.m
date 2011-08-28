//
// HHValidatedButton.m
//
// Copyright (c) 2009 Houdah Software s.à r.l. (http://www.houdah.com)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "HHValidatedButton.h"


@implementation HHValidatedButton

#pragma mark -
#pragma mark initialization

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]) != nil) {
	}
	
    return self;
}

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	
	NSWindow *window = [self window];
	
	if (window != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(windowDidUpdate:)
													 name:NSWindowDidUpdateNotification
												   object:window];
	}
}


#pragma mark -
#pragma mark accessors


#pragma mark -
#pragma mark display

- (void)windowDidUpdate:(NSNotification*)notification
{
    id validator = [NSApp targetForAction:[self action] to:[self target] from:self];
	
    if ((validator == nil) || ![validator respondsToSelector:[self action]]) {
		[self setEnabled:NO];
    }
    else if ([validator respondsToSelector:@selector(validateButton:)]) {
        [self setEnabled:[validator validateButton:self]];
    }
    else if ([validator respondsToSelector:@selector(validateUserInterfaceItem:)]) {
        [self setEnabled:[validator validateUserInterfaceItem:self]];
    }
    else {
		[self setEnabled:YES];
    }
}


#pragma mark -
#pragma mark finalization

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end