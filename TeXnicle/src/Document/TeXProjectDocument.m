//
//  TeXProjectDocument.m
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "TeXProjectDocument.h"
#import "ProjectEntity.h"
#import "ProjectItemTreeController.h"
#import "FileEntity.h"
#import "TeXFileEntity.h"
#import "TPLaTeXEngine.h"
#import "ConsoleController.h"
#import "MHControlsTabBarController.h"
#import "UKKQueue+TeXnicle.h"
#import "FindInProjectController.h"
#import "NSString+LaTeX.h"
#import "TPStatusView.h"

@implementation TeXProjectDocument

@synthesize project;
@synthesize projectOutlineView;
@synthesize controlsTabview;
@synthesize openDocuments;
@synthesize projectItemTreeController;
@synthesize texEditorViewController;
@synthesize texEditorContainer;
@synthesize statusView;
@synthesize engine;
@synthesize projectTypeSelector;
@synthesize pdfView;
@synthesize pdfSearchResults;

- (void) dealloc
{
//  NSLog(@"TeXProjectDocument dealloc");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [projectOutlineController deactivate];
  [finder release];
  self.texEditorViewController = nil;
  self.engine = nil;
  self.pdfSearchResults = nil;
  [super dealloc];
}

- (id)init
{
//  NSLog(@"TeXProjectDocument init");
  self = [super init];
  if (self) {
  }
  return self;
}

- (NSString *)windowNibName
{
  // Override returning the nib file name of the document
  // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
  return @"TeXProjectDocument";
}

- (BOOL)setMetadataForStoreAtURL:(NSURL *)url 
{
  NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
  NSPersistentStore *pStore = [psc persistentStoreForURL:url];
  NSString *projectName = self.project.name;
  
  if ((pStore != nil) && (projectName != nil)) {
    NSMutableDictionary *metadata = [[psc metadataForPersistentStore:pStore] mutableCopy];
    if (metadata == nil) {
      metadata = [NSMutableDictionary dictionary];
    }
    [metadata setObject:[NSArray arrayWithObject:projectName]
                 forKey:(NSString *)kMDItemKeywords];
    [psc setMetadata:metadata forPersistentStore:pStore];
    return YES;
  }
  return NO;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
  // Setup text view
  
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
  self.openDocuments.texEditorViewController = self.texEditorViewController;
  [self.openDocuments disableTextView];
  
  // setup engine
  self.engine = [TPLaTeXEngine engineWithDelegate:self];
  
	// Don't select anything
	[self.projectItemTreeController setSelectionIndexPath:nil];
  
	// Double-click the tree to open standalone windows
	[self.projectOutlineView setDoubleAction:@selector(openStandaloneWindow:)];
  
	// Update the project folder in case the file was moved
	NSString *projectFolder = [[[self fileURL] path] stringByDeletingLastPathComponent];
	NSString *saveFolder = [self.project valueForKey:@"folder"];
	if (![saveFolder isEqual:projectFolder]) {
    //		NSLog(@"Set project folder from %@ to %@", saveFolder, projectFolder);
		[self.project setValue:projectFolder forKey:@"folder"];
	}
  
  // -- Notifications
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  // observe changes to the selection of the project outline view
  [nc addObserver:self
         selector:@selector(handleProjectOutlineViewSelectionChange:)
             name:NSOutlineViewSelectionDidChangeNotification
           object:self.projectOutlineView];
  
  [nc addObserver:self
         selector:@selector(handleTypesettingCompletedNotification:)
             name:TPTypesettingCompletedNotification
           object:self.engine];
  
  [nc addObserver:self
         selector:@selector(handleControlTabSelectionChanged:)
             name:TPControlsTabSelectionDidChangeNotification 
           object:nil];
  
  [nc addObserver:self
         selector:@selector(handleTextEditorSelectionChanged:)
             name:NSTextViewDidChangeSelectionNotification 
           object:self.texEditorViewController.textView];
  
  
  [self.statusView setProjectStatus:@"Welcome to TeXnicle."];
  [self.statusView setEditorStatus:@"No Selection."];
  [self.projectTypeSelector selectItemWithTitle:[self.project valueForKey:@"type"]];
  
	// spell checker language
	NSString *language = [[NSUserDefaults standardUserDefaults] valueForKey:TPSpellCheckerLanguage];
	if (![language isEqual:@""]) {
    //		NSLog(@"Setting language to %@", language);
		[[NSSpellChecker sharedSpellChecker] setLanguage:language];
	}

  
  // ensure the project has the same name as on disk
  [self.project setValue:[[[self fileURL] lastPathComponent] stringByDeletingPathExtension] forKey:@"name"];
//  [self saveDocument:self];

//  NSLog(@"Loaded project %@", self.project);
//  for (NSManagedObject *item in [self.project valueForKey:@"items"]){
//    NSLog(@"%@", [item valueForKey:@"parent"]);
//  }
  [self.pdfView setDocument:nil];
  [self showDocument];
}


- (void)windowWillClose:(NSNotification *)notification 
{
	
	// make sure we store the current status of open docs
	[self.openDocuments commitStatus];
	
	// close all tabs
	for (NSTabViewItem *item in [self.openDocuments.tabView tabViewItems]) {
		[self.openDocuments.tabView removeTabViewItem:item];
	}
	
  //	NSWindow *window = [[self window];
  //	[window setDelegate:nil];
  //	[self release];
	
	if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
		if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
			[[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
      [[ConsoleController sharedConsoleController] close];
		}
	}
	
}

