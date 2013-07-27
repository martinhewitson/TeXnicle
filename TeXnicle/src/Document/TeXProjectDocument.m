//
//  TeXProjectDocument.m
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

#import "NSApplication+Library.h"
#import "TeXProjectDocument.h"
#import "TPDocumentMatch.h"
#import "TPResultDocument.h"
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
#import "TPSyntaxError.h"
#import "TPLabel.h"
#import "TPNewCommand.h"
#import "FileDocument.h"
#import "TPRegularExpression.h"
#import "NSResponder+TeXnicle.h"
#import "NSAttributedString+Placeholders.h"
#import "NSDictionary+TeXnicle.h"
#import "TPFileMetadata.h"
#import "MMTabBarView.h"
#import "TPTeXLogParser.h"
#import "ExternalTeXDoc.h"

#define kSplitViewLeftMinSize 220.0
#define kSplitViewCenterMinSize 400.0
#define kSplitViewRightMinSize 400.0

@interface TeXProjectDocument ()

@property (assign) BOOL navigatingHistory;
@property (readonly) BOOL pdfHasSelection;


@property (strong) TPProjectTemplateCreator *templateCreator;
@property (strong) NSMenu *createFolderMenu;
@property (strong) NSMutableArray *tabHistory;
@property (assign) NSInteger currentTabHistoryIndex;
@property (strong) NSTimer *liveUpdateTimer;
@property (strong) TPProjectOutlineViewController *outlineViewController;

@property (strong) TPWarningsViewController *warningsViewController;
@property (strong) TPLabelsViewController *labelsViewController;
@property (strong) TPCitationsViewController *citationsViewController;
@property (strong) TPNewCommandsViewController *commandsViewController;

@property (strong) MHMiniConsoleViewController *miniConsole;
@property (strong) TPConsoleViewController *embeddedConsoleViewController;
@property (strong) NSTimer *statusTimer;
@property (strong) TPStatusViewController *statusViewController;
@property (strong) TPEngineSettingsController *engineSettings;
@property (strong) TPEngineManager *engineManager;
@property (strong) PaletteController *palette;
@property (strong) FinderController *finder;
@property (strong) TPLibraryController *libraryController;
@property (strong) TPSpellCheckerListingViewController *spellcheckerViewController;
@property (nonatomic, strong) ProjectEntity *project;
@property (strong) TPImageViewerController *imageViewerController;
@property (strong) TPFileMonitor *fileMonitor;
@property (strong) TPTemplateEditor *templateEditor;

@property (strong) OpenDocumentsManager *openDocuments;

@property (strong) TPMetadataManager *metadataManager;
@property (strong) NSMutableArray *fileMetadata;
@property (strong) NSMutableArray *textFiles;

@property (strong) MHControlsTabBarController *controlsTabBarController;
@property (unsafe_unretained) IBOutlet NSView *controlsTabBarControlContainer;
@property (strong) MHInfoTabBarController *infoControlsTabBarController;
@property (unsafe_unretained) IBOutlet NSView *infoControlsTabBarControlContainer;
@property (unsafe_unretained) IBOutlet NSTabView *controlsTabview;
@property (unsafe_unretained) IBOutlet NSTabView *infoControlsTabview;

@property (unsafe_unretained) IBOutlet NSToolbar *toolbar;
@property (unsafe_unretained) IBOutlet NSTabView *tabbar;

@property (unsafe_unretained) IBOutlet HHValidatedButton *backTabButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *forwardTabButton;
@property (unsafe_unretained) IBOutlet NSWindow *mainWindow;
@property (unsafe_unretained) IBOutlet NSView *outlineViewContainer;

@property (unsafe_unretained) IBOutlet NSView *warningsContainerView;
@property (unsafe_unretained) IBOutlet NSView *labelsContainerView;
@property (unsafe_unretained) IBOutlet NSView *citationsContainerView;
@property (unsafe_unretained) IBOutlet NSView *commandsContainerView;

@property (unsafe_unretained) IBOutlet NSView *embeddedConsoleContainer;
@property (unsafe_unretained) IBOutlet NSView *statusViewContainer;
@property (unsafe_unretained) IBOutlet NSSplitView *editorSplitView;
@property (unsafe_unretained) IBOutlet HHValidatedButton *createFolderButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *createFileButton;
@property (unsafe_unretained) IBOutlet NSView *engineSettingsContainer;
@property (unsafe_unretained) IBOutlet NSSplitView *splitview;
@property (unsafe_unretained) IBOutlet NSView *leftView;
@property (unsafe_unretained) IBOutlet NSView *rightView;
@property (unsafe_unretained) IBOutlet NSView *centerView;
@property (unsafe_unretained) IBOutlet NSView *bookmarkContainerView;
@property (unsafe_unretained) IBOutlet NSView *paletteContainverView;
@property (unsafe_unretained) IBOutlet NSView *finderContainerView;
@property (unsafe_unretained) IBOutlet NSView *libraryContainerView;
@property (unsafe_unretained) IBOutlet NSView *spellCheckerContainerView;
@property (unsafe_unretained) IBOutlet TPOutlineView *projectOutlineView;
@property (unsafe_unretained) IBOutlet NSView *texEditorContainer;
@property (unsafe_unretained) IBOutlet NSView *imageViewerContainer;

@property (unsafe_unretained) IBOutlet NSView *navButtonsBackground;
@property (unsafe_unretained) IBOutlet MMTabBarView *psmTabBarControl;

@property (strong) TPDocumentReportWindowController *documentReport;

@property (strong) TPQuickJumpViewController *quickJumpController;

@property (copy) NSString *miniConsoleLastMessage;

@end

@implementation TeXProjectDocument

- (void) dealloc
{
//  NSLog(@"Dealloc %@", self);
}

- (void) awakeFromNib
{
  if ([super respondsToSelector:@selector(awakeFromNib)])
    [super awakeFromNib];
  
  _building = NO;
  
  self.tabHistory = [NSMutableArray array];
}

- (void)setupLiveUpdateTimer
{
  [self stopLiveUpdateTimer];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  float updateInterval;
  if ([[defaults valueForKey:TPLiveUpdateMode] integerValue] == 0) {
    // time since last update
    updateInterval = [[defaults valueForKey:TPLiveUpdateFrequency] floatValue];
  } else {
    // time since last edit; we check if we should update often enough
    updateInterval = 0.2f;
  }
  
  self.liveUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(doLiveBuild) userInfo:nil repeats:YES];

  [self.toolbar setAllowsUserCustomization:YES];
	[self.toolbar setAutosavesConfiguration:YES];
  [self.toolbar setShowsBaselineSeparator:NO];

  
}

- (void) stopLiveUpdateTimer
{
  if (self.liveUpdateTimer) {
    [self.liveUpdateTimer invalidate];
  }
}

#pragma mark -
#pragma mark KVO 

+ (NSArray*)preferencesToObserve
{
  return @[TEJumpBarEnabled, TPLiveUpdateMode, TPLiveUpdateEditDelay, TPLiveUpdateFrequency];
}

- (void) stopObserving
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  
  for (NSString *key in [TeXProjectDocument preferencesToObserve]) {
    [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", key]];
  }
}

- (void) observePreferences
{
  
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  
  for (NSString *key in [TeXProjectDocument preferencesToObserve]) {
    [defaults addObserver:self
               forKeyPath:[NSString stringWithFormat:@"values.%@", key]
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
  }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPLiveUpdateFrequency]] ||
      [keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPLiveUpdateEditDelay]] ||
      [keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPLiveUpdateMode]]) {
    [self setupLiveUpdateTimer];
	} else if ([keyPath isEqualToString:[NSString stringWithFormat:@"values.%@", TEJumpBarEnabled]]) {
    [self.texEditorViewController toggleJumpBar:YES];
  }
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
      metadata = [[NSMutableDictionary alloc] init];
    }
    metadata[(NSString *)kMDItemKeywords] = @[projectName];
    [psc setMetadata:metadata forPersistentStore:pStore];
    return YES;
  }
  return NO;
}

