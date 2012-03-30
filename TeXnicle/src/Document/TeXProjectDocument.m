//
//  TeXProjectDocument.m
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TeXProjectDocument.h"
#import "ProjectEntity.h"
#import "ProjectItemTreeController.h"
#import "FileEntity.h"
#import "TeXFileEntity.h"
#import "TPLaTeXEngine.h"
#import "ConsoleController.h"
#import "MHControlsTabBarController.h"
#import "FinderController.h"
#import "NSString+LaTeX.h"
#import "TPImageViewerController.h"
#import "PaletteController.h"
#import "PDFViewerController.h"
#import "Bookmark.h"
#import "MHLineNumber.h"
#import "TPEngineManager.h"
#import "TPEngine.h"
#import "Settings.h"
#import "UKXattrMetadataStore.h"
#import "NSString+RelativePath.h"
#import "NSArray+LaTeX.h"
#import "TPSupportedFilesManager.h"
#import "NSApplication+SystemVersion.h"
#import "MHSynctexController.h"
#import "BibliographyEntry.h"
#import "RegexKitLite.h"

#define kSplitViewLeftMinSize 230.0
#define kSplitViewCenterMinSize 400.0
#define kSplitViewRightMinSize 400.0

@implementation TeXProjectDocument

@synthesize statusTimer;

@synthesize documentOutlineViewcontroller;
@synthesize documentOutlineViewContainer;

@synthesize createFileButton;
@synthesize createFolderButton;

@synthesize pdfViewer;

@synthesize library;
@synthesize libraryContainerView;

@synthesize bookmarkManager;
@synthesize bookmarkContainerView;

@synthesize pdfViewerController;
@synthesize project;
@synthesize projectOutlineView;
@synthesize controlsTabview;
@synthesize openDocuments;
@synthesize projectItemTreeController;
@synthesize texEditorViewController;
@synthesize texEditorContainer;

@synthesize fileMonitor;
@synthesize imageViewerController;
@synthesize imageViewerContainer;
@synthesize pdfHasSelection;

@synthesize finder;
@synthesize finderContainerView;

@synthesize palette;
@synthesize paletteContainverView;

@synthesize engineManager;
@synthesize engineSettings;
@synthesize engineSettingsContainer;

@synthesize statusViewContainer;
@synthesize statusViewController;

@synthesize splitview;
@synthesize leftView;
@synthesize rightView;
@synthesize centerView;

@synthesize templateEditor;

@synthesize controlsTabBarController;

@synthesize miniConsole;
@synthesize embeddedConsoleContainer;
@synthesize embeddedConsoleViewController;

@synthesize liveUpdateTimer;

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [projectOutlineController deactivate];
  
  [self.statusTimer invalidate];
  self.statusTimer = nil;
 
  self.statusViewController = nil;
//  self.documentOutlineViewcontroller.delegate = nil;
//  self.documentOutlineViewcontroller = nil;
  self.bookmarkManager = nil;
  self.palette = nil;
  self.project = nil;  
  self.pdfViewerController = nil;
  self.imageViewerController = nil;
  self.texEditorViewController = nil;
  self.fileMonitor = nil;
  self.finder = nil;
  self.library = nil;
  self.engineManager = nil;
  self.engineSettings = nil;
  self.pdfViewer = nil;
  self.miniConsole = nil;
  self.embeddedConsoleViewController = nil;
  [self.liveUpdateTimer invalidate];
  self.liveUpdateTimer = nil;
  
  [super dealloc];
}

- (void) awakeFromNib
{
  _building = NO;
  _liveUpdate = NO;
  self.liveUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doLiveBuild) userInfo:nil repeats:YES];
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
    NSMutableDictionary *metadata = [[[psc metadataForPersistentStore:pStore] mutableCopy] autorelease];
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

//+ (BOOL)autosavesInPlace
//{
//  return YES;
//}

//- (BOOL)revertToContentsOfURL:(NSURL *)inAbsoluteURL ofType:(NSString *)inTypeName error:(NSError **)outError
//{
//  NSLog(@"Reverting to %@ for type %@", inAbsoluteURL, inTypeName);
//  return [super revertToContentsOfURL:inAbsoluteURL ofType:inTypeName error:outError];
//}


- (void)windowWillEnterVersionBrowser:(NSNotification *)notification
{
//  NSLog(@"Window will enter versions browser");
  _leftDividerPostion = self.leftView.frame.size.width;
  _rightDividerPostion = self.splitview.frame.size.width - self.rightView.frame.size.width;
  _windowFrame = self.windowForSheet.frame;
//  [self.splitview setPosition:0 ofDividerAtIndex:0];
//  [self.splitview setPosition:self.splitview.frame.size.width ofDividerAtIndex:1];
  
  // disable some UI 
  [self.texEditorViewController.textView setEditable:NO];  
  [self.statusViewController enable:NO];
}

- (void)windowDidEnterVersionBrowser:(NSNotification *)notification
{
//  NSLog(@"Window did enter versions");
  _inVersionsBrowser = YES;
}

- (void)windowWillExitVersionBrowser:(NSNotification *)notification
{
//  NSLog(@"Window will exit versions browser");
}

- (void)windowDidExitVersionBrowser:(NSNotification *)notification
{
//  NSLog(@"Window did exit versions browser");
  if (self.windowForSheet == [notification object]) {
    _inVersionsBrowser = NO;
    
    CAAnimation *anim = [CABasicAnimation animation];
    [anim setDelegate:self];
    [self.windowForSheet setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frame"]];
    
    [self.windowForSheet.animator setFrame:_windowFrame display:YES];
  }
//  [self performSelector:@selector(restoreSplitViewPositions) withObject:nil afterDelay:0.2];
  
  // reenable some UI
  [self.texEditorViewController.textView setEditable:YES];  
  [self.statusViewController enable:YES];
}


- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
//  [self performSelector:@selector(restoreSplitViewPositions) withObject:nil afterDelay:0.2];
  [self.windowForSheet makeKeyAndOrderFront:self];
}

- (void) restoreSplitViewPositions
{
  //  NSLog(@"Restoring positions %f, %f", _leftDividerPostion, _rightDividerPostion);
  [self.splitview setPosition:_leftDividerPostion ofDividerAtIndex:0];
  [self.splitview setPosition:_rightDividerPostion ofDividerAtIndex:1];
}

