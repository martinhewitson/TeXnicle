//
//  NSImage+Resize.m
//  Agenda2
//
//  Created by Martin Hewitson on 6/1/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "NSImage+Resize.h"


@implementation NSImage (Resize)

- (NSImage*)resizeToSize:(NSSize)aSize
{
	NSRect oldRect = NSMakeRect(0.0, 0.0, self.size.width, self.size.height);
  
  // new size
  CGFloat w = aSize.width;
  CGFloat h = aSize.height;

  CGFloat ow = self.size.width;
  CGFloat oh = self.size.height;
  
  while (ow > w || oh > h) {
    ow *= 0.95;
    oh *= 0.95;
  }
  
  while (ow < w && oh < h) {
    ow *= 1.05;
    oh *= 1.05;
  }
  
  // one final step
  if (ow > w || oh > h) {
    ow *= 0.95;
    oh *= 0.95;
  }
  
	NSRect newRect = NSMakeRect(0.0, 0.0, ow, oh);
	NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(ow, oh)];
  
	[newImage lockFocus];
	[self drawInRect:newRect fromRect:oldRect operation:NSCompositeCopy fraction:1.0];
	[newImage unlockFocus];
	return newImage;
}

@end