- (void) setupDocument
{
  if (_didSetup)
    return;
  
  // force fetching the project
  [self project];
  
//  NSLog(@"setupDocument");

  // outline view
  self.outlineViewController = [[TPProjectOutlineViewController alloc] initWithDelegate:self];
  [self.outlineViewController.view setFrame:[self.outlineViewContainer bounds]];
  [self.outlineViewContainer addSubview:self.outlineViewController.view];
   
  // warnings view
  self.warningsViewController = [[TPWarningsViewController alloc] initWithDelegate:self];
  [self.warningsViewController.view setFrame:self.warningsContainerView.bounds];
  [self.warningsContainerView addSubview:self.warningsViewController.view];
  
  // labels view
  self.labelsViewController = [[TPLabelsViewController alloc] initWithDelegate:self];
  [self.labelsViewController.view setFrame:self.labelsContainerView.bounds];
  [self.labelsContainerView addSubview:self.labelsViewController.view];
  
  // citations view
  self.citationsViewController = [[TPCitationsViewController alloc] initWithDelegate:self];
  [self.citationsViewController.view setFrame:self.citationsContainerView.bounds];
  [self.citationsContainerView addSubview:self.citationsViewController.view];
  
  // commands view
  self.commandsViewController = [[TPNewCommandsViewController alloc] initWithDelegate:self];
  [self.commandsViewController.view setFrame:self.commandsContainerView.bounds];
  [self.commandsContainerView addSubview:self.commandsViewController.view];
  
  // setup settings
  self.engineSettings = [[TPEngineSettingsController alloc] initWithDelegate:self];
  [[self.engineSettings view] setFrame:[self.engineSettingsContainer bounds]];
  [self.engineSettingsContainer addSubview:[self.engineSettings view]];
    
  // Setup text view  
  self.texEditorViewController = [[TeXEditorViewController alloc] init];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
  [self.texEditorViewController setDelegate:self];
  [self.texEditorViewController setPerformSyntaxCheck:YES];
  [self.texEditorViewController setupSyntaxChecker];
  
  // setup open docs manager
  self.openDocuments = [[OpenDocumentsManager alloc] init];
  self.openDocuments.delegate = self;
  self.openDocuments.navigationButtonsView = self.navButtonsBackground;
  self.openDocuments.tabBar = self.psmTabBarControl;
  self.openDocuments.tabBar.delegate = self.openDocuments;
  self.openDocuments.tabView = self.tabbar;
  self.projectItemTreeController.openDocumentsManager = self.openDocuments;
  self.openDocuments.texEditorViewController = self.texEditorViewController;
  [self.openDocuments setup];
  [self.openDocuments disableTextView];
  
  // setup status view
  self.statusViewController = [[TPStatusViewController alloc] init];
  [self.statusViewController.view setFrame:[self.statusViewContainer bounds]];
  [self.statusViewContainer addSubview:self.statusViewController.view];
  _statusViewIsShowing = YES;
  
//  NSLog(@"Project settings %@", self.project.settings);
  
  if (![self.project.settings.showStatusBar boolValue]) {
    // the status bar is showing by default, so toggle it out
    [self toggleStatusBar:NO];
  }
  
  // setup image viewer
  self.imageViewerController = [[TPImageViewerController alloc] init];
  self.openDocuments.imageViewerController = self.imageViewerController;
  self.openDocuments.imageViewContainer = self.imageViewerContainer;
  [[self.imageViewerController view] setFrame:[self.imageViewerContainer bounds]];
  [self.imageViewerContainer addSubview:[self.imageViewerController view]];
  
  // setup pdf viewer
  self.pdfViewerController = [[PDFViewerController alloc] initWithDelegate:self];
  [self.pdfViewerController.view setFrame:[_pdfViewerContainerView bounds]];
  [_pdfViewerContainerView addSubview:self.pdfViewerController.view];
  
  // setup library
  self.libraryController = [[TPLibraryController alloc] initWithDelegate:self];
  [self.libraryController.view setFrame:self.libraryContainerView.bounds];
  [self.libraryContainerView addSubview:self.libraryController.view];  
  
  // setup spellchecker
  self.spellcheckerViewController = [[TPSpellCheckerListingViewController alloc] initWithDelegate:self];
  [self.spellcheckerViewController.view setFrame:[self.spellCheckerContainerView bounds]];
  [self.spellCheckerContainerView addSubview:self.spellcheckerViewController.view];  
  
  // setup file monitor
  self.fileMonitor = [TPFileMonitor monitorWithDelegate:self];
  
  // setup finder
  self.finder = [[FinderController alloc] initWithDelegate:self];
  [self.finder.view setFrame:[self.finderContainerView bounds]];
  [self.finderContainerView addSubview:self.finder.view];
  
  // setup palette
  self.palette = [[PaletteController alloc] initWithDelegate:self];
  NSView *paletteView = [self.palette view];
  [paletteView setFrame:[self.paletteContainverView bounds]];
  [self.paletteContainverView addSubview:paletteView];
  
  // setup bookmark manager
  self.bookmarkManager = [[BookmarkManager alloc] initWithDelegate:self];
  NSView *bookmarkView = [self.bookmarkManager view];
  [bookmarkView setFrame:[self.bookmarkContainerView bounds]];
  [self.bookmarkContainerView addSubview:bookmarkView];
  
  // setup engine manager
  self.engineManager = [TPEngineManager engineManagerWithDelegate:self];
  
  // register the mini console
  [self.engineManager registerConsole:self.miniConsole];
  
  // embedded console
  self.embeddedConsoleViewController = [[TPConsoleViewController alloc] initWithDelegate:self];
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
    
//    NSLog(@"####################################### Reloading because project moved....");
//    NSLog(@" project: %@", self.project);
    
    [self.project setValue:projectFolder forKey:@"folder"];
    [self.managedObjectContext processPendingChanges];
    
    // reload all files
    for (ProjectItemEntity *item in self.project.items) {
      if ([item isKindOfClass:[FileEntity class]]) {
//        NSLog(@"####################################### Reloading %@ because project moved....", item);
        [(FileEntity*)item reloadFromDisk];
      }
    }
  }

  // tab bar controls
  self.controlsTabBarController = [[MHControlsTabBarController alloc] init];
  [self.controlsTabBarController.view setFrame:[self.controlsTabBarControlContainer bounds]];
  [self.controlsTabBarControlContainer addSubview:self.controlsTabBarController.view];
  self.controlsTabBarController.tabView = self.controlsTabview;
  self.controlsTabBarController.splitview = self.splitview;
  self.controlsTabview.delegate = self.controlsTabBarController;
  
  self.infoControlsTabBarController = [[MHInfoTabBarController alloc] init];
  [self.infoControlsTabBarController.view setFrame:[self.infoControlsTabBarControlContainer bounds]];
  [self.infoControlsTabBarControlContainer addSubview:self.infoControlsTabBarController.view];
  self.infoControlsTabBarController.tabView = self.infoControlsTabview;
  self.infoControlsTabBarController.splitview = self.splitview;
  self.infoControlsTabview.delegate = self.infoControlsTabBarController;
  
  // metadata manager
  self.metadataManager = [[TPMetadataManager alloc] initWithDelegate:self];

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
           object:self.controlsTabBarController];
  
  [nc addObserver:self
         selector:@selector(handleInfoTabSelectionChanged:)
             name:TPInfoControlsTabSelectionDidChangeNotification 
           object:self.infoControlsTabBarController];
  
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
  
  [nc addObserver:self
         selector:@selector(handleSupportedFileSpellCheckFlagChangedNotification:) 
             name:TPSupportedFileSpellCheckFlagChangedNotification 
           object:nil];
  
  [nc addObserver:self
         selector:@selector(handleOpenDocumentsDidChangeFileNotification:) 
             name:TPOpenDocumentsDidChangeFileNotification 
           object:self.openDocuments];
  
  [nc addObserver:self
         selector:@selector(handleOpenDocumentsDidAddFileNotification:) 
             name:TPOpenDocumentsDidAddFileNotification 
           object:self.openDocuments];
  
  [nc addObserver:self
         selector:@selector(handleMetadataDidBeginUpdateNotification:)
             name:TPMetadataManagerDidBeginUpdateNotification
           object:self.metadataManager];
  
  [nc addObserver:self
         selector:@selector(handleMetadataDidEndUpdateNotification:)
             name:TPMetadataManagerDidEndUpdateNotification
           object:self.metadataManager];
  
  [self.statusViewController setFilenameText:@""];
  [self.statusViewController setEditorStatusText:@"No Selection."];
  [self.statusViewController setShowRevealButton:NO];
  
  
  // ensure the project has the same name as on disk
  NSString *newProjectName = [[[self fileURL] lastPathComponent] stringByDeletingPathExtension];
  if (![[self.project valueForKey:@"name"] isEqualToString:newProjectName]) {
    [self.project setValue:newProjectName forKey:@"name"];
  }

  self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateStatusView)
                                                    userInfo:nil
                                                     repeats:YES];
  
  // start metadata gathering
  [self.metadataManager performSelector:@selector(start) withObject:nil afterDelay:0.0];
  
  // insert controls tab bar in the responder chain
  [self.controlsTabBarController setNextResponder:self.mainWindow.nextResponder];
  [self.mainWindow setNextResponder:self.controlsTabBarController];  
  
  // Show document
  [self showDocument];
  
  _didSetup = YES;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
//  NSLog(@"windowControllerDidLoadNib %@", [self windowForSheet]);
  [super windowControllerDidLoadNib:aController];
  
  self.miniConsole = [[MHMiniConsoleViewController alloc] init];
  NSArray *items = [[[self windowForSheet] toolbar] items];
  for (NSToolbarItem *item in items) {
    if ([[item itemIdentifier] isEqualToString:@"MiniConsole"]) {
      [item setMinSize:NSMakeSize(400, 39)];
      NSBox *box = (NSBox*)[item view];
      [box setContentView:self.miniConsole.view];
    }
  }
  [self.miniConsole message:@"Welcome to TeXnicle."];
  [self setupDocument];
  [self observePreferences];
  [self setupLiveUpdateTimer];

  if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPRestoreOpenTabs] boolValue]) {
    [self restoreOpenTabs];
  }
  
  // [self restoreUIstate];
  [self performSelector:@selector(restoreUIstate) withObject:nil afterDelay:0];
  
  [self.outlineViewController start];
  
  // update metadata views
  NSTimeInterval delay = 2.0;
  [self.warningsViewController performSelector:@selector(updateUI) withObject:nil afterDelay:delay];
  [self.labelsViewController performSelector:@selector(updateUI) withObject:nil afterDelay:delay];
  [self.citationsViewController performSelector:@selector(updateUI) withObject:nil afterDelay:delay];
  [self.commandsViewController performSelector:@selector(updateUI) withObject:nil afterDelay:delay];
  
}

- (void) restoreOpenTabs
{
  NSMutableArray *openFiles = [NSMutableArray array];
  // build array of open files.
  for (ProjectItemEntity *item in self.project.items) {
    if ([item isKindOfClass:[FileEntity class]]) {
      FileEntity *file = (FileEntity*)item;
      if ([file existsOnDisk]){
        NSInteger pos = [[file valueForKey:@"wasOpen"] integerValue];
        if (pos >= 0) {
          [openFiles addObject:file];
        }
      }
    }
  }
  
  // now sort the array
  NSArray *sortedFiles = [openFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    
    NSInteger pos1 = [[obj1 valueForKey:@"wasOpen"] integerValue];
    NSInteger pos2 = [[obj2 valueForKey:@"wasOpen"] integerValue];
    
    if (pos1 > pos2) {
      return (NSComparisonResult)NSOrderedDescending;
    }
    
    if (pos1 < pos2) {
      return (NSComparisonResult)NSOrderedAscending;
    }
    
    return (NSComparisonResult)NSOrderedSame;
    
  }];
  
  // open the sorted files
  for (FileEntity *file in sortedFiles) {
    [self.openDocuments addDocument:file select:NO];
    [file setPrimitiveValue:@-1 forKey:@"wasOpen"];
  }
  
  // select the previously selected file
  FileEntity *selected = [self.project valueForKey:@"selected"];
  if (selected != nil) {
    [self performSelectorOnMainThread:@selector(selectTabForFile:) withObject:selected waitUntilDone:YES];
  }
  
  // clear history
  [self clearTabHistory];
}

- (void) windowDidBecomeKey:(NSNotification *)notification
{
//  NSLog(@"Window did become key");
  ProjectEntity *p = self.project;
  // set language for this project
  if (p) {
    if (p.settings) {
      if (p.settings.language) {
        [[NSSpellChecker sharedSpellChecker] setLanguage:p.settings.language];
      }
    }
  }
}


- (void) stopStatusTimer
{
  if (self.statusTimer) {
    [self.statusTimer invalidate];
  }
}

