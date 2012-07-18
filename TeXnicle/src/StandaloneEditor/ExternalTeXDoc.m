  //
//  ExternalTeXDoc.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
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

#import "ExternalTeXDoc.h"
#import "TeXProjectDocument.h"
#import "ProjectEntity.h"
#import "NSString+LaTeX.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "TeXEditorViewController.h"
#import "externs.h"
#import "ConsoleController.h"
#import "UKXattrMetadataStore.h"
#import "MHFileReader.h"
#import "NSAttributedString+LineNumbers.h"
#import "RegexKitLite.h"
#import "MHLineNumber.h"
#import "TPDocumentMatch.h"
#import "NSArray+LaTeX.h"
#import "TPSupportedFilesManager.h"
#import "NSApplication+SystemVersion.h"
#import "TPProjectBuilder.h"
#import "MHSynctexController.h"
#import "TPSyntaxError.h"
#import "TPLabel.h"
#import "TPNewCommand.h"
#import "BibliographyEntry.h"


#define kSplitViewLeftMinSize 210.0
#define kSplitViewCenterMinSize 400.0
#define kSplitViewRightMinSize 400.0

NSString * const TPExternalDocControlsTabIndexKey = @"TPExternalDocControlsTabIndexKey"; 
NSString * const TPExternalDocControlsWidthKey = @"TPExternalDocControlsWidthKey"; 
NSString * const TPExternalDocEditorWidthKey = @"TPExternalDocEditorWidthKey"; 
NSString * const TPExternalDocPDFVisibleRectKey = @"TPExternalDocPDFVisibleRectKey"; 
NSString * const TPMaxOutlineDepth = @"TPMaxOutlineDepth"; 

@implementation ExternalTeXDoc

@synthesize lastEdit;

@synthesize documentData;
@synthesize texEditorContainer;
@synthesize texEditorViewController;
@synthesize fileLoadDate;
@synthesize fileMonitor;
@synthesize engineManager;
@synthesize settings;

@synthesize miniConsole;
@synthesize embeddedConsoleContainer;
@synthesize embeddedConsoleViewController;

@synthesize mainWindow;
@synthesize pdfViewContainer;
@synthesize pdfViewerController;
@synthesize results;
@synthesize statusViewController;
@synthesize statusViewContainer;

@synthesize tabbarController;
@synthesize infoTabbarController;

@synthesize warningsContainerView;
@synthesize warningsViewController;

@synthesize labelsContainerView;
@synthesize labelsViewController;

@synthesize citationsContainerView;
@synthesize citationsViewController;

@synthesize commandsContainerView;
@synthesize commandsViewController;

@synthesize palette;
@synthesize paletteContainerView;

@synthesize library;
@synthesize libraryContainerView;

@synthesize outlineViewController;
@synthesize outlineViewContainer;

@synthesize engineSettingsController;
@synthesize prefsContainerView;

@synthesize spellcheckerViewController;
@synthesize spellCheckerContainerView;

@synthesize pdfViewer;

@synthesize leftView;
@synthesize centerView;
@synthesize rightView;
@synthesize splitView;

@synthesize templateEditor;

@synthesize liveUpdateTimer;
@synthesize metadataUpdateTimer;
@synthesize maxOutlineViewDepth;

- (id) init
{
  self = [super init];
  if (self) {
    _encoding = -1;
  }
  
  return self;
}

+ (NSArray *)readableTypes
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSArray *types =  [[super readableTypes] arrayByAddingObjectsFromArray:[sfm supportedTypes]];
//  NSLog(@"Readable types: %@", types);
  return types;
}

+ (NSArray *)writableTypes
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSArray *types = [[super writableTypes] arrayByAddingObjectsFromArray:[sfm supportedTypes]];
//  NSLog(@"Writable types: %@", types);
  return types;
}

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation
{
//  NSLog(@"Getting file extension for type %@", typeName);
  NSString *ext = [super fileNameExtensionForType:typeName saveOperation:saveOperation];
  if (ext) {
    return ext;
  }
  
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  ext = [sfm extensionForType:typeName];
  if (ext) {
    return ext;
  }
  
  return nil;
}

- (void) captureUIsettings
{
  if ([self fileURL]) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // controls tab index
    [dict setValue:[NSNumber numberWithInteger:[self.tabbarController indexOfSelectedTab]] forKey:TPExternalDocControlsTabIndexKey];
    
    // controls width
    NSRect r = [controlsViewContainer frame];
    [dict setValue:[NSNumber numberWithFloat:r.size.width] forKey:TPExternalDocControlsWidthKey];
    
    // editor width
    r = [texEditorContainer frame];
    [dict setValue:[NSNumber numberWithFloat:r.size.width] forKey:TPExternalDocEditorWidthKey];
    
    // pdf view visible rect
    [dict setValue:[self.pdfViewerController visibleRectForPersisting] forKey:TPExternalDocPDFVisibleRectKey];
    
    // max outline depth
    [dict setValue:self.maxOutlineViewDepth forKey:TPMaxOutlineDepth];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];  
    [UKXattrMetadataStore setData:data forKey:@"com.bobsoft.TeXnicleUISettings" atPath:[[self fileURL] path] traverseLink:YES];  
  }
}

- (void) restoreUIsettings
{
  if ([self fileURL]) {
    NSData *data = [UKXattrMetadataStore dataForKey:@"com.bobsoft.TeXnicleUISettings" atPath:[[self fileURL] path] traverseLink:YES];
    if (data) {
      NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
      if (dict) {
        
        // controls tab index
        NSInteger tabIndex = [[dict valueForKey:TPExternalDocControlsTabIndexKey] integerValue];
        [self.tabbarController selectTabAtIndex:tabIndex];
        [self.infoTabbarController selectTabAtIndex:2];
        
        if (![NSApp isLion]) {
          // controls width
          CGFloat controlsWidth = [[dict valueForKey:TPExternalDocControlsWidthKey] floatValue];
          if (controlsWidth >= 0.0) {
            NSRect fr = [controlsViewContainer frame];
            fr.size.width = controlsWidth;
            [controlsViewContainer setFrame:fr];
          }
          
          // editor width
          CGFloat editorWidth = [[dict valueForKey:TPExternalDocEditorWidthKey] floatValue];
          if (editorWidth >= 0.0) {
            NSRect fr = [texEditorContainer frame];
            fr.size.width = editorWidth;
            [texEditorContainer setFrame:fr];
          }
        }
        
        // max outline depth
        self.maxOutlineViewDepth = [dict valueForKey:TPMaxOutlineDepth];
        if (self.maxOutlineViewDepth == nil) {
          self.maxOutlineViewDepth = [NSNumber numberWithInt:5];
        }
        [self.outlineViewController setOutlineDepth:[self.maxOutlineViewDepth integerValue]];
        
        
        // pdf view visible rect
        NSString *pdfVisibleRect = [dict valueForKey:TPExternalDocPDFVisibleRectKey];
        [self.pdfViewerController restoreVisibleRectFromPersistentString:pdfVisibleRect];
        
      }
    }    
  }
}


