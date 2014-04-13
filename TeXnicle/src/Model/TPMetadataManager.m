//
//  TPMetadataManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/3/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPMetadataManager.h"
#import "TPFileMetadata.h"

NSString * const TPFileMetadataSectionsUpdatedNotification = @"TPFileMetadataSectionsUpdatedNotification";
NSString * const TPFileMetadataUpdatedNotification = @"TPFileMetadataUpdatedNotification";
NSString * const TPMetadataManagerDidBeginUpdateNotification = @"TPMetadataManagerDidBeginUpdateNotification";
NSString * const TPMetadataManagerDidEndUpdateNotification = @"TPMetadataManagerDidEndUpdateNotification";

@interface TPMetadataManager ()

@property (strong) NSTimer *timer;
@property (assign) NSInteger updatingCount;

@end

@implementation TPMetadataManager

- (id) initWithDelegate:(id<MetadataManagerDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
  }
  
  return self;
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  self.delegate = nil;
  [self stop];
}

- (void) start
{
  [self stop];
  [self setupTimer];
}

- (void) setupTimer
{
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                              selector:@selector(update)
                                              userInfo:nil
                                               repeats:YES];
  
}


- (void) stop
{
  
#if TEAR_DOWN
  NSLog(@"Stopping metadata timer for %@", self);
#endif
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}


- (void) update
{
  if (_updatingCount > 0 || self.timer == nil || [self.timer isValid] == NO || self.delegate == nil) {
    //NSLog(@"Already updating...[%ld]", _updatingCount);
    return;
  }
  
  //NSLog(@"Metadata Manager update triggered on thread %@", [NSThread currentThread]);
  
  // get list of files from delegate
  NSArray *filesToUpdate = [self metadataManagerFilesToScan:self];
  
  _updatingCount = 0;
  for (TPFileMetadata *f in filesToUpdate) {
    if (f.needsUpdate || f.needsSyntaxCheck) {
      f.delegate = self;
      if (f.needsSyntaxCheck)
        _updatingCount++;
      if (f.needsUpdate)
        _updatingCount++;
      //NSLog(@" +++ count [%ld] (%@)", _updatingCount, f.name);
      [f updateMetadata];
    }
  }
  
  if (_updatingCount > 0) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TPMetadataManagerDidBeginUpdateNotification object:self];
  }
}


#pragma mark -
#pragma mark FileMetadata Delegate

- (void) fileMetadataDidUpdate:(TPFileMetadata *)file
{
  _updatingCount--;
//NSLog(@" --- count [%ld] (%@)", _updatingCount, file.name);

  if (_updatingCount == 0) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TPMetadataManagerDidEndUpdateNotification object:self];
  }
}

#pragma mark -
#pragma mark Delegate

- (NSArray*) metadataManagerFilesToScan:(TPMetadataManager *)manager
{
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(metadataManagerFilesToScan:)]) {
    return [self.delegate performSelector:@selector(metadataManagerFilesToScan:) withObject:self];
  }
  
  return @[];
}

@end
