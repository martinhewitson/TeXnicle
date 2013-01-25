// MODIFIED VERSION OF BELOW CODE FOR USE IN TEXNICLE
//
// Based On:
//
//  ESTreeController.m
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

#import "ProjectItemTreeController.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"
#import "ImageAndTextCell.h"
#import "FileEntity.h"
#import "FolderEntity.h"
#import "TeXFileEntity.h"
#import "NSString+Comparisons.h"
#import "ConsoleController.h"
#import "NSFileManager+TeXnicle.h"
#import "TPOutlineView.h"
#import "MHFileReader.h"
#import "NSString+FileTypes.h"

@interface ProjectItemTreeController (Private)
- (void)updateSortOrderOfModelObjects;
@end

@implementation ProjectItemTreeController (Private)

- (void)updateSortOrderOfModelObjects
{
//  NSLog(@"Update sort order...");
	int count = 0;
	for (NSTreeNode *node in [self flattenedNodes]) {
//    [[node representedObject] setPrimitiveValue:[NSNumber numberWithInt:count] forKey:@"sortIndex"];
		[[node representedObject] setValue:@(count) forKey:@"sortIndex"];
//    NSLog(@"Set %@", [node representedObject]);
		count++;
	}
}





@end

@interface ProjectItemTreeController ()

@property (strong) NSMutableArray *filesToAdd;
@property (strong) FolderEntity *selectedFolder;

@property (assign) IBOutlet TPOutlineView *outlineView;

// Add existing file
@property (assign) IBOutlet NSWindow *addExistingFileSheet;
@property (assign) IBOutlet NSButton *doCopyExistingFileCheckbox;
@property (assign) IBOutlet NSTextField *doCopyFileLabel;
@property (assign) IBOutlet NSTextField *toFolderLabel;

// Add existing files
@property (assign) IBOutlet NSWindow *addExistingFilesSheet;
@property (assign) IBOutlet NSButton *doCopyExistingFilesCheckbox;
@property (assign) IBOutlet NSTextField *destinationFolderLabel;

// Add existing folder
@property (assign) IBOutlet NSWindow *addExistingFolderSheet;
@property (assign) IBOutlet NSTextField *folderToImportLabel;
@property (assign) IBOutlet NSTextField *dstFolderLabel;
@property (assign) IBOutlet NSButton *doCopyExistingFolderCheckbox;
@property (assign) IBOutlet NSButton *includeTeXFilesCheckbox;
@property (assign) IBOutlet NSButton *includeAllFilesCheckbox;
@property (assign) IBOutlet NSButton *includeRecursivelyCheckbox;

@property (assign) IBOutlet NSWindow *addingFilesSheet;
@property (assign) IBOutlet NSTextField *addingFileLabel;
@property (assign) IBOutlet NSTextField *filesAddedCountLabel;
@property (assign) IBOutlet NSButton *finishedAddingFilesBtn;

@end

// Declare a string constant for the drag type - to be used when writing and retrieving pasteboard data...

NSString * const OutlineViewNodeType = @"OutlineViewNodeType";
NSString * const TableViewNodeType = @"TableViewNodeType";
NSString * const TPTreeSelectionDidChange = @"TPTreeSelectionDidChange";
NSString * const TPDocumentWasRenamed = @"TPDocumentWasRenamed";

@implementation ProjectItemTreeController

- (void) tearDown
{
//  NSLog(@"Tear down %@", self);
	NSError *error = nil;
	BOOL success = [self fetchWithRequest:nil merge:YES error:&error];
	if (success == NO) {
		[NSApp presentError:error];
		return;
	}
  
  [self unbind:@"managedObjectContext"];
  self.managedObjectContext = nil;
  self.openDocumentsManager = nil;
  self.document = nil;
  
  self.filesToAdd = nil;
  self.selectedFolder = nil;
  
  self.outlineView.dataSource = nil;
  self.outlineView.delegate = nil;
  self.outlineView = nil;
  
  // Add existing file
  self.addExistingFileSheet = nil;
  self.doCopyExistingFileCheckbox = nil;
  self.doCopyFileLabel = nil;
  self.toFolderLabel = nil;
  
  // Add existing files
  self.addExistingFilesSheet = nil;
  self.doCopyExistingFilesCheckbox = nil;
  self.destinationFolderLabel = nil;
  
  // Add existing folder
  self.addExistingFolderSheet = nil;
  self.dstFolderLabel = nil;
  self.doCopyExistingFolderCheckbox = nil;
  self.includeTeXFilesCheckbox = nil;
  self.includeAllFilesCheckbox = nil;
  self.includeRecursivelyCheckbox = nil;
  
  self.addingFilesSheet = nil;
  self.addingFileLabel = nil;
  self.filesAddedCountLabel = nil;
  self.finishedAddingFilesBtn = nil;
  
}

- (void)updateSortOrder
{
  [self updateSortOrderOfModelObjects];
}

- (NSManagedObject *)project
{
	if (_project != nil) {
		return _project;
	}
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *fetchError = nil;
	NSArray *fetchResults;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project"
																						inManagedObjectContext:moc];
	
	[fetchRequest setEntity:entity];
	fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
	
	if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil)) {
		_project = fetchResults[0];
		return _project;
	}
	
	if (fetchError != nil) {
		[NSApp presentError:fetchError];
	}
	else {
		// should present custom error message...
	}
	return nil;
}

- (void) awakeFromNib
{
  self.dragEnabled = YES;
  
	// Set the outline view to accept the custom drag type OutlineViewNodeType...
	[self.outlineView registerForDraggedTypes:@[OutlineViewNodeType,TableViewNodeType,NSFilenamesPboardType]];
	// apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:YES];
	[imageAndTextCell setImage:[NSImage imageNamed:NSImageNameFolderBurnable]];
	[tableColumn setDataCell:imageAndTextCell];
  
	[self.outlineView setSortDescriptors:[self treeNodeSortDescriptors]];

	// make sure we have loaded all items before we try to observe them
	NSError *error = nil;
	BOOL success = [self fetchWithRequest:nil merge:YES error:&error];
	if (success == NO) {
		[NSApp presentError:error];
		return;
	}		
	self.filesToAdd = [[NSMutableArray alloc] init];
	
	[super awakeFromNib];
}

- (void) dealloc
{
//  NSLog(@"Dealloc %@", self);
}

#pragma mark -
#pragma mark  Project control

- (void) selectDocument:(FileEntity*)aDoc
{
	NSTreeNode *node = [self treeNodeForObject:aDoc];
	[self setSelectionIndexPath:[node indexPath]];
}

- (void) selectItem:(ProjectItemEntity*)aDoc
{
	NSTreeNode *node = [self treeNodeForObject:aDoc];
	[self setSelectionIndexPath:[node indexPath]];
}