- (void) setupDocument
{
//  NSLog(@"setupDocument");
  
  // setup settings
  self.engineSettings = [[[TPEngineSettingsController alloc] initWithDelegate:self] autorelease];
  [[self.engineSettings view] setFrame:[self.engineSettingsContainer bounds]];
  [self.engineSettingsContainer addSubview:[self.engineSettings view]];
//  NSLog(@"Setup settings");
  
  // Setup text view  
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
  [self.texEditorViewController setPerformSyntaxCheck:YES];
  
  self.openDocuments.texEditorViewController = self.texEditorViewController;
  [self.openDocuments disableTextView];
//  NSLog(@"Setup tex editor");
  
  // setup status view
  self.statusViewController = [[[TPStatusViewController alloc] init] autorelease];
  [self.statusViewController.view setFrame:[self.statusViewContainer bounds]];
  [self.statusViewContainer addSubview:self.statusViewController.view];
  statusViewIsShowing = YES;
  if (![self.project.settings.showStatusBar boolValue]) {
    // the status bar is showing by default, so toggle it out
    [self toggleStatusBar:NO];
  }
//  NSLog(@"Setup status");
  
  // setup image viewer
  self.imageViewerController = [[[TPImageViewerController alloc] init] autorelease];
  self.openDocuments.imageViewerController = self.imageViewerController;
  self.openDocuments.imageViewContainer = self.imageViewerContainer;
  [[self.imageViewerController view] setFrame:[self.imageViewerContainer bounds]];
  [self.imageViewerContainer addSubview:[self.imageViewerController view]];
//  NSLog(@"Setup image viewer");
  
  // setup pdf viewer
  self.pdfViewerController = [[[PDFViewerController alloc] initWithDelegate:self] autorelease];
  [self.pdfViewerController.view setFrame:[pdfViewerContainerView bounds]];
  [pdfViewerContainerView addSubview:self.pdfViewerController.view];
//  NSLog(@"Setup pdf viewer");
    
  // setup library
  self.library = [[[LibraryController alloc] initWithDelegate:self] autorelease];
  NSView *libraryView = [self.library view];
  [libraryView setFrame:[self.libraryContainerView bounds]];
  [self.libraryContainerView addSubview:libraryView];
//  NSLog(@"Setup library");
  
  // setup file monitor
  self.fileMonitor = [TPFileMonitor monitorWithDelegate:self];
//  NSLog(@"Setup filemonitor");
  
  // setup finder
  self.finder = [[[FinderController alloc] initWithDelegate:self] autorelease];
  [self.finder.view setFrame:[self.finderContainerView bounds]];
  [self.finderContainerView addSubview:self.finder.view];
//  NSLog(@"Setup finder");
  
  // setup palette
  self.palette = [[[PaletteController alloc] initWithDelegate:self] autorelease];
  NSView *paletteView = [self.palette view];
  [paletteView setFrame:[self.paletteContainverView bounds]];
  [self.paletteContainverView addSubview:paletteView];
//  NSLog(@"Setup palette");
  
  // setup bookmark manager
  self.bookmarkManager = [[[BookmarkManager alloc] initWithDelegate:self] autorelease];
  NSView *bookmarkView = [self.bookmarkManager view];
  [bookmarkView setFrame:[self.bookmarkContainerView bounds]];
  [self.bookmarkContainerView addSubview:bookmarkView];
//  NSLog(@"Setup bookmark manager");
  
  // set up document outline view controller
//  self.documentOutlineViewcontroller = [[[TPDocumentOutlineViewController alloc] initWithDelegate:self] autorelease];
//  [self.documentOutlineViewcontroller.view setFrame:[self.documentOutlineViewContainer bounds]];
//  [self.documentOutlineViewContainer addSubview:self.documentOutlineViewcontroller.view];
  
  // setup engine manager
  self.engineManager = [TPEngineManager engineManagerWithDelegate:self];
//  NSLog(@"Setup engine manager");
  
  // register the mini console
  [self.engineManager registerConsole:self.miniConsole];
  
  // embedded console
  self.embeddedConsoleViewController = [[[TPConsoleViewController alloc] init] autorelease];
  [self.embeddedConsoleViewController.view setFrame:[self.embeddedConsoleContainer bounds]];
  [self.embeddedConsoleContainer addSubview:self.embeddedConsoleViewController.view];
  [self.engineManager registerConsole:self.embeddedConsoleViewController];
  
	// Don't select anything
	[self.projectItemTreeController setSelectionIndexPath:nil];
  
	// Double-click the tree to open standalone windows
	[self.projectOutlineView setDoubleAction:@selector(openStandaloneWindow:)];
  
	// Update the project folder in case the file was moved
	NSString *projectFolder = [[[self fileURL] path] stringByDeletingLastPathComponent];
	NSString *saveFolder = [self.project valueForKey:@"folder"];
  if (![saveFolder isEqual:projectFolder]) {
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
             name:TPEngineCompilingCompletedNotification
           object:self.engineManager];
  
  [nc addObserver:self
         selector:@selector(handleControlTabSelectionChanged:)
             name:TPControlsTabSelectionDidChangeNotification 
           object:nil];
  
  [nc addObserver:self
         selector:@selector(handleTextEditorSelectionChanged:)
             name:NSTextViewDidChangeSelectionNotification 
           object:self.texEditorViewController.textView];
  
  [nc addObserver:self
         selector:@selector(handleTextEditorDidProcessEdits:)
             name:TPFileItemTextStorageChangedNotification
           object:nil];
  
  [nc addObserver:self
         selector:@selector(handleLineNumberClickedNotification:) 
             name:TELineNumberClickedNotification
           object:self.texEditorViewController.textView];
    
//  NSLog(@"Set status view values");
  [self.statusViewController setFilenameText:@""];
  [self.statusViewController setEditorStatusText:@"No Selection."];
  [self.statusViewController setShowRevealButton:NO];
  
//	// spell checker language
//	NSString *language = [[NSUserDefaults standardUserDefaults] valueForKey:TPSpellCheckerLanguage];
//	if (![language isEqual:@""]) {
//    //		NSLog(@"Setting language to %@", language);
//		[[NSSpellChecker sharedSpellChecker] setLanguage:language];
//	}
  
  
  // ensure the project has the same name as on disk
//  NSLog(@"Setting up project %@", self.project);
  NSString *newProjectName = [[[self fileURL] lastPathComponent] stringByDeletingPathExtension];
//  NSLog(@"Setting project name from %@ to %@", self.project.name, newProjectName);
  if (![[self.project valueForKey:@"name"] isEqualToString:newProjectName]) {
    [self.project setValue:newProjectName forKey:@"name"];
  }

  self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateStatusView)
                                                    userInfo:nil
                                                     repeats:YES];
  
//  NSLog(@"Setup document finished.");
  // Show document
  [self showDocument];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
//  NSLog(@"windowControllerDidLoadNib %@", [self windowForSheet]);
  [super windowControllerDidLoadNib:aController];
  
  self.miniConsole = [[[MHMiniConsoleViewController alloc] init] autorelease];
  NSArray *items = [[[self windowForSheet] toolbar] items];
  for (NSToolbarItem *item in items) {
    if ([[item itemIdentifier] isEqualToString:@"MiniConsole"]) {
      NSBox *box = (NSBox*)[item view];
      [box setContentView:self.miniConsole.view];
    }
  }
  [self.miniConsole message:@"Welcome to TeXnicle."];
  
  [self performSelector:@selector(setupDocument) withObject:nil afterDelay:0];
  [self performSelector:@selector(restoreOpenTabs) withObject:nil afterDelay:0];
  [self performSelector:@selector(restoreUIstate) withObject:nil afterDelay:0];
}

- (void) restoreOpenTabs
{
  
  for (ProjectItemEntity *item in self.project.items) {
    if ([item isKindOfClass:[FileEntity class]]) {
      FileEntity *file = (FileEntity*)item;
      if ([[file valueForKey:@"wasOpen"] boolValue]) {        
        [self.openDocuments addDocument:file];          
      }
      [file setPrimitiveValue:[NSNumber numberWithBool:NO] forKey:@"wasOpen"];
    }
  }
  
  FileEntity *selected = [self.project valueForKey:@"selected"];
  if (selected) {
    [self performSelector:@selector(selectTabForFile:) withObject:selected afterDelay:0.2];
  }
  

  
}


- (void)windowWillClose:(NSNotification *)notification 
{
//  NSLog(@"Window will close %@ / %@", [notification object], [self windowForSheet]);
  _windowIsClosing = YES;
  
  // stop timer
  [self.statusTimer invalidate];
  self.statusTimer = nil;
  
  // stop file monitor
	self.fileMonitor.delegate = nil;
  
  // stop engine manager
  self.engineManager.delegate = nil;
  
	// close all tabs
	for (NSTabViewItem *item in [self.openDocuments.tabView tabViewItems]) {
		[self.openDocuments.tabView removeTabViewItem:item];
	}
	
	NSWindow *window = [[[self windowControllers] objectAtIndex:0] window];
	[window setDelegate:nil];
//  NSLog(@"Open windows %d", [[[NSDocumentController sharedDocumentController] documents] count]);
	if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
		if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
			[[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
      [[ConsoleController sharedConsoleController] close];
		}
	}
}

- (void) restoreUIstate
{
  // controls tab
  [self.controlsTabBarController selectTabAtIndex:[self.project.uiSettings.selectedControlsTab integerValue]];
  
  if(![NSApp isLion]) {
    // controls width
    NSRect r = [self.leftView frame];
    r.size.width = [self.project.uiSettings.controlsWidth floatValue];
    if (r.size.width>=0) {
      [self.leftView setFrame:r];
    }
    
    // editor width
    r = [self.centerView frame];
    r.size.width = [self.project.uiSettings.editorWidth floatValue];
    if (r.size.width>=0) {
      [self.centerView setFrame:r];
    }
  }
  // pdf viewer visible rect
  [self.pdfViewerController restoreVisibleRectFromPersistentString:self.project.uiSettings.pdfViewScrollRect];
  
}

- (void) captureUIstate
{
  if (_inVersionsBrowser)
    return;
  
  if (self.project == nil) {
    return;
  }
  
  // selected controls tab
  self.project.uiSettings.selectedControlsTab = [NSNumber numberWithInteger:[self.controlsTabBarController indexOfSelectedTab]];
  
  // controls width
  NSRect r = [self.leftView frame];
  self.project.uiSettings.controlsWidth = [NSNumber numberWithFloat:r.size.width];
  
  // editor width
  r = [self.centerView frame];
  self.project.uiSettings.editorWidth = [NSNumber numberWithFloat:r.size.width];
  
  // pdf viewer visible rect
  self.project.uiSettings.pdfViewScrollRect = [self.pdfViewerController visibleRectForPersisting];  
  
}

+ (void) createTeXnicleProjectAtURL:(NSURL*)aURL
{
  // make a new managed object context  
  NSManagedObjectContext *moc = [TeXProjectDocument managedObjectContextForStoreURL:aURL];
  NSString *path = [aURL path];
  
  [moc processPendingChanges];
  [[moc undoManager] disableUndoRegistration];
  NSEntityDescription *projectDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:moc];
  ProjectEntity *project = [[[ProjectEntity alloc] initWithEntity:projectDescription insertIntoManagedObjectContext:moc] autorelease]; 
  
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
    return;
  }
}

