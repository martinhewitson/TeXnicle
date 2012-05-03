//
//  TPSourceItem.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSourceItem.h"

@implementation TPSourceItem

@synthesize path;
@synthesize parent;

- (id) initWithParent:(TPSourceItem*)aParent path:(NSURL*)aURL
{
  self = [super init];
  if (self) {
    self.path = aURL;
    self.parent = aParent;
  }
  return self;
}

- (void) dealloc
{
  self.path = nil;
  [super dealloc];
}

- (NSString*)name
{
  return [self.path lastPathComponent];
}

@end
