//
//  SBGradientView.h
//  Strongbox
//
//  Created by Martin Hewitson on 5/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBGradientView : NSView {
	
	NSColor *borderColor;
  NSColor *startingColor;
  NSColor *endingColor;
	int cornerRadius;
  int angle;
	CGFloat borderWidth;
	
	NSGradient *aGradient;
	
}

// Define the variables as properties
@property(nonatomic, retain) NSColor *borderColor;
@property(nonatomic, retain) NSColor *startingColor;
@property(nonatomic, retain) NSColor *endingColor;
@property(assign) int cornerRadius;
@property(assign) int angle;
@property(assign) CGFloat borderWidth;

@end
