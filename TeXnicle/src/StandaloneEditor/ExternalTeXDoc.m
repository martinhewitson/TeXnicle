//
//  ExternalTeXDoc.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "ExternalTeXDoc.h"
#import "TeXProjectDocument.h"
#import "ProjectEntity.h"
#import "NSString+LaTeX.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "TeXEditorViewController.h"
#import "TPLaTeXEngine.h"
#import "externs.h"
#import "ConsoleController.h"
#import "TPStatusView.h"

@implementation ExternalTeXDoc

@synthesize documentData;
@synthesize texEditorContainer;
@synthesize texEditorViewController;
@synthesize engine;
@synthesize statusView;
@synthesize compilerType;
@synthesize fileLoadDate;
@synthesize fileMonitor;

- (void)awakeFromNib
{
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
	
	if (self.documentData) {
		[self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
	}
	
  self.engine = [TPLaTeXEngine engineWithDelegate:self];
  self.compilerType = TPEngineCompilerPDFLaTeX;
  
  self.fileMonitor = [TPFileMonitor monitorWithDelegate:self];
  
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
				 selector:@selector(handleTextSelectionChanged:)
						 name:NSTextViewDidChangeSelectionNotification
					 object:self.texEditorViewController.textView];
	  
  [nc addObserver:self
         selector:@selector(handleTypesettingCompletedNotification:)
             name:TPTypesettingCompletedNotification
           object:self.engine];

  if (![self fileURL]) {
    [self.statusView setFilename:@"Welcome to TeXnicle!"];
  } else {
    [self.statusView setFilename:[[self fileURL] path]];
    [self.statusView setShowRevealButton:YES];
  }
  [self.statusView setEditorStatus:@"No Selection."];
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
//	NSLog(@"Closing window %@", [[NSDocumentController sharedDocumentController] documents]);
	
	if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
//    NSLog(@"Showing startup...");
		if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
			[[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
		}
	}	
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  self.engine = nil;
  self.fileLoadDate = nil;
  self.fileMonitor = nil;
	[super dealloc];
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

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSAttributedString *attStr = [self.texEditorViewController.textView attributedString];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
	[string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
	
	NSString *str = [string string];
	BOOL res = [str writeToURL:absoluteURL
									atomically:YES
										encoding:NSUTF8StringEncoding
											 error:outError];
	[string release];
	return res;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSStringEncoding encoding;
	NSLog(@"Reading from URL %@", absoluteURL);
	
	NSString *str = [NSString stringWithContentsOfURL:absoluteURL
																						 usedEncoding:&encoding
																										error:outError];
		
	if (str) {
    self.fileLoadDate = [NSDate date];
		[self setDocumentData:[[NSMutableAttributedString alloc] initWithString:str]];
		return YES;
	}

	return NO;
}


//- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
//{
//	// Insert code here to write your document to data of the specified type. 
//	// If the given outError != NULL, ensure that you set *outError when returning nil.
//	NSLog(@"returning data for saving");
//	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, 
//	//or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//	NSString *str = [[textView attributedString] string];
//	NSLog(@"Saving string: %@", str);
//	NSData *data = [str dataUsingEncoding:NS];	
//	NSLog(@"Got data %@", data);
//	[textView breakUndoCoalescing];
//	
//	return data;	
//}

//- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
//{
//	if (!data) 
//		return NO;
//	
//	documentData = [[NSMutableAttributedString alloc] 
//									initWithData:data 
//									options:nil 
//									documentAttributes:nil error:outError];	
//	if (outError && *outError) {
//		return NO;
//	}
//	
//	
//	// Insert code here to read your document from the given data of the specified type.  
//	// If the given outError != NULL, ensure that you set *outError when returning NO.
//	
//	// You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
//	
//	// For applications targeted for Panther or earlier systems, you should use 
//	// the deprecated API -loadDataRepresentation:ofType. In this case you can also 
//	// choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
//	
//	return YES;
//}

#pragma mark -
#pragma mark control

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


#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender
{
  [self.engine trashAuxFiles];  
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
  [self.engine reset];
  [self.engine build];  
}

- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote
{  
  if (openPDFAfterBuild) {
    [self openPDF:self];
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


#pragma mark -
#pragma mark LaTeX Engine delegate

- (NSString*) engineDocumentToCompile:(TPLaTeXEngine*)anEngine
{
  return [[self fileURL] path];
}

- (NSString*) engineWorkingDirectory:(TPLaTeXEngine*)anEngine
{
  return [[[self fileURL] path] stringByDeletingLastPathComponent]; 
}

- (BOOL) engineCanBibTeX:(TPLaTeXEngine*)anEngine
{
	return YES;	 
}

- (TPEngineCompiler) engineProjectType:(TPLaTeXEngine*)anEngine
{
  return self.compilerType;
}

- (BOOL) engineDocumentIsProject:(TPLaTeXEngine*)anEngine
{
  return NO;
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

@end
