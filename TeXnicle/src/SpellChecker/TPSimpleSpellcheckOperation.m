//
//  TPSimpleSpellcheckOperation.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSimpleSpellcheckOperation.h"
#import "NSString+Spelling.h"

@implementation TPSimpleSpellcheckOperation

@synthesize text;
@synthesize words;

- (id) initWithText:(NSString *)aString
{
  self = [super init];
  if (self) {
    self.text = aString;
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
    
    self.words = [self.text listOfMisspelledWords];
        
    [pool release];
  }
  @catch(...) {
    // Do not rethrow exceptions.
  }
}



@end
