//
//  TPTemplateEditor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/12.
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

#import "TPTemplateEditor.h"

@interface TPTemplateEditor ()

@property (unsafe_unretained) IBOutlet NSView *templateEditorViewContainer;
@property (unsafe_unretained) IBOutlet NSButton *cancelButton;
@property (unsafe_unretained) IBOutlet NSButton *selectButton;
@property (unsafe_unretained) IBOutlet NSButton *setAsMainFileButton;
@property (unsafe_unretained) IBOutlet NSTextField *filenameField;
@property (unsafe_unretained) IBOutlet NSTextField *filenameLabel;

@property (assign) BOOL editMode;

@end

@implementation TPTemplateEditor

- (id) initWithDelegate:(id<TemplateEditorDelegate>)aDelegate activeFilename:(BOOL)withFilename editMode:(BOOL)editable
{
  self = [super initWithWindowNibName:@"TemplateEditor"];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    self.showFilename = withFilename;
    self.editMode = editable;
  }
  return self;
}

- (id) initWithDelegate:(id<TemplateEditorDelegate>)aDelegate activeFilename:(BOOL)withFilename
{
  return [self initWithDelegate:aDelegate activeFilename:withFilename editMode:YES];
}

- (void) tearDown
{
  NSLog(@"Tear down %@", self);
  self.delegate = nil;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // create a template editor view
  self.templateEditorView = [[TPTemplateEditorView alloc] init];
  [self.templateEditorView.view setFrame:[self.templateEditorViewContainer bounds]];
  [self.templateEditorViewContainer addSubview:self.templateEditorView.view];

  // Enable UI elements
  [self.setAsMainFileButton setEnabled:self.showFilename];
  [self.filenameField setEnabled:self.showFilename];
  if (self.showFilename) {
    [self.filenameLabel setTextColor:[NSColor controlTextColor]];
  } else {
    [self.filenameLabel setTextColor:[NSColor disabledControlTextColor]];
  }
  
  if (self.showFilename) {
    // Set filename
    if (_filename) {
      [self.filenameField setStringValue:_filename];
    }
  } else {
    [self.filenameField setStringValue:@""];
  }
  
  [self.templateEditorView.addTemplateButton setHidden:!self.editMode];
  [self.templateEditorView.removeTemplateButton setHidden:!self.editMode];
  [self.templateEditorView.templateCodeView setEditable:self.editMode];
  self.templateEditorView.editable = self.editMode;
}

- (BOOL) setAsMainFile
{
  return [self.setAsMainFileButton state];
}

- (void)setFilename:(NSString*)aFilename
{
  _filename = aFilename;
  [self.filenameField setStringValue:_filename];
}

- (NSString*)filename
{
  return [self.filenameField stringValue];
}

- (IBAction)selectAction:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(templateEditor:didSelectTemplate:)]) {   
    [self.delegate templateEditor:self didSelectTemplate:[self.templateEditorView selectedTemplate]];
  }
}

- (IBAction)cancelAction:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(templateEditorDidCancelSelection:)]) {
    [self.delegate templateEditorDidCancelSelection:self];
  }
}

@end
