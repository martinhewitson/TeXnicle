//
//  NSString+FileTypes.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "NSString+FileTypes.h"

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
  
  CFStringRef fileExtension = (CFStringRef) self;
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


- (BOOL)isText
{
  // work-around for engine files.
  if ([self isEqualToString:@"engine"]) {
    return YES;
  }
  
  if ([self isEqualToString:@"tex"]) {
    return YES;
  }

  if ([self isEqualToString:@"cls"]) {
    return YES;
  }
  
  if ([self isEqualToString:@"sty"]) {
    return YES;
  }
  
  if ([self isEqualToString:@"bib"]) {
    return YES;
  }
  
//  NSLog(@"Checking ext %@", self);
  
  BOOL fileIsText = NO;
    
  CFStringRef fileExtension = (CFStringRef) self;
  CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
  if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
    fileIsText = YES;
  }  

  CFRelease(fileUTI);
  
  return fileIsText;
  
//  BOOL result =  [[NSWorkspace sharedWorkspace] filenameExtension:self isValidForType:(NSString *)kUTTypeText];  
//  
//  NSLog(@"Result %d", result);
//  
//  return result;
}

@end
