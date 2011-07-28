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
@synthesize showRevealButton;

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.showRevealButton = NO;
    self.projectStatusText = @"";
    projectStatusCell = [[NSTextFieldCell alloc] initTextCell:self.projectStatusText];
    [projectStatusCell setBackgroundStyle:NSBackgroundStyleRaised];
    self.editorStatusText = @"";
    editorStatusCell = [[NSTextFieldCell alloc] initTextCell:self.editorStatusText];
    [editorStatusCell setBackgroundStyle:NSBackgroundStyleRaised];
    
    revealButton = nil;
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
  CGFloat buttonWidth = 20.0;
  CGFloat buttonHeight = 18.0;
  
  if (self.projectStatusText) {
    [projectStatusCell setStringValue:self.projectStatusText];
  } else {
    [projectStatusCell setStringValue:@""];    
  }
  NSSize filenameSize = [[projectStatusCell attributedStringValue] size];
  CGFloat filenameWidth = 1.0*MIN(filenameSize.width+10.0, bounds.size.width-buttonWidth);
  NSRect buttonRect = NSMakeRect(filenameWidth, bounds.size.height/2.0 + (bounds.size.height/2.0-buttonHeight)/2.0, buttonWidth, buttonHeight);
  NSRect top = NSMakeRect(0, bounds.size.height/2.0, filenameWidth, bounds.size.height/2.0);
  NSRect bottom = NSMakeRect(0, 0.0, bounds.size.width, bounds.size.height/2.0);
  [projectStatusCell drawWithFrame:top inView:self];
  if (self.editorStatusText) {
    [editorStatusCell setStringValue:self.editorStatusText];
  } else {
    [editorStatusCell setStringValue:@""];
  }
  [editorStatusCell drawWithFrame:bottom inView:self];
  
  if (!revealButton) {
    NSImage *image = [NSImage imageNamed:@"revealArrow"];
    [image setSize:NSMakeSize(buttonWidth/2.0, buttonHeight/2.0)];
    revealButton = [[NSButton alloc] initWithFrame:buttonRect];
    [revealButton setTarget:self];
    [revealButton setAction:@selector(revealButtonClicked:)];
    [revealButton setImage:image];
    [revealButton setBezelStyle:NSRecessedBezelStyle];
    [revealButton setButtonType:NSMomentaryLightButton];
    [revealButton setShowsBorderOnlyWhileMouseInside:YES];
    [revealButton setImagePosition:NSImageOnly];
    [self addSubview:revealButton];
  } else {
    [revealButton setFrame:buttonRect];
  }
  [revealButton setHidden:!self.showRevealButton];
}

- (void) revealButtonClicked:(id)sender
{
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws selectFile:self.projectStatusText 
inFileViewerRootedAtPath:[self.projectStatusText stringByDeletingLastPathComponent]];

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
