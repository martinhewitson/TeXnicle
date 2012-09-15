//
//  NSColor+Lightness.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/09/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSColor+Lightness.h"

@implementation NSColor (Lightness)

- (BOOL)isDarkerThan:(float)lightness
{
  NSColor *monoColor = [self colorUsingColorSpaceName:@"NSCalibratedWhiteColorSpace"];
  return ([monoColor whiteComponent] < lightness);
}


@end
