//
//  TPTemplateEditor.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPTemplateEditorView.h"

@class TPTemplateEditor;

@protocol TemplateEditorDelegate <NSObject>

@optional
- (void)templateEditor:(TPTemplateEditor*)editor didSelectTemplate:(NSDictionary*)aTemplate;
- (void)templateEditorDidCancelSelection:(TPTemplateEditor*)editor;

@end

@interface TPTemplateEditor : NSWindowController {
@private
  NSString *_filename;
  NSView *templateEditorViewContainer;
  TPTemplateEditorView *templateEditorView;
  id<TemplateEditorDelegate> delegate;
  BOOL showFilename;
  
  NSButton *cancelButton;
  NSButton *selectButton;
  NSButton *setAsMainFileButton;
  NSTextField *filenameField;
  NSTextField *filenameLabel;
}

- (id) initWithDelegate:(id<TemplateEditorDelegate>)aDelegate activeFilename:(BOOL)withFilename;

@property (assign) id<TemplateEditorDelegate> delegate;
@property (assign) IBOutlet NSView *templateEditorViewContainer;
@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *selectButton;
@property (assign) IBOutlet NSButton *setAsMainFileButton;
@property (assign) IBOutlet NSTextField *filenameField;
@property (assign) IBOutlet NSTextField *filenameLabel;
@property (assign) BOOL showFilename;

@property (retain) TPTemplateEditorView *templateEditorView;

- (void)setFilename:(NSString*)aFilename;
- (BOOL) setAsMainFile;
- (NSString*)filename;

@end
