//
//  TeXProjectDocument.h
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
//  Copyright 2011 bobsoft. All rights reserved.
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
#import <Quartz/Quartz.h>
#import "OpenDocumentsManager.h"
#import "TeXEditorViewController.h"
#import "TPFileMonitor.h"
#import "HHValidatedButton.h"
#import "PDFViewerController.h"
#import "FinderController.h"
#import "TPLibraryController.h"
#import "PaletteController.h"
#import "BookmarkManager.h"
#import "TPEngineManager.h"
#import "TPEngineSettingsController.h"
#import "TPOutlineView.h"
#import "MHMiniConsoleViewController.h"
#import "MHConsoleManager.h"
#import "TPStatusViewController.h"
#import "PDFViewer.h"
#import "TPSupportedFilesManager.h"
#import "MHControlsTabBarController.h"
#import "MHInfoTabBarController.h"
#import "TPTemplateEditor.h"
#import "TPProjectTemplateCreator.h"
#import "TPConsoleViewController.h"
#import "OtherFilesViewController.h"
#import "TPSpellCheckerListingViewController.h"
#import "TPProjectOutlineViewController.h"
#import "TPWarningsViewController.h"
#import "TPLabelsViewController.h"
#import "TPCitationsViewController.h"
#import "TPNewCommandsViewController.h"

@class ProjectEntity;
@class ProjectItemEntity;
@class ProjectItemTreeController;
@class FindInProjectController;
@class TPStatusView;
@class TPImageViewerController;
@class Bookmark;

@interface TeXProjectDocument : NSPersistentDocument <TPNewCommandsViewDelegate, TPCitationsViewDelegate, TPLabelsViewDelegate, 
TPWarningsViewDelegate, TPProjectOutlineDelegate, TPSpellCheckerListingDelegate, 
OtherFilesViewControllerDelegate, TPProjectTemplateCreateDelegate, TemplateEditorDelegate, 
PDFViewerDelegate, NSToolbarDelegate, NSUserInterfaceValidations, TPEngineSettingsDelegate, 
NSMenuDelegate, TPEngineManagerDelegate, BookmarkManagerDelegate, PDFViewerControllerDelegate, 
PaletteControllerDelegate, TPLibraryControllerDelegate, TPFileMonitorDelegate, 
FinderControllerDelegate, OpenDocumentsManagerDelegate, TeXTextViewDelegate, NSWindowDelegate> {

@private
  
  NSWindow *_mainWindow;
  
  ProjectEntity *_project;
  BOOL _openPDFAfterBuild;
  
	// New file
	IBOutlet NSWindow *_newFileSheet;
	IBOutlet NSTextField *_newFilenameTextField;
  
  // split views  
  NSSplitView *_splitview;
  NSView *_leftView;
  NSView *_rightView;
  NSView *_centerView;
  
  BOOL _inVersionsBrowser;
  
  
	IBOutlet NSWindow *_renameSheet;
	IBOutlet NSTextField *_renameField;
	NSUInteger _itemBeingRenamed;
  
  IBOutlet NSTabView *_tabView;
  
  IBOutlet NSView *_pdfViewerContainerView;
  
  NSTimer *_statusTimer;
  
  NSMenu *_treeActionMenu;
  ProjectItemEntity *_selectedItem;
  NSInteger _selectedRow;
  
  TPOutlineView *_projectOutlineView;
  NSTabView *_controlsTabview;
  OpenDocumentsManager *_openDocuments;
  ProjectItemTreeController *_projectItemTreeController;
  TeXEditorViewController *_texEditorViewController;
  NSView *_texEditorContainer;
  TPImageViewerController *_imageViewerController;
  NSView *_imageViewerContainer;
  TPFileMonitor *_fileMonitor;
      
  NSView *_bookmarkContainerView;
  BookmarkManager *_bookmarkManager;
  
  NSView *_finderContainerView;
  FinderController *_finder;
  BOOL _shouldHighlightFirstMatch;
  
  TPEngineManager *_engineManager;
  
  TPEngineSettingsController *_engineSettings;
  NSView *_engineSettingsContainer;
  
  HHValidatedButton *_createFolderButton;
  HHValidatedButton *_createFileButton;
  
  TPProjectOutlineViewController *_outlineViewController;
  NSView *_outlineViewContainer;
  
  MHMiniConsoleViewController *_miniConsole;
  TPConsoleViewController *_embeddedConsoleViewController;
  NSView *_embeddedConsoleContainer;
  IBOutlet NSSplitView *_editorSplitView;
  
  NSView *_statusViewContainer;
  TPStatusViewController *_statusViewController;
  BOOL _statusViewIsShowing;
  
  TPLibraryController *_libraryController;
  NSView *_libraryContainerView;
  
  TPSpellCheckerListingViewController *_spellcheckerViewController;
  NSView *_spellCheckerContainerView;
  
  TPWarningsViewController *_warningsViewController;
  NSView *_warningsContainerView;
  
  TPLabelsViewController *_labelsViewController;
  NSView *_labelsContainerView;
  
  TPCitationsViewController *_citationsViewController;
  NSView *_citationsContainerView;
  
  TPNewCommandsViewController *_commandsViewController;
  NSView *_commandsContainerView;
  
  PDFViewerController *_pdfViewerController;
  
  PaletteController *_palette;
  NSView *_paletteContainverView;
    
  BOOL _pdfHasSelection;
  
  BOOL _windowIsClosing;
  
  MHControlsTabBarController *_controlsTabBarController;
  MHInfoTabBarController *_infoControlsTabBarController;
  
//  NSRange lastLineRange;
//  NSInteger lastLineNumber;
  PDFViewer *_pdfViewer;
  
  TPTemplateEditor *_templateEditor;
  
  BOOL _liveUpdate;
  BOOL _building;
  NSTimer *_liveUpdateTimer;
  
  NSMutableArray *_tabHistory;
  NSInteger _currentTabHistoryIndex;
  BOOL _navigatingHistory;
  HHValidatedButton *_backTabButton;
  HHValidatedButton *_forwardTabButton;
  
  NSMenu *_createFolderMenu;
  
  BOOL _didSetup;
  
  TPProjectTemplateCreator *_templateCreator;
}

