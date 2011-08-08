//
//  BookmarkManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BookmarkManager;
@class Bookmark;
@class FileEntity;

@protocol BookmarkManagerDelegate <NSObject>

- (NSArray*)bookmarksForProject;
- (void) jumpToBookmark:(Bookmark*)aBookmark;

@end

@interface BookmarkManager : NSViewController <BookmarkManagerDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
@private
  id<BookmarkManagerDelegate> delegate;
}

@property (assign) id<BookmarkManagerDelegate> delegate;
@property (assign) IBOutlet NSOutlineView *outlineView;

- (id)initWithDelegate:(id<BookmarkManagerDelegate>)aDelegate;

- (NSArray*)bookmarksForFile:(FileEntity*)aFile;
- (NSArray*)files;
- (void) reloadData;

@end