#pragma mark -
#pragma mark File management

- (NSString*)pathForInsertion
{
	NSIndexPath *insertionPath = [[self indexPathForInsertion] indexPathByRemovingLastIndex];
//	NSLog(@"Insertion path: %@", insertionPath);
	NSTreeNode *node = [self nodeAtIndexPath:insertionPath];
//	NSLog(@"Node: %@", node);
	NSString *pathOnDisk = nil;
	NSString *projectFolder = [[self project] folder];
	if (projectFolder) {
		pathOnDisk = [NSString stringWithString:projectFolder];
	} else {
		pathOnDisk = [NSString stringWithString:[[[self.document fileURL] path] stringByDeletingLastPathComponent]];
	}
	
	// See if we can get a better folder path for insertion
	if (node) {
//		NSLog(@"Node for %@", [node representedObject]);
		
		NSString *path = [[node representedObject] valueForKey:@"pathOnDisk"];
		if (path) {
			pathOnDisk = [NSString stringWithString:path];
		}
	}
	
	return pathOnDisk;
}

- (BOOL) makeFolderOnDisk:(NSString*)aPath
{
	//NSLog(@"Creating %@", pathOnDisk);
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;	
	BOOL success = [fm createDirectoryAtPath:aPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
	
	if (success == NO) {
		[NSApp presentError:error];
		return NO;
	}
	
	return YES;
}

- (BOOL) makeFileOnDisk:(NSString*)aPath withContents:(NSData*)data overwrite:(BOOL)overwrite
{

	NSFileManager *fm = [NSFileManager defaultManager];
	// Check if the file already exists on disk
	if (![fm fileExistsAtPath:aPath] || overwrite) {		
		// otherwise we need to make the file on disk
		if (![fm createFileAtPath:aPath contents:data attributes:nil]) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:[NSString stringWithFormat:@"Failed to write file"]];
			[alert setInformativeText:[NSString stringWithFormat:@"It was not possible to create a new file at %@", aPath]];
			[alert setAlertStyle:NSWarningAlertStyle];		
			[alert runModal];
			//			[[self managedObjectContext] deleteObject:object];
			return NO;
		}
	} else {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"File Exists"]];
    [alert setInformativeText:[NSString stringWithFormat:@"A file already exists at %@", aPath]];
    [alert setAlertStyle:NSWarningAlertStyle];		
    [alert runModal];
    
//		NSLog(@"File exists at %@", aPath);
	}	
	
	return YES;
}


#pragma mark -
#pragma mark Item Control

// rename items
- (void) renameItemAtRow:(NSInteger)row
{
	[self.outlineView editColumn:0 row:row withEvent:nil select:YES];
}

// Add a new folder to the project
- (void) addNewFolder
{
	NSString *folderName = [NSString stringWithFormat:@"New Folder %02lu", [[self flattenedContent] count]];
	[self addFolder:folderName withFilePath:nil createOnDisk:NO];
}

// Add a new folder to the project and create on disk
- (void) addNewFolderCreateOnDisk
{
	NSString *folderName = [NSString stringWithFormat:@"New Folder %02lu", [[self flattenedContent] count]];
	[self addFolder:folderName withFilePath:nil createOnDisk:YES];
}


