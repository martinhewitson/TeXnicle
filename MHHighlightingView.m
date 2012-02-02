//
//  MHHighlightingView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 02/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHHighlightingView.h"
#import "MHPDFView.h"
#import "NSView+Subview.h"

@implementation MHHighlightingView

@synthesize isFocused;

- (void) awakeFromNib
{
  self.isFocused = NO;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handlePDFViewGainedFocusNotification:)
                                               name:MHPDFViewDidGainFocusNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handlePDFViewLostFocusNotification:)
                                               name:MHPDFViewDidLoseFocusNotification
                                             object:nil];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void) handlePDFViewGainedFocusNotification:(NSNotification*)aNote
{
  NSView *v = [aNote object];
  if ([v isSubviewOf:self]) {
    self.isFocused = YES;
    [self setNeedsDisplay:YES];
  }
}


- (void) handlePDFViewLostFocusNotification:(NSNotification*)aNote
{
  NSView *v = [aNote object];
  if ([v isSubviewOf:self]) {
    self.isFocused = NO;
    [self setNeedsDisplay:YES];
  }
}

- (void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  if (self.isFocused) {
    [[NSColor keyboardFocusIndicatorColor] set];
    [NSBezierPath setDefaultLineWidth:1.0];
    [NSBezierPath strokeRect:[self bounds]];
  } else {
    [[NSColor darkGrayColor] set];
    [NSBezierPath setDefaultLineWidth:1.0];
    [NSBezierPath strokeRect:[self bounds]];
  }
  
}

@end
