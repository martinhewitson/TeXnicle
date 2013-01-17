//
//  TPBoxView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/1/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPBoxView.h"

@implementation TPBoxView


- (void)drawRect:(NSRect)dirtyRect
{
  CGFloat radius = 0.0f;
  CGFloat lineWidth = 2.0f;
  NSRect bounds = [self bounds];
  
  NSBezierPath *path = [NSBezierPath bezierPath];
  CGFloat inset = lineWidth/2.0;
  
  
  [path moveToPoint:NSMakePoint(inset, radius)];
  [path lineToPoint:NSMakePoint(inset, bounds.size.height-radius)];
  [path curveToPoint:NSMakePoint(radius+inset, bounds.size.height-inset) controlPoint1:NSMakePoint(inset, bounds.size.height-inset) controlPoint2:NSMakePoint(inset, bounds.size.height-inset)];
  [path lineToPoint:NSMakePoint(bounds.size.width-radius-inset, bounds.size.height-inset)];
  [path curveToPoint:NSMakePoint(bounds.size.width-inset, bounds.size.height-radius-inset) controlPoint1:NSMakePoint(bounds.size.width-inset, bounds.size.height-inset) controlPoint2:NSMakePoint(bounds.size.width-inset, bounds.size.height-inset)];
  [path lineToPoint:NSMakePoint(bounds.size.width-inset, radius)];
  [path curveToPoint:NSMakePoint(bounds.size.width-radius, inset) controlPoint1:NSMakePoint(bounds.size.width-inset, inset) controlPoint2:NSMakePoint(bounds.size.width-inset, inset)];
  [path lineToPoint:NSMakePoint(radius, inset)];
  [path curveToPoint:NSMakePoint(inset, radius) controlPoint1:NSMakePoint(inset, inset) controlPoint2:NSMakePoint(inset, inset)];
  [path closePath];

  [path setLineWidth:lineWidth];
  [[NSColor lightGrayColor] set];
  [path stroke];
  
}

@end
