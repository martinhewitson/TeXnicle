//
//  TPPopupTableView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 30/1/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPPopupTableView.h"

@implementation TPPopupTableView

- (void)highlightSelectionInClipRect:(NSRect)theClipRect
{
  
  // this method is asking us to draw the hightlights for
  // all of the selected rows that are visible inside theClipRect
  
  // 1. get the range of row indexes that are currently visible
  // 2. get a list of selected rows
  // 3. iterate over the visible rows and if their index is selected
  // 4. draw our custom highlight in the rect of that row.
  
  NSRange         aVisibleRowIndexes = [self rowsInRect:theClipRect];
  NSIndexSet *    aSelectedRowIndexes = [self selectedRowIndexes];
  NSInteger       aRow = aVisibleRowIndexes.location;
  NSInteger       anEndRow = aRow + aVisibleRowIndexes.length;
  NSGradient *    gradient;
  
  // if the view is focused, use highlight color, otherwise use the out-of-focus highlight color
  gradient = [[NSGradient alloc] initWithColorsAndLocations:
               [NSColor colorWithDeviceRed:(float)163/255 green:(float)190/255 blue:(float)252/255 alpha:1.0], 0.0,
               [NSColor colorWithDeviceRed:(float)80/255 green:(float)150/255 blue:(float)240/255 alpha:1.0], 1.0, nil]; //160 80
  
  
  // draw highlight for the visible, selected rows
  for (aRow; aRow < anEndRow; aRow++)
  {
    if([aSelectedRowIndexes containsIndex:aRow])
    {
      NSRect aRowRect = NSInsetRect([self rectOfRow:aRow], 1, 2); //first is horizontal, second is vertical
      NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:aRowRect xRadius:2.0 yRadius:2.0]; //6.0
      
      [gradient drawInBezierPath:path angle:90];
    }
  }
  
  [gradient release];
  
}

- (IBAction)moveDown:(id)sender
{
  NSInteger row = [self selectedRow];
  
  if (row == -1 && [self numberOfRows] > 0)
    row = 0;
  
  if (row < [self numberOfRows]-1){
    row ++;
  }
  
  if (row >= 0) {
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [self scrollRowToVisible:row];
  }
}


- (IBAction)moveUp:(id)sender
{
  NSInteger row = [self selectedRow];
  
  if (row == -1 && [self numberOfRows] > 0)
    row = 0;
  
  if (row > 0){
    row --;
  }
  
  if (row >= 0) {
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [self scrollRowToVisible:row];
  }
}

@end
