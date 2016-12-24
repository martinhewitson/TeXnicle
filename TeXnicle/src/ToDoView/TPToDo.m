//
//  TPToDo.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPToDo.h"

@implementation TPToDo

+ (id) toDoWithFile:(id)aFile text:(NSString*)aString
{
  return [[TPToDo alloc] initWithFile:aFile text:aString];
}

- (id) initWithFile:(id)aFile text:(NSString*)aString
{
  self = [super init];
  if (self) {
    self.file = aFile;
    self.text = aString;
  }
  return self;
}


- (NSString*)string
{
  return self.text;
}

- (NSString*)sortKey
{
  return @"name";
}

- (id) value
{
  return self.text;
}

@end
