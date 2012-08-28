//
//  MHPDFSearchResultsTable.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/08/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHPDFSearchResultsTable.h"

@implementation MHPDFSearchResultsTable

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

@end
