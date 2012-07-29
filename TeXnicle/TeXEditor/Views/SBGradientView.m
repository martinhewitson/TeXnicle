//
//  SBGradientView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 5/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
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
#import "SBGradientView.h"

@interface SBGradientView ()

@end

@implementation SBGradientView


- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
		[self setBorderColor:[NSColor blackColor]];
    [self setStartingColor:[NSColor lightGrayColor]];
    [self setEndingColor:[NSColor whiteColor]];
    [self setAngle:0];
		[self setCornerRadius:0];
		[self setBorderWidth:1.0];
  }
  return self;
}


- (void)setStartingColor:(NSColor *)aColor
{
	if (_startingColor) {
		_startingColor = nil;
	}
	
	_startingColor = [aColor copy];
		
	aGradient = nil;
}


- (void) setEndingColor:(NSColor *)aColor
{
	if (_endingColor) {
		_endingColor = nil;
	}
	
	_endingColor = [aColor copy];
	
	aGradient = nil;
}

- (void)drawRect:(NSRect)rect {
	// Fill view with a top-down gradient
	// from startingColor to endingColor
	if (!aGradient) {
		aGradient = [[NSGradient alloc]
									initWithStartingColor:_startingColor
									endingColor:_endingColor];
	}
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:_cornerRadius yRadius:_cornerRadius];
	[aGradient drawInBezierPath:path angle:_angle];
	
	// stroke border
	if (_borderColor && _borderWidth>0.0) {
		NSRect r = NSInsetRect([self bounds], _borderWidth, _borderWidth);
		path = [NSBezierPath bezierPathWithRoundedRect:r xRadius:_cornerRadius yRadius:_cornerRadius];
		[path setLineWidth:_borderWidth];
		[_borderColor set];
		[path stroke];
	}
	
}

@end
