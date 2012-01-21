//
//  TeXProjectDocument.h
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "OpenDocumentsManager.h"
#import "TeXEditorViewController.h"
#import "ProjectOutlineController.h"
#import "TPFileMonitor.h"
#import "HHValidatedButton.h"
#import "PDFViewerController.h"
#import "FinderController.h"
#import "LibraryController.h"
#import "PaletteController.h"
#import "BookmarkManager.h"
#import "TPEngineManager.h"
#import "TPEngineSettingsController.h"
#import "TPOutlineView.h"
#import "MHMiniConsoleViewController.h"
#import "MHConsoleManager.h"
#import "TPStatusViewController.h"
#import "PDFViewer.h"
#import "TPDocumentOutlineViewController.h"
#import "TPSupportedFilesManager.h"
#import "MHControlsTabBarController.h"

@class ProjectEntity;
@class ProjectItemEntity;
@class ProjectItemTreeController;
@class FindInProjectController;
@class TPStatusView;
@class TPImageViewerController;
@class Bookmark;

@interface TeXProjectDocument : NSPersistentDocument <DocumentOutlineDelegate, PDFViewerDelegate, NSToolbarDelegate, NSUserInterfaceValidations, TPEngineSettingsDelegate, NSMenuDelegate, TPEngineManagerDelegate, BookmarkManagerDelegate, PDFViewerControllerDelegate, PaletteControllerDelegate, LibraryControllerDelegate, TPFileMonitorDelegate, FinderControllerDelegate, ProjectOutlineControllerDelegate, OpenDocumentsManagerDelegate, TeXTextViewDelegate, NSWindowDelegate> {
@private
  ProjectEntity *project;
  BOOL openPDFAfterBuild;
  
  TPDocumentOutlineViewController *documentOutlineViewcontroller;
  NSView *documentOutlineViewContainer;
  
	NSArray *templateArray;
	IBOutlet NSWindow *templateSheet;
	IBOutlet NSArrayController *templates;
	IBOutlet NSTableView *templateTable;
	IBOutlet NSTextField *documentName;
	IBOutlet NSTextView *documentCode;
	IBOutlet NSButton *setAsMainFileCheckButton;
	// New file
	IBOutlet NSWindow *newFileSheet;
	IBOutlet NSTextField *newFilenameTextField;
  
  // split views  
  NSSplitView *splitview;
  NSView *leftView;
  NSView *rightView;
  NSView *centerView;
  
  BOOL _inVersionsBrowser;
  CGFloat _leftDividerPostion;
  CGFloat _rightDividerPostion;
  NSRect _windowFrame;
  
  NSInteger selectedControlsTab;
  
	IBOutlet NSWindow *renameSheet;
	IBOutlet NSTextField *renameField;
	NSUInteger itemBeingRenamed;
  
  IBOutlet ProjectOutlineController *projectOutlineController;
  
  IBOutlet NSTabView *tabView;
  
  IBOutlet NSView *pdfViewerContainerView;
  
  NSTimer *statusTimer;
  
  NSMenu *treeActionMenu;
  ProjectItemEntity *selectedItem;
  NSInteger selectedRow;
  
  TPOutlineView *projectOutlineView;
  NSTabView *controlsTabview;
  OpenDocumentsManager *openDocuments;
  ProjectItemTreeController *projectItemTreeController;
  TeXEditorViewController *texEditorViewController;
  NSView *texEditorContainer;
  TPImageViewerController *imageViewerController;
  NSView *imageViewerContainer;
  TPFileMonitor *fileMonitor;
      
  NSView *bookmarkContainerView;
  BookmarkManager *bookmarkManager;
  
  NSView *finderContainerView;
  FinderController *finder;
  BOOL shouldHighlightFirstMatch;
  
  TPEngineManager *engineManager;
  
  TPEngineSettingsController *engineSettings;
  NSView *engineSettingsContainer;
  
  HHValidatedButton *createFolderButton;
  HHValidatedButton *createFileButton;
  
  
  MHMiniConsoleViewController *miniConsole;
  
  NSView *statusViewContainer;
  TPStatusViewController *statusViewController;
  BOOL statusViewIsShowing;
  
  LibraryController *library;
  NSView *libraryContainerView;
  
  PDFViewerController *pdfViewerController;
  
  PaletteController *palette;
  NSView *paletteContainverView;
  
  BOOL pdfHasSelection;
  
  BOOL _windowIsClosing;
  
  MHControlsTabBarController *controlsTabBarController;
  
//  NSRange lastLineRange;
//  NSInteger lastLineNumber;
  PDFViewer *pdfViewer;
}

@property (retain) TPDocumentOutlineViewController *documentOutlineViewcontroller;
@property (assign) IBOutlet NSView *documentOutlineViewContainer;

@property (retain) MHMiniConsoleViewController *miniConsole;

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
@property (retain) LibraryController *library;

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

@property (assign) IBOutlet MHControlsTabBarController *controlsTabBarController;

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
- (void) insertTextToCurrentDocument:(NSString*)string;


#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender;
- (IBAction) projectTypeChanged:(id)sender;
- (IBAction) buildAndView:(id)sender;
- (IBAction) buildProject:(id)sender;
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
- (void) showTemplatesSheet;
- (void) templateSelectionChanged:(NSNotification*)aNote;
- (IBAction) addNewTemplate:(id)sender;
- (IBAction) endTemplateSheet:(id)sender;
- (void) newTexFileExists:(NSAlert *)alert code:(int)choice context:(void *)v;
- (void) makeNewTexFileFromTemplate;
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



@end
