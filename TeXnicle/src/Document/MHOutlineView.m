//
//  MHOutlineView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 03/07/14.
//  Copyright (c) 2014 bobsoft. All rights reserved.
//

#import "MHOutlineView.h"
#import "NSApplication+SystemVersion.h"

@implementation MHOutlineView

- (BOOL) allowsVibrancy
{
  return YES;
}

- (void) awakeFromNib
{
  if ([NSApp isYosemite]) {
    [self setRowHeight:22.0];
    [self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
  } else {
    [self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
  }
  
}

@end
