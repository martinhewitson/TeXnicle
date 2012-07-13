//
//  TPTabbarMatchingBackground.m
//  TeXnicle
//
//  Created by Martin Hewitson on 13/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPTabbarMatchingBackground.h"

@implementation TPTabbarMatchingBackground

- (void) awakeFromNib
{
  self.borderWidth = 0.5;
  self.borderColor = [NSColor blackColor];
  self.cornerRadius = 0.0;
  self.startingColor = [NSColor colorWithDeviceWhite:184.0/255.0 alpha:1.0];
  self.endingColor = self.startingColor;
}

@end
