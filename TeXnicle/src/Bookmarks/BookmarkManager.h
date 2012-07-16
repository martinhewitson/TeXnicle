//
//  BookmarkManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
