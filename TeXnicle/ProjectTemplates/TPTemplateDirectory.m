//
//  TPTemplateDirectory.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPTemplateDirectory.h"
#import "TPTemplateFile.h"

@implementation TPTemplateDirectory


@synthesize children;

- (id) initWithPath:(NSString*)aPath
{
  self = [super initWithPath:aPath];
  if (self) {
    [self populateChildren];
  }
  return self;
}

- (void) dealloc
{
  self.children = nil;
  [super dealloc];
}

- (void) populateChildren
{
  NSMutableArray *childArray = [NSMutableArray array];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *contents = [fm contentsOfDirectoryAtPath:self.path error:&error];
  if (error) {
    [NSApp presentError:error];
    return;
  }
  
  for (NSString *file in contents) {
    
    // subpath to file or directory
    NSString *subpath = [self.path stringByAppendingPathComponent:file];
    
    error = nil;
    NSDictionary *atts = [fm attributesOfItemAtPath:subpath error:&error];
    if (error) {
      [NSApp presentError:error];
      continue;
    }    
    
    // if directory
    if ([[atts valueForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
      TPTemplateDirectory *subdir = [[[TPTemplateDirectory alloc] initWithPath:subpath] autorelease];
      [childArray addObject:subdir];
    } else {
      // add file
      TPTemplateFile *newfile = [[[TPTemplateFile alloc] initWithPath:subpath] autorelease];
      [childArray addObject:newfile];
    }
    
  }  
  
  self.children = childArray;
}

- (void) saveContents
{
  // save all files
  for (TPTemplateItem *item in self.children) {
    if ([item isMemberOfClass:[TPTemplateFile class]]) {
      [(TPTemplateFile*)item saveContent];
    } else if ([item isMemberOfClass:[TPTemplateDirectory class]]) {
      [(TPTemplateDirectory*)item saveContents];
    }
  }
}

@end
