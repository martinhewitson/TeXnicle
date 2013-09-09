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
#import "TPSpellCheckerListingViewController.h"
#import "TPProjectOutlineViewController.h"
#import "TPWarningsViewController.h"
#import "TPLabelsViewController.h"
#import "TPCitationsViewController.h"
#import "TPNewCommandsViewController.h"
#import "TPDocumentReportWindowController.h"
#import "TPQuickJumpViewController.h"

#import "TPMetadataViewController.h"
#import "TPMetadataManager.h"

@class ProjectEntity;
@class ProjectItemEntity;
@class ProjectItemTreeController;
@class FindInProjectController;
@class TPStatusView;
@class TPImageViewerController;
@class Bookmark;

@interface TeXProjectDocument : NSPersistentDocument <MetadataManagerDelegate, TPMetadataViewDelegate, TPNewCommandsViewDelegate, TPCitationsViewDelegate, TPLabelsViewDelegate,
TPWarningsViewDelegate, TPProjectOutlineDelegate, TPSpellCheckerListingDelegate, TPProjectTemplateCreateDelegate, TemplateEditorDelegate, 
PDFViewerDelegate, NSToolbarDelegate, NSUserInterfaceValidations, TPEngineSettingsDelegate, 
NSMenuDelegate, TPEngineManagerDelegate, BookmarkManagerDelegate, PDFViewerControllerDelegate,
PaletteControllerDelegate, TPLibraryControllerDelegate, TPFileMonitorDelegate, 
FinderControllerDelegate, OpenDocumentsManagerDelegate, TeXTextViewDelegate, NSWindowDelegate, TPDocumentReporterDelegate, TPConsoleDelegate, QuickJumpDelegate> {

@private
    
	IBOutlet NSWindow *_newFileSheet;
	IBOutlet NSTextField *_newFilenameTextField;
	IBOutlet NSWindow *_renameSheet;
	IBOutlet NSTextField *_renameField;
  IBOutlet NSTabView *_tabView;
  IBOutlet NSView *_pdfViewerContainerView;
    
  NSMenu *_treeActionMenu;
  
  ProjectItemEntity *_selectedItem;
  
	NSUInteger _itemBeingRenamed;
  NSInteger _selectedRow;
        
  BOOL _openPDFAfterBuild;
  BOOL _shouldHighlightFirstMatch;
  BOOL _statusViewIsShowing;
  BOOL _windowIsClosing;
  BOOL _building;
  BOOL _didSetup;
}

@property (strong) IBOutlet	ProjectItemTreeController *projectItemTreeController;
@property (strong) PDFViewer *pdfViewer;
@property (strong) TeXEditorViewController *texEditorViewController;
@property (strong) PDFViewerController *pdfViewerController;
@property (strong) BookmarkManager *bookmarkManager;

- (void) restoreUIstate;
- (void) captureUIstate;

- (IBAction)reopenUsingEncoding:(id)sender;
- (void) restoreOpenTabs;
+ (TeXProjectDocument*) createNewTeXnicleProject;
+ (void) createTeXnicleProjectAtURL:(NSURL*)aURL;
+ (NSSavePanel*)getDocumentURLSavePanel;
+ (NSURL*)getNewDocumentURL;
+ (NSManagedObjectContext*) managedObjectContextForStoreURL: (NSURL*) storeURL;

- (void) updateStatusView;

- (IBAction)showQuickJump:(id)sender;

- (void) toggleStatusBar:(BOOL)animate;

- (IBAction)togglePanelFocus:(id)sender;

- (IBAction) showIntegratedPDFViewer:(id)sender;
- (IBAction) showIntegratedConsole:(id)sender;

- (IBAction)backTabButtonPressed:(id)sender;
- (IBAction)forwardTabButtonPressed:(id)sender;

#pragma mark -
#pragma mark Notification Handlers

- (void) handleProjectOutlineViewSelectionChange:(NSNotification*)aNote;

#pragma mark -
#pragma mark ProjectOutlineController delegate

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile;

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

- (IBAction) cancelCompile:(id)sender;
- (IBAction) clean:(id)sender;
- (IBAction) buildAndView:(id)sender;
- (IBAction) buildProject:(id)sender;

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

- (void) didRemoveFile:(FileEntity*)aFile;
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

- (void) syncPDFToEditor;
- (void) syncToPDFLine:(NSInteger)lineNumber column:(NSInteger)column;
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

- (IBAction)createDocumentReport:(id)sender;
- (IBAction)createProjectTemplate:(id)sender;

#pragma mark -
#pragma mark Tab history
- (void) clearTabHistory;

@end
