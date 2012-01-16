//
//  MHDocumentController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHDocumentController.h"
#import "TPSupportedFilesManager.h"
#import "ExternalTeXDoc.h"

@implementation MHDocumentController

@synthesize appDelegate;

- (id) init
{
  self = [super init];
//  NSLog(@"MHDocumentController init");
  if (self) {
    
  }
  return self;
}

- (void)reopenDocumentForURL:(NSURL *)urlOrNil 
           withContentsOfURL:(NSURL *)contentsURL 
                     display:(BOOL)displayDocument 
           completionHandler:(void (^)(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error))completionHandler
{
  
//  NSLog(@"Reopen doc %@", urlOrNil);
  
  [self.appDelegate setValue:[NSNumber numberWithBool:NO] forKey:@"openStartupScreenAtAppStartup"];
  
  [super reopenDocumentForURL:urlOrNil 
            withContentsOfURL:contentsURL
                      display:displayDocument
            completionHandler:completionHandler];
  
}

- (NSString *)typeForContentsOfURL:(NSURL *)inAbsoluteURL error:(NSError **)outError
{
//  NSLog(@"Getting type for contents of %@", inAbsoluteURL);
  NSString *type = [super typeForContentsOfURL:inAbsoluteURL error:outError];
//  NSLog(@"Got %@", type);
  if (type) 
    return type;
  
  NSString *ext = [inAbsoluteURL pathExtension];
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  if (ext) {
    NSString *type = [sfm typeForExtension:ext];
    if (type) {
//      NSLog(@"Returning %@", type);
      return type;
    }
  }
  
  return nil;
}

- (Class)documentClassForType:(NSString *)documentTypeName
{
//  NSLog(@"Document class for type %@", documentTypeName);
  Class c = [super documentClassForType:documentTypeName];
  
//  NSLog(@"Got %@", c);
  if (c)
    return c;
  
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSString *ext = [sfm extensionForType:documentTypeName];
  if (ext) {
    return [ExternalTeXDoc class];
  }
  
  return nil;
}


- (NSArray *)fileExtensionsFromType:(NSString *)documentTypeName
{  
  NSArray *exts = [super fileExtensionsFromType:documentTypeName];
  if (exts && [exts count]>0) {
    return exts;
  }
  
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSString *ext = [sfm extensionForType:documentTypeName];
  if (ext) {
    return [NSArray arrayWithObject:ext];
  }
  
  return nil;
}

@end
