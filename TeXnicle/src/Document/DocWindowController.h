//
//  DocWindowController.h
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"

@class FileEntity;
@class TeXEditorViewController;
@class TPStatusView;

@interface DocWindowController : NSWindowController <TeXTextViewDelegate> {

	IBOutlet NSView *texEditorContainer;
  IBOutlet TPStatusView *statusView;
	id mainDocument;
	FileEntity *file;
	TeXEditorViewController *texEditorViewController;
}

@property (readwrite,assign) FileEntity *file;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (retain) IBOutlet NSView *texEditorContainer;

- (id) initWithFile:(FileEntity*)aFile document:(id)document;
- (IBAction) saveDocument:(id)sender;
- (void) updateEditedState;

- (void) handleTextSelectionChanged:(NSNotification*)aNote;
- (void) updateCursorInfoText;


@end
