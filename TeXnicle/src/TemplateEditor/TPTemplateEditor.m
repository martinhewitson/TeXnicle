//
//  TPTemplateEditor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPTemplateEditor.h"

@implementation TPTemplateEditor

@synthesize templateEditorViewContainer;
@synthesize templateEditorView;
@synthesize cancelButton;
@synthesize selectButton;
@synthesize setAsMainFileButton;
@synthesize filenameField;
@synthesize filenameLabel;
@synthesize delegate;
@synthesize showFilename;

- (id) initWithDelegate:(id<TemplateEditorDelegate>)aDelegate activeFilename:(BOOL)withFilename
{
  self = [super initWithWindowNibName:@"TemplateEditor"];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    self.showFilename = withFilename;
  }
  
  return self;
}

- (void) dealloc
{
  self.templateEditorView = nil;
  [super dealloc];
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // create a template editor view
  self.templateEditorView = [[[TPTemplateEditorView alloc] init] autorelease];
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
}

- (BOOL) setAsMainFile
{
  return [self.setAsMainFileButton state];
}

- (void)setFilename:(NSString*)aFilename
{
  _filename = aFilename;
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