// Add a folder to the project with the given name and filepath, and create on disk if requested.
- (FolderEntity*) addFolder:(NSString*)aName withFilePath:(NSString*)filepath createOnDisk:(BOOL)create
{
	NSManagedObjectContext *moc = [self managedObjectContext];	
	NSEntityDescription *newFolderEntity = [NSEntityDescription entityForName:@"Folder"
																											inManagedObjectContext:moc];
	
	FolderEntity *newFolder = [[FolderEntity alloc] initWithEntity:newFolderEntity
                                  insertIntoManagedObjectContext:moc];
	
	// set name
  [newFolder setValue:aName forKey:@"name"];
  
  // set project
  [newFolder setValue:self.project forKey:@"project"];
  	
	// set parent
	id parent = [[self selectedObjects] firstObject];
  // if the parent is a file, get its parent
  if ([parent isKindOfClass:[FileEntity class]]) {
    parent = [parent valueForKey:@"parent"];
  }
	if (parent) {
		[newFolder setParent:parent];
    NSTreeNode *parentNode = [self treeNodeForObject:parent];
    // expand parent
    [self.outlineView expandItem:parentNode];
	}
  
  if (parent == nil) {
    [newFolder setFilepath:[@"." stringByAppendingPathComponent:aName]];
  }
  
  [newFolder resetFilePath];
  if (create) {
    
    // we create inside the parent folder, or in the project root
    FolderEntity *parentFolder = (FolderEntity*)parent;
    NSString *newPath = nil;
    if ([parentFolder pathOnDisk]) {
      newPath = [[parentFolder pathOnDisk] stringByAppendingPathComponent:newFolder.name];
    } else {
      // project root
      newPath = [[newFolder.project folder] stringByAppendingPathComponent:newFolder.name];
    }
    
    if (newPath) {
      NSFileManager *fm = [NSFileManager defaultManager];
      if (![fm fileExistsAtPath:newPath]) {
        [fm createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:NULL];
      }
    }
  }
  
	// console log
	[[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Added Folder: %@", aName]];
	
	// update sort order
	[self updateSortOrderOfModelObjects];
  
	// select the new folder
  [self performSelector:@selector(selectItem:) withObject:newFolder afterDelay:0.1];
	  
	// This is now managed by the controller so we can release it here
	return newFolder;				
}

- (NSManagedObject*) addNewFile:(NSString*)name 
										 atFilepath:(NSString*)aFilepath 
											extension:(NSString*)extension
												 isText:(BOOL)textFile 
													 code:(NSString*)codeStr 
										 asMainFile:(BOOL)main 
									 createOnDisk:(BOOL)create
{
  // we should check if we already have a file with this path:
  for (NSManagedObject *item in [self.project valueForKey:@"items"]) {
    NSString *itemPath = [item valueForKey:@"pathOnDisk"];
    if ([itemPath isEqualToString:aFilepath] && [[item valueForKey:@"name"] isEqualToString:name]) {
      // then there already exists an item in the project. Ask the user if they want to add a copy.
			NSAlert *alert = [NSAlert alertWithMessageText:@"File already exists in project" 
                                       defaultButton:@"NO" 
                                     alternateButton:@"YES" 
                                         otherButton:nil 
                           informativeTextWithFormat:@"The file %@ already exists in the project. Do you want to add it again?", name];
			NSInteger result = [alert runModal];
      if (result == NSAlertDefaultReturn) {
        return nil;
      }
      
    }
  }
  
  
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	if (!extension) 
		extension = [name pathExtension];
	
	FileEntity *newFile;
	NSEntityDescription *entity = nil;
	if ([extension isEqual:@"tex"]) {
		entity = [NSEntityDescription entityForName:@"TeXFile" inManagedObjectContext:moc];
	} else {
		entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc];		
	}
	
	newFile = [[FileEntity alloc] initWithEntity:entity
                insertIntoManagedObjectContext:moc];
  
	// set the parent object
	id parent = [[self selectedObjects] firstObject];
	if (parent) {
    if ([parent isKindOfClass:[FileEntity class]]) {
//      NSLog(@"Getting parent of selected file: %@", [parent valueForKey:@"name"]);
      parent = [parent valueForKey:@"parent"];
//      NSLog(@"... got parent folder: %@", [parent valueForKey:@"name"]);
    }
		[newFile setParent:parent];
	} else {
    
  }
  
	[moc processPendingChanges];
	
  
	if (codeStr && ![codeStr isEqual:@""]) {
		NSData *data = [codeStr dataUsingEncoding:[MHFileReader defaultEncoding]];
		[newFile setValue:data forKey:@"content"];
	} else {
		[newFile setValue:[@"" dataUsingEncoding:[MHFileReader defaultEncoding]] forKey:@"content"];
	}
		 
	// set project
	[newFile setValue:[self project] forKey:@"project"];
	
	// set name
	[newFile setValue:name forKey:@"name"];
	
	// set isText
	[newFile setValue:@(textFile) forKey:@"isText"];
	
	// set extension
	if (extension) {
		[newFile setValue:extension forKey:@"extension"];
	} else {
		[newFile setValue:[name pathExtension] forKey:@"extension"];
	}
		
	// configure the textstorage
	[newFile reconfigureDocument];	
	
	// set as main file if necessary	
	if (main) {
		[[self project] setValue:newFile forKey:@"mainFile"];
	}
	
	// Set the filepath to the given one, or to the path in the project
	if (aFilepath) {
		[newFile setValue:aFilepath forKey:@"filepath"];
	} else {
		// Check the proposed project path to see that it exists on disk
		NSString *projectPath = [newFile projectPath];
		NSString *proposedFolder = [projectPath stringByDeletingLastPathComponent];
//		NSLog(@"Checking proposed folder %@", proposedFolder);
		NSString *projFolder = [[self project] folder];
		NSString *newFilepath = nil;
		if (projFolder) {
			newFilepath = [projFolder stringByAppendingPathComponent:name];
		}
		if ([NSFileManager directoryExists:proposedFolder] || !newFilepath) {
			newFilepath = projectPath;
		}
		[newFile setValue:newFilepath forKey:@"filepath"];
	}
	
	
	// Now make the file on disk
	if (create) {
		[self makeFileOnDisk:[newFile valueForKey:@"pathOnDisk"] withContents:[newFile valueForKey:@"content"] overwrite:YES];
	}

	// set file load data
	[newFile setValue:[NSDate date] forKey:@"fileLoadDate"];
	[newFile setValue:[NSDate date] forKey:@"lastEditDate"];
		
//	NSLog(@"New file %@", newFile);
	
	// select the new file
	[self selectItem:newFile];
	
	// and update the sort order
	[self updateSortOrderOfModelObjects];

	// console message
	[[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Added File: %@", [newFile valueForKey:@"filepath"]]];
	
//	NSLog(@"Added object: %@", newFile);
	
	return newFile;				
}




#pragma mark -
#pragma mark Add Existing Folder 

- (void) addExistingFolder:(id)sender
{
	// get user to choose file
	NSOpenPanel *openPanel = [NSOpenPanel openPanel]; 
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanCreateDirectories:NO];
  
  [openPanel beginSheetModalForWindow:[self.document windowForSheet]
                    completionHandler:^(NSInteger result) {
                      if (result == NSCancelButton) 
                        return;
                      
                      [openPanel orderOut:self];
                      
                      // get folder name from user
                      NSString *path = [[openPanel URL] path];	
                      [self showFolderImportSheetForPath:path];	
                    }];
}


- (void) showFolderImportSheetForPath:(NSString*)path
{
	NSString *dstfolderPath = nil;
	
	// set folder to the selected folder
	NSArray *selectedObjects = [self selectedObjects];
	//NSLog(@"Selected: %@", selectedObjects);
	if ([selectedObjects count] == 1) {
		ProjectItemEntity *item = selectedObjects[0];
		if ([item isKindOfClass:[FolderEntity class]]) {
			dstfolderPath = [item valueForKey:@"pathOnDisk"];
		}
	}
	if (!dstfolderPath) {
		// set it to project path 
		dstfolderPath = [[self project] valueForKey:@"folder"];
	}
	
	[self.folderToImportLabel setStringValue:path];
	[self.dstFolderLabel setStringValue:dstfolderPath];
	
	//	[copyFileLabel setStringValue:path];
	//	[toFolderLabel setStringValue:dstfolderPath];
	
	// prompt user to include files and folders recursively in to selected folder or project folder, or not
	
	[NSApp beginSheet:self.addExistingFolderSheet
		 modalForWindow:[self.document windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
}


- (IBAction) endAddExistingFolderSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:self.addExistingFolderSheet];
		[self.addExistingFolderSheet orderOut:sender];
		return;
	}
	
	
	// copy file, or not
	BOOL copyFolder = [self.doCopyExistingFolderCheckbox state];
	BOOL includeTeXFiles = [self.includeTeXFilesCheckbox state];
	BOOL includeAllFiles = [self.includeAllFilesCheckbox state];
	BOOL includeRecursively = [self.includeRecursivelyCheckbox state];
	
	// add to project
	NSString *srcfolder = [self.folderToImportLabel stringValue];
	NSString *containerFolder = [self.dstFolderLabel stringValue];
	NSString *dstfolder = nil;
	
	NSError *error = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	if (copyFolder) {
		dstfolder = [containerFolder stringByAppendingPathComponent:[srcfolder lastPathComponent]];
//		NSLog(@"copying %@ to %@", srcfolder, dstfolder);
		if (![srcfolder isEqual:dstfolder]) {
			
			// check if the folder already exists
			BOOL copyFolderConfirmed = YES;
			if ([NSFileManager directoryExists:dstfolder]) {
				
				// prompt the user
				NSAlert *alert = [NSAlert alertWithMessageText:@"Overwrite?"
																				 defaultButton:@"OK" alternateButton:@"Cancel"
																					 otherButton:nil 
														 informativeTextWithFormat:@"The directory \u201c%@\u201d already exists. Do you want to overwrite it?", dstfolder
													]; 
				
				NSInteger result = [alert runModal];
				if (result == NSAlertAlternateReturn) {
					copyFolderConfirmed = NO;
				}
				
			}
			// if the folder doesn't exist or the user confirms overwrite, go ahead and copy
			if (copyFolderConfirmed) {
				BOOL success = [fm copyItemAtPath:srcfolder
                                   toPath:dstfolder 
                                    error:&error];
				if (success == NO) {
					[NSApp presentError:error];
					return;
				}
			}
		} else {
			//NSLog(@"Destination is same as source for %@", filepath);
		}
	} else {
		dstfolder = srcfolder;
	}
	
	[NSApp endSheet:self.addExistingFolderSheet];
	[self.addExistingFolderSheet orderOut:sender];
	
	
	[self.finishedAddingFilesBtn setEnabled:NO];
	
	[NSApp beginSheet:self.addingFilesSheet
		 modalForWindow:[self.document windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
//	NSLog(@"Adding file %@ to %@", dstfolder, containerFolder);
	recurseCount = 0;
	filesAddedCounter = 0;
		
	[self addFolderAtPath:dstfolder includeTeXFiles:includeTeXFiles includeAllFiles:includeAllFiles recursive:includeRecursively];
	
	NSSound *systemSound = [NSSound soundNamed:@"Glass"];
	[systemSound play];
	[self.finishedAddingFilesBtn setEnabled:YES];
	
	return;	
}	

- (IBAction) endAddingFilesSheet:(id)sender
{
	[NSApp endSheet:self.addingFilesSheet];
	[self.addingFilesSheet orderOut:sender];
	
}

- (FolderEntity*) addFolderAtPath:(NSString*)srcFolder 
				 includeTeXFiles:(BOOL)texFiles 
				 includeAllFiles:(BOOL)allFiles 
							 recursive:(BOOL)recursively
{
	
	NSArray *skipFiles = @[@"CVS"];
	
	recurseCount++;
	
	if (recurseCount>1000) {
		NSLog(@"Recursion limit exceeded!");
		return nil;
	}
	
//	NSLog(@"%d: Adding folder: %@", recurseCount, srcFolder);
	
	// add the file to the project	
	FolderEntity *newFolder = [self addFolder:[srcFolder lastPathComponent]
																	withFilePath:srcFolder
																	createOnDisk:NO];
	

	// Keep the current insertion path because the path with change when objects are inserted
	// but we want all objects to be inserted at this path.
//	NSIndexPath *insertPath = [self indexPathForInsertion];
	
	// get a directory listing
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *contents = [fm contentsOfDirectoryAtPath:srcFolder
																							error:&error];
	
	if (contents == nil) {
		[NSApp presentError:error];
	} else {
		
		for (NSString *diritem in contents) {
			
			NSString *itempath = [srcFolder stringByAppendingPathComponent:diritem];
			
//			NSLog(@"Examining %@", itempath);
			
			// Skip unwanted files and folders
			if ([[itempath lastPathComponent] hasPrefix:@"."] || 
					[skipFiles containsObject:[itempath lastPathComponent]])
				continue;
			
			// Look at the file we are adding
			NSString *fileType = [NSFileManager fileTypeAtPath:itempath];
			
			BOOL isFolder = NO;
			BOOL isTeXFile = NO;
			BOOL isFile = NO;
			
			if ([fileType isEqual:NSFileTypeRegular]) {
				isFile = YES;
				NSString *ext = [itempath pathExtension];
				NSArray *textExtensions = @[@"tex"];
				if ([textExtensions containsObject:ext]) {
					isTeXFile = YES;
				}
			}			
			if ([fileType isEqual:NSFileTypeDirectory]) {
				isFolder = YES;
			}
			
			BOOL added = NO;
			if (isFolder && recursively) {
				FolderEntity *newSubFolder = [self addFolderAtPath:itempath includeTeXFiles:texFiles includeAllFiles:allFiles recursive:recursively];
				[newSubFolder setParent:newFolder];
				added = YES;
			} else if (isFile && allFiles) {
				FileEntity *newFile = [self addFileAtPath:itempath toFolder:newFolder copy:NO];
				[newFile setParent:newFolder];
				added = YES;
			} else if (isTeXFile && texFiles) {
				FileEntity *newFile = [self addFileAtPath:itempath toFolder:newFolder copy:NO];
				[newFile setParent:newFolder];
				added = YES;
			}
			
			if (added) {
				filesAddedCounter++;
				[self.addingFileLabel setStringValue:itempath];
				[self.addingFileLabel display];
				[self.filesAddedCountLabel setIntValue:filesAddedCounter];
				[self.filesAddedCountLabel display];
			}			
			
			// now make sure we select the folder again otherwise the insertion doesn't work
			[self setSelectionIndexPath:[self indexPathToObject:newFolder]];
			
		}
	}
	
	return newFolder;
}


#pragma mark -
#pragma mark Add Existing File

- (void) addExistingFile:(id)sender toFolder:(FolderEntity*)aFolder
{
	// get user to choose file
	NSOpenPanel *openPanel = [NSOpenPanel openPanel]; 
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanCreateDirectories:NO];
	
//	NSArray *fileTypes = [NSArray arrayWithObjects:@"txt", @"text",
//                        NSFileTypeForHFSTypeCode( 'TEXT' ), @"tex", nil];
//	[openPanel setAllowedFileTypes:fileTypes];
	
	self.selectedFolder = aFolder;
	
  [openPanel beginSheetModalForWindow:[self.document windowForSheet]
                    completionHandler:^(NSInteger result) {
                      if (result == NSCancelButton) 
                        return;
                      
                      [openPanel orderOut:self];
                      
                      NSMutableArray *filenames = [NSMutableArray array];
                      for (NSURL *url in [openPanel URLs]) {
                        [filenames addObject:[url path]];
                      }
                      [self addFiles:filenames withContext:(__bridge void *)(self.selectedFolder)];
                    }];
}

- (void) addFiles:(NSArray*)files withContext:(void*)context
{
	// get file name from user
	[self.filesToAdd removeAllObjects];
	[self.filesToAdd addObjectsFromArray:files];
	if ([self.filesToAdd count] == 0) 
		return;
	
//	NSLog(@"Adding files: %@", filesToAdd);
	
	NSString *folderPath = nil;
	id passed = (__bridge id)(context);
//	NSLog(@"Passed folder: %@", passed);
	if (passed) {
		//NSLog(@"Passed context %@", passed);
		if ([passed isKindOfClass:[FolderEntity class]]) {
			FolderEntity *folder = (__bridge FolderEntity *)(context);
			folderPath = [folder projectPath];
		}
	} 
	
	// check if the folder path exists on disk
	BOOL folderExists = [NSFileManager directoryExists:folderPath];
	
	if (!folderPath || !folderExists) {
		// set it to project path insertion point
		folderPath = [[self project] valueForKey:@"folder"];
//		NSLog(@"Project folder:%@", folderPath);
		
		// we can fall back to the insertion path if it exists on disk
		NSString *insertionPath = [self pathForInsertion];
//		NSLog(@"Insertion path:%@", insertionPath);
		if ([NSFileManager directoryExists:insertionPath]) {
			folderPath = insertionPath;
		}
	}
	
//	NSLog(@"Adding to folder:%@", folderPath);
	
	
	if ([self.filesToAdd count]==1) {
		
		NSString *path = self.filesToAdd[0];
		
		
		[self.doCopyFileLabel setStringValue:path];
		[self.toFolderLabel setStringValue:folderPath];
		
		// prompt user to copy file in to selected folder or project folder, or not
//		NSLog(@"Starting sheet %@ on %@", addExistingFileSheet, self.document);
		[NSApp beginSheet:self.addExistingFileSheet
			 modalForWindow:[self.document windowForSheet]
				modalDelegate:self
			 didEndSelector:NULL
					contextInfo:NULL];
		
		
	} else {
		// Multiple files
		
		[self.destinationFolderLabel setStringValue:folderPath];
		
		[NSApp beginSheet:self.addExistingFilesSheet
			 modalForWindow:[self.document windowForSheet]
				modalDelegate:self
			 didEndSelector:NULL
					contextInfo:NULL];
	}
}


- (IBAction) endAddExistingFilesSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:self.addExistingFilesSheet];
		[self.addExistingFilesSheet orderOut:sender];
		return;
	}
	
	BOOL copyFile = NO;
	if ([self.doCopyExistingFilesCheckbox state]==NSOnState) {
		copyFile = YES;
	}
	
	NSIndexPath *selected = [self selectionIndexPath];
	for (NSString *file in self.filesToAdd) {		
		[self setSelectionIndexPath:selected];
		[self addFileAtPath:file toFolder:nil copy:copyFile];
	}
	
	[NSApp endSheet:self.addExistingFilesSheet];
	[self.addExistingFilesSheet orderOut:sender];
}


