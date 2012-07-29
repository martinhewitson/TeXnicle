//
//  TPTemplateDirectory.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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


- (void) populateChildren
{
  NSMutableArray *childArray = [NSMutableArray array];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *contents = [fm contentsOfDirectoryAtPath:self.path error:&error];
  if (contents == nil) {
    [NSApp presentError:error];
    return;
  }
  
  for (NSString *file in contents) {
    
    // subpath to file or directory
    NSString *subpath = [self.path stringByAppendingPathComponent:file];
    
    error = nil;
    NSDictionary *atts = [fm attributesOfItemAtPath:subpath error:&error];
    if (atts == nil) {
      [NSApp presentError:error];
      continue;
    }    
    
    // if directory
    if ([[atts valueForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
      TPTemplateDirectory *subdir = [[TPTemplateDirectory alloc] initWithPath:subpath];
      [childArray addObject:subdir];
    } else {
      // add file
      TPTemplateFile *newfile = [[TPTemplateFile alloc] initWithPath:subpath];
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
