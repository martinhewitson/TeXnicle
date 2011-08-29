//
//  OpenDocumentsManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSMTabBarControl.h"
#import "TeXEditorViewController.h"
#import "TPImageViewerController.h"

@class FileEntity;
@class OpenDocument;
@class ProjectEntity;

@protocol OpenDocumentsManagerDelegate <NSObject>

-(ProjectEntity*)project;
-(void) openDocumentsManager:(id)aDocumentManager didSelectFile:(FileEntity*)aFile;

@end

@interface OpenDocumentsManager : NSResponder {

	id sectionListController;
	
	FileEntity  *currentDoc;
	NSMutableArray *openDocuments;
	
	NSMutableArray *standaloneWindows;
	
  id<OpenDocumentsManagerDelegate> delegate;
	
  IBOutlet PSMTabBarControl *tabBar;
  IBOutlet NSBox *tabBackground;
	NSTabView *tabView;
  TeXEditorViewController *texEditorViewController;
	TPImageViewerController *imageViewerController;
	BOOL isOpening;
	
}

@property (readwrite, assign) BOOL isOpening;
@property (readwrite, assign) FileEntity *currentDoc;
@property (assign) IBOutlet id<OpenDocumentsManagerDelegate> delegate;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) TeXEditorViewController *texEditorViewController;
@property (assign) TPImageViewerController *imageViewerController;;

- (NSInteger) count;
- (void) refreshTabForDocument:(FileEntity*)aDoc;
- (void) handleDocumentRenamed:(NSNotification*)aNote;
- (void)updateDoc;
- (void)setupViewerForDoc:(FileEntity*)aDoc;

- (void) selectTabForFile:(FileEntity*)aFile;

- (void) standaloneWindowForFile:(FileEntity*)aFile;
- (void) closeCurrentTab;
- (NSInteger) indexOfDocumentWithFile:(FileEntity*)aFile;
- (void) removeDocument:(FileEntity*)aDoc;
- (void) addDocument:(FileEntity*)aDoc;
- (void) disableTextView;
- (void) enableTextView;
- (void)enableImageView:(BOOL)state;

- (void) setCursorAndScrollPositionForCurrentDoc;
- (void) saveCursorAndScrollPosition;
- (void) commitStatus;

- (NSArray*)standaloneWindows;

@end