- (IBAction) endAddExistingFileSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:self.addExistingFileSheet];
		[self.addExistingFileSheet orderOut:sender];
		return;
	}
	
	// copy file, or not
	BOOL copyFile = [self.doCopyExistingFileCheckbox state];
	
	// add to project
	NSString *filepath = [self.doCopyFileLabel stringValue];		
	[self addFileAtPath:filepath toFolder:nil copy:copyFile];
		
	[NSApp endSheet:self.addExistingFileSheet];
	[self.addExistingFileSheet orderOut:sender];
}	

- (FileEntity*) addFileAtPath:(NSString*)aPath toFolder:(FolderEntity*)aFolder copy:(BOOL)copyFile
{
//	NSLog(@"Adding file to project: %@", aPath);
  
	// Look at the file we are adding
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	NSString *projectPath = aPath;
	
  NSDictionary *sourceAttributes = [fm attributesOfItemAtPath:aPath error:&error];
  if (![[sourceAttributes fileType] isEqualToString:NSFileTypeRegular]) {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Source File Error"
                                     defaultButton:@"OK" 
                                   alternateButton:@"Cancel"
                                       otherButton:nil 
                         informativeTextWithFormat:@"The source file at %@ is not a regular file. Aborting.", aPath
                      ]; 
    
    [alert runModal];
    return nil;
  }
  
	// Copy first?
	if (copyFile) {
		
		NSIndexPath *indexPath = [self selectionIndexPath];
		NSString *dstPath = [aFolder projectPath];
		
		if (!dstPath && indexPath) {
			NSManagedObject *item = [[self nodeAtIndexPath:indexPath] representedObject];
			dstPath = [item valueForKey:@"projectPath"];
		} else {
			dstPath = [[self project] valueForKey:@"folder"];
		}
		
//		NSLog(@"Destination path: %@", dstPath);
		
		// it may be that the destination folder doesn't exist on disk, in which 
		// case we need to get the project folder
		if (![NSFileManager directoryExists:dstPath]) {
			NSString *projectFolder = [[self project] folder];
			dstPath = projectFolder;
		}
				
		NSString *fileType = [NSFileManager fileTypeAtPath:dstPath];		
		if ([fileType isEqual:NSFileTypeRegular]) {
			dstPath = [dstPath stringByDeletingLastPathComponent];
		}
		
		dstPath = [dstPath stringByAppendingPathComponent:[aPath lastPathComponent]];

//		NSLog(@"Destination path: %@", dstPath);
		
		if (![aPath isEqual:dstPath]) {
      // check if there exists a file at the destination path
      if ([fm fileExistsAtPath:dstPath]) {
        
        // ask the user if they want to overwrite it
				NSAlert *alert = [NSAlert alertWithMessageText:@"Overwrite?"
																				 defaultButton:@"OK" 
                                       alternateButton:@"Cancel"
																					 otherButton:nil 
														 informativeTextWithFormat:@"A file already exists at %@. Do you want to overwrite it?", dstPath
													]; 
				
				NSInteger result = [alert runModal];
				if (result == NSAlertDefaultReturn) {
          // remove the file at the destination path
          NSError *error = nil;
          BOOL success = [fm removeItemAtPath:dstPath error:&error];
          if (success == NO) {
            [NSApp presentError:error];
            return nil;
          }
				}
        
      }
//			NSLog(@"Copying %@ \nto \n%@", aPath, dstPath); 
			BOOL success = [fm copyItemAtPath:aPath toPath:dstPath error:&error];
			if (success == NO) {
				[NSApp presentError:error];
				return nil;
			}
		}
		aPath = dstPath;	
    projectPath = dstPath;
	}
	
	// read the contents of the source file
	BOOL isTextFile = NO;
  MHFileReader *fr = [[MHFileReader alloc] init];
  NSString *contents = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:aPath]];

  NSString *extension = [aPath pathExtension];
	if ([extension isText]) {
		isTextFile = YES;
	}
	
	// Add to project
	id doc = [self addNewFile:[aPath lastPathComponent]
								 atFilepath:projectPath
									extension:extension
										 isText:isTextFile
											 code:contents
								 asMainFile:NO
							 createOnDisk:NO];
	
	return doc;
}



