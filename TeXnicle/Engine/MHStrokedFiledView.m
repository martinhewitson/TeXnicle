//
//  MHStrokedFiledView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHStrokedFiledView.h"

@implementation MHStrokedFiledView

@synthesize fillColor;
@synthesize strokeColor;
@synthesize strokeSides;


- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
    self.fillColor = [NSColor controlBackgroundColor];
    self.strokeColor = [NSColor darkGrayColor];
    self.strokeSides = NO;
  }
  
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.
  NSRect b = [self bounds];
  
  NSRect r = NSInsetRect(b, 0.5, 0.5);

  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint:NSMakePoint(r.origin.x, r.origin.y)];
  [path lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y)];
  [path moveToPoint:NSMakePoint(r.origin.x, r.origin.y+r.size.height)];
  [path lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height)];
  
  if (self.strokeSides) {
    [path moveToPoint:NSMakePoint(r.origin.x, r.origin.y)];
    [path lineToPoint:NSMakePoint(r.origin.x, r.origin.y+r.size.height)];
    [path moveToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y)];
    [path lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height)];
  }
  
  [path setLineWidth:1.0];
  [self.strokeColor set];
  [path stroke];
  [self.fillColor set];
  NSRectFill(r);
  
}

@end
