//
//  MHTableConfigureController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "MHTableConfigureController.h"

@implementation MHTableConfigureController

@synthesize delegate;
@synthesize numColsField;
@synthesize numRowsField;
@synthesize numberOfRows;
@synthesize numberOfColumns;

- (id)initWithDelegate:(id<MHTableConfigureDelegate>)aDelegate
{
  self = [super initWithWindowNibName:@"MHTableConfigureWindow"];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)cancelClicked:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(tableConfigureDidCancelConfiguration)]) {
    [self.delegate tableConfigureDidCancelConfiguration];
  }
}

- (IBAction)okClicked:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(tableConfigureDidAcceptConfiguration)]) {
    [self.delegate tableConfigureDidAcceptConfiguration];
  }
}

@end
