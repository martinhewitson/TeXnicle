//
//  FileEntity+ProjectTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "FileEntity+ProjectTemplate.h"
#import "MHFileReader.h"

@implementation FileEntity (ProjectTemplate)

- (void) writeContentsAndChildrenToURL:(NSURL*)aURL
{
  NSURL *url = [aURL URLByAppendingPathComponent:[self shortName] isDirectory:YES];
  
  
  // get the encoding of this file
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  NSStringEncoding encoding = [fr encodingForFileAtPath:[self pathOnDisk]]; 
  
  // write contents
  NSError *error = nil;
  if ([[self isText] boolValue]) {
    // write file with these contents
    NSString *contents = [self workingContentString];
    [contents writeToURL:url atomically:YES encoding:encoding error:&error];  
  } else if ([self isImage]) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *sourceURL = [NSURL fileURLWithPath:[self pathOnDisk]];
    if ([fm fileExistsAtPath:[url path]]) {
      [fm removeItemAtURL:url error:&error];
    }
    if (error == nil) {
      [fm copyItemAtURL:sourceURL toURL:url error:&error];
    }
  } else {
    // ??
  }
  
  if (error) {
    [NSApp presentError:error];
  }
}

@end
