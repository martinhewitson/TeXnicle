//
//  FindInProjectController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 20/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TeXProjectDocument;
@class ProjectEntity;
@class FileEntity;
@class TPResultDocument;
@class FindInProjectController;

@protocol FindInProjectControllerDelegate <NSObject>

- (ProjectEntity*)project;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile;

- (void)didBeginSearch:(FindInProjectController*)aFinder;
- (void)didEndSearch:(FindInProjectController*)aFinder;
- (void)didMakeMatch:(FindInProjectController*)aFinder;
- (void)didCancelSearch:(FindInProjectController*)aFinder;

@end

@interface FindInProjectController : NSWindowController <NSOutlineViewDelegate, NSOutlineViewDataSource> {

  IBOutlet NSOutlineView *resultsOutlineView;	
  id<FindInProjectControllerDelegate> delegate;  
  NSMutableArray *results;
  NSCharacterSet *ws;
  NSCharacterSet *ns;
  
	dispatch_queue_t queue;
  dispatch_semaphore_t arrayLock;
  
  NSInteger filesProcessed;
  BOOL isSearching;
  BOOL shouldContinueSearching;
  BOOL shouldSearchOnEnd;
  
}

@property (assign) IBOutlet id<FindInProjectControllerDelegate> delegate;
@property (retain) NSMutableArray *results;


- (IBAction) performSearch:(id)sender;
- (void)searchForTerm:(NSString*)searchTerm;
- (void) searchForTerm:(NSString *)searchTerm inFile:(FileEntity*)file;
- (IBAction)handleOutlineViewDoubleClick:(id)sender;
- (void) jumpToResultAtRow:(NSInteger)aRow;
- (void) jumpToSearchResult:(NSInteger)index;
- (NSInteger)count;
- (id)resultAtIndex:(NSInteger)anIndex;

- (TPResultDocument*)resultDocumentForDocument:(FileEntity*)aFile;

@end
