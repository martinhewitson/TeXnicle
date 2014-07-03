//
//  MHStrokedFiledView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import "MHStrokedFiledView.h"

@implementation MHStrokedFiledView


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