@property (retain) TPProjectTemplateCreator *templateCreator;

@property (retain) NSMenu *createFolderMenu;

@property (assign) IBOutlet HHValidatedButton *backTabButton;
@property (assign) IBOutlet HHValidatedButton *forwardTabButton;
@property (retain) NSMutableArray *tabHistory;
@property (assign) NSInteger currentTabHistoryIndex;
@property (assign) BOOL navigatingHistory;

@property (assign) IBOutlet NSWindow *mainWindow;

@property (retain) NSTimer *liveUpdateTimer;

@property (retain) TPProjectOutlineViewController *outlineViewController;
@property (assign) IBOutlet NSView *outlineViewContainer;

@property (retain) TPWarningsViewController *warningsViewController;
@property (assign) IBOutlet NSView *warningsContainerView;

@property (retain) TPLabelsViewController *labelsViewController;
@property (assign) IBOutlet NSView *labelsContainerView;

@property (retain) TPCitationsViewController *citationsViewController;
@property (assign) IBOutlet NSView *citationsContainerView;

@property (retain) TPNewCommandsViewController *commandsViewController;
@property (assign) IBOutlet NSView *commandsContainerView;

@property (retain) MHMiniConsoleViewController *miniConsole;

@property (retain) TPConsoleViewController *embeddedConsoleViewController;
@property (assign) IBOutlet NSView *embeddedConsoleContainer;


@property (retain) PDFViewer *pdfViewer;

@property (retain)   NSTimer *statusTimer;

@property (assign) IBOutlet NSView *statusViewContainer;
@property (retain) TPStatusViewController *statusViewController;

@property (assign) IBOutlet HHValidatedButton *createFolderButton;
@property (assign) IBOutlet HHValidatedButton *createFileButton;

@property (retain) TPEngineSettingsController *engineSettings;
@property (assign) IBOutlet NSView *engineSettingsContainer;

