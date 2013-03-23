//
//  TPFileMetaData.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/3/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPFileMetadata.h"
#import "TPMetadataOperation.h"
#import "externs.h"

@implementation TPFileMetadata

- (id) initWithParentId:(NSManagedObjectID*)objId extension:(NSString*)ext text:(NSString*)text path:(NSString*)pathOnDisk name:(NSString*)aName
{
  self = [super init];
  if (self) {
    self.objId = objId;
    self.extension = ext;
    self.text = text;
    self.pathOnDisk = pathOnDisk;
    self.aQueue = [[NSOperationQueue alloc] init];
    self.name = aName;
  }
  
  return self;
}

- (void) notifyOfUpdate
{
  if (self && self.currentOperation) {
    self.needsUpdate = NO;
    self.lastUpdate = [NSDate date];
    self.userNewCommands = self.currentOperation.commands;
    self.citations = self.currentOperation.citations;
    self.labels = self.currentOperation.labels;
    
    [self fileMetadataDidUpdate:self];
    
    [self postUpdateNotification];
  }
}

- (void) postUpdateNotification
{
  // send notification of update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:TPFileMetadataUpdatedNotification object:self];
}

- (void) updateMetadata
{
  __block TPFileMetadata *blockSelf = self;
  
  if (self.needsUpdate) {
    if ([self.aQueue operationCount] == 0) {
      self.currentOperation = [[TPMetadataOperation alloc] initWithFile:self];
      [self.currentOperation setCompletionBlock:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
          [blockSelf notifyOfUpdate];
          blockSelf = nil;
        });
      }];
      
      [self.aQueue addOperation:self.currentOperation];
    }
  }  
}

- (void) fileMetadataDidUpdate:(TPFileMetadata *)file
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileMetadataDidUpdate:)]) {
    [self.delegate fileMetadataDidUpdate:self];
  }
}

@end