+ (id)newTeXnicleProject
{
  // get a project name from the user
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setTitle:@"Save New Project..."];
  [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"texnicle"]];
  [savePanel setPrompt:@"Create"];
  [savePanel setMessage:@"Choose a location for the new TeXnicle project."];
  [savePanel setNameFieldLabel:@"Create Project:"];
  [savePanel setAllowsOtherFileTypes:NO];
  [savePanel setCanCreateDirectories:YES];
  
  BOOL result = [savePanel runModal];
  
  if (result == NSFileHandlingPanelCancelButton) {
    return nil;
  }
  
  NSString *path = [[savePanel URL] path];
  NSURL *url = [NSURL fileURLWithPath:path];
  
  // Remove file if it is there
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@".yyyy_MM_dd_HH_mm"];
    NSString *movedPath = [path stringByAppendingFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    NSError *moveError = nil;
    [fm moveItemAtPath:path toPath:movedPath error:&moveError];
    if (moveError) {
      [NSApp presentError:moveError];
      return nil;
    }
  }
  
  // make a new managed object context  
  NSManagedObjectContext *moc = [TeXProjectDocument managedObjectContextForStoreURL:url];
  
  [moc processPendingChanges];
  [[moc undoManager] disableUndoRegistration];
  NSEntityDescription *projectDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:moc];
  ProjectEntity *project = [[NSManagedObject alloc] initWithEntity:projectDescription insertIntoManagedObjectContext:moc]; 
    
  // set name and folder of the project
  NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
  NSString *folder = [path stringByDeletingLastPathComponent];
  [project setValue:name forKey:@"name"];
  [project setValue:folder forKey:@"folder"]; 
  
  [moc processPendingChanges];
  [[moc undoManager] enableUndoRegistration];
  
  NSError *error = nil;
  [moc save:&error];
  if (error) {
    [NSApp presentError:error];
    return nil;
  }
  
  NSError *openError = nil;
  id doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES error:&openError];
  if (openError) {
    [NSApp presentError:openError];
    return nil;
  }  
  
  return doc;
}

+ (NSManagedObjectContext*) managedObjectContextForStoreURL: (NSURL*) storeURL
{
	//	Find the document's model
	
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	if (!model)
		return nil;
	
//  NSLog(@"Got model %@", model);
	//	Create a persistent store
  
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
//  NSLog(@"Coordinator %@", psc);
  
	if (!psc)
		return nil;
	  
	NSError *error = nil;
  NSMutableDictionary *options = nil;
  [options setObject:[NSNumber numberWithBool:YES] 
							forKey:NSMigratePersistentStoresAutomaticallyOption];
	NSPersistentStore *store = [psc addPersistentStoreWithType:NSXMLStoreType
                                               configuration:nil 
                                                         URL:storeURL 
                                                     options:options 
                                                       error:&error];
	if (!store)
		return nil;
	
	//	Create a managed object context for the store
	
	NSManagedObjectContext* managedContext = [[NSManagedObjectContext alloc] init];
	if (!managedContext)
		return nil;
	
	managedContext.persistentStoreCoordinator = psc;
	managedContext.undoManager = nil;
	
	return managedContext;
}

//- (id)initWithType:(NSString *)typeName error:(NSError **)outError
//{
//  //	NSLog(@"Init with type...");
//	NSError *error=nil;
//	self = [super initWithType:typeName error:&error];
//	if (error) {
//		[NSApp presentError:error];
//		return nil;
//	}
//	
//	if (self != nil) {
//    
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    [managedObjectContext processPendingChanges];
//    [[managedObjectContext undoManager] disableUndoRegistration];
//    self.project = [NSEntityDescription insertNewObjectForEntityForName:@"Project"
//                                                 inManagedObjectContext:managedObjectContext];
//    [managedObjectContext processPendingChanges];
//    [[managedObjectContext undoManager] enableUndoRegistration];
//    
//    // get a project name from the user
//    NSSavePanel *savePanel = [NSSavePanel savePanel];
//    [savePanel setTitle:@"Save New Project..."];
//    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"texnicle"]];
//    [savePanel setPrompt:@"Create"];
//    [savePanel setMessage:@"Choose a location for the new TeXnicle project."];
//    [savePanel setAllowsOtherFileTypes:NO];
//    [savePanel setCanCreateDirectories:YES];
//    
//    BOOL result = [savePanel runModal];
//    
//    if (result == NSFileHandlingPanelCancelButton) {
//      return nil;
//    }
// 
//    
//////    [self saveDocument:self];
//    NSError *saveError = nil;
//    NSString *path = [[savePanel URL] path];
//    NSURL *url = [NSURL fileURLWithPath:path];
//
//    [self setFileType:@"texnicle"];
//    [self setFileURL:url];
//    
//    NSLog(@"Saving to %@", url);
//    [self saveToURL:url ofType:@"texnicle" forSaveOperation:NSSaveOperation error:&saveError];
//    if (saveError) {
//      [NSApp presentError:saveError];
//      return nil;
//    }
//    
//    NSString *fullpath = [[self fileURL] path];
//    NSString *name = [[fullpath lastPathComponent] stringByDeletingPathExtension];
//    NSString *folder = [fullpath stringByDeletingLastPathComponent];
//    // set these to the project
//    [managedObjectContext processPendingChanges];
//    [[managedObjectContext undoManager] disableUndoRegistration];
//    [self.project setValue:name forKey:@"name"];
//    [self.project setValue:folder forKey:@"folder"]; 
//    [self addNewArticleMainFile];
//    [managedObjectContext processPendingChanges];
//    [[managedObjectContext undoManager] enableUndoRegistration];    
//    
//    
////    [self saveToURL:url ofType:@"texnicle" forSaveOperation:NSSaveOperation delegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:NULL];
//    
////    [self saveDocument:self];
//    
////    [self setFileType:@"XML"];
////    [self runModalSavePanelForSaveOperation:NSSaveOperation delegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:NULL];		
//	}
//	return self;
//}


- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL*)url 
																					 ofType:(NSString*)fileType
															 modelConfiguration:(NSString*)configuration
																		 storeOptions:(NSDictionary*)storeOptions
																						error:(NSError**)error
{
  NSMutableDictionary *options = nil;
  if (storeOptions != nil) {
    options = [storeOptions mutableCopy];
  } else {
    options = [[NSMutableDictionary alloc] init];
  }
	
  [options setObject:[NSNumber numberWithBool:YES] 
							forKey:NSMigratePersistentStoresAutomaticallyOption];
  
  BOOL result = [super configurePersistentStoreCoordinatorForURL:url
																													ofType:fileType
																							modelConfiguration:configuration
																										storeOptions:options
																													 error:error];
  [options release], options = nil;
  
  if (result) {
    NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
    NSPersistentStore *pStore = [psc persistentStoreForURL:url];
    id existingMetadata = [[psc metadataForPersistentStore:pStore]
                           objectForKey:(NSString *)kMDItemKeywords];
    if (existingMetadata == nil) {
      result = [self setMetadataForStoreAtURL:url];
    }  
  }
    
  return result;
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
		[self presentError:fetchError];
	}
	else {
		// should present custom error message...
	}
	[fetchRequest release];
	return nil;
}


#pragma mark -
#pragma mark Tree Action Menu

