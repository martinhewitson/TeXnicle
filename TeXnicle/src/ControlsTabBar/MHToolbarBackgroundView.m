//
//  MHToolbarBackgroundView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "MHToolbarBackgroundView.h"


@implementation MHToolbarBackgroundView

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
}

@end