@property (retain) TPEngineManager *engineManager;

@property (assign) IBOutlet NSSplitView *splitview;
@property (assign) IBOutlet NSView *leftView;
@property (assign) IBOutlet NSView *rightView;
@property (assign) IBOutlet NSView *centerView;

@property (assign) IBOutlet NSView *bookmarkContainerView;
@property (retain) BookmarkManager *bookmarkManager;

@property (assign) IBOutlet NSView *paletteContainverView;
@property (retain) PaletteController *palette;

@property (assign) IBOutlet NSView *finderContainerView;
@property (retain) FinderController *finder;

@property (assign) IBOutlet NSView *libraryContainerView;
@property (retain) TPLibraryController *libraryController;

@property (retain) TPSpellCheckerListingViewController *spellcheckerViewController;
@property (assign) IBOutlet NSView *spellCheckerContainerView;

@property (retain) PDFViewerController *pdfViewerController;
@property (retain) ProjectEntity *project;
@property (assign) IBOutlet TPOutlineView *projectOutlineView;
@property (assign) IBOutlet NSTabView *controlsTabview;
@property (assign) IBOutlet OpenDocumentsManager *openDocuments;
@property (assign) IBOutlet	ProjectItemTreeController *projectItemTreeController;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (assign) IBOutlet NSView *texEditorContainer;
@property (assign) IBOutlet NSView *imageViewerContainer;
@property (retain) TPImageViewerController *imageViewerController;
@property (retain) TPFileMonitor *fileMonitor;

@property (retain) TPTemplateEditor *templateEditor;

@property (assign) IBOutlet MHControlsTabBarController *controlsTabBarController;
@property (assign) IBOutlet MHInfoTabBarController *infoControlsTabBarController;

@property (readonly) BOOL pdfHasSelection;

- (void) restoreUIstate;
- (void) captureUIstate;
- (void) restoreSplitViewPositions;


- (IBAction)reopenUsingEncoding:(id)sender;
- (void) restoreOpenTabs;
+ (TeXProjectDocument*) createNewTeXnicleProject;
+ (void) createTeXnicleProjectAtURL:(NSURL*)aURL;
+ (NSSavePanel*)getDocumentURLSavePanel;
+ (NSURL*)getNewDocumentURL;
+ (NSManagedObjectContext*) managedObjectContextForStoreURL: (NSURL*) storeURL;

- (void) updateStatusView;

- (void) toggleStatusBar:(BOOL)animate;

- (IBAction)togglePanelFocus:(id)sender;

- (IBAction) showIntegratedPDFViewer:(id)sender;
- (IBAction) showIntegratedConsole:(id)sender;


#pragma mark -
#pragma mark Notification Handlers

- (void) handleProjectOutlineViewSelectionChange:(NSNotification*)aNote;

#pragma mark -
#pragma mark ProjectOutlineController delegate

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile;

#pragma mark -
#pragma mark Tree Action Menu

- (IBAction) showCategoryActionMenu:(id)sender;
- (IBAction) setMainItem:(id)sender;
- (IBAction) revealItem:(id)sender;
- (IBAction) renameItem:(id)sender;
- (IBAction) removeItem:(id)sender;
- (IBAction) locateItem:(id)sender;

#pragma mark -
#pragma mark Rename project items

- (void) renameItemAtRow:(NSInteger)row;
- (IBAction) endRenameSheet:(id)sender;
- (void) renameItemTo:(NSString*)newName;

#pragma mark -
#pragma mark Text Handling

- (IBAction)pasteAsImage:(id)sender;
- (NSString*)imageTextForFile:(NSString*)filepath;

- (void) insertTextToCurrentDocument:(NSString*)string;


#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender;
- (IBAction) projectTypeChanged:(id)sender;
- (IBAction) buildAndView:(id)sender;
- (IBAction) buildProject:(id)sender;

- (IBAction)liveUpdate:(id)sender;
- (void)doLiveBuild;

- (void) build;
- (IBAction) openPDF:(id)sender;
- (IBAction)openWithSystemPDFViewer:(id)sender;
- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote;


