//
//  MHPDFView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "MHPDFView.h"

NSString * const MHPDFViewDidGainFocusNotification = @"MHPDFViewDidGainFocusNotification";
NSString * const MHPDFViewDidLoseFocusNotification = @"MHPDFViewDidLoseFocusNotification";


@implementation MHPDFView

- (void) awakeFromNib
{
  [super awakeFromNib];
  [self setBackgroundColor:[NSColor colorWithDeviceRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
}

- (void)performFindPanelAction:(id)sender
{
  NSEvent *event = [[NSApplication sharedApplication] currentEvent];
  if ([event.characters isEqualToString:@"f"]) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(findInPDF:)]) {
      [self.delegate performSelector:@selector(findInPDF:) withObject:self];
    }
  } else if ([event.characters isEqualToString:@"g"]) {
    NSUInteger modifiers = [event modifierFlags];
    if (modifiers & NSShiftKeyMask) {
      // find previous
      if (self.delegate && [self.delegate respondsToSelector:@selector(showPreviousResult:)]) {
        [self.delegate performSelector:@selector(showPreviousResult:) withObject:self];
      }
    } else {
      // find next
      if (self.delegate && [self.delegate respondsToSelector:@selector(showNextResult:)]) {
        [self.delegate performSelector:@selector(showNextResult:) withObject:self];
      }
    }
  }
}

- (void) setNeedsDisplay
{
  [self setNeedsDisplay:YES];
}

- (void) setNeedsDisplay:(BOOL)flag
{
//  NSLog(@"Set Needs Display");
  [super setNeedsDisplay:flag];
}

- (void) drawPagePost:(PDFPage *)page
{
  [super drawPagePost:page];
  
//  NSLog(@"Draw page post");
  // focussed?
  if ([[self window] firstResponder] == self && [NSApp isActive]) {
    //    NSLog(@"  is first responder");
    [NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
    NSRect r = [[self documentView] bounds];
		[[NSBezierPath bezierPathWithRect:r] fill];
    [NSGraphicsContext restoreGraphicsState];
  }
  
}


- (BOOL)becomeFirstResponder
{
//  NSLog(@"Become first");
//  [[NSNotificationCenter defaultCenter] postNotificationName:MHPDFViewDidGainFocusNotification object:self];
  BOOL success = [super becomeFirstResponder];
  if (success) {
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
  }
  
  return success;
}

- (BOOL)resignFirstResponder
{
//  NSLog(@"Resign first");
//  [[NSNotificationCenter defaultCenter] postNotificationName:MHPDFViewDidLoseFocusNotification object:self];
  
  BOOL success = [super resignFirstResponder];
  
  if (success) {
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
  }
  
  return success;
}

- (void) displayLineAtPoint:(NSPoint)point inPageAtIndex:(NSUInteger)pageIndex
{
  [self displayLineAtPoint:point inPageAtIndex:pageIndex giveFocus:YES];
}

- (void)displayLineAtPoint:(NSPoint)point inPageAtIndex:(NSUInteger)pageIndex giveFocus:(BOOL)shouldFocus
{
  if ([self document]) {
    if (pageIndex < [[self document] pageCount]) {
      PDFPage *page = [[self document] pageAtIndex:pageIndex];
      PDFSelection *sel = [page selectionForLineAtPoint:point];
      if ([self currentPage] != page) {
        [self performSelectorOnMainThread:@selector(goToPage:) withObject:page waitUntilDone:YES];
      }
      [self setCurrentSelection:sel];
      [self scrollSelectionToVisible:self];
      [self setCurrentSelection:nil];
      [self display];
      if (shouldFocus) {
        [[self window] makeFirstResponder:self];
        [self performSelector:@selector(setCurrentSelectionAndAnimate:) withObject:sel afterDelay:0];
      }
    }
  }
}



- (void) setCurrentSelectionAndAnimate:(PDFSelection*)sel
{
  [self setCurrentSelection:sel animate:YES];
}

- (void)setNeedsDisplayInRect:(NSRect)rect ofPage:(PDFPage *)page 
{
  NSRect aRect = [self convertRect:rect fromPage:page];
  CGFloat scale = [self scaleFactor];
  CGFloat maxX = ceil(NSMaxX(aRect) + scale);
  CGFloat maxY = ceil(NSMaxY(aRect) + scale);
  CGFloat minX = floor(NSMinX(aRect) - scale);
  CGFloat minY = floor(NSMinY(aRect) - scale);
  
  aRect = NSIntersectionRect([self bounds], NSMakeRect(minX, minY, maxX - minX, maxY - minY));
  if (NSIsEmptyRect(aRect) == NO)
    [self setNeedsDisplayInRect:aRect];
}

- (void) mouseDown:(NSEvent *)theEvent
{
  NSUInteger modifiers = [theEvent modifierFlags];
  if (modifiers & NSCommandKeyMask) {
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    PDFPage *page = [self pageForPoint:mouseLoc nearest:YES];
    NSPoint location = [self convertPoint:mouseLoc toPage:page];
    NSUInteger pageIndex = [[page document] indexForPage:page];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pdfview:didCommandClickOnPage:inRect:atPoint:)]) {     
      [self.delegate pdfview:self didCommandClickOnPage:pageIndex inRect:[page boundsForBox:kPDFDisplayBoxMediaBox] atPoint:location];
    }
  }
  
  [super mouseDown:theEvent];
  
}

@end
