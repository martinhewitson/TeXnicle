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

@synthesize delegate;

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

- (void)displayLineAtPoint:(NSPoint)point inPageAtIndex:(NSUInteger)pageIndex
{
  if (pageIndex < [[self document] pageCount]) {
    PDFPage *page = [[self document] pageAtIndex:pageIndex];
    PDFSelection *sel = [page selectionForLineAtPoint:point];
    NSRect rect = [sel boundsForPage:page];    
    [self setCurrentSelection:sel animate:YES];    
    [self goToRect:rect onPage:page];    
    [self setNeedsDisplayInRect:rect ofPage:[[self document] pageAtIndex:pageIndex]];
  }
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