#pragma mark -
#pragma mark NSController overrides


- (void)insertObject:(id)object atArrangedObjectIndexPath:(NSIndexPath *)indexPath;
{	
//	NSLog(@"InsertObject: %@", object);
	[super insertObject:object atArrangedObjectIndexPath:indexPath];		
	[self updateSortOrderOfModelObjects];	
}

- (void)insertObjects:(NSArray *)objects atArrangedObjectIndexPaths:(NSArray *)indexPaths;
{
	[super insertObjects:objects atArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
}

- (void)removeObjectAtArrangedObjectIndexPath:(NSIndexPath *)indexPath;
{
	//NSLog(@"Remove object");
	[self setIsDeleting:YES];
	[super removeObjectAtArrangedObjectIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
	[self setIsDeleting:NO];
}

- (void)removeObjectsAtArrangedObjectIndexPaths:(NSArray *)indexPaths;
{
	[self setIsDeleting:YES];
	//NSLog(@"Remove objects");
	[super removeObjectsAtArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
	[self setIsDeleting:NO];
}

- (void)moveNode:(NSTreeNode *)node toIndexPath:(NSIndexPath *)indexPath;
{
	[self setIsDeleting:YES];
//	NSLog(@"Move node");
	[super moveNode:node toIndexPath:indexPath];
  
  [self.managedObjectContext processPendingChanges];
  
//  NSLog(@"Updating %@ [%d]", [[node representedObject] valueForKey:@"name"], [[node representedObject] isManaged]);
  if ([[node representedObject] isManaged]) {
    [[node representedObject] resetFilePath];
  }
  
	[self updateSortOrderOfModelObjects];
	[self setIsDeleting:NO];
}

- (void)moveNodes:(NSArray *)nodes toIndexPath:(NSIndexPath *)indexPath;
{
	[self setIsDeleting:YES];
//	NSLog(@"Move Nodes");
	for (NSTreeNode *node in nodes) {
		[self moveNode:node toIndexPath:indexPath];
	}	
	[self setIsDeleting:NO];
}

- (void)add:(id)sender
{
	[super add:sender];
	[[self managedObjectContext] processPendingChanges];
}

- (void)remove:(id)sender
{
	
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete Selected Items?"
																	 defaultButton:@"Delete" alternateButton:@"Cancel"
																		 otherButton:nil 
											 informativeTextWithFormat:@"Do you really want to delete the selected items?"
										]; 
	[alert beginSheetModalForWindow:[self.document windowForSheet]
										modalDelegate:self
									 didEndSelector:@selector(removeItemsAlertEnded:code:context:) 
											contextInfo:NULL];
	
}


- (void)removeItemsAlertEnded:(NSAlert *)alert 
												 code:(int)choice 
											context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
		
    // get a pointer to the selected items
    NSArray *items = [self selectedObjects];
    
    // remove them from the project
		[self setIsDeleting:YES];    
		[super remove:self];
		[self setIsDeleting:NO];
    
    // remove them from the document manager
		[self removeItems:items];
		
    
    // sync selection between tree controller and outline view    
    [self setSelectionIndexPath:[NSIndexPath indexPathWithIndex:[[self.outlineView selectedRowIndexes] firstIndex]]];
		
	} else {
		// do nothing
	}
	
}


