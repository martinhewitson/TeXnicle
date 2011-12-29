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

- (void) awakeFromNib
{
  _sidePanelisVisible = YES;
}

- (IBAction)togglePanel:(id)sender
{
//  NSButton *item = (NSButton*)sender;
  NSRect fr = [contentView frame];
  NSRect sr = [sidePanel frame];
//  NSLog(@"Content rect %@", NSStringFromRect(fr));
//  NSLog(@"Slide rect %@", NSStringFromRect(sr));
  if (sr.origin.x > fr.size.width) {
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
//  NSLog(@"Width = %f", w);
  // slide in 
  nsr = NSMakeRect(fr.size.width-w, sr.origin.y, sr.size.width, sr.size.height);
//  NSLog(@"Slide in to %@", NSStringFromRect(nsr));
  nmr = NSMakeRect(0, mr.origin.y, fr.size.width-w, mr.size.height);
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
  nsr = NSMakeRect(fr.size.width+1, sr.origin.y, sr.size.width, sr.size.height);
//  NSLog(@"Slide out to %@", NSStringFromRect(nsr));
  nmr = NSMakeRect(0, mr.origin.y, fr.size.width, mr.size.height);
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
