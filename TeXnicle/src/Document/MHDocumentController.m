//
//  MHDocumentController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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
