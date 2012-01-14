//
//  BookmarkManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HHValidatedButton.h"

@class BookmarkManager;
@class Bookmark;
@class FileEntity;

@protocol BookmarkManagerDelegate <NSObject>
@optional
- (NSArray*)bookmarksForCurrentFile;
- (NSArray*)bookmarksForProject;
- (void) jumpToBookmark:(Bookmark*)aBookmark;
- (void) didDeleteBookmark;
- (void) didAddBookmark;

@end

@interface BookmarkManager : NSViewController <NSUserInterfaceValidations, BookmarkManagerDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
@private
  id<BookmarkManagerDelegate> delegate;
  NSOutlineView *outlineView;
  HHValidatedButton *jumpToButton;
  HHValidatedButton *deleteButton;
  NSInteger _currentSelectedBookmark;
  
  HHValidatedButton *expandAllButton;
  HHValidatedButton *collapseAllButton;
}

@property (assign) id<BookmarkManagerDelegate> delegate;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet HHValidatedButton *jumpToButton;
@property (assign) IBOutlet HHValidatedButton *deleteButton;
@property (assign) IBOutlet HHValidatedButton *expandAllButton;
@property (assign) IBOutlet HHValidatedButton *collapseAllButton;


- (id)initWithDelegate:(id<BookmarkManagerDelegate>)aDelegate;

- (IBAction)expandAll:(id)sender;
- (IBAction)collapseAll:(id)sender;

- (IBAction)previousBookmark:(id)sender;
- (IBAction)nextBookmark:(id)sender;
- (IBAction)jumpToSelectedBookmark:(id)sender;
- (IBAction)deleteSelectedBookmark:(id)sender;
- (Bookmark*)selectedBookmark;

- (void) reloadData;

- (NSArray*)bookmarksForFile:(FileEntity*)aFile;
- (NSArray*)files;
- (NSArray*)allBookmarks;

@end
