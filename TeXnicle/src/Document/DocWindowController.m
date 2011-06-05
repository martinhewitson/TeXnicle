//
//  DocWindowController.m
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "DocWindowController.h"
#import "FileEntity.h"
#import "FileDocument.h"
#import "TeXEditorViewController.h"
#import "TeXTextView.h"
#import "TPSectionListController.h"

@implementation DocWindowController

@synthesize file;
@synthesize texEditorContainer;
@synthesize texEditorViewController;

- (id) initWithFile:(FileEntity*)aFile document:(id)document
{
	
	if (![self initWithWindowNibName:@"DocWindow"]) {
		return nil;
	}
	
	mainDocument = document;
	[self setFile:aFile];
	
//	NSLog(@"New view for %@", [file valueForKey:@"name"]);
	[self setFile:aFile];
	
	
	return self;
}

- (void) awakeFromNib
{
	//NSLog(@"Standalone awakeFromNib for %@", [file valueForKey:@"name"]);
	
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
	
	FileDocument *doc = [file document];
	
	// Add the textview's layout manager to the list of managers
	// for the text storage
	[[doc textStorage] addLayoutManager:[self.texEditorViewController.textView layoutManager]];		
	
	// color the file
	[self.texEditorViewController.textView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0.2];
	
	// watch for edits
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
				 selector:@selector(handleTextChanged:)
						 name:NSTextStorageDidProcessEditingNotification
					 object:[doc textStorage]];
	[nc addObserver:self
				 selector:@selector(windowWillClose:)
						 name:NSWindowWillCloseNotification
					 object:[self window]];
	
	[self updateEditedState];
}

- (void)windowWillClose:(NSNotification *)notification 
{
}

- (void) dealloc
{
	[super dealloc];
}

- (IBAction) saveDocument:(id)sender
{
	[mainDocument saveDocument:sender];
	[self updateEditedState];
}

- (void)handleTextChanged:(NSNotification*)aNote
{
  if (![[self window] isKeyWindow]) {
    [self.texEditorViewController.textView colorVisibleText];
  }
	[self updateEditedState];
}

- (void) updateEditedState
{
	BOOL fileState = [file hasEdits];
	BOOL myState =  [[self window] isDocumentEdited];
	if (myState != fileState) {
		[[self window] setDocumentEdited:fileState];
	}
}

#pragma mark -
#pragma mark Text Colorer delegate

- (NSArray*) listOfTeXFilesPrependedWith:(NSString*)string
{
	return [mainDocument listOfTeXFilesPrependedWith:string];
}

- (NSArray*) listOfCitations
{
	return [mainDocument listOfCitations];
}


- (NSArray*) listOfReferences
{
	return [mainDocument listOfReferences];
}

- (BOOL) shouldRecolorDocument
{
	// If this is not a TeX document being edited, then we can return just 
	// applying the plain doc settings
	NSString *ext = [file valueForKey:@"extension"] ;
	if ([ext isEqual:@"tex"] ||
			[ext isEqual:@"bib"]) {
		return YES;
	}
	
	//NSLog(@"Don't recolor");
	
	return NO;
}


@end
