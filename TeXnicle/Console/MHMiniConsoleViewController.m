//
//  MHMiniConsoleViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHMiniConsoleViewController.h"

@implementation MHMiniConsoleViewController

@synthesize textField;
@synthesize progressIndicator;

- (id)init
{
  self = [super initWithNibName:@"MHMiniConsoleViewController" bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) clear
{
  [self.textField setStringValue:@""];
  [self.textField setNeedsDisplay];
  [self.textField setToolTip:@""];
}

- (void) appendText:(NSString*)someText
{
  // do nothing
}

- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor
{
  // do nothing
}

- (void) error:(NSString*)someText
{
  [self.textField setTextColor:[NSColor redColor]];
  [self.textField setStringValue:someText];
  [self.textField setNeedsDisplay];
  [self.textField setToolTip:someText];
}

- (void)message:(NSString *)someText
{
  [self.textField setTextColor:[NSColor darkGrayColor]];
  [self.textField setStringValue:someText];
  [self.textField setNeedsDisplay];
  [self.textField setToolTip:someText];
}

- (void) setAnimating:(BOOL)state
{
  if (state) {
    [self.progressIndicator startAnimation:self];
  } else {
    [self.progressIndicator stopAnimation:self];
  }
}

@end
