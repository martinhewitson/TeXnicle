//
//  FinderProjectController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HHValidatedButton.h"

@class ProjectEntity;
@class FileEntity;
@class FinderController;
@class TPResultDocument;
@class TPDocumentMatch;

@protocol FinderControllerDelegate <NSObject>

- (ProjectEntity*)project;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile;
- (void)didBeginSearch:(FinderController*)aFinder;
- (void)didEndSearch:(FinderController*)aFinder;
- (void)didMakeMatch:(FinderController*)aFinder;
- (void)didCancelSearch:(FinderController*)aFinder;
- (NSInteger)lineNumberForRange:(NSRange)aRange;

@end

@interface FinderController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, FinderControllerDelegate, NSUserInterfaceValidations> {
@private
  
  NSOutlineView *outlineView;	
  id<FinderControllerDelegate> delegate;  
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

@property (assign) id<FinderControllerDelegate> delegate;
@property (assign) IBOutlet HHValidatedButton *jumpToButton;
@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (retain) NSMutableArray *results;

- (id) initWithDelegate:(id<FinderControllerDelegate>)aDelegate;

- (void)searchForTerm:(NSString*)searchTerm;
- (TPResultDocument*)resultDocumentForDocument:(FileEntity*)aFile;
- (IBAction)handleOutlineViewDoubleClick:(id)sender;
- (NSInteger)count;
- (void) jumpToResultAtRow:(NSInteger)aRow;
- (void) jumpToSearchResult:(NSInteger)index;
- (IBAction) performSearch:(id)sender;
- (void) searchForTerm:(NSString *)searchTerm inFile:(FileEntity*)file;
- (id)resultAtIndex:(NSInteger)anIndex;
- (void)setSearchTerm:(NSString*)aString;
@end
