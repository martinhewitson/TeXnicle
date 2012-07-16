//
//  TPFileEntityMetadata.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPMetadataOperation.h"
#import "TPFileEntityMetadata.h"
#import "TPSectionTemplate.h"
#import "TPSection.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "FileEntity.h"
#import "ExternalTeXDoc.h"
#import "NSString+SectionsOutline.h"
#import "RegexKitLite.h"

NSString * const TPFileMetadataSectionsUpdatedNotification = @"TPFileMetadataSectionsUpdatedNotification";

@implementation TPFileEntityMetadata

@synthesize checker;
@synthesize temporaryFileForSyntaxCheck;

@synthesize lastMetadataUpdate;
@synthesize metadataTimer;

@synthesize sections;
@synthesize lastUpdateOfSections;

@synthesize userNewCommands;
@synthesize lastUpdateOfNewCommands;

@synthesize syntaxErrors;
@synthesize citations;
@synthesize labels;
@synthesize includes;
@synthesize parent;

@synthesize aQueue;

- (id) initWithParent:(id)aFile
{
  self = [super init];
  if (self != nil) {
    self.parent = aFile;
    self.lastUpdateOfNewCommands = nil;
    self.lastUpdateOfSections = nil;
    queue = dispatch_queue_create("com.bobsoft.TeXnicle", NULL);
    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
    dispatch_set_target_queue(queue,priority);
        
    self.checker = [[[TPSyntaxChecker alloc] initWithDelegate:self] autorelease];
    
    self.metadataTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateMetadata)
                                                        userInfo:nil
                                                         repeats:YES];
    
    self.aQueue = [[[NSOperationQueue alloc] init] autorelease];
  }
  return self;
}

- (void) stopMetadataTimer
{
  if (self.metadataTimer) {
    [self.metadataTimer invalidate];
    self.metadataTimer = nil;
  }
}

- (void) dealloc
{  
	[self stopMetadataTimer];
  dispatch_release(queue);
  self.checker = nil;
  [self.aQueue cancelAllOperations];
  self.aQueue = nil;
  self.userNewCommands = nil;
  self.lastUpdateOfNewCommands = nil;
  self.sections = nil;
  self.syntaxErrors = nil;
  self.lastUpdateOfSections = nil;
  self.citations = nil;
  self.labels = nil;
  self.includes = nil;
  
  [super dealloc];
}

- (void) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  
  dispatch_async(queue, ^{						
    
    self.sections = [self updateSectionsForTypes:templates forceUpdate:force];
    self.lastUpdateOfSections = [NSDate date];
    
  });
  
  dispatch_sync(queue, ^{						
    // both blocks have completed
  });
  
  dispatch_async(dispatch_get_main_queue(), ^{
    // send notification of section update
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.parent, @"file", self.sections, @"sections", nil];
    [nc postNotificationName:TPFileMetadataSectionsUpdatedNotification
                      object:self
                    userInfo:dict];
  });
  
  
}


- (NSArray*)updateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  // prepare sections found array
  NSArray *sectionsFound = nil;
    
  // get the parent file and the text to search
  id file = self.parent;
  NSString *text = [self.parent text];

  sectionsFound = [text sectionsInStringForTypes:templates existingSections:self.sections inFile:file];
  
  return sectionsFound;
}

#pragma mark -
#pragma mark get new commands

- (NSArray*)listOfNewCommands
{
  return self.userNewCommands;
}


- (void) updateMetadata
{
  NSDate *lastEdit = self.parent.lastEditDate;
  NSDate *lastUpdate = self.lastMetadataUpdate;
  
  if ([lastEdit timeIntervalSinceDate:lastUpdate]>0 || lastUpdate == nil) {    
    if ([self.aQueue operationCount] == 0) {
      TPMetadataOperation *op = [[[TPMetadataOperation alloc] initWithFile:self.parent] autorelease];      
      [op setCompletionBlock:^{        
        [self performSelectorOnMainThread:@selector(notifyOfUpdate:) withObject:op waitUntilDone:NO];
      }];
      
      [self.aQueue addOperation:op];
    }
    
    //-------------- syntax errors
    NSString *path = [NSString pathForTemporaryFileWithPrefix:@"chktek"];
    if ([self.parent.workingContentString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {    
      self.temporaryFileForSyntaxCheck = path;
      [self.checker checkSyntaxOfFileAtPath:self.temporaryFileForSyntaxCheck];
    }

    
  }  
}

- (void) notifyOfUpdate:(TPMetadataOperation*)op
{
  self.userNewCommands = op.commands;
  self.citations = op.citations;
  self.lastMetadataUpdate = [NSDate date];
  
  // send notification of update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.parent, @"file", self.sections, @"sections", nil];
  [nc postNotificationName:TPFileMetadataSectionsUpdatedNotification
                    object:self
                  userInfo:dict];
}

- (void) cleanup
{
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:self.temporaryFileForSyntaxCheck]) {
    [fm removeItemAtPath:self.temporaryFileForSyntaxCheck error:NULL];
  }  
}

- (void)syntaxCheckerCheckFailed:(TPSyntaxChecker*)checker
{
  [self cleanup];
}

- (void)syntaxCheckerCheckDidFinish:(TPSyntaxChecker*)aChecker
{
  [self cleanup];
  self.syntaxErrors = aChecker.errors;
}

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)checker
{
  return YES;
}

@end
