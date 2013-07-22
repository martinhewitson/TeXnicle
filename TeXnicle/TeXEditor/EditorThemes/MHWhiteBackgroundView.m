//
//  MHWhiteBackgroundView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "MHWhiteBackgroundView.h"

@implementation MHWhiteBackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.
  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);
}

@end
