//
//  TPSpellCheckFileOperation.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSpellCheckFileOperation.h"
#import "FileEntity.h"
#import "NSString+Spelling.h"

@implementation TPSpellCheckFileOperation

@synthesize file;
@synthesize words;

- (id) initWithFile:(TPSpellCheckedFile *)aFile
{
  self = [super init];
  if (self) {
    self.file = aFile;
  }
  return self;
}

- (void) dealloc
{
  self.words = nil;
  [super dealloc];
}


-(void)main {
  @try {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    self.words = [[self.file.file workingContentString] listOfMisspelledWords];
    
    [pool release];
  }
  @catch(...) {
    // Do not rethrow exceptions.
  }
}

@end
