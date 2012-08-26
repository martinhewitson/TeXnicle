//
//  NSString+FileTypes.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import "NSString+FileTypes.h"
#import "NSArray+LaTeX.h"
#import "TPSupportedFilesManager.h"

@implementation NSString (FileTypes)

- (BOOL) pathIsText
{
  return [[self pathExtension] isText];
}

- (BOOL)pathIsImage
{
  return [[self pathExtension] isImage];
}

- (BOOL)isImage
{
  BOOL fileIsImage = NO;
  
  CFStringRef fileExtension = (__bridge CFStringRef) self;
  CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
  if (UTTypeConformsTo(fileUTI, kUTTypeImage) 
      || UTTypeConformsTo(fileUTI, kUTTypePDF)
      || UTTypeConformsTo(fileUTI, kUTTypeBMP)
      || UTTypeConformsTo(fileUTI, kUTTypeGIF)
      || UTTypeConformsTo(fileUTI, kUTTypeJPEG)
      || UTTypeConformsTo(fileUTI, kUTTypeJPEG2000)
      || UTTypeConformsTo(fileUTI, kUTTypePNG)
      || UTTypeConformsTo(fileUTI, kUTTypeTIFF)
      || UTTypeConformsTo(fileUTI, (CFStringRef)@"com.adobe.postscript")
      || UTTypeConformsTo(fileUTI, (CFStringRef)@"com.adobe.encapsulated-postscript")
      ) {
    fileIsImage = YES;
  }
  
  CFArrayRef  supportedTypes = CGImageSourceCopyTypeIdentifiers();
  CFIndex		i, typeCount = CFArrayGetCount(supportedTypes);
  
  for (i = 0; i < typeCount; i++) {
    if (UTTypeConformsTo(fileUTI, (CFStringRef)CFArrayGetValueAtIndex(supportedTypes, i))) {
      fileIsImage = YES;
      break;
    }
  }
  
  CFRelease(supportedTypes);
  CFRelease(fileUTI);
  
  return fileIsImage;  
}

// checks the file extension is text
- (BOOL)isText
{
  NSString *extension = self;
  if ([[extension pathExtension] length] > 0) {
    extension = [extension pathExtension];
  }
  
//  NSLog(@"Checking if %@ is text", extension);
  // work-around for engine files.
  if ([extension isEqualToString:@"engine"]) {
    return YES;
  }
  
  // ensure images are not interpreted as text files.
  if ([extension isImage]) {
//    NSLog(@"Is image");
    return NO;
  }
  
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
//  NSLog(@"Is supported type?");
  for (NSString *lext in [sfm supportedExtensions]) {
//    NSLog(@" checking [%@]", lext);
    if ([extension isEqualToString:lext]) {
//      NSLog(@"    yes - %@", lext);
      return YES;
    }
  }
//  NSLog(@"   no :( ");
  
//  NSLog(@"Checking valid for type [%@]", kUTTypeText);
  BOOL result =  [[NSWorkspace sharedWorkspace] filenameExtension:extension isValidForType:(NSString *)kUTTypeText];
  
//  NSLog(@"Result %d", result);
  
  return result;
}

@end