- (void)awakeFromNib
{
//  NSLog(@"Awake from nib");
  self.results = [NSMutableArray array];
  
  // ensure we have a settings dictionary before proceeding
  [self initSettings];
  
  [self.tabbarController selectTabAtIndex:1];
  [self.infoTabbarController selectTabAtIndex:2];
  
//  NSLog(@"Awake from nib");
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  self.texEditorViewController.delegate = self;
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
  [self.texEditorViewController enableEditor];
  [self.texEditorViewController setPerformSyntaxCheck:YES];
  
	if (self.documentData) {
//    NSLog(@"Setting document data to %@", self.documentData);
		[self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
	}
	
  // warnings view
  self.warningsViewController = [[[TPWarningsViewController alloc] initWithDelegate:self] autorelease];
  [self.warningsViewController.view setFrame:self.warningsContainerView.bounds];
  [self.warningsContainerView addSubview:self.warningsViewController.view];
  
  // labels view
  self.labelsViewController = [[[TPLabelsViewController alloc] initWithDelegate:self] autorelease];
  [self.labelsViewController.view setFrame:self.labelsContainerView.bounds];
  [self.labelsContainerView addSubview:self.labelsViewController.view];
  
  // citations view
  self.citationsViewController = [[[TPCitationsViewController alloc] initWithDelegate:self] autorelease];
  [self.citationsViewController.view setFrame:self.citationsContainerView.bounds];
  [self.citationsContainerView addSubview:self.citationsViewController.view];
  
  // commands view
  self.commandsViewController = [[[TPNewCommandsViewController alloc] initWithDelegate:self] autorelease];
  [self.commandsViewController.view setFrame:self.commandsContainerView.bounds];
  [self.commandsContainerView addSubview:self.commandsViewController.view];
  
  // setup outline view  
  self.outlineViewController = [[[TPProjectOutlineViewController alloc] initWithDelegate:self] autorelease];
  [self.outlineViewController.view setFrame:[self.outlineViewContainer bounds]];
  [self.outlineViewContainer addSubview:self.outlineViewController.view];
  
  // setup pdf viewer
  self.pdfViewerController = [[[PDFViewerController alloc] initWithDelegate:self] autorelease];
  [self.pdfViewerController.view setFrame:[self.pdfViewContainer bounds]];
  [self.pdfViewContainer addSubview:self.pdfViewerController.view];
  
  // set up engine manager
  self.engineManager = [TPEngineManager engineManagerWithDelegate:self];
    
  // set up engine settings
  self.engineSettingsController = [[[TPEngineSettingsController alloc] initWithDelegate:self] autorelease];
  [self.engineSettingsController.view setFrame:[self.prefsContainerView bounds]];
  [self.prefsContainerView addSubview:self.engineSettingsController.view];
    
  // setup palette
  self.palette = [[[PaletteController alloc] initWithDelegate:self] autorelease];
  [self.palette.view setFrame:[self.paletteContainerView bounds]];
  [self.paletteContainerView addSubview:self.palette.view];
  
  // setup library
  self.library = [[[TPLibraryController alloc] initWithDelegate:self] autorelease];
  [self.library.view setFrame:[self.libraryContainerView bounds]];
  [self.libraryContainerView addSubview:self.library.view];
  
  // setup spellchecker
  self.spellcheckerViewController = [[[TPSpellCheckerListingViewController alloc] initWithDelegate:self] autorelease];
  [self.spellcheckerViewController.view setFrame:[self.spellCheckerContainerView bounds]];
  [self.spellCheckerContainerView addSubview:self.spellcheckerViewController.view];  
  
  // set up engine settings
  [self setupSettings];
  
  // set up file monitor
  self.fileMonitor = [TPFileMonitor monitorWithDelegate:self];
  
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
				 selector:@selector(handleTextSelectionChanged:)
						 name:NSTextViewDidChangeSelectionNotification
					 object:self.texEditorViewController.textView];
	  
  [nc addObserver:self
         selector:@selector(handleTypesettingCompletedNotification:)
             name:TPEngineCompilingCompletedNotification
           object:self.engineManager];
  
  [nc addObserver:self
         selector:@selector(handleTextChanged:) 
             name:NSTextDidChangeNotification
           object:self.texEditorViewController.textView];
  
  self.miniConsole = [[[MHMiniConsoleViewController alloc] init] autorelease];
  NSArray *items = [[self.mainWindow toolbar] items];
  for (NSToolbarItem *item in items) {
//    NSLog(@"%@: %@", [item itemIdentifier], NSStringFromRect([[item view] frame]));
    if ([[item itemIdentifier] isEqualToString:@"MiniConsole"]) {
      NSBox *box = (NSBox*)[item view];
      [box setContentView:self.miniConsole.view];
    }
  }
  [self.miniConsole message:@"Welcome to TeXnicle."];

  // register the mini console
  [self.engineManager registerConsole:self.miniConsole];
  
  // embedded console
  self.embeddedConsoleViewController = [[[TPConsoleViewController alloc] init] autorelease];
  [self.embeddedConsoleViewController.view setFrame:[self.embeddedConsoleContainer bounds]];
  [self.embeddedConsoleContainer addSubview:self.embeddedConsoleViewController.view];
  [self.engineManager registerConsole:self.embeddedConsoleViewController];  
  
  // setup status view
  self.statusViewController = [[[TPStatusViewController alloc] init] autorelease];
  [self.statusViewController.view setFrame:[self.statusViewContainer bounds]];
  [self.statusViewContainer addSubview:self.statusViewController.view];  
  statusViewIsShowing = YES; 
//  NSLog(@"Status view showing...");
  
  NSNumber *showStatusBarSetting = [self.settings valueForKey:@"TPStandAloneEditorShowStatusBar"];
  if (showStatusBarSetting) {
    if(![showStatusBarSetting boolValue]) {
      [self toggleStatusBar:NO];
    }
  } else {
    [self.settings setObject:[NSNumber numberWithBool:statusViewIsShowing] forKey:@"TPStandAloneEditorShowStatusBar"];
  }
  [self updateFileStatus];
  
  if ([self inVersionsMode]) {
    [self.texEditorViewController disableJumpBar];
  }
  
  // Show associated pdf document, assuming we have on
  [self showDocument];
  
  // resture UI settings
  [self performSelector:@selector(restoreUIsettings) withObject:nil afterDelay:0];
  
  // Present templates if we have no URL
  [self performSelector:@selector(checkToShowTemplateSheet) withObject:nil afterDelay:0];
  
  // insert controls tab bar in the responder chain
  [self performSelector:@selector(insertTabbarControllerIntoResponderChain) withObject:nil afterDelay:0];
  
  _building = NO;
  _liveUpdate = NO;
  self.liveUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doLiveBuild) userInfo:nil repeats:YES];
  self.metadataUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateMetadata) userInfo:nil repeats:YES];
  
}

- (void) insertTabbarControllerIntoResponderChain
{
  [self.tabbarController setNextResponder:self.mainWindow.nextResponder];
  [self.mainWindow setNextResponder:self.tabbarController];    
}

- (void)checkToShowTemplateSheet
{
  if ([self fileURL] == nil 
      && ([self.texEditorViewController.textView string] == nil || [[self.texEditorViewController.textView string] length]==0)) {
    [self performSelector:@selector(showTemplatesSheet) withObject:nil afterDelay:0];    
  }
}


- (void)windowWillEnterVersionBrowser:(NSNotification *)notification
{
//  NSLog(@"Window will enter versions browser");
  _leftDividerPostion = self.leftView.frame.size.width;
  _rightDividerPostion = self.splitView.frame.size.width - self.rightView.frame.size.width;
  _windowFrame = self.windowForSheet.frame;
  [self.splitView setPosition:0 ofDividerAtIndex:0];
  [self.splitView setPosition:self.splitView.frame.size.width ofDividerAtIndex:1];
  
  // disable some UI 
  [self.texEditorViewController disableJumpBar];
  [self.texEditorViewController.textView setEditable:NO];  
  [self.statusViewController enable:NO];
}

- (void)windowDidEnterVersionBrowser:(NSNotification *)notification
{
  _inVersionsBrowser = YES;
}

- (void)windowWillExitVersionBrowser:(NSNotification *)notification
{
//  NSLog(@"Window will exit versions browser");
}

- (void)windowDidExitVersionBrowser:(NSNotification *)notification
{
  if (self.windowForSheet == [notification object]) {
    _inVersionsBrowser = NO;
    
    CAAnimation *anim = [CABasicAnimation animation];
    [anim setDelegate:self];
    [self.windowForSheet setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frame"]];
    
    [self.windowForSheet.animator setFrame:_windowFrame display:YES];
  }
  [self performSelector:@selector(restoreSplitViewPositions) withObject:nil afterDelay:0.2];
  
  // reenable some UI
  [self.texEditorViewController enableJumpBar];
  [self.texEditorViewController.textView setEditable:YES];  
  [self.statusViewController enable:YES];
}


- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
  [self performSelector:@selector(restoreSplitViewPositions) withObject:nil afterDelay:0.2];
  [self.windowForSheet makeKeyAndOrderFront:self];
}


