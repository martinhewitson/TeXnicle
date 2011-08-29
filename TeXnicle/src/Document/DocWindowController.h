//
//  DocWindowController.h
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"
#import "BookmarkManager.h"
#import "TeXProjectDocument.h"

@class FileEntity;
@class TeXEditorViewController;
@class TPStatusView;

@interface DocWindowController : NSWindowController <TeXTextViewDelegate, BookmarkManagerDelegate> {

	IBOutlet NSView *texEditorContainer;
  IBOutlet TPStatusView *statusView;
	TeXProjectDocument *mainDocument;
	FileEntity *file;
	TeXEditorViewController *texEditorViewController;
}

@property (readwrite,assign) FileEntity *file;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (retain) IBOutlet NSView *texEditorContainer;
@property (assign) TeXProjectDocument *mainDocument;

- (id) initWithFile:(FileEntity*)aFile document:(TeXProjectDocument*)document;
- (IBAction) saveDocument:(id)sender;
- (void) updateEditedState;

- (void) handleTextSelectionChanged:(NSNotification*)aNote;
- (void) updateCursorInfoText;

- (Bookmark*)bookmarkForCurrentLine;
- (Bookmark*)bookmarkForLine:(NSInteger)linenumber;
- (BOOL) hasBookmarkAtCurrentLine:(id)sender;
- (BOOL) hasBookmarkAtLine:(NSInteger)aLinenumber;
- (IBAction)addBookmarkAtCurrentLine:(id)sender;
- (void) addBookmarkAtLine:(NSInteger)aLinenumber;
- (IBAction)removeBookmarkAtCurrentLine:(id)sender;
- (void) removeBookmarkAtLine:(NSInteger)aLinenumber;
- (IBAction)toggleBookmark:(id)sender;
- (IBAction)previousBookmark:(id)sender;
- (IBAction)nextBookmark:(id)sender;

@end
