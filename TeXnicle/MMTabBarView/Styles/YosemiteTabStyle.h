//
//  YosemiteTabStyle
//  MMTabBarView
//
//

#import <Cocoa/Cocoa.h>
#import "MMTabStyle.h"

@interface YosemiteTabStyle : NSObject <MMTabStyle>
{
	NSImage					*_closeButton;
	NSImage					*_closeButtonDown;
	NSImage					*_closeButtonOver;
	NSImage					*_closeDirtyButton;
	NSImage					*_closeDirtyButtonDown;
	NSImage					*_closeDirtyButtonOver;
	NSImage					*_gradientImage;

	BOOL					_drawsUnified;
	BOOL					_drawsRight;
}

- (void)loadImages;

- (BOOL)drawsUnified;
- (void)setDrawsUnified:(BOOL)value;
- (BOOL)drawsRight;
- (void)setDrawsRight:(BOOL)value;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
