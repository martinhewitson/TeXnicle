//
//  SBGradientView.m
//  Strongbox
//
//  Created by Martin Hewitson on 5/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "SBGradientView.h"


@implementation SBGradientView

// Automatically create accessor methods
@synthesize startingColor;
@synthesize endingColor;
@synthesize angle;
@synthesize cornerRadius;
@synthesize borderColor;
@synthesize borderWidth;

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

- (void) dealloc
{
	[aGradient release];
	[super dealloc];
}

- (void)setStartingColor:(NSColor *)aColor
{
	if (startingColor) {
		[startingColor release];
		startingColor = nil;
	}
	
	startingColor = [aColor copy];
		
	[aGradient release];
	aGradient = nil;
}


- (void) setEndingColor:(NSColor *)aColor
{
	if (endingColor) {
		[endingColor release];
		endingColor = nil;
	}
	
	endingColor = [aColor copy];
	
	[aGradient release];
	aGradient = nil;
}

- (void)drawRect:(NSRect)rect {
	// Fill view with a top-down gradient
	// from startingColor to endingColor
	if (!aGradient) {
		aGradient = [[NSGradient alloc]
									initWithStartingColor:startingColor
									endingColor:endingColor];
	}
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerRadius yRadius:cornerRadius];
	[aGradient drawInBezierPath:path angle:angle];
	
	// stroke border
	if (borderColor && borderWidth>0.0) {
		NSRect r = NSInsetRect([self bounds], borderWidth, borderWidth);
		path = [NSBezierPath bezierPathWithRoundedRect:r xRadius:cornerRadius yRadius:cornerRadius];
		[path setLineWidth:borderWidth];
		[borderColor set];
		[path stroke];
	}
	
}

@end
