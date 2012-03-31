//
//  BookmarkOutlineView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
