//
//  TPSourceDirectory.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSourceItem.h"

@class TPSourceDirectory;

@protocol TPSourceDirectoryDelegate <NSObject>

- (BOOL) sourceDirectory:(TPSourceDirectory*)aDirectory shouldIncludeChildItemAtPath:(NSURL*)url;

@end

@interface TPSourceDirectory : TPSourceItem <TPSourceDirectoryDelegate> {
@private
  NSArray *children;
	BOOL didPopulate;
  id<TPSourceDirectoryDelegate> __unsafe_unretained delegate;
}

@property (strong) NSArray *children;
@property (assign) BOOL didPopulate;
@property (unsafe_unretained) id<TPSourceDirectoryDelegate> delegate;

+ (TPSourceDirectory*)directoryWithParent:(TPSourceItem *)aParent path:(NSURL *)aURL delegate:(id<TPSourceDirectoryDelegate>)aDelegate;
- (id)initWithParent:(TPSourceItem *)aParent path:(NSURL *)aURL delegate:(id<TPSourceDirectoryDelegate>)aDelegate;

- (void) populateChildren;


@end
