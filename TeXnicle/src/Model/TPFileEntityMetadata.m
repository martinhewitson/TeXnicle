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
#import "TPSyntaxError.h"
#import "externs.h"
#import "NSNotificationAdditions.h"

NSString * const TPFileMetadataSectionsUpdatedNotification = @"TPFileMetadataSectionsUpdatedNotification";
NSString * const TPFileMetadataUpdatedNotification = @"TPFileMetadataUpdatedNotification";
NSString * const TPFileMetadataWarningsUpdatedNotification = @"TPFileMetadataWarningsUpdatedNotification";

@interface TPFileEntityMetadata ()

@end

@implementation TPFileEntityMetadata

@synthesize aQueue;

- (id) initWithParent:(id)aFile
{
  self = [super init];
  if (self != nil) {
    self.parent = aFile;
    self.lastUpdateOfSections = nil;
    self.needsUpdate = NO;
    self.needsSyntaxCheck = NO;
    
//    queue = dispatch_queue_create("com.bobsoft.TeXnicle", NULL);
//    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
//    dispatch_set_target_queue(queue,priority);
//        
//    self.checker = [[TPSyntaxChecker alloc] initWithDelegate:self];
    
//    self.aQueue = [[NSOperationQueue alloc] init];
//    [self performSelector:@selector(setupMetadataTimer) withObject:nil afterDelay:1.0];
    
//    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
//    
//    [defaults addObserver:self
//               forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]
//                  options:NSKeyValueObservingOptionNew
//                  context:NULL];		
//    
//    [defaults addObserver:self
//               forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]
//                  options:NSKeyValueObservingOptionNew
//                  context:NULL];		
    
    
  }
  return self;
}

- (void) setupMetadataTimer
{
//  self.metadataTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                        target:self
//                                                      selector:@selector(updateMetadata)
//                                                      userInfo:nil
//                                                       repeats:YES];
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]]) {	
    self.needsSyntaxCheck = YES;
  } else if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]]) {
    self.needsSyntaxCheck = YES;
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
//  NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
//  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]];
//  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]];

//  dispatch_release(queue);  
}

- (NSArray*) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  // we have to update all sections for this file because we look for other files included from
  // here, and they might have changed. So, the only case where we don't need to update is if no
  // files have changed. Is that really worth checking?
  
  [self updateSectionsForTypes:templates forceUpdate:force];
  
  return self.sections;
}


- (void)updateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  // get the parent file and the text to search
  FileEntity *file = self.parent;
  
  [file.managedObjectContext lock];
  self.sections = [file.text sectionsInStringForTypes:templates existingSections:self.sections inFile:file];
  [file.managedObjectContext unlock];
  
}

#pragma mark -
#pragma mark get new commands

- (NSArray*)listOfNewCommands
{
  return self.userNewCommands;
}


- (void) updateMetadata
{
//  [self.parent.managedObjectContext lock];
//  BOOL isText = [[self.parent isText] boolValue];
//  [self.parent.managedObjectContext unlock];
//  
//  // in case the file has gone
//  if (self.parent == nil || isText == NO) {
//    return;
//  }
//  
//  if ([[NSApplication sharedApplication] isActive] == NO) {
//    return;
//  }
  
  [self.parent.managedObjectContext lock];
  NSDate *lastEdit = self.parent.lastEditDate;
  [self.parent.managedObjectContext unlock];

  NSDate *lastUpdate = self.lastMetadataUpdate;
  
//  __block TPFileEntityMetadata *blockSelf = self;
//  
//  if ([lastEdit timeIntervalSinceDate:lastUpdate]>0 || lastUpdate == nil || self.needsUpdate) {
//    if ([self.aQueue operationCount] == 0) {
//      currentOperation = [[TPMetadataOperation alloc] initWithFile:self.parent];      
//      [currentOperation setCompletionBlock:^{
//        dispatch_sync(dispatch_get_main_queue(), ^{
//          [blockSelf notifyOfUpdate];
//          blockSelf = nil;
//        });
//      }];
//      
//      [self.aQueue addOperation:currentOperation];
//    }
//    
//    self.lastMetadataUpdate = [NSDate date];
//  }
  
  if ([lastEdit timeIntervalSinceDate:lastUpdate] > 1 || lastUpdate == nil || self.needsSyntaxCheck) {
    //-------------- syntax errors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:TPCheckSyntax] boolValue] == YES) {
      [self.parent.managedObjectContext lock];
      NSString *extension = self.parent.extension;
      [self.parent.managedObjectContext unlock];
      
      if ([extension isEqualToString:@"tex"]) {
        NSString *path = [NSString pathForTemporaryFileWithPrefix:@"chktek"];
        if ([self.parent.workingContentString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
          self.temporaryFileForSyntaxCheck = path;
          [self.checker checkSyntaxOfFileAtPath:self.temporaryFileForSyntaxCheck];
        }
      }
    } else {
      // clear errors
      self.syntaxErrors = @[];
      [self postWarningsUpdateNotification];
    }

    self.needsSyntaxCheck = NO;
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
