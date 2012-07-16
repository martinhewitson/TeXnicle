//
//  MHToolbarBackgroundView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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

#import "MHToolbarBackgroundView.h"


@implementation MHToolbarBackgroundView

@synthesize strokeLeftSide;
@synthesize strokeRightSide;

-(void)awakeFromNib
{
	self.endingColor = [NSColor lightGrayColor];
  CGFloat v = 240;
  self.startingColor = [NSColor colorWithDeviceRed:v/255.0 green:v/255.0 blue:v/255.0 alpha:1.0];
  self.angle = 270;
  self.cornerRadius = 0;
  self.borderWidth = 0.0;  
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	// draw line alone the top
	NSRect r = [self bounds];
	[[NSColor blackColor] set];
	NSBezierPath *path = [NSBezierPath bezierPath];
	CGFloat lineWidth = 0.5;
	[path setLineWidth:lineWidth];
	[path moveToPoint:NSMakePoint(0.0, r.size.height)];
	[path lineToPoint:NSMakePoint(r.size.width, r.size.height)];
	[path stroke];
	// draw line alone the bottom
	[path moveToPoint:NSMakePoint(0.0, lineWidth)];
	[path lineToPoint:NSMakePoint(r.size.width, lineWidth)];
	[path stroke];
  
  if (self.strokeLeftSide) {
    [path moveToPoint:NSMakePoint(r.origin.x, r.origin.y)];
    [path lineToPoint:NSMakePoint(r.origin.x, r.origin.y+r.size.height)];
    [path stroke];
  }
  if (self.strokeRightSide) {
    [path moveToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y)];
    [path lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height)];
    [path stroke];
  }  
}

@end
