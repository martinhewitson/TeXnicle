//
//  TPPasteTableConfigureWindowController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPPasteTableConfigureWindowController.h"

@interface TPPasteTableConfigureWindowController ()

@property (unsafe_unretained) IBOutlet NSTextField *customSeparatorField;
@property (unsafe_unretained) IBOutlet NSMatrix *separatorMatrix;

@end

@implementation TPPasteTableConfigureWindowController

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
