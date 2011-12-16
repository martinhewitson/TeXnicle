//
//  BookmarkOutlineView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Bookmark;

@protocol BookmarkOutlineViewDelegate <NSObject>

- (Bookmark*)selectedBookmark;
- (void)selectBookmarkForLinenumber:(NSInteger)aLinenumber;

@end

@interface BookmarkOutlineView : NSOutlineView {
@private
  id<BookmarkOutlineViewDelegate> bookmarkDelegate;
  NSString *capturedString;
  NSDate *lastKeyStroke;
  NSTimer *resetTimer;
  NSTextField *selectingStatus;
}

@property (retain) NSTimer *resetTimer;
@property (assign) IBOutlet id<BookmarkOutlineViewDelegate> bookmarkDelegate;
@property (retain) NSDate *lastKeyStroke;
@property (assign) IBOutlet NSTextField *selectingStatus;

- (void) updateStatus;

@end
