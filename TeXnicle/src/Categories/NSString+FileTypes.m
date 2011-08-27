//
//  NSString+FileTypes.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "NSString+FileTypes.h"

@implementation NSString (FileTypes)

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
  
  CFRelease(fileUTI);
  
  return fileIsImage;  
}


- (BOOL)isText
{
  BOOL fileIsText = NO;
  
  CFStringRef fileExtension = (CFStringRef) self;
  CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
  
  if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
    fileIsText = YES;
  }
    
  CFRelease(fileUTI);
  
  return fileIsText;  
}

@end
