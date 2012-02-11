//
//  MHPDFView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHPDFView.h"

NSString * const MHPDFViewDidGainFocusNotification = @"MHPDFViewDidGainFocusNotification";
NSString * const MHPDFViewDidLoseFocusNotification = @"MHPDFViewDidLoseFocusNotification";


@implementation MHPDFView


- (void)performFindPanelAction:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(findInPDF:)]) {
    [self.delegate performSelector:@selector(findInPDF:) withObject:self];
  }
}

- (void)drawPage:(PDFPage *)page
{
  [super drawPage:page];
  // focussed?
  if ([[self window] firstResponder] == self && [NSApp isActive]) {
    
    [[self superview] lockFocus];
		NSRect fr = [self frame];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[[NSBezierPath bezierPathWithRect:fr] fill];
		[[self superview] unlockFocus];
  }
}

- (BOOL)becomeFirstResponder
{
//  [[NSNotificationCenter defaultCenter] postNotificationName:MHPDFViewDidGainFocusNotification object:self];
  [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
  return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
//  [[NSNotificationCenter defaultCenter] postNotificationName:MHPDFViewDidLoseFocusNotification object:self];
  [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
  return [super resignFirstResponder];
}

@end
