//
//  TPOutlineView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 30/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import "TPOutlineView.h"
#import "FolderEntity.h"
#import "TeXFileEntity.h"

@implementation TPOutlineView

- (void) dealloc
{
  self.mainDocument = nil;
}

- (void) awakeFromNib
{
  self.showMenu = YES;
}

- (void) setNeedsDisplay
{
  [self setNeedsDisplay:YES];
}

-(NSMenu*)menuForEvent:(NSEvent*)evt 
{
  if (!self.showMenu) {
    return nil;
  }
  
	NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
	NSInteger row=[self rowAtPoint:pt];
	
	// Main tree context menu
	if (row < 0) {
		return [self defaultMenu];
	}
	return [self defaultMenuForRow:row];
}
						

#pragma mark -
#pragma mark Main Context Menu

- (NSMenu*)defaultMenu
{
	
	NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Project Tree Context Menu"];
	
	[theMenu setAutoenablesItems:NO];
	
	//------ Add existing file
	NSMenuItem *menuItem;
	
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Add existing files..."
																				action:@selector(addExistingFile:)
																 keyEquivalent:@""];
	[theMenu addItem:menuItem];
	
	//------ Add existing folder	
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Add existing folder..."
																				action:@selector(addExistingFolder:)
																 keyEquivalent:@""];
	[theMenu addItem:menuItem];

  [theMenu addItem:[NSMenuItem separatorItem]];
  
	//------ New Folder on disk
	menuItem = [[NSMenuItem alloc] initWithTitle:@"New folder on disk..."
																				action:@selector(newFolderOnDisk:)
																 keyEquivalent:@""];
	[theMenu addItem:menuItem];
	
	//------ New Group Folder
	menuItem = [[NSMenuItem alloc] initWithTitle:@"New group folder..."
																				action:@selector(newGroupFolder:)
																 keyEquivalent:@""];
	[theMenu addItem:menuItem];

  
  [theMenu addItem:[NSMenuItem separatorItem]];
  
	//------ New File
	menuItem = [[NSMenuItem alloc] initWithTitle:@"New file..."
																				action:@selector(addNewFile:)
																 keyEquivalent:@""];
	[theMenu addItem:menuItem];
  
  
	return theMenu;
}

- (IBAction) addExistingFolder:(id)sender
{
	[treeController addExistingFolder:self];
  selectedItem = nil;
}


- (IBAction) addExistingFile:(id)sender
{
	[treeController addExistingFile:self toFolder:nil];
  selectedItem = nil;
}

- (IBAction) addExistingFileToSelectedFolder:(id)sender
{
	[treeController addExistingFile:self toFolder:(FolderEntity*)selectedItem];
  selectedItem = nil;
}


#pragma mark -
#pragma mark Menu for item

