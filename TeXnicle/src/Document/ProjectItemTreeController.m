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
		[[node representedObject] setValue:[NSNumber numberWithInt:count] forKey:@"sortIndex"];
//    NSLog(@"Set %@", [node representedObject]);
		count++;
	}
}

@end


// Declare a string constant for the drag type - to be used when writing and retrieving pasteboard data...

NSString * const OutlineViewNodeType = @"OutlineViewNodeType";
NSString * const TableViewNodeType = @"TableViewNodeType";
NSString * const TPTreeSelectionDidChange = @"TPTreeSelectionDidChange";
NSString * const TPDocumentWasRenamed = @"TPDocumentWasRenamed";

@implementation ProjectItemTreeController

@synthesize project;
@synthesize document;
@synthesize isDeleting;


- (void)updateSortOrder
{
  [self updateSortOrderOfModelObjects];
}

- (NSManagedObject *)project
{
	if (project != nil) {
		return project;
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
		self.project = [fetchResults objectAtIndex:0];
		[fetchRequest release];
		return project;
	}
	
	if (fetchError != nil) {
		[NSApp presentError:fetchError];
	}
	else {
		// should present custom error message...
	}
	[fetchRequest release];
	return nil;
}

- (void) awakeFromNib
{
	// Set the outline view to accept the custom drag type OutlineViewNodeType...
	[outlineView registerForDraggedTypes:[NSArray arrayWithObjects:OutlineViewNodeType,TableViewNodeType,NSFilenamesPboardType,nil]];
	// apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:YES];
	[imageAndTextCell setImage:[NSImage imageNamed:NSImageNameFolderBurnable]];
	[tableColumn setDataCell:imageAndTextCell];
	
	[outlineView setSortDescriptors:[self treeNodeSortDescriptors]];

	// make sure we have loaded all items before we try to observe them
	NSError *error = nil;
	[self fetchWithRequest:nil merge:YES error:&error];
	if (error) {
		[NSApp presentError:error];
		return;
	}		
	filesToAdd = [[NSMutableArray alloc] init];
	
	[super awakeFromNib];
}

- (void) dealloc
{
	//NSLog(@"ProjectItemTreeController dealloc");
	NSError *error = nil;
	[self fetchWithRequest:nil merge:YES error:&error];
	if (error) {
		[NSApp presentError:error];
		return;
	}
	[filesToAdd release];
	[super dealloc];
}

#pragma mark -
#pragma mark  Project control

- (void) selectDocument:(TeXFileEntity*)aDoc
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
		pathOnDisk = [NSString stringWithString:[[[document fileURL] path] stringByDeletingLastPathComponent]];
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
	[fm createDirectoryAtPath:aPath
withIntermediateDirectories:YES
								 attributes:nil
											error:&error];
	
	if (error) {
		[NSApp presentError:error];
		return NO;
	}
	
	return YES;
}

- (BOOL) makeFileOnDisk:(NSString*)aPath withContents:(NSData*)data overwrite:(BOOL)overwrite
{
//	NSLog(@"Making file on disk: %@ with contents: \n%@", aPath, data);
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
			[alert release];
			//			[[self managedObjectContext] deleteObject:object];
			return NO;
		}
	} else {
//		NSLog(@"File exists at %@", aPath);
	}	
	
	return YES;
}


#pragma mark -
#pragma mark Item Control

// rename items
- (void) renameItemAtRow:(NSInteger)row
{
	[outlineView editColumn:0 row:row withEvent:nil select:YES];
}

