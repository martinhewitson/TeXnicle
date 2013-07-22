//
//  NSColor+ContrastingLabelExtensions.m

#import "NSColor+ContrastingLabelExtensions.h"


@implementation NSColor (ContrastingLabelExtensions)

- (NSColor *)contrastingLabelColor
{
  NSColor *monoColor = [self colorUsingColorSpaceName:@"NSCalibratedWhiteColorSpace"];
  CGFloat avgGray = [monoColor whiteComponent];
	return (avgGray > 0.95) ? [NSColor blackColor] : [NSColor whiteColor];
}

- (NSString*) stringArray
{
	CGFloat			fRed, fGreen, fBlue, fAlpha;
	
	NSColor *col = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	[col getRed: &fRed green: &fGreen blue: &fBlue alpha: &fAlpha];
	
	return [NSString stringWithFormat:@"%f %f %f %f", fRed, fGreen, fBlue, fAlpha];
}


@end
