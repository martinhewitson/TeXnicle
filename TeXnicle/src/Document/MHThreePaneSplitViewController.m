//
//  MHThreePaneSplitViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/11/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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

#import "MHThreePaneSplitViewController.h"

#define kSplitViewLeftMinSize 230.0
#define kSplitViewCenterMinSize 400.0
#define kSplitViewRightMinSize 400.0


@implementation MHThreePaneSplitViewController


- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
//  NSLog(@"Resize with old size %@", NSStringFromSize(oldSize));
  
  NSSize splitViewSize = [sender frame].size;  
  NSSize leftSize = [self.leftView frame].size;
  leftSize.height = splitViewSize.height;
  
  NSSize centerSize = [self.centerView frame].size;
  centerSize.height = splitViewSize.height;
  
  NSSize rightSize;
  rightSize.width = splitViewSize.width - centerSize.width;
  rightSize.width -= 2.0*[sender dividerThickness];
  
  if (![sender isSubviewCollapsed:self.leftView]) {
    rightSize.width -= leftSize.width + [sender dividerThickness];
  }
  
  rightSize.height = splitViewSize.height;
  
  if (![sender isSubviewCollapsed:self.leftView]) {
    [self.leftView setFrameSize:leftSize];
  }
  [self.centerView setFrameSize:centerSize];
  if (![sender isSubviewCollapsed:self.rightView]) {
    [self.rightView setFrameSize:rightSize];
  }
  
  [sender adjustSubviews];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
  
  if (subview == self.leftView || subview == self.centerView)
    return NO;
  
  
  if (subview == self.rightView) {
    NSRect b = [self.rightView bounds];
    if (b.size.width < kSplitViewRightMinSize) {
      return NO;
    }
  }
  
  return YES;
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
  if (subview == self.centerView) {
    return NO;
  }
  
  return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 0) {
    NSRect b = [splitView bounds];
    NSRect rb = [self.rightView bounds];
    CGFloat max =  b.size.width - rb.size.width - kSplitViewCenterMinSize;
    return max;
  }
  
  if (dividerIndex == 1) {
    NSRect b = [splitView bounds];
    return b.size.width-kSplitViewRightMinSize;
  }
  
  return proposedMax;
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 0) {
    return kSplitViewLeftMinSize;
  }
  
  if (dividerIndex == 1) {
    NSRect lb = [self.leftView bounds];
    
    if ([splitView isSubviewCollapsed:self.leftView]) {
      return kSplitViewCenterMinSize;
    }
    return lb.size.width + kSplitViewCenterMinSize;
  }
  
  
  
  return proposedMin;
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
  NSSize leftSize = [self.leftView frame].size;
  NSSize centerSize = [self.centerView frame].size;  
//  NSSize rightSize = [rightView frame].size;
  
//  NSLog(@"Left %@", NSStringFromSize(leftSize));
//  NSLog(@"Center %@", NSStringFromSize(centerSize));
//  NSLog(@"Right %@", NSStringFromSize(rightSize));
  
  CGFloat w = 0.0;
  
  if (![self.mainSplitView isSubviewCollapsed:self.leftView]) {
    w += leftSize.width;
    w += [self.mainSplitView dividerThickness];
  }
  if (![self.mainSplitView isSubviewCollapsed:self.centerView]) {
    w += centerSize.width;
    w += [self.mainSplitView dividerThickness];
  }
  
  if (![self.mainSplitView isSubviewCollapsed:self.rightView]) {
    if ((frameSize.width - w) < 200.0) {
      frameSize.width = w + 200.0;
    }  
  }
  
  return frameSize; 
}

@end
