//
//  BookmarkOutlineView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "BookmarkOutlineView.h"

@implementation BookmarkOutlineView

@synthesize bookmarkDelegate;
@synthesize resetTimer;
@synthesize lastKeyStroke;

- (void) awakeFromNib
{
  capturedString = @"";
  resetTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(resetTimerFired:) userInfo:nil repeats:YES];
}

- (void) dealloc
{
  [self.resetTimer invalidate];
  self.resetTimer = nil;
  [super dealloc];
}

- (void) keyDown:(NSEvent *)theEvent
{
  capturedString = [capturedString stringByAppendingString:[theEvent characters]];
  self.lastKeyStroke = [NSDate date];
  
  NSInteger line = [capturedString integerValue];
  [self.bookmarkDelegate selectBookmarkForLinenumber:line];  
  
  [super keyDown:theEvent];
}

- (void)resetTimerFired:(NSTimer*)theTimer
{
  NSDate *now = [NSDate date];
  NSTimeInterval elapsed = [now timeIntervalSinceDate:self.lastKeyStroke];
  if (elapsed > 1.0) {
    capturedString = @"";
  }
}

@end
