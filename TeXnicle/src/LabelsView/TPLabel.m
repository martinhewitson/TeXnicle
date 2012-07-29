//
//  TPLabel.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPLabel.h"

@implementation TPLabel

@synthesize text;
@synthesize file;

+ (id) labelWithFile:(id)aFile text:(NSString*)aString
{
  return [[TPLabel alloc] initWithFile:aFile text:aString];
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

@end
