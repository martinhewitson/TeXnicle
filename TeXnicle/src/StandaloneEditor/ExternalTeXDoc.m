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
#import "TPStatusView.h"
#import "UKXattrMetadataStore.h"
#import "MHFileReader.h"
#import "NSAttributedString+LineNumbers.h"
#import "RegexKitLite.h"
#import "MHLineNumber.h"
#import "TPDocumentMatch.h"

@implementation ExternalTeXDoc

@synthesize documentData;
@synthesize texEditorContainer;
@synthesize texEditorViewController;
@synthesize statusView;
@synthesize fileLoadDate;
@synthesize fileMonitor;
@synthesize engineManager;
@synthesize engineSettingsController;
@synthesize drawerContentView;
@synthesize drawer;
@synthesize settings;
@synthesize compileProgressIndicator;
@synthesize miniConsole;
@synthesize mainWindow;
@synthesize pdfViewContainer;
@synthesize pdfViewerController;
@synthesize results;

- (void)awakeFromNib
{
  self.results = [NSMutableArray array];
  
  // ensure we have a settings dictionary before proceeding
  [self initSettings];
  
//  NSLog(@"Awake from nib");
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
	
	if (self.documentData) {
		[self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
	}
	
  // setup pdf viewer
  self.pdfViewerController = [[PDFViewerController alloc] initWithDelegate:self];
  NSView *pdfViewer = [self.pdfViewerController view];
  [pdfViewer setFrame:[self.pdfViewContainer bounds]];
  [self.pdfViewContainer addSubview:pdfViewer];
  
  // set up engine manager
  self.engineManager = [TPEngineManager engineManagerWithDelegate:self];
    
  // set up engine settings
  self.engineSettingsController = [[TPEngineSettingsController alloc] initWithDelegate:self];
  [self.engineSettingsController.view setFrame:[self.drawerContentView bounds]];
  [self.drawerContentView addSubview:self.engineSettingsController.view];
  [self.drawer setContentSize:NSMakeSize(230, 400)];
  [self.drawer setMinContentSize:NSMakeSize(230, 400)];
  [self.drawer setMaxContentSize:NSMakeSize(230, 400)];
    
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

  if (![self fileURL]) {
    [self.statusView setFilename:@"Welcome to TeXnicle!"];
  } else {
    [self.statusView setFilename:[[self fileURL] path]];
    [self.statusView setShowRevealButton:YES];
  }
  [self.statusView setEditorStatus:@"No Selection."];
  
  
  self.miniConsole = [[[MHMiniConsoleViewController alloc] init] autorelease];
  NSArray *items = [[self.mainWindow toolbar] items];
  for (NSToolbarItem *item in items) {
//    NSLog(@"%@: %@", [item itemIdentifier], NSStringFromRect([[item view] frame]));
    if ([[item itemIdentifier] isEqualToString:@"MiniConsole"]) {
      NSBox *box = (NSBox*)[item view];
      [box setContentView:self.miniConsole.view];
    }
  }
  [self.miniConsole message:@"Welcome."];

  // register the mini console
  [self.engineManager registerConsole:self.miniConsole];
  
  [self showDocument];
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
                     nil];
  }
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
	NSRange sel = [self.texEditorViewController.textView selectedRange];
  [self.statusView setEditorStatus:[NSString stringWithFormat:@"character: %d", sel.location]];
}


- (void) windowDidBecomeKey:(NSNotification *)notification
{
}

- (void)windowWillClose:(NSNotification *)notification 
{		
  // stop filemonitor from reaching us
  self.fileMonitor.delegate = nil;
  
	if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
		if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
			[[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
		}
	}	
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  self.fileLoadDate = nil;
  self.fileMonitor = nil;
  self.engineManager = nil;
  self.settings = nil;
  self.miniConsole = nil;
  self.pdfViewerController = nil;
  self.results = nil;
	[super dealloc];
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
}