- (void) restoreSplitViewPositions
{
//  NSLog(@"Restoring positions %f, %f", _leftDividerPostion, _rightDividerPostion);
  [self.splitView setPosition:_leftDividerPostion ofDividerAtIndex:0];
  [self.splitView setPosition:_rightDividerPostion ofDividerAtIndex:1];
}

- (void) windowDidBecomeKey:(NSNotification *)notification
{
  
  // set language for this project
  [[NSSpellChecker sharedSpellChecker] setLanguage:[self.settings valueForKey:@"language"]];
  
}
- (void)windowWillClose:(NSNotification *)notification 
{		
//  NSLog(@"WindowWillClose %@", self);
  
  if (![self inVersionsMode]) {
    if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
      if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
        [[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
      }
    }
  }
  
  if ([NSApp isLion]) {
    [self captureUIsettings];
  }  
  
  [self cleanUp];
}


- (void) initSettings
{  
  if (self.settings == nil) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.settings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     [defaults valueForKey:TPDefaultEngineName], @"engineName", 
                     [defaults valueForKey:BibTeXDuringTypeset], @"doBibtex", 
                     [defaults valueForKey:TPShouldRunPS2PDF], @"doPS2PDF", 
                     [defaults valueForKey:OpenConsoleOnTypeset], @"openConsole",
                     [defaults valueForKey:TPNRunsPDFLatex], @"nCompile",
                     [[NSSpellChecker sharedSpellChecker] language], @"language",
                     [NSNumber numberWithBool:YES], @"TPStandAloneEditorShowStatusBar",
                     nil];
  }
  
  self.maxOutlineViewDepth = [NSNumber numberWithInt:5];
  
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
  [self.settings setObject:[NSNumber numberWithBool:statusViewIsShowing] forKey:@"TPStandAloneEditorShowStatusBar"];
}


- (void) setupSettings
{
  [self initSettings]; 
  [self.engineSettingsController setupEngineSettings];
}

#pragma mark -
#pragma mark Notification Handlers

