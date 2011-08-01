//
//  TPImageViewerBackgroundView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPImageViewerBackgroundView.h"

@implementation TPImageViewerBackgroundView

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
  NSRect bounds = [self bounds];
  [[NSColor whiteColor] set];
  NSRectFill(bounds);
  [[NSColor lightGrayColor] set];
  [NSBezierPath setDefaultLineWidth:2.0];
  [NSBezierPath strokeRect:NSInsetRect(bounds, 1.0, 1.0)];
}

@end
