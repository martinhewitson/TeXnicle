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
@synthesize selectingStatus;

- (void) awakeFromNib
{
  capturedString = @"";
  resetTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(resetTimerFired:) userInfo:nil repeats:YES];
}

- (void) dealloc
{
  [self.resetTimer invalidate];
  self.resetTimer = nil;
  self.lastKeyStroke = nil;
  [super dealloc];
}

- (void) keyDown:(NSEvent *)theEvent
{
  NSString *newChars = [theEvent characters];
  char c = [newChars characterAtIndex:0];
  if(c>='0' && c<='9')
  {
    capturedString = [capturedString stringByAppendingString:[theEvent characters]];
    self.lastKeyStroke = [NSDate date];
    [self updateStatus];
  }
  
  
  [super keyDown:theEvent];
}

- (void)resetTimerFired:(NSTimer*)theTimer
{
  NSDate *now = [NSDate date];
  NSTimeInterval elapsed = [now timeIntervalSinceDate:self.lastKeyStroke];
  if (elapsed > 0.5) {
    NSInteger line = [capturedString integerValue];
    [self.bookmarkDelegate selectBookmarkForLinenumber:line];  
    capturedString = @"";
    [self updateStatus];
  }
}

- (void) updateStatus
{
  if ([capturedString length] == 0) {
    [self.selectingStatus setStringValue:@""];
  } else {
    [self.selectingStatus setStringValue:[NSString stringWithFormat:@"Jumping to %@", capturedString]];
  }
}

@end