- (void) syntaxCheckerDidFinish
{
//  [self.warningsViewController performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

- (void) handleTextSelectionChanged:(NSNotification*)aNote
{
	[self updateCursorInfoText];
}

- (void) updateCursorInfoText
{
  NSInteger cursorPosition = [self.texEditorViewController.textView cursorPosition];
  NSInteger lineNumber = [self.texEditorViewController.textView lineNumber];
  [self.statusViewController setCharacter:cursorPosition];
  [self.statusViewController setLineNumber:lineNumber];
  [self.statusViewController updateDisplay];
}

- (void) stopTimers
{
  if (self.liveUpdateTimer) {
    [self.liveUpdateTimer invalidate];
    self.liveUpdateTimer = nil;
  }    
  if (self.metadataUpdateTimer) {
    [self.metadataUpdateTimer invalidate];
    self.metadataUpdateTimer = nil;
  }
}

- (void) cleanUp
{
//  NSLog(@"### Clean up");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  
  // stop timers
  [self stopTimers];
  
  // max outline view depth
  self.maxOutlineViewDepth= nil;
  
  // results
  self.results = nil;
  
  // pdfviewer
  self.pdfViewer.delegate = nil;
  self.pdfViewer = nil;
  
  // warnings view
  self.warningsViewController.delegate = nil;
  self.warningsViewController = nil;
  
  // labels view
  self.labelsViewController.delegate = nil;
  self.labelsViewController = nil;
  
  // citations view
  self.citationsViewController.delegate = nil;
  self.citationsViewController = nil;
  
  // commands view
  self.commandsViewController.delegate = nil;
  self.commandsViewController = nil;
  
  // pdf view controller
  self.pdfViewerController.delegate = nil;
  self.pdfViewerController = nil;

  // mini console
  self.miniConsole = nil;
  
  // console viewer
  self.embeddedConsoleViewController = nil;
  
  // outline view controller
  self.outlineViewController.delegate = nil;
  self.outlineViewController = nil;
  
  // status view controller
  self.statusViewController = nil;
  
  // spell checker  
  self.spellcheckerViewController.delegate = nil;
  [self.spellcheckerViewController stop];
  self.spellcheckerViewController = nil;
  
  // settings
  self.settings = nil;
  
  // engine settings controller
  self.engineSettingsController.delegate = nil;
  self.engineSettingsController = nil;
  
  // library
  self.library.delegate = nil;
  self.library = nil;
  
  // palette
  self.palette.delegate = nil;
  self.palette = nil;
  
  // tex editor view controller
  self.texEditorViewController.textView.delegate = nil;
  self.texEditorViewController.delegate = nil;
  self.texEditorViewController = nil;
  
  // file load date
  self.fileLoadDate = nil;
  
  // file monitor  
  self.fileMonitor.delegate = nil;
  self.fileMonitor = nil;
  
  // engine manager
  self.engineManager.delegate = nil;  
  self.engineManager = nil;
  
  // template editor
  self.templateEditor.delegate = nil;
  self.templateEditor = nil;
 
}


- (void) dealloc
{
  self.lastEdit = nil;
	[super dealloc];
}


- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
  if ([self inVersionsMode]) {
    return NO;
  }
    
	NSInteger tag = [menuItem tag];
  
  // Open Project Folder in Finder
  if (tag == 21) {
    return NO;
  }
  
  // Add Existing Folder...
  if (tag == 28) {
    return NO;
  }
  
  // Create Project Template...
  if (tag == 29) {
    return NO;
  }
  
  // find text selection in pdf
  if (tag == 116020) {
    return [self.pdfViewerController hasDocument] && [self.texEditorViewController textViewHasSelection];
  }
  
  // Find PDF Selection in Source
  if (tag == 116030) {
    return [self pdfHasSelection]; 
  }
  
  // toggle status bar
  if (tag == 2040) {
    if (statusViewIsShowing) {
      [menuItem setTitle:@"Hide Status Bar"];
    } else {
      [menuItem setTitle:@"Show Status Bar"];
    }
  }
  
  // show integrated console
  if (tag == 2041) {
    if ([[[editorSplitView subviews] objectAtIndex:1] isHidden] == NO) {
      return NO;
    } else {
      return YES;
    }
  }
  
  // show integrated pdf viewer
  if (tag == 2042) {
    if ([rightView isHidden] == NO) {
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
  

	return [super validateMenuItem:menuItem];
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

- (void) findSourceOfText:(NSString *)searchTerm
{
  NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
  NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
  
  // search this string
  NSMutableAttributedString *aStr = [[self.texEditorViewController.textView textStorage] mutableCopy];
  NSArray *lineNumbers = [aStr lineNumbersForTextRange:NSMakeRange(0, [aStr length])];
  NSString *string = [aStr unfoldedString];
  [aStr release];
  if (!string)
    return;
  
	NSArray *searchTerms = [searchTerm componentsSeparatedByString:@" "];
  if ([searchTerms count] == 0) {
    return;
  }
  
	NSMutableString *regexp = [NSMutableString stringWithString:@"(\\n)?.*"];
	for (NSString *term in searchTerms) {
		[regexp appendFormat:@"%@(\\s)*(\\n)?", term];
	}
	[regexp appendFormat:@".*(\\n)?"];
  
  NSArray *regexpresults = [string componentsMatchedByRegex:regexp];
  
  NSScanner *aScanner = [NSScanner scannerWithString:string];
  shouldContinueSearching = YES;
  if ([regexpresults count] > 0) {
    
    for (NSString *result in regexpresults) {
      if (!shouldContinueSearching) {
        break;
      } // If should continue 
      
      NSString *returnResult = nil; //[NSString stringWithControlsFilteredForString:result];
      
      returnResult = [result stringByTrimmingCharactersInSet:ws];
      returnResult = [returnResult stringByTrimmingCharactersInSet:ns];
      
      if ([aScanner scanUpToString:returnResult intoString:NULL]) {
        
        NSRange resultRange = NSMakeRange([aScanner scanLocation], [returnResult length]);
        if (resultRange.location != NSNotFound) {
          
          NSRange subrange    = [returnResult rangeOfRegex:[searchTerms objectAtIndex:0]];
          if (subrange.location != NSNotFound) {
            resultRange.location += subrange.location;
            resultRange.length = [searchTerm length];
            
            
            // scan back to start of word
            NSInteger idx = subrange.location;
            while (idx > 0) {
              if ([ws characterIsMember:[returnResult characterAtIndex:idx]]) {
                break;
              }
              idx--;
            }
            NSInteger len = (NSInteger)MIN(subrange.location-idx+30, [returnResult length]-idx);
            len = MAX(len, [searchTerm length]);
            NSString *matchingString = [returnResult substringWithRange:NSMakeRange(idx, len)];
            if (idx>0) {
              matchingString = [@"..." stringByAppendingString:matchingString];
              idx-=3;
            }
            
            MHLineNumber *ln = [MHLineNumber lineNumberContainingIndex:resultRange.location inArray:lineNumbers];
            NSInteger lineNumber = ln.number;
            TPDocumentMatch *match = [TPDocumentMatch documentMatchInLine:lineNumber withRange:resultRange subrange:NSMakeRange(subrange.location-idx, [searchTerm length]) matchingString:matchingString inDocument:nil];
            if (![self.results containsObject:match]) {
              [self.results addObject:match];
            }            
          } // end subrange found
        } // end result range founds
      } // end scanner
    } // end loop over results
  } // end if [results count] > 0  
  
  
  // highlight first result
  if ([self.results count]>0) {
    TPDocumentMatch *first = [self.results objectAtIndex:0];
    
    // expand all folded code
    [self.texEditorViewController.textView expandAll:self];
    
    // Now highlight the search term in that 
    [self.texEditorViewController.textView selectRange:first.range scrollToVisible:YES animate:YES];
    
    // Make text view first responder
    [self.mainWindow makeFirstResponder:self.texEditorViewController.textView]; 
    
  }
    
}

- (IBAction)findSource:(id)sender
{
  [self.results removeAllObjects];
  
  
  PDFSelection *selection = [self.pdfViewerController.pdfview currentSelection];
  NSString *searchTerm = [selection string];

  [self findSourceOfText:searchTerm];  
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

#pragma mark -
#pragma mark Document stuff

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{    
  if ([self inVersionsMode]) {
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
  
  // view
  if ([theItem tag] == 45) {
    if (![self compiledDocumentPath]) {
      return NO;
    }
  }
  
  // trash
  if ([theItem tag] == 50) {
    if ([self.engineManager isCompiling]) {
      return NO;
    }
  }
  
  // add to project
  if ([theItem tag] == 100) {
    if ([self fileURL] == nil) {
      return NO;
    }
  }
  
  return YES;
}



- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (BOOL) canAddNewFolder
{
	return NO;
}

- (BOOL) canAddNewTeXFile
{
	return NO;
}

- (BOOL) canRemove
{
	return NO;
}

- (void) showDocument
{
  //  NSLog(@"Show doc");
  NSView *view = [self.pdfViewerController.pdfview documentView];    
  PDFPage *page = [self.pdfViewerController.pdfview currentPage];
  NSInteger index = [self.pdfViewerController.pdfview.document indexForPage:page];
  NSRect r = [view visibleRect];
  //  NSLog(@"Visible rect %@", NSStringFromRect(r));
  BOOL hasDoc = [self.pdfViewerController hasDocument];
  [self.pdfViewerController redisplayDocument];
  if (hasDoc) {
    PDFDisplayMode mode = [self.pdfViewerController.pdfview displayMode];
    if (mode == kPDFDisplaySinglePageContinuous ||
        mode == kPDFDisplayTwoUpContinuous) {
      [view scrollRectToVisible:r];
    } else {
      if (page) {
        [self.pdfViewerController.pdfview goToPage:[self.pdfViewerController.pdfview.document pageAtIndex:index]];
      }
    }
  }
}

- (IBAction) saveDocument:(id)sender
{
//  NSLog(@"Save doc...");
  
  if ([self fileURL] == nil) {
    // make sure we store the text editor string to our document string
    [self syncDocumentDataFromEditor];
  }
        
//	NSRange selRange = [self.texEditorViewController.textView selectedRange];
//	NSRect selRect = [self.texEditorViewController.textView visibleRect];
	NSResponder *r = [[self windowForSheet] firstResponder];
  [self saveDocumentWithDelegate:self didSaveSelector:@selector(documentSave:didSave:contextInfo:) contextInfo:NULL];
//	[self.texEditorViewController.textView setSelectedRange:selRange];
//	[self.texEditorViewController.textView scrollRectToVisible:selRect];
	[[self windowForSheet] makeFirstResponder:r];
  [self updateFileStatus];
  // capture UI state
  [self captureUIsettings];
}

- (void)documentSave:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
//  if (didSave) {
//    [self.engine setFilepath:[[self fileURL] path]];
//  } else {
//  }
  [self updateFileStatus];  
  [self.texEditorViewController.textView breakUndoCoalescing];
}

- (BOOL) inVersionsMode
{
  if ([NSApp isLion]) {
    return _inVersionsBrowser || [self isInViewingMode];
  }
  return NO;
}

- (void) updateFileStatus
{
  if ([self fileURL] && ![self inVersionsMode]) {
    [self.statusViewController setFilenameText:[[self fileURL] path]];
    [self.statusViewController enable:YES];
  } else {
    [self.statusViewController enable:NO];
  }
  self.fileLoadDate = [NSDate dateWithTimeIntervalSinceNow:2];
}

- (void) setFileURL:(NSURL *)absoluteURL
{  
  [super setFileURL:absoluteURL];
  [self updateFileStatus];
}

- (void)documentSaveAndBuild:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
  if (didSave) {
//    [self.engine setFilepath:[[self fileURL] path]];
    [self build];
  } else {
  }
  [self updateFileStatus];  
}

- (NSString *)windowNibName {
	// Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
	return @"ExternalTeXDoc";
}

+ (BOOL)autosavesInPlace
{
  return YES;
}

- (IBAction)reopenUsingEncoding:(id)sender
{
//  NSLog(@"Reopen using encoding %@", [sender title]);
  
  NSString *path = [[self fileURL] path];
  if (path) {
    // clear the xattr
    [UKXattrMetadataStore setString:@""
                             forKey:@"com.bobsoft.TeXnicleTextEncoding"
                             atPath:path
                       traverseLink:YES];
    
    MHFileReader *fr = [[[MHFileReader alloc] initWithEncodingNamed:[sender title]] autorelease];
    NSString *str = [fr readStringFromFileAtURL:[self fileURL]];
    if (str) {
      self.fileLoadDate = [NSDate date];
      NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[fr encodingUsed]]
                                                          forKey:NSCharacterEncodingDocumentAttribute];
      NSMutableAttributedString *attStr = [[[NSMutableAttributedString alloc] initWithString:str attributes:options] autorelease];
      [self setDocumentData:attStr];
      [self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
      
      // read settings
      NSData *data = [UKXattrMetadataStore dataForKey:@"com.bobsoft.TeXnicleSettings" atPath:[[self fileURL] path] traverseLink:NO];
      if (data) {
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (dict) {
          self.settings = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
      }
      
    }
  }
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
//  NSLog(@"Write to URL %@", absoluteURL);
  
	NSAttributedString *attStr = [self.texEditorViewController.textView attributedString];
//  NSLog(@"Text editor string %@", attStr);
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
	[string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
//  NSLog(@"Set document data %@", string);
  [self setDocumentData:string];
	NSString *str = [string string];
  
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  if (_encoding == -1) {
    _encoding = [fr defaultEncoding];
  }
  BOOL res = [fr writeString:str toURL:absoluteURL withEncoding:_encoding];
	[string release];
  
  if (res) {
    // now write project settings as xattr  
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.settings];
    [UKXattrMetadataStore setData:data forKey:@"com.bobsoft.TeXnicleSettings" atPath:[absoluteURL path] traverseLink:NO];
  }
  
	return res;
}


- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	return [self loadFileAtURL:absoluteURL];
}

- (BOOL) loadFileAtURL:(NSURL*)absoluteURL
{
//  NSLog(@"Loading file at URL %@", absoluteURL);
  
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  NSString *str = [fr readStringFromFileAtURL:absoluteURL];
	if (str) {
    _encoding = [fr encodingUsed];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:_encoding]
                                                        forKey:NSCharacterEncodingDocumentAttribute];
    NSMutableAttributedString *attStr = [[[NSMutableAttributedString alloc] initWithString:str attributes:options] autorelease];
		[self setDocumentData:attStr];
    [[self.texEditorViewController.textView textStorage] setAttributedString:attStr];
    [self.texEditorViewController.textView applyFontAndColor:YES];
    [self.texEditorViewController.textView colorWholeDocument];
    
    // read settings
    NSData *data = [UKXattrMetadataStore dataForKey:@"com.bobsoft.TeXnicleSettings" atPath:[absoluteURL path] traverseLink:NO];
    if (data) {
      NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
      if (dict) {
        self.settings = [NSMutableDictionary dictionaryWithDictionary:dict];
      }
    }
    
    self.fileLoadDate = [NSDate date];
    [self setFileModificationDate:self.fileLoadDate];
    [self updateChangeCount:NSChangeCleared];
    [self syncFileModificationDate];
		return YES;
	}
  
	return NO;  
}

