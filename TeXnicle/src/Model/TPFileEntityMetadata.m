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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
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
#import "TPSyntaxError.h"
#import "externs.h"
#import "NSNotificationAdditions.h"

NSString * const TPFileMetadataSectionsUpdatedNotification = @"TPFileMetadataSectionsUpdatedNotification";
NSString * const TPFileMetadataUpdatedNotification = @"TPFileMetadataUpdatedNotification";
NSString * const TPFileMetadataWarningsUpdatedNotification = @"TPFileMetadataWarningsUpdatedNotification";

@implementation TPFileEntityMetadata

@synthesize aQueue;

- (id) initWithParent:(id)aFile
{
  self = [super init];
  if (self != nil) {
    self.parent = aFile;
    self.lastUpdateOfSections = nil;
    self.needsUpdate = NO;
    
    
    queue = dispatch_queue_create("com.bobsoft.TeXnicle", NULL);
    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
    dispatch_set_target_queue(queue,priority);
        
    self.checker = [[TPSyntaxChecker alloc] initWithDelegate:self];
    
    self.metadataTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateMetadata)
                                                        userInfo:nil
                                                         repeats:YES];
    
    self.aQueue = [[NSOperationQueue alloc] init];
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [defaults addObserver:self
               forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]
                  options:NSKeyValueObservingOptionNew
                  context:NULL];		
    
    [defaults addObserver:self
               forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]
                  options:NSKeyValueObservingOptionNew
                  context:NULL];		
    
    
  }
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]]) {	
    self.needsUpdate = YES;
  }
	if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]]) {	
    self.needsUpdate = YES;
  }
}

- (void) stopMetadataTimer
{  
//  NSLog(@"Stopping metadata timer for %@", self);
  if (self.metadataTimer) {
    [self.aQueue cancelAllOperations];
    self.aQueue = nil;
    [self.metadataTimer invalidate];
    self.metadataTimer = nil;
  }
}

- (void) dealloc
{  
//  NSLog(@"Dealloc metadata %@", self);
  NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]];

  dispatch_release(queue);
  
  
  
  
  
  
  
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
    if (self.parent != nil && self.sections != nil) {
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      NSDictionary *dict = @{@"file": self.parent, @"sections": self.sections};
      
      [nc postNotificationName:TPFileMetadataSectionsUpdatedNotification
                        object:self
                      userInfo:dict];
    }
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
  // in case the file has gone
  if (self.parent == nil) {
    return;
  }
  
  NSDate *lastEdit = self.parent.lastEditDate;
  NSDate *lastUpdate = self.lastMetadataUpdate;
  __block TPFileEntityMetadata *blockSelf = self;
  
  if ([lastEdit timeIntervalSinceDate:lastUpdate]>0 || lastUpdate == nil || self.needsUpdate) {    
    if ([self.aQueue operationCount] == 0) {
      currentOperation = [[TPMetadataOperation alloc] initWithFile:self.parent];      
      [currentOperation setCompletionBlock:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
          [blockSelf notifyOfUpdate];
          blockSelf = nil;
        });
      }];
      
      [self.aQueue addOperation:currentOperation];
    }
    
    //-------------- syntax errors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    if ([[defaults valueForKey:TPCheckSyntax] boolValue]) {
      if ([self.parent.extension isEqualToString:@"tex"]) {
        NSString *path = [NSString pathForTemporaryFileWithPrefix:@"chktek"];
        if ([self.parent.workingContentString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {    
          self.temporaryFileForSyntaxCheck = path;
          [self.checker checkSyntaxOfFileAtPath:self.temporaryFileForSyntaxCheck];
        }
      } 
    } else {
      // clear errors
      self.syntaxErrors = @[];
      [self postUpdateNotification];
    }
    self.lastMetadataUpdate = [NSDate date];
  }  
}

- (void) notifyOfUpdate
{
  if (self && currentOperation) {
    self.needsUpdate = NO;
    self.userNewCommands = currentOperation.commands;
    self.citations = currentOperation.citations;
    self.labels = currentOperation.labels;
    self.lastMetadataUpdate = [NSDate date];    
    [self postUpdateNotification];
  }
}

- (void) postUpdateNotification
{
  // send notification of update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:TPFileMetadataUpdatedNotification object:self];
}

- (void) postWarningsUpdateNotification
{
  // send notification of update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:TPFileMetadataWarningsUpdatedNotification object:self];
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
  for (TPSyntaxError *error in self.syntaxErrors) {
    error.file = self.parent; 
  }
  [self postWarningsUpdateNotification];
}

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)checker
{
  return YES;
}

@end
