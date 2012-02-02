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

//- (void)drawPage:(PDFPage *)page
//{
//  NSLog(@"Draw rect");
//  [super drawPage:page];
//  // focussed?
//  if ([[self window] firstResponder] == self) {
//    
//    [[NSGraphicsContext currentContext] saveGraphicsState];
//    
//    NSRect displayRect = [page boundsForBox:[self displayBox]];
//
//    [[NSColor yellowColor] set];
//    [NSBezierPath setDefaultLineWidth:1.0];
//    [NSBezierPath strokeRect:displayRect];
//        
//    [[NSGraphicsContext currentContext] restoreGraphicsState];
//  }
//}
//
- (BOOL)becomeFirstResponder
{
  [[NSNotificationCenter defaultCenter] postNotificationName:MHPDFViewDidGainFocusNotification object:self];
  return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
  [[NSNotificationCenter defaultCenter] postNotificationName:MHPDFViewDidLoseFocusNotification object:self];
  return [super resignFirstResponder];
}

@end
