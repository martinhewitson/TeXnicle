//
//  MHImageView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 02/06/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHImageView.h"


@implementation MHImageView

- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void) drawRect:(NSRect)dirtyRect
{
  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);
//  [super drawRect:dirtyRect];
  
  NSRect bounds = [self bounds];
  NSImage *image =   [self image];
  NSSize size = [image size]; 
  // scale size so that width fits bounds
  CGFloat w = bounds.size.width;
  CGFloat scale = w/size.width;
  CGFloat h = scale * size.height;
  
  if (h > bounds.size.height) {
    h = bounds.size.height;
    scale = h/size.height;    
    w = size.width*scale;
  }
  
  NSRect imrect = NSMakeRect(bounds.size.width/2-w/2, bounds.size.height/2-h/2, w, h);
  
  [image drawInRect:imrect
           fromRect:NSZeroRect
          operation:NSCompositeSourceOver
           fraction:1.0];
  
//  NSRect		imageBounds = NSMakeRect (0, 0, size.width, size.height);
//  
//  [image lockFocus];
//  [[NSColor whiteColor] set];
//  NSRectFill (imageBounds);
//  [image unlockFocus];
//  [super drawRect:dirtyRect];
}

@end
