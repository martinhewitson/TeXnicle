//
//  TPDocumentOutlineView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 05/01/12.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPDocumentOutlineView.h"

@implementation TPDocumentOutlineView
@synthesize dataSource;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL) isFlipped
{
  return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);
  
  [self drawItem:nil yoffset:0.0];
  
}

- (CGFloat) drawItem:(id)item yoffset:(CGFloat)yoffset
{
  // draw items children
  
  NSInteger nChildren = [self outlineView:self numberOfChildrenOfItem:item];
  for (NSInteger c = 0; c<nChildren; c++) {
    
    id child = [self outlineView:self child:c ofItem:item];
    if (child == nil) {
      return yoffset;
    }
    
    id value = [self outlineView:self objectValueForItem:child];
    if (value == nil) {
      value = @"<null>";
    }
    
    if ([value isKindOfClass:[NSAttributedString class]]) {
      NSAttributedString *attStr = (NSAttributedString*)value;      
      NSSize strSize = [attStr size];
      
      CGFloat xoffset = 5.0 * [self outlineView:self indentLevelForItem:child];
      
      NSRect vr = [self visibleRect];
      if (yoffset >= vr.origin.y && yoffset < vr.origin.y+vr.size.height) {
        NSRect strRect = NSMakeRect(xoffset, yoffset, strSize.width, strSize.height);
        [attStr drawInRect:strRect];  
      }
      
      // move on
      yoffset += 1.1*strSize.height;
      
      // check bounds
      NSRect r = [self frame];
      NSRect newBounds = r;
      if (yoffset > r.size.height) {
        newBounds.size.height = yoffset + 10.0;
      }
      if (xoffset + strSize.width > r.size.width) {
        newBounds.size.width = xoffset + strSize.width + 10.0; 
      }
      
      if (!NSEqualRects(r, newBounds)) {
        [self setFrame:newBounds];
        [self setNeedsDisplay:YES];
        return yoffset;
      }      
    } else {
      NSLog(@"Error drawing value %@", value);
    }
    
    // draw children of this item
    yoffset = [self drawItem:child yoffset:yoffset];
    
  }
  return yoffset;
}

#pragma mark -
#pragma mark Data source

- (id)outlineView:(TPDocumentOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (self.dataSource && [self.dataSource respondsToSelector:@selector(outlineView:child:ofItem:)]) {
    return [self.dataSource outlineView:outlineView child:index ofItem:item];
  }
  return nil;
}

- (NSInteger)outlineView:(TPDocumentOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (self.dataSource && [self.dataSource respondsToSelector:@selector(outlineView:numberOfChildrenOfItem:)]) {
    return [self.dataSource outlineView:outlineView numberOfChildrenOfItem:item];
  }
  return 0;
}

- (id)outlineView:(TPDocumentOutlineView *)outlineView objectValueForItem:(id)item
{
  if (self.dataSource && [self.dataSource respondsToSelector:@selector(outlineView:objectValueForItem:)]) {
    return [self.dataSource outlineView:outlineView objectValueForItem:item];
  }
  return nil;
}

- (NSUInteger)outlineView:(TPDocumentOutlineView*)outlineView indentLevelForItem:(id)item
{
  if (self.dataSource && [self.dataSource respondsToSelector:@selector(outlineView:indentLevelForItem:)]) {
    return [self.dataSource outlineView:outlineView indentLevelForItem:item];
  }
  return 0;
}



@end