- (void)syncFileModificationDate 
{
  NSFileManager *fm = [NSFileManager defaultManager];
  NSDictionary *fileAttributes = [fm attributesOfItemAtPath:[[self fileURL] path]
                                                      error:NULL];
  NSDate* newDate = [fileAttributes objectForKey:NSFileModificationDate];
  [self setFileModificationDate:newDate];
}

#pragma mark -
#pragma mark control

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

- (IBAction)pasteAsImage:(id)sender
{  
  
  // make a filename for the image checking the selected path in the project
  NSString *root = [[[self fileURL] path] stringByDeletingLastPathComponent];
  
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
        // insert text
        NSMutableString *insert = [NSMutableString stringWithFormat:@"\\begin{figure}[htbp]\n"];
        [insert appendFormat:@"\\centering\n"];
        [insert appendFormat:@"\\includegraphics[width=0.8\\textwidth]{%@}\n", [url path]];
        [insert appendFormat:@"\\caption{My Nice Pasted Figure.}\n"];
        [insert appendFormat:@"\\label{fig:%@}\n", [[url lastPathComponent] stringByDeletingPathExtension]];
        [insert appendFormat:@"\\end{figure}\n"];
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


- (IBAction)reloadCurrentFileFromDisk:(id)sender
{
  if ([self fileURL] != nil) {
    NSRange selected = [self.texEditorViewController.textView selectedRange];
    [self.texEditorViewController.textView setSelectedRange:NSMakeRange(0, 0)];  
    [self revertDocumentToSaved:self];
    [self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
    if (NSMaxRange(selected) < [[self.documentData string] length]) {
      [self.texEditorViewController.textView setSelectedRange:selected];
    }  
  }
}

- (IBAction) addToProject:(id)sender
{
  if ([self fileURL] == nil) {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Can't Add to Project"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Please save the file before trying to add it to a project."];
    [alert runModal];
    return;
  }
  
  
	// Fill the popup button
	NSMutableArray *projects = [NSMutableArray array];
	NSArray *docs = [[NSDocumentController sharedDocumentController] documents];
	for (id doc in docs) {
//		NSLog(@"Got doc: %@", doc);
		if ([doc isKindOfClass:[TeXProjectDocument class]]) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			ProjectEntity *project = [doc project];
			[dict setObject:[project valueForKey:@"name"] forKey:@"Name"];
			[dict setObject:doc forKey:@"Project"];
			[projects addObject:dict];
		}
	}
	
	if ([projects count] > 0) {
		[projectsController setContent:projects];
		
		// launch window
		[NSApp beginSheet:addToProjectSheet
			 modalForWindow:[self windowForSheet]
				modalDelegate:self
			 didEndSelector:NULL
					contextInfo:NULL];	
	} else {
		
		// launch window
		[NSApp beginSheet:addToEmptyProjectSheet
			 modalForWindow:[self windowForSheet]
				modalDelegate:self
			 didEndSelector:NULL
					contextInfo:NULL];	
	}
	
}

- (IBAction) endAddToProjectSheet:(id)sender
{
  NSInteger tag = [sender tag];
	// user clicked cancel
	if (tag == 0) {
		[NSApp endSheet:addToProjectSheet];
		[addToProjectSheet orderOut:sender];
		return;
	}
	
	// user clicked new project button
	if (tag == 2) {
		[self addToNewEmptyProject];
		return;
	}
	
	
	NSArray *selected = [projectsController selectedObjects];
//	NSLog(@"Selected: %@", selected);
	if ([selected count] == 1) {
		TeXProjectDocument *doc = [[selected objectAtIndex:0] valueForKey:@"Project"];
//		NSLog(@"Adding to %@", [doc project]);
		BOOL copy = NO;
		if ([copyToProjectCheckButton state]==NSOnState) {
			copy = YES;
		}
		[NSApp endSheet:addToProjectSheet];
		[addToProjectSheet orderOut:sender];
		
//		NSLog(@"Copy? %d", copy);
		
		// Now make the document
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attributes = [fm attributesOfItemAtPath:[[self fileURL] path] error:&error];
    if (attributes == nil) {
      [NSApp presentError:error];
      return;
    }
    
    if (![[attributes fileType] isEqualToString:NSFileTypeRegular]) {
      
			NSAlert *alert = [NSAlert alertWithMessageText:@"Adding to project failed."
																			 defaultButton:@"OK"
																		 alternateButton:nil
																				 otherButton:nil
													 informativeTextWithFormat:@"The current TeX file is not a standard file '%@'.", [self fileURL]];
			
      [alert runModal];
      return;
    }
    
		if ([doc addFileAtURL:[self fileURL] copy:copy]) {
			[self close];
		} else {			
			
			NSAlert *alert = [NSAlert alertWithMessageText:@"Adding to project failed."
																			 defaultButton:@"OK"
																		 alternateButton:nil
																				 otherButton:nil
													 informativeTextWithFormat:@"It was not possible to add this file to the project '%@'.", [[doc project] valueForKey:@"name"]];
			
			[alert beginSheetModalForWindow:[self windowForSheet]
												modalDelegate:self
											 didEndSelector:NULL
													contextInfo:NULL];

		}
	} else {
		[NSApp endSheet:addToProjectSheet];
		[addToProjectSheet orderOut:sender];
	}			
}

- (IBAction) endAddToNewProjectSheet:(id)sender
{
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:addToEmptyProjectSheet];
		[addToEmptyProjectSheet orderOut:sender];
		return;
	}
	
	[self addToNewEmptyProject];
	
	
}

- (void) addToNewEmptyProject
{  
  TeXProjectDocument *doc = [TeXProjectDocument createNewTeXnicleProject];
  
	if (doc) {
		
		BOOL copy = NO;
		if ([copyToNewProjectCheckButton state]==NSOnState) {
			copy = YES;
		}
		BOOL makeMain = NO;
		if ([makeMainFileCheckButton state] == NSOnState) {
			makeMain = YES;
		}
		
		[NSApp endSheet:addToEmptyProjectSheet];
		[addToEmptyProjectSheet orderOut:self];
		
    
    // TODO: in order to invoke the project builder here, we need to factor out the code in the project builder which 
    // generates a list of project files from the code that adds the files. So we want to do something like:
    //   NSArray *filelist = [pb listOfIncludeFilesForFile:somefile]; 
    // This list should include somefile.
    // Then add and copy them, if necessary:
    //   for each file
    //      id newDoc = [doc addFileAtURL:file copy:copy];
    //   
    

    
		id newDoc = [doc addFileAtURL:[self fileURL] copy:copy];
		if (newDoc) {
			if (makeMain) {
				[[doc project] setValue:newDoc forKey:@"mainFile"];	
			}
      
			[self close];
		}
		
	} else {
		[NSApp endSheet:addToEmptyProjectSheet];
		[addToEmptyProjectSheet orderOut:self];
	}
}

