//
//  MHSlideViewController.m
//  SlidePanel
//
//  Created by Martin Hewitson on 31/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHSlideViewController.h"

@implementation MHSlideViewController

@synthesize contentView;
@synthesize sidePanel;
@synthesize mainPanel;
@synthesize rightSided;

- (void) awakeFromNib
{
  _sidePanelisVisible = YES;
  self.rightSided = YES;
}

- (IBAction)togglePanel:(id)sender
{
  if (!_sidePanelisVisible) {
    // slide in 
    [self slideInAnimate:YES];
  } else {
    // slide out
    [self slideOutAnimate:YES];
  }
}

- (void) slideInAnimate:(BOOL)animate
{
  if (_sidePanelisVisible)
    return;
  
  NSRect sr = [sidePanel frame];
  NSRect mr = [mainPanel frame];
  NSRect fr = [contentView frame];
  NSRect nsr;
  NSRect nmr;
  CGFloat w = sr.size.width;
  // slide in 
  if (self.rightSided) {
    nsr = NSMakeRect(fr.size.width-w, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(0, mr.origin.y, fr.size.width-w, mr.size.height);
  } else {
    nsr = NSMakeRect(0, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(w, mr.origin.y, fr.size.width-w, mr.size.height);
  }
  if (animate) {
    [[sidePanel animator] setFrame:nsr];
    [[mainPanel animator] setFrame:nmr];
  } else {
    [sidePanel setFrame:nsr];
    [mainPanel setFrame:nmr];
  }
  _sidePanelisVisible = YES;
}

- (void) slideOutAnimate:(BOOL)animate
{
  if (!_sidePanelisVisible)
    return;
  
  NSRect sr = [sidePanel frame];
  NSRect mr = [mainPanel frame];
  NSRect fr = [contentView frame];
  NSRect nsr;
  NSRect nmr;
  CGFloat w = sr.size.width;
  // slide out
  if (self.rightSided) {
    nsr = NSMakeRect(fr.size.width+1, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(0, mr.origin.y, fr.size.width, mr.size.height);
  } else {
    nsr = NSMakeRect(-w, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(0, mr.origin.y, fr.size.width, mr.size.height);
  }
  if (animate) {
    [[sidePanel animator] setFrame:nsr];
    [[mainPanel animator] setFrame:nmr];
  } else {
    [sidePanel setFrame:nsr];
    [mainPanel setFrame:nmr];
  }
  _sidePanelisVisible = NO;
}

@end