// This doesn't actually add the items to the tree-controller. This is intended for 
// use in the undo mechanism and just reinstates the observation and reloads the contents
// of the file from disk.
- (void) addItems:(NSArray*)items
{
	
//	NSLog(@"Adding items: %@", items);
	NSUndoManager *undo = [[self managedObjectContext] undoManager];
	[[undo prepareWithInvocationTarget:self] removeItems:items];
	
	if (![undo isUndoing]) {
		[undo setActionName:@"Add Items"];
	}
	
	for (id item in items) {
		if ([item isKindOfClass:[FileEntity class]]) {
			[self addFile:item];
		}
		if ([item isKindOfClass:[FolderEntity class]]) {
			[self addItemsInFolder:item];
		}
	}
}

// Recursively process the items in the folder
- (void) addItemsInFolder:(FolderEntity*)aFolder
{
	
	for (id item in [aFolder valueForKey:@"children"]) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			[self addFile:item];
		}
		if ([item isKindOfClass:[FolderEntity class]]) {
			[self addItemsInFolder:item];
		}		
	}
}

// This doesn't actually remove the items from the tree-controller. It's just there
// to handle the observation and open document management when files are removed for the
// undo manager.
- (void) removeItems:(NSArray*)items
{
//	NSLog(@"Removing items: %@", items);
	
	
	NSUndoManager *undo = [[self managedObjectContext] undoManager];
	[[undo prepareWithInvocationTarget:self] addItems:items];
		
	if (![undo isUndoing]) {
		[undo setActionName:@"Remove Items"];
	}
	
	// make sure we close the tab
	for (id item in items) {
		// and stop observing file items
		if ([item isKindOfClass:[FileEntity class]]) {
			[self removeFile:item];
		}		
		if ([item isKindOfClass:[FolderEntity class]]) {
			[self removeItemsInFolder:item];
		}
	}
	
}

// Recursively remove items in the folder in an undoable way
- (void) removeItemsInFolder:(FolderEntity*)aFolder
{	
	for (id item in [aFolder valueForKey:@"children"]) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			[self removeFile:item];
		}
		if ([item isKindOfClass:[FolderEntity class]]) {
			[self removeItemsInFolder:item];
		}
	}
}

// Add a file after an undo. This just observes the file again
// and reloads the file contents from disk.
- (void) addFile:(FileEntity*)aFile
{
	// make sure the item has the contents from on disk
	[aFile reloadFromDisk];	
}

