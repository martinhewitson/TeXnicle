//
//  MHRoundedBottomView.m
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