// Add a new folder to the project
- (void) addNewFolder
{
	NSString *folderName = [NSString stringWithFormat:@"New Folder %02d", [[self flattenedContent] count]];
	[self addFolder:folderName withFilePath:nil createOnDisk:NO];
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
//	NSLog(@"Adding new folder: %@", newFolder);
	
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
    [outlineView expandItem:parentNode];
	}
	
	// console log
	[[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Added Folder: %@", aName]];
	
	// update sort order
	[self updateSortOrderOfModelObjects];
  
	// select the new folder
  [self performSelector:@selector(selectItem:) withObject:newFolder afterDelay:0.1];
	
	// This is now managed by the controller so we can release it here
	return [newFolder autorelease];				
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
//		NSData *data = [codeStr RTFFromRange:NSMakeRange(0, [codeStr length]) documentAttributes:nil];	
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
	[newFile setValue:[NSNumber numberWithBool:textFile] forKey:@"isText"];
	
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
	
	return [newFile autorelease];				
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
  
  [openPanel beginSheetModalForWindow:[document windowForSheet]
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
		ProjectItemEntity *item = [selectedObjects objectAtIndex:0];
		if ([item isKindOfClass:[FolderEntity class]]) {
			dstfolderPath = [item valueForKey:@"pathOnDisk"];
		}
	}
	if (!dstfolderPath) {
		// set it to project path 
		dstfolderPath = [[self project] valueForKey:@"folder"];
	}
	
	[folderToImportLabel setStringValue:path];
	[dstFolderLabel setStringValue:dstfolderPath];
	
	//	[copyFileLabel setStringValue:path];
	//	[toFolderLabel setStringValue:dstfolderPath];
	
	// prompt user to include files and folders recursively in to selected folder or project folder, or not
	
	[NSApp beginSheet:addExistingFolderSheet
		 modalForWindow:[document windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
}


- (IBAction) endAddExistingFolderSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:addExistingFolderSheet];
		[addExistingFolderSheet orderOut:sender];
		return;
	}
	
	
	// copy file, or not
	BOOL copyFolder = [copyExistingFolderCheckbox state];
	BOOL includeTeXFiles = [includeTeXFilesCheckbox state];
	BOOL includeAllFiles = [includeAllFilesCheckbox state];
	BOOL includeRecursively = [includeRecursivelyCheckbox state];
	
	// add to project
	NSString *srcfolder = [folderToImportLabel stringValue];
	NSString *containerFolder = [dstFolderLabel stringValue];
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
				[fm copyItemAtPath:srcfolder
										toPath:dstfolder 
										 error:&error];
				if (error) {
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
	
	[NSApp endSheet:addExistingFolderSheet];
	[addExistingFolderSheet orderOut:sender];
	
	
	[finishedAddingFilesBtn setEnabled:NO];
	
	[NSApp beginSheet:addingFilesSheet
		 modalForWindow:[document windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
//	NSLog(@"Adding file %@ to %@", dstfolder, containerFolder);
	recurseCount = 0;
	filesAddedCounter = 0;
		
	[self addFolderAtPath:dstfolder includeTeXFiles:includeTeXFiles includeAllFiles:includeAllFiles recursive:includeRecursively];
	
	NSSound *systemSound = [NSSound soundNamed:@"Glass"];
	[systemSound play];
	[finishedAddingFilesBtn setEnabled:YES];
	
	return;	
}	

- (IBAction) endAddingFilesSheet:(id)sender
{
	[NSApp endSheet:addingFilesSheet];
	[addingFilesSheet orderOut:sender];
	
}

- (FolderEntity*) addFolderAtPath:(NSString*)srcFolder 
				 includeTeXFiles:(BOOL)texFiles 
				 includeAllFiles:(BOOL)allFiles 
							 recursive:(BOOL)recursively
{
	
	NSArray *skipFiles = [NSArray arrayWithObjects:@"CVS", nil];
	
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
	
	if (error) {
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
				NSArray *textExtensions = [NSArray arrayWithObjects:@"tex", nil];
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
				[addingFileLabel setStringValue:itempath];
				[addingFileLabel display];
				[filesAddedCountLabel setIntValue:filesAddedCounter];
				[filesAddedCountLabel display];
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
	
	selectedFolder = aFolder;
	
  [openPanel beginSheetModalForWindow:[document windowForSheet]
                    completionHandler:^(NSInteger result) {
                      if (result == NSCancelButton) 
                        return;
                      
                      [openPanel orderOut:self];
                      
                      NSMutableArray *filenames = [NSMutableArray array];
                      for (NSURL *url in [openPanel URLs]) {
                        [filenames addObject:[url path]];
                      }
                      [self addFiles:filenames withContext:selectedFolder];
                    }];
}

- (void) addFiles:(NSArray*)files withContext:(void*)context
{
	// get file name from user
	[filesToAdd removeAllObjects];
	[filesToAdd addObjectsFromArray:files];
	if ([filesToAdd count] == 0) 
		return;
	
//	NSLog(@"Adding files: %@", filesToAdd);
	
	NSString *folderPath = nil;
	id passed = context;
//	NSLog(@"Passed folder: %@", passed);
	if (passed) {
		//NSLog(@"Passed context %@", passed);
		if ([passed isKindOfClass:[FolderEntity class]]) {
			FolderEntity *folder = context;
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
	
	
	if ([filesToAdd count]==1) {
		
		NSString *path = [filesToAdd objectAtIndex:0];
		
		
		[copyFileLabel setStringValue:path];
		[toFolderLabel setStringValue:folderPath];
		
		// prompt user to copy file in to selected folder or project folder, or not
//		NSLog(@"Starting sheet %@ on %@", addExistingFileSheet, self.document);
		[NSApp beginSheet:addExistingFileSheet
			 modalForWindow:[self.document windowForSheet]
				modalDelegate:self
			 didEndSelector:NULL
					contextInfo:NULL];
		
		
	} else {
		// Multiple files
		
		[destinationFolderLabel setStringValue:folderPath];
		
		[NSApp beginSheet:addExistingFilesSheet
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
		[NSApp endSheet:addExistingFilesSheet];
		[addExistingFilesSheet orderOut:sender];
		return;
	}
	
	BOOL copyFile = NO;
	if ([copyExistingFilesCheckbox state]==NSOnState) {
		copyFile = YES;
	}
	
	NSIndexPath *selected = [self selectionIndexPath];
	for (NSString *file in filesToAdd) {		
		[self setSelectionIndexPath:selected];
		[self addFileAtPath:file toFolder:nil copy:copyFile];
	}
	
	[NSApp endSheet:addExistingFilesSheet];
	[addExistingFilesSheet orderOut:sender];
}


- (IBAction) endAddExistingFileSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:addExistingFileSheet];
		[addExistingFileSheet orderOut:sender];
		return;
	}
	
	// copy file, or not
	BOOL copyFile = [copyExistingFileCheckbox state];
	
	// add to project
	NSString *filepath = [copyFileLabel stringValue];		
	[self addFileAtPath:filepath toFolder:nil copy:copyFile];
		
	[NSApp endSheet:addExistingFileSheet];
	[addExistingFileSheet orderOut:sender];
}	

- (FileEntity*) addFileAtPath:(NSString*)aPath toFolder:(FolderEntity*)aFolder copy:(BOOL)copyFile
{
//	NSLog(@"Adding file to project: %@", aPath);
  

	
	// Look at the file we are adding
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	NSString *projectPath = aPath;
	
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
          [fm removeItemAtPath:dstPath error:&error];
          if (error) {
            [NSApp presentError:error];
            return nil;
          }
				}
        
      }
//			NSLog(@"Copying %@ \nto \n%@", aPath, dstPath); 
			[fm copyItemAtPath:aPath toPath:dstPath error:&error];
			if (error) {
				[NSApp presentError:error];
				return nil;
			}
		}
		aPath = dstPath;	
    projectPath = dstPath;
	}
	
	// read the contents of the source file
	BOOL isTextFile = NO;
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  NSString *contents = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:aPath]];

	if ([aPath isText]) {
		isTextFile = YES;
	}	
	
	// Add to project
	id doc = [self addNewFile:[aPath lastPathComponent]
								 atFilepath:projectPath
									extension:[aPath pathExtension]
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
	[alert beginSheetModalForWindow:[document windowForSheet]
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
    [self setSelectionIndexPath:[NSIndexPath indexPathWithIndex:[[outlineView selectedRowIndexes] firstIndex]]];
		
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
	[openDocumentsManager removeDocument:aFile];
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
	
	CGFloat imageSize = 20.0;
	[anOutlineView setRowHeight:imageSize+2.0];
	
	ProjectItemEntity *object = [item representedObject];

	[cell setImageSize:imageSize];
  [cell setTextColor:[NSColor blackColor]];
		
	if ([object isMemberOfClass:[FolderEntity class]]) {
//    NSLog(@"%@ is a folder", [object name]);
		if ([[object valueForKey:@"isExpanded"] boolValue]) {
			NSString *folderFileType = NSFileTypeForHFSTypeCode(kOpenFolderIcon);
			[cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];		
		} else {
			NSString *folderFileType = NSFileTypeForHFSTypeCode(kGenericFolderIcon);
			[cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];		
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
				
		if ([object isKindOfClass:[TeXFileEntity class]] && [ext isEqual:@"tex"]) {
			if (object == [[object valueForKey:@"project"] valueForKey:@"mainFile"]) {
				NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[cell title]];
				[title applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [title length])];
				ImageAndTextCell *c = (ImageAndTextCell*)cell;
				[c setAttributedStringValue:title];
				[title release];
			}
		}
    		
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:ext];				
		[cell setImage:icon];						
	}
	