// Remove a file
- (void) removeFile:(FileEntity*)aFile
{
//  NSLog(@"Removing file %@", aFile);
	// check if the file has edits
	[self promptForSaveForItem:aFile];
	// remove from document manager
	[self.openDocumentsManager removeDocument:aFile];
	// post message
	[[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Removed %@", [aFile valueForKey:@"filepath"]]];
}

- (void) promptForSaveForItem:(FileEntity*)aFile
{
	if (![aFile existsOnDisk])
		return;
	
	if ([aFile hasEdits]) {
		
		NSAlert *alert = [NSAlert alertWithMessageText:@"Save Edits?"
																		 defaultButton:@"Save" 
																	 alternateButton:@"Continue"
																			 otherButton:nil 
												 informativeTextWithFormat:@"The file \u201c%@\u201d has been edited. Do you want to save it before removing it?", [aFile valueForKey:@"name"]
											]; 
		
		NSInteger res = [alert runModal];
//		NSLog(@"Returned %d", res);
		if (res == NSAlertDefaultReturn) {
			[aFile saveContentsToDisk];
		} else {
			// do nothing
		}
	}
}


#pragma mark -
#pragma mark Outline view delegate methods

// We do editing by context menu. Here we use the double click to open documents.
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item 
{	
  if ([[item representedObject] isKindOfClass:[FolderEntity class]]) {
    return YES;
  }
  
	return NO;
}


- (NSString *)outlineView:(NSOutlineView *)ov 
					 toolTipForCell:(NSCell *)cell 
										 rect:(NSRectPointer)rect 
							tableColumn:(NSTableColumn *)tc 
										 item:(id)item 
						mouseLocation:(NSPoint)mouseLocation
{
	ProjectItemEntity *object = [item representedObject];
	return [object valueForKey:@"filepath"];
//	return [NSString stringWithFormat:@"%@\n%@", [object valueForKey:@"pathOnDisk"], [object valueForKey:@"filepath"]];
}

- (void)outlineView:(NSOutlineView *)anOutlineView 
		willDisplayCell:(id)cell 
		 forTableColumn:(NSTableColumn *)tableColumn 
							 item:(id)item
{

	if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
    CGFloat imageSize = 20.0;
    [anOutlineView setRowHeight:imageSize+2.0];
    
    ProjectItemEntity *object = [item representedObject];
    
    [cell setImageSize:imageSize];
    [cell setTextColor:[NSColor blackColor]];
		
    if ([object isMemberOfClass:[FolderEntity class]]) {
      //    NSLog(@"%@ is a folder", [object name]);
      NSString *pathOnDisk = [object valueForKey:@"pathOnDisk"];
      if (pathOnDisk) {
        if ([[object valueForKey:@"isExpanded"] boolValue]) {
          NSString *folderFileType = NSFileTypeForHFSTypeCode(kOpenFolderIcon);
          [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];
        } else {
          NSString *folderFileType = NSFileTypeForHFSTypeCode(kGenericFolderIcon);
          [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];
        }
      } else {
        if ([[object valueForKey:@"isExpanded"] boolValue]) {
          [cell setImage:[NSImage imageNamed:@"groupFolderOpen"]];
        } else {
          [cell setImage:[NSImage imageNamed:@"groupFolder"]];
        }
      }
    } else if ([object isKindOfClass:[FileEntity class]]) {
      //    NSLog(@"%@ is a file", [object name]);
      
      if ([[(FileEntity*)object valueForKey:@"isText"] boolValue]) {
        BOOL dirty = [object hasEdits];
        if (dirty) {
          [cell setTextColor:[NSColor lightGrayColor]];
        }
      }
      
      if(![object existsOnDisk]) {
        [cell setTextColor:[NSColor redColor]];
      }	
      
      NSString *ext = [object valueForKey:@"extension"];
      if (!ext)
        ext = @"";
      
      NSString *title;
      title = [object valueForKey:@"name"];
      [cell setTitle:title];
      
      if (object == [[object valueForKey:@"project"] valueForKey:@"mainFile"]) {
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[cell title]];
        [title applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [title length])];
        ImageAndTextCell *c = (ImageAndTextCell*)cell;
        [c setAttributedStringValue:title];
      }
      
      NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:ext];				
      [cell setImage:icon];						
    }
  }

	
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return NO;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	NSDictionary *dict = [notification userInfo];
	NSTreeNode *node = dict[@"NSObject"];
	[[node representedObject] setPrimitiveValue:@NO forKey:@"isExpanded"];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
	NSDictionary *dict = [notification userInfo];
	NSTreeNode *node = dict[@"NSObject"];
	[[node representedObject] setPrimitiveValue:@YES forKey:@"isExpanded"];
}

//- (void)outlineViewSelectionDidChange:(NSNotification *)notification
//{
	
//	NSArray *nodes = [self selectedNodes];	
//	NSTreeNode *node = [[self selectedNodes] firstObject];
	
//	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//	NSDictionary *dict = nil;
//	if (node && [nodes count] == 1) {
//		dict = [NSDictionary dictionaryWithObject:[node representedObject] forKey:@"item"];
//	}
//	[nc postNotificationName:TPTreeSelectionDidChange object:self userInfo:dict];
	
//}

#pragma mark -
#pragma mark Category Tree Data Source Methods for Drag-n-drop



- (NSArray *)treeNodeSortDescriptors
{
	return @[[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES]];
}