- (void) insertTextToCurrentDocument:(NSString*)string
{
	[self.texEditorViewController.textView insertText:string];
	[self.texEditorViewController.textView performSelector:@selector(colorVisibleText) 
                                              withObject:nil 
                                              afterDelay:0.1];
}


#pragma mark -
#pragma mark Interface

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)item
{
  if ([self inVersionsMode]) {
    return NO;
  }
  
	// Add to project button
	if (item == addToProjectButton) {
		if ([self isDocumentEdited] || [self fileURL] == nil) {
			return NO;
		}
	}
	
	return [super validateUserInterfaceItem:item];
}


#pragma mark -
#pragma mark Text Editor delegate

- (NSString*) nameOfFileBeingEdited
{
  return [[self fileURL] lastPathComponent];
}

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)aChecker
{
  if ([[[self fileURL] pathExtension] isEqualToString:@"tex"] == NO) {
    return NO;
  }
  
  if ([[self mainWindow] isKeyWindow] == NO) {
    return NO;
  }
  return YES;
}

- (id)currentUndoManager
{
  return [self undoManager];
}

-(void)textView:(TeXTextView*)aTextView didCommandClickAtLine:(NSInteger)lineNumber column:(NSInteger)column
{
  MHSynctexController *sync = [[MHSynctexController alloc] initWithEditor:aTextView pdfViews:[NSArray arrayWithObjects:self.pdfViewerController.pdfview, self.pdfViewer.pdfViewerController.pdfview, nil]];
  [sync displaySelectionInPDFFile:[self compiledDocumentPath] sourceFile:[[self fileURL] path] lineNumber:lineNumber column:column];
  [sync release];
}


-(NSString*)codeForCommand:(NSString*)command
{
  NSString *code = [self.library codeForCommand:command];
  return code;
}

- (NSArray*)commandsBeginningWithPrefix:(NSString *)prefix
{
  return [self.library commandsBeginningWith:prefix];
}

-(NSArray*)listOfTeXFilesPrependedWith:(NSString*)prefix;
{
  return [NSArray array];
}

-(NSString*)fileExtension
{
  return [[self fileURL] pathExtension];
}


-(id)project
{
  return nil;
}

- (NSArray*) listOfCitations
{
	NSString *str = [self.texEditorViewController.textView string];
  
  NSMutableArray *citations = [NSMutableArray array];
  
  [citations addObjectsFromArray:[str citations]];
  [citations addObjectsFromArray:[str citationsFromBibliographyIncludedFromPath:[[self fileURL] path]]];
  
	return citations;	
}

-(NSArray*)listOfCommands
{
  NSMutableArray *commands = [NSMutableArray array];
  // consolidated main file
  NSString *allText = [self.texEditorViewController.textView string];
  NSArray *newCommands = [allText componentsMatchedByRegex:@"\\\\newcommand\\{\\\\[a-zA-Z]*\\}"];
  for (NSString *newCommand in newCommands) {
    [commands addObject:[newCommand argument]];
  }
  
  return commands; //[NSArray array]; 
}
- (NSArray*) listOfReferences
{
	NSString *str = [self.texEditorViewController.textView string];
  
  NSArray *parsedLabels = [str referenceLabels];
  NSMutableArray *newLabels = [NSMutableArray array];
  for (NSString *str in parsedLabels) {
    TPLabel *l = [[TPLabel alloc] initWithFile:self text:str];
    [newLabels addObject:l];
    [l release];
  }

	return [NSArray arrayWithArray:newLabels];
}

- (BOOL) shouldSyntaxHighlightDocument
{
  if ([self fileURL] == nil) {
    return YES;
  }
  
	NSString *ext = [[[self fileURL] path] pathExtension];
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  for (NSString *lext in [sfm supportedExtensionsForHighlighting]) {
    if ([ext isEqual:lext]) {
      return YES;
    }
  }
  return NO;
}

-(NSArray*)bookmarksForCurrentFileInLineRange:(NSRange)aRange
{
  return [NSArray array];
}


#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender
{
  [self.engineManager trashAuxFiles];
  [self showDocument];
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
//		[self saveDocument:self];
    [self saveDocumentWithDelegate:self didSaveSelector:@selector(documentSaveAndBuild:didSave:contextInfo:) contextInfo:NULL];
	} else {
    [self build];	
  }
  
}
     
