//
//  FinderProjectController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
- (void) replaceSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile withText:(NSString*)replacement;
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
  
  NSView *topbarView;
  NSPopUpButton *modeSelector;
  NSScrollView *scrollview;
  HHValidatedButton *replaceButton;
  HHValidatedButton *replaceAllButton;
  NSView *replaceView;
  NSTextField *replaceText;
  NSView *bottomBarView;
  
  HHValidatedButton *jumpToButton;
  NSSearchField *searchField;
  NSProgressIndicator *progressIndicator;
  NSTextField *statusLabel;
}

@property (assign) id<FinderControllerDelegate> delegate;
@property (assign) IBOutlet HHValidatedButton *jumpToButton;
@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSView *topbarView;
@property (assign) IBOutlet NSPopUpButton *modeSelector;
@property (assign) IBOutlet NSScrollView *scrollview;
@property (assign) IBOutlet HHValidatedButton *replaceButton;
@property (assign) IBOutlet HHValidatedButton *replaceAllButton;
@property (assign) IBOutlet NSView *replaceView;
@property (assign) IBOutlet NSView *bottomBarView;
@property (assign) IBOutlet NSTextField *replaceText;
@property (retain) NSMutableArray *results;

- (id) initWithDelegate:(id<FinderControllerDelegate>)aDelegate;

- (IBAction)replaceSelected:(id)sender;
- (IBAction)replaceAll:(id)sender;
- (void)searchForTerm:(NSString*)searchTerm;
- (TPResultDocument*)resultDocumentForDocument:(FileEntity*)aFile;
- (IBAction)handleOutlineViewDoubleClick:(id)sender;
- (NSInteger)count;
- (void) jumpToResultAtRow:(NSInteger)aRow;
- (void) jumpToSearchResult:(NSInteger)index;
- (IBAction) performSearch:(id)sender;
- (IBAction)selectMode:(id)sender;
- (void) stringSearchForTerm:(NSString *)searchTerm inFile:(FileEntity*)file;
- (void) searchForTerm:(NSString *)searchTerm inFile:(FileEntity*)file;
- (id)resultAtIndex:(NSInteger)anIndex;
- (void)setSearchTerm:(NSString*)aString;

@end