+ (NSSavePanel*)getDocumentURLSavePanel
{
  // get a project name from the user
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setTitle:@"Save New Project..."];
  [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"texnicle"]];
  [savePanel setPrompt:@"Create"];
  [savePanel setMessage:@"Choose a name and location for the new TeXnicle project document."];
  [savePanel setNameFieldLabel:@"Create Project:"];
  [savePanel setAllowsOtherFileTypes:NO];
  [savePanel setCanCreateDirectories:YES];
  return savePanel;
}

+ (NSURL*)getNewDocumentURL
{
  
  NSSavePanel *savePanel = [TeXProjectDocument getDocumentURLSavePanel];
  
    
  BOOL result = [savePanel runModal];
  
  if (result == NSFileHandlingPanelCancelButton) {
    return nil;
  }
  
  NSString *path = [[savePanel URL] path];
  
  if (!path) {
    return nil;
  }
  
  
  NSURL *url = [NSURL fileURLWithPath:path];
  
  return url;
}

- (void) setupProject
{
  NSURL *aURL = [self fileURL];
  NSString *path = [aURL path];
  NSManagedObjectContext *moc = [self managedObjectContext];
  [moc processPendingChanges];
  [[moc undoManager] disableUndoRegistration];
//  NSEntityDescription *projectDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:moc];
//  ProjectEntity *project = [[NSManagedObject alloc] initWithEntity:projectDescription insertIntoManagedObjectContext:moc]; 
  
  // set name and folder of the project
  NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
  NSString *folder = [path stringByDeletingLastPathComponent];
  [self.project setValue:name forKey:@"name"];
  [self.project setValue:folder forKey:@"folder"]; 
  
  [moc processPendingChanges];
  [[moc undoManager] enableUndoRegistration];
  
  NSError *error = nil;
  [moc save:&error];
  if (error) {
    [NSApp presentError:error];
    return;
  }  
}


+ (TeXProjectDocument*)createNewTeXnicleProject
{
  NSURL *url = [TeXProjectDocument getNewDocumentURL];
  
  if (!url) {
    return nil;
  }
  
  NSString *path = [url path];
  
  // Remove file if it is there
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@".yyyy_MM_dd_HH_mm_ss"];
    NSString *movedPath = [path stringByAppendingFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    NSError *moveError = nil;
    [fm moveItemAtPath:path toPath:movedPath error:&moveError];
    if (moveError) {
      [NSApp presentError:moveError];
      return nil;
    }
  }
  
  // create project
  [TeXProjectDocument createTeXnicleProjectAtURL:url];
  
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
//  NSLog(@"managedObjectContextForStoreURL %@", storeURL);
	//	Find the document's model	
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	if (!model)
		return nil;
	
//  NSLog(@"Got model %@", model);
	//	Create a persistent store
  
	NSPersistentStoreCoordinator *psc = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model] autorelease];
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
	
	NSManagedObjectContext* managedContext = [[[NSManagedObjectContext alloc] init] autorelease];
	if (!managedContext)
		return nil;
	
	managedContext.persistentStoreCoordinator = psc;
	managedContext.undoManager = nil;
	
	return managedContext;
}

- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL*)url 
																					 ofType:(NSString*)fileType
															 modelConfiguration:(NSString*)configuration
																		 storeOptions:(NSDictionary*)storeOptions
																						error:(NSError**)error
{
//  NSLog(@"configurePersistentStoreCoordinatorForURL %@", url);
  NSMutableDictionary *options = nil;
  if (storeOptions != nil) {
    options = [storeOptions mutableCopy];
  } else {
    options = [[NSMutableDictionary alloc] init];
  }
	
  [options setObject:[NSNumber numberWithBool:YES] 
							forKey:NSMigratePersistentStoresAutomaticallyOption];
  [options setObject:[NSNumber numberWithBool:YES]
              forKey:NSInferMappingModelAutomaticallyOption];
  
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

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{    
  if (_inVersionsBrowser) {
    return NO;
  }
  
  // build
  if ([theItem tag] == 30) {
    if ([self.engineManager isCompiling]) {
      return NO;
    }
  }
  
  // build and view
  if ([theItem tag] == 40) {
    if ([self.engineManager isCompiling]) {
      return NO;
    }
  }
  
  // trash
  if ([theItem tag] == 50) {
    if ([self.engineManager isCompiling]) {
      return NO;
    }
  }
  
  // view
  if ([theItem tag] == 45) {
    if (![self compiledDocumentPath]) {
      return NO;
    }
  }
  
  return YES;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (_inVersionsBrowser) {
    return NO;
  }
  
  if (anItem == self.createFolderButton) {
    return [self.projectItemTreeController canAdd];
  }
  
  if (anItem == self.createFileButton) {
    return YES;
  }
  
  return [super validateUserInterfaceItem:anItem];
}

- (void) updateStatusView
{
	NSArray *all = [self.projectItemTreeController selectedObjects];	
  //  NSLog(@"Selected %@", all);
  NSString *path = nil;
	if ([all count] == 1) {
		NSManagedObject *item = [all objectAtIndex:0];
    path = [item valueForKey:@"pathOnDisk"];
  }  
  
  // if nothing is selected in the outline view, fall back to the current
  // file in the open documents manager.
  if (!path && [all count]==0) {
    path = [[openDocuments currentDoc] valueForKey:@"pathOnDisk"];
  }
  
  if (path) {
    [self.statusViewController setFilenameText:path];
    [self.statusViewController enable:YES];    
  } else {
    [self.statusViewController setFilenameText:path];
    [self.statusViewController enable:NO];    
  }
  
}

- (IBAction)reopenUsingEncoding:(id)sender
{
  FileEntity *file = [self.openDocuments currentDoc];
//  NSLog(@"Reloading doc %@", file);
  // clear the xattr
  [UKXattrMetadataStore setString:@""
                           forKey:@"com.bobsoft.TeXnicleTextEncoding"
                           atPath:[file pathOnDisk]
                     traverseLink:YES];
  
  [file reloadFromDiskWithEncoding:[sender title]];
  [self.openDocuments closeCurrentTab];
  [self.openDocuments addDocument:file];
}

- (NSManagedObject *)project
{
	if (project != nil) {
		return project;
	}
//  NSLog(@"Fetching project...");
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
//    NSLog(@"   got project");
		return project;
	}
	
	if (fetchError != nil) {
		[self presentError:fetchError];
	}
	else {
		// should present custom error message...
	}
	[fetchRequest release];
//  NSLog(@"   got nil");
	return nil;
}


#pragma mark -
#pragma mark Tree Action Menu

- (IBAction) showCategoryActionMenu:(id)sender
{
  if (_inVersionsBrowser) {
    return;
  }
  
	if (treeActionMenu) {
    [treeActionMenu release];
    treeActionMenu = nil;
  }
  
  selectedItem = nil;
  
	// Make popup menu with bound actions
	treeActionMenu = [[NSMenu alloc] initWithTitle:@"Project Tree Action Menu"];	
	[treeActionMenu setAutoenablesItems:NO];
  
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
  [self showDocument];
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
  [self.projectOutlineView locateItem:self];
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
  [self updateStatusView];
  
}


#pragma mark -
#pragma mark Actions

- (IBAction)togglePanelFocus:(id)sender
{
  NSWindow *w = [self windowForSheet];
  if ([w firstResponder] == self.texEditorViewController.textView) {
    [w makeFirstResponder:self.pdfViewerController.pdfview];
  } else {
    [w makeFirstResponder:self.texEditorViewController.textView];
  }
}

- (IBAction)printDocument:(id)sender
{
  // set printing properties
  NSPrintInfo *myPrintInfo = [[[NSPrintInfo alloc] initWithDictionary:[[self printInfo] dictionary]] autorelease];
  [myPrintInfo setHorizontalPagination:NSFitPagination];
  [myPrintInfo setHorizontallyCentered:YES];
  [myPrintInfo setVerticallyCentered:NO];
  [myPrintInfo setLeftMargin:72.0];
  [myPrintInfo setRightMargin:72.0];
  [myPrintInfo setTopMargin:72.0];
  [myPrintInfo setBottomMargin:90.0];
  
  // create new view just for printing
  NSTextView *printView = [[NSTextView alloc] initWithFrame:[myPrintInfo imageablePageBounds]];
//  NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 8.5 * 72, 11.0 * 72)];
  //	[MyPrintInfo imageablePageBounds]];
  
  // copy the textview into the printview
  NSRange textViewRange = NSMakeRange(0, [[self.texEditorViewController.textView textStorage] length]);
  NSRange printViewRange = NSMakeRange(0, [[printView textStorage] length]);
  
  [printView replaceCharactersInRange:printViewRange 
                              withRTF:[self.texEditorViewController.textView RTFFromRange: textViewRange]];
  
  NSPrintOperation *op = [NSPrintOperation printOperationWithView:printView printInfo:myPrintInfo];
  [op setShowsPrintPanel:YES];
  [self runModalPrintOperation: op delegate: nil didRunSelector: NULL 
                   contextInfo: NULL];
  
  [printView release];
  
}

