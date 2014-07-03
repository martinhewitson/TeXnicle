//
//  TPCodeClippingEditorViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 03/07/14.
//  Copyright (c) 2014 bobsoft. All rights reserved.
//

#import "TPCodeClippingEditorViewController.h"
#import "TeXTextView.h"

@interface TPCodeClippingEditorViewController ()

@property (weak) NSPopover *popover;
@property (unsafe_unretained) IBOutlet TeXTextView *textView;

@end

@implementation TPCodeClippingEditorViewController

- (id)initWithPopover:(NSPopover*)aPopover
{
  self = [super initWithNibName:@"TPCodeClippingEditorViewController" bundle:nil];
  if (self) {
    self.popover = aPopover;
  }
  return self;
}

- (void) prepareForEditing
{
  NSString *code = self.clip.code;
  [[self.textView textStorage] beginEditing];
  [[self.textView textStorage] setAttributedString:[[NSAttributedString alloc] initWithString:code]];
  [[self.textView textStorage] endEditing];
  [self.textView applyFontAndColor:YES];
}


- (void) setClip:(TPLibraryEntry *)clip
{
  _clip = clip;
  [self prepareForEditing];
}

- (IBAction)doneClicked:(id)sender
{
  self.clip.code = [self.textView string];
  self.clip.imageIsValid = @NO;
  [self.clip.managedObjectContext save:nil];
  if (self.popover) {
    [self.popover close];
  }
}


- (IBAction)cancelClicked:(id)sender
{
  if (self.popover) {
    [self.popover close];
  }  
}


@end
