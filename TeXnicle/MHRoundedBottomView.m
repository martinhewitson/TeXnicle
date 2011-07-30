//
//  MHRoundedBottomView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 02/06/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHRoundedBottomView.h"


@implementation MHRoundedBottomView

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
  [path moveToPoint:NSMakePoint(inset, bounds.size.height-inset)];
  [path lineToPoint:NSMakePoint(inset, radius-inset)];
  [path curveToPoint:NSMakePoint(radius+inset, inset) controlPoint1:NSMakePoint(inset, inset) controlPoint2:NSMakePoint(inset, inset)];
  [path lineToPoint:NSMakePoint(bounds.size.width-radius-inset, inset)];
  [path curveToPoint:NSMakePoint(bounds.size.width-inset, radius-inset) controlPoint1:NSMakePoint(bounds.size.width-inset, inset) controlPoint2:NSMakePoint(bounds.size.width-inset, inset)];
  [path lineToPoint:NSMakePoint(bounds.size.width-inset, bounds.size.height-inset)];
  [path closePath];
  //  [[NSColor controlLightHighlightColor] set];
  //  [path fill];
  [path setLineWidth:lineWidth];
  [[NSColor lightGrayColor] set];
  [path stroke];
  
  if (!aGradient) {
		aGradient = [[NSGradient alloc]
                 initWithStartingColor:[NSColor colorWithDeviceRed:0.96 green:0.96 blue:0.96 alpha:1.0]
                 endingColor:[NSColor lightGrayColor]];
	}
	[aGradient drawInBezierPath:path angle:270];
  
  
  // Drawing code here.
}

@end
