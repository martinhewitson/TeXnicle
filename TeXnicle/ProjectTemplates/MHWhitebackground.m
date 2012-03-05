//
//  MHWhitebackground.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHWhitebackground.h"

@implementation MHWhitebackground

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.
  NSRect bounds = [self bounds];
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(bounds, 0.5, 0.5)
                                                       xRadius:5.0 yRadius:5.0];
  [path setLineWidth:1.0];
  [[NSColor lightGrayColor] set];
  [path stroke];
  [[NSColor colorWithDeviceWhite:1.0 alpha:0.75] set];
  [path fill];
  
}

@end
