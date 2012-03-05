//
//  FolderEntity+ProjectTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "FolderEntity+ProjectTemplate.h"

@implementation FolderEntity (ProjectTemplate)


- (void) writeContentsAndChildrenToURL:(NSURL*)aURL
{
  NSURL *url = [aURL URLByAppendingPathComponent:[self name] isDirectory:YES];
  
  // create directory with this name
  NSError *error = nil;
  NSFileManager *fm = [NSFileManager defaultManager];
  [fm createDirectoryAtURL:url
withIntermediateDirectories:YES
                attributes:nil
                     error:&error];
  if (error) {
    [NSApp presentError:error];
    return;
  }
  
  // process all children
  for (ProjectItemEntity *child in self.children) {
    [child writeContentsAndChildrenToURL:url];
  }
  
}

@end
