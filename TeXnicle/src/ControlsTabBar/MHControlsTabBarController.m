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
  
  buttons = [[NSArray arrayWithObjects:self.projectButton, self.palletButton, self.libraryButton, self.outlineButton, self.findButton, nil] retain];
  
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
  NSInteger idx = [buttons indexOfObject:sender];
  [self.tabView selectTabViewItemAtIndex:idx];
  [self toggleOn:sender];  
  
  [[NSNotificationCenter defaultCenter] postNotificationName:TPControlsTabSelectionDidChangeNotification
                                                      object:self
                                                    userInfo:nil];
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

#pragma mark -
#pragma mark TabView Delegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  NSInteger idx = [self.tabView indexOfTabViewItem:tabViewItem];
  if (idx == 0) {
    [self toggleOn:self.projectButton];
  } else if (idx == 1) {
    [self toggleOn:self.palletButton];
  } else if (idx == 2) {
    [self toggleOn:self.libraryButton];
  } else if (idx == 3) {
    [self toggleOn:self.outlineButton];
  } else if (idx == 4) {
    [self toggleOn:self.findButton];    
  }
}

@end