-(NSMenu*)defaultMenuForRow:(NSInteger)row
{
  if (!self.showMenu) return nil;
  
	if (row < 0) return nil;
	
	selectedRow = row;
	[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
//  [treeController setSelectionIndexPath:[NSIndexPath indexPathWithIndex:row]];

	// get the object for this row
//	NSArray *items = [treeController selectedObjects]; //[treeController flattenedContent];
	selectedItem = [[self itemAtRow:row] representedObject];  
  [treeController selectItem:selectedItem];
	
	NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Project Item Context Menu"];
	
	[theMenu setAutoenablesItems:NO];
	
	NSString *itemName = [selectedItem valueForKey:@"name"];
	
	
	//--------- add existing file
	if ([selectedItem isKindOfClass:[FolderEntity class]]) {
		
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add existing files..."
																									action:@selector(addExistingFileToSelectedFolder:)
																					 keyEquivalent:@""];
		[theMenu addItem:item];
		
		//------ Add existing folder	
		item = [[NSMenuItem alloc] initWithTitle:@"Add existing folder..."
																					action:@selector(addExistingFolder:)
																	 keyEquivalent:@""];
		[theMenu addItem:item];
		
	}
  
  [theMenu addItem:[NSMenuItem separatorItem]];
  
  //------ Add new file
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"New file..."
                                    action:@selector(addNewFile:)
                             keyEquivalent:@""];
  [theMenu addItem:item];
  
	
  [theMenu addItem:[NSMenuItem separatorItem]];
  
	//--------- set main file
	if ([selectedItem isKindOfClass:[FileEntity class]]) {
		NSMenuItem *mainItem;
		if ([[treeController project] valueForKey:@"mainFile"] == selectedItem) {
			mainItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Unset \u201c%@\u201d as main file", itemName]
																												action:@selector(setMainItem:)
																								 keyEquivalent:@""];
		} else {
			mainItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Set \u201c%@\u201d as main file", itemName]
																												action:@selector(setMainItem:)
																								 keyEquivalent:@""];
		}
		[theMenu addItem:mainItem];
	}
	
	//--------- rename item
	if ([selectedItem isKindOfClass:[ProjectItemEntity class]]) {
		NSMenuItem *renameItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Rename \u201c%@\u201d", itemName]
																												action:@selector(renameItem:)
																								 keyEquivalent:@""];
		[theMenu addItem:renameItem];
	}
	
	//--------- remove item
	NSMenuItem *removeItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Remove \u201c%@\u201d", itemName]
																											action:@selector(removeItem:)
																							 keyEquivalent:@""];
	[theMenu addItem:removeItem];
	
  //--------- Reveal in Finder
	if ([selectedItem isKindOfClass:[FileEntity class]] || 
      ([selectedItem isKindOfClass:[FolderEntity class]] && [selectedItem valueForKey:@"pathOnDisk"]) ) {
    NSString *path = [selectedItem valueForKey:@"pathOnDisk"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
      NSMenuItem *revealItem = [[NSMenuItem alloc] initWithTitle:@"Reveal in Finder"
                                                          action:@selector(revealItem:)
                                                   keyEquivalent:@""];
      [theMenu addItem:[NSMenuItem separatorItem]];
      [theMenu addItem:revealItem];
    }
		
  }
  
  //--------- Locate on disk
  if ([selectedItem isKindOfClass:[FileEntity class]]){
    //--------- locate item
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:[selectedItem valueForKey:@"pathOnDisk"]]) {
			[theMenu addItem:[NSMenuItem separatorItem]];
			NSMenuItem *locateItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Locate '%@' on disk", itemName]
																													action:@selector(locateItem:) 
																									 keyEquivalent:@""];
			[theMenu addItem:locateItem];
			[theMenu addItem:[NSMenuItem separatorItem]];
		}
	}
	
  
	//--------- New folder on disk
	if ([selectedItem isKindOfClass:[FolderEntity class]]) {
    [theMenu addItem:[NSMenuItem separatorItem]];
    if ([selectedItem pathOnDisk]) {
      NSMenuItem *newSubfolder = [[NSMenuItem alloc] initWithTitle:@"New folder on disk"
                                                            action:@selector(newFolderOnDisk:)
                                                     keyEquivalent:@""];
      [theMenu addItem:newSubfolder];
    }
	}
	

	//--------- New Subfolder
	if ([selectedItem isKindOfClass:[FolderEntity class]]) {
		NSMenuItem *newSubfolder = [[NSMenuItem alloc] initWithTitle:@"New group folder"
																													action:@selector(newGroupFolder:)
																									 keyEquivalent:@""];
		[theMenu addItem:newSubfolder];
	}
	
  
	//--------- New TeX file
	
	//--------- Add menu
	
	return theMenu;
}

- (IBAction) addNewFile:(id)sender
{
  [treeController addNewFile];  
}

- (IBAction) newGroupFolder:(id) sender
{
  [treeController addNewFolder];
  selectedItem = nil;
}

- (IBAction) newFolderOnDisk:(id)sender
{
  [treeController addNewFolderCreateOnDisk];
  selectedItem = nil;
}

- (IBAction) newSubfolder:(id)sender
{
	NSManagedObjectContext *moc = [treeController managedObjectContext];
	
	NSManagedObject *newFolder = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Folder"
																																									 inManagedObjectContext:moc]
																				insertIntoManagedObjectContext:moc];
	[newFolder setValue:[NSString stringWithFormat:@"New Folder %02lu", [[treeController flattenedContent] count]]
							 forKey:@"name"];
		
  [newFolder setValue:self.mainDocument.project forKey:@"project"];
  
	[treeController addObject:newFolder];
	[self editColumn:0 row:[self selectedRow] withEvent:nil select:YES];
}

- (IBAction) setMainItem:(id)sender
{
  if ([selectedItem isKindOfClass:[FileEntity class]]) {
    FileEntity *file = (FileEntity*)selectedItem;
    ProjectEntity *project = [treeController project];
    if ([project valueForKey:@"mainFile"] == selectedItem) {
      project.mainFile = nil;
    } else {
      project.mainFile = file;
    }
    [self setNeedsDisplay:YES];
  }
  [self.mainDocument showDocument];
  selectedItem = nil;
}

- (IBAction) revealItem:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *fullpath = [selectedItem valueForKey:@"pathOnDisk"];
	[ws selectFile:fullpath inFileViewerRootedAtPath:[fullpath stringByDeletingLastPathComponent]];
  selectedItem = nil;
}