- (void) stopAllMetadataOperations
{
  [self.metadataManager stop];
  
  for (TPFileMetadata *item in self.fileMetadata) {
    [item tearDown];
  }
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Clean up %@...", self.project.name);
#endif
  [self.engineManager cancelCompilation];
  
  [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
  [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
  
  // stop observing notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  
  // stop gathering metadata
  [self stopAllMetadataOperations];
  
  // stop spell checking timer
  [self.spellcheckerViewController stop];
  
  // stop timer
  [self stopStatusTimer];
  
  // live update timer
  [self stopLiveUpdateTimer];
  
  // stop KVO
  [self stopObserving];

  // outline view controller
  [self.outlineViewController tearDown];
  self.outlineViewController = nil;
  
  // clean up tab bar controls
  [NSResponder removeResponder:self.controlsTabBarController fromChainOfResponder:self.mainWindow];
  [self.controlsTabBarController tearDown];
  self.controlsTabBarController = nil;
  
  [self.infoControlsTabBarController tearDown];
  self.infoControlsTabBarController = nil;
  
  // clean up project item tree controller
  [self.projectItemTreeController tearDown];
  self.projectItemTreeController.project = nil;
  self.project = nil;  
  
  // clear up open documents
  [self.openDocuments tearDown];
  self.openDocuments = nil;
  
  // warnings view
  [self.warningsViewController tearDown];
  self.warningsViewController = nil;
  
  // labels view
  [self.labelsViewController tearDown];
  self.labelsViewController = nil;
  
  // citations view
  [self.citationsViewController tearDown];
  self.citationsViewController = nil;
  
  // commands view
  [self.commandsViewController tearDown];
  self.commandsViewController = nil;
    
  // pdfviewer
  [self.pdfViewer tearDown];
  self.pdfViewer = nil;
  
  // engine settings controller
  [self.engineSettings tearDown];
  self.engineSettings = nil;
  
  // engine manager
  [self.engineManager tearDown];
  self.engineManager = nil;
  
  // bookmark manager
  [self.bookmarkManager tearDown];
  self.bookmarkManager = nil;
  
  // palette
  [self.palette tearDown];
  self.palette = nil;
  
  // finder
  [self.finder tearDown];
  self.finder = nil;
  
  // library
  [self.libraryController tearDown];
  self.libraryController = nil;
  
  // spell checker
  [self.spellcheckerViewController tearDown];
  self.spellcheckerViewController = nil;
  
  // pdf view controller
  [self.pdfViewerController tearDown];
  self.pdfViewerController = nil;
  
  // tex editor view controller
  [self.texEditorViewController tearDown];
  self.texEditorViewController = nil;
  
  // file monitor  
  [self.fileMonitor tearDown];
  self.fileMonitor = nil;
  
  // template editor
  [self.templateEditor tearDown];
  self.templateEditor = nil;
  
  self.tabbar.delegate = nil;
  
  
}


- (void)windowWillClose:(NSNotification *)notification 
{
//  NSLog(@"Window will close %@ / %@", [notification object], [self windowForSheet]);
  _windowIsClosing = YES;
  
    
  // see if we want to open the startup screen
	NSWindow *window = [[self windowControllers][0] window];
	[window setDelegate:nil];
	if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
    id appDel = [NSApp delegate];
    BOOL shouldShowStartupScreen = [[[NSUserDefaults standardUserDefaults] valueForKey:TPShouldShowStartupScreenOnClosingLastDocument] boolValue];
		if (appDel != nil && [appDel respondsToSelector:@selector(showStartupScreen:)] && shouldShowStartupScreen) {
			[appDel performSelector:@selector(showStartupScreen:) withObject:self];
      [[ConsoleController sharedConsoleController] close];
		}
	}
  
  [self tearDown];
}


- (void) restoreUIstate
{
//  NSLog(@"Restore UI");
  // controls tab
  [self.controlsTabBarController selectTabAtIndex:[self.project.uiSettings.selectedControlsTab integerValue]];
  [self.infoControlsTabBarController selectTabAtIndex:0];  
  
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
//  NSLog(@"Capturing UI state...");
  
  
  if (self.project == nil) {
    return;
  }
  
  // selected controls tab
  self.project.uiSettings.selectedControlsTab = @([self.controlsTabBarController indexOfSelectedTab]);
  
  // controls width
  NSRect r = [self.leftView frame];
  self.project.uiSettings.controlsWidth = [NSNumber numberWithFloat:r.size.width];
  
  // editor width
  r = [self.centerView frame];
  self.project.uiSettings.editorWidth = [NSNumber numberWithFloat:r.size.width];
  
  // pdf viewer visible rect
  self.project.uiSettings.pdfViewScrollRect = [self.pdfViewerController visibleRectForPersisting];  
  
//  NSLog(@"UI State captured.");
}

+ (void) createTeXnicleProjectAtURL:(NSURL*)aURL
{
//  NSLog(@"Creating new project %@", aURL);
  
  // make a new managed object context  
  NSManagedObjectContext *moc = [TeXProjectDocument managedObjectContextForStoreURL:aURL];
  NSString *path = [aURL path];
  
  [moc processPendingChanges];
  [[moc undoManager] disableUndoRegistration];
  NSEntityDescription *projectDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:moc];
  ProjectEntity *project = [[ProjectEntity alloc] initWithEntity:projectDescription insertIntoManagedObjectContext:moc];
  [project createSettings];
  
  // set name and folder of the project
  NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
  NSString *folder = [path stringByDeletingLastPathComponent];
  [project setValue:name forKey:@"name"];
  [project setValue:folder forKey:@"folder"]; 
  
  [moc processPendingChanges];
  [[moc undoManager] enableUndoRegistration];
  
  NSError *error = nil;
  BOOL success = [moc save:&error];
  
  
  if (success == NO) {
    [NSApp presentError:error];
    return;
  }
}

+ (NSSavePanel*)getDocumentURLSavePanel
{
  // get a project name from the user
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setTitle:@"Save New Project..."];
  [savePanel setAllowedFileTypes:@[@"texnicle"]];
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
  
  // set name and folder of the project
  NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
  NSString *folder = [path stringByDeletingLastPathComponent];
  [self.project setValue:name forKey:@"name"];
  [self.project setValue:folder forKey:@"folder"]; 
  
  [moc processPendingChanges];
  [[moc undoManager] enableUndoRegistration];
  
  NSError *error = nil;
  BOOL success = [moc save:&error];
  if (success == NO) {
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
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
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *path = [bundle pathForResource:@"TeXProject" ofType:@"momd"];
  NSURL *url = [NSURL fileURLWithPath:path];
  NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
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
  options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
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

#pragma mark -
#pragma mark Core Data overrides

- (NSManagedObjectModel*)managedObjectModel
{
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *path = [bundle pathForResource:@"TeXProject" ofType:@"momd"];
  NSURL *url = [NSURL fileURLWithPath:path];
  NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
  return model;
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
	
  // check version at URL
  NSError *metaerror = nil;
  NSDictionary *storeMeta = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:url error:&metaerror];
  
  // get new managed object model
  NSManagedObjectModel *model = [self managedObjectModel];
  
  // check if the new model is compatible, otherwise we try to repair store files created with
  // model version 11, because they had a merged model with the Library.
  if ([model isConfiguration:nil compatibleWithStoreMetadata:storeMeta] == NO) {
    // load XML file
    [self repairXMLStoreAtURL:url];
  }
    
  options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
  options[NSInferMappingModelAutomaticallyOption] = @YES;
  
  BOOL result = [super configurePersistentStoreCoordinatorForURL:url
																													ofType:fileType
																							modelConfiguration:configuration
																										storeOptions:options
																													 error:error];
  options = nil;
  
  if (result) {
    NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
    NSPersistentStore *pStore = [psc persistentStoreForURL:url];
    id existingMetadata = [psc metadataForPersistentStore:pStore][(NSString *)kMDItemKeywords];
    if (existingMetadata == nil) {
      result = [self setMetadataForStoreAtURL:url];
    }  
  }
    
  return result;
}

- (void) repairXMLStoreAtURL:(NSURL*)url
{
  NSStringEncoding encoding;
  NSString *fileContents = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:NULL];
  if (fileContents != nil) {
    NSMutableArray *outlines = [NSMutableArray array];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//    NSLog(@"%@", lines);
    for (NSInteger kk=0; kk<[lines count]; kk++) {
      NSString *tline = [lines[kk] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      if ([tline isEqualToString:@"<key>Category</key>"]) {
        kk+=3;
        continue;
      }
      if ([tline isEqualToString:@"<key>Entry</key>"]) {
        kk+=3;
        continue;
      }
      
      [outlines addObject:lines[kk]];
    }
//    NSLog(@"Output: %@", outlines);
    if ([outlines count] > 0) {
      
      // make backup of old URL
      NSFileManager *fm = [NSFileManager defaultManager];
      NSError *error = nil;
      NSURL *backupURL = [url URLByAppendingPathExtension:@"backup"];
      if ([fm copyItemAtURL:url toURL:backupURL error:&error]) {
        NSString *outString = [outlines componentsJoinedByString:@"\n"];
        //      NSLog(@"%@", outString);
        error = nil;
        if ([outString writeToURL:url atomically:YES encoding:encoding error:&error] == NO) {
          // failed to write
          NSAlert *alert = [NSAlert alertWithMessageText:@"File Repair Failed"
                                           defaultButton:@"OK"
                                         alternateButton:nil
                                             otherButton:nil
                               informativeTextWithFormat:@"The repair of the old format texnicle file failed. Contact bobsoft support for further assistance, or create a new TeXnicle project using the 'build' menu option."];
          [alert runModal];
          NSLog(@"Failed to repair store at url %@", url);
          return;
        }
      } else {
        // copy back the backup
        error = nil;
        if ([fm copyItemAtURL:backupURL toURL:url error:&error] == NO) {
          NSLog(@"Failed to restore backup from %@ to %@", backupURL, url);
          NSLog(@"%@", error);
        }
        NSLog(@"Failed to repair store at url %@", url);
        return;
      }
    }
  }
  
  NSLog(@"Successfully repaired store at url %@", url);
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
  
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
  
  // cancel compile
  if ([theItem tag] == 60) {
    if ([self.engineManager isCompiling]) {
      return YES;
    } else {
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
  
  if (anItem == self.backTabButton) {
    if ([self.tabHistory count] <= 1 || self.currentTabHistoryIndex == 0) {
      return NO;
    }
  }
  
  if (anItem == self.forwardTabButton) {
    if ([self.tabHistory count] <= 1 || self.currentTabHistoryIndex == [self.tabHistory count]-1) {
      return NO;
    }
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
		NSManagedObject *item = all[0];
    path = [item valueForKey:@"pathOnDisk"];
  }  
  
  // if nothing is selected in the outline view, fall back to the current
  // file in the open documents manager.
  if (!path && [all count]==0) {
    path = [[self.openDocuments currentDoc] valueForKey:@"pathOnDisk"];
  }
  
  [self.statusViewController setFilenameText:path];
  if (path) {
    [self.statusViewController enable:YES];    
  } else {
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
  [self.openDocuments addDocument:file select:YES];
}

- (NSManagedObject *)project
{
	if (_project != nil) {
		return _project;
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
		_project = fetchResults[0];
//    NSLog(@"   got project");
    
    
    [[NSSpellChecker sharedSpellChecker] setLanguage:self.project.settings.language];
    
		return _project;
	}
	
	if (fetchError != nil) {
		[self presentError:fetchError];
	}
	else {
		// should present custom error message...
	}
//  NSLog(@"   got nil");
	return nil;
}


#pragma mark -
#pragma mark Tree Action Menu

- (IBAction) showCategoryActionMenu:(id)sender
{
  
  _selectedItem = nil;
  
	// Make popup menu with bound actions
	_treeActionMenu = [[NSMenu alloc] initWithTitle:@"Project Tree Action Menu"];
	[_treeActionMenu setAutoenablesItems:NO];
  
  // check selected item(s)
  NSArray *selectedItems = [self.projectItemTreeController selectedObjects];
//  NSLog(@"Selected items %@", selectedItems);
  
  if ([selectedItems count] == 0) {
    
    // add existing files
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add Existing file(s)..."
                                                  action:@selector(addExistingFile:)
                                           keyEquivalent:@""];
    [item setTarget:self];
    [_treeActionMenu addItem:item];
    
    // add existing folders
    item = [[NSMenuItem alloc] initWithTitle:@"Add Existing folder..."
                                      action:@selector(addExistingFolder:)
                               keyEquivalent:@""];
    [item setTarget:self];
    [_treeActionMenu addItem:item];

  } else if ([selectedItems count] == 1) {
    
    _selectedItem = selectedItems[0];
    _selectedRow = [self.projectOutlineView selectedRow];
    NSString *itemName = [_selectedItem valueForKey:@"name"];
    
    // if a folder is selected...
    if ([_selectedItem isKindOfClass:[FolderEntity class]]) {
      
      // add existing files
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add Existing file(s)..."
                                                    action:@selector(addExistingFileToSelectedFolder:)
                                             keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // add existing folders
      item = [[NSMenuItem alloc] initWithTitle:@"Add Existing folder..."
                                        action:@selector(addExistingFolder:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // add existing folders
      item = [[NSMenuItem alloc] initWithTitle:@"New Folder"
                                        action:@selector(addNewFolder:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // rename selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Rename \u201c%@\u201d", itemName]
                                        action:@selector(renameItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // Remove selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Remove \u201c%@\u201d", itemName]
                                        action:@selector(removeItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
    } else {
      
      // rename selected
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Rename \u201c%@\u201d", itemName]
                                        action:@selector(renameItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // Remove selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Remove \u201c%@\u201d", itemName]
                                        action:@selector(removeItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // reveal selected
      item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Reveal \u201c%@\u201d in Finder", itemName]
                                        action:@selector(revealItem:)
                                 keyEquivalent:@""];
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // reveal selected
      if ([self.project valueForKey:@"mainFile"] == _selectedItem) {
        item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Unset \u201c%@\u201d as main file", itemName]
                                          action:@selector(setMainItem:)
                                   keyEquivalent:@""];
      } else {
        item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Set \u201c%@\u201d as main file", itemName]
                                          action:@selector(setMainItem:)
                                   keyEquivalent:@""];
      }
      
      [item setTarget:self];
      [_treeActionMenu addItem:item];
      
      // Locate selected
      NSFileManager *fm = [NSFileManager defaultManager];
      if (![fm fileExistsAtPath:[_selectedItem valueForKey:@"pathOnDisk"]]) {
        item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Locate \u201c%@\u201d on disk", itemName]
                                          action:@selector(locateItem:)
                                   keyEquivalent:@""];
        [item setTarget:self];
        [_treeActionMenu addItem:item];
      }      
      
    }
    
  } else {
    
    NSInteger nselected = [selectedItems count];
    
    // Remove selected
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Remove selected %ld items", nselected]
                                      action:@selector(removeItem:)
                               keyEquivalent:@""];
    [item setTarget:self];
    [_treeActionMenu addItem:item];
    
    // 
    
    
  }
  
//  NSLog(@"Made menu %@", _treeActionMenu);
  
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
	
	
	[NSMenu popUpContextMenu:_treeActionMenu withEvent:event forView:(NSButton *)sender];

	
	
}


- (IBAction) setMainItem:(id)sender
{
	if ([self.project valueForKey:@"mainFile"] == _selectedItem) {
		[self.project setValue:nil forKey:@"mainFile"];
	} else {
		[self.project setValue:_selectedItem forKey:@"mainFile"];
	}
	[self.projectOutlineView setNeedsDisplay:YES];
  [self showDocument];
}

- (IBAction) revealItem:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *fullpath = [_selectedItem valueForKey:@"pathOnDisk"];
	[ws selectFile:fullpath inFileViewerRootedAtPath:[fullpath stringByDeletingLastPathComponent]];
}

- (IBAction) renameItem:(id)sender
{
  [self renameItemAtRow:_selectedRow];
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
	_itemBeingRenamed = row;
	
	NSString *oldName = [items[row] valueForKey:@"name"];
	[_renameField setStringValue:oldName];
	
	// show the sheet
	[NSApp beginSheet:_renameSheet
		 modalForWindow:[self windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
	// select only the name up to the extension
	NSText* textEditor = [_renameSheet fieldEditor:YES forObject:_renameField];
	NSRange r = [oldName rangeOfString:[oldName stringByDeletingPathExtension]];
	[textEditor setSelectedRange:r];
}

- (IBAction) endRenameSheet:(id)sender
{
	if ([(NSButton*)sender tag] == 0) {
		[NSApp endSheet:_renameSheet];
		[_renameSheet orderOut:sender];
		return;
	}
	
	[NSApp endSheet:_renameSheet];
	[_renameSheet orderOut:sender];
	
	// else we go on and rename
  //	NSLog(@"Renaming to %@", [nameField stringValue]);
	
	[self performSelector:@selector(renameItemTo:) withObject:[_renameField stringValue] afterDelay:0.0];
  //	[self renameItemTo:[nameField stringValue]];
	
}

- (void) renameItemTo:(NSString*)newName
{
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] disableUndoRegistration];
	
	NSArray *items = [self.projectItemTreeController flattenedContent];
	ProjectItemEntity *item = items[_itemBeingRenamed];
  //	NSLog(@"Renaming %@", item);
	
	[item setValue:newName forKey:@"name"];
	
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] enableUndoRegistration];
	//	[self updateChangeCount:NSChangeDone];
	
	// notify all listeners that a file was renamed
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *dict = @{@"document": item};
	[nc postNotificationName:TPDocumentWasRenamed object:self.projectItemTreeController userInfo:dict];
	
  // update status bar
  [self updateStatusView];
  
}


#pragma mark -
#pragma mark Actions

- (IBAction)showQuickJump:(id)sender
{
  NSView *view = self.mainWindow.contentView;
  NSRect frame = view.frame;
  NSPoint point = NSMakePoint(frame.size.width/2.0, frame.size.height / 3.0);
	NSPoint wp = [view convertPoint:point toView:nil];
  
  self.quickJumpController = [[TPQuickJumpViewController alloc] initWithDelegate:self
                                                                         atPoint:wp inParentWindow:[view window]];
  
  [self.quickJumpController showPopup];
}

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
  NSPrintInfo *myPrintInfo = [[NSPrintInfo alloc] initWithDictionary:[[self printInfo] dictionary]];
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
  
  
}

- (IBAction)toggleStatusView:(id)sender
{
  [self toggleStatusBar:YES];
}

- (void) toggleStatusBar:(BOOL)animate
{
  NSRect tefr = [self.editorSplitView frame];
  NSRect svfr = [self.statusViewContainer frame];
  
  id tec;
  id sbc;
  if (animate) {
    tec = self.editorSplitView.animator;
    sbc = self.statusViewContainer.animator;
  } else {
    tec = self.editorSplitView;
    sbc = self.statusViewContainer;
  }
  
  if (_statusViewIsShowing) {
    _statusViewIsShowing = NO;
    // move status view out
    [sbc setFrame:NSMakeRect(svfr.origin.x, svfr.origin.y-svfr.size.height, svfr.size.width, svfr.size.height)];    
    // stretch tex editor container
    NSRect newFrame = NSMakeRect(tefr.origin.x, tefr.origin.y-svfr.size.height, tefr.size.width, tefr.size.height+svfr.size.height);
    //NSLog(@"Change editor container frame to %@", NSStringFromRect(newFrame));
    [tec setFrame:newFrame];
  } else {
    _statusViewIsShowing = YES;
    // move status view in
    [sbc setFrame:NSMakeRect(svfr.origin.x, svfr.origin.y+svfr.size.height, svfr.size.width, svfr.size.height)];    
    // shrink tex editor container
    [tec setFrame:NSMakeRect(tefr.origin.x, tefr.origin.y+svfr.size.height, tefr.size.width, tefr.size.height-svfr.size.height)];
  }
  
  // update settings if necessary
  if ([self.project.settings.showStatusBar boolValue] != _statusViewIsShowing) {
    self.project.settings.showStatusBar = @(_statusViewIsShowing);
  }
}

- (IBAction) openStandaloneWindow:(id)sender
{
	NSArray *selected = [self.projectItemTreeController selectedObjects];
	for (ProjectItemEntity *item in selected) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			if ([[item valueForKey:@"isText"] boolValue]) {
        [(FileEntity*)item increaseActiveCount];
				[self.openDocuments standaloneWindowForFile:(FileEntity*)item];
			} else {				
				// pass the opening of the file to the system
				[[NSWorkspace sharedWorkspace] openFile:[item valueForKey:@"pathOnDisk"]];				
			}
		}
	}
}

