//
//  PrefsWindowController.h
//  Strongbox
//
//  Created by Martin Hewitson on 12/11/09.
//  Copyright 2009 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "SyntaxHighlightControlController.h"
#import "TeXTextView.h"

@interface PrefsWindowController : DBPrefsWindowController {

	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *syntaxColorsView;
	IBOutlet NSView *templatesView;
	IBOutlet NSView *engineView;

	IBOutlet NSArrayController *templatesController;
	IBOutlet NSTableView *templatesTable;
	IBOutlet TeXTextView *templateEditor;
	
	IBOutlet NSTextField *docFont;
	
	
	SyntaxHighlightControlController *commentsController;
	IBOutlet NSView *commentsView;
	
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
	
}



#pragma mark -
#pragma mark Control 

- (void) templateSelectionChanged:(NSNotification*)aNote;
- (IBAction) newTemplate:(id)sender;

- (IBAction) insertSpacesForTabsChanged:(id)sender;

- (IBAction)selectDocFont:(id)sender;
- (IBAction)docFontChanged:(id)sender;

- (IBAction) wrapStyleChanged:(id)sender;

- (IBAction) browseForGSExecutable:(id)sender;
- (void)locateGSDidEnd:(NSSavePanel*)savePanel 
						returnCode:(NSInteger)returnCode
					 contextInfo:(void*)context;

- (IBAction) browseForPDFLatexExecutable:(id)sender;
- (void)locatePDFLatexDidEnd:(NSSavePanel*)savePanel 
									returnCode:(NSInteger)returnCode
								 contextInfo:(void*)context;

- (IBAction) browseForLatexExecutable:(id)sender;
- (void)locateLatexDidEnd:(NSSavePanel*)savePanel 
							 returnCode:(NSInteger)returnCode
							contextInfo:(void*)context;

- (IBAction) browseForDvipsExecutable:(id)sender;
- (void)locateDvipsDidEnd:(NSSavePanel*)savePanel 
							 returnCode:(NSInteger)returnCode
							contextInfo:(void*)context;

- (IBAction) browseForBibTeXExecutable:(id)sender;
- (void)locateBibTeXDidEnd:(NSSavePanel*)savePanel 
								returnCode:(NSInteger)returnCode
							 contextInfo:(void*)context;

@end
