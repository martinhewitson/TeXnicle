//
//  MHDocumentController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHDocumentController.h"

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

@end