- (IBAction) findInProject:(id)sender
{
  [self.controlsTabview selectTabViewItemAtIndex:4];
  [self.windowForSheet makeFirstResponder:self.finder.searchField];
}

#pragma mark -
#pragma mark Tab navigation

- (void) clearTabHistory
{
  [self.tabHistory removeAllObjects];
  self.currentTabHistoryIndex = -1;
}

- (IBAction)backTabButtonPressed:(id)sender
{
  self.navigatingHistory = YES;
  // get the previous file
  self.currentTabHistoryIndex--;
  if (self.currentTabHistoryIndex < 0) {
    self.currentTabHistoryIndex = 0;
  }
  //  NSLog(@"Going back to index %ld", self.currentTabHistoryIndex);
  
  FileEntity *file = (self.tabHistory)[self.currentTabHistoryIndex];
  
  // select document
  [self.openDocuments selectTabForFile:file];
  
}

- (IBAction)forwardTabButtonPressed:(id)sender
{
  self.navigatingHistory = YES;
  self.currentTabHistoryIndex++;
  if (self.currentTabHistoryIndex >= [self.tabHistory count]) {
    self.currentTabHistoryIndex = [self.tabHistory count]-1;
  }
  //  NSLog(@"Going forward to index %d", self.currentTabHistoryIndex);
  
  // get the previous file
  FileEntity *file = (self.tabHistory)[self.currentTabHistoryIndex];
  
  // select document
  [self.openDocuments selectTabForFile:file];
}


#pragma mark -
#pragma mark Notification Handlers

- (void) handleOpenDocumentsDidChangeFileNotification:(NSNotification*)aNote
{
  if (self.navigatingHistory) {
    self.navigatingHistory = NO;
    return;
  }
  
  NSInteger historyLength = [self.tabHistory count];
//  NSLog(@"History length %ld", historyLength);
//  NSLog(@"Current index %ld", self.currentTabHistoryIndex);
  FileEntity *file = [[aNote userInfo] valueForKey:@"file"];
  if (file) {
    if (self.currentTabHistoryIndex+1 < historyLength) {
      // insert this object
      [self.tabHistory insertObject:file atIndex:self.currentTabHistoryIndex+1];
//      NSLog(@"Inserted object at %ld", self.currentTabHistoryIndex+1);
      // clear objects after this index
      NSRange indexRange = NSMakeRange(self.currentTabHistoryIndex+2, historyLength-(self.currentTabHistoryIndex+2-1));
      NSIndexSet *indicesToRemove = [NSIndexSet indexSetWithIndexesInRange:indexRange];
//      NSLog(@"Removing indices %@", indicesToRemove);
      [self.tabHistory removeObjectsAtIndexes:indicesToRemove];
      self.currentTabHistoryIndex = [self.tabHistory count]-1;
    } else {
      // add to end of the history
      [self.tabHistory addObject:file];
      self.currentTabHistoryIndex = [self.tabHistory count]-1;
//      NSLog(@"Added object at index %ld", self.currentTabHistoryIndex);
    }
  }
  
  [self.texEditorViewController.textView performSelector:@selector(applyLineSpacingToDocument) withObject:nil afterDelay:0];  
  
  [self.projectItemTreeController setNeedsDisplay];
}

- (void) handleOpenDocumentsDidAddFileNotification:(NSNotification*)aNote
{
}


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
  NSInteger column = [self.texEditorViewController.textView column];
  NSInteger cursorPosition = [self.texEditorViewController.textView cursorPosition];
  NSInteger lineNumber = [self.texEditorViewController.textView lineNumber];
  [self.statusViewController setColumn:column];
  [self.statusViewController setLineNumber:lineNumber];
  [self.statusViewController setCharacter:cursorPosition];
  [self.statusViewController updateDisplay];
}


- (void) handleProjectOutlineViewSelectionChange:(NSNotification*)aNote
{
	if ([self.projectItemTreeController isDeleting])
		return;
  
  // set all to not selected
  for (ProjectItemEntity *item in self.project.items) {
    item.isSelected = NO;
  }
  
	NSArray *all = [self.projectItemTreeController selectedObjects];	
	if ([all count] == 1) {
		NSManagedObject *item = all[0];
		if ([item isKindOfClass:[FileEntity class]]) {
      if (self.openDocuments) {
        FileEntity *file = (FileEntity*)item;
        file.isSelected = YES;
        [self.openDocuments addDocument:file select:YES];
      }
		}
	}
  
  [self.projectOutlineView reloadData];
  
  [self updateStatusView];
}

- (void) handleControlTabSelectionChanged:(NSNotification*)aNote
{
}

- (void) handleInfoTabSelectionChanged:(NSNotification*)aNote
{
//  NSLog(@"Tab changed %@", [aNote object]);
  if ([aNote object] == self.infoControlsTabBarController) {
    NSInteger idx = [self.infoControlsTabBarController indexOfSelectedTab];
//    NSLog(@"Index %d", idx);
    switch (idx) {
      case 0:
        // bookmarks
        break;
      case 1:
        // warnings
        [self.warningsViewController updateUI];
        break;
      case 2:
        // spelling
        break;
      case 3:
        // labels
        [self.labelsViewController updateUI];
        break;
      case 4:
        // citations
        [self.citationsViewController updateUI];
        break;
      case 5:
        // commands
        [self.commandsViewController updateUI];
        break;
      default:
        break;
    }
  }
}


#pragma mark -
#pragma mark Split view delegate

- (IBAction) showIntegratedPDFViewer:(id)sender
{  
  
  NSRect rightfr = [self.rightView frame];
  if ([self.rightView isHidden] == NO) {
    return;
  }
  
  CGFloat size = kSplitViewRightMinSize;
  
  rightfr.size.width = size;
  NSRect midfr = [self.centerView frame];
  midfr.size.width = midfr.size.width - size;
  midfr.origin.x = size;
  
  [self.centerView setFrame:midfr];
  [self.rightView.animator setFrame:rightfr];
  [self.rightView setHidden:NO];
}

