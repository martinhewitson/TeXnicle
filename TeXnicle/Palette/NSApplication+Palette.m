//
//  NSApplication+Palette.m
//  TeXnicle
//
//  Created by Martin Hewitson on 2/8/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSApplication+Palette.h"
#import "TeXnicleAppController.h"

@implementation NSApplication (Palette)

+ (TPPalette*)sharedPalette
{
  id delegate = [[NSApplication sharedApplication] delegate];
  if (delegate) {
    return [(TeXnicleAppController*)delegate palette];
  }
  return nil;
}

@end
