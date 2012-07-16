//
//  TPDescriptionView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/7/11.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPDescriptionView.h"

@implementation TPDescriptionView

@synthesize descriptionText;
@synthesize backgroundColor;
@synthesize descriptionCell;
@synthesize borderColor;

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.descriptionText = @"";
    self.backgroundColor = [NSColor clearColor];
    self.borderColor = [NSColor lightGrayColor];
    descriptionCell = [[NSTextFieldCell alloc] initTextCell:self.descriptionText];
    [descriptionCell setWraps:YES];
    [descriptionCell setTextColor:[NSColor darkGrayColor]];
    [descriptionCell setBackgroundStyle:NSBackgroundStyleRaised];
    [descriptionCell setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
  }
  
  return self;
}

- (void) dealloc
{
  [descriptionCell release];
  [backgroundColor release];
  [borderColor release];
  [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.
  NSRect bounds = [self bounds];
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(bounds, 0.5, 0.5)
                                                       xRadius:5.0 yRadius:5.0];
  [path setLineWidth:1.0];
  [self.borderColor set];
  [path stroke];
  [self.backgroundColor set];
  [path fill];
  
  if (self.descriptionText) {
    [descriptionCell setStringValue:self.descriptionText];
  } else {
    [descriptionCell setStringValue:@""];    
  }
  [descriptionCell drawWithFrame:NSInsetRect(bounds, 3.0, 3.0) inView:self];
}

@end
