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
  TPSourceItem *parent;
}

@property (retain) NSURL *path;
@property (readonly) NSString *name;
@property (assign) TPSourceItem *parent;

- (id) initWithParent:(TPSourceItem*)aParent path:(NSURL*)aURL;

@end
