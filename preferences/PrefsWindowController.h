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

@class TPEnginesEditor;

@interface PrefsWindowController : DBPrefsWindowController <NSTableViewDelegate, NSTableViewDataSource> {

	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *syntaxColorsView;
	IBOutlet NSView *templatesView;
	IBOutlet NSView *engineView;
	IBOutlet NSView *userCommandsView;
	IBOutlet NSView *libraryPrefsView;

  
  IBOutlet NSTableView *userCommandsTable;
	IBOutlet NSArrayController *userCommandsController;
  
	IBOutlet NSArrayController *templatesController;
	IBOutlet NSTableView *templatesTable;
	IBOutlet TeXTextView *templateEditor;
	
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
}

@property (retain) TPEnginesEditor *enginesEditor;
@property (assign) IBOutlet NSView *enginesEditorContainer;

#pragma mark -
#pragma mark Engine stuff

- (IBAction)selectEngineName:(id)sender;
- (NSString*)engineName;

#pragma mark -
#pragma mark Commands Control

- (IBAction) newCommand:(id)sender;

#pragma mark -
#pragma mark Control 


- (void) templateSelectionChanged:(NSNotification*)aNote;
- (IBAction) newTemplate:(id)sender;

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

@end