- (IBAction) renameItem:(id)sender
{
	if ([self.mainDocument respondsToSelector:@selector(renameItem:)]) {
		[self.mainDocument renameItem:selectedItem];
	}
  selectedItem = nil;
}


- (IBAction) removeItem:(id)sender
{
	[treeController remove:self];
}

- (IBAction) locateItem:(id)sender
{
	// get user to choose file
	NSOpenPanel *openPanel = [NSOpenPanel openPanel]; 
	if ([selectedItem isKindOfClass:[FolderEntity class]]) {
		[openPanel setCanChooseFiles:NO];
		[openPanel setCanChooseDirectories:YES];
	} else {
		[openPanel setCanChooseFiles:YES];
		[openPanel setCanChooseDirectories:NO];
	}
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanCreateDirectories:NO];
	
  [openPanel beginSheetModalForWindow:[[[NSDocumentController sharedDocumentController] currentDocument] windowForSheet]
                    completionHandler:^(NSInteger result) {
                      
                      if (result == NSCancelButton) {
                        selectedItem = nil;
                        return;
                      }
                      
                      NSString *path = [[openPanel URL] path];
                      
                      // set the path to the item
                      [selectedItem setValue:path forKey:@"filepath"];
                      
                      NSString *newName = [path lastPathComponent];
                      if (newName) {
                        if (![[selectedItem name] isEqualToString:newName]) {
                          [selectedItem setValue:newName forKey:@"name"];
                        }
                      }
                      
                      [self reloadItem:selectedItem];
                      selectedItem = nil;
                    }];
	
	
}


- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
//  NSLog(@"prepareForDragOperation: %d", dragLeftView);
  if (self.dragLeftView)
    return NO;
  
  return [super prepareForDragOperation:sender];
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender
{
//  NSLog(@"Dragging ended");
  if (self.dragLeftView) {
    [self reloadData];
  }
  self.dragLeftView = NO;
  [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
//  NSLog(@"performDragOperation: %d", dragLeftView);
  if (self.dragLeftView)
    return NO;
  
  return [super performDragOperation:sender];
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
  self.dragLeftView = YES;
  
//  NSLog(@"Dragging from %@", sender);
  NSPasteboard *pboard = [sender draggingPasteboard];
//  NSLog(@"Dragging exited %@", [pboard types]);
  
  NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[sender draggingPasteboard] dataForType:OutlineViewNodeType]];
  
//  NSFileManager *fm = [NSFileManager defaultManager];
  
  // collect array of file paths
  NSMutableArray *paths = [NSMutableArray array];
  
  for (NSIndexPath *indexPath in droppedIndexPaths) {      
    NSManagedObject *item = [[treeController nodeAtIndexPath:indexPath] representedObject];
    if ([item isKindOfClass:[FileEntity class]]) {
      NSString *path = [item valueForKey:@"pathOnDisk"];
      [paths addObject:path];
    }
  }
  
  [pboard setPropertyList:paths forType:NSFilenamesPboardType];
  
//  [pboard writeObjects:paths forType:NSFilenamesPboardType];
  
//  NSString *fileString = @"";
//  for (NSIndexPath *indexPath in droppedIndexPaths) {      
//    NSManagedObject *item = [[treeController nodeAtIndexPath:indexPath] representedObject];
//    if ([item isKindOfClass:[FileEntity class]]) {
//      NSString *filename = [item valueForKey:@"filepath"];
//      NSString *path = [item valueForKey:@"pathOnDisk"];
//      CFStringRef fileExtension = (CFStringRef) [path pathExtension];
////      NSLog(@"Extension %@", fileExtension);
//      CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
////      NSLog(@"UTI %@, %d", fileUTI, UTTypeConformsTo(fileUTI, kUTTypeImage));
//      if (UTTypeConformsTo(fileUTI, kUTTypeImage) || UTTypeConformsTo(fileUTI, kUTTypePDF)) {
//        NSString *str = [NSString stringWithFormat:@"\\begin{figure}[htbp]\n\\centering\n\\includegraphics[width=1.0\\textwidth]{%@}\n\\caption{My Nice Figure.}\n\\label{fig:myfigure}\n\\end{figure}\n", filename];
//        fileString = [fileString stringByAppendingString:str];
//      } else {
//        fileString = [fileString stringByAppendingFormat:@"\\input{%@}\n", filename];
//      }
//      
//    }
//  }
//  
//  
//  [pboard setString:fileString forType:NSPasteboardTypeString];
  //  [self setFile:[[pboard propertyListForType:NSFilenamesPboardType]objectAtIndex:0]];
  
}


@end