- (IBAction) showCategoryActionMenu:(id)sender
{
	if (treeActionMenu) {
    [treeActionMenu release];
    treeActionMenu = nil;
  }
  
  selectedItem = nil;
  
	// Make popup menu with bound actions
	treeActionMenu = [[NSMenu alloc] initWithTitle:@"Project Tree Action Menu"];	
	[treeActionMenu setAutoenablesItems:YES];
  
  // check selected item(s)
  NSArray *selectedItems = [self.projectItemTreeController selectedObjects];
//  NSLog(@"Selected items %@", selectedItems);
  
  if ([selectedItems count] == 0) {
    
    // add existing files
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add Existing file(s)..."
                                                  action:@selector(addExistingFile:)
                                           keyEquivalent:@""];
    [item setTarget:self];
    [treeActionMenu addItem:item];
    [item release];		
    
    // add existing folders
    item = [[NSMenuItem alloc] initWithTitle:@"Add Existing folder..."
                                      action:@selector(addExistingFolder:)
                               keyEquivalent:@""];
    [item setTarget:self];
    [treeActionMenu addItem:item];
    [item release];		

  } else if ([selectedItems count] == 1) {
    
    selectedItem = [selectedItems objectAtIndex:0];
    selectedRow = [self.projectOutlineView selectedRow];
    NSString *itemName = [selectedItem valueForKey:@"name"];
    
    // if a folder is selected...
    if ([selectedItem isKindOfClass:[FolderEntity class]]) {
      
      // add existing files
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add Existing file(s)..."
                                                    action:@selector(addExistingFileToSelectedFolder:)
                                             keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // add existing folders
      item = [[NSMenuItem alloc] initWithTitle:@"Add Existing folder..."
                                        action:@selector(addExistingFolder:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // add existing folders
      item = [[NSMenuItem alloc] initWithTitle:@"New Folder"
                                        action:@selector(addNewFolder:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // rename selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Rename \u201c%@\u201d", itemName]
                                        action:@selector(renameItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // Remove selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Remove \u201c%@\u201d", itemName]
                                        action:@selector(removeItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
    } else {
      
      // rename selected
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Rename \u201c%@\u201d", itemName]
                                        action:@selector(renameItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // Remove selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Remove \u201c%@\u201d", itemName]
                                        action:@selector(removeItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // reveal selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Reveal \u201c%@\u201d in Finder", itemName]
                                        action:@selector(revealItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // reveal selected
      if ([self.project valueForKey:@"mainFile"] == selectedItem) {
        item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Unset \u201c%@\u201d as main file", itemName]
                                          action:@selector(setMainItem:)
                                   keyEquivalent:@""];
      } else {
        item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Set \u201c%@\u201d as main file", itemName]
                                          action:@selector(setMainItem:)
                                   keyEquivalent:@""];
      }
      
      [item setTarget:self];
      [treeActionMenu addItem:item];
      [item release];		
      
      // Locate selected
      NSFileManager *fm = [NSFileManager defaultManager];
      if (![fm fileExistsAtPath:[selectedItem valueForKey:@"pathOnDisk"]]) {
        item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Locate \u201c%@\u201d on disk", itemName]
                                          action:@selector(locateItem:)
                                   keyEquivalent:@""];
        [item setTarget:self];
        [treeActionMenu addItem:item];
        [item release];		
      }      
      
    }
    
  } else {
    
    NSInteger nselected = [selectedItems count];
    
    // Remove selected
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Remove selected %ld items", nselected]
                                      action:@selector(removeItem:)
                               keyEquivalent:@""];
    [item setTarget:self];
    [treeActionMenu addItem:item];
    [item release];		
    
    // 
    
    
  }
  
//  NSLog(@"Made menu %@", treeActionMenu);
  
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] 
												convertPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)																		 
												toView:nil];
	
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
																			 location:menuOrigin
																	modifierFlags:NSLeftMouseDownMask // 0x100
																			timestamp:0
																	 windowNumber:[[(NSButton *)sender window] windowNumber]
																				context:[[(NSButton *)sender window] graphicsContext]
																		eventNumber:0
																		 clickCount:1
																			 pressure:1];
	
	
	[NSMenu popUpContextMenu:treeActionMenu withEvent:event forView:(NSButton *)sender];

	
	
}


- (IBAction) setMainItem:(id)sender
{
	if ([self.project valueForKey:@"mainFile"] == selectedItem) {
		[self.project setValue:nil forKey:@"mainFile"];
	} else {
		[self.project setValue:selectedItem forKey:@"mainFile"];
	}
	[self.projectOutlineView setNeedsDisplay:YES];
}

- (IBAction) revealItem:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *fullpath = [selectedItem valueForKey:@"pathOnDisk"];
	[ws selectFile:fullpath inFileViewerRootedAtPath:[fullpath stringByDeletingLastPathComponent]];
}

- (IBAction) renameItem:(id)sender
{
  [self renameItemAtRow:selectedRow];
}


- (IBAction) removeItem:(id)sender
{
	[self.projectItemTreeController remove:self];
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
	
	SEL select = @selector(locateItemDidEnd:returnCode:contextInfo:);
	[openPanel beginSheetForDirectory:nil
															 file:nil 
										 modalForWindow:[[[NSDocumentController sharedDocumentController] currentDocument] windowForSheet]
											modalDelegate:self 
										 didEndSelector:select
												contextInfo:nil];
	
	
}

- (void)locateItemDidEnd:(NSSavePanel*)savePanel 
              returnCode:(NSInteger)returnCode
             contextInfo:(void*)context
{
	if (returnCode == NSCancelButton) 
		return;
	
	NSString *path = [[savePanel URL] path];
	
	// set the path to the item
	[selectedItem setValue:path forKey:@"filepath"];
	
}	

#pragma mark -
#pragma mark Rename project items

