//
//  OpenDocumentsManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSMTabBarControl.h"
#import "TeXEditorViewController.h"

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
	
	BOOL isOpening;
	
}

@property (readwrite, assign) BOOL isOpening;
@property (readwrite, assign) FileEntity *currentDoc;
@property (assign) IBOutlet id<OpenDocumentsManagerDelegate> delegate;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) TeXEditorViewController *texEditorViewController;

- (NSInteger) count;
- (void) refreshTabForDocument:(FileEntity*)aDoc;
- (void) handleDocumentRenamed:(NSNotification*)aNote;
- (void)updateDoc;

- (void) selectTabForFile:(FileEntity*)aFile;

- (void) standaloneWindowForFile:(FileEntity*)aFile;
- (void) closeCurrentTab;
- (NSInteger) indexOfDocumentWithFile:(FileEntity*)aFile;
- (void) removeDocument:(FileEntity*)aDoc;
- (void) addDocument:(FileEntity*)aDoc;
- (void) disableTextView;
- (void) enableTextView;

- (void) setCursorAndScrollPositionForCurrentDoc;
- (void) saveCursorAndScrollPosition;
- (void) commitStatus;



@end


