//
//  TPDescriptionView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
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
  }
  
  return self;
}

- (void) dealloc
{
  [descriptionCell release];
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
