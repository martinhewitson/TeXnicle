//
//  MHControlsTabBarController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHControlsTabBarController.h"

NSString * const TPControlsTabSelectionDidChangeNotification = @"TPControlsTabSelectionDidChangeNotification";

@implementation MHControlsTabBarController


@synthesize projectButton;
@synthesize palletButton;
@synthesize libraryButton;
@synthesize outlineButton;
@synthesize findButton;
@synthesize tabView;
@synthesize bookmarksButton;
@synthesize prefsButton;

- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) awakeFromNib
{
  [self.tabView selectTabViewItemAtIndex:0];
  [self.projectButton setState:NSOnState];
  [self.palletButton setState:NSOffState];
  [self.libraryButton setState:NSOffState];
  [self.outlineButton setState:NSOffState];
  [self.findButton setState:NSOffState];
  [self.bookmarksButton setState:NSOffState];
  [self.prefsButton setState:NSOffState];
  
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
  if (self.bookmarksButton != nil) {
    [nonNilButtons addObject:self.bookmarksButton];
  }
  if (self.prefsButton != nil) {
    [nonNilButtons addObject:self.prefsButton];
  }
  
  buttons = [[NSArray arrayWithArray:nonNilButtons] retain];
  
}

- (void) selectTabAtIndex:(NSInteger)index
{
  [self.tabView selectTabViewItemAtIndex:index];
  [self toggleOn:[self buttonForTabIndex:index]];
  [[NSNotificationCenter defaultCenter] postNotificationName:TPControlsTabSelectionDidChangeNotification
                                                      object:self
                                                    userInfo:nil];
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
      return self.bookmarksButton;
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
  } else if (sender == self.bookmarksButton) {
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
  } else if (idx == [buttons indexOfObject:self.bookmarksButton]) {
    [self toggleOn:self.bookmarksButton];    
  } else if (idx == [buttons indexOfObject:self.prefsButton]) {
    [self toggleOn:self.prefsButton];    
  }
}

@end
