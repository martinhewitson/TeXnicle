//
//  ProjectOutlineController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 24/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProjectEntity;
@class FileEntity;

@protocol ProjectOutlineControllerDelegate <NSObject>

- (ProjectEntity*)project;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile;
- (BOOL) shouldGenerateOutline;

@end

@interface ProjectOutlineController : NSWindowController {

	NSTimer *timer;
	NSMutableArray *sections;
	NSMutableParagraphStyle *paragraphStyle;
	
//	TeXProjectDocument *projectDocument;
	IBOutlet NSTextView *textView;
	id<ProjectOutlineControllerDelegate> delegate;
	BOOL generating;
}

@property (nonatomic, retain) NSTimer *timer;
@property (assign) IBOutlet id<ProjectOutlineControllerDelegate> delegate;

- (void) generateTOC;
//- (void) handleDocChanges:(NSNotification*)aNote;
- (NSMutableAttributedString*) addLinksTo:(NSMutableAttributedString*)aStr InFile:(FileEntity*)aFile inProject:(ProjectEntity*)project;
-(void) turnOffWrapping;
- (void) deactivate;

@end
