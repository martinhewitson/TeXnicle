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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
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
#import "LibraryController.h"
#import "PaletteController.h"
#import "ProjectOutlineController.h"
#import "PDFViewer.h"
#import "TeXTextView.h"
#import "TPTemplateEditor.h"
#import "TPConsoleViewController.h"

@class TeXEditorViewController;

@interface ExternalTeXDoc : NSDocument <TemplateEditorDelegate, NSWindowDelegate, PDFViewerDelegate, ProjectOutlineControllerDelegate, PaletteControllerDelegate, LibraryControllerDelegate, PDFViewerControllerDelegate, NSApplicationDelegate, TPFileMonitorDelegate, TeXTextViewDelegate, TPEngineManagerDelegate, TPEngineSettingsDelegate> {

  NSView *leftView;
  NSView *centerView;
  NSView *rightView;
  NSSplitView *splitView;
  
  NSRect _leftViewFrame;
  NSRect _centerViewFrame;
  NSRect _rightViewFrame;
  
  CGFloat _leftDividerPostion;
  CGFloat _rightDividerPostion;
  NSRect _windowFrame;
  
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
  TPConsoleViewController *embeddedConsoleViewController;
  NSView *embeddedConsoleContainer;
  IBOutlet NSSplitView *editorSplitView;
  
  NSWindow *mainWindow;
  
  NSView *pdfViewContainer;
  PDFViewerController *pdfViewerController;
  
  BOOL shouldHighlightFirstMatch;
  
  BOOL shouldContinueSearching;
  
  BOOL statusViewIsShowing;
  BOOL _inVersionsBrowser;
  
  TPEngineSettingsController *engineSettingsController;
  
  TPStatusViewController *statusViewController;
  NSView *statusViewContainer;
  
  NSMutableArray *results;
  
  PDFViewer *pdfViewer;
  
  MHControlsTabBarController *tabbarController;
  PaletteController *palette;
  NSView *paletteContainerView;
  LibraryController *library;
  NSView *libraryContainerView;
  NSView *prefsContainerView;
  
  IBOutlet ProjectOutlineController *outlineController;
  
  IBOutlet NSView *controlsViewContainer;
  
  NSStringEncoding _encoding;
  
  TPTemplateEditor *templateEditor;
  
  
  BOOL _liveUpdate;
  BOOL _building;
  NSDate *lastBuildDate;
  NSTimer *liveUpdateTimer;
}

@property (retain) NSTimer *liveUpdateTimer;

@property (assign) IBOutlet NSWindow *mainWindow;

@property (assign) IBOutlet NSView *leftView;
@property (assign) IBOutlet NSView *centerView;
@property (assign) IBOutlet NSView *rightView;
@property (assign) IBOutlet NSSplitView *splitView;

@property (retain) NSMutableArray *results;

@property (retain) PDFViewer *pdfViewer;

@property (assign) IBOutlet MHControlsTabBarController *tabbarController;

@property (assign) IBOutlet NSView *pdfViewContainer;
@property (retain) PDFViewerController *pdfViewerController;

@property (retain) MHMiniConsoleViewController *miniConsole;
@property (retain) TPConsoleViewController *embeddedConsoleViewController;
@property (assign) IBOutlet NSView *embeddedConsoleContainer;

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
@property (assign) IBOutlet NSView *texEditorContainer;
@property (retain) NSDate *fileLoadDate;

@property (retain) TPFileMonitor *fileMonitor;

@property (retain) TPEngineManager *engineManager;

@property (retain) TPTemplateEditor *templateEditor;


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

@end

