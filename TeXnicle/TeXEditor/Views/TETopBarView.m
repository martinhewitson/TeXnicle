//
//  TPBottomBarView.m
//  Trips
//
//  Created by Martin Hewitson on 30/8/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "TETopBarView.h"


@implementation TETopBarView

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void) awakeFromNib
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
				 selector:@selector(handleWindowResignedMain:)
						 name:NSApplicationDidResignActiveNotification
					 object:NSApp];
	[nc addObserver:self
				 selector:@selector(handleWindowDidBecomeMain:)
						 name:NSApplicationDidBecomeActiveNotification
					 object:NSApp];
	
//	self.endingColor = [NSColor lightGrayColor];
  CGFloat v = 237;
  self.endingColor = [NSColor colorWithDeviceRed:v/255.0 green:v/255.0 blue:v/255.0 alpha:1.0];
  self.startingColor = [NSColor colorWithDeviceRed:v/255.0 green:v/255.0 blue:v/255.0 alpha:1.0];
  self.angle = 270;
  self.cornerRadius = 0;
  self.borderWidth = 0.0;
}

#pragma mark -
#pragma mark Notification handlers

- (void) handleWindowDidBecomeMain:(NSNotification*)notification
{
//  CGFloat start = 207/255.0;
//  CGFloat end   = 168/255.0;
//  self.startingColor = [NSColor colorWithDeviceRed:start green:start blue:start alpha:1.0];
//  self.endingColor = [NSColor colorWithDeviceRed:end green:end blue:end alpha:1.0];
//	[self setNeedsDisplay:YES];
}

- (void) handleWindowResignedMain:(NSNotification*)notification
{
//  CGFloat start = 237/255.0;
//  CGFloat end   = 217/255.0;
//  self.startingColor = [NSColor colorWithDeviceRed:start green:start blue:start alpha:1.0];
//  self.endingColor = [NSColor colorWithDeviceRed:end green:end blue:end alpha:1.0];
//	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	// draw line alone the bottom
	NSRect r = [self bounds];
	[[NSColor darkGrayColor] set];
	NSBezierPath *path = [NSBezierPath bezierPath];
	CGFloat lineWidth = 0.5;
	[path setLineWidth:lineWidth];
	[path moveToPoint:NSMakePoint(0.0, lineWidth)];
	[path lineToPoint:NSMakePoint(r.size.width, lineWidth)];
	
//  [path moveToPoint:NSMakePoint(0.0, r.size.height-lineWidth)];
//  [path lineToPoint:NSMakePoint(r.size.width, r.size.height-lineWidth)];
  [path stroke];
}

@end
