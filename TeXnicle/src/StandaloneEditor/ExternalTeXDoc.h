//
//  ExternalTeXDoc.h
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPFileMonitor.h"
#import "TeXTextView.h"
#import "TPEngineManager.h"
#import "TPEngineSettingsController.h"
#import "MHMiniConsoleViewController.h"
#import "PDFViewerController.h"
#import "MHSlideViewController.h"
#import "TPStatusViewController.h"
#import "MHControlsTabBarController.h"
#import "LibraryController.h"
#import "PaletteController.h"
#import "ProjectOutlineController.h"

@class TeXEditorViewController;

@interface ExternalTeXDoc : NSDocument <ProjectOutlineControllerDelegate, PaletteControllerDelegate, LibraryControllerDelegate, PDFViewerControllerDelegate, NSApplicationDelegate, TPFileMonitorDelegate, TeXTextViewDelegate, TPEngineManagerDelegate, TPEngineSettingsDelegate> {

  IBOutlet NSView *leftView;
  IBOutlet NSView *rightView;
  
	NSMutableAttributedString *documentData;

	IBOutlet NSWindow *addToProjectSheet;
	IBOutlet NSWindow *addToEmptyProjectSheet;
	
	// Add to project
	IBOutlet NSArrayController *projectsController;
	
	IBOutlet NSButton *copyToProjectCheckButton;
	IBOutlet NSToolbarItem *addToProjectButton;
	
	// Add to new project
	IBOutlet NSButton *copyToNewProjectCheckButton;
	IBOutlet NSButton *makeMainFileCheckButton;
		
  TeXEditorViewController *texEditorViewController;
  NSView *texEditorContainer;
  
  BOOL openPDFAfterBuild;
  
  NSDate *fileLoadDate;
  TPFileMonitor *fileMonitor;
  
  TPEngineManager *engineManager;
  
  NSMutableDictionary *settings;
  
  MHMiniConsoleViewController *miniConsole;
  
  NSWindow *mainWindow;
  
  NSView *pdfViewContainer;
  PDFViewerController *pdfViewerController;
  
  BOOL shouldHighlightFirstMatch;
  
  BOOL shouldContinueSearching;
  
  BOOL statusViewIsShowing;
  
  TPEngineSettingsController *engineSettingsController;
  
  MHSlideViewController *slideViewController;
  
  TPStatusViewController *statusViewController;
  NSView *statusViewContainer;
  
  NSMutableArray *results;
}

@property (assign) IBOutlet NSWindow *mainWindow;

@property (retain) NSMutableArray *results;

@property (assign) IBOutlet MHControlsTabBarController *tabbarController;

@property (assign) IBOutlet MHSlideViewController *slideViewController;

@property (assign) IBOutlet NSView *pdfViewContainer;
@property (retain) PDFViewerController *pdfViewerController;

@property (retain) MHMiniConsoleViewController *miniConsole;

@property (retain) TPStatusViewController *statusViewController;
@property (assign) IBOutlet NSView *statusViewContainer;

@property (retain) NSMutableDictionary *settings;
@property (retain) TPEngineSettingsController *engineSettingsController;
@property (assign) IBOutlet NSView *prefsContainerView;

@property (retain) LibraryController *library;
@property (assign) IBOutlet NSView *libraryContainerView;

@property (retain) PaletteController *palette;
@property (assign) IBOutlet NSView *paletteContainerView;

@property(readwrite, assign) NSMutableAttributedString *documentData;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (retain) IBOutlet NSView *texEditorContainer;
@property (retain) NSDate *fileLoadDate;

@property (retain) TPFileMonitor *fileMonitor;

@property (retain) TPEngineManager *engineManager;

- (void) initSettings;
- (void) setupSettings;
- (void) updateFileStatus;
- (void)documentSave:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo;
- (void)documentSaveAndBuild:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo;


- (void) wrappedHighlightSearchResult:(NSString*)result withRange:(NSString*)aRangeString inFile:(id)aFile;

#pragma mark -
#pragma mark Notification Handlers

- (void) handleTextSelectionChanged:(NSNotification*)aNote;
- (void) updateCursorInfoText;

#pragma mark -
#pragma mark control

- (IBAction) addToProject:(id)sender;
- (IBAction) endAddToProjectSheet:(id)sender;
- (IBAction) endAddToNewProjectSheet:(id)sender;
- (void) addToNewEmptyProject;
- (void) insertTextToCurrentDocument:(NSString*)string;
- (IBAction)toggleStatusView:(id)sender;
- (void) toggleStatusBar:(BOOL)animate;

#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender;
- (IBAction) buildAndView:(id)sender;
- (IBAction) buildProject:(id)sender;
- (void) build;
- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote;
- (IBAction) openPDF:(id)sender;
- (void) showDocument;
- (NSString*)compiledDocumentPath;

- (BOOL) pdfHasSelection;

@end