//	// check if the file exists on disk, and if not, indicate by making red text
//	if ([object isKindOfClass:[FileEntity class]]) {
//		if(![object existsOnDisk]) {
//			[cell setTextColor:[NSColor redColor]];
//		}	
//	}
	
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
	NSTreeNode *node = [dict objectForKey:@"NSObject"];
	[[node representedObject] setPrimitiveValue:[NSNumber numberWithBool:NO] forKey:@"isExpanded"];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
	NSDictionary *dict = [notification userInfo];
	NSTreeNode *node = [dict objectForKey:@"NSObject"];
	[[node representedObject] setPrimitiveValue:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
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
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES] autorelease]];
}


/*
 Beginning the drag from the outline view.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
	
	
	[pboard declareTypes:[NSArray arrayWithObject:OutlineViewNodeType] owner:self];
	[pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:OutlineViewNodeType];	
	// Return YES so that the drag actually begins...
	return YES;
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
		BOOL copyFiles = NO;
		if ([info draggingSourceOperationMask] & NSDragOperationCopy) {
			copyFiles = YES;
		}
		for (NSString *path in urls) {			
			// make sure the parent item is selected
			[self setSelectionIndexPath:[self indexPathToObject:[proposedParentItem representedObject]]];
      FileEntity *newfile = nil;
			if ([NSFileManager directoryExists:path]) {
				[self showFolderImportSheetForPath:path];
			} else {
        if (([[NSApp currentEvent] modifierFlags] & NSControlKeyMask)) {
          // link
//          NSLog(@"Linking file %@", path);
          newfile = [self addFileAtPath:path toFolder:nil copy:NO];
        } else {
          // copy
//          NSLog(@"Copying file %@", path);
          newfile = [self addFileAtPath:path toFolder:nil copy:YES];
        }
        
//        NSDragOperation op = [info draggingSourceOperationMask];
//        NSLog(@"Drag op %d", op);
//        if (op == NSDragOperationLink) {
//        } else if (op == NSDragOperationCopy) {
//        } else {
//          return NO;
//        }
			}
      if (newfile) {
        NSTreeNode *node = [self treeNodeForObject:newfile];
        NSIndexPath *proposedParentIndexPath;
        if (!proposedParentItem)
          proposedParentIndexPath = [[[NSIndexPath alloc] init] autorelease]; // makes a NSIndexPath with length == 0
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
	if (!proposedParentItem)
		proposedParentIndexPath = [[[NSIndexPath alloc] init] autorelease]; // makes a NSIndexPath with length == 0
	else
		proposedParentIndexPath = [proposedParentItem indexPath];
	
	if (proposedChildIndex > -1) {
		[self moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex]];
	} else {
		[self moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:0]];
	}
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
		NSTreeNode *node = [self nodeAtIndexPath:indexPath];
		if ([proposedParentItem isDescendantOfNode:node] || proposedParentItem == node) { // can't drop a group on one of its descendants
			targetIsValid = NO;
			break;
		}
	}
	return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
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
	for (i = 0; i < [items count] && ![object isEqualToString:[[[[[items objectAtIndex:i] representedObject] objectID] URIRepresentation] absoluteString]]; i++)
	{
		[items addObjectsFromArray:[[items objectAtIndex:i] childNodes]];
	}
	return i < [items count] ? [items objectAtIndex:i] : nil;
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
