//
//  TPTemplateItem.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPTemplateItem.h"

@implementation TPTemplateItem
@synthesize path;
@synthesize isExpanded;

- (id) initWithPath:(NSString*)aPath
{
  self = [super init];
  if (self) {
    self.path = aPath;
    self.isExpanded = NO;
  }
  return self;
}


- (id) representedObject
{
  return self;
}

@end