- (IBAction)toggleStatusView:(id)sender
{
  [self toggleStatusBar:YES];
}

- (void) toggleStatusBar:(BOOL)animate
{
  NSRect tefr = [self.texEditorContainer frame];
  NSRect svfr = [self.statusViewContainer frame];
  
  id tec;
  id sbc;
  if (animate) {
    tec = self.texEditorContainer.animator;
    sbc = self.statusViewContainer.animator;
  } else {
    tec = self.texEditorContainer;
    sbc = self.statusViewContainer;
  }
  
  if (statusViewIsShowing) {
    statusViewIsShowing = NO;
    // move status view out
    [sbc setFrame:NSMakeRect(svfr.origin.x, svfr.origin.y-svfr.size.height, svfr.size.width, svfr.size.height)];    
    // stretch tex editor container
    [tec setFrame:NSMakeRect(tefr.origin.x, tefr.origin.y-svfr.size.height, tefr.size.width, tefr.size.height+svfr.size.height)]; 
  } else {
    statusViewIsShowing = YES;
    // move status view in
    [sbc setFrame:NSMakeRect(svfr.origin.x, svfr.origin.y+svfr.size.height, svfr.size.width, svfr.size.height)];    
    // shrink tex editor container
    [tec setFrame:NSMakeRect(tefr.origin.x, tefr.origin.y+svfr.size.height, tefr.size.width, tefr.size.height-svfr.size.height)];
  }
  
  // update settings if necessary
  if ([self.project.settings.showStatusBar boolValue] != statusViewIsShowing) {
    self.project.settings.showStatusBar = [NSNumber numberWithBool:statusViewIsShowing];        
  }
}

- (IBAction) openStandaloneWindow:(id)sender
{
	NSArray *selected = [self.projectItemTreeController selectedObjects];
	for (ProjectItemEntity *item in selected) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			if ([[item valueForKey:@"isText"] boolValue]) {
        [(FileEntity*)item increaseActiveCount];
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
  [self.windowForSheet makeFirstResponder:self.finder.searchField];
}

#pragma mark -
#pragma mark Notification Handlers

- (void) handleLineNumberClickedNotification:(NSNotification*)aNote
{
  MHLineNumber *linenumber = [[aNote userInfo] valueForKey:@"LineNumber"];
//  NSLog(@"Clicked on %@", linenumber);
  // Check if there is already a bookmark for this file
  if ([self hasBookmarkAtLine:linenumber.number]) {
    [self removeBookmarkAtLine:linenumber.number];
  } else {
    [self addBookmarkAtLine:linenumber.number];
  }
}

- (void) handleTextEditorDidProcessEdits:(NSNotification*)aNote
{
  [self.projectOutlineView setNeedsDisplay:YES];
}

- (void) handleTextEditorSelectionChanged:(NSNotification*)aNote
{
  NSInteger cursorPosition = [self.texEditorViewController.textView cursorPosition];
  NSInteger lineNumber = [self.texEditorViewController.textView lineNumber];
  if (lineNumber == NSNotFound) {
    [self.statusViewController setEditorStatusText:[NSString stringWithFormat:@"line: -, char: %ld", cursorPosition]];
  } else {
    [self.statusViewController setEditorStatusText:[NSString stringWithFormat:@"line: %ld, char: %ld", lineNumber, cursorPosition]];
  }
}


- (void) handleProjectOutlineViewSelectionChange:(NSNotification*)aNote
{
	if ([self.projectItemTreeController isDeleting])
		return;
  
	NSArray *all = [self.projectItemTreeController selectedObjects];	
	if ([all count] == 1) {
		NSManagedObject *item = [all objectAtIndex:0];
		if ([item isKindOfClass:[FileEntity class]]) {
      if (openDocuments) {					
        [openDocuments addDocument:(FileEntity*)item];          
      }
		}
	}
  
  [self updateStatusView];
}

- (void) handleControlTabSelectionChanged:(NSNotification*)aNote
{
  id sender = [aNote object];
  selectedControlsTab = [sender indexOfSelectedTab];
}

#pragma mark -
#pragma mark Split view delegate

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
  //  NSLog(@"Resize with old size %@", NSStringFromSize(oldSize));
  if (sender == self.splitview) {
    NSSize splitViewSize = [sender frame].size;  
    NSSize leftSize = [self.leftView frame].size;
    leftSize.height = splitViewSize.height;
    
    NSSize centerSize = [self.centerView frame].size;
    centerSize.height = splitViewSize.height;
    
    NSSize rightSize;
    rightSize.width = splitViewSize.width - centerSize.width;
    rightSize.width -= 2.0*[sender dividerThickness];
    
    if (![sender isSubviewCollapsed:self.leftView]) {
      rightSize.width -= leftSize.width;
    }
    
    rightSize.height = splitViewSize.height;
    
    if (![sender isSubviewCollapsed:self.leftView]) {
      [self.leftView setFrameSize:leftSize];
    }
    [self.centerView setFrameSize:centerSize];
    if (![sender isSubviewCollapsed:self.rightView]) {
      [self.rightView setFrameSize:rightSize];
    }
  }
    
  [sender adjustSubviews];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
  if (splitView == self.splitview) {
    if (subview == self.leftView || subview == self.centerView)
      return NO;
    
    
    if (subview == self.rightView) {
      NSRect b = [self.rightView bounds];
      if (b.size.width < kSplitViewRightMinSize) {
        return NO;
      }
    }
  }
  
  return YES;
    
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
  if (splitView == self.splitview) {
    if (subview == self.centerView) {
      return NO;
    }
  }
  
  return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
  NSRect b = [splitView bounds];
  
  if (splitView == self.splitview) {
    if (dividerIndex == 0) {
      NSRect rb = [self.rightView bounds];
      CGFloat max =  b.size.width - rb.size.width - kSplitViewCenterMinSize;
      return max;
    }
    
    if (dividerIndex == 1) {
      NSRect b = [splitView bounds];
      return b.size.width-kSplitViewRightMinSize;
    }
  }
  
  if (splitView == editorSplitView) {    
    return b.size.height - 26.0 - [splitView dividerThickness];    
  }
  
  return proposedMax;
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
  if (splitView == self.splitview) {
    if (dividerIndex == 0) {
      return kSplitViewLeftMinSize;
    }
    
    if (dividerIndex == 1) {
      NSRect lb = [self.leftView bounds];
      
      if ([splitView isSubviewCollapsed:self.leftView]) {
        return kSplitViewCenterMinSize;
      }
      return lb.size.width + kSplitViewCenterMinSize;
    }
  }  
  
  if (splitView == editorSplitView) {    
    return 60.0;    
  }
  
  return proposedMin;
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
  NSSize leftSize = [self.leftView frame].size;
  NSSize centerSize = [self.centerView frame].size;  
//  NSSize rightSize = [self.rightView frame].size;
  
  //  NSLog(@"Left %@", NSStringFromSize(leftSize));
  //  NSLog(@"Center %@", NSStringFromSize(centerSize));
  //  NSLog(@"Right %@", NSStringFromSize(rightSize));
  
  CGFloat w = 0.0;
  
  if (![self.splitview isSubviewCollapsed:self.leftView]) {
    w += leftSize.width;
    w += [self.splitview dividerThickness];
  }
  if (![self.splitview isSubviewCollapsed:self.centerView]) {
    w += centerSize.width;
    w += [self.splitview dividerThickness];
  }
  
  if (![self.splitview isSubviewCollapsed:self.rightView]) {
    if ((frameSize.width - w) < kSplitViewRightMinSize) {
      frameSize.width = w + kSplitViewRightMinSize;
    }  
  }
  
  return frameSize; 
}

#pragma mark -
#pragma mark TeXEditorView delegate

-(NSString*)codeForCommand:(NSString*)command
{
  NSString *code = [self.library codeForCommand:command];
  return code;
}

- (NSArray*)commandsBeginningWithPrefix:(NSString *)prefix
{
  return [self.library commandsBeginningWith:prefix];
}

-(NSString*)fileExtension
{
  return [[[self.openDocuments currentDoc] pathOnDisk] pathExtension];
}

- (NSUndoManager*)currentUndoManager
{
	id file = [openDocuments currentDoc];
	FileDocument *doc = [file document];
	return [doc undoManager];
}


-(NSArray*)listOfCitations
{
//  NSLog(@"Generating list of citations...");
	NSMutableArray *citations = [NSMutableArray array];
  
	NSArray *docs = [[self project] valueForKey:@"items"];
	for (id doc in docs) {
//    NSLog(@"Checking doc: %@", doc);
		if ([doc isKindOfClass:[FileEntity class]]) {
			FileEntity *file = (FileEntity*)doc;
      if ([file isText]) {
				NSString *content = [file workingContentString];
				if (content) {
					NSArray *docTags = [content citations];			
					[citations addObjectsFromArray:docTags];			
          
          // add any citations from a \bibliography{} command
          [citations addObjectsFromArray:[content citationsFromBibliographyIncludedFromPath:file.pathOnDisk]];
				}				
			} else {
				// do nothing
			}
		}
	} // end loop

	return citations;	
}