- (IBAction)findSource:(id)sender
{
  [self.results removeAllObjects];
  
  NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
  NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
  
  PDFSelection *selection = [self.pdfViewerController.pdfview currentSelection];
  NSString *searchTerm = [selection string];

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
  BOOL didMatch = NO;
  shouldContinueSearching = YES;
  if ([regexpresults count] > 0) {
    
    for (NSString *result in regexpresults) {
      if (!shouldContinueSearching) {
        break;
      } // If should continue 
      
      NSString *returnResult = [NSString stringWithControlsFilteredForString:result];
      
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
            didMatch = YES;
            
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
  NSView *view = [self.pdfViewerController.pdfview documentView];    
  NSRect r = [view visibleRect];
  BOOL hasDoc = [self.pdfViewerController hasDocument];
  [self.pdfViewerController redisplayDocument];
  if (hasDoc) {
    [view scrollRectToVisible:r];
  }
}

- (IBAction) saveDocument:(id)sender
{
	NSRange selRange = [self.texEditorViewController.textView selectedRange];
	NSRect selRect = [self.texEditorViewController.textView visibleRect];
	NSResponder *r = [[self windowForSheet] firstResponder];
  [self saveDocumentWithDelegate:self didSaveSelector:@selector(documentSave:didSave:contextInfo:) contextInfo:NULL];
//	[super saveDocument:sender];
	[self.texEditorViewController.textView setSelectedRange:selRange];
	[self.texEditorViewController.textView scrollRectToVisible:selRect];
	[[self windowForSheet] makeFirstResponder:r];
  [self updateFileStatus];
}

- (void)documentSave:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
//  if (didSave) {
//    [self.engine setFilepath:[[self fileURL] path]];
//  } else {
//  }
  [self updateFileStatus];  
}

- (void) updateFileStatus
{
  if ([self fileURL]) {
    [self.statusView setFilename:[[self fileURL] path]];    
    [self.statusView setShowRevealButton:YES];
  } else {
    [self.statusView setFilename:@"Welcome to TeXnicle!"];
    [self.statusView setShowRevealButton:NO];
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

- (IBAction)reopenUsingEncoding:(id)sender
{
  NSString *path = [[self fileURL] path];
  
  // clear the xattr
  [UKXattrMetadataStore setString:@""
                           forKey:@"com.bobsoft.TeXnicleTextEncoding"
                           atPath:path
                     traverseLink:YES];
  
  MHFileReader *fr = [[[MHFileReader alloc] initWithEncodingNamed:[sender title]] autorelease];
  NSString *str = [fr readStringFromFileAtURL:[self fileURL]];
	if (str) {
    self.fileLoadDate = [NSDate date];
		[self setDocumentData:[[NSMutableAttributedString alloc] initWithString:str]];
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

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSAttributedString *attStr = [self.texEditorViewController.textView attributedString];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
	[string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
	
	NSString *str = [string string];
  
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  BOOL res = [fr writeString:str toURL:absoluteURL];
	[string release];
  
  // now write project settings as xattr  
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.settings];
  
  [UKXattrMetadataStore setData:data forKey:@"com.bobsoft.TeXnicleSettings" atPath:[absoluteURL path] traverseLink:NO];
  
	return res;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  NSString *str = [fr readStringFromFileAtURL:absoluteURL];
	if (str) {
    self.fileLoadDate = [NSDate date];
		[self setDocumentData:[[NSMutableAttributedString alloc] initWithString:str]];
    
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

- (IBAction)reloadCurrentFileFromDisk:(id)sender
{
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
	// user clicked cancel
	if ([sender tag] == 0) {
		[NSApp endSheet:addToProjectSheet];
		[addToProjectSheet orderOut:sender];
		return;
	}
	
	// user clicked new project button
	if ([sender tag] == 2) {
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
  id doc = [TeXProjectDocument newTeXnicleProject];
  
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
	// Add to project button
	if (item == addToProjectButton) {
		if ([self isDocumentEdited] || [self fileURL] == nil) {
			return NO;
		}
	}
	
	return YES;
}


#pragma mark -
#pragma mark Text Colorer delegate

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
	NSString *ext = [[[self fileURL] path] pathExtension];
	if ([ext isEqual:@"tex"] ||
			[ext isEqual:@"bib"]) {
		return YES;
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
  [self.compileProgressIndicator startAnimation:self];
  [self.engineManager compile];
}

- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote
{
  [self.compileProgressIndicator stopAnimation:self];
  NSDictionary *userinfo = [aNote userInfo];
  if ([[userinfo valueForKey:@"success"] boolValue]) {
    [self showDocument];
    if (openPDFAfterBuild) {
      [self openPDF:self];
    }
  }
}


- (IBAction) openPDF:(id)sender
{
  NSString *docFile = [self compiledDocumentPath];
	// check if the pdf exists
	if (docFile) {
		//NSLog(@"Opening %@", pdfFile);
		[[NSWorkspace sharedWorkspace] openFile:docFile];
	}
	
	// .. if not, ask the user if they want to typeset the project
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
  if (![self isDocumentEdited]) {
    [self performSelector:@selector(reloadCurrentFileFromDisk:) withObject:self afterDelay:0];
  }
}


-(void) fileMonitor:(TPFileMonitor *)aMonitor fileChangedOnDisk:(id)file modifiedDate:(NSDate*)modified
{
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

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
  if (subview == leftView)
    return NO;
  
  return YES;
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
  return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 0) {
    NSRect b = [splitView bounds];
    return b.size.width-250;
  }
  
  return proposedMax;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
  
  if (dividerIndex == 0) {
    return 250;
  }
  
  return proposedMin;
}

@end
