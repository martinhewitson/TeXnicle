//
//  BookmarkManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BookmarkManager;

@protocol BookmarkManagerDelegate <NSObject>

@end

@interface BookmarkManager : NSViewController <BookmarkManagerDelegate> {
@private
  id<BookmarkManagerDelegate> delegate;
}

@property (assign) id<BookmarkManagerDelegate> delegate;

- (id)initWithDelegate:(id<BookmarkManagerDelegate>)aDelegate;

@end