-(NSArray*)listOfCommands
{
  NSMutableArray *commands = [NSMutableArray array];
  // consolidated main file
  NSString *allText = [self.project.mainFile consolidatedFileContents];
  NSArray *newCommands = [allText componentsMatchedByRegex:@"\\\\newcommand\\{\\\\[a-zA-Z]*\\}"];
  for (NSString *newCommand in newCommands) {
    [commands addObject:[newCommand argument]];
  }
  
  return commands; //[NSArray array]; 
}

- (BOOL) shouldSyntaxHighlightDocument
{
  if (_windowIsClosing) {
    return NO;
  }
  
  FileEntity *file = [self.openDocuments currentDoc];
	NSString *ext = [file valueForKey:@"extension"] ;
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  for (NSString *lext in [sfm supportedExtensionsForHighlighting]) {
    if ([ext isEqual:lext]) {
      return YES;
    }
  }
  return NO;
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

- (NSArray*)bookmarksForCurrentFileInLineRange:(NSRange)aRange
{
  NSMutableArray *bookmarks = [NSMutableArray array];
  FileEntity *file = [self.openDocuments currentDoc];
  if (file && [[file valueForKey:@"isText"] boolValue]) {    
    NSArray *allBookmarks = [file.bookmarks allObjects];
    for (Bookmark *b in allBookmarks) {
      NSInteger bl = [b.linenumber integerValue];
      if (bl >= aRange.location && bl < NSMaxRange(aRange)) {
        [bookmarks addObject:b];
      }
    }
  }
  return bookmarks;
}

#pragma mark -
#pragma mark Open Documents Manager Delegate

-(void) openDocumentsManager:(OpenDocumentsManager*)aDocumentManager didSelectFile:(FileEntity*)aFile
{
  NSArray *selected = [self.projectItemTreeController selectedObjects];
  if ([selected count] == 1) {
    if ([selected objectAtIndex:0] != aFile) {
      [self.projectItemTreeController selectItem:aFile];
    }
  }
}



#pragma mark -
#pragma mark ProjectOutlineController delegate

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

- (IBAction)pasteAsImage:(id)sender
{  

  // make a filename for the image checking the selected path in the project
  NSString *root = [self.projectItemTreeController pathForInsertion];
  
  NSString *fileRoot = @"pastedImage";
  NSFileManager *fm = [NSFileManager defaultManager];
  NSInteger count = 0;
  
  NSPasteboard *pboard = [NSPasteboard generalPasteboard];
  NSString *type = [pboard availableTypeFromArray:[NSImage imageTypes]];
  if (type) {
    NSString *ext = [[NSWorkspace sharedWorkspace] preferredFilenameExtensionForType:type];
    NSString *imagePath = [[root stringByAppendingPathComponent:fileRoot] stringByAppendingPathExtension:ext];
    while ([fm fileExistsAtPath:imagePath]) {
      imagePath = [[root stringByAppendingPathComponent:[fileRoot stringByAppendingFormat:@"-%d", count]] stringByAppendingPathExtension:ext];
      count++;
    }
        
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setTitle:@"Save pasted image"];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:type]];
    [panel setAllowsOtherFileTypes:NO];
    [panel setCanCreateDirectories:YES];
    [panel setMessage:@"Save pasted image"];
    [panel setNameFieldLabel:@"Image Path"];
    [panel setNameFieldStringValue:[imagePath lastPathComponent]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[imagePath stringByDeletingLastPathComponent]]];
    
    [panel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result) {
      
      if (result == NSFileHandlingPanelCancelButton) {
        return;
      }
      
      NSURL *url = [panel URL];
      
      // get data
      NSData *data = [pboard dataForType:type];    
      
      // write the file
      if ([data writeToURL:url atomically:YES]) {
        // cache current open document
        FileEntity *currentDoc = [self.openDocuments currentDoc];
        
        // add it to the project
        [self addFileAtURL:url copy:NO];
        
        // select current doc again
        [self.openDocuments selectTabForFile:currentDoc];
        
        // insert text
        NSString *projectFolder = [self.project valueForKey:@"folder"];
        NSString *file = [projectFolder relativePathTo:[url path]];
        
        NSString *insert = [self imageTextForFile:file];
        
        [self insertTextToCurrentDocument:insert];
        
        
      } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Creating Image Failed"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Failed to create image from the clipboard at %@", [url path]];
        [alert beginSheetModalForWindow:self.windowForSheet modalDelegate:nil didEndSelector:nil contextInfo:NULL];
      }
      
      
    }];
    
  }
  
}

- (NSString*)imageTextForFile:(NSString *)filepath
{
  NSString *name = [[filepath lastPathComponent] stringByDeletingPathExtension];
  TPEngine *engine = [self.engineManager engineNamed:[self engineName]];
  NSString *template = engine.imageIncludeString;
  template = [template stringByReplacingOccurrencesOfString:@"$NAME$" withString:name];
  template = [template stringByReplacingOccurrencesOfString:@"$PATH$" withString:filepath];
  return [NSString stringWithFormat:@"%@", template];
}


- (void) insertTextToCurrentDocument:(NSString*)string
{
	[self.texEditorViewController.textView insertText:string];
	[self.texEditorViewController.textView colorVisibleText];
}

#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender
{
  [self.engineManager trashAuxFiles];
  [self showDocument];
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
  [self.miniConsole setAnimating:YES];
  // setup the engine
  _building = YES;
  [self.engineManager compile];
}

- (IBAction)liveUpdate:(id)sender
{
  if ([sender state] == NSOnState) {
    _liveUpdate = YES;
  } else {
    _liveUpdate = NO;
  }
}

- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote
{
  [self.miniConsole setAnimating:NO];
  NSDictionary *userinfo = [aNote userInfo];
  if ([[userinfo valueForKey:@"success"] boolValue]) {
    [self showDocument];  
    if (openPDFAfterBuild) {
      [self openPDF:self];
    }
  }    
  _building = NO;
}

- (void)doLiveBuild
{  
  if (!_building && _liveUpdate && [self.project hasChanges]) {
		[self saveDocument:self];
    [self build];
  }  
}

- (NSString*)workingDirectory
{
  return [self.project folder];
}

- (NSString*)documentToCompile
{
  FileEntity *mainFile = self.project.mainFile;
  if (mainFile) {
    NSString *doc = [mainFile.pathOnDisk stringByDeletingPathExtension];
    if (doc) {
      return doc;
    }
  }
  return nil;
}

- (NSString*)compiledDocumentPath
{
	// build path to the pdf file
	NSString *mainFile = [self documentToCompile]; 
  NSString *docFile = [mainFile stringByAppendingPathExtension:@"pdf"];
  // check if the pdf exists
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:docFile]) {
    return docFile;
  }
  
  return nil;
}

- (IBAction)openWithSystemPDFViewer:(id)sender
{
  NSString *docFile = [self compiledDocumentPath];

  // check if the pdf exists
	if (docFile) {
		[[NSWorkspace sharedWorkspace] openFile:docFile];
	}

  // .. if not, ask the user if they want to typeset the project
}

- (IBAction) openPDF:(id)sender
{
	  
  if (!self.pdfViewer) {
    self.pdfViewer = [[[PDFViewer alloc] initWithDelegate:self] autorelease];
  }
  [self.pdfViewer showWindow:self];
  
}

