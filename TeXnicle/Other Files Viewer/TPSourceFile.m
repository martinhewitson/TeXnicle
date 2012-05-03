//
//  TPSourceFile.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSourceFile.h"

@implementation TPSourceFile

+ (TPSourceFile*)fileWithParent:(TPSourceItem*)aParent path:(NSURL*)aPath
{
  return [[[TPSourceFile alloc] initWithParent:aParent path:aPath] autorelease];
}

- (id) initWithParent:(TPSourceItem *)aParent path:(NSURL *)aURL
{
  self = [super initWithParent:aParent path:aURL];
  if (self) {
    
  }
  return self;
}
          
          
@end
