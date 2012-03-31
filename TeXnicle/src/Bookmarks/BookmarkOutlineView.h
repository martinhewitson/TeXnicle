//
//  BookmarkOutlineView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/8/11.
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
