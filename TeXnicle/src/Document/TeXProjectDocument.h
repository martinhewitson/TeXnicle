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
  
  NSWindow *__unsafe_unretained _mainWindow;
  
  ProjectEntity *_project;
  BOOL _openPDFAfterBuild;
  
	// New file
	IBOutlet NSWindow *_newFileSheet;
	IBOutlet NSTextField *_newFilenameTextField;
  
  // split views  
  NSSplitView *__unsafe_unretained _splitview;
  NSView *__unsafe_unretained _leftView;
  NSView *__unsafe_unretained _rightView;
  NSView *__unsafe_unretained _centerView;
  
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
  
  TPOutlineView *__unsafe_unretained _projectOutlineView;
  NSTabView *__unsafe_unretained _controlsTabview;
  OpenDocumentsManager *__unsafe_unretained _openDocuments;
  ProjectItemTreeController *__unsafe_unretained _projectItemTreeController;
  TeXEditorViewController *_texEditorViewController;
  NSView *__unsafe_unretained _texEditorContainer;
  TPImageViewerController *_imageViewerController;
  NSView *__unsafe_unretained _imageViewerContainer;
  TPFileMonitor *_fileMonitor;
      
  NSView *__unsafe_unretained _bookmarkContainerView;
  BookmarkManager *_bookmarkManager;
  
  NSView *__unsafe_unretained _finderContainerView;
  FinderController *_finder;
  BOOL _shouldHighlightFirstMatch;
  
  TPEngineManager *_engineManager;
  
  TPEngineSettingsController *_engineSettings;
  NSView *__unsafe_unretained _engineSettingsContainer;
  
  HHValidatedButton *__unsafe_unretained _createFolderButton;
  HHValidatedButton *__unsafe_unretained _createFileButton;
  
  TPProjectOutlineViewController *_outlineViewController;
  NSView *__unsafe_unretained _outlineViewContainer;
  
  MHMiniConsoleViewController *_miniConsole;
  TPConsoleViewController *_embeddedConsoleViewController;
  NSView *__unsafe_unretained _embeddedConsoleContainer;
  IBOutlet NSSplitView *_editorSplitView;
  
  NSView *__unsafe_unretained _statusViewContainer;
  TPStatusViewController *_statusViewController;
  BOOL _statusViewIsShowing;
  
  TPLibraryController *_libraryController;
  NSView *__unsafe_unretained _libraryContainerView;
  
  TPSpellCheckerListingViewController *_spellcheckerViewController;
  NSView *__unsafe_unretained _spellCheckerContainerView;
  
  TPWarningsViewController *_warningsViewController;
  NSView *__unsafe_unretained _warningsContainerView;
  
  TPLabelsViewController *_labelsViewController;
  NSView *__unsafe_unretained _labelsContainerView;
  
  TPCitationsViewController *_citationsViewController;
  NSView *__unsafe_unretained _citationsContainerView;
  
  TPNewCommandsViewController *_commandsViewController;
  NSView *__unsafe_unretained _commandsContainerView;
  
  PDFViewerController *_pdfViewerController;
  
  PaletteController *_palette;
  NSView *__unsafe_unretained _paletteContainverView;
    
  BOOL _pdfHasSelection;
  
  BOOL _windowIsClosing;
  
  MHControlsTabBarController *__unsafe_unretained _controlsTabBarController;
  MHInfoTabBarController *__unsafe_unretained _infoControlsTabBarController;
  
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
  HHValidatedButton *__unsafe_unretained _backTabButton;
  HHValidatedButton *__unsafe_unretained _forwardTabButton;
  
  NSMenu *_createFolderMenu;
  
  BOOL _didSetup;
  
  TPProjectTemplateCreator *_templateCreator;
}

@property (strong) TPProjectTemplateCreator *templateCreator;

@property (strong) NSMenu *createFolderMenu;