- (void) renameItemAtRow:(NSInteger)row
{
	NSArray *items = [self.projectItemTreeController flattenedContent];
	
	// get the name of the item at this row
	itemBeingRenamed = row;
	
	NSString *oldName = [[items objectAtIndex:row] valueForKey:@"name"];
	[renameField setStringValue:oldName];
	
	// show the sheet
	[NSApp beginSheet:renameSheet
		 modalForWindow:[self windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
	// select only the name up to the extension
	NSText* textEditor = [renameSheet fieldEditor:YES forObject:renameField];
	NSRange r = [oldName rangeOfString:[oldName stringByDeletingPathExtension]];
	[textEditor setSelectedRange:r];
}

- (IBAction) endRenameSheet:(id)sender
{
	if ([sender tag] == 0) {
		[NSApp endSheet:renameSheet];
		[renameSheet orderOut:sender];
		return;
	}
	
	[NSApp endSheet:renameSheet];
	[renameSheet orderOut:sender];
	
	// else we go on and rename
  //	NSLog(@"Renaming to %@", [nameField stringValue]);
	
	[self performSelector:@selector(renameItemTo:) withObject:[renameField stringValue] afterDelay:0.0];
  //	[self renameItemTo:[nameField stringValue]];
	
}

- (void) renameItemTo:(NSString*)newName
{
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] disableUndoRegistration];
	
	NSArray *items = [projectItemTreeController flattenedContent];
	ProjectItemEntity *item = [items objectAtIndex:itemBeingRenamed];
  //	NSLog(@"Renaming %@", item);
	
	[item setValue:newName forKey:@"name"];
	
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] enableUndoRegistration];
	//	[self updateChangeCount:NSChangeDone];
	
	// notify all listeners that a file was renamed
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *dict = [NSDictionary dictionaryWithObject:item forKey:@"document"];
	[nc postNotificationName:TPDocumentWasRenamed object:projectItemTreeController userInfo:dict];
	
  // update status bar
  NSString *path = [item valueForKey:@"pathOnDisk"];
  if (path) {
    [self.statusView setProjectStatus:path];
  }

  
}


#pragma mark -
#pragma mark Actions

- (IBAction) openStandaloneWindow:(id)sender
{
	NSArray *selected = [self.projectItemTreeController selectedObjects];
	for (ProjectItemEntity *item in selected) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			if ([[item valueForKey:@"isText"] boolValue]) {
				[openDocuments standaloneWindowForFile:(FileEntity*)item];
			} else {				
				// pass the opening of the file to the system
				[[NSWorkspace sharedWorkspace] openFile:[item valueForKey:@"pathOnDisk"]];				
			}
		}
	}
}

- (IBAction) findInProject:(id)sender
{
  [controlsTabview selectTabViewItemAtIndex:4];
//	if (!finder) {
//		finder = [[FindInProjectController alloc] initWithProjectDocument:self];
//	}
//	
//	[finder showWindow:self];
//	[[finder window] makeKeyAndOrderFront:self];
	
}

#pragma mark -
#pragma mark Notification Handlers

- (void) handleTextEditorSelectionChanged:(NSNotification*)aNote
{
  NSInteger cursorPosition = [self.texEditorViewController.textView cursorPosition];
  NSInteger lineNumber = [self.texEditorViewController.textView lineNumber];
  if (lineNumber == NSNotFound) {
    [self.statusView setEditorStatus:[NSString stringWithFormat:@"line: -, char: %ld", cursorPosition]];
  } else {
    [self.statusView setEditorStatus:[NSString stringWithFormat:@"line: %ld, char: %ld", lineNumber, cursorPosition]];
  }
}


- (void) handleProjectOutlineViewSelectionChange:(NSNotification*)aNote
{
	if ([self.projectItemTreeController isDeleting])
		return;
  
	NSArray *all = [self.projectItemTreeController selectedObjects];	
//  NSLog(@"Selected %@", all);
	if ([all count] == 1) {
		NSManagedObject *item = [all objectAtIndex:0];
		NSString *path = [item valueForKey:@"pathOnDisk"];
		if (path) {
      [self.statusView setProjectStatus:path];
		}
		if ([item isKindOfClass:[FileEntity class]]) {
			if ([[item valueForKey:@"isText"] boolValue]) {
				if (openDocuments) {					
					[openDocuments addDocument:(FileEntity*)item];          
				}
			}
		}
	}
  
}

- (void) handleControlTabSelectionChanged:(NSNotification*)aNote
{
  id sender = [aNote object];
  selectedControlsTab = [sender indexOfSelectedTab];
}

#pragma mark -
#pragma mark Split view delegate

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
 if (subview == leftView || subview == rightView)
   return NO;
    
  return YES;
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
  return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 1) {
    NSRect b = [splitView bounds];
    return b.size.width-250;
  }
 
  return proposedMax;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 0) {
    return 200;
  }
  
  if (dividerIndex == 1) {
    return 400;
  }
  
  return proposedMin;
}

#pragma mark -
#pragma mark TeXEditorView delegate

- (NSUndoManager*)currentUndoManager
{
	id file = [openDocuments currentDoc];
	FileDocument *doc = [file document];
	return [doc undoManager];
}


-(NSArray*)listOfCitations
{
  //	NSLog(@"Generating list of citations...");
	NSMutableArray *citations = [NSMutableArray array];
	
	NSArray *docs = [[self project] valueForKey:@"items"];
	for (id doc in docs) {
    //		NSLog(@"Checking doc: %@", doc);
		if ([doc isKindOfClass:[FileEntity class]]) {
			FileEntity *file = (FileEntity*)doc;
      //			NSLog(@"Checking file %@", file);
			if ([[file valueForKey:@"extension"] isEqual:@"bib"]) {				
				NSString *content = [file workingContentString];
				if (content) {
					NSArray *bibTags = [content citations];
					[citations addObjectsFromArray:bibTags];
				}
			} else if ([[file valueForKey:@"extension"] isEqual:@"tex"]) {
				NSString *content = [file workingContentString];
				if (content) {
					NSArray *docTags = [content citations];			
					[citations addObjectsFromArray:docTags];			
				}				
			} else {
				// do nothing
			}
		}
	} // end loop
	
	return citations;	
}

-(NSArray*)listOfReferences
{
	NSMutableArray *tags = [NSMutableArray array];
	
	// go through all project documents
	NSArray *docs = [[self project] valueForKey:@"items"];
	for (id doc in docs) {				
		if ([doc isKindOfClass:[FileEntity class]]) {
			FileEntity *item = (FileEntity*)doc;
			if ([[item valueForKey:@"extension"] isEqual:@"tex"]) {
				NSString *content = [item workingContentString];
				if (content) {
          //NSLog(@"Collecting tags from %@", [doc name]);
					NSArray *docTags = [content referenceLabels];			
					[tags addObjectsFromArray:docTags];			
				}
			}
		}
	}
	
	return tags;	
}

-(NSArray*)listOfTeXFilesPrependedWith:(NSString*)prefix
{
	NSMutableArray *texfiles = [NSMutableArray array];
	NSArray *files = [project valueForKey:@"items"];
	for (ProjectItemEntity *item in files) {
		if ([item isKindOfClass:[FileEntity class]]) {
			[texfiles addObject:[prefix stringByAppendingString:[item valueForKey:@"filepath"]]];
		}
	}	
	return texfiles;
}


