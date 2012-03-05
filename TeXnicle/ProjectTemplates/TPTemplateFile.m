//
//  TPTemplateFile.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPTemplateFile.h"
#import "NSString+FileTypes.h"
#import "MHFileReader.h"

@implementation TPTemplateFile
@synthesize stringContent;
@synthesize dataContent;

- (id) initWithPath:(NSString*)aPath
{
  self = [super initWithPath:aPath];
  if (self) {
    [self readContent];
  }
  return self;
}

- (void) readContent
{
  if ([self.path pathIsText]) {
    MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
    NSString *str = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:self.path]];
    if (str) {
      self.stringContent = str;
    }
  } else if ([self.path pathIsImage]) {
    self.dataContent = [[[NSData alloc] initWithContentsOfFile:self.path] autorelease];
  } else {
    NSLog(@"Unknown file type: this shouldn't happen");
  }  
}

- (void) saveContent
{
  if (self.stringContent) {
    MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
    [fr writeString:self.stringContent toURL:[NSURL fileURLWithPath:self.path]];
  }
}

@end
