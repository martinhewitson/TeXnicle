//
//  MHMiniConsoleBackground.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHMiniConsoleBackground.h"

@implementation MHMiniConsoleBackground

- (void)awakeFromNib
{
  self.endingColor = [NSColor colorWithDeviceRed:235.0/255.0 green:245.0/255.0 blue:255.0/255.0 alpha:1.0];
  self.startingColor = [NSColor colorWithDeviceRed:210.0/255.0 green:220.0/255.0 blue:230.0/255.0 alpha:1.0];
  self.angle = 90;
  self.cornerRadius = 2;
  self.borderWidth = 0.0;
}

@end
