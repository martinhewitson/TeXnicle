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

- (BOOL) isEqualToColor:(NSColor *)otherColor
{
  NSLog(@"Checking %p against %p", self, otherColor);
  
  if (self == otherColor)
    return YES;
  
  NSColor *c1 = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
  NSColor *c2 = [otherColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
  
  
	CGFloat r1, g1, b1, a1;
	CGFloat r2, g2, b2, a2;
  [c1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
  [c2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
  
  NSLog(@"Comparing (%f,%f,%f,%f) and (%f,%f,%f,%f)", r1, g1, b1, a1, r2, g2, b2, a2);
  
  CGFloat tol = 1e-10;
  if (fabs(r1-r2)< tol & fabs(g1-g2) < tol & fabs(b1-b2) < tol & fabs(a1-a2) < tol) {
    return YES;
  }
  
  return NO;
}

@end
