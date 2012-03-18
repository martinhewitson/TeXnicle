//
//  TPPasteTableConfigureWindowController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPPasteTableConfigureWindowController.h"

@interface TPPasteTableConfigureWindowController ()

@end

@implementation TPPasteTableConfigureWindowController

@synthesize customSeparatorField;
@synthesize separatorMatrix;

- (id)init
{
  self = [super initWithWindowNibName:@"TPPasteTableConfigureWindowController"];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  [self.separatorMatrix selectCellWithTag:1];
  [self.customSeparatorField setEnabled:NO];
}

- (IBAction)selectNewSeparator:(id)sender
{
  NSMatrix *radio = (NSMatrix*)sender;
  
  NSString *selected = [[radio selectedCell] title];
  
  if ([selected isEqualToString:@"comma"]) {
    [self.customSeparatorField setEnabled:NO];
  } else if ([selected isEqualToString:@"tab"]) {
    [self.customSeparatorField setEnabled:NO];
    
  } else if ([selected isEqualToString:@"whitespace"]) {
    [self.customSeparatorField setEnabled:NO];
  } else if ([selected isEqualToString:@"custom"]) {
    [self.customSeparatorField setEnabled:YES];
    
  } else {
    
  }
  
  
}

- (NSString*)separator
{
  NSString *selected = [[self.separatorMatrix selectedCell] title];
  
  if ([selected isEqualToString:@"comma"]) {
    return @",";
  } else if ([selected isEqualToString:@"tab"]) {
    return [NSString stringWithString:@"\t"];
  } else if ([selected isEqualToString:@"whitespace"]) {
    return @" ";
  } else if ([selected isEqualToString:@"custom"]) {
    return [self.customSeparatorField stringValue];
  } else {
    return @"";
  }
}

- (IBAction)cancel:(id)sender
{
  [self.window orderOut:self];
  [NSApp endSheet:self.window returnCode:NSCancelButton];
}

- (IBAction)done:(id)sender
{
  [self.window orderOut:self];
  [NSApp endSheet:self.window returnCode:NSOKButton];
}

@end
