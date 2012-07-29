//
//  TPSourceItem.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSourceItem : NSObject {
@private
  NSURL *path;
  TPSourceItem *__unsafe_unretained parent;
}

@property (strong) NSURL *path;
@property (unsafe_unretained, readonly) NSString *name;
@property (unsafe_unretained) TPSourceItem *parent;

- (id) initWithParent:(TPSourceItem*)aParent path:(NSURL*)aURL;

@end
