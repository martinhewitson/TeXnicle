//
//  ExternalTeXDoc.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#define kSplitViewLeftMinSize 230.0
#define kSplitViewCenterMinSize 400.0
#define kSplitViewRightMinSize 400.0

NSString * const TPExternalDocControlsTabIndexKey = @"TPExternalDocControlsTabIndexKey"; 
NSString * const TPExternalDocControlsWidthKey = @"TPExternalDocControlsWidthKey"; 
NSString * const TPExternalDocEditorWidthKey = @"TPExternalDocEditorWidthKey"; 
NSString * const TPExternalDocPDFVisibleRectKey = @"TPExternalDocPDFVisibleRectKey"; 

@implementation ExternalTeXDoc

@synthesize documentData;
@synthesize texEditorContainer;
@synthesize texEditorViewController;
@synthesize fileLoadDate;
@synthesize fileMonitor;
@synthesize engineManager;
@synthesize settings;
@synthesize miniConsole;
@synthesize mainWindow;
@synthesize pdfViewContainer;
@synthesize pdfViewerController;
@synthesize results;
@synthesize statusViewController;
@synthesize statusViewContainer;
@synthesize tabbarController;

@synthesize palette;
@synthesize paletteContainerView;

@synthesize library;
@synthesize libraryContainerView;

@synthesize engineSettingsController;
@synthesize prefsContainerView;

@synthesize pdfViewer;

@synthesize leftView;
@synthesize centerView;
@synthesize rightView;
@synthesize splitView;

@synthesize templateEditor;

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
  return [[super readableTypes] arrayByAddingObjectsFromArray:[sfm supportedTypes]];
}

+ (NSArray *)writableTypes
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  return [[super writableTypes] arrayByAddingObjectsFromArray:[sfm supportedTypes]];
}

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation
{
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
        
        // pdf view visible rect
        NSString *pdfVisibleRect = [dict valueForKey:TPExternalDocPDFVisibleRectKey];
        [self.pdfViewerController restoreVisibleRectFromPersistentString:pdfVisibleRect];
        
      }
    }    
  }
}


- (void)awakeFromNib
{
  self.results = [NSMutableArray array];
  
  // ensure we have a settings dictionary before proceeding
  [self initSettings];
  
  [self.tabbarController selectTabAtIndex:1];
  
//  NSLog(@"Awake from nib");
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
  [self.texEditorViewController enableEditor];
  
	if (self.documentData) {
		[self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
	}
	
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
  self.library = [[[LibraryController alloc] initWithDelegate:self] autorelease];
  [self.library.view setFrame:[self.libraryContainerView bounds]];
  [self.libraryContainerView addSubview:self.library.view];
  
  
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
}

- (void)windowWillClose:(NSNotification *)notification 
{		
  // stop filemonitor from reaching us
  self.fileMonitor.delegate = nil;
  outlineController.delegate = nil;
  
  if (![self inVersionsMode]) {
    if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
      if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
        [[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
      }
    }
  }
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
                     [NSNumber numberWithBool:YES], @"TPStandAloneEditorShowStatusBar",
                     nil];
  }
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

- (void) handleTextSelectionChanged:(NSNotification*)aNote
{
	[self updateCursorInfoText];
}

- (void) updateCursorInfoText
{
  NSInteger cursorPosition = [self.texEditorViewController.textView cursorPosition];
  NSInteger lineNumber = [self.texEditorViewController.textView lineNumber];
  if (lineNumber == NSNotFound) {
    [self.statusViewController setEditorStatusText:[NSString stringWithFormat:@"line: -, char: %ld", cursorPosition]];
  } else {
    [self.statusViewController setEditorStatusText:[NSString stringWithFormat:@"line: %ld, char: %ld", lineNumber, cursorPosition]];
  }
}


- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  self.fileLoadDate = nil;
  self.fileMonitor = nil;
  self.engineManager = nil;
  self.settings = nil;
  self.palette = nil;
  self.library = nil;
  self.texEditorViewController = nil;
  self.miniConsole = nil;
  self.settings = nil;
  self.engineSettingsController = nil;
  self.statusViewContainer = nil;
  self.pdfViewerController.delegate = nil;
  self.pdfViewerController = nil;
  self.results = nil;
  self.pdfViewer = nil;
	[super dealloc];
}



- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
  if ([self inVersionsMode]) {
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
  
  // toggle status bar
  if (tag == 2040) {
    if (statusViewIsShowing) {
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
  if (self.pdfViewerController && self.pdfViewerController.pdfview) {
    NSView *view = [self.pdfViewerController.pdfview documentView];    
    NSRect r = [view visibleRect];
    BOOL hasDoc = [self.pdfViewerController hasDocument];
    [self.pdfViewerController redisplayDocument];
    if (hasDoc) {
      [view scrollRectToVisible:r];
    }    
  }  
}

- (IBAction) saveDocument:(id)sender
{
//  NSLog(@"Save doc...");
  
  // cache chosen language
  NSString *language = [[NSSpellChecker sharedSpellChecker] language];	
	[[NSUserDefaults standardUserDefaults] setValue:language forKey:TPSpellCheckerLanguage];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
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
	NSAttributedString *attStr = [self.texEditorViewController.textView attributedString];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
	[string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
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
//  NSLog(@"Read from URL %@", absoluteURL);
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  NSString *str = [fr readStringFromFileAtURL:absoluteURL];
	if (str) {
    self.fileLoadDate = [NSDate date];
    _encoding = [fr encodingUsed];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:_encoding]
                                                        forKey:NSCharacterEncodingDocumentAttribute];
    NSMutableAttributedString *attStr = [[[NSMutableAttributedString alloc] initWithString:str attributes:options] autorelease];
		[self setDocumentData:attStr];
    [[self.texEditorViewController.textView textStorage] setAttributedString:attStr];
    [self.texEditorViewController.textView applyFontAndColor];
    [self.texEditorViewController.textView colorWholeDocument];
    
    // read settings
    NSData *data = [UKXattrMetadataStore dataForKey:@"com.bobsoft.TeXnicleSettings" atPath:[absoluteURL path] traverseLink:NO];
    if (data) {
      NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
      if (dict) {
        self.settings = [NSMutableDictionary dictionaryWithDictionary:dict];
      }
    }
    
		return YES;
	}
  
	return NO;
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
//  NSLog(@"Reload current file from disk");
  NSRange selected = [self.texEditorViewController.textView selectedRange];
  [self.texEditorViewController.textView setSelectedRange:NSMakeRange(0, 0)];  
  [self revertDocumentToSaved:self];
  [self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
  if (NSMaxRange(selected) < [[self.documentData string] length]) {
    [self.texEditorViewController.textView setSelectedRange:selected];
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
    if (error) {
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
	return [str citations];	
}

- (NSArray*) listOfCommands
{
  return [NSArray array];
}

- (NSArray*) listOfReferences
{
	NSString *str = [self.texEditorViewController.textView string];
	return [str referenceLabels];	
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
  [self.engineManager compile];
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

- (void) fileMonitor:(TPFileMonitor *)aMonitor fileWasAccessedOnDisk:(id)file accessDate:(NSDate *)access
{
//  NSLog(@"File was accessed on disk...");
  if ([self fileURL]) {
    if (![self isDocumentEdited]) {
      [self performSelector:@selector(reloadCurrentFileFromDisk:) withObject:self afterDelay:0];
    }
  }
}


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
        [self revertDocumentToSaved:self];
        [self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
      } else {
        self.fileLoadDate = modified;
      }
    } else {
      [self revertDocumentToSaved:self];
      [self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
    }
  }
}


#pragma mark -
#pragma mark Engine Settings Delegate

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

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
  //  NSLog(@"Resize with old size %@", NSStringFromSize(oldSize));
  
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
  
  [sender adjustSubviews];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
  
  if (subview == self.leftView || subview == self.centerView)
    return NO;
  
  
  if (subview == self.rightView) {
    NSRect b = [self.rightView bounds];
    if (b.size.width < kSplitViewRightMinSize) {
      return NO;
    }
  }
  
  return YES;
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
  if (subview == self.centerView) {
    return NO;
  }
  
  return YES;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 0) {
    NSRect b = [aSplitView bounds];
    NSRect rb = [self.rightView bounds];
    CGFloat max =  b.size.width - rb.size.width - kSplitViewCenterMinSize;
    return max;
  }
  
  if (dividerIndex == 1) {
    NSRect b = [aSplitView bounds];
    return b.size.width-kSplitViewRightMinSize;
  }
  
  return proposedMax;
}


- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
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

- (void) libraryController:(LibraryController*)library insertText:(NSString*)text
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
  
  if (aFile == nil || [[aFile path] isEqualToString:[[self fileURL] path]]) {
    
    // Now highlight the search term in that 
    [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
    
    // Make text view first responder
    [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
    
    // and color the newly viewed text
    [self.texEditorViewController.textView performSelector:@selector(colorVisibleText) withObject:nil afterDelay:0];
    
  } else {
    
    __block NSString *forwardResult = result;
    __block NSRange forwardRange = aRange;
    __block id forwardFile = aFile;
    
    [[NSDocumentController sharedDocumentController]
      openDocumentWithContentsOfURL:aFile
      display:YES
      completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
        if (document) {
          ExternalTeXDoc *doc = (ExternalTeXDoc*)document;
          
          NSString *rangeString = NSStringFromRange(forwardRange);
          
          NSInvocation			*invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(wrappedHighlightSearchResult:withRange:inFile:)]];
          [invocation setSelector:@selector(wrappedHighlightSearchResult:withRange:inFile:)];
          [invocation setTarget:doc];
          [invocation setArgument:&forwardResult atIndex:2];    
          [invocation setArgument:&rangeString atIndex:3];    
          [invocation setArgument:&forwardFile atIndex:4];    
          [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0.1];
          
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
    [self.texEditorViewController setString:[aTemplate valueForKey:@"Code"]];
    [self.texEditorViewController.textView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0];
  }
  [NSApp endSheet:self.templateEditor.window];
  [self.templateEditor.window orderOut:self];  
}



@end