#pragma mark -
#pragma mark Open Documents Manager Delegate

-(void) openDocumentsManager:(OpenDocumentsManager*)aDocumentManager didSelectFile:(FileEntity*)aFile
{
  [self.projectItemTreeController selectItem:aFile];
}

#pragma mark -
#pragma mark ProjectOutlineController delegate

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile
{
	
	// first select the file
	[projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [projectItemTreeController indexPathToObject:aFile];
	[projectItemTreeController setSelectionIndexPath:idx];
	[self.texEditorViewController.textView expandAll:self];
	
	// Now highlight the search term in that 
	[self.texEditorViewController.textView setSelectedRange:aRange];
	[self.texEditorViewController.textView scrollRangeToVisible:aRange];
	[self.texEditorViewController.textView showFindIndicatorForRange:aRange];
  
  // and make sure we are colored
  [self.texEditorViewController.textView performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0.1];
	
	[[[[self windowControllers] objectAtIndex:0] window] makeKeyAndOrderFront:self];
}

- (BOOL) shouldGenerateOutline
{
  // if outline tab is selected....
  if (selectedControlsTab == 3) {
    return YES;
  }
  return NO;
}


#pragma mark -
#pragma mark Text Handling

- (void) insertTextToCurrentDocument:(NSString*)string
{
	[self.texEditorViewController.textView insertText:string];
	[self.texEditorViewController.textView colorVisibleText];
}

#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender
{
	// build path to the pdf file
	NSString *mainFile = [self.engine fileToCompile];
  
	NSArray *filesToClear = [[NSUserDefaults standardUserDefaults] valueForKey:TPTrashFiles]; // [NSArray arrayWithObjects:@"pdf", @"aux", @"log", @"dvi", @"ps", @"bbl", nil];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	for (NSString *ext in filesToClear) {
		error = nil;
		NSString *file = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
		if ([fm removeItemAtPath:file error:&error]) {
			[[ConsoleController sharedConsoleController] appendText:[NSString stringWithFormat:@"Deleted: %@", file]];
		} else {
			[[ConsoleController sharedConsoleController] error:[NSString stringWithFormat:@"Failed to delete: %@ [%@]", file, [error localizedDescription]]];
		} 
		
	}		
}

- (IBAction) projectTypeChanged:(id)sender
{
  [self.project setValue:[[sender selectedItem] title] forKey:@"type"];
}

- (IBAction) buildAndView:(id)sender
{
  openPDFAfterBuild = YES;
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPSaveOnCompile] boolValue]) {
		[self saveDocument:self];
	}
  [self build];
}

- (IBAction) buildProject:(id)sender
{
  openPDFAfterBuild = NO;
	
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPSaveOnCompile] boolValue]) {
		[self saveDocument:self];
	}
  
  [self build];	
}

- (void) build
{
  [self.engine reset];
  [self.engine build];
  
}

- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote
{
  [self showDocument];
  
  if (openPDFAfterBuild) {
    [self openPDF:self];
  }

}

- (IBAction) showNextResult:(id)sender
{
  if ([self.pdfSearchResults count] == 0) {
    return;
  }
  currentHighlightedPDFSearchResult++;
  if (currentHighlightedPDFSearchResult >= [self.pdfSearchResults count]) {
    currentHighlightedPDFSearchResult = 0;
  }
  PDFSelection *selection = [self.pdfSearchResults objectAtIndex:currentHighlightedPDFSearchResult];
  [self.pdfView setCurrentSelection:selection animate:YES];
  [self.pdfView scrollSelectionToVisible:self];
}

- (IBAction) searchPDF:(id)sender
{
  NSString *searchText = [sender stringValue];
  
  self.pdfSearchResults = [NSMutableArray arrayWithArray:[[self.pdfView document] findString:searchText withOptions:NSCaseInsensitiveSearch]];
  currentHighlightedPDFSearchResult = -1;
  [self showNextResult:self];
  
}


- (void) showDocument
{
  NSString *docPath = [self.engine compiledDocumentPath];
  if ([self engineProjectType:self.engine] == TPEngineCompilerLaTeX) {
    [self.pdfView setHidden:YES];
    return;
  }
  
  if (docPath) {
    PDFDocument *pdfDoc = [[[PDFDocument alloc] initWithURL: [NSURL fileURLWithPath:docPath]] autorelease];
    NSView *view = [self.pdfView documentView];
    NSRect r = [view visibleRect];
    BOOL hasDoc = ([self.pdfView document] != nil);
//    NSLog(@"Has doc %d: setting doc %@", hasDoc, pdfDoc);
    [self.pdfView setHidden:NO];
    [self.pdfView setDocument: pdfDoc];
    if (hasDoc) {
      [view scrollRectToVisible:r];
    }
  } else {
    [self.pdfView setHidden:YES];
  }
}


- (IBAction) openPDF:(id)sender
{
  NSString *docFile = [self.engine compiledDocumentPath];
	
	// check if the pdf exists
	if (docFile) {
		//NSLog(@"Opening %@", pdfFile);
		[[NSWorkspace sharedWorkspace] openFile:docFile];
	}
	
	// .. if not, ask the user if they want to typeset the project
}

- (BOOL) canViewPDF
{
	TeXFileEntity *mainfile = [project valueForKey:@"mainFile"];
	if (!mainfile) {
		return NO;
	}
	
	NSString *mainFilePath = [mainfile valueForKey:@"pathOnDisk"];
	NSString *pdfFilePath = [[mainFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:pdfFilePath]) {
		return YES;
	}
	
	return NO;	
}

- (BOOL) canTypeset
{
	if ([project valueForKey:@"mainFile"]) {
		return YES;
	}	
	return NO;
}

- (BOOL) canBibTeX
{
	if ([project valueForKey:@"mainFile"]) {
		return YES;
	}	
	return NO;	
}


#pragma mark -
#pragma mark Files and Folders

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
	NSInteger tag = [menuItem tag];
	
	if (tag == 1010) {		
		if ([openDocuments count]>0) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[tabView tabViewItemAtIndex:0] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1020) {
		if ([openDocuments count]>1) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[tabView tabViewItemAtIndex:1] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1030) {
		if ([openDocuments count]>2) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[tabView tabViewItemAtIndex:2] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1040) {
		if ([openDocuments count]>3) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[tabView tabViewItemAtIndex:3] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1050) {
		if ([openDocuments count]>4) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[tabView tabViewItemAtIndex:4] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	
	return [super validateMenuItem:menuItem];
}

