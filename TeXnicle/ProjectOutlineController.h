//
//  ProjectOutlineController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 24/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProjectEntity;
@class FileEntity;
@class TPDocumentSection;

@protocol ProjectOutlineControllerDelegate <NSObject>

- (ProjectEntity*)project;

- (NSURL*)fileURL;
- (NSAttributedString*)documentString;

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile;
- (BOOL) shouldGenerateOutline;
@end

@interface ProjectOutlineController : NSWindowController <NSOutlineViewDelegate, NSOutlineViewDataSource> {

	NSTimer *timer;
	NSMutableArray *sections;
	NSMutableParagraphStyle *paragraphStyle;
	
//	TeXProjectDocument *projectDocument;
	IBOutlet NSTextView *textView;
	id<ProjectOutlineControllerDelegate> delegate;
	BOOL generating;
  
  IBOutlet NSOutlineView *outlineView;
  TPDocumentSection *section;
}

@property (nonatomic, retain) NSTimer *timer;
@property (assign) IBOutlet id<ProjectOutlineControllerDelegate> delegate;
@property (retain) TPDocumentSection *section;

- (void) generateTOC;
- (void) generateTOCForProject:(ProjectEntity*)project;
- (void) generateTOCForFileAtURL:(NSURL*)aURL;

//- (void) handleDocChanges:(NSNotification*)aNote;
- (NSMutableAttributedString*) addLinksTo:(NSMutableAttributedString*)aStr InFile:(id)aFile inProject:(ProjectEntity*)project;
- (NSMutableAttributedString*) addLinksTo:(NSMutableAttributedString*)aStr forString:(NSMutableAttributedString*)astring atURL:(NSURL*)aURL;
-(void) turnOffWrapping;
- (void) deactivate;

- (void) reloadData;

@end
