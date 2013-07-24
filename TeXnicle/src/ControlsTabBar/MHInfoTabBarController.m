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

@interface MHInfoTabBarController()

@property (assign) BOOL standalone;

@end

@implementation MHInfoTabBarController

- (void) dealloc
{
//  NSLog(@"Dealloc %@", self);
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  [self.view removeFromSuperview];
  [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
  [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
  self.splitview = nil;
  self.tabView.delegate = nil;
  self.tabView = nil;
  self.bookmarksButton = nil;
  self.warningsButton = nil;
  self.spellingButton = nil;
  self.labelsButton = nil;
  self.citationsButton = nil;
  self.commandsButton = nil;
}

- (id) init
{
  self = [self initWithMode:NO];
  if (self) {
    
  }
  return self;
}

- (id) initWithMode:(BOOL)standAlone
{
  NSString *nibName = nil;
  if (standAlone) {
    nibName = @"MHStandaloneInfoTabBarViewController";
  } else {
    nibName = @"MHInfoTabBarController";
  }
  
  self = [super initWithNibName:nibName bundle:nil];
  if (self) {
    self.standalone = standAlone;
  }
  return self;
}


- (void) awakeFromNib
{
  [self.tabView selectTabViewItemAtIndex:0];
  [self.spellingButton setState:NSOffState];
  [self.bookmarksButton setState:NSOffState];
  [self.warningsButton setState:NSOffState];
  [self.labelsButton setState:NSOffState];
  [self.citationsButton setState:NSOffState];
  [self.commandsButton setState:NSOffState];
  
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
  if (self.citationsButton != nil) {
    [nonNilButtons addObject:self.citationsButton];
  }
  if (self.commandsButton != nil) {
    [nonNilButtons addObject:self.commandsButton];
  }
  
  buttons = [NSArray arrayWithArray:nonNilButtons];
  
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
    case 4:
      return self.citationsButton;
      break;
    case 5:
      return self.commandsButton;
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
  } else if (sender == self.citationsButton) {
    return 4;
  } else if (sender == self.commandsButton) {
    return 5;
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
  } else if (idx == [buttons indexOfObject:self.citationsButton]) {
    [self toggleOn:self.citationsButton];    
  } else if (idx == [buttons indexOfObject:self.commandsButton]) {
    [self toggleOn:self.commandsButton];    
  }
}


@end