- (IBAction)selectTab:(id)sender
{
	NSMenuItem *item = (NSMenuItem*)sender;
	NSInteger tag = [item tag];
	if (tag == 1010) {		
		[tabView selectTabViewItemAtIndex:0];
	} else if (tag == 1020) {
		[tabView selectTabViewItemAtIndex:1];
	} else if (tag == 1030) {
		[tabView selectTabViewItemAtIndex:2];
	} else if (tag == 1040) {
		[tabView selectTabViewItemAtIndex:3];
	} else if (tag == 1050) {
		[tabView selectTabViewItemAtIndex:4];
	} else {
		// do nothing
	}
}

- (IBAction) selectNextTab:(id)sender
{
	[tabView selectNextTabViewItem:self];
}

- (IBAction) selectPreviousTab:(id)sender
{
	[tabView selectPreviousTabViewItem:self];
}

- (IBAction) addExistingFile:(id)sender
{
	[self.projectItemTreeController addExistingFile:self toFolder:nil];
	[self.texEditorViewController.textView colorWholeDocument];
  //	[self updateChangeCount:NSChangeDone];
}

- (IBAction) addExistingFolder:(id)sender
{
	[self.projectItemTreeController addExistingFolder:self];
}

- (IBAction) addNewFolder:(id)sender
{
  [self newFolder:sender];
}

- (IBAction) addExistingFileToSelectedFolder:(id)sender
{
	[self.projectItemTreeController addExistingFile:self toFolder:(FolderEntity*)selectedItem];
}




- (NSArray*)getSelectedItems
{
	return [projectItemTreeController selectedObjects];
}

- (IBAction) jumpToMainFile:(id)sender
{
	TeXFileEntity *mainFile = [project valueForKey:@"mainFile"];
	
	if (mainFile) {
		[self.projectItemTreeController selectDocument:mainFile];
	}
	
}

- (IBAction) setMainFile:(id)sender
{
	// get selected file
	NSArray *items = [self getSelectedItems];
	if ([items count] == 1) {
		ProjectItemEntity *item = [items objectAtIndex:0];
		if ([[item valueForKey:@"extension"] isEqual:@"tex"]) {
			if ([project valueForKey:@"mainFile"] == item) {
				[project setValue:nil forKey:@"mainFile"];
			} else {
				[project setValue:item forKey:@"mainFile"];
			}
			[projectOutlineView setNeedsDisplay:YES];
		}
	}
}


- (IBAction) openProjectFolderInFinder:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  //	NSString *fullpath = [project valueForKey:@"folder"];
	NSString *fullpath = [[self fileURL] path];
	[ws selectFile:fullpath inFileViewerRootedAtPath:[fullpath stringByDeletingLastPathComponent]];	
}


- (NSString*) nameOfSelectedProjectItem
{
	NSArray *selected = [projectItemTreeController selectedObjects];
	if ([selected count] == 1) {
    id obj = [selected objectAtIndex:0];
    NSString *name = [obj valueForKey:@"name"];
    //NSLog(@"Selected project item %@", name);
    if (name) {
      return [NSString stringWithString:name];
    }
	}
	
	return @"selected";
}

- (IBAction) closeCurrentTab:(id)sender
{
	[openDocuments closeCurrentTab];
}

- (IBAction) newFolder:(id)sender
{
	[projectItemTreeController addNewFolder];
}

- (IBAction) newFile:(id)sender
{
	// ask the user for a new file name
	[NSApp beginSheet:newFileSheet
		 modalForWindow:[self windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
}

- (IBAction) endNewFileSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:newFileSheet];
		[newFileSheet orderOut:sender];
		return;
	}
	
	// before we add this file, we better check that the file doesn't exist
	NSString *name = [newFilenameTextField stringValue];
	NSString *pathOnDisk = [projectItemTreeController pathForInsertion];
	NSString *filename = [pathOnDisk stringByAppendingPathComponent:name];
	
  //	NSLog(@"Checking for file %@ ay %@", name, pathOnDisk);
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filename]) {
    //		NSLog(@"File exists...");
		NSAlert *alert = [NSAlert alertWithMessageText:@"Overwrite?"
																		 defaultButton:@"OK" alternateButton:@"Cancel"
																			 otherButton:nil 
												 informativeTextWithFormat:@"The file \u201c%@\u201d already exists. Do you want to overwrite it?", filename
											]; 
		[alert beginSheetModalForWindow:newFileSheet
											modalDelegate:self
										 didEndSelector:@selector(newFileExists:code:context:) 
												contextInfo:NULL];
		return;		
	}
	
	[self makeNewFile];
	
	
	
}

- (void)newFileExists:(NSAlert *)alert 
								 code:(int)choice 
							context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
		[self makeNewFile];
	} else {
		// do nothing
	}
	
}

- (void) makeNewFile
{
	NSString *name = [newFilenameTextField stringValue];	
	
	[projectItemTreeController addNewFile:name
														 atFilepath:nil
															extension:nil
																 isText:YES
																	 code:nil
														 asMainFile:NO
													 createOnDisk:YES];
	
	[NSApp endSheet:newFileSheet];
	[newFileSheet orderOut:self];
	return;
}

- (IBAction) newTeXFile:(id)sender
{
	[self showTemplatesSheet];	
}

- (void) templateSelectionChanged:(NSNotification*)aNote
{
  NSArray *selectedObjects = [templates selectedObjects];
  if ([selectedObjects count] == 1) {
    
    NSDictionary *selected = [selectedObjects objectAtIndex:0];
    NSString *code = [selected valueForKey:@"Code"];
    
    [documentCode scrollRectToVisible:NSZeroRect];
    
    [documentCode setString:code];
    [documentCode didChangeText];
    [documentCode performSelector:@selector(colorVisibleText)
                       withObject:nil
                       afterDelay:0.1];
    [documentCode performSelector:@selector(colorWholeDocument)
                       withObject:nil
                       afterDelay:0.2];
  }
}

