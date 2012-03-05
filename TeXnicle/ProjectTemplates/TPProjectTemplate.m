//
//  MHProjectTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 19/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPProjectTemplate.h"

@implementation TPProjectTemplate

@synthesize name;
@synthesize path;
@synthesize isBuiltIn;
@synthesize desc;

- (id) initWithPath:(NSString*)aPath
{
  self = [super init];
  if (self) {
    self.path = aPath;
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[self.path stringByAppendingPathComponent:@"info.plist"]];
    if (info) {
      self.name      = [info valueForKey:@"name"];
      self.desc      = [info valueForKey:@"description"];
      self.isBuiltIn = [[info valueForKey:@"builtin"] boolValue];
    }
  }
  return self;
}

- (NSString*) description
{
  return [NSString stringWithFormat:@"%@, %@", self.name, self.desc];
}

@end
