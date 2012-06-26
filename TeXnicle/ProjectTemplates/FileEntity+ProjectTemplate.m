//
//  FileEntity+ProjectTemplate.m
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
  BOOL success;
  NSError *error = nil;
  if ([[self isText] boolValue]) {
    // write file with these contents
    NSString *contents = [self workingContentString];
    [contents writeToURL:url atomically:YES encoding:encoding error:&error];  
  } else if ([self isImage]) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *sourceURL = [NSURL fileURLWithPath:[self pathOnDisk]];
    if ([fm fileExistsAtPath:[url path]]) {
      success = [fm removeItemAtURL:url error:&error];
      if (success) {
        success = [fm copyItemAtURL:sourceURL toURL:url error:&error];
        if (success == NO) {
          [NSApp presentError:error];
        }
      } else {
        [NSApp presentError:error];
      }
    }
  } else {
    // ??
  }
  
}

@end