- (void) showTemplatesSheet
{
	
	// we should ask the user what type of file they want
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	//NSLog(@"User defaults: %@", defaults);
	templateArray = [defaults valueForKey:TEDocumentTemplates];
	[templates setContent:templateArray];
	
	//NSLog(@"Got templates: %@", templateArray);
	
	NSString *suggestedDocumentName = [NSString stringWithFormat:@"untitled%02d", [[projectItemTreeController flattenedContent] count]];
	[documentName setStringValue:suggestedDocumentName];
	NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];	
	[documentCode setFont:font];
	
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(templateSelectionChanged:) 
                                               name:NSTableViewSelectionDidChangeNotification
                                             object:templateTable];
	
	[NSApp beginSheet:templateSheet
		 modalForWindow:[self windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
}

- (IBAction) addNewTemplate:(id)sender
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSString stringWithFormat:@"New Template %d", [[templates arrangedObjects] count]]
					forKey:@"Name"];
	[dict setValue:@"New empty template" forKey:@"Description"];
	
	[templates insertObject:dict atArrangedObjectIndex:0];
	[templates setSelectionIndex:0];	
}

- (IBAction) endTemplateSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:templateSheet];
		[templateSheet orderOut:sender];
		return;
	}
	
	// before we add this file, we better check that the file doesn't exist
	NSString *name = [documentName stringValue];
	if ([[name pathExtension] length]==0) {
		name = [name stringByAppendingPathExtension:@"tex"];
	}
	NSString *insertionPath = [projectItemTreeController pathForInsertion];
  //	NSLog(@"Checking path on disk %@", insertionPath);
	NSString *filename = [insertionPath stringByAppendingPathComponent:name];
	
  //	NSLog(@"Checking for file %@", filename);
	
	// check all project files
	NSArray *allitems = [projectItemTreeController flattenedContent];
	for (ProjectItemEntity *item in allitems) {
		if ([item isKindOfClass:[FileEntity class]]) {
			if ([[item pathOnDisk] isEqual:filename]) {
				
				NSAlert *alert = [NSAlert alertWithMessageText:@"File Exists"
																				 defaultButton:@"OK"
																			 alternateButton:nil
																					 otherButton:nil 
														 informativeTextWithFormat:@"The file \u201c%@\u201d already exists in the project; choose another name.", filename
													]; 
				
				[alert runModal];
				return;
			}
		}
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filename]) {
    //		NSLog(@"File exists...");
		NSAlert *alert = [NSAlert alertWithMessageText:@"Overwrite?"
																		 defaultButton:@"OK" alternateButton:@"Cancel"
																			 otherButton:nil 
												 informativeTextWithFormat:@"The file \u201c%@\u201d already exists. Do you want to overwrite it?", filename
											]; 
		[alert beginSheetModalForWindow:templateSheet
											modalDelegate:self
										 didEndSelector:@selector(newTexFileExists:code:context:) 
												contextInfo:NULL];
		return;		
	}
  
	[self makeNewTexFileFromTemplate];
}	

- (void)newTexFileExists:(NSAlert *)alert 
										code:(int)choice 
								 context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
		[self makeNewTexFileFromTemplate];
	} else {
		// do nothing
	}
	
}

- (void) makeNewTexFileFromTemplate
{
	//NSLog(@"Making new TeX file");
	
	NSString *name = [documentName stringValue];
	NSString *ext = [name pathExtension];
	if ([ext length]==0) {
		name = [name stringByAppendingPathExtension:@"tex"];
	}
	
	// Make the new file in the project
	id newFile = [projectItemTreeController addNewFile:name
                                          atFilepath:nil
                                           extension:[name pathExtension]
                                              isText:YES
                                                code:[documentCode string]
                                          asMainFile:[setAsMainFileCheckButton state]
                                        createOnDisk:YES];
  
	// save templates back to the user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *templatesToStore = [NSMutableArray array];
	for (NSDictionary *dict in [templates arrangedObjects]) {
		[templatesToStore addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
	}
	//NSLog(@"Setting templates: %@", templatesToStore);
	[defaults setObject:templatesToStore forKey:TEDocumentTemplates];
	[defaults synchronize];
	
	[self.texEditorViewController.textView colorWholeDocument];
	
	[NSApp endSheet:templateSheet];
	[templateSheet orderOut:self];
}

+ (NSString*) newArticleMainFileCode
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	//NSLog(@"User defaults: %@", defaults);
	NSArray *templateArray = [defaults valueForKey:TEDocumentTemplates];
  
	// Look for the article template
	NSString *code = nil;
	for (NSDictionary *dict in templateArray) {
		if ([[dict valueForKey:@"Name"] isEqual:@"Article"]) {
      //			code = [[[NSAttributedString alloc] initWithString:[dict valueForKey:@"Code"]] autorelease];
			code = [NSString stringWithString:[dict valueForKey:@"Code"]];
			break;
		}
	}
	
	if (!code) {
		
    
    code = [NSString stringWithString:@"\
            % Built-in Article Template\n\
            \\documentclass[11pt]{article}\n\
            \n\
            \\usepackage{ifpdf}\n\
            \\ifpdf\n\
            \\usepackage[pdftex]{graphicx}   % to include graphics\n\
            \\pdfcompresslevel=9\n\
            \\usepackage[pdftex,     % sets up hyperref to use pdftex driver\n\
            plainpages=false,   % allows page i and 1 to exist in the same document\n\
            breaklinks=true,    % link texts can be broken at the end of line\n\
            colorlinks=true,\n\
            pdftitle=My Document\n\
            pdfauthor=My Good Self\n\
            ]{hyperref} \n\
            \\usepackage{thumbpdf}\n\
            \\else\n\
            \\usepackage{graphicx}       % to include graphics\n\
            \\usepackage{hyperref}       % to simplify the use of \\href\n\
            \\fi \n\
            \n\
            \\title{Brief Article}\n\
            \\author{The Author}\n\
            \\date{}\n\
            \n\
            \\begin{document}\\n\
            \\maketitle\\n\
            \\section{Section}\n\
            \\subsection{Subsection}\n\
            \\end{document}"];  
  }
  
  return code;
}