- (IBAction) showIntegratedConsole:(id)sender
{
  NSView *topView = [self.editorSplitView subviews][0];
  NSView *bottomView = [self.editorSplitView subviews][1];
  
  //  NSLog(@"Left view is hidden? %d", [leftView isHidden]);
  //  NSLog(@"Left view size %@", NSStringFromRect([leftView frame]));
  
  
  NSRect bottomfr = [bottomView frame];
  if ([bottomView isHidden] == NO) {
    return;
  }
  
  CGFloat size = 150.0;
  
  bottomfr.size.height = size;
  NSRect topfr = [topView frame];
  topfr.size.height = topfr.size.height - size;
  topfr.origin.y = size;
  
  [topView setFrame:topfr];
  [bottomView.animator setFrame:bottomfr];
  [bottomView setHidden:NO];
}

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
  
  if (splitView == self.editorSplitView) {
    return b.size.height - 42.0 - [splitView dividerThickness];
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
  
  if (splitView == self.editorSplitView) {
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

- (NSString*) nameOfFileBeingEdited
{
  return [[self.openDocuments currentDoc] name];
}

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)aChecker
{
//  NSLog(@"Edit asking if it should syntax check of %@", [[self.openDocuments currentDoc] name]);
//  NSLog(@"  checking window %@", [self mainWindow]);
  
  if ([[[self.openDocuments currentDoc] extension] isEqualToString:@"tex"] == NO) {
    return NO;
  }
  
  if ([[self mainWindow] isKeyWindow] == NO) {
//    NSLog(@"     yes!");
    return NO;
  }
  
  return YES;
}

-(NSString*)codeForCommand:(NSString*)command
{
  NSString *code = [self.libraryController codeForCommand:command];
  return code;
}

- (NSArray*)commandsBeginningWithPrefix:(NSString *)prefix
{
  return [self.libraryController commandsBeginningWith:prefix];
}

-(NSString*)fileExtension
{
  return [[[self.openDocuments currentDoc] pathOnDisk] pathExtension];
}

- (NSUndoManager*)currentUndoManager
{
	id file = [self.openDocuments currentDoc];
	FileDocument *doc = [file document];
	return [doc undoManager];
}


-(NSArray*)listOfCitations
{
  NSMutableArray *citations = [NSMutableArray array];
  
  for (TPFileMetadata *file in self.fileMetadata) {
    for (BibliographyEntry *entry in file.citations) {
      if (![citations containsObject:entry]) {
        [citations addObject:entry];
      }
    }
  }
  
  return citations;
}

-(NSArray*)listOfCommands
{
  NSMutableArray *commands = [NSMutableArray array];
  
  for (TPFileMetadata *file in self.fileMetadata) {
    for (TPNewCommand *c in file.userNewCommands) {
      [commands addObject:c.argument];
    }
  }
  
  // add palette commands
  [commands addObjectsFromArray:[self.palette listOfCommands]];
    
  return commands;
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
  
  for (TPFileMetadata *file in self.fileMetadata) {
    [tags addObjectsFromArray:file.labels];
  }
  
	return tags;	
}

-(NSArray*)listOfTeXFilesPrependedWith:(NSString*)prefix
{
	NSMutableArray *texfiles = [NSMutableArray array];
	NSArray *files = [self.project valueForKey:@"items"];
	for (ProjectItemEntity *item in files) {
		if ([item isKindOfClass:[FileEntity class]]) {
      NSString *path = [[[prefix stringByAppendingString:[item valueForKey:@"filepath"]] stringByStandardizingPath] stringByDeletingPathExtension];
			[texfiles addObject:path];
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
    if (selected[0] != aFile) {
      [self.projectItemTreeController selectItem:aFile];
    }
  }
}



#pragma mark -
#pragma mark ProjectOutlineController delegate

- (NSArray*) allMetadataFiles
{
  return self.fileMetadata;
}

- (id) mainFile
{
  
  // get the metadata file for the project
  NSManagedObjectID *mainId = [self.project.mainFile objectID];
  
  for (TPFileMetadata *file in self.fileMetadata) {
    if (file.objId == mainId) {
      return file;
    }
  }
  
  return nil;
}

- (NSString*)textForFile:(id)aFile
{
  if ([aFile isKindOfClass:[FileEntity class]]) {
    return [aFile workingContentString];
  }
  
  if ([aFile isKindOfClass:[TPFileMetadata class]]) {
    return [aFile valueForKey:@"text"];
  }
  
  return @"";
}

- (id)fileWithPath:(NSString *)path
{
  return [self.project fileWithPath:path];
}

- (NSNumber*) maxOutlineDepth
{
  return self.project.uiSettings.maxOutlineDepth;
}

- (void) didSetMaxOutlineDepthTo:(NSInteger)depth
{
  self.project.uiSettings.maxOutlineDepth = @(depth);
}


- (BOOL) shouldGenerateOutline
{
  // check last edit and don't trigger an update unless we have a pause
  NSDate *lastEdit = [self.openDocuments.currentDoc lastEditDate];
  NSDate *now = [NSDate date];
  float lastEditInterval = 1.0;
  if ([now timeIntervalSinceDate:lastEdit] < lastEditInterval) {
    // do nothing
    return NO;
  }
  
  // if outline tab is selected....
  if (self.controlsTabBarController != nil && [self.controlsTabBarController indexOfSelectedTab] == 3) {
    return YES;
  }
  return NO;
}


- (id) currentFile
{
  FileEntity *file = self.openDocuments.currentDoc;  
  return [self metaFileForFile:file];
}

- (NSInteger) locationInCurrentEditor
{
  NSRange s = [self.texEditorViewController.textView selectedRange];
  return s.location;
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
      imagePath = [[root stringByAppendingPathComponent:[fileRoot stringByAppendingFormat:@"-%lu", count]] stringByAppendingPathExtension:ext];
      count++;
    }
        
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setTitle:@"Save pasted image"];
    [panel setAllowedFileTypes:@[type]];
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

- (IBAction) cancelCompile:(id)sender
{
  [self.engineManager cancelCompilation];
  [self.engineManager.consoleManager error:@"User cancelled typesetting"];
}

- (IBAction) clean:(id)sender
{
  [self.engineManager trashAuxFiles:NO];
  [self showDocument];
}

- (IBAction) buildAndView:(id)sender
{
  _openPDFAfterBuild = YES;
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPSaveOnCompile] boolValue]) {
		[self saveDocument:self];
	}
  [self build];
}

- (IBAction) buildProject:(id)sender
{
  _openPDFAfterBuild = NO;
	
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


- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote
{
  //NSLog(@"Typesetting finished");
  
  [self.miniConsole setAnimating:NO];
  
  // parse log file
  NSString *logfile = [[self documentToCompile] stringByAppendingPathExtension:@"log"];
  [self.embeddedConsoleViewController loadLogAtPath:logfile];
  
  NSDictionary *userinfo = [aNote userInfo];
  if ([[userinfo valueForKey:@"success"] boolValue]) {
    //NSLog(@"  and it was successful");
    [self showDocument];  
    if (_openPDFAfterBuild) {
      [self openPDF:self];
    }
    
    // if we want, sync pdf
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPSyncPDFAfterCompile] boolValue]) {
      NSInteger line = [self.texEditorViewController.textView lineNumber];
      NSInteger col  = [self.texEditorViewController.textView column];
      [self syncToPDFLine:line column:col giveFocus:NO];
    }
    
    // if we want, trash aux files
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPAutoTrashAfterCompile] boolValue]) {
      [self.engineManager trashAuxFiles:YES];
    }
    
  }
  
  
  _building = NO;
}


- (void) parseLogFile:(NSString*)logpath
{
  // TEST------
  // load log file
//  NSArray *logItems = [TPTeXLogParser parseLogFile:logpath];
//  NSLog(@"%@", logItems);
  
}

- (void)doLiveBuild
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if ([[NSApplication sharedApplication] isActive] == NO) {
    return;
  }
  
  if (!_building && [self.project.settings.doLiveUpdate boolValue] && [self.project hasEdits]) {
    if ([[defaults valueForKey:TPLiveUpdateMode] integerValue] == 1) {
      // check for the last edit date
      NSDate *lastEdit = [self.openDocuments.currentDoc lastEditDate];
      NSDate *now = [NSDate date];
      float lastEditInterval = [[defaults valueForKey:TPLiveUpdateEditDelay] floatValue];
      if ([now timeIntervalSinceDate:lastEdit] < lastEditInterval) {
        // do nothing
        return;
      }
    }
    
    // do update
    [self saveDocument:self];
    [self.miniConsole setAnimating:YES];
    // setup the engine
    _building = YES;
    [self.engineManager liveCompile];
//    [self build];
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
    self.pdfViewer = [[PDFViewer alloc] initWithDelegate:self];
  }
  [self.pdfViewer showWindow:self];
  
}

- (BOOL) canViewPDF
{
	FileEntity *mainfile = [self.project valueForKey:@"mainFile"];
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
	if ([self.project valueForKey:@"mainFile"]) {
		return YES;
	}	
	return NO;
}

- (BOOL) canBibTeX
{
	if ([self.project valueForKey:@"mainFile"]) {
		return YES;
	}	
	return NO;	
}


#pragma mark -
#pragma mark Files and Folders

- (void) didAddFile:(FileEntity*)aFile
{
  if ([self.textFiles containsObject:aFile] == NO) {
    [self.textFiles addObject:aFile];
  }
}

