// MODIFIED VERSION OF BELOW CODE FOR USE IN TEXNICLE
//
//  ESTreeController.h
//  SortedTree
//
//  Created by Jonathan Dann on 14/05/2008.
//
// Copyright (c) 2008 Jonathan Dann
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "Sorted Tree" by Jonathan Dann" will do.

#import <Cocoa/Cocoa.h>

#import "NSTreeController_Extensions.h"
#import "ProjectItemEntity.h"
#import "ProjectEntity.h"
#import "FolderEntity.h"
#import "OpenDocumentsManager.h"
#import "externs.h"

extern NSString * const OutlineViewNodeType;


@class TeXProjectDocument;
@class TeXFileEntity;
@class TPOutlineView;

@interface ProjectItemTreeController : NSTreeController <NSOutlineViewDataSource, NSOutlineViewDelegate> {
	
	TeXProjectDocument *__unsafe_unretained document;
	ProjectEntity *__unsafe_unretained project;
	IBOutlet TPOutlineView *outlineView;
	IBOutlet OpenDocumentsManager *openDocumentsManager;
	ProjectItemEntity *lastInserted;
	
	// Add existing file
	IBOutlet NSWindow *addExistingFileSheet;
	IBOutlet NSButton *copyExistingFileCheckbox;
	IBOutlet NSTextField *copyFileLabel;
	IBOutlet NSTextField *toFolderLabel;
	
	// Add existing files
	IBOutlet NSWindow *addExistingFilesSheet;
	IBOutlet NSButton *copyExistingFilesCheckbox;
	IBOutlet NSTextField *destinationFolderLabel;
	NSMutableArray *filesToAdd;
	
	FolderEntity *selectedFolder;
	
	// Add existing folder
	IBOutlet NSWindow *addExistingFolderSheet;
	IBOutlet NSTextField *folderToImportLabel;
	IBOutlet NSTextField *dstFolderLabel;
	IBOutlet NSButton *copyExistingFolderCheckbox;
	IBOutlet NSButton *includeTeXFilesCheckbox;
	IBOutlet NSButton *includeAllFilesCheckbox;
	IBOutlet NSButton *includeRecursivelyCheckbox;
	
	IBOutlet NSWindow *addingFilesSheet;
	IBOutlet NSTextField *addingFileLabel;
	IBOutlet NSTextField *filesAddedCountLabel;
	IBOutlet NSButton *finishedAddingFilesBtn;
	int recurseCount;
	int filesAddedCounter;
	
	BOOL isDeleting;
	BOOL dragEnabled;
}

@property (readwrite, assign) BOOL isDeleting;
@property (assign) BOOL dragEnabled;

@property (readwrite, unsafe_unretained) IBOutlet TeXProjectDocument *document;
@property (readwrite, unsafe_unretained) ProjectEntity *project;

- (void)updateSortOrder;

- (void) selectDocument:(FileEntity*)aDoc;
- (void) selectItem:(ProjectItemEntity*)aDoc;
- (NSArray *)treeNodeSortDescriptors;


#pragma mark -
#pragma mark File management

- (NSString*)pathForInsertion;
- (BOOL) makeFolderOnDisk:(NSString*)aPath;
- (BOOL) makeFileOnDisk:(NSString*)aPath withContents:(NSData*)data overwrite:(BOOL)overwrite;

#pragma mark - 
#pragma mark  Control

- (void) renameItemAtRow:(NSInteger)row;

- (void) addItems:(NSArray*)items;
- (void) addItemsInFolder:(FolderEntity*)aFolder;
- (void) addFile:(FileEntity*)aFile;

// Remove a file
- (void) removeFile:(FileEntity*)aFile;

- (void) removeItems:(NSArray*)items;
- (void) removeItemsInFolder:(FolderEntity*)aFolder;

- (void) promptForSaveForItem:(FileEntity*)aFile;
- (void)removeItemsAlertEnded:(NSAlert *)alert 
												 code:(int)choice 
											context:(void *)v;

- (void) addNewFolder;
- (void) addNewFolderCreateOnDisk;
- (FolderEntity*) addFolder:(NSString*)aName
							 withFilePath:(NSString*)filepath 
							 createOnDisk:(BOOL)create;
- (FileEntity*) addNewFile:(NSString*)name 
								atFilepath:(NSString*)aFilepath 
								 extension:(NSString*)extension
										isText:(BOOL)textFile 
											code:(NSString*)codeStr 
								asMainFile:(BOOL)main 
							createOnDisk:(BOOL)create;

#pragma mark -
#pragma mark Add existing file
- (void) addExistingFile:(id)sender toFolder:(FolderEntity*)aFolder;
- (IBAction) endAddExistingFileSheet:(id)sender;
- (IBAction) endAddExistingFilesSheet:(id)sender;
- (FileEntity*) addFileAtPath:(NSString*)aPath toFolder:(FolderEntity*)aFolder copy:(BOOL)copyFile;
- (void) addFiles:(NSArray*)files withContext:(void*)context;


#pragma mark -
#pragma mark Add existing Folder

- (void) addExistingFolder:(id)sender;
- (void) showFolderImportSheetForPath:(NSString*)path;
- (IBAction) endAddExistingFolderSheet:(id)sender;
- (FolderEntity*) addFolderAtPath:(NSString*)srcFolder includeTeXFiles:(BOOL)texFiles includeAllFiles:(BOOL)allFiles recursive:(BOOL)recursively;
- (IBAction) endAddingFilesSheet:(id)sender;

@end
