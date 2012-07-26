//
//  ExternalTeXDoc.h
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
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
#import "TPFileMonitor.h"
#import "TeXTextView.h"
#import "TPEngineManager.h"
#import "TPEngineSettingsController.h"
#import "MHMiniConsoleViewController.h"
#import "PDFViewerController.h"
#import "TPStatusViewController.h"
#import "MHControlsTabBarController.h"
#import "MHInfoTabBarController.h"
#import "TPLibraryController.h"
#import "PaletteController.h"
#import "PDFViewer.h"
#import "TeXTextView.h"
#import "TPTemplateEditor.h"
#import "TPConsoleViewController.h"
#import "TPProjectOutlineViewController.h"
#import "TPSpellCheckerListingViewController.h"
#import "TPWarningsViewController.h"
#import "TPLabelsViewController.h"
#import "TPCitationsViewController.h"
#import "TPNewCommandsViewController.h"


@class TeXEditorViewController;

@interface ExternalTeXDoc : NSDocument <TPNewCommandsViewDelegate, TPCitationsViewDelegate, TPLabelsViewDelegate, TPWarningsViewDelegate, TPProjectOutlineDelegate, TPSpellCheckerListingDelegate, TemplateEditorDelegate, NSWindowDelegate, PDFViewerDelegate, PaletteControllerDelegate, TPLibraryControllerDelegate, PDFViewerControllerDelegate, NSApplicationDelegate, TPFileMonitorDelegate, TeXTextViewDelegate, TPEngineManagerDelegate, TPEngineSettingsDelegate> {

  NSView *_leftView;
  NSView *_centerView;
  NSView *_rightView;
  NSSplitView *_splitView;
  
  NSRect _leftViewFrame;
  NSRect _centerViewFrame;
  NSRect _rightViewFrame;
  
  CGFloat _leftDividerPostion;
  CGFloat _rightDividerPostion;
  NSRect _windowFrame;
  
	NSMutableAttributedString *_documentData;

	IBOutlet NSWindow *_addToProjectSheet;
	IBOutlet NSWindow *_addToEmptyProjectSheet;
	
	// Add to project
	IBOutlet NSArrayController *_projectsController;
	
	IBOutlet NSButton *_copyToProjectCheckButton;
	IBOutlet NSToolbarItem *_addToProjectButton;
	
	// Add to new project
	IBOutlet NSButton *_copyToNewProjectCheckButton;
	IBOutlet NSButton *_makeMainFileCheckButton;
		
  TeXEditorViewController *_texEditorViewController;
  NSView *_texEditorContainer;
  
  TPSpellCheckerListingViewController *_spellcheckerViewController;
  NSView *_spellCheckerContainerView;
  
  BOOL _openPDFAfterBuild;
  
  NSDate *_fileLoadDate;
  TPFileMonitor *_fileMonitor;
  
  TPEngineManager *_engineManager;
  
  NSMutableDictionary *_settings;
  
  MHMiniConsoleViewController *_miniConsole;
  TPConsoleViewController *_embeddedConsoleViewController;
  NSView *_embeddedConsoleContainer;
  IBOutlet NSSplitView *_editorSplitView;
  
  NSWindow *_mainWindow;
  
  NSView *_pdfViewContainer;
  PDFViewerController *_pdfViewerController;
  
  TPProjectOutlineViewController *_outlineViewController;
  NSView *_outlineViewContainer;
    
  BOOL _shouldContinueSearching;
  
  BOOL _statusViewIsShowing;
  BOOL _inVersionsBrowser;
  
  TPEngineSettingsController *_engineSettingsController;
  
  TPStatusViewController *_statusViewController;
  NSView *_statusViewContainer;
  
  NSMutableArray *_results;
  
  PDFViewer *_pdfViewer;
  
  MHControlsTabBarController *_tabbarController;
  MHInfoTabBarController *_infoTabbarController;
  PaletteController *_palette;
  NSView *_paletteContainerView;
  TPLibraryController *_library;
  NSView *_libraryContainerView;
  NSView *_prefsContainerView;
  
  TPWarningsViewController *_warningsViewController;
  NSView *_warningsContainerView;
  
  TPLabelsViewController *_labelsViewController;
  NSView *_labelsContainerView;
  
  TPCitationsViewController *_citationsViewController;
  NSView *_citationsContainerView;
  
  TPNewCommandsViewController *_commandsViewController;
  NSView *_commandsContainerView;
  
