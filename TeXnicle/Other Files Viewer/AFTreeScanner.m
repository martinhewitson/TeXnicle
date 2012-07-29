//
//  AFDirscanManager.m
//  AllAboutFiles
//
//  Created by Martin Hewitson on 30/01/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "AFTreeScanner.h"
#import "TPSourceDirectory.h"
#import "TPSourceFile.h"
#import "externs.h"

#define kMaxBlocks 100
#define kMinUpdateInterval 0.2
#define kProcessTimerInterval 0.05
#define kQueueWatcherInterval 0.5

@implementation AFTreeScanner

@synthesize trees;
@synthesize lastPost;
@synthesize queueJobs;
@synthesize queueWatcher;
@synthesize processTimer;
@synthesize processing;
@synthesize failures;

static AFTreeScanner *sharedScanner = nil;


- (id)init
{
  self = [super init];
  if (self) {
    self.trees = [NSMutableArray array];
    self.processing = [NSMutableArray array];
    self.failures = [NSMutableArray array];
    queue = dispatch_queue_create("com.bobsoft.TeXnicleScanQueue", NULL);
    dispatch_queue_t high = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);    
    dispatch_set_target_queue(queue,high);
    
    treesLock = dispatch_semaphore_create(1);
    processLock = dispatch_semaphore_create(1);
		
    treeScannerQueue = [[NSOperationQueue alloc] init];
    [treeScannerQueue setName:@"TreeScannerQueue"];
    [treeScannerQueue setMaxConcurrentOperationCount:10]; // limit width
		
    treeScannerCompleteQueue = [[NSOperationQueue alloc] init];
    [treeScannerCompleteQueue setName:@"treeScannerCompleteQueue"];
    [treeScannerCompleteQueue setMaxConcurrentOperationCount:10]; // limit width
		
    valid = YES;
		
    self.queueJobs = 0;

    self.queueWatcher = [NSTimer scheduledTimerWithTimeInterval:kQueueWatcherInterval target:self selector:@selector(queueWatcherTrigger) userInfo:nil repeats:YES];
    
	}
	return self;
}

- (void) dealloc
{
  valid = NO;
	dispatch_release(queue);
  dispatch_release(treesLock);
  dispatch_release(processLock);
  
  [self.queueWatcher invalidate];
  
  [self.processTimer invalidate];
}


+ (AFTreeScanner*)sharedScanner
{
  static AFTreeScanner *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[AFTreeScanner alloc] init];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}


#pragma mark -
#pragma mark control 

- (void) clearQueue
{	
	valid = NO;
}

- (void) reset
{
	valid = YES;	
  [self.failures removeAllObjects];
	[self.trees removeAllObjects];
  [self.processing removeAllObjects];
  self.processTimer = [NSTimer scheduledTimerWithTimeInterval:kProcessTimerInterval target:self selector:@selector(processQueue) userInfo:nil repeats:YES];
}

- (void) scanTree:(TPSourceDirectory*)aTree
{
  if (!valid) {
    return;
  }
}

- (void) queueTree:(TPSourceDirectory*)aTree
{
//  NSLog(@"Queing %@", aTree);
  dispatch_semaphore_wait(treesLock, DISPATCH_TIME_FOREVER);
  [trees insertObject:aTree atIndex:0];
  dispatch_semaphore_signal(treesLock);
}

- (void) processQueue
{
  if ([trees count]==0){
    return;
  }
  
  if ([processing count]>=kMaxBlocks) {
    return;
  }
    
//  NSLog(@"Processing queue [%lu][%lu]...", [trees count], [processing count]);
  
  int count = 0;
  while (count < kMaxBlocks && [processing count]<kMaxBlocks && [trees count]>0) {
        
    if (!valid) 
      return;
    
    TPSourceDirectory *nextTree = [trees lastObject];
    dispatch_semaphore_wait(treesLock, DISPATCH_TIME_FOREVER);
    [trees removeLastObject];
//    [trees removeObject:nextTree];
    dispatch_semaphore_signal(treesLock);
    
    if (nextTree) {
      dispatch_semaphore_wait(processLock, DISPATCH_TIME_FOREVER);
      [processing addObject:nextTree];
      dispatch_semaphore_signal(processLock);
      
      dispatch_async(queue, ^{						
        if (valid) {
          @autoreleasepool {          
            NSError *error = nil;
            [nextTree populateChildren];
            if (error) {
//            NSLog(@"Failed to scan %@", nextTree);
              [self.failures addObject:nextTree];            
              dispatch_semaphore_wait(processLock, DISPATCH_TIME_FOREVER);
              [processing removeObject:nextTree];
              dispatch_semaphore_signal(processLock);
            } else {
              nextTree.didPopulate = YES;
              dispatch_semaphore_wait(processLock, DISPATCH_TIME_FOREVER);
              [processing removeObject:nextTree];
              dispatch_semaphore_signal(processLock);
              
              
              if (lastPost) {		
                NSDate *now = [NSDate date];
                NSTimeInterval ti = [now timeIntervalSinceDate:lastPost];
                if (ti > kMinUpdateInterval) {    
                  dispatch_async(dispatch_get_main_queue(),
                                // block
                                ^{
                                  if (valid) {
                                    [self postNotificationsForTree:nextTree];
                                  }
                                });
                  self.lastPost = now;
                }
                
              } else {
                [self postNotificationsForTree:nextTree];
                self.lastPost = [NSDate date];
              }
              
              if ([trees count]==0) {
                dispatch_async(dispatch_get_main_queue(),
                              // block
                              ^{
                                if (valid) {
//                                [[NSNotificationCenter defaultCenter] postNotificationName:AFTreeScannerQueueEmptiedNotification
//                                                                                    object:self
//                                                                                  userInfo:NULL];																		 
                                }
                              }
                              );      
                
              } // end tree count == 0
            } // end if no error
          }      
        } // end if valid
      });
      
    }
    
    count++;
  } // end while loop
}

- (void) queueWatcherTrigger
{
  // if we are here and both queues are empty, we can notify
  if (valid && [self.processing count]==0 && [self.trees count]==0) {
    [self.processTimer invalidate];
//    [[NSNotificationCenter defaultCenter] postNotificationName:AFTreeScannerQueueEmptiedNotification
//                                                        object:self
//                                                      userInfo:NULL];																		 
    valid = NO;
  }
}


- (void) postNotificationsForTree:(TPSourceDirectory*)aTree 
{
  
//  [[NSNotificationCenter defaultCenter] postNotificationName:AFTreeScannerTreeScannedNotification
//                                                      object:aTree
//                                                    userInfo:NULL];
}

@end
