//
//  NSView+Subview.m
//  TeXnicle
//
//  Created by Martin Hewitson on 02/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSView+Subview.h"

@implementation NSView (Subview)

- (BOOL)isSubviewOf:(NSView*)aView
{
  if ([[aView subviews] containsObject:self]) {
    return YES;
  }
  // check children
  for (NSView *v in [aView subviews]) {
    if ([self isSubviewOf:v]) {
      return YES;
    }
  }
  
  return NO;
}


@end
