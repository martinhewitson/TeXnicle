//
//  TPStatusView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 03/07/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "TPStatusView.h"

@implementation TPStatusView

@synthesize editorStatusText;
@synthesize projectStatusText;

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
    self.projectStatusText = @"";
    projectStatusCell = [[NSTextFieldCell alloc] initTextCell:self.projectStatusText];
    [projectStatusCell setBackgroundStyle:NSBackgroundStyleRaised];
    self.editorStatusText = @"";
    editorStatusCell = [[NSTextFieldCell alloc] initTextCell:self.editorStatusText];
    [editorStatusCell setBackgroundStyle:NSBackgroundStyleRaised];
  }
  
  return self;
}

- (void) dealloc
{
  [projectStatusCell release];
  [editorStatusCell release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.
  NSRect bounds = [self bounds];
  NSRect top = NSMakeRect(0, bounds.size.height/2.0, bounds.size.width, bounds.size.height/2.0);
  NSRect bottom = NSMakeRect(0, 0.0, bounds.size.width, bounds.size.height/2.0);
  if (self.projectStatusText) {
    [projectStatusCell setStringValue:self.projectStatusText];
  } else {
    [projectStatusCell setStringValue:@""];    
  }
  [projectStatusCell drawWithFrame:top inView:self];
  if (self.editorStatusText) {
    [editorStatusCell setStringValue:self.editorStatusText];
  } else {
    [editorStatusCell setStringValue:@""];
  }
  [editorStatusCell drawWithFrame:bottom inView:self];
}

- (void) setProjectStatus:(NSString*)text
{
  self.projectStatusText = text;
  [self setNeedsDisplay:YES];
}

- (void) setEditorStatus:(NSString*)text
{
  self.editorStatusText = text;
  [self setNeedsDisplay:YES];
}


@end