- (void) didRemoveFile:(FileEntity*)aFile
{
  TPFileMetadata *metafile = [self metaFileForFile:aFile];
  if (metafile) {
    [self.fileMetadata removeObject:metafile];
  }
  
  if ([self.textFiles containsObject:aFile]) {
    [self.textFiles removeObject:aFile];
  }
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
  
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
		if ([self.openDocuments count]>0) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[_tabView tabViewItemAtIndex:0] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1020) {
		if ([self.openDocuments count]>1) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[_tabView tabViewItemAtIndex:1] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1030) {
		if ([self.openDocuments count]>2) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[_tabView tabViewItemAtIndex:2] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1040) {
		if ([self.openDocuments count]>3) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[_tabView tabViewItemAtIndex:3] label]]];
			return YES;
		} else {
			return NO;
		}
	}
	if (tag == 1050) {
		if ([self.openDocuments count]>4) {
			[menuItem setTitle:[NSString stringWithFormat:@"Tab \u201c%@\u201d", [[_tabView tabViewItemAtIndex:4] label]]];
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
  
  // create folder on disk
  if (tag == 401000) {
    // if the selected parent is a folder on disk, or there is no selected parent, then
    // we can create a folder on disk
    NSArray *selected = [self.projectItemTreeController selectedObjects];
    if ([selected count] == 0) {
      return YES;
    }
    
    if ([selected count] == 1) {
      id object = selected[0];
      if ([object isMemberOfClass:[FileEntity class]]) {
        if ([object pathOnDisk]) {
          return YES;
        }
      }
    }
    
    return NO;
  }
  
  
  // delete selected bookmark
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

  // show integrated console
  if (tag == 2041) {
    if ([[self.editorSplitView subviews][1] isHidden] == NO) {
      return NO;
    } else {
      return YES;
    }
  }
  
  // show integrated pdf viewer
  if (tag == 2042) {
    if ([self.rightView isHidden] == NO) {
      return NO;
    } else {
      return YES;
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
  
  // cancel typesetting
  if (tag == 66) {
    if ([self.engineManager isCompiling]) {
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
		[_tabView selectTabViewItemAtIndex:0];
	} else if (tag == 1020) {
		[_tabView selectTabViewItemAtIndex:1];
	} else if (tag == 1030) {
		[_tabView selectTabViewItemAtIndex:2];
	} else if (tag == 1040) {
		[_tabView selectTabViewItemAtIndex:3];
	} else if (tag == 1050) {
		[_tabView selectTabViewItemAtIndex:4];
	} else {
		// do nothing
	}
}

- (IBAction) selectNextTab:(id)sender
{
	[_tabView selectNextTabViewItem:self];
}

- (IBAction) selectPreviousTab:(id)sender
{
	[_tabView selectPreviousTabViewItem:self];
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
	[self.projectItemTreeController addExistingFile:self toFolder:(FolderEntity*)_selectedItem];
}




- (NSArray*)getSelectedItems
{
	return [self.projectItemTreeController selectedObjects];
}

- (IBAction) jumpToMainFile:(id)sender
{
	FileEntity *mainFile = [self.project valueForKey:@"mainFile"];
	
	if (mainFile) {
		[self.projectItemTreeController selectDocument:mainFile];
	}
	
}

- (IBAction) setMainFile:(id)sender
{
	// get selected file
	NSArray *items = [self getSelectedItems];
	if ([items count] == 1) {
		ProjectItemEntity *item = items[0];
    NSArray *exts = [[TPSupportedFilesManager sharedSupportedFilesManager] supportedExtensions];
		if ([exts containsObject:[item valueForKey:@"extension"]]) {
			if ([self.project valueForKey:@"mainFile"] == item) {
        self.project.mainFile = nil;
			} else {
				[self.project setValue:item forKey:@"mainFile"];
			}
			[self.projectOutlineView setNeedsDisplay:YES];
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
	NSArray *selected = [self.projectItemTreeController selectedObjects];
	if ([selected count] == 1) {
    id obj = selected[0];
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
  [self.openDocuments closeAllTabs];
  [self.statusViewController setFilenameText:@""];
}

- (IBAction) closeCurrentTab:(id)sender
{
	[self.openDocuments closeCurrentTab];
}

- (IBAction) newFolder:(id)sender
{
  // create popup menu
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
  
  // if we selected item is a real folder on disk, then we can make a subfolder
  NSArray *selectedItems = [self.projectItemTreeController selectedObjects];
 
  ProjectItemEntity *selectedProjectItem = nil;
  if ([selectedItems count] > 0)
    selectedProjectItem = selectedItems[0];
  
  // Make popup menu with bound actions
  self.createFolderMenu = [[NSMenu alloc] initWithTitle:@"New Folder Action Menu"];
  [self.createFolderMenu setAutoenablesItems:YES];
  
  NSMenuItem *item;
  
  if (selectedProjectItem == nil || [selectedProjectItem pathOnDisk]) {
    // New folder on disk
    item = [[NSMenuItem alloc] initWithTitle:@"Create New Folder on Disk"
                                                  action:@selector(newFolderOnDisk:)
                                           keyEquivalent:@""];
    [item setTarget:self];
    [self.createFolderMenu addItem:item];
  }
  
  // New group folder
  item = [[NSMenuItem alloc] initWithTitle:@"Create New Group Folder"
                                    action:@selector(newGroupFolder:)
                             keyEquivalent:@""];
  [item setTarget:self];
  [self.createFolderMenu addItem:item];
  	
	
	[NSMenu popUpContextMenu:self.createFolderMenu withEvent:event forView:(NSButton *)sender];
    
}

- (IBAction) newGroupFolder:(id) sender
{
  [self.projectItemTreeController addNewFolder];
}

- (IBAction) newFolderOnDisk:(id)sender
{
  [self.projectItemTreeController addNewFolderCreateOnDisk];
}

- (IBAction) newFile:(id)sender
{
	// ask the user for a new file name
	[NSApp beginSheet:_newFileSheet
		 modalForWindow:[self windowForSheet]
			modalDelegate:self
		 didEndSelector:NULL
				contextInfo:NULL];	
	
}

- (IBAction) endNewFileSheet:(id)sender
{
	// user clicked cancel
	if ([(NSButton*)sender tag] == 0) {
		[NSApp endSheet:_newFileSheet];
		[_newFileSheet orderOut:sender];
		return;
	}
	
	// before we add this file, we better check that the file doesn't exist
	NSString *name = [_newFilenameTextField stringValue];
	NSString *pathOnDisk = [self.projectItemTreeController pathForInsertion];
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
		[alert beginSheetModalForWindow:_newFileSheet
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
	NSString *name = [_newFilenameTextField stringValue];
	
	[self.projectItemTreeController addNewFile:name
                                  atFilepath:nil
                                   extension:nil
                                      isText:YES
                                        code:nil
                                  asMainFile:NO
                                createOnDisk:YES];
	
	[NSApp endSheet:_newFileSheet];
	[_newFileSheet orderOut:self];
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
    NSDictionary *template = (__bridge NSDictionary*)v;
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
			code = [NSString stringWithString:[dict valueForKey:@"Code"]];
			break;
		}
	}
	
	if (!code) {
		
    
    code = @"\
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
            \\end{document}";
  }
  
  return code;
}

- (void) addNewArticleMainFile
{
  //  NSLog(@"********* Adding new main file to %@", project);
  
	NSString *code = [TeXProjectDocument stringForNewArticleMainFileCode];
	
	// check if main.tex exists
	NSString *newName = [NSString stringWithFormat:@"%@_main.tex", [self.project name]];
	NSString *filename = [[self.project folder] stringByAppendingPathComponent:newName];
	NSFileManager *fm = [NSFileManager defaultManager];
	int dd = 1;
	while ([fm fileExistsAtPath:filename]) {
		NSString *name = [NSString stringWithFormat:@"%@_main%d.tex", [self.project name], dd];
		filename = [[self.project folder] stringByAppendingPathComponent:name];
		dd++;
	}
  //	NSLog(@"Filename %@", filename);
	
	id file = [self.projectItemTreeController addNewFile:[filename lastPathComponent]
                                       atFilepath:nil
                                        extension:@"tex"
                                           isText:YES
                                             code:code
                                       asMainFile:YES
                                     createOnDisk:YES];
	
	
	[file setValue:@0 forKey:@"sortIndex"];
  
	// add include folder
	[self.projectItemTreeController setSelectionIndexPath:nil];
	FolderEntity *includeFolder = [self.projectItemTreeController addFolder:@"include" withFilePath:nil createOnDisk:YES];
  [includeFolder setValue:@1 forKey:@"sortIndex"];
  
	// add images folder
	[self.projectItemTreeController setSelectionIndexPath:nil];
	FolderEntity *imagesFolder = [self.projectItemTreeController addFolder:@"images" withFilePath:nil createOnDisk:YES];
  [imagesFolder setValue:@2 forKey:@"sortIndex"];
	
	// select the main file
  [self.openDocuments performSelector:@selector(addAndSelectDocument:) withObject:file afterDelay:0.1];
  [self.projectItemTreeController performSelector:@selector(selectItem:) withObject:file afterDelay:0.5];
}

- (IBAction) newMainTeXFile:(id)sender
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	NSManagedObject *newFile = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"TeXFile"
																																								 inManagedObjectContext:moc]
																			insertIntoManagedObjectContext:moc];
	
	
	[newFile setValue:@"main" forKey:@"name"];
  [newFile setValue:self.project forKey:@"project"];  
	[self.projectItemTreeController addObject:newFile];
	[self.project setValue:newFile forKey:@"mainFile"];
	
	
}

- (IBAction) delete:(id)sender
{
	[self.projectItemTreeController remove:self];
}

- (BOOL) canAddNewFile
{
	return [self.projectItemTreeController canAdd];
}


- (BOOL) canAddNewTeXFile
{
	return [self.projectItemTreeController canAdd];
}

- (BOOL) canAddNewFolder
{
	return [self.projectItemTreeController canAdd];
}

- (BOOL) canRemove
{
	return [self.projectItemTreeController canRemove];
}

- (NSManagedObject*) addFileAtURL:(NSURL*)aURL copy:(BOOL)copyFile
{
	id doc = [self.projectItemTreeController addFileAtPath:[aURL path] toFolder:nil copy:copyFile];
	if (doc) {
		[self.openDocuments addDocument:doc select:YES];
		return doc;
	}
	
	return nil;
}

#pragma mark -
#pragma mark Template Stuff

- (void) showTemplatesSheet
{
	if (self.templateEditor == nil) {
    self.templateEditor = [[TPTemplateEditor alloc] initWithDelegate:self activeFilename:YES editMode:NO];
  }
  
  // set suggested filename
  NSString *suggestedDocumentName = [NSString stringWithFormat:@"untitled%02lu", [[self.projectItemTreeController flattenedContent] count]];
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
    NSString *insertionPath = [self.projectItemTreeController pathForInsertion];
    //	NSLog(@"Checking path on disk %@", insertionPath);
    NSString *filename = [insertionPath stringByAppendingPathComponent:name];
    
    // check all project files
    NSArray *allitems = [self.projectItemTreeController flattenedContent];
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
                          contextInfo:(__bridge void *)(aTemplate)];
      
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
	[self.projectItemTreeController addNewFile:name
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
//	[self.openDocuments commitStatus];
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
	[self.openDocuments commitStatus];
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
  self.project.settings.language = language;
  
	// make sure we save the files here
	if ([self saveAllProjectFiles]) {    
    NSString *path = [absoluteURL path];
    NSURL *url = [NSURL fileURLWithPath:path];
        
		BOOL result = [super saveToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
    
    return result;
	}	
  
	return NO;
}
  
- (BOOL) saveAllProjectFiles
{
	// write contents of all files to disk
	NSArray *allItems = [self.projectItemTreeController flattenedContent];
  
//  NSLog(@"Saving %@", allItems);
	BOOL success = YES;
	for (ProjectItemEntity *item in allItems) {
		if ([item isKindOfClass:[FileEntity class]]) {
			FileEntity *file = (FileEntity*)item;
      if ([file isText] && [file isImage] == NO) {
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


#pragma mark -
#pragma mark File Monitor Delegate

- (NSArray*) fileMonitorFileList:(TPFileMonitor*)aMonitor
{
  if (![self.mainWindow isVisible] || self.fileMonitor == nil || self.fileMonitor != aMonitor) {
    return @[];
  }
  
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
  [self syncToPDFLine:lineNumber column:column];
}

- (void) syncToPDFLine:(NSInteger)lineNumber column:(NSInteger)column
{
  [self syncToPDFLine:lineNumber column:column giveFocus:YES];
}

- (void) syncToPDFLine:(NSInteger)lineNumber column:(NSInteger)column giveFocus:(BOOL)shouldFocus
{
  NSMutableArray *pdfViews = [NSMutableArray array];
  if (self.pdfViewerController.pdfview != nil) {
    [pdfViews addObject:self.pdfViewerController.pdfview];
  }
  if (self.pdfViewer.pdfViewerController.pdfview != nil) {
    [pdfViews addObject:self.pdfViewer.pdfViewerController.pdfview];
  }
  
  MHSynctexController *sync = [[MHSynctexController alloc] initWithEditor:self.texEditorViewController.textView pdfViews:pdfViews];
  [sync displaySelectionInPDFFile:[self compiledDocumentPath]
                       sourceFile:[[self.openDocuments currentDoc] pathOnDisk]
                       lineNumber:lineNumber
                           column:column
                        giveFocus:shouldFocus];
  
  if (shouldFocus == NO) {
    // give focus back to tex editor
    [self.mainWindow performSelector:@selector(makeFirstResponder:) withObject:self.texEditorViewController.textView afterDelay:0];
  }
}

- (IBAction)findSource:(id)sender
{
  PDFSelection *selection = [self.pdfViewerController.pdfview currentSelection];
  NSString *selectedText = [selection string];
  [self findSourceOfText:selectedText];
}

- (void) findSourceOfText:(NSString *)string
{
  [self.controlsTabview selectTabViewItemAtIndex:4];
  [self.finder setSearchTerm:string];
  [self.finder searchForTerm:string];
  _shouldHighlightFirstMatch = YES;
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
  [self asyncShowDocument];
}

- (void) asyncShowDocument
{
  __block PDFViewerController *blockPdfViewControler = self.pdfViewerController;
  
  dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_sync(globalQueue, ^{
    //  NSLog(@"Show doc");
    NSView *view = [blockPdfViewControler.pdfview documentView];
    PDFPage *page = [blockPdfViewControler.pdfview currentPage];
    NSInteger index = [blockPdfViewControler.pdfview.document indexForPage:page];
    NSRect r = [view visibleRect];
    //  NSLog(@"Visible rect %@", NSStringFromRect(r));
    BOOL hasDoc = [blockPdfViewControler hasDocument];
    [blockPdfViewControler redisplayDocument];
    if (hasDoc) {
      PDFDisplayMode mode = [blockPdfViewControler.pdfview displayMode];
      if (mode == kPDFDisplaySinglePageContinuous ||
          mode == kPDFDisplayTwoUpContinuous) {
        [view scrollRectToVisible:r];
      } else {
        if (page) {
          [blockPdfViewControler.pdfview goToPage:[blockPdfViewControler.pdfview.document pageAtIndex:index]];
        }
      }
    }
  });
}


#pragma mark -
#pragma mark Finder Delegate

- (void) didBeginSearch:(FindInProjectController *)aFinder
{
}

- (void) didEndSearch:(FindInProjectController *)aFinder
{
  if (_shouldHighlightFirstMatch) {
    if ([self.finder count]>0) {
      [self.finder jumpToSearchResult:0];
    }
  }
  _shouldHighlightFirstMatch = NO;
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

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile
{  
  id file = nil;
  if ([aFile isKindOfClass:[TPFileMetadata class]]) {
    file = [self.managedObjectContext objectWithID:[aFile valueForKey:@"objId"]];
  } else {
    file = aFile;
  }
  
	// first select the file
	[self.projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
  
	[self.projectItemTreeController setSelectionIndexPath:idx];
    
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // Now highlight the search term in that 
  [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
  
  // Make text view first responder
  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
  
}

- (void) highlightFinderSearchResult:(TPDocumentMatch*)result
{	  
  TPResultDocument *doc = result.parent;
  FileEntity *file = doc.document;
  
  // first select the file
	[self.projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
	[self.projectItemTreeController setSelectionIndexPath:idx];
  [self.openDocuments updateDoc];
  
  // search for result in attributed string
  NSRange range = NSMakeRange(0, [[self.texEditorViewController.textView string] length]);
    
  [[self.texEditorViewController.textView textStorage] enumerateAttribute:TPDocumentMatchAttributeName inRange:range options:0
                                                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                                                 
                                                                 if (value == result) {
                                                                   [self.texEditorViewController.textView selectRange:range scrollToVisible:YES animate:YES];
                                                                   *stop = YES;
                                                                 }                                                                 
                                                               }];
  
  // Make text view first responder
  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
  
}

- (void) replaceSearchResult:(TPDocumentMatch*)result withText:(NSString*)replacement
{
  TPResultDocument *doc = result.parent;
  FileEntity *file = doc.document;
  
  // first select the file
	[self.projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
	[self.projectItemTreeController setSelectionIndexPath:idx];
  [self.openDocuments updateDoc];
  
  // search for result in attributed string
  NSRange range = NSMakeRange(0, [[self.texEditorViewController.textView string] length]);
  
  [[self.texEditorViewController.textView textStorage] enumerateAttribute:TPDocumentMatchAttributeName inRange:range options:0
                                                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                                                 
                                                                 if (value == result) {
                                                                   [self.texEditorViewController.textView replaceRange:range withText:replacement scrollToVisible:YES animate:YES];
                                                                   *stop = YES;
                                                                 }                                                                 
                                                               }];
  
  // Make text view first responder
  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
  
}

- (void) replaceSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile withText:(NSString*)replacement
{
	// first select the file
	[self.projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:aFile];
	[self.projectItemTreeController setSelectionIndexPath:idx];
  
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // now replace the text
  [self.texEditorViewController.textView replaceRange:aRange withText:replacement scrollToVisible:NO animate:NO];
  
  // Make text view first responder
  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];  
}

#pragma mark -
#pragma mark PDFViewerController delegate

- (BOOL) pdfViewControllerShouldDoLiveUpdate:(PDFViewerController *)aPDFViewer
{
  return [self.project.settings.doLiveUpdate boolValue];
}

- (void) pdfViewController:(PDFViewerController *)aPDFViewer didSelectLiveUpdate:(BOOL)state
{
  self.project.settings.doLiveUpdate = @(state);
}

- (BOOL)pdfViewControllerShouldShowPDFThumbnails:(PDFViewerController*)aPDFViewer
{
  return [self.project.uiSettings.showPDFThumbnails boolValue];
}

- (void)pdfViewController:(PDFViewerController*)aPDFViewer didChangeThumbnailsViewerState:(BOOL)visible
{
  self.project.uiSettings.showPDFThumbnails = @(visible);
}


- (void)pdfview:(MHPDFView*)pdfView didCommandClickOnPage:(NSInteger)pageIndex inRect:(NSRect)aRect atPoint:(NSPoint)aPoint
{
//  NSLog(@"Clicked on PDF in project...");
  
  NSMutableArray *pdfViews = [NSMutableArray array];
  if (self.pdfViewerController.pdfview != nil) {
    [pdfViews addObject:self.pdfViewerController.pdfview];
  }
  if (self.pdfViewer.pdfViewerController.pdfview != nil) {
    [pdfViews addObject:self.pdfViewer.pdfViewerController.pdfview];
  }
  
  MHSynctexController *sync = [[MHSynctexController alloc] initWithEditor:self.texEditorViewController.textView pdfViews:pdfViews];
  NSInteger lineNumber = NSNotFound;
  NSString *sourcefile = [sync sourceFileForPDFFile:[self compiledDocumentPath] lineNumber:&lineNumber pageIndex:pageIndex pageBounds:aRect point:aPoint];
  
  sourcefile = [sourcefile stringByStandardizingPath];
  [self selectLine:lineNumber inFileAtPath:sourcefile];
}

- (BOOL) selectLine:(NSInteger)lineNumber inFileAtPath:(NSString*)sourcefile
{
  if ([sourcefile isAbsolutePath]) {
    //    NSLog(@"    source file is absolute path");
    sourcefile = [self.project.folder relativePathTo:sourcefile];
  }
  //NSLog(@"  source file: %@", sourcefile);
  FileEntity *file = [self.project fileWithPath:sourcefile];
  //NSLog(@"    got project file: %@", file);
  [self.openDocuments addDocument:file select:YES];
  if (file) {
    [self.openDocuments selectTabForFile:file];
    if (lineNumber >= 0 && lineNumber != NSNotFound) {
      [self.texEditorViewController.textView goToLine:(int)lineNumber];
    }
    return YES;
  }
  
  return NO;
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

- (void)libraryController:(TPLibraryController *)library insertText:(NSString *)text
{
  TeXTextView *textView = self.texEditorViewController.textView;
  NSRange sel = [textView selectedRange];
  NSAttributedString *astr = [NSAttributedString stringWithPlaceholdersRestored:text attributes:[NSDictionary currentTypingAttributes]];
  
  if ([textView shouldChangeTextInRange:sel replacementString:[astr string]]) {
    [[textView textStorage] replaceCharactersInRange:sel withAttributedString:astr];
    [textView didChangeText];
    [textView performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
  }
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
  [self.texEditorViewController.textView updateEditorRuler];
  
  // forward this to all open document windows
  for (id<BookmarkManagerDelegate> doc in [self.openDocuments standaloneWindows]) {
    [doc didDeleteBookmark];
  }
  
}

- (void) didAddBookmark
{
  [self.texEditorViewController.textView updateEditorRuler];
  
  // forward this to all open document windows
  for (id<BookmarkManagerDelegate> doc in [self.openDocuments standaloneWindows]) {
    [doc didAddBookmark];
  }  
}

- (void) jumpToBookmark:(Bookmark *)aBookmark
{
  NSInteger linenumber = [aBookmark.linenumber integerValue];
  FileEntity *file = aBookmark.parentFile;
  
	// first select the file
	[self.projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
	[self.projectItemTreeController setSelectionIndexPath:idx];
  
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

- (NSString*)language
{
  return self.project.settings.language;
}

- (void) didSelectLanguage:(NSString *)aName
{
  self.project.settings.language = aName;
  if ([aName isEqualToString:TPSpellingAutomaticByLanguage]) {
    [[NSSpellChecker sharedSpellChecker] setAutomaticallyIdentifiesLanguages:YES];
  } else {
    [[NSSpellChecker sharedSpellChecker] setLanguage:self.project.settings.language];
    [[NSSpellChecker sharedSpellChecker] setAutomaticallyIdentifiesLanguages:NO];
  }
  [self.texEditorViewController.textView checkSpelling:self];
}

-(NSArray*)registeredEngineNames
{
  return [self.engineManager registeredEngineNames];
}

-(void)didSelectDoBibtex:(BOOL)state
{
  self.project.settings.doBibtex = @(state);
}

-(void)didSelectDoPS2PDF:(BOOL)state
{
  self.project.settings.doPS2PDF = @(state);
}

-(void)didSelectOpenConsole:(BOOL)state
{
  self.project.settings.openConsole = @(state);
}

-(void)didChangeNCompile:(NSInteger)number
{
  self.project.settings.nCompile = @(number);
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
  // if we are in live update, return no
  if ([self.project.settings.doLiveUpdate boolValue]) {
    return @NO;
  }
  
  return self.project.settings.openConsole;
}

-(NSNumber*)nCompile
{
  // Probably we don't want this. At least we should disable the correspond
  // UI on the project preferences, otherwise it's very confusing for the user.
  //if (_liveUpdate)
  //  return @1;
  
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

- (void) documentCompileDidFinish:(BOOL)success
{
}

#pragma mark -
#pragma mark Project Template Stuff

- (IBAction)createProjectTemplate:(id)sender
{
  if (self.templateCreator == nil) {
    self.templateCreator = [[TPProjectTemplateCreator alloc] initWithDelegate:self];
  }
  
  // set suggested name
  NSString *name = [self.project.name stringByAppendingString:@"_template"];
  self.templateCreator.suggestedTemplateName = name;
  self.templateCreator.suggestedTemplateDescription = [NSString stringWithFormat:@"Project template based on project %@", self.project.name];
  
  [NSApp beginSheet:self.templateCreator.window
     modalForWindow:[self windowForSheet]
      modalDelegate:self
     didEndSelector:nil
        contextInfo:NULL];
  
}


#pragma mark -
#pragma mark Spell Checker View Delegate

- (void) handleSupportedFileSpellCheckFlagChangedNotification:(NSNotification*)aNote
{
  [self.spellcheckerViewController updateAllLists];
}

- (NSArray*)filesToSpellCheck
{
  NSMutableArray *files = [NSMutableArray array];
  
  for (ProjectItemEntity *item in self.project.items) {
    if ([item isKindOfClass:[FileEntity class]]) {
      FileEntity *file = (FileEntity*)item;
      
      if ([file isText]) {        
        NSString *ext = [file valueForKey:@"extension"] ;
        TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
        for (NSString *lext in [sfm supportedExtensionsForSpellChecking]) {
          if ([ext isEqual:lext]) {
            [files addObject:file];
          }
        }        
      }
    }    
  }
  
  return files;
}

- (BOOL)shouldPerformSpellCheck
{
  // if info tab is selected....  
  if (self.controlsTabBarController != nil && [self.controlsTabBarController indexOfSelectedTab] == 5) {
    // and if the info tab is 2
    if (self.infoControlsTabBarController != nil && [self.infoControlsTabBarController indexOfSelectedTab] == 2) {
      return YES;
    }
  }
  return NO;
}

- (void)replaceMisspelledWord:(NSString*)word atRange:(NSRange)aRange withCorrection:(NSString*)correction inFile:(FileEntity*)file
{
	// first select the file
	[self.projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
	[self.projectItemTreeController setSelectionIndexPath:idx];
  
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // replace the word
  [self.texEditorViewController.textView replaceRange:aRange withText:correction scrollToVisible:YES animate:YES];
  
}

- (void) highlightMisspelledWord:(NSString *)word atRange:(NSRange)aRange inFile:(FileEntity*)file
{
	// first select the file
	[self.projectItemTreeController setSelectionIndexPath:nil];
	// But now try to select the file
	NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
	[self.projectItemTreeController setSelectionIndexPath:idx];
  
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // highlight the word
  [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
  
}


- (void) dictionaryDidLearnNewWord
{
}


#pragma mark -
#pragma mark Metadata manager delegate

- (void) handleMetadataDidBeginUpdateNotification:(NSNotification*)aNote
{
//  if ([aNote object] == self.metadataManager) {
//    self.miniConsoleLastMessage = self.miniConsole.currentMessage;
//    [self.miniConsole message:@"Updating metadata"];
//    [self.miniConsole setAnimating:YES];
//  }
}

- (void) handleMetadataDidEndUpdateNotification:(NSNotification*)aNote
{
//  if ([aNote object] == self.metadataManager) {
//    [self.miniConsole message:self.miniConsoleLastMessage];
//    [self.miniConsole setAnimating:NO];
//  }
}


- (NSArray*) metadataManagerFilesToScan:(TPMetadataManager *)manager
{
  //NSLog(@"Metadata Update on thread %@", [NSThread currentThread]);
  
  // build array of TPFileMetadata for project files
  [self performSelectorOnMainThread:@selector(updateMetaFiles) withObject:nil waitUntilDone:YES];

  //  [self updateMetaFiles];
  
  NSMutableArray *filesToScan = [[NSMutableArray alloc] init];
  
  // loop over our meta files and decide if they need scanned
  for (TPFileMetadata *f in self.fileMetadata) {
    if (f.needsUpdate || f.needsSyntaxCheck) {
      [filesToScan addObject:f];
    }
  }
  
  return filesToScan;
}


- (void) updateMetaFiles
{  
  // NSLog(@"Update meta files on thread %@", [NSThread currentThread]);
  if (self.fileMetadata == nil) {
    self.fileMetadata = [[NSMutableArray alloc] init];
  }
  if (self.textFiles == nil) {
    self.textFiles = [[NSMutableArray alloc] init];
  }
  
  // go through project files and build meta files if necessary
  for (ProjectItemEntity *item in self.project.items) {
    if ([item isKindOfClass:[FileEntity class]]) {
      FileEntity *file = (FileEntity*)item;
      
      // make sure we cache these to stop them being faulted
      if ([self.textFiles containsObject:file] == NO) {
        [self.textFiles addObject:file];
        // NSLog(@"Cached file %p:%@ [%@]", file, file.name, file.objectID);
      }
      
      if ([file isText] && [file isImage] == NO) {
        TPFileMetadata *fm = [self metaFileForFile:file];
        
        // if we don't have the file, add it, otherwise update it
        if (fm == nil) {
          TPFileMetadata *newFile = [[TPFileMetadata alloc] initWithParentId:file.objectID
                                                                   extension:file.extension
                                                                        text:file.workingContentString
                                                                        path:file.pathOnDisk
                                                                 projectPath:[file.filepath stringByStandardizingPath]
                                                                        name:file.name];
          newFile.needsUpdate = YES;
          newFile.needsSyntaxCheck = YES;
          [self.fileMetadata addObject:newFile];
          //NSLog(@"Added metafile %@ <--> %@", newFile, newFile.objId);
        } else {
          
          // check last edit date
          NSDate *lastEdit = file.lastEditDate;
          NSDate *lastUpdate = fm.lastUpdate;
          if ([lastEdit timeIntervalSinceDate:lastUpdate] > 0 || lastUpdate == nil) {
            fm.text = file.workingContentString;
            // update path here because it's relatively expensive, and it shouldn't change often.
            fm.pathOnDisk = file.pathOnDisk;
            fm.needsUpdate = YES;
            fm.needsSyntaxCheck = YES;
          }
          // ensure other info is up to date
          fm.projectPath = [file.filepath stringByStandardizingPath];
          fm.objId = file.objectID;
          fm.name = file.name;
          fm.extension = file.extension;
        }
        
      } // end if isText and not isImage
    } // end if is file entity
  } // end loop over project items
  
  //NSLog(@"*** Have %ld metafiles", [self.fileMetadata count]);
}


- (FileEntity*) fileForMetaFile:(TPFileMetadata*)file
{
  for (FileEntity *f in self.textFiles) {
    if ([f objectID] == file.objId || [file.projectPath isEqualToString:[[f filepath] stringByStandardizingPath]]) {
      return f;
    }
  }
  return nil;
}

- (TPFileMetadata*) metaFileForFile:(FileEntity*)file
{
  for (TPFileMetadata *f in self.fileMetadata) {
    if (f.objId == [file objectID] || [[f projectPath] isEqualToString:[[file filepath] stringByStandardizingPath]]) {
      return f;
    }
  }
  return nil;
}


#pragma mark -
#pragma mark Metadata view delegate

- (NSArray*) metadataViewListOfFiles:(TPMetadataViewController *)aViewController
{
  NSMutableArray *files = [NSMutableArray array];

  for (TPFileMetadata *item in self.fileMetadata) {
    if (aViewController == self.commandsViewController && [item.userNewCommands count] > 0) {
      [files addObject:item];
    } else if (aViewController == self.citationsViewController && [item.citations count] > 0) {
      [files addObject:item];
    } else if (aViewController == self.labelsViewController && [item.labels count] > 0) {
      [files addObject:item];
    } else if (aViewController == self.warningsViewController && [item.syntaxErrors count] > 0) {
      [files addObject:item];
    }
  }
  
  return [NSArray arrayWithArray:files];
}

- (void) metadataView:(TPMetadataViewController *)aViewController didSelectItem:(id)anItem
{
  // get the item's objId and get a file from that
  TPFileMetadata *fileMeta = [anItem valueForKey:@"file"];
  NSManagedObject *obj = [self.managedObjectContext objectWithID:fileMeta.objId];
  if (obj == nil) {
    return;
  }
  
  FileEntity *file = nil;
  if ([obj isKindOfClass:[FileEntity class]]) {
    file = (FileEntity*)obj;
  }
  
  if (file == nil) {
    return;
  }
  
  if (aViewController == self.commandsViewController) {
    // first select the file
    [self.projectItemTreeController setSelectionIndexPath:nil];
    // But now try to select the file
    NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
    [self.projectItemTreeController setSelectionIndexPath:idx];
    
    // now select the text
    NSRange r = [[self.texEditorViewController.textView string] rangeOfString:[anItem valueForKey:@"source"]];
    [self.texEditorViewController.textView selectRange:r scrollToVisible:YES animate:YES];
    
  } else if (aViewController == self.citationsViewController) {
    
    BibliographyEntry *entry = [anItem valueForKey:@"entry"];
    
    // first select the file
    [self.projectItemTreeController setSelectionIndexPath:nil];
    // But now try to select the file
    NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
    [self.projectItemTreeController setSelectionIndexPath:idx];
    
    // just search for the first line of the source string, or up to the first ','
    NSInteger index = 0;
    NSString *source = entry.sourceString;
    while (index < [source length]) {
      unichar c = [source characterAtIndex:index];
      if ([[NSCharacterSet newlineCharacterSet] characterIsMember:c] ||
          c == ',') {
        source = [source substringToIndex:index];
        break;
      }
      index++;
    }
    
    NSRange r = [[self.texEditorViewController.textView string] rangeOfString:source];
    [self.texEditorViewController.textView selectRange:r scrollToVisible:YES animate:YES];
    
  } else if (aViewController == self.labelsViewController) {
    
    // first select the file
    [self.projectItemTreeController setSelectionIndexPath:nil];
    // But now try to select the file
    NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
    [self.projectItemTreeController setSelectionIndexPath:idx];
    
    // now select the text
    NSString *exp = [NSString stringWithFormat:@"\\label(\\[.+?\\]|)\\{%@\\}", [anItem valueForKey:@"text"]];
    
    NSRange r = [TPRegularExpression rangeOfExpr:exp inText:[self.texEditorViewController.textView string]];
    if (r.location != NSNotFound) {
      [self.texEditorViewController.textView selectRange:r scrollToVisible:YES animate:YES];
    }
    
  } else if (aViewController == self.warningsViewController) {
    
    // first select the file
    [self.projectItemTreeController setSelectionIndexPath:nil];
    // But now try to select the file
    NSIndexPath *idx = [self.projectItemTreeController indexPathToObject:file];
    [self.projectItemTreeController setSelectionIndexPath:idx];
    
    [self.texEditorViewController.textView jumpToLine:[[anItem valueForKey:@"line"] integerValue] inFile:file select:YES];
    [self.mainWindow makeFirstResponder:self.texEditorViewController.textView];
    
  }
}

- (NSArray*) metadataView:(TPMetadataViewController *)aViewController newItemsForFile:(TPFileMetadata*)file
{
  if (aViewController == self.commandsViewController) {
    return file.userNewCommands;
  } else if (aViewController == self.citationsViewController) {
    return file.citations;
  } else if (aViewController == self.labelsViewController) {
    return file.labels;
  } else if (aViewController == self.warningsViewController) {
    return file.syntaxErrors;
  }
  
  return @[];
}


#pragma mark -
#pragma mark document report

- (NSString*)fileToReportOn
{
  return [self.project.mainFile pathOnDisk];
}

- (NSString*)documentName
{
  return self.project.mainFile.name;
}

- (IBAction)createDocumentReport:(id)sender
{
  if (self.documentReport == nil) {
    self.documentReport = [[TPDocumentReportWindowController alloc] initWithDelegate:self];
  }
  
  [self.documentReport showWindow:self];
  [self.documentReport startGeneration];
}

#pragma mark -
#pragma mark Console delegate

- (BOOL)texlogview:(TPTeXLogViewController*)logview shouldShowEntriesForFile:(NSString*)aFile
{
  return YES;
}

- (void)texlogview:(TPTeXLogViewController*)logview didSelectLogItem:(TPLogItem*)aLog
{
  if ([self selectLine:aLog.linenumber inFileAtPath:aLog.filepath] == NO) {
    NSURL *url = [NSURL fileURLWithPath:aLog.filepath];
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
      // do stuff
      ExternalTeXDoc *doc = (ExternalTeXDoc*)document;
      if (aLog.linenumber != NSNotFound && aLog.linenumber >= 0) {
        [doc.texEditorViewController.textView performSelector:@selector(goToLineWithNumber:) withObject:@(aLog.linenumber) afterDelay:0];
      }
    }];
    
  }
}

#pragma mark -
#pragma mark Quickjump delegate


- (void) quickjump:(TPQuickJumpViewController *)quickjump didSelectItem:(id)anItem
{
  if (anItem) {
    [self.openDocuments addAndSelectDocument:anItem];
  }
}

- (NSArray*)quickjumpItemsForDisplay:(TPQuickJumpViewController *)quickjump
{
  if (self.quickJumpController == quickjump) {
    
    NSMutableArray *items = [NSMutableArray array];
    for (ProjectItemEntity *item in self.project.items) {
      
      if ([item isKindOfClass:[FileEntity class]]) {
        [items addObject:item];
      }
    }
    
    return items;
  }
  
  return @[];
}



@end
