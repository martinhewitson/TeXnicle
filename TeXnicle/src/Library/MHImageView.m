//
//  MHImageView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 02/06/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
