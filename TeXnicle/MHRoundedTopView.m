//
//  MHRoundedTopView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 02/06/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "MHRoundedTopView.h"


@implementation MHRoundedTopView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)dealloc
{
  [aGradient release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
  CGFloat radius = 20.0f;
  CGFloat lineWidth = 2.0f;
  NSRect bounds = [self bounds];
  
  NSBezierPath *path = [NSBezierPath bezierPath];
  CGFloat inset = lineWidth/2.0;
  [path moveToPoint:NSMakePoint(inset, 0)];
  [path lineToPoint:NSMakePoint(inset, bounds.size.height-radius)];
  [path curveToPoint:NSMakePoint(radius+inset, bounds.size.height-inset) controlPoint1:NSMakePoint(inset, bounds.size.height-inset) controlPoint2:NSMakePoint(inset, bounds.size.height-inset)];
  [path lineToPoint:NSMakePoint(bounds.size.width-radius-inset, bounds.size.height-inset)];
  [path curveToPoint:NSMakePoint(bounds.size.width-inset, bounds.size.height-radius-inset) controlPoint1:NSMakePoint(bounds.size.width-inset, bounds.size.height-inset) controlPoint2:NSMakePoint(bounds.size.width-inset, bounds.size.height-inset)];
  [path lineToPoint:NSMakePoint(bounds.size.width-inset, inset)];
  [path closePath];
//  [[NSColor controlLightHighlightColor] set];
//  [path fill];
  [path setLineWidth:lineWidth];
  [[NSColor lightGrayColor] set];
  [path stroke];
  
  if (!aGradient) {
		aGradient = [[NSGradient alloc]
                 initWithStartingColor:[NSColor colorWithDeviceRed:0.98 green:0.98 blue:0.98 alpha:1.0]
                 endingColor:[NSColor lightGrayColor]];
	}
	[aGradient drawInBezierPath:path angle:270];
  
  
  // Drawing code here.
}

@end
