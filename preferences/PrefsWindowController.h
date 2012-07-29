//
//  PrefsWindowController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/11/09.
//  Copyright 2009 bobsoft. All rights reserved.
//
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

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "SyntaxHighlightControlController.h"
#import "TeXTextView.h"
#import "TPSupportedFilesEditor.h"
#import "TPTemplateEditorView.h"
#import "TPProjectTemplateManager.h"

@class TPEnginesEditor;

@interface PrefsWindowController : DBPrefsWindowController <NSTableViewDelegate, NSTableViewDataSource> {
@private
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

	SyntaxHighlightControlController *markupL1Controller;
	SyntaxHighlightControlController *markupL2Controller;
	SyntaxHighlightControlController *markupL3Controller;
	IBOutlet NSView *markupL1View;
	IBOutlet NSView *markupL2View;
	IBOutlet NSView *markupL3View;
	
	SyntaxHighlightControlController *mathController;
	IBOutlet NSView *mathView;
	
	SyntaxHighlightControlController *commandsController;
	IBOutlet NSView *commandsView;
	
	SyntaxHighlightControlController *keywordsController;
	IBOutlet NSView *keywordsView;
	
	SyntaxHighlightControlController *argumentsController;
	IBOutlet NSView *argumentsView;

	SyntaxHighlightControlController *dollarController;
	IBOutlet NSView *dollarView;  
  
	IBOutlet NSPopUpButton *wrapStylePopup;
	IBOutlet NSStepper *wrapWidthStepper;
	IBOutlet NSTextField *wrapWidthEdit;
	IBOutlet NSTextField *wrapAtWidthLabel;
	IBOutlet NSTextField *wrapCharsLabel;
  
  IBOutlet NSTextField *numSpacesEdit;
	IBOutlet NSStepper *numSpacesStepper;
  IBOutlet NSTextField *spacesLabel;
	
  IBOutlet NSPopUpButton *enginePopup;
  
  IBOutlet NSPopUpButton *defaultEncodingPopup;
  
  IBOutlet NSTableView *syntaxErrorsTable;
  IBOutlet NSTextField *chktexBinaryPath;
  IBOutlet NSButton *chktexBinaryPathBrowse;
  IBOutlet NSButton *activateAllChecksButton;
  IBOutlet NSButton *deactivateAllChecksButton;
  IBOutlet NSButton *defaultChecksButton;
}


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
- (IBAction)setDefaultSelectedTextColor:(id)sender;
- (IBAction)setDefaultSelectedTextBackgroundColor:(id)sender;

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
