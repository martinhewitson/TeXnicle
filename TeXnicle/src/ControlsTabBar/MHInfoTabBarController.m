//
//  MHInfoTabBarController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
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

#import "MHInfoTabBarController.h"

NSString * const TPInfoControlsTabSelectionDidChangeNotification = @"TPInfoControlsTabSelectionDidChangeNotification";

@implementation MHInfoTabBarController

@synthesize tabView;
@synthesize bookmarksButton;
@synthesize warningsButton;
@synthesize spellingButton;
@synthesize labelsButton;
@synthesize splitview;
@synthesize containerView;

- (void) awakeFromNib
{
  [self.tabView selectTabViewItemAtIndex:0];
  [self.spellingButton setState:NSOffState];
  [self.bookmarksButton setState:NSOffState];
  [self.warningsButton setState:NSOffState];
  [self.labelsButton setState:NSOffState];
  
  NSMutableArray *nonNilButtons = [NSMutableArray array];
  if (self.bookmarksButton != nil) {
    [nonNilButtons addObject:self.bookmarksButton];
  }
  if (self.warningsButton != nil) {
    [nonNilButtons addObject:self.warningsButton];
  }
  if (self.spellingButton != nil) {
    [nonNilButtons addObject:self.spellingButton];
  }
  if (self.labelsButton != nil) {
    [nonNilButtons addObject:self.labelsButton];
  }
  
  buttons = [[NSArray arrayWithArray:nonNilButtons] retain];
  
}

- (void) selectTabAtIndex:(NSInteger)index
{
  if (index >= 0 && index < [self.tabView numberOfTabViewItems]) {
    [self.tabView selectTabViewItemAtIndex:index];
    [self toggleOn:[self buttonForTabIndex:index]];
    [[NSNotificationCenter defaultCenter] postNotificationName:TPInfoControlsTabSelectionDidChangeNotification
                                                        object:self
                                                      userInfo:nil];
  }
}

- (void)dealloc
{
  [buttons release];
  [super dealloc];
}

- (NSInteger) indexOfSelectedTab
{
  return [self.tabView indexOfTabViewItem:[self.tabView selectedTabViewItem]];
}

- (IBAction)buttonSelected:(id)sender
{
  NSInteger idx = [self tabIndexForButton:sender];
  [self selectTabAtIndex:idx];
}

- (void) toggleOn:(id)except
{
  for (NSButton *b in buttons) {
    if (b == except) {
      [b setState:NSOnState];
    } else {
      [b setState:NSOffState];      
    }
  }
}


- (id) buttonForTabIndex:(NSInteger)index
{
  switch (index) {
    case 0:
      return self.bookmarksButton;
      break;
    case 1:
      return self.warningsButton;
      break;
    case 2:
      return self.spellingButton;
      break;
    case 3:
      return self.labelsButton;
      break;
    default:
      return nil;
      break;
  }
}

- (NSInteger)tabIndexForButton:(id)sender
{
  if (sender == self.bookmarksButton) {
    return 0;
  } else if (sender == self.warningsButton) {
    return 1;
  } else if (sender == self.spellingButton) {
    return 2;
  } else if (sender == self.labelsButton) {
    return 3;
  } else {
    return 0;
  }
}

#pragma mark -
#pragma mark TabView Delegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  NSInteger idx = [self.tabView indexOfTabViewItem:tabViewItem];
  if (idx == [buttons indexOfObject:self.bookmarksButton]) {
    [self toggleOn:self.bookmarksButton];    
  } else if (idx == [buttons indexOfObject:self.spellingButton]) {
    [self toggleOn:self.spellingButton];    
  } else if (idx == [buttons indexOfObject:self.warningsButton]) {
    [self toggleOn:self.warningsButton];    
  } else if (idx == [buttons indexOfObject:self.labelsButton]) {
    [self toggleOn:self.labelsButton];    
  }
}


@end
