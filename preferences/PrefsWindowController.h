//
//  PrefsWindowController.h
//  Strongbox
//
//  Created by Martin Hewitson on 12/11/09.
//  Copyright 2009 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "SyntaxHighlightControlController.h"
#import "TeXTextView.h"
#import "TPSupportedFilesEditor.h"
#import "TPTemplateEditorView.h"
#import "TPProjectTemplateManager.h"

@class TPEnginesEditor;

@interface PrefsWindowController : DBPrefsWindowController <NSTableViewDelegate, NSTableViewDataSource> {

	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *syntaxColorsView;
	IBOutlet NSView *templatesView;
	IBOutlet NSView *engineView;
	IBOutlet NSView *userCommandsView;
	IBOutlet NSView *libraryPrefsView;
	IBOutlet NSView *fileTypesPrefsView;

  
  IBOutlet NSTableView *userCommandsTable;
  IBOutlet NSTableView *refCommandsTable;
  IBOutlet NSTableView *citeCommandsTable;
  IBOutlet NSTableView *beginCommandsTable;
  IBOutlet NSTableView *fileCommandsTable;
  
	IBOutlet NSArrayController *userCommandsController;
  	
	IBOutlet NSTextField *docFont;
	IBOutlet NSTextField *consoleFont;
	
	
	SyntaxHighlightControlController *commentsController;
	SyntaxHighlightControlController *commentsL2Controller;
	SyntaxHighlightControlController *commentsL3Controller;
	IBOutlet NSView *commentsView;
	IBOutlet NSView *commentsL2View;
	IBOutlet NSView *commentsL3View;
	
	SyntaxHighlightControlController *mathController;
	IBOutlet NSView *mathView;
	
	SyntaxHighlightControlController *commandsController;
	IBOutlet NSView *commandsView;
	
	SyntaxHighlightControlController *keywordsController;
	IBOutlet NSView *keywordsView;
	
	SyntaxHighlightControlController *argumentsController;
	IBOutlet NSView *argumentsView;
  	
	IBOutlet NSPopUpButton *wrapStylePopup;
	IBOutlet NSStepper *wrapWidthStepper;
	IBOutlet NSTextField *wrapWidthEdit;
	IBOutlet NSTextField *wrapAtWidthLabel;
	IBOutlet NSTextField *wrapCharsLabel;
  
  IBOutlet NSTextField *numSpacesEdit;
	IBOutlet NSStepper *numSpacesStepper;
  IBOutlet NSTextField *spacesLabel;
	
  TPEnginesEditor *enginesEditor;
  NSView *enginesEditorContainer;
  
  IBOutlet NSPopUpButton *enginePopup;
  
  IBOutlet NSPopUpButton *defaultEncodingPopup;
  
  TPSupportedFilesEditor *supportedFilesEditor;
  
  TPTemplateEditorView *templateEditorView;
  NSView *templateEditorViewContainer;
  
  TPProjectTemplateManager *projectTemplateManager;
  NSView *projectTemplateManagerContainer;
  
  IBOutlet NSTableView *syntaxErrorsTable;
  IBOutlet NSTextField *chktexBinaryPath;
  IBOutlet NSButton *chktexBinaryPathBrowse;
  IBOutlet NSButton *activateAllChecksButton;
  IBOutlet NSButton *deactivateAllChecksButton;
  IBOutlet NSButton *defaultChecksButton;
}

@property (retain) TPProjectTemplateManager *projectTemplateManager;
@property (assign) IBOutlet NSView *projectTemplateManagerContainer;
@property (retain) TPSupportedFilesEditor *supportedFilesEditor;
@property (retain) TPEnginesEditor *enginesEditor;
@property (assign) IBOutlet NSView *enginesEditorContainer;
@property (retain) TPTemplateEditorView *templateEditorView;
@property (assign) IBOutlet NSView *templateEditorViewContainer;

- (IBAction)defaultEncodingSelected:(id)sender;

#pragma mark -
#pragma mark Engine stuff

- (IBAction)selectEngineName:(id)sender;
- (NSString*)engineName;

#pragma mark -
#pragma mark Syntax check control

- (IBAction)syntaxCheckStateChanged:(id)sender;
- (IBAction)selectChkTeXPath:(id)sender;
- (IBAction)activateAllErrorChecks:(id)sender;
- (IBAction)deactivateAllErrorChecks:(id)sender;
- (IBAction)defaultErrorChecks:(id)sender;

#pragma mark -
#pragma mark Commands Control

- (IBAction) newCommand:(id)sender;

#pragma mark -
#pragma mark Control 


- (NSString*)formatNewCommand:(NSString*)userInput;
- (void)editSelectedInTableView:(NSTableView*)aTableView;

- (IBAction) insertSpacesForTabsChanged:(id)sender;

- (IBAction)selectDocFont:(id)sender;
- (IBAction)docFontChanged:(id)sender;

- (IBAction)selectConsoleFont:(id)sender;
- (void)consoleFontChanged:(id)sender;

- (IBAction) wrapStyleChanged:(id)sender;

- (IBAction)setDefaultLineHighlightingColor:(id)sender;
- (IBAction)setDefaultMatchingWordHighlightingColor:(id)sender;

- (IBAction) browseForGSExecutable:(id)sender;
- (IBAction) browseForPDFLatexExecutable:(id)sender;

#pragma mark -
#pragma mark Cite Command Control
- (IBAction)newCiteCommand:(id)sender;
- (IBAction)deleteSelectedCiteCommand:(id)sender;

#pragma mark -
#pragma mark Ref Command Control
- (IBAction)newRefCommand:(id)sender;
- (IBAction)deleteSelectedRefCommand:(id)sender;

#pragma mark -
#pragma mark File Command Control
- (IBAction)newFileCommand:(id)sender;
- (IBAction)deleteSelectedFileCommand:(id)sender;

#pragma mark -
#pragma mark Begin Command Control
- (IBAction)newBeginCommand:(id)sender;
- (IBAction)deleteSelectedBeginCommand:(id)sender;

@end