- (BOOL) canViewPDF
{
	FileEntity *mainfile = [project valueForKey:@"mainFile"];
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
  if (_inVersionsBrowser) {
    return NO;
  }
  
	NSInteger tag = [menuItem tag];
  
  // find text selection in pdf
  if (tag == 116020) {
    return [self.pdfViewerController hasDocument] && [self.texEditorViewController textViewHasSelection];
  }
  
  // Find PDF Selection in Source
  if (tag == 116030) {
    return [self pdfHasSelection]; 
  }

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
  
  // toggle bookmark
  if (tag == 406010) {
    NSRange sel = [self.texEditorViewController.textView selectedRange];
    if ([self.openDocuments count]>0 && sel.location>0) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // delete selected bookmark
//  NSLog(@"Tag = %d", tag);
//  NSResponder *responder = [[self windowForSheet] firstResponder];
//  NSLog(@"Document: %@", self);
//  NSLog(@"First responder: %@", responder);
//  while ((responder = [responder nextResponder])) {
//    NSLog(@"  %@", responder);
//  }
//  NSLog(@"Selected bookmark: %@", [self.bookmarkManager selectedBookmark]);
  if (tag == 406020) {
    if ([self.bookmarkManager selectedBookmark]) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // jump to selected bookmark
  if (tag == 406030) {
    if ([self.bookmarkManager selectedBookmark]) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // previous bookmark
  if (tag == 406040) {
    if ([[self bookmarksForProject] count] == 0) {
      return NO;
    }
  }
  // next bookmark
  if (tag == 406050) {
    if ([[self bookmarksForProject] count] == 0) {
      return NO;
    }
  }
  
  // encoding menus
  if (tag >= 11100 && tag <= 11180) {
    if ([self.openDocuments currentDoc]) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // reload from disk
  if (tag == 10100) {
    if ([self.openDocuments currentDoc] != nil) {
      return YES;
    } else {
      return NO;
    }
  }
  
  // toggle status bar
  if (tag == 2040) {
    if ([self.project.settings.showStatusBar boolValue]) {
      [menuItem setTitle:@"Hide Status Bar"];
    } else {
      [menuItem setTitle:@"Show Status Bar"];
    }
  }
  
  // open pdf viewer
  if (tag == 60) {
    if ([self compiledDocumentPath]) {
      return YES;
    } else {
      return NO;
    }    
  }
  
  // open with system pdf viewer
  if (tag == 65) {
    if ([self compiledDocumentPath]) {
      return YES;
    } else {
      return NO;
    }    
  }
  
	return [super validateMenuItem:menuItem];
}

- (void) selectTabForFile:(FileEntity*)aFile
{
 [self.openDocuments selectTabForFile:aFile];
}

- (IBAction)reloadCurrentFileFromDisk:(id)sender
{
  [self.texEditorViewController.textView setSelectedRange:NSMakeRange(0, 0)];
  FileEntity *fileEntity = [self.openDocuments currentDoc];
  [fileEntity reloadFromDisk];
  [self.openDocuments updateDoc];  
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
	FileEntity *mainFile = [project valueForKey:@"mainFile"];
	
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
    NSArray *exts = [[TPSupportedFilesManager sharedSupportedFilesManager] supportedExtensions];
		if ([exts containsObject:[item valueForKey:@"extension"]]) {
			if ([project valueForKey:@"mainFile"] == item) {
        project.mainFile = nil;
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

- (IBAction)closeAllTabs:(id)sender
{
  [openDocuments closeAllTabs];
  [self.statusViewController setFilenameText:@""];
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


- (void)newTexFileExists:(NSAlert *)alert 
										code:(int)choice 
								 context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
    NSDictionary *template = (NSDictionary*)v;
    if (template != nil) {
      [self makeNewTexFileFromTemplate:template withFilename:[self.templateEditor filename] setAsMain:[self.templateEditor setAsMainFile]];
      [NSApp endSheet:self.templateEditor.window];
      [self.templateEditor.window orderOut:self];  
    }
	} else {
		// do nothing
	}
	
}

+ (NSString*) stringForNewArticleMainFileCode
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
  
	NSString *code = [TeXProjectDocument stringForNewArticleMainFileCode];
	
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
  [openDocuments performSelector:@selector(addDocument:) withObject:file afterDelay:0.1];
  [projectItemTreeController performSelector:@selector(selectItem:) withObject:file afterDelay:0.5];
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

- (IBAction) delete:(id)sender
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
#pragma mark Template Stuff

- (void) showTemplatesSheet
{
	if (self.templateEditor == nil) {
    self.templateEditor = [[[TPTemplateEditor alloc] initWithDelegate:self activeFilename:YES] autorelease];  
  }
  
  // set suggested filename
  NSString *suggestedDocumentName = [NSString stringWithFormat:@"untitled%02d", [[projectItemTreeController flattenedContent] count]];
  [self.templateEditor setFilename:suggestedDocumentName];
  
  [NSApp beginSheet:self.templateEditor.window
		 modalForWindow:[self windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];
}


- (void)templateEditorDidCancelSelection:(TPTemplateEditor *)editor
{
  [NSApp endSheet:self.templateEditor.window];
  [self.templateEditor.window orderOut:self];
}

- (void)templateEditor:(TPTemplateEditor *)editor didSelectTemplate:(NSDictionary *)aTemplate
{
  if (aTemplate) {
    // before we add this file, we better check that the file doesn't exist
    NSString *name = [self.templateEditor filename];
    if ([[name pathExtension] length]==0) {
      name = [name stringByAppendingPathExtension:@"tex"];
    }
    NSString *insertionPath = [projectItemTreeController pathForInsertion];
    //	NSLog(@"Checking path on disk %@", insertionPath);
    NSString *filename = [insertionPath stringByAppendingPathComponent:name];
    
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
                           informativeTextWithFormat:@"The file \u201c%@\u201d already exists on disk. Do you want to overwrite it?", filename
                        ]; 
      [alert beginSheetModalForWindow:editor.window
                        modalDelegate:self
                       didEndSelector:@selector(newTexFileExists:code:context:) 
                          contextInfo:aTemplate];
      
      return;		
    }
    
    // make new file
    [self makeNewTexFileFromTemplate:aTemplate withFilename:name setAsMain:[self.templateEditor setAsMainFile]];
    
  }
  
  [NSApp endSheet:self.templateEditor.window];
  [self.templateEditor.window orderOut:self];  
}

- (void) makeNewTexFileFromTemplate:(NSDictionary*)aTemplate withFilename:(NSString*)aFilename setAsMain:(BOOL)isMain
{
	NSString *name = aFilename;
	NSString *ext = [name pathExtension];
	if ([ext length]==0) {
		name = [name stringByAppendingPathExtension:@"tex"];
	}
	
	// Make the new file in the project
	[projectItemTreeController addNewFile:name
                             atFilepath:nil
                              extension:[name pathExtension]
                                 isText:YES
                                   code:[aTemplate valueForKey:@"Code"]
                             asMainFile:isMain
                           createOnDisk:YES];
	
	[self.texEditorViewController.textView colorWholeDocument];	
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

// #### CAREFUL: THIS DOESN'T WORK ON 10.6.8 !!!!!
//- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *errorOrNil))completionHandler
//{
//	NSLog(@"Save %@, %lu", typeName, saveOperation);
//	
//	// commit changes for open docs
//	[openDocuments commitStatus];
//  // make sure we store the current status of open docs
//  if ([self.openDocuments currentDoc] != nil) {
//    //    NSLog(@"Setting selected to %@", [self.openDocuments currentDoc]);
//    [self.project setValue:[self.openDocuments currentDoc] forKey:@"selected"];
//  } else {
//    self.project.selected = nil;
//  }
//  
//  // capture UI state
//  [self captureUIstate];
//  
//  // cache chosen language
//  NSString *language = [[NSSpellChecker sharedSpellChecker] language];	
//	[[NSUserDefaults standardUserDefaults] setValue:language forKey:TPSpellCheckerLanguage];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	
//	// make sure we save the files here
//	if ([self saveAllProjectFiles]) {    
//    NSString *path = [url path];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:completionHandler];    
//	}	
//}


- (BOOL)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName 
 forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
  
//	NSLog(@"Save %@, %d", typeName, saveOperation);
	
	// commit changes for open docs
	[openDocuments commitStatus];
  // make sure we store the current status of open docs
  if ([self.openDocuments currentDoc] != nil) {
//    NSLog(@"Setting selected to %@", [self.openDocuments currentDoc]);
    [self.project setValue:[self.openDocuments currentDoc] forKey:@"selected"];
  } else {
    self.project.selected = nil;
  }
  
  // capture UI state
  [self captureUIstate];
  
  // cache chosen language
  NSString *language = [[NSSpellChecker sharedSpellChecker] language];	
	[[NSUserDefaults standardUserDefaults] setValue:language forKey:TPSpellCheckerLanguage];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// make sure we save the files here
	if ([self saveAllProjectFiles]) {    
    NSString *path = [absoluteURL path];
    NSURL *url = [NSURL fileURLWithPath:path];
        
		BOOL result = [super saveToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
    
    [self.projectOutlineView setNeedsDisplay:YES];
    
    return result;
	}	
  
	return NO;
}
  
- (BOOL) saveAllProjectFiles
{
	// write contents of all files to disk
	NSArray *allItems = [projectItemTreeController flattenedContent];
  
//  NSLog(@"Saving %@", allItems);
	BOOL success = YES;
	for (ProjectItemEntity *item in allItems) {
		if ([item isKindOfClass:[FileEntity class]]) {
			FileEntity *file = (FileEntity*)item;
			//NSLog(@"Watching %@ %d", [file pathOnDisk], watching);
      if ([file isText]) {
        success = [file saveContentsToDisk];
      }
//			NSLog(@"Saved %@ %d ", [file pathOnDisk], success);
		} // end if item is a file
	}
    
	return success;
}

- (void)saveDocument:(id)sender
{
  [super saveDocument:self];
  [self.projectOutlineView setNeedsDisplay];
}

//
//
//#pragma mark -
//#pragma mark LaTeX Engine Delegate
//
//- (NSString*) engineDocumentToCompile:(TPLaTeXEngine*)anEngine
//{
//  return [[[self.project valueForKey:@"mainFile"] valueForKey:@"pathOnDisk"] stringByDeletingPathExtension];
//}
//
//- (NSString*) engineWorkingDirectory:(TPLaTeXEngine*)anEngine
//{
//  return [self.project folder]; 
//}
//
//- (BOOL) engineCanBibTeX:(TPLaTeXEngine*)anEngine
//{
//  if ([self.project valueForKey:@"mainFile"]) {
//    return YES;
//  }	
//	return NO;	 
//}
//
//- (TPEngineCompiler) engineProjectType:(TPLaTeXEngine*)anEngine
//{
//  if ([[[self.project valueForKey:@"type"] lowercaseString] isEqualToString:@"latex"]) {
//    return TPEngineCompilerLaTeX;
//  } else {
//    return TPEngineCompilerPDFLaTeX;
//  }
//}
//
//- (BOOL) engineDocumentIsProject:(TPLaTeXEngine*)anEngine
//{
//  return YES;
//}

#pragma mark -
#pragma mark File Monitor Delegate

- (NSArray*) fileMonitorFileList:(TPFileMonitor*)aMonitor
{
  NSFileManager *fm = [NSFileManager defaultManager];
  NSMutableArray *files = [NSMutableArray array];
  for (id item in self.project.items) {
    if ([item isKindOfClass:[FileEntity class]]) {
      if ([fm fileExistsAtPath:[item valueForKey:@"pathOnDisk"]]) {
        [files addObject:item];
      }
    }
  }
  return files;
}

- (void) fileMonitor:(TPFileMonitor *)aMonitor fileWasAccessedOnDisk:(id)file accessDate:(NSDate *)access
{
//  NSLog(@"File %@ was accessed at %@", [file valueForKey:@"name"], access);
  FileEntity *fileEntity = (FileEntity*)file;
  if (![file hasEdits]) {
    [self performSelectorOnMainThread:@selector(reloadCurrentFileFromDiskAndRestoreSelection:) withObject:fileEntity waitUntilDone:NO];
  }
}

- (void) reloadCurrentFileFromDiskAndRestoreSelection:(FileEntity*)fileEntity
{
  NSRange selected = [self.texEditorViewController.textView selectedRange];
  [self.texEditorViewController.textView setSelectedRange:NSMakeRange(0, 0)];
  [fileEntity reloadFromDisk];
  [self.openDocuments updateDoc];  
  [self.texEditorViewController.textView setSelectedRange:selected];
}

- (void) fileMonitor:(TPFileMonitor*)aMonitor fileChangedOnDisk:(id)file modifiedDate:(NSDate*)modified
{
  if ([file hasEdits]) {
    
    NSString *filename = [file valueForKey:@"shortName"];
    NSAlert *alert = [NSAlert alertWithMessageText:@"File Changed On Disk" 
                                     defaultButton:@"Reload"
                                   alternateButton:@"Continue"
                                       otherButton:nil 
                         informativeTextWithFormat:@"The file %@ changed on disk. Do you want to reload from disk? This may result in loss of changes.", filename];
    NSInteger result = [alert runModal];
    if (result == NSAlertDefaultReturn) {
      
      FileEntity *fileEntity = (FileEntity*)file;
      [fileEntity reloadFromDisk];
      [self.openDocuments updateDoc];
      
    } else {
      [file setValue:modified forKey:@"fileLoadDate"];
    }
    
  } else {
    // silently reload
    FileEntity *fileEntity = (FileEntity*)file;
    [fileEntity reloadFromDisk];
    [self.openDocuments updateDoc];
    
  }
  
}

- (NSString*)fileMonitor:(TPFileMonitor*)aMonitor pathOnDiskForFile:(id)file
{
  return [file valueForKey:@"pathOnDisk"];
}


#pragma mark -
#pragma mark PDF Selection

- (IBAction)findCorrespondingPDFText:(id)sender
{
  // get selected text
  NSString *text = [self.texEditorViewController selectedText];
  [self.pdfViewerController setSearchText:text];
  [self.pdfViewerController searchForStringInPDF:text];
  
  if (self.pdfViewer) {
    if ([self.pdfViewer.window isVisible]) {
      [self.pdfViewer.pdfViewerController setSearchText:text];
      [self.pdfViewer.pdfViewerController searchForStringInPDF:text];
    }
  }
  
}

-(void)textView:(TeXTextView*)aTextView didCommandClickAtLine:(NSInteger)lineNumber column:(NSInteger)column
{
  MHSynctexController *sync = [[MHSynctexController alloc] initWithEditor:aTextView pdfViews:[NSArray arrayWithObjects:self.pdfViewerController.pdfview, self.pdfViewer.pdfViewerController.pdfview, nil]];
  [sync displaySelectionInPDFFile:[self compiledDocumentPath] 
                       sourceFile:[[[self openDocuments] currentDoc] pathOnDisk] 
                       lineNumber:lineNumber 
                           column:column];
  [sync release];
}

- (IBAction)findSource:(id)sender
{
  PDFSelection *selection = [self.pdfViewerController.pdfview currentSelection];
  NSString *selectedText = [selection string];
  [self findSourceOfText:selectedText];
}

- (void) findSourceOfText:(NSString *)string
{
  [controlsTabview selectTabViewItemAtIndex:4];
  [self.finder setSearchTerm:string];
  [self.finder searchForTerm:string];
  shouldHighlightFirstMatch = YES;
}

- (BOOL) pdfHasSelection
{
  PDFSelection *selection = [self.pdfViewerController.pdfview currentSelection];
  if (selection) {
    NSString *selectedText = [selection string];
    if (selectedText && [selectedText length]>0) {
      return YES;
    }
  }
  return NO;
}


- (void) showDocument
{
  NSView *view = [self.pdfViewerController.pdfview documentView];    
  NSRect r = [view visibleRect];
  BOOL hasDoc = [self.pdfViewerController hasDocument];
  [self.pdfViewerController redisplayDocument];
  if (hasDoc) {
    [view scrollRectToVisible:r];
  }
}

#pragma mark -
#pragma mark Finder Delegate

- (void) didBeginSearch:(FindInProjectController *)aFinder
{
}

- (void) didEndSearch:(FindInProjectController *)aFinder
{
  if (shouldHighlightFirstMatch) {
    if ([self.finder count]>0) {
      [self.finder jumpToSearchResult:0];
    }
  }
  shouldHighlightFirstMatch = NO;
}

- (void) didCancelSearch:(FindInProjectController *)aFinder
{
}

- (void)didMakeMatch:(FindInProjectController *)aFinder
{
}

- (NSInteger)lineNumberForRange:(NSRange)aRange
{
  return [self.texEditorViewController.textView lineNumberForRange:aRange];
}

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile
{	
	// first select the file
	[projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [projectItemTreeController indexPathToObject:aFile];
	[projectItemTreeController setSelectionIndexPath:idx];
    
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // Now highlight the search term in that 
  [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
  
  // Make text view first responder
  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
  
}

- (void) replaceSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile withText:(NSString*)replacement
{
	// first select the file
	[projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [projectItemTreeController indexPathToObject:aFile];
	[projectItemTreeController setSelectionIndexPath:idx];
  
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // now replace the text
  [self.texEditorViewController.textView replaceRange:aRange withText:replacement scrollToVisible:NO animate:NO];
  
  // Make text view first responder
  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];  
}

#pragma mark -
#pragma mark PDFViewerController delegate

- (void)pdfview:(MHPDFView*)pdfView didCommandClickOnPage:(NSInteger)pageIndex inRect:(NSRect)aRect atPoint:(NSPoint)aPoint
{
//  NSLog(@"Clicked on PDF in project...");
  MHSynctexController *sync = [[[MHSynctexController alloc] initWithEditor:self.texEditorViewController.textView pdfViews:[NSArray arrayWithObjects:self.pdfViewerController.pdfview, self.pdfViewer.pdfViewerController.pdfview, nil]] autorelease];
  NSInteger lineNumber = NSNotFound;
  NSString *sourcefile = [sync sourceFileForPDFFile:[self compiledDocumentPath] lineNumber:&lineNumber pageIndex:pageIndex pageBounds:aRect point:aPoint];
  sourcefile = [sourcefile stringByStandardizingPath];  
  if ([sourcefile isAbsolutePath]) {
//    NSLog(@"    source file is absolute path");
    sourcefile = [self.project.folder relativePathTo:sourcefile];
  }
//  NSLog(@"  source file: %@", sourcefile);
  FileEntity *file = [self.project fileWithPath:sourcefile];
//  NSLog(@"    got project file: %@", file);
  [self.openDocuments addDocument:file];
  if (file) {
    [self.openDocuments selectTabForFile:file];
    [self.texEditorViewController.textView goToLine:lineNumber];
  }
}

- (NSString*)documentPathForViewer:(PDFViewerController *)aPDFViewer
{
  NSString *path = [self compiledDocumentPath];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    return path;
  } else {
    return nil;
  }
  
}

#pragma mark -
#pragma mark Library Controller Delegate

- (void)libraryController:(LibraryController *)library insertText:(NSString *)text
{
  TeXTextView *textView = self.texEditorViewController.textView;
  NSRange sel = [textView selectedRange];
  NSRange textRange = NSMakeRange(sel.location, [text length]);
  
  [[textView undoManager] beginUndoGrouping];
  [textView shouldChangeTextInRange:sel replacementString:text];
  [textView replaceCharactersInRange:sel withString:text];
  [textView replacePlaceholdersInString:text range:textRange];      
  [textView didChangeText];
  [[textView undoManager] endUndoGrouping];
  [textView performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];  
  
}

#pragma mark -
#pragma mark Palette Controller Delegate

- (BOOL)paletteCanInsertText:(PaletteController *)aPalette
{
  if ([self.openDocuments currentDoc]) {
    return YES;
  }
  return NO;
}

- (void)palette:(PaletteController *)aPalette insertText:(NSString *)aString
{
  [self insertTextToCurrentDocument:aString];
}

#pragma mark -
#pragma mark Bookmarks

- (NSArray*)bookmarksForCurrentFile
{
  if (_windowIsClosing) {
    return nil;
  }
  
  FileEntity *file = [self.openDocuments currentDoc];
  return [file.bookmarks allObjects];
}

- (IBAction)showBookmarks:(id)sender
{
  [self.controlsTabview selectTabViewItemAtIndex:5];
  [self.bookmarkManager expandAll:self];
  [[self windowForSheet] makeFirstResponder:self.bookmarkManager.outlineView];
}

- (IBAction)deleteSelectedBookmark:(id)sender
{
  [self.bookmarkManager deleteSelectedBookmark:sender];
}

- (IBAction)jumpToSelectedBookmark:(id)sender
{
  [self.bookmarkManager jumpToSelectedBookmark:sender];
}

- (void) didDeleteBookmark
{
  [self.texEditorViewController.textView setNeedsDisplay:YES];
  
  // forward this to all open document windows
  for (id<BookmarkManagerDelegate> doc in [self.openDocuments standaloneWindows]) {
    [doc didDeleteBookmark];
  }
  
}

- (void) didAddBookmark
{
  [self.texEditorViewController.textView setNeedsDisplay:YES];
  
  // forward this to all open document windows
  for (id<BookmarkManagerDelegate> doc in [self.openDocuments standaloneWindows]) {
    [doc didAddBookmark];
  }  
}

- (void) jumpToBookmark:(Bookmark *)aBookmark
{
  NSInteger linenumber = [aBookmark.linenumber integerValue];
  FileEntity *file = aBookmark.parentFile;
  
  // forward this to all open document windows
//  for (id<BookmarkManagerDelegate> doc in [self.openDocuments standaloneWindows]) {
//    [doc jumpToBookmark:aBookmark];
//  }
  
	// first select the file
	[projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [projectItemTreeController indexPathToObject:file];
	[projectItemTreeController setSelectionIndexPath:idx];
  
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // Now highlight the search term in that 
  [self.texEditorViewController.textView jumpToLine:linenumber inFile:file select:YES];
//  [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
  
  
  // Make text view first responder
  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
  
}

- (NSArray*)bookmarksForProject
{
  NSMutableArray *bookmarks = [NSMutableArray array];
  for (ProjectItemEntity *item in [self.project valueForKey:@"items"]) {
    if ([item isKindOfClass:[FileEntity class]]) {
      FileEntity *file = (FileEntity*)item;
      if ([[file valueForKey:@"isText"] boolValue]) {
        [bookmarks addObjectsFromArray:[file.bookmarks allObjects]]; 
      }
    }
  }  
  return bookmarks;
}

- (Bookmark*)bookmarkForCurrentLine
{
  NSInteger linenumber = [self.texEditorViewController.textView lineNumber];
  return [self bookmarkForLine:linenumber];
}

- (Bookmark*)bookmarkForLine:(NSInteger)linenumber
{
  FileEntity *file = [self.openDocuments currentDoc];
  Bookmark *bookmark = [file bookmarkForLinenumber:linenumber];
  return bookmark;
}

- (BOOL) hasBookmarkAtLine:(NSInteger)aLinenumber
{
  Bookmark *bookmark = [self bookmarkForLine:aLinenumber];
  return bookmark != nil;
}

- (BOOL) hasBookmarkAtCurrentLine:(id)sender
{
  Bookmark *bookmark = [self bookmarkForCurrentLine];
  return bookmark != nil;
}


- (IBAction)toggleBookmark:(id)sender
{
  Bookmark *b = [self bookmarkForCurrentLine];
  if (b) {
    [self removeBookmarkAtCurrentLine:self];
  } else {
    [self addBookmarkAtCurrentLine:self];
  }  
}

- (IBAction)previousBookmark:(id)sender
{
  [self.bookmarkManager previousBookmark:self];
}

- (IBAction)nextBookmark:(id)sender
{
  [self.bookmarkManager nextBookmark:self];
}

- (IBAction)addBookmarkAtCurrentLine:(id)sender
{
  NSInteger linenumber = [self.texEditorViewController.textView lineNumber];
  [self addBookmarkAtLine:linenumber];
}

- (void) addBookmarkAtLine:(NSInteger)aLinenumber
{
  Bookmark *b = [self bookmarkForLine:aLinenumber];
  if (!b) {
    FileEntity *file = [self.openDocuments currentDoc];
    Bookmark *bookmark = [Bookmark bookmarkWithLinenumber:aLinenumber inFile:file inManagedObjectContext:self.managedObjectContext];    
    if (bookmark) {
      [self.texEditorViewController.textView setNeedsDisplay:YES];
      [self.bookmarkManager reloadData];
      [self didAddBookmark];
    }
  }
}

- (IBAction)removeBookmarkAtCurrentLine:(id)sender
{
  NSInteger linenumber = [self.texEditorViewController.textView lineNumber];
  [self removeBookmarkAtLine:linenumber];
}

- (void) removeBookmarkAtLine:(NSInteger)aLinenumber
{
  Bookmark *b = [self bookmarkForLine:aLinenumber];
  if (b) {
    FileEntity *file = [self.openDocuments currentDoc];
    [[file mutableSetValueForKey:@"bookmarks"] removeObject:b];
    [self.texEditorViewController.textView setNeedsDisplay:YES];
    [self.bookmarkManager reloadData];
    [self didDeleteBookmark];
  }  
}

#pragma mark -
#pragma mark Engine Settings

-(NSArray*)registeredEngineNames
{
  return [self.engineManager registeredEngineNames];
}

-(void)didSelectDoBibtex:(BOOL)state
{
  self.project.settings.doBibtex = [NSNumber numberWithBool:state];
}

-(void)didSelectDoPS2PDF:(BOOL)state
{
  self.project.settings.doPS2PDF = [NSNumber numberWithBool:state];
}

-(void)didSelectOpenConsole:(BOOL)state
{
  self.project.settings.openConsole = [NSNumber numberWithBool:state];
}

-(void)didChangeNCompile:(NSInteger)number
{
  self.project.settings.nCompile = [NSNumber numberWithInteger:number];
}

-(void)didSelectEngineName:(NSString*)aName
{
  self.project.settings.engineName = aName;
}

-(NSString*)engineName
{
  return self.project.settings.engineName;
}

-(NSNumber*)doBibtex
{
  return self.project.settings.doBibtex;
}

-(NSNumber*)doPS2PDF
{
  return self.project.settings.doPS2PDF;
}

-(NSNumber*)openConsole
{
  return self.project.settings.openConsole;
}

-(NSNumber*)nCompile
{
  if (_liveUpdate)
    return [NSNumber numberWithInt:1];
  
  return self.project.settings.nCompile;
}

- (BOOL) supportsDoBibtex
{
  TPEngine *engine = [self.engineManager engineNamed:[self engineName]];
  if (engine) {
    return engine.supportsDoBibtex;
  }
  return NO;
}

- (BOOL) supportsDoPS2PDF
{
  TPEngine *engine = [self.engineManager engineNamed:[self engineName]];
  if (engine) {
    return engine.supportsDoPS2PDF;
  }
  return NO;
}

- (BOOL) supportsNCompile
{
  TPEngine *engine = [self.engineManager engineNamed:[self engineName]];
  if (engine) {
    return engine.supportsNCompile;
  }
  return NO;
}


#pragma mark -
#pragma mark Project Template Stuff

- (IBAction)createProjectTemplate:(id)sender
{
  TPProjectTemplateCreator *creator = [[[TPProjectTemplateCreator alloc] initWithDelegate:self] autorelease];
  
  // set suggested name
  NSString *name = [self.project.name stringByAppendingString:@"_template"];
  creator.suggestedTemplateName = name;
  creator.suggestedTemplateDescription = [NSString stringWithFormat:@"Project template based on project %@", self.project.name];
  
  [NSApp beginSheet:creator.window
     modalForWindow:[self windowForSheet]
      modalDelegate:self
     didEndSelector:nil
        contextInfo:NULL];
  
}


@end
