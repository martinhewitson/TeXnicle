//
//  DocWindowController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import "DocWindowController.h"
#import "FileEntity.h"
#import "FileDocument.h"
#import "TeXEditorViewController.h"
#import "TeXTextView.h"
#import "TPSectionListController.h"
#import "Bookmark.h"
#import "MHLineNumber.h"
#import "NSArray+LaTeX.h"
#import "TPSupportedFilesManager.h"
#import "MHSynctexController.h"

@interface DocWindowController()

@end

@implementation DocWindowController


- (id) initWithFile:(FileEntity*)aFile document:(id)document
{
	self = [super initWithWindowNibName:@"DocWindow"];
  if (self) {    
    self.mainDocument = document;
    self.file = aFile;
	}
	
	return self;
}

- (void) awakeFromNib
{
	//NSLog(@"Standalone awakeFromNib for %@", [file valueForKey:@"name"]);
	
  self.texEditorViewController = [[TeXEditorViewController alloc] init];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorContainer setNeedsDisplay:YES];
  [self.texEditorViewController setPerformSyntaxCheck:YES];
  [self.texEditorViewController setupSyntaxChecker];
	
  // setup status view
  self.statusViewController = [[TPStatusViewController alloc] init];
  [self.statusViewController.view setFrame:[self.statusViewContainer bounds]];
  [self.statusViewContainer addSubview:self.statusViewController.view];
  
  
	FileDocument *doc = [self.file document];
	
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
  
  [self.texEditorViewController enableEditor];
  
  [self.statusViewController setFilenameText:[self.file pathOnDisk]];
  [self.statusViewController enable:YES];
  [self updateCursorInfoText];
}

- (void)windowWillClose:(NSNotification *)notification 
{
  [self.file decreaseActiveCount];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.statusViewContainer = nil;
}


- (IBAction)printDocument:(id)sender
{
  // set printing properties
  NSPrintInfo *myPrintInfo = [[NSPrintInfo alloc] initWithDictionary:[[self.mainDocument printInfo] dictionary]];
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
  [op runOperationModalForWindow:self.window delegate:self didRunSelector:nil contextInfo:NULL];
//  [self.mainDocument runModalPrintOperation: op delegate: nil didRunSelector: NULL 
//                   contextInfo: NULL];
  
  
}

- (IBAction) saveDocument:(id)sender
{
	[self.mainDocument saveDocument:sender];
  [[self window] setDocumentEdited:NO];
  [self updateEditedState];
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

- (void)handleTextChanged:(NSNotification*)aNote
{
  if (![[self window] isKeyWindow]) {
    [self.texEditorViewController.textView colorVisibleText];
  }
	[self updateEditedState];
}

- (void) updateEditedState
{
	BOOL fileState = [self.file hasEdits];
//  NSLog(@"File has edits %d", fileState);
//  NSLog(@"Document state %d", [[self window] isDocumentEdited]);
	BOOL myState =  [[self window] isDocumentEdited];
	if (myState != fileState) {
		[[self window] setDocumentEdited:fileState];
	}
}

#pragma mark -
#pragma mark Text Colorer delegate

-(void)textView:(TeXTextView*)aTextView didCommandClickAtLine:(NSInteger)lineNumber column:(NSInteger)column
{
  [self.mainDocument syncToPDFLine:lineNumber column:column];
}

-(id)project
{
  return [self.file valueForKey:@"project"];
}

-(NSString*)fileExtension
{
  return [[self.file pathOnDisk] pathExtension];
}


- (NSArray*) listOfTeXFilesPrependedWith:(NSString*)string
{
	return [self.mainDocument listOfTeXFilesPrependedWith:string];
}

-(NSString*)codeForCommand:(NSString*)command
{
  return [self.mainDocument codeForCommand:command];
}

- (NSArray*)commandsBeginningWithPrefix:(NSString *)prefix
{
  return [self.mainDocument commandsBeginningWithPrefix:prefix];
}

- (NSArray*) listOfCitations
{
	return [self.mainDocument listOfCitations];
}

- (NSArray*)listOfCommands
{
  return [self.mainDocument listOfCommands];
}

- (NSArray*) listOfReferences
{
	return [self.mainDocument listOfReferences];
}

- (BOOL) shouldSyntaxHighlightDocument
{
	// If this is not a TeX document being edited, then we can return just 
	// applying the plain doc settings
	NSString *ext = [self.file valueForKey:@"extension"] ;
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  for (NSString *lext in [sfm supportedExtensionsForHighlighting]) {
    if ([ext isEqual:lext]) {
      return YES;
    }
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
    if (bookmark) {
      [self.texEditorViewController.textView setNeedsDisplay:YES];
      [self.mainDocument.texEditorViewController.textView setNeedsDisplay:YES];
      [self.mainDocument.bookmarkManager reloadData];
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
    [[self.file mutableSetValueForKey:@"bookmarks"] removeObject:b];
    [self.texEditorViewController.textView setNeedsDisplay:YES];
    [self.mainDocument.texEditorViewController.textView setNeedsDisplay:YES];
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
    [self.texEditorViewController.textView jumpToLine:linenumber inFile:self.file select:YES];
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