- (void) addNewArticleMainFile
{
//  NSLog(@"********* Adding new main file to %@", project);
  
	NSString *code = [TeXProjectDocument newArticleMainFileCode];
	
	// check if main.tex exists
	NSString *newName = [NSString stringWithFormat:@"%@_main.tex", [project name]];
	NSString *filename = [[project folder] stringByAppendingPathComponent:newName];
	NSFileManager *fm = [NSFileManager defaultManager];
	int dd = 1;
	while ([fm fileExistsAtPath:filename]) {
		NSString *name = [NSString stringWithFormat:@"%@_main%d.tex", [project name], dd];
		filename = [[project folder] stringByAppendingPathComponent:name];
		dd++;
	}
//	NSLog(@"Filename %@", filename);
	
	id file = [projectItemTreeController addNewFile:[filename lastPathComponent]
                                       atFilepath:nil
                                        extension:@"tex"
                                           isText:YES
                                             code:code
                                       asMainFile:YES
                                     createOnDisk:YES];
	
	
	[file setValue:[NSNumber numberWithInt:0] forKey:@"sortIndex"];
   
	// add include folder
	[projectItemTreeController setSelectionIndexPath:nil];
	FolderEntity *includeFolder = [projectItemTreeController addFolder:@"include" withFilePath:nil createOnDisk:YES];	
  [includeFolder setValue:[NSNumber numberWithInt:1] forKey:@"sortIndex"];
  
	// add images folder
	[projectItemTreeController setSelectionIndexPath:nil];
	FolderEntity *imagesFolder = [projectItemTreeController addFolder:@"images" withFilePath:nil createOnDisk:YES];
  [imagesFolder setValue:[NSNumber numberWithInt:2] forKey:@"sortIndex"];
	
	// select the main file
	[openDocuments addDocument:(TeXFileEntity*)file];		
  [projectItemTreeController performSelector:@selector(selectItem:) withObject:file afterDelay:0.2];
  
}

- (IBAction) newMainTeXFile:(id)sender
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	NSManagedObject *newFile = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"TeXFile"
																																								 inManagedObjectContext:moc]
																			insertIntoManagedObjectContext:moc];
	
	
	[newFile setValue:@"main" forKey:@"name"];
	[projectItemTreeController addObject:newFile];
	[self.project setValue:newFile forKey:@"mainFile"];
	
	[newFile release];			
	
}

- (IBAction) deleteItem:(id)sender
{
	[projectItemTreeController remove:self];
}

- (BOOL) canAddNewFile
{
	return [projectItemTreeController canAdd];
}


- (BOOL) canAddNewTeXFile
{
	return [projectItemTreeController canAdd];
}

- (BOOL) canAddNewFolder
{
	return [projectItemTreeController canAdd];
}

- (BOOL) canRemove
{
	return [projectItemTreeController canRemove];
}

- (NSManagedObject*) addFileAtURL:(NSURL*)aURL copy:(BOOL)copyFile
{
	id doc = [self.projectItemTreeController addFileAtPath:[aURL path] toFolder:nil copy:copyFile];
	if (doc) {
		[openDocuments addDocument:doc];
		return doc;
	}
	
	return nil;
}

#pragma mark -
#pragma mark Saving

//+ (BOOL)autosavesInPlace
//{
//  return YES;
//}


- (BOOL)writeToURL:(NSURL *)absoluteURL
            ofType:(NSString *)typeName
  forSaveOperation:(NSSaveOperationType)saveOperation
originalContentsURL:(NSURL *)absoluteOriginalContentsURL
             error:(NSError **)error 
{
  
  if ([self fileURL] != nil) {
    [self setMetadataForStoreAtURL:[self fileURL]];
  }
  return [super writeToURL:absoluteURL
                    ofType:typeName
          forSaveOperation:saveOperation
       originalContentsURL:absoluteOriginalContentsURL
                     error:error];
}

//- (void)saveToURL:(NSURL *)url
//           ofType:(NSString *)typeName
// forSaveOperation:(NSSaveOperationType)saveOperation
//completionHandler:(void (^)(NSError *errorOrNil))completionHandler
//{
//	// commit changes for open docs
//	[openDocuments commitStatus];
//	
//	// make sure we save the files here
//	if ([self saveAllProjectFiles]) {
//		[super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:completionHandler];
//	}	
//  
//}
//
//- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url
//                             ofType:(NSString *)typeName
//                   forSaveOperation:(NSSaveOperationType)saveOperation
//{
//  return YES;
//}



- (BOOL)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName 
 forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
  
//	NSLog(@"Save %@, %d", typeName, saveOperation);
	
	// commit changes for open docs
	[openDocuments commitStatus];
	
	// make sure we save the files here
	if ([self saveAllProjectFiles]) {
    NSString *path = [absoluteURL path];
    NSURL *url = [NSURL fileURLWithPath:path];
		return [super saveToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
	}	
	return NO;
}

- (BOOL) saveAllProjectFiles
{
	// write contents of all files to disk
	UKKQueue *queue = [UKKQueue sharedFileWatcher];
	NSArray *allItems = [projectItemTreeController flattenedContent];
  
//  NSLog(@"Saving %@", allItems);
	BOOL success = YES;
	BOOL watching = NO;
	for (ProjectItemEntity *item in allItems) {
		if ([item isKindOfClass:[FileEntity class]]) {
			FileEntity *file = (FileEntity*)item;
			watching = [queue watchingPath:[file pathOnDisk]];
			//NSLog(@"Watching %@ %d", [file pathOnDisk], watching);
			if (watching) {
				[queue removePath:[file pathOnDisk]];
			}
			success = [file saveContentsToDisk];
			if (watching) {
				[queue addPathToQueue: [file pathOnDisk]
							 notifyingAbout: UKKQueueNotifyAboutWrite];
			}
			//NSLog(@"Saved %@ %d ", [file pathOnDisk], success);
		} // end if item is a file
	}
	return success;
}

- (void)saveDocument:(id)sender
{
  [super saveDocument:self];
}


#pragma mark -
#pragma mark LaTeX Engine Delegate

- (NSString*) engineDocumentToCompile:(TPLaTeXEngine*)anEngine
{
  return [[[self.project valueForKey:@"mainFile"] valueForKey:@"pathOnDisk"] stringByDeletingPathExtension];
}

- (NSString*) engineWorkingDirectory:(TPLaTeXEngine*)anEngine
{
  return [self.project folder]; 
}

- (BOOL) engineCanBibTeX:(TPLaTeXEngine*)anEngine
{
  if ([self.project valueForKey:@"mainFile"]) {
    return YES;
  }	
	return NO;	 
}

- (TPEngineCompiler) engineProjectType:(TPLaTeXEngine*)anEngine
{
  if ([[self.project valueForKey:@"type"] isEqualToString:@"latex"]) {
    return TPEngineCompilerLaTeX;
  } else {
    return TPEngineCompilerPDFLaTeX;
  }
}

- (BOOL) engineDocumentIsProject:(TPLaTeXEngine*)anEngine
{
  return YES;
}


@end
