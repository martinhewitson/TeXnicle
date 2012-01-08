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
  NSString *ext = [inAbsoluteURL pathExtension];
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  if (ext) {
    NSString *type = [sfm typeForExtension:ext];
    if (type) {
      return type;
    }
  }
  
  return [super typeForContentsOfURL:inAbsoluteURL error:outError];
}

- (Class)documentClassForType:(NSString *)documentTypeName
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSString *ext = [sfm extensionForType:documentTypeName];
  if (ext) {
    return [ExternalTeXDoc class];
  }
  
  return [super documentClassForType:documentTypeName];
}

- (NSArray *)fileExtensionsFromType:(NSString *)documentTypeName
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSString *ext = [sfm extensionForType:documentTypeName];
  if (ext) {
    return [NSArray arrayWithObject:ext];
  }
  
  return [super fileExtensionsFromType:documentTypeName];
}

@end