- (void) build
{
//  NSLog(@"Building...");
  [self.miniConsole setAnimating:YES];
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

- (void) handleTextChanged:(NSNotification*)aNote
{
  
  // update labels view
  [self.labelsViewController performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
  
  // update last edit time
  self.lastEdit = [NSDate date];
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
  lastBuildDate = [NSDate date];
}

- (void) updateChangeCount:(NSDocumentChangeType)change
{
  [super updateChangeCount:change];
}

- (BOOL)hasChanges
{
  return ![[self.documentData string] isEqualToString:[self.texEditorViewController.textView string]];
}

- (void)doLiveBuild
{
  if (!_building && _liveUpdate && [self hasChanges] && [self.pdfViewerController hasDocument]) {
    [self saveDocument:self];
    [self build];
  }  
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
  
  if (self.pdfViewer == nil) {
    self.pdfViewer = [[[PDFViewer alloc] initWithDelegate:self] autorelease];
  }
  [self.pdfViewer showWindow:self];
  
}


#pragma mark -
#pragma mark File Monitor Delegate

- (NSString*)fileMonitor:(TPFileMonitor*)aMonitor pathOnDiskForFile:(id)file
{
  return [[self fileURL] path];
}

- (NSArray*)fileMonitorFileList:(TPFileMonitor *)aMonitor
{
  return [NSArray arrayWithObject:self];
}

//- (void) fileMonitor:(TPFileMonitor *)aMonitor fileWasAccessedOnDisk:(id)file accessDate:(NSDate *)access
//{
////  NSLog(@"File was accessed on disk...");
//  if ([self fileURL]) {
//    if (![self isDocumentEdited]) {
//      [self performSelector:@selector(reloadCurrentFileFromDisk:) withObject:self afterDelay:0];
//    }
//  }
//}


-(void) fileMonitor:(TPFileMonitor *)aMonitor fileChangedOnDisk:(id)file modifiedDate:(NSDate*)modified
{
//  NSLog(@"File was changed on disk...%@", [self fileURL]);
  if ([self fileURL]) {
    if ([self isDocumentEdited]) {
      NSString *filename = [[[self fileURL] path] lastPathComponent];
      NSAlert *alert = [NSAlert alertWithMessageText:@"File Changed On Disk" 
                                       defaultButton:@"Reload"
                                     alternateButton:@"Continue"
                                         otherButton:nil 
                           informativeTextWithFormat:@"The file %@ changed on disk. Do you want to reload from disk? This may result in loss of changes.", filename];
      NSInteger result = [alert runModal];
      if (result == NSAlertDefaultReturn) {
        [self loadFileAtURL:[self fileURL]];
//        [self revertDocumentToSaved:self];
//        [self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
      } else {
        self.fileLoadDate = modified;
      }
    } else {
      [self loadFileAtURL:[self fileURL]];
//      [self revertDocumentToSaved:self];
//      [self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
    }
  }
}


#pragma mark -
#pragma mark Engine Settings Delegate

- (NSString*)language
{
  NSString *language = [self.settings valueForKey:@"language"];
  if (language == nil || [language length] == 0) {
    language = [[NSSpellChecker sharedSpellChecker] language];
    [self.settings setValue:language forKey:@"language"];
  }
  
  return language;
}

- (void) didSelectLanguage:(NSString *)aName
{
  [self.settings setValue:aName forKey:@"language"];
  if ([aName isEqualToString:TPSpellingAutomaticByLanguage]) {
    [[NSSpellChecker sharedSpellChecker] setAutomaticallyIdentifiesLanguages:YES];
  } else {
    [[NSSpellChecker sharedSpellChecker] setLanguage:aName];
    [[NSSpellChecker sharedSpellChecker] setAutomaticallyIdentifiesLanguages:NO];
  }
  [self.texEditorViewController.textView checkSpelling:self];
}

-(void)didSelectDoBibtex:(BOOL)state
{
  [self.settings setValue:[NSNumber numberWithBool:state] forKey:@"doBibtex"];
  [self updateChangeCount:NSChangeUndone];
}

-(void)didSelectDoPS2PDF:(BOOL)state
{
  [self.settings setValue:[NSNumber numberWithBool:state] forKey:@"doPS2PDF"];
  [self updateChangeCount:NSChangeUndone];
}

-(void)didSelectOpenConsole:(BOOL)state
{
  [self.settings setValue:[NSNumber numberWithBool:state] forKey:@"openConsole"];
  [self updateChangeCount:NSChangeUndone];
}

-(void)didChangeNCompile:(NSInteger)number
{
  [self.settings setValue:[NSNumber numberWithInteger:number] forKey:@"nCompile"];
}

-(void)didSelectEngineName:(NSString*)aName
{
  [self.settings setValue:aName forKey:@"engineName"];
}

-(NSString*)engineName
{
  return [self.settings valueForKey:@"engineName"];
}

-(NSNumber*)doBibtex
{
  return [self.settings valueForKey:@"doBibtex"];
}

-(NSNumber*)doPS2PDF
{
  return [self.settings valueForKey:@"doPS2PDF"];
}

-(NSNumber*)openConsole
{
  return [self.settings valueForKey:@"openConsole"];
}

-(NSNumber*)nCompile
{
  if (_liveUpdate) {
    return [NSNumber numberWithInt:1];
  }
  
  return [self.settings valueForKey:@"nCompile"];  
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

-(NSArray*)registeredEngineNames
{
  return [self.engineManager registeredEngineNames];
}

#pragma mark -
#pragma mark Engine Manager Delegate


-(NSString*)documentToCompile
{
  return [[[self fileURL] path] stringByDeletingPathExtension];  
}

-(NSString*)workingDirectory
{
  return [[[self fileURL] path] stringByDeletingLastPathComponent];
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

#pragma mark -
#pragma mark PDFViewerController delegate


- (void)pdfview:(MHPDFView*)pdfView didCommandClickOnPage:(NSInteger)pageIndex inRect:(NSRect)aRect atPoint:(NSPoint)aPoint
{
//  NSLog(@"Clicked on PDF...");
  MHSynctexController *sync = [[[MHSynctexController alloc] initWithEditor:self.texEditorViewController.textView pdfViews:[NSArray arrayWithObjects:self.pdfViewerController.pdfview, self.pdfViewer.pdfViewerController.pdfview, nil]] autorelease];
  NSInteger lineNumber = NSNotFound;
  NSString *sourcefile = [sync sourceFileForPDFFile:[self compiledDocumentPath] lineNumber:&lineNumber pageIndex:pageIndex pageBounds:aRect point:aPoint];
  sourcefile = [sourcefile stringByStandardizingPath]; 
//  NSLog(@"  source file: %@", sourcefile);
//  NSLog(@"  my path: %@", [self fileURL]);  
//  NSLog(@"  my last path component: %@", [[self fileURL] lastPathComponent]);
  if ([sourcefile isEqualToString:[[self fileURL] lastPathComponent]]) {
//    NSLog(@"    source file is me");
    [self.texEditorViewController.textView goToLine:lineNumber];
  } else {
//    NSLog(@"    opening source fil");
    NSURL *path = nil;
    // open the file in a new document
    if ([sourcefile isAbsolutePath]) {
//      NSLog(@"     source file is absolute path");
      path = [NSURL fileURLWithPath:sourcefile];
    } else {
      path = [[[self fileURL] URLByDeletingLastPathComponent] URLByAppendingPathComponent:sourcefile];
    }
//    NSLog(@"        opening %@", path);
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:path display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
      // do stuff
      ExternalTeXDoc *doc = (ExternalTeXDoc*)document;
      [doc.texEditorViewController.textView performSelector:@selector(goToLineWithNumber:) withObject:[NSNumber numberWithInteger:lineNumber] afterDelay:0];
    }];
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
#pragma mark Split view delegate

- (IBAction) showIntegratedPDFViewer:(id)sender
{  
  
  NSRect rightfr = [rightView frame];
  if ([rightView isHidden] == NO) {
    return;
  }
  
  CGFloat size = kSplitViewRightMinSize;
  
  rightfr.size.width = size;
  NSRect midfr = [centerView frame];
  midfr.size.width = midfr.size.width - size;
  midfr.origin.x = size;
  
  [centerView setFrame:midfr];
  [rightView.animator setFrame:rightfr];
  [rightView setHidden:NO];
}

- (IBAction) showIntegratedConsole:(id)sender
{
  NSView *topView = [[editorSplitView subviews] objectAtIndex:0];
  NSView *bottomView = [[editorSplitView subviews] objectAtIndex:1];
  
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
  if (sender == self.splitView) {
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

- (BOOL)splitView:(NSSplitView *)aSplitView shouldAdjustSizeOfSubview:(NSView *)subview
{
  if (aSplitView == self.splitView) { 
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


- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)subview
{
  if (aSplitView == self.splitView) {
    if (subview == self.centerView) {
      return NO;
    }
  }
  
  return YES;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
  NSRect b = [aSplitView bounds];
  
  if (aSplitView == self.splitView) {
    if (dividerIndex == 0) {
      NSRect rb = [self.rightView bounds];
      CGFloat max =  b.size.width - rb.size.width - kSplitViewCenterMinSize;
      return max;
    }
    
    if (dividerIndex == 1) {
      NSRect b = [aSplitView bounds];
      return b.size.width-kSplitViewRightMinSize;
    }
  }
  
  if (aSplitView == editorSplitView) {    
    return b.size.height - 26.0 - [splitView dividerThickness];    
  }
  
  return proposedMax;
}


- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
  if (aSplitView == self.splitView) {
    if (dividerIndex == 0) {
      return kSplitViewLeftMinSize;
    }
    
    if (dividerIndex == 1) {
      NSRect lb = [self.leftView bounds];
      
      if ([aSplitView isSubviewCollapsed:self.leftView]) {
        return kSplitViewCenterMinSize;
      }
      return lb.size.width + kSplitViewCenterMinSize;
    }
  }
  
  if (aSplitView == editorSplitView) {    
    return 42.0;    
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
  
  if (![self.splitView isSubviewCollapsed:self.leftView]) {
    w += leftSize.width;
    w += [self.splitView dividerThickness];
  }
  if (![self.splitView isSubviewCollapsed:self.centerView]) {
    w += centerSize.width;
    w += [self.splitView dividerThickness];
  }
  
  if (![self.splitView isSubviewCollapsed:self.rightView]) {
    if ((frameSize.width - w) < kSplitViewRightMinSize) {
      frameSize.width = w + kSplitViewRightMinSize;
    }  
  }
  
  return frameSize; 
}

#pragma mark -
#pragma mark Palette delegate

- (BOOL)paletteCanInsertText:(PaletteController*)aPalette
{
  return YES;
}

- (void)palette:(PaletteController*)aPalette insertText:(NSString*)aString
{
	[self.texEditorViewController.textView insertText:aString];
	[self.texEditorViewController.textView colorVisibleText];
}


#pragma mark -
#pragma mark Library delegate

- (void) libraryController:(TPLibraryController*)library insertText:(NSString*)text
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
#pragma mark ProjectOutlineController delegate


- (id) mainFile
{
  return [self fileURL];
}

- (NSString*) textForFile:(id)aFile
{
  if ([[self fileURL] isEqual:aFile]) {
    return [self.texEditorViewController.textView string];
  }
  
  return @"";
}

- (void) didSetMaxOutlineDepthTo:(NSInteger)depth
{
  self.maxOutlineViewDepth = [NSNumber numberWithInteger:depth];
}

- (NSNumber*) maxOutlineDepth
{
  return maxOutlineViewDepth;
}



- (BOOL) shouldGenerateOutline
{
  // if outline tab is selected....
  if ([self.tabbarController indexOfSelectedTab] == 3) {
    return YES;
  }
  return NO;
}

- (NSAttributedString*)documentString
{
  return [self.texEditorViewController.textView attributedString];
}

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile
{	    
  
  if (aFile == nil || [aFile isEqualTo:[self fileURL]]) {
    
    // Now highlight the search term in that 
    [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
    
    // Make text view first responder
    [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
    
    // and color the newly viewed text
    [self.texEditorViewController.textView performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
    
  } else {
    // TODO: this will break on 10.6.8 !!!!
    
    [[NSDocumentController sharedDocumentController]
      openDocumentWithContentsOfURL:aFile
      display:YES
      completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
        if (document) {
          ExternalTeXDoc *doc = (ExternalTeXDoc*)document;
          
          NSString *rangeString = NSStringFromRange(aRange);
          NSString *forwardResult = result;
          id forwardFile = aFile;          
          
          NSInvocation			*invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(highlightSearchResult:withRange:inFile:)]];
          [invocation setSelector:@selector(highlightSearchResult:withRange:inFile:)];
          [invocation setTarget:doc];
          [invocation setArgument:&forwardResult atIndex:2];    
          [invocation setArgument:&rangeString atIndex:3];    
          [invocation setArgument:&forwardFile atIndex:4];    
          [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0];
          
        } else {
          if (error) {
            [NSApp presentError:error];
          }
        }
        
      }];
    
  }
  
}

- (void) wrappedHighlightSearchResult:(NSString*)result withRange:(NSString*)aRangeString inFile:(id)aFile
{
  [self highlightSearchResult:result withRange:NSRangeFromString(aRangeString) inFile:aFile];
}


#pragma mark -
#pragma mark Template sheet

- (void) showTemplatesSheet
{
  if (self.templateEditor == nil) {
	 self.templateEditor = [[[TPTemplateEditor alloc] initWithDelegate:self activeFilename:NO] autorelease];
  }
  
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
    NSString *code = [aTemplate valueForKey:@"Code"];
    if (code != nil && [code length]>0) {
      [self.texEditorViewController setString:code];
      [self syncDocumentDataFromEditor];
    }
    [self.texEditorViewController.textView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0];
  }
  [NSApp endSheet:self.templateEditor.window];
  [self.templateEditor.window orderOut:self];  
}


- (void) syncDocumentDataFromEditor
{
  NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[MHFileReader defaultEncoding]]
                                                           forKey:NSCharacterEncodingDocumentAttribute];
  NSMutableAttributedString *attStr = [[[NSMutableAttributedString alloc] initWithString:[self.texEditorViewController.textView string] attributes:options] autorelease];
  [self setDocumentData:attStr];
}

#pragma mark -
#pragma mark Spell Checker View Delegate

- (BOOL) performSimpleSpellCheck
{
  return YES;
}

- (NSString*)fileToCheck
{
  return [[self fileURL] path];
}

- (NSString*) stringToCheck
{
  return [self.texEditorViewController.textView string];
}

- (BOOL)shouldPerformSpellCheck
{
  if ([self.tabbarController indexOfSelectedTab] == 5) {
    // if spelling tab is selected....
    if ([self.infoTabbarController indexOfSelectedTab] == 2) {
      return YES;
    }
  }
  return NO;
}

- (NSDate*)lastEditDate
{
  return lastEdit;
}

- (void)replaceMisspelledWord:(NSString*)word atRange:(NSRange)aRange withCorrection:(NSString*)correction inFile:(FileEntity*)file
{  
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // replace the word
  [self.texEditorViewController.textView replaceRange:aRange withText:correction scrollToVisible:YES animate:YES];
  
}

- (void) highlightMisspelledWord:(NSString *)word atRange:(NSRange)aRange inFile:(FileEntity*)file
{
  // expand all folded code
  [self.texEditorViewController.textView expandAll:self];
  
  // highlight the word
  [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
  
}


- (void) dictionaryDidLearnNewWord
{
}

- (void) updateMetadata 
{
  [self.warningsViewController performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
  [self.labelsViewController performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
  [self.citationsViewController performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
  [self.commandsViewController performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark Warnings view delegate

- (NSArray*) warningsViewlistOfFiles:(TPWarningsViewController *)warningsView
{
  return [NSArray arrayWithObject:[self fileURL]];
}

- (NSArray*) warningsView:(TPWarningsViewController *)warningsView warningsForFile:(id)file
{
  return self.texEditorViewController.errors;
}

- (void) warningsView:(TPWarningsViewController*)warningsView didSelectError:(TPSyntaxError*)anError
{
  [self.texEditorViewController.textView jumpToLine:[anError.line integerValue] select:YES];    
  [self.mainWindow makeFirstResponder:self.texEditorViewController.textView];
}

#pragma mark -
#pragma mark Labels view delegate

- (NSArray*) labelsViewlistOfFiles:(TPLabelsViewController*)aLabelsView
{
  return [NSArray arrayWithObject:[self fileURL]];
}

- (NSArray*) labelsView:(TPLabelsViewController*)aLabelsView labelsForFile:(id)file
{
  return [self listOfReferences];
}

- (void) labelsView:(TPLabelsViewController*)aLabelsView didSelectLabel:(TPLabel*)aLabel
{
  // now select the text
  NSString *str = [NSString stringWithFormat:@"\\label{%@}", aLabel.text];
  NSRange r = [[self.texEditorViewController.textView string] rangeOfString:str];
  [self.texEditorViewController.textView selectRange:r scrollToVisible:YES animate:YES];  
}

#pragma mark -
#pragma mark Citations view delegate

- (NSArray*) citationsViewlistOfFiles:(TPCitationsViewController*)aView
{
  return [NSArray arrayWithObject:[self fileURL]];
}

- (NSArray*) citationsView:(TPCitationsViewController*)aView citationsForFile:(id)file
{
	NSString *str = [self.texEditorViewController.textView string];
  return [str citations];
}

- (void) citationsView:(TPCitationsViewController*)aView didSelectCitation:(id)aCitation
{
  BibliographyEntry *entry = [aCitation valueForKey:@"entry"];
    
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
}

#pragma mark -
#pragma mark Commands view delegate

- (NSArray*) commandsViewlistOfFiles:(TPNewCommandsViewController*)aView
{  
  return [NSArray arrayWithObject:[self fileURL]];
}

- (NSArray*) commandsView:(TPNewCommandsViewController*)aView newCommandsForFile:(id)file
{
  NSString *allText = [self.texEditorViewController.textView string];
  NSArray *parsedCommands = [allText componentsMatchedByRegex:@"\\\\newcommand\\{\\\\[a-zA-Z]*\\}"];
  NSMutableArray *commandObjects = [NSMutableArray array];
  for (NSString *str in parsedCommands) {
    TPNewCommand *c = [[TPNewCommand alloc] initWithSource:str];
    [commandObjects addObject:c];
    [c release];
  }

  return [NSArray arrayWithArray:commandObjects];
}

- (void) commandsView:(TPNewCommandsViewController*)aView didSelectNewCommand:(id)aCommand
{
  // now select the text
  NSRange r = [[self.texEditorViewController.textView string] rangeOfString:[aCommand valueForKey:@"source"]];
  [self.texEditorViewController.textView selectRange:r scrollToVisible:YES animate:YES];  
}


@end
