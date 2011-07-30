//
//  TPMetal.h
//  TeXnicle
//
//  Created by Martin Hewitson on 13/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSMTabStyle.h"


@interface TPMetalTabStyle : NSObject <PSMTabStyle> {

	NSImage *metalCloseButton;
	NSImage *metalCloseButtonDown;
	NSImage *metalCloseButtonOver;
	NSImage *metalCloseDirtyButton;
	NSImage *metalCloseDirtyButtonDown;
	NSImage *metalCloseDirtyButtonOver;
	NSImage *_addTabButtonImage;
	NSImage *_addTabButtonPressedImage;
	NSImage *_addTabButtonRolloverImage;
	
	NSDictionary *_objectCountStringAttributes;
	
	PSMTabBarOrientation orientation;
	PSMTabBarControl *tabBar;
}

- (void)drawInteriorWithTabCell:(PSMTabBarCell *)cell inView:(NSView*)controlView;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;


@end