  IBOutlet NSView *_controlsViewContainer;
  
  NSStringEncoding _encoding;
  
  TPTemplateEditor *_templateEditor;
  
  
  NSTimer *_metadataUpdateTimer;
  
  BOOL _liveUpdate;
  BOOL _building;
  NSDate *_lastBuildDate;
  NSDate *_lastEdit;
  NSTimer *_liveUpdateTimer;
  NSNumber *_maxOutlineViewDepth;
  
  BOOL _didSetupUI;
}

@property (retain) NSDate *lastEdit;
@property (retain) NSTimer *liveUpdateTimer;
@property (retain) NSTimer *metadataUpdateTimer;

@property (assign) IBOutlet NSWindow *mainWindow;

@property (retain) NSNumber *maxOutlineViewDepth;

@property (assign) IBOutlet NSView *leftView;
@property (assign) IBOutlet NSView *centerView;
@property (assign) IBOutlet NSView *rightView;
@property (assign) IBOutlet NSSplitView *splitView;

@property (retain) NSMutableArray *results;

@property (retain) PDFViewer *pdfViewer;

@property (assign) IBOutlet MHControlsTabBarController *tabbarController;
@property (assign) IBOutlet MHInfoTabBarController *infoTabbarController;

@property (retain) TPWarningsViewController *warningsViewController;
@property (assign) IBOutlet NSView *warningsContainerView;

@property (retain) TPLabelsViewController *labelsViewController;
@property (assign) IBOutlet NSView *labelsContainerView;

@property (retain) TPCitationsViewController *citationsViewController;
@property (assign) IBOutlet NSView *citationsContainerView;

@property (retain) TPNewCommandsViewController *commandsViewController;
@property (assign) IBOutlet NSView *commandsContainerView;

@property (assign) IBOutlet NSView *pdfViewContainer;
@property (retain) PDFViewerController *pdfViewerController;

@property (retain) MHMiniConsoleViewController *miniConsole;
@property (retain) TPConsoleViewController *embeddedConsoleViewController;
@property (assign) IBOutlet NSView *embeddedConsoleContainer;

@property (retain) TPProjectOutlineViewController *outlineViewController;
@property (assign) IBOutlet NSView *outlineViewContainer;

@property (retain) TPStatusViewController *statusViewController;
@property (assign) IBOutlet NSView *statusViewContainer;

@property (retain) TPSpellCheckerListingViewController *spellcheckerViewController;
@property (assign) IBOutlet NSView *spellCheckerContainerView;

@property (retain) NSMutableDictionary *settings;
@property (retain) TPEngineSettingsController *engineSettingsController;
@property (assign) IBOutlet NSView *prefsContainerView;

@property (retain) TPLibraryController *library;
@property (assign) IBOutlet NSView *libraryContainerView;

@property (retain) PaletteController *palette;
@property (assign) IBOutlet NSView *paletteContainerView;

@property (readwrite, retain) NSMutableAttributedString *documentData;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (assign) IBOutlet NSView *texEditorContainer;
@property (retain) NSDate *fileLoadDate;

@property (retain) TPFileMonitor *fileMonitor;

@property (retain) TPEngineManager *engineManager;

@property (retain) TPTemplateEditor *templateEditor;


- (void) insertTabbarControllerIntoResponderChain;
- (void) initSettings;
- (void) setupSettings;
- (void) updateFileStatus;
- (void)documentSave:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo;
- (void)documentSaveAndBuild:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo;
- (BOOL) loadFileAtURL:(NSURL*)absoluteURL;
- (void)syncFileModificationDate;
- (void)checkToShowTemplateSheet;

- (void) restoreSplitViewPositions;

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
- (IBAction)reloadCurrentFileFromDisk:(id)sender;

#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender;
- (IBAction) buildAndView:(id)sender;
- (IBAction) buildProject:(id)sender;
- (void) build;

- (IBAction)liveUpdate:(id)sender;
- (BOOL)hasChanges;
- (void)doLiveBuild;

- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote;
- (IBAction) openPDF:(id)sender;
- (void) showDocument;
- (NSString*)compiledDocumentPath;

- (BOOL) pdfHasSelection;

#pragma mark -
#pragma mark Template sheet
- (void) showTemplatesSheet;
- (void) templateSelectionChanged:(NSNotification*)aNote;

- (void) syncDocumentDataFromEditor;

@end