/*
 Beginning the drag from the outline view.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
	if (!self.dragEnabled) return NO;
	
  // if the items being dragged contain a folder which exists on disk, don't allow the drag
  NSUInteger itemsOnDisk = 0;
  for (NSTreeNode *node in items) {
    ProjectItemEntity *item = [node representedObject];
    if ([item isKindOfClass:[FolderEntity class]]) {
//      NSLog(@"Checking item %@ / %@", [item name], [item pathOnDisk]);
      if ([item pathOnDisk]) {
        itemsOnDisk ++;
      }
    }
    
    // don't allow moving a file/folder which is not under the project into a folder on disk
    if ([item pathOnDisk] != nil && [item isUnderProject] == NO) {
      return NO;
    }
  }
  
  // don't allow dragging multiple items which are on disk - the logic is too hard
  if (itemsOnDisk > 1) {
    return NO;
  }
  
  
  
	[pasteboard declareTypes:@[OutlineViewNodeType] owner:self];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:OutlineViewNodeType];	
	// Return YES so that the drag actually begins...
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)anOutlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)proposedParentItem proposedChildIndex:(NSInteger)proposedChildIndex;
{
  //  if (outlineView.dragLeftView)
  //    return NO;
  
	// handle file drops from outside
	NSPasteboard *pboard = [info draggingPasteboard];
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
    //    NSLog(@"Info mask %d", [info draggingSourceOperationMask]);
    
    if ([info draggingSourceOperationMask] & NSDragOperationCopy) {
      //      NSLog(@"returning copy");
      return  NSDragOperationCopy;
    }
    
    if ([info draggingSourceOperationMask] & NSDragOperationLink) {
      //      NSLog(@"returning ling");
      return  NSDragOperationLink;
    }
    
    //    NSLog(@"returning copy");
		return NSDragOperationCopy;
	}
  
	
	if ([[proposedParentItem representedObject] isKindOfClass:[FileEntity class]]) {
		return NSDragOperationNone;
	}
	
	
	NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:OutlineViewNodeType]];
	BOOL targetIsValid = YES;
	for (NSIndexPath *indexPath in draggedIndexPaths) {
    
    // can't drop a group on one of its descendants
		NSTreeNode *node = [self nodeAtIndexPath:indexPath];
		if ([proposedParentItem isDescendantOfNode:node] || proposedParentItem == node) { 
			targetIsValid = NO;
			break;
		}
    
    // can't drop disk folder onto group folder
    ProjectItemEntity *child = [node representedObject];
    ProjectItemEntity *parent = [proposedParentItem representedObject];
    if ([child isMemberOfClass:[FolderEntity class]]) {
      if (parent != nil && [child pathOnDisk] != nil && [parent pathOnDisk] == nil) {
        targetIsValid = NO;
        break;
      }
    }
    
    // can't drop managed file onto group folder
    if ([child isMemberOfClass:[FileEntity class]]) {
      if ([child isManaged]) {
        if (parent != nil && [child pathOnDisk] != nil && [parent pathOnDisk] == nil) {
          targetIsValid = NO;
          break;
        }
      }
    }
    
	}
  
  
	return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView 
				 acceptDrop:(id < NSDraggingInfo >)info 
							 item:(id)proposedParentItem 
				 childIndex:(NSInteger)proposedChildIndex;
{	
//  if (outlineView.dragLeftView)
//    return NO;
  
//  NSLog(@"acceptDrop: %@", info);
//  NSLog(@"Proposed parent %@", proposedParentItem);
  
	NSPasteboard *pboard = [info draggingPasteboard];
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray* urls = [pboard propertyListForType:NSFilenamesPboardType];
		for (NSString *path in urls) {			
			// make sure the parent item is selected
			[self setSelectionIndexPath:[self indexPathToObject:[proposedParentItem representedObject]]];
      FileEntity *newfile = nil;
			if ([NSFileManager directoryExists:path]) {
				[self showFolderImportSheetForPath:path];
			} else {
        if (([[NSApp currentEvent] modifierFlags] & NSControlKeyMask)) {
          // link
          newfile = [self addFileAtPath:path toFolder:nil copy:NO];
        } else {
          // copy
          newfile = [self addFileAtPath:path toFolder:nil copy:YES];
        }        
			}
      if (newfile) {
        NSTreeNode *node = [self treeNodeForObject:newfile];
        NSIndexPath *proposedParentIndexPath;
        if (!proposedParentItem)
          proposedParentIndexPath = [[NSIndexPath alloc] init]; // makes a NSIndexPath with length == 0
        else
          proposedParentIndexPath = [proposedParentItem indexPath];
        
        if (proposedChildIndex > -1) {
          [self moveNode:node toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex]];
        } else {
          [self moveNode:node toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:0]];
        }
      }
		}
		return YES;
	}
	
	NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:OutlineViewNodeType]];
  
	NSMutableArray *draggedNodes = [NSMutableArray array];
	for (NSIndexPath *indexPath in droppedIndexPaths)
		[draggedNodes addObject:[self nodeAtIndexPath:indexPath]];
	
	NSIndexPath *proposedParentIndexPath;
	if (!proposedParentItem) {
		proposedParentIndexPath = [[NSIndexPath alloc] init]; // makes a NSIndexPath with length == 0
	} else {
		proposedParentIndexPath = [proposedParentItem indexPath];
	}
  
	if (proposedChildIndex <= -1) {
    proposedChildIndex = 0;
	}
	
  
  // if we are moving a real folder on disk, do the action here
  BOOL didMoveFoldersOnDisk = NO;
  for (NSTreeNode *node in draggedNodes) {
    
    ProjectItemEntity *child = [node representedObject];
    ProjectItemEntity *parent = [proposedParentItem representedObject];
    
    // if the child doesn't exist on disk in its current location, we can't move it
    if ([child existsOnDisk]) {
      //    NSLog(@"Parent %@", parent);
      
      //    NSLog(@"Moving %@", [child name]);
      NSString *fromPath = [child pathOnDisk];
      NSString *toPath = nil;
      if (parent == nil) {
        toPath = [[child.project folder] stringByAppendingPathComponent:child.name];
      } else {
        toPath = [[parent pathOnDisk] stringByAppendingPathComponent:child.name];
      }
      
      // check extension if we are dealing with a file
      if ([child isMemberOfClass:[FileEntity class]]) {
        if ([[toPath pathExtension] isEqualToString:[(FileEntity*)child extension]] == NO) {
          toPath = [[toPath stringByDeletingPathExtension] stringByAppendingPathExtension:[(FileEntity*)child extension]];
        }
      }
      
//      NSLog(@"From %@", fromPath);
//      NSLog(@"To %@", toPath);
      NSFileManager *fm = [NSFileManager defaultManager];
      NSError *error = nil;
      if (fromPath != nil && toPath != nil && [fromPath isEqualToString:toPath] == NO) {
        BOOL success = [fm moveItemAtPath:fromPath toPath:toPath error:&error];
        if (success == NO) {
          [NSApp presentError:error];
          [draggedNodes removeObject:node];
        }
        
        didMoveFoldersOnDisk = YES;
      }
    }
    
    // update any child objects
//    for (ProjectItemEntity *item in child.children) {
//      NSLog(@"Updating %@", item);
//      if ([item isUnderProject]) {
//        [item resetFilePath];
//      }
//    }
  }
  
  if (didMoveFoldersOnDisk) {
    [self.managedObjectContext processPendingChanges];
    [[self.managedObjectContext undoManager] disableUndoRegistration];
  }
  
  [self moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex]];
  
  if (didMoveFoldersOnDisk) {
    [self.managedObjectContext processPendingChanges];
    [[self.managedObjectContext undoManager] enableUndoRegistration];
  }
  
  return YES;
}







//------------------------------------------------------------------------------
#pragma mark -
#pragma mark Outline View Data Source
//------------------------------------------------------------------------------

// Although linked to the core-data context via bindings and a tree controller,
// the outline view also has an instance of this object connected to the outline
// view's data source.

- (id)outlineView:(NSOutlineView *)anOutlineView itemForPersistentObject:(id)object
{
	// Iterate all the items. This is not straightforward because the outline
	// view items are nested. So you cannot just iterate the rows. Rows
	// correspond to root nodes only. The outline view interface does not
	// provide any means to query the hidden children within each collapsed row
	// either. However, the root nodes do respond to -childNodes. That makes it
	// possible to walk the tree.
	NSMutableArray *items = [NSMutableArray array];
	NSInteger i, rows = [anOutlineView numberOfRows];
	for (i = 0; i < rows; i++)
	{
		[items addObject:[anOutlineView itemAtRow:i]];
	}
	for (i = 0; i < [items count] && ![object isEqualToString:[[[[items[i] representedObject] objectID] URIRepresentation] absoluteString]]; i++)
	{
		[items addObjectsFromArray:[items[i] childNodes]];
	}
	return i < [items count] ? items[i] : nil;
}

- (id)outlineView:(NSOutlineView *)anOutlineView persistentObjectForItem:(id)item
{
	// "Persistent object" means a unique representation of the item's object,
	// representing the objects identity, not its state. Outline view writes
	// this to user defaults as soon as the item expands. That's when it asks
	// for the persistent object, sending -outlineView:persistentObjectForItem:
	// and execution arrives here. A minor problem arises when adding new
	// items. The new item represents a new unsaved managed object. The managed
	// object only has a temporary object identifier. It will receive a
	// permanent one when saved. So, if the objectID answers a temporary one,
	// ask the context to save and re-request the objectID. The second request
	// gives a permanent identifier, assuming saving succeeds. Don't worry about
	// committing unsaved edits at this point.
	
	
	NSManagedObject *object = [item representedObject];
	NSManagedObjectID *objectID = [object objectID];
	if ([objectID isTemporaryID])
	{
		if (![[object managedObjectContext] save:NULL])
		{
			return nil;
		}
		objectID = [object objectID];
	}
	
	return [[objectID URIRepresentation] absoluteString];
}


@end