- (NSString*)workingDirectory;
- (NSString*)documentToCompile;
- (NSString*)compiledDocumentPath;

- (BOOL) canViewPDF;
- (BOOL) canTypeset;
- (BOOL) canBibTeX;



#pragma mark - 
#pragma mark Files and Folders

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem;
- (IBAction)reloadCurrentFileFromDisk:(id)sender;
- (void) selectTabForFile:(FileEntity*)aFile;
- (IBAction) selectTab:(id)sender;
- (IBAction) selectNextTab:(id)sender;
- (IBAction) selectPreviousTab:(id)sender;

- (IBAction) addExistingFile:(id)sender;
- (IBAction) addExistingFolder:(id)sender;
- (IBAction) addNewFolder:(id)sender;
- (IBAction) addExistingFileToSelectedFolder:(id)sender;


- (NSArray*) getSelectedItems;
- (IBAction) jumpToMainFile:(id)sender;
- (IBAction) setMainFile:(id)sender;
- (IBAction) openProjectFolderInFinder:(id)sender;
- (NSString*) nameOfSelectedProjectItem;
- (IBAction)closeAllTabs:(id)sender;
- (IBAction) closeCurrentTab:(id)sender;
- (IBAction) newFolder:(id)sender;
- (IBAction) newFile:(id)sender;
- (IBAction) endNewFileSheet:(id)sender;
- (void) newFileExists:(NSAlert *)alert code:(int)choice context:(void *)v;
- (void) makeNewFile;
- (IBAction) newTeXFile:(id)sender;

// new template stuff
- (void) showTemplatesSheet;
- (void) makeNewTexFileFromTemplate:(NSDictionary*)aTemplate withFilename:(NSString*)aFilename setAsMain:(BOOL)isMain;

- (void) newTexFileExists:(NSAlert *)alert code:(int)choice context:(void *)v;
- (void) addNewArticleMainFile;
- (IBAction) newMainTeXFile:(id)sender;
- (IBAction) delete:(id)sender;
- (BOOL) canAddNewFile;
- (BOOL) canAddNewTeXFile;
- (BOOL) canAddNewFolder;
- (BOOL) canRemove;
- (NSManagedObject*) addFileAtURL:(NSURL*)aURL copy:(BOOL)copyFile;

+ (NSString*) stringForNewArticleMainFileCode;

- (void) reloadCurrentFileFromDiskAndRestoreSelection:(FileEntity*)fileEntity;

#pragma mark -
#pragma mark Saving

- (BOOL) saveAllProjectFiles;

#pragma mark -
#pragma mark PDF Selection

- (IBAction) findCorrespondingPDFText:(id)sender;
- (IBAction) findSource:(id)sender;
- (void) findSourceOfText:(NSString *)string;
- (BOOL) pdfHasSelection;
- (void) showDocument;

#pragma mark -
#pragma mark Bookmarks

- (IBAction)showBookmarks:(id)sender;
- (IBAction)deleteSelectedBookmark:(id)sender;
- (IBAction)jumpToSelectedBookmark:(id)sender;
- (Bookmark*)bookmarkForCurrentLine;
- (Bookmark*)bookmarkForLine:(NSInteger)linenumber;
- (BOOL) hasBookmarkAtCurrentLine:(id)sender;
- (BOOL) hasBookmarkAtLine:(NSInteger)aLinenumber;
- (IBAction)addBookmarkAtCurrentLine:(id)sender;
- (void) addBookmarkAtLine:(NSInteger)aLinenumber;
- (IBAction)removeBookmarkAtCurrentLine:(id)sender;
- (void) removeBookmarkAtLine:(NSInteger)aLinenumber;
- (IBAction)toggleBookmark:(id)sender;
- (IBAction)previousBookmark:(id)sender;
- (IBAction)nextBookmark:(id)sender;


#pragma mark -
#pragma mark Project Template Stuff

- (IBAction)createProjectTemplate:(id)sender;

#pragma mark -
#pragma mark Tab history
- (void) clearTabHistory;

@end
