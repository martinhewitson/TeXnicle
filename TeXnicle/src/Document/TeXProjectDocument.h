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

@class ProjectEntity;
@class ProjectItemEntity;
@class ProjectItemTreeController;
@class FindInProjectController;
@class TPStatusView;
@class TPImageViewerController;
@class Bookmark;

@interface TeXProjectDocument : NSPersistentDocument <NSUserInterfaceValidations, TPEngineSettingsDelegate, NSMenuDelegate, TPEngineManagerDelegate, BookmarkManagerDelegate, PDFViewerControllerDelegate, PaletteControllerDelegate, LibraryControllerDelegate, TPFileMonitorDelegate, FinderControllerDelegate, ProjectOutlineControllerDelegate, OpenDocumentsManagerDelegate, TeXTextViewDelegate, NSWindowDelegate> {
@private
  ProjectEntity *project;
  BOOL openPDFAfterBuild;
  
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
  IBOutlet NSView *leftView;
  IBOutlet NSView *midView;
  IBOutlet NSView *rightView;
  
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
  NSInteger currentHighlightedPDFSearchResult;
  
  TPOutlineView *projectOutlineView;
  NSTabView *controlsTabview;
  OpenDocumentsManager *openDocuments;
  ProjectItemTreeController *projectItemTreeController;
  TeXEditorViewController *texEditorViewController;
  NSView *texEditorContainer;
  TPImageViewerController *imageViewerController;
  NSView *imageViewerContainer;
  TPStatusView *statusView;
  TPFileMonitor *fileMonitor;
      
  NSView *bookmarkContainerView;
  BookmarkManager *bookmarkManager;
  
  NSView *finderContainerView;
  FinderController *finder;
  BOOL shouldHighlightFirstMatch;
  
  TPEngineManager *engineManager;
  
  TPEngineSettingsController *engineSettings;
  NSView *engineSettingsContainer;
  
  HHValidatedButton *newFolderButton;
  HHValidatedButton *newFileButton;
  
  NSProgressIndicator *compileProgressIndicator;
}

@property (assign) IBOutlet NSProgressIndicator *compileProgressIndicator;

@property (retain)   NSTimer *statusTimer;

@property (assign) IBOutlet HHValidatedButton *newFolderButton;
@property (assign) IBOutlet HHValidatedButton *newFileButton;

@property (retain) TPEngineSettingsController *engineSettings;
@property (assign) IBOutlet NSView *engineSettingsContainer;

@property (retain) TPEngineManager *engineManager;

@property (assign) IBOutlet NSSplitView *splitview;

@property (assign) IBOutlet NSView *bookmarkContainverView;
@property (retain) BookmarkManager *bookmarkManager;

@property (assign) IBOutlet NSView *paletteContainverView;
@property (retain) PaletteController *palette;

@property (assign) IBOutlet NSView *finderContainverView;
@property (retain) FinderController *finder;

@property (assign) IBOutlet NSView *libraryContainerView;
@property (retain) LibraryController *library;

@property (retain) PDFViewerController *pdfViewerController;
@property (assign) IBOutlet TPStatusView *statusView;
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

@property (readonly) BOOL pdfHasSelection;

- (IBAction)reopenUsingEncoding:(id)sender;
- (void) restoreOpenTabs;
+ (TeXProjectDocument*) newTeXnicleProject;
+ (void) createTeXnicleProjectAtURL:(NSURL*)aURL;
+ (NSSavePanel*)getDocumentURLSavePanel;
+ (NSURL*)getNewDocumentURL;
+ (NSManagedObjectContext*) managedObjectContextForStoreURL: (NSURL*) storeURL;

- (void) updateStatusView;

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

- (void) insertTextToCurrentDocument:(NSString*)string;


#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender;
- (IBAction) projectTypeChanged:(id)sender;
- (IBAction) buildAndView:(id)sender;
- (IBAction) buildProject:(id)sender;
- (void) build;
- (IBAction) openPDF:(id)sender;
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

+ (NSString*) newArticleMainFileCode;

#pragma mark -
#pragma mark Saving

- (BOOL) saveAllProjectFiles;

#pragma mark -
#pragma mark PDF Selection

- (IBAction) findCorrespondingPDFText:(id)sender;
- (IBAction) findSource:(id)sender;
- (BOOL) pdfHasSelection;
- (void) showDocument;

#pragma mark -
#pragma mark Bookmarks

- (IBAction)showBookmarks:(id)sender;
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
#pragma mark Settings



@end
