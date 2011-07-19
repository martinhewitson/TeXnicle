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
	
  self.engine = [TPLaTeXEngine engineWithPath:[[self fileURL] path] delegate:self];
  
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
				 selector:@selector(handleTextSelectionChanged:)
						 name:NSTextViewDidChangeSelectionNotification
					 object:self.texEditorViewController.textView];
	  
  [nc addObserver:self
         selector:@selector(handleTypesettingCompletedNotification:)
             name:TPTypesettingCompletedNotification
           object:self.engine];

  [self.statusView setProjectStatus:[[self fileURL] path]];
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
	[super saveDocument:sender];
	[self.texEditorViewController.textView setSelectedRange:selRange];
	[self.texEditorViewController.textView scrollRectToVisible:selRect];
	[[self windowForSheet] makeFirstResponder:r];
  [self.engine setFilepath:[[self fileURL] path]];
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
	
	
	NSString *str = [NSString stringWithContentsOfURL:absoluteURL
																						 usedEncoding:&encoding
																										error:outError];
		
//	NSString *str = [NSString stringWithContentsOfURL:absoluteURL
//																					 encoding:NSUTF8StringEncoding
//																							error:outError];
//	
//	
//	if (!str) {		
//		str = [NSString stringWithContentsOfURL:absoluteURL
//																	 encoding:NSASCIIStringEncoding
//																			error:outError];
//	}

	if (str) {
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

- (NSArray*) listOfCitations
{
	NSString *str = [self.texEditorViewController.textView string];
	return [str citations];	
}


- (NSArray*) listOfReferences
{
	NSString *str = [self.texEditorViewController.textView string];
	return [str referenceLabels];	
}

- (BOOL) shouldRecolorDocument
{
	return YES;
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
    [self saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:NULL];
	} else {
    [self build];	
  }
  
}
     
- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
  NSLog(@"Did save %d", didSave);
  if (didSave) {
    [self.engine setFilepath:[[self fileURL] path]];
    [self build];
  } else {
    
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

@end
