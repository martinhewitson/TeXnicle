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
#import "TPDocumentReportWindowController.h"


@class TeXEditorViewController;

@interface ExternalTeXDoc : NSDocument <TPNewCommandsViewDelegate, TPCitationsViewDelegate, TPLabelsViewDelegate, TPWarningsViewDelegate, TPProjectOutlineDelegate, TPSpellCheckerListingDelegate, TemplateEditorDelegate, NSWindowDelegate, PDFViewerDelegate, PaletteControllerDelegate, TPLibraryControllerDelegate, PDFViewerControllerDelegate, NSApplicationDelegate, TPFileMonitorDelegate, TeXTextViewDelegate, TPEngineManagerDelegate, TPEngineSettingsDelegate, TPDocumentReporterDelegate, TPConsoleDelegate> {

@private
  
  CGFloat _leftDividerPostion;
  CGFloat _rightDividerPostion;
  NSRect _windowFrame;
  
	IBOutlet NSWindow *_addToProjectSheet;
	IBOutlet NSWindow *_addToEmptyProjectSheet;
	IBOutlet NSArrayController *_projectsController;
	IBOutlet NSButton *_copyToProjectCheckButton;
	IBOutlet NSToolbarItem *_addToProjectButton;
	IBOutlet NSButton *_copyToNewProjectCheckButton;
	IBOutlet NSButton *_makeMainFileCheckButton;
  IBOutlet NSView *_controlsViewContainer;
  
  NSStringEncoding _encoding;
  NSDate *_lastBuildDate;

  BOOL _openPDFAfterBuild;
  BOOL _shouldContinueSearching;
  BOOL _statusViewIsShowing;
  BOOL _inVersionsBrowser;
  BOOL _liveUpdate;
  BOOL _building;
  BOOL _didSetupUI;
}

@property (strong) NSDate *lastEdit;
@property (strong) NSTimer *liveUpdateTimer;
@property (strong) NSTimer *metadataUpdateTimer;
@property (strong) NSNumber *maxOutlineViewDepth;
@property (strong) NSMutableArray *results;
@property (strong) PDFViewer *pdfViewer;
@property (strong) TPWarningsViewController *warningsViewController;
@property (strong) TPLabelsViewController *labelsViewController;
@property (strong) TPCitationsViewController *citationsViewController;
@property (strong) TPNewCommandsViewController *commandsViewController;
@property (strong) PDFViewerController *pdfViewerController;
@property (strong) MHMiniConsoleViewController *miniConsole;
@property (strong) TPConsoleViewController *embeddedConsoleViewController;
@property (strong) TPProjectOutlineViewController *outlineViewController;
@property (strong) TPStatusViewController *statusViewController;
@property (strong) TPSpellCheckerListingViewController *spellcheckerViewController;
@property (strong) NSMutableDictionary *settings;
@property (strong) TPEngineSettingsController *engineSettingsController;
@property (strong) TPLibraryController *library;
@property (strong) PaletteController *palette;
@property (strong) NSMutableAttributedString *documentData;
@property (strong) TeXEditorViewController *texEditorViewController;
@property (strong) NSDate *fileLoadDate;
@property (strong) TPFileMonitor *fileMonitor;
@property (strong) TPEngineManager *engineManager;
@property (strong) TPTemplateEditor *templateEditor;


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
- (void) syncDocumentDataFromEditor;

- (IBAction)createDocumentReport:(id)sender;


@end

