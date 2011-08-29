//
//  DocWindowController.m
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "DocWindowController.h"
#import "FileEntity.h"
#import "FileDocument.h"
#import "TeXEditorViewController.h"
#import "TeXTextView.h"
#import "TPSectionListController.h"
#import "TPStatusView.h"
#import "Bookmark.h"
#import "MHLineNumber.h"

@implementation DocWindowController

@synthesize file;
@synthesize texEditorContainer;
@synthesize texEditorViewController;
@synthesize mainDocument;

- (id) initWithFile:(FileEntity*)aFile document:(id)document
{
	
	if (![self initWithWindowNibName:@"DocWindow"]) {
		return nil;
	}
	
	self.mainDocument = document;
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
  [nc addObserver:self
				 selector:@selector(handleTextSelectionChanged:)
						 name:NSTextViewDidChangeSelectionNotification
					 object:self.texEditorViewController.textView];
	
  [nc addObserver:self
         selector:@selector(handleLineNumberClickedNotification:) 
             name:TELineNumberClickedNotification
           object:self.texEditorViewController.textView];
  
	[self updateEditedState];
  
  [statusView setFilename:[file pathOnDisk]];
  [statusView setShowRevealButton:YES];
  [self updateCursorInfoText];
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

- (void) handleTextSelectionChanged:(NSNotification*)aNote
{
  
	[self updateCursorInfoText];
}

- (void) updateCursorInfoText
{
	NSRange sel = [self.texEditorViewController.textView selectedRange];
  [statusView setEditorStatus:[NSString stringWithFormat:@"character: %d", sel.location]];
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

-(id)project
{
  return [file valueForKey:@"project"];
}

- (NSArray*) listOfTeXFilesPrependedWith:(NSString*)string
{
	return [mainDocument listOfTeXFilesPrependedWith:string];
}

- (NSArray*) listOfCitations
{
	return [mainDocument listOfCitations];
}

- (NSArray*)listOfCommands
{
  return [mainDocument listOfCommands];
}

- (NSArray*) listOfReferences
{
	return [mainDocument listOfReferences];
}

- (BOOL) shouldSyntaxHighlightDocument
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

- (NSArray*)bookmarksForCurrentFileInLineRange:(NSRange)aRange
{
  NSMutableArray *bookmarks = [NSMutableArray array];
  if (self.file && [[self.file valueForKey:@"isText"] boolValue]) {    
    NSArray *allBookmarks = [self.file.bookmarks allObjects];
    for (Bookmark *b in allBookmarks) {
      NSInteger bl = [b.linenumber integerValue];
      if (bl >= aRange.location && bl < NSMaxRange(aRange)) {
        [bookmarks addObject:b];
      }
    }
  }
  return bookmarks;
}

- (void) handleLineNumberClickedNotification:(NSNotification*)aNote
{
  MHLineNumber *linenumber = [[aNote userInfo] valueForKey:@"LineNumber"];
  
  // Check if there is already a bookmark for this file
  if ([self hasBookmarkAtLine:linenumber.number]) {
    [self removeBookmarkAtLine:linenumber.number];
  } else {
    [self addBookmarkAtLine:linenumber.number];
  }
}

- (Bookmark*)bookmarkForCurrentLine
{
  NSInteger linenumber = [self.texEditorViewController.textView lineNumber];
  return [self bookmarkForLine:linenumber];
}

- (Bookmark*)bookmarkForLine:(NSInteger)linenumber
{
  Bookmark *bookmark = [self.file bookmarkForLinenumber:linenumber];
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
  [self.mainDocument.bookmarkManager previousBookmark:self];
}

- (IBAction)nextBookmark:(id)sender
{
  [self.mainDocument.bookmarkManager nextBookmark:self];
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
    Bookmark *bookmark = [Bookmark bookmarkWithLinenumber:aLinenumber inFile:self.file inManagedObjectContext:self.mainDocument.managedObjectContext];    
    [self.texEditorViewController.textView setNeedsDisplay:YES];
    [self.mainDocument.bookmarkManager reloadData];
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
    [[self.file mutableSetValueForKey:@"bookmarks"] removeObject:b];
    [self.texEditorViewController.textView setNeedsDisplay:YES];
    [self.mainDocument.bookmarkManager reloadData];
  }  
}

#pragma mark -
#pragma mark Bookmark Manager delegate

- (void) didDeleteBookmark
{
  [self.texEditorViewController.textView setNeedsDisplay:YES];
}

- (void) didAddBookmark
{
  [self.texEditorViewController.textView setNeedsDisplay:YES];
}

- (void) jumpToBookmark:(Bookmark *)aBookmark
{
  NSInteger linenumber = [aBookmark.linenumber integerValue];
  FileEntity *jumpToFile = aBookmark.parentFile;
  
  if (jumpToFile == self.file) {
    // expand all folded code
    [self.texEditorViewController.textView expandAll:self];
    
    // Now highlight the search term in that 
    [self.texEditorViewController.textView jumpToLine:linenumber inFile:file select:YES];
  }
  
  //  [self.texEditorViewController.textView selectRange:aRange scrollToVisible:YES animate:YES];
  
  // Make text view first responder
//  [[self windowForSheet] makeFirstResponder:self.texEditorViewController.textView];
  
  
}

- (NSArray*)bookmarksForCurrentFile
{
  return [self.file.bookmarks allObjects];
}

//- (NSArray*)bookmarksForProject
//{
//  NSMutableArray *bookmarks = [NSMutableArray array];
//  for (ProjectItemEntity *item in [self.project valueForKey:@"items"]) {
//    if ([item isKindOfClass:[FileEntity class]]) {
//      FileEntity *file = (FileEntity*)item;
//      if ([[file valueForKey:@"isText"] boolValue]) {
//        [bookmarks addObjectsFromArray:[file.bookmarks allObjects]]; 
//      }
//    }
//  }  
//  return bookmarks;
//}


@end
