//
//  TPImageViewerController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPImageViewerController.h"

@implementation TPImageViewerController

@synthesize imageViewer;
@synthesize contentView;
@synthesize backgroundView;
@synthesize toolbarView;
@synthesize path;

- (id) init
{
  self = [self initWithNibName:@"TPImageViewerController" bundle:nil];
  if (self) {    
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) awakeFromNib
{
  [self disable];
}

- (void) enable 
{
  [self.view setHidden:NO];
}

- (void) disable
{
  [self.view setHidden:YES];
}

- (void) setImage:(NSImage*)anImage atPath:(NSString*)aPath
{  
  self.path = aPath;
  [self.imageViewer setImage:anImage];
}

- (IBAction)openItem:(id)sender
{
  [[NSWorkspace sharedWorkspace] openFile:self.path];				
}

@end
