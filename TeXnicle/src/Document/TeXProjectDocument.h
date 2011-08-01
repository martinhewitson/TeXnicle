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
#import "FindInProjectController.h"
#import "TPLaTeXEngine.h"
#import "TPFileMonitor.h"

@class ProjectEntity;
@class ProjectItemEntity;
@class ProjectItemTreeController;
@class TPLaTeXEngine;
@class FindInProjectController;
@class TPStatusView;
@class TPImageViewerController;

@interface TeXProjectDocument : NSPersistentDocument <TPFileMonitorDelegate, TPLaTeXEngineDelegate, FindInProjectControllerDelegate, ProjectOutlineControllerDelegate, OpenDocumentsManagerDelegate, TeXTextViewDelegate> {
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
  PDFView *pdfView;
  
  NSMenu *treeActionMenu;
  ProjectItemEntity *selectedItem;
  NSInteger selectedRow;
	// Finder
	FindInProjectController *finder;
  NSInteger currentHighlightedPDFSearchResult;
  
  NSOutlineView *projectOutlineView;
  NSTabView *controlsTabview;
  OpenDocumentsManager *openDocuments;
  ProjectItemTreeController *projectItemTreeController;
  TeXEditorViewController *texEditorViewController;
  TPLaTeXEngine *engine;
  NSPopUpButton *projectTypeSelector;
  NSMutableArray *pdfSearchResults;
  NSView *texEditorContainer;
  TPImageViewerController *imageViewerController;
  NSView *imageViewerContainer;
  TPStatusView *statusView;
  TPFileMonitor *fileMonitor;
}

@property (assign) IBOutlet TPStatusView *statusView;
@property (retain) ProjectEntity *project;
@property (assign) IBOutlet NSOutlineView *projectOutlineView;
@property (assign) IBOutlet NSTabView *controlsTabview;
@property (assign) IBOutlet OpenDocumentsManager *openDocuments;
@property (assign) IBOutlet	ProjectItemTreeController *projectItemTreeController;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (retain) TPLaTeXEngine *engine;
@property (retain) NSMutableArray *pdfSearchResults;
@property (assign) IBOutlet NSView *texEditorContainer;
@property (assign) IBOutlet NSView *imageViewerContainer;
@property (retain) TPImageViewerController *imageViewerController;
@property (assign) IBOutlet NSPopUpButton *projectTypeSelector;
@property (assign) IBOutlet PDFView *pdfView;
@property (retain) TPFileMonitor *fileMonitor;

+ (TeXProjectDocument*) newTeXnicleProject;
+ (void) createTeXnicleProjectAtURL:(NSURL*)aURL;
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
- (void)locateItemDidEnd:(NSSavePanel*)savePanel 
              returnCode:(NSInteger)returnCode
             contextInfo:(void*)context;

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

- (BOOL) canViewPDF;
- (BOOL) canTypeset;
- (BOOL) canBibTeX;



#pragma mark - 
#pragma mark Files and Folders

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem;
- (IBAction)selectTab:(id)sender;
- (IBAction) selectNextTab:(id)sender;
- (IBAction) selectPreviousTab:(id)sender;

- (IBAction) addExistingFile:(id)sender;
- (IBAction) addExistingFolder:(id)sender;
- (IBAction) addNewFolder:(id)sender;
- (IBAction) addExistingFileToSelectedFolder:(id)sender;

- (IBAction) showNextResult:(id)sender;
- (IBAction) searchPDF:(id)sender;
- (void) showDocument;



- (NSArray*)getSelectedItems;
- (IBAction) jumpToMainFile:(id)sender;
- (IBAction) setMainFile:(id)sender;
- (IBAction) openProjectFolderInFinder:(id)sender;
- (NSString*) nameOfSelectedProjectItem;
- (IBAction) closeCurrentTab:(id)sender;
- (IBAction) newFolder:(id)sender;
- (IBAction) newFile:(id)sender;
- (IBAction) endNewFileSheet:(id)sender;
- (void)newFileExists:(NSAlert *)alert code:(int)choice context:(void *)v;
- (void) makeNewFile;
- (IBAction) newTeXFile:(id)sender;
- (void) showTemplatesSheet;
- (void) templateSelectionChanged:(NSNotification*)aNote;
- (IBAction) addNewTemplate:(id)sender;
- (IBAction) endTemplateSheet:(id)sender;
- (void)newTexFileExists:(NSAlert *)alert code:(int)choice context:(void *)v;
- (void) makeNewTexFileFromTemplate;
- (void) addNewArticleMainFile;
- (IBAction) newMainTeXFile:(id)sender;
- (IBAction) deleteItem:(id)sender;
- (BOOL) canAddNewFile;
- (BOOL) canAddNewTeXFile;
- (BOOL) canAddNewFolder;
- (BOOL) canRemove;
- (NSManagedObject*) addFileAtURL:(NSURL*)aURL copy:(BOOL)copyFile;

+ (NSString*) newArticleMainFileCode;

#pragma mark -
#pragma mark Saving

- (BOOL) saveAllProjectFiles;

@end