@property (unsafe_unretained) IBOutlet HHValidatedButton *backTabButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *forwardTabButton;
@property (strong) NSMutableArray *tabHistory;
@property (assign) NSInteger currentTabHistoryIndex;
@property (assign) BOOL navigatingHistory;

@property (unsafe_unretained) IBOutlet NSWindow *mainWindow;

@property (strong) NSTimer *liveUpdateTimer;

@property (strong) TPProjectOutlineViewController *outlineViewController;
@property (unsafe_unretained) IBOutlet NSView *outlineViewContainer;

@property (strong) TPWarningsViewController *warningsViewController;
@property (unsafe_unretained) IBOutlet NSView *warningsContainerView;

@property (strong) TPLabelsViewController *labelsViewController;
@property (unsafe_unretained) IBOutlet NSView *labelsContainerView;

@property (strong) TPCitationsViewController *citationsViewController;
@property (unsafe_unretained) IBOutlet NSView *citationsContainerView;

@property (strong) TPNewCommandsViewController *commandsViewController;
@property (unsafe_unretained) IBOutlet NSView *commandsContainerView;

@property (strong) MHMiniConsoleViewController *miniConsole;

@property (strong) TPConsoleViewController *embeddedConsoleViewController;
@property (unsafe_unretained) IBOutlet NSView *embeddedConsoleContainer;


@property (strong) PDFViewer *pdfViewer;

@property (strong)   NSTimer *statusTimer;

@property (unsafe_unretained) IBOutlet NSView *statusViewContainer;
@property (strong) TPStatusViewController *statusViewController;

@property (unsafe_unretained) IBOutlet HHValidatedButton *createFolderButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *createFileButton;

@property (strong) TPEngineSettingsController *engineSettings;
@property (unsafe_unretained) IBOutlet NSView *engineSettingsContainer;

@property (strong) TPEngineManager *engineManager;

@property (unsafe_unretained) IBOutlet NSSplitView *splitview;
@property (unsafe_unretained) IBOutlet NSView *leftView;
@property (unsafe_unretained) IBOutlet NSView *rightView;
@property (unsafe_unretained) IBOutlet NSView *centerView;

@property (unsafe_unretained) IBOutlet NSView *bookmarkContainerView;
@property (strong) BookmarkManager *bookmarkManager;

@property (unsafe_unretained) IBOutlet NSView *paletteContainverView;
@property (strong) PaletteController *palette;

@property (unsafe_unretained) IBOutlet NSView *finderContainerView;
@property (strong) FinderController *finder;

@property (unsafe_unretained) IBOutlet NSView *libraryContainerView;
@property (strong) TPLibraryController *libraryController;

@property (strong) TPSpellCheckerListingViewController *spellcheckerViewController;
@property (unsafe_unretained) IBOutlet NSView *spellCheckerContainerView;

@property (strong) PDFViewerController *pdfViewerController;
@property (strong) ProjectEntity *project;
@property (unsafe_unretained) IBOutlet TPOutlineView *projectOutlineView;
@property (unsafe_unretained) IBOutlet NSTabView *controlsTabview;
@property (unsafe_unretained) IBOutlet OpenDocumentsManager *openDocuments;
@property (unsafe_unretained) IBOutlet	ProjectItemTreeController *projectItemTreeController;
@property (strong) TeXEditorViewController *texEditorViewController;
@property (unsafe_unretained) IBOutlet NSView *texEditorContainer;
@property (unsafe_unretained) IBOutlet NSView *imageViewerContainer;
@property (strong) TPImageViewerController *imageViewerController;
@property (strong) TPFileMonitor *fileMonitor;

@property (strong) TPTemplateEditor *templateEditor;

@property (unsafe_unretained) IBOutlet MHControlsTabBarController *controlsTabBarController;
@property (unsafe_unretained) IBOutlet MHInfoTabBarController *infoControlsTabBarController;

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
- (IBAction) newFolderOnDisk:(id)sender;
- (IBAction) newGroupFolder:(id) sender;
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
