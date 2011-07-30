//
//  MHFoldingTag.m
//  TeXEditor
//
//  Created by Martin Hewitson on 07/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHFoldingTag.h"


@implementation MHFoldingTag

@synthesize tag;
@synthesize index;
@synthesize lineNumber;
@synthesize isStartTag;

+ (MHFoldingTag*) tagWithStartTag:(MHFoldingTagDescription*)aTag index:(NSInteger)anIndex lineNumber:(NSInteger)aLineNumber isStartTag:(BOOL)result
{
  return [[[MHFoldingTag alloc] initWithStartTag:aTag index:anIndex lineNumber:aLineNumber isStartTag:result] autorelease];
}

- (id) initWithStartTag:(MHFoldingTagDescription*)aTag index:(NSInteger)anIndex lineNumber:(NSInteger)aLineNumber isStartTag:(BOOL)result
{
  self = [super init];
  if (self) {
    self.tag = aTag;
    self.index = anIndex;
    self.lineNumber = aLineNumber;
    self.isStartTag = result;
  }
  
  return self;
}

- (void)dealloc
{
  self.tag = nil;
  [super dealloc];
}

- (NSString*) description
{
  if (self.isStartTag) {
    return [NSString stringWithFormat:@"%ld, %ld: %@, isStartTag=%d", self.lineNumber, self.index, self.tag.startTag, self.isStartTag];
  } else {
    return [NSString stringWithFormat:@"%ld, %ld: %@, isStartTag=%d", self.lineNumber, self.index, self.tag.endTag, self.isStartTag];
  }
}

@end
