//
//  MHControlsTabBarController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import "MHControlsTabBarController.h"
#import "MHToolbarBackgroundView.h"

NSString * const TPControlsTabSelectionDidChangeNotification = @"TPControlsTabSelectionDidChangeNotification";

@interface MHControlsTabBarController ()

@property (strong) IBOutlet MHToolbarBackgroundView *viewBackground;

@end

@implementation MHControlsTabBarController

- (void) dealloc
{
//  NSLog(@"Dealloc %@", self);
}

- (void) tearDown
{
//  NSLog(@"Tear down %@", self);
  buttons = nil;
  self.viewBackground = nil;
  self.splitview = nil;
  self.tabView.delegate = nil;
  self.tabView = nil;
  self.projectButton = nil;
  self.palletButton = nil;
  self.libraryButton = nil;
  self.outlineButton = nil;
  self.findButton = nil;
  self.infoButton = nil;
  self.prefsButton = nil;
}

- (id)init
{
  self = [self initWithMode:NO];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (id)initWithMode:(BOOL)standAlone
{
  NSString *nibName = nil;
  if (standAlone) {
    nibName = @"MHStandaloneControlsTabBarViewController";
  } else {
    nibName = @"MHControlsTabBarController";
  }
  
  self = [super initWithNibName:nibName bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) awakeFromNib
{
  [self.projectButton setState:NSOnState];
  [self.findButton setState:NSOffState];
  
  [self.tabView selectTabViewItemAtIndex:0];
  [self.palletButton setState:NSOffState];
  [self.libraryButton setState:NSOffState];
  [self.outlineButton setState:NSOffState];
  [self.infoButton setState:NSOffState];
  [self.prefsButton setState:NSOffState];
  
  self.viewBackground.strokeRightSide = YES;
  
  
  NSMutableArray *nonNilButtons = [NSMutableArray array];
  if (self.projectButton != nil) {
    [nonNilButtons addObject:self.projectButton];
  }
  if (self.palletButton != nil) {
    [nonNilButtons addObject:self.palletButton];
  }
  if (self.libraryButton != nil) {
    [nonNilButtons addObject:self.libraryButton];
  }
  if (self.outlineButton != nil) {
    [nonNilButtons addObject:self.outlineButton];
  }
  if (self.findButton != nil) {
    [nonNilButtons addObject:self.findButton];
  }
  if (self.infoButton != nil) {
    [nonNilButtons addObject:self.infoButton];
  }
  if (self.prefsButton != nil) {
    [nonNilButtons addObject:self.prefsButton];
  }
  
  buttons = [NSArray arrayWithArray:nonNilButtons];
  
}

- (void) selectTabAtIndex:(NSInteger)index
{
  if (index >= 0 && index < [self.tabView numberOfTabViewItems]) {
    [self.tabView selectTabViewItemAtIndex:index];
    [self toggleOn:[self buttonForTabIndex:index]];
    [[NSNotificationCenter defaultCenter] postNotificationName:TPControlsTabSelectionDidChangeNotification
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
      return self.projectButton;
      break;
    case 1:
      return self.palletButton;
      break;
    case 2:
      return self.libraryButton;
      break;
    case 3:
      return self.outlineButton;
      break;
    case 4:
      return self.findButton;
      break;
    case 5:
      return self.infoButton;
      break;
    case 6:
      return self.prefsButton;
      break;
    default:
      return nil;
      break;
  }
}

- (NSInteger)tabIndexForButton:(id)sender
{
  if (sender == self.projectButton) {
    return 0;
  } else if (sender == self.palletButton) {
    return 1;
  } else if (sender == self.libraryButton) {
    return 2;
  } else if (sender == self.outlineButton) {
    return 3;
  } else if (sender == self.findButton) {
    return 4;
  } else if (sender == self.infoButton) {
    return 5;
  } else if (sender == self.prefsButton) {
    return 6;
  } else {
    return 0;
  }
}

#pragma mark -
#pragma mark TabView Delegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  NSInteger idx = [self.tabView indexOfTabViewItem:tabViewItem];
  if (idx == [buttons indexOfObject:self.projectButton]) {
    [self toggleOn:self.projectButton];
  } else if (idx == [buttons indexOfObject:self.palletButton]) {
    [self toggleOn:self.palletButton];
  } else if (idx == [buttons indexOfObject:self.libraryButton]) {
    [self toggleOn:self.libraryButton];
  } else if (idx == [buttons indexOfObject:self.outlineButton]) {
    [self toggleOn:self.outlineButton];
  } else if (idx == [buttons indexOfObject:self.findButton]) {
    [self toggleOn:self.findButton];    
  } else if (idx == [buttons indexOfObject:self.infoButton]) {
    [self toggleOn:self.infoButton];    
  } else if (idx == [buttons indexOfObject:self.prefsButton]) {
    [self toggleOn:self.prefsButton];    
  }
}

#pragma mark -
#pragma mark Control

- (IBAction) showProjectTree:(id)sender
{
  [self showNavigator:self];
  [self showProjectTree];
}

- (void) showProjectTree 
{
  [self selectTabAtIndex:[self tabIndexForButton:self.projectButton]];
}

- (IBAction) showSymbolPalette:(id)sender
{
  [self showNavigator:self];
  [self showSymbolPalette];
}

- (void) showSymbolPalette
{
  [self selectTabAtIndex:[self tabIndexForButton:self.palletButton]];
}

- (IBAction) showClippingsLibrary:(id)sender
{
  [self showNavigator:self];
  [self showClippingsLibrary];
}

- (void) showClippingsLibrary
{
  [self selectTabAtIndex:[self tabIndexForButton:self.libraryButton]];
}

- (IBAction) showDocumentOutline:(id)sender
{
  [self showNavigator:self];
  [self showDocumentOutline];
}

- (void) showDocumentOutline
{
  [self selectTabAtIndex:[self tabIndexForButton:self.outlineButton]];
}

- (IBAction) showProjectSearch:(id)sender
{
  [self showNavigator:self];
  [self showProjectSearch];
}

- (void) showProjectSearch
{
  [self selectTabAtIndex:[self tabIndexForButton:self.findButton]];
}

- (IBAction) showFileInfo:(id)sender
{
  [self showNavigator:self];
  [self showFileInfo];
}

- (void) showFileInfo
{
  [self selectTabAtIndex:[self tabIndexForButton:self.infoButton]];
}

- (IBAction) showProjectSettings:(id)sender
{
  [self showNavigator:self];
  [self showProjectSettings];
}

- (void) showProjectSettings
{
  [self selectTabAtIndex:[self tabIndexForButton:self.prefsButton]];
}

- (IBAction) hideNavigator:(id)sender
{
  NSView *leftView = [self.splitview subviews][0];
  NSView *midView = [self.splitview subviews][1];
  
  NSRect leftFrame = leftView.frame;
  NSRect midFrame = midView.frame;
  
  midFrame.size.width += leftFrame.size.width;
  leftFrame.size.width = 0.0f;
  midFrame.origin.x = 0;
  
  NSMutableDictionary *collapseMainAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
  collapseMainAnimationDict[NSViewAnimationTargetKey] = midView;
  collapseMainAnimationDict[NSViewAnimationEndFrameKey] = [NSValue valueWithRect:midFrame];
  
  NSMutableDictionary *collapseInspectorAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
  collapseInspectorAnimationDict[NSViewAnimationTargetKey] = leftView;
  collapseInspectorAnimationDict[NSViewAnimationEndFrameKey] = [NSValue valueWithRect:leftFrame];
  
  NSViewAnimation *collapseAnimation = [[NSViewAnimation alloc] initWithViewAnimations:@[collapseMainAnimationDict, collapseInspectorAnimationDict]];
  [collapseAnimation setDuration:0.25f];
  [collapseAnimation startAnimation];
  
}

- (IBAction) showNavigator:(id)sender
{
  NSView *leftView = [self.splitview subviews][0];
  NSView *midView = [self.splitview subviews][1];
  
//  NSLog(@"Left view is hidden? %d", [leftView isHidden]);
//  NSLog(@"Left view size %@", NSStringFromRect([leftView frame]));
  
  CGFloat size = [buttons count]*31.0;
  if (size < 220.0)
    size = 220.0;
  
  NSRect leftfr = [leftView frame];
  if ([leftView isHidden] == NO) {
    return;
  }
  
  leftfr.size.width = size;
  NSRect midfr = [midView frame];
  midfr.size.width = midfr.size.width - size;
  midfr.origin.x = size;
  
  [leftView.animator setFrame:leftfr];
  [midView.animator setFrame:midfr];
  [leftView setHidden:NO];
  
//  NSMutableDictionary *collapseMainAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
//  collapseMainAnimationDict[NSViewAnimationTargetKey] = midView;
//  collapseMainAnimationDict[NSViewAnimationEndFrameKey] = [NSValue valueWithRect:midfr];
//  
//  NSMutableDictionary *collapseInspectorAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
//  collapseInspectorAnimationDict[NSViewAnimationTargetKey] = leftView;
//  collapseInspectorAnimationDict[NSViewAnimationEndFrameKey] = [NSValue valueWithRect:leftfr];
//  
//  NSViewAnimation *collapseAnimation = [[NSViewAnimation alloc] initWithViewAnimations:@[collapseMainAnimationDict, collapseInspectorAnimationDict]];
//  [collapseAnimation setDuration:0.25f];
//  [collapseAnimation startAnimation];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
  // 2110 -> 2180
  
  NSInteger tag = [menuItem tag];
  
  if (tag == 2110) {
    // show project tree
    if (self.projectButton) {
      return YES;
    }
  }

  if (tag == 2120) {
    // show palette
    if (self.palletButton) {
      return YES;
    }
  }

  if (tag == 2130) {
    // show library 
    if (self.libraryButton) {
      return YES;
    }
  }
  
  if (tag == 2140) {
    // show document outline 
    if (self.outlineButton) {
      return YES;
    }
  }
  
  if (tag == 2150) {
    // show project search 
    if (self.findButton) {
      return YES;
    }
  }
  
  if (tag == 2160) {
    // show bookmarks 
    if (self.infoButton) {
      return YES;
    }
  }
    
  if (tag == 2170) {
    // show settings 
    if (self.prefsButton) {
      return YES;
    }
  }
  
  if (tag == 2180) {
    // show navigator 
    NSView *leftView = [self.splitview subviews][0];
    if ([leftView isHidden] == YES) {
      return YES;
    }
  }
  
  if (tag == 2190) {
    // show navigator
    NSView *leftView = [self.splitview subviews][0];
    if ([leftView isHidden] == NO) {
      return YES;
    }
  }
  
  return NO;
}

@end
