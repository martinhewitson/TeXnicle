//
//  TPTabbarMatchingBackground.m
//  TeXnicle
//
//  Created by Martin Hewitson on 13/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPTabbarMatchingBackground.h"

@interface TPTabbarMatchingBackground ()

@property (strong) NSColor *activeColor;
@property (strong) NSColor *inactiveColor;

@end

@implementation TPTabbarMatchingBackground

- (void) awakeFromNib
{
  self.borderWidth = 0.5;
  self.borderColor = [NSColor darkGrayColor];
  self.cornerRadius = 0.0;
  self.startingColor = [NSColor colorWithDeviceWhite:162.0/255.0 alpha:1.0];
  self.endingColor = self.startingColor;
  
  
  self.activeColor = [NSColor colorWithDeviceWhite:162.0/255.0 alpha:1.0];
  self.inactiveColor = [NSColor colorWithDeviceWhite:222.0/255.0 alpha:1.0];
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(windowStatusDidChange:) name:NSWindowDidBecomeKeyNotification object:[self window]];
  [nc addObserver:self selector:@selector(windowStatusDidChange:) name:NSWindowDidResignKeyNotification object:[self window]];
  
}

- (void) windowStatusDidChange:(NSNotification*)aNote
{
  [self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)dirtyRect
{
  NSWindow *window = [self window];
  
  if ([window isKeyWindow] || [window isMainWindow]) {
    self.startingColor = self.activeColor;
  } else {
    self.startingColor = self.inactiveColor;
  }
  self.endingColor = self.startingColor;
  
  [super drawRect:dirtyRect];
}

@end
