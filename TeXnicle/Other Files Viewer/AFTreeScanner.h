//
//  AFDirscanManager.h
//  AllAboutFiles
//
//  Created by Martin Hewitson on 30/01/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TPSourceDirectory;
@class TPSourceFile;

@interface AFTreeScanner : NSObject {
	NSMutableArray *trees;
  NSMutableArray *processing;
  NSMutableArray *failures;
	dispatch_queue_t queue;
  dispatch_semaphore_t treesLock;
  dispatch_semaphore_t processLock;
	dispatch_group_t group;
	NSOperationQueue *treeScannerQueue;
	NSOperationQueue *treeScannerCompleteQueue;
  NSDate *lastPost;
  NSUInteger queueJobs;
	BOOL valid;
  NSTimer *processTimer;
  NSTimer *queueWatcher;
}
+ (AFTreeScanner*)sharedScanner;

@property (nonatomic, strong) NSMutableArray *failures;
@property (nonatomic, strong) NSTimer * queueWatcher;
@property (nonatomic, strong) NSTimer * processTimer;
@property (nonatomic, assign) NSUInteger queueJobs;
@property (nonatomic, strong) NSMutableArray *trees;
@property (nonatomic, strong) NSMutableArray *processing;
@property (nonatomic, strong) NSDate *lastPost;

- (void) scanTree:(TPSourceDirectory*)aTree;
- (void) clearQueue;
- (void) reset;
- (void) postNotificationsForTree:(TPSourceDirectory*)aTree;

- (void) queueTree:(TPSourceDirectory*)aTree;
- (void) processQueue;
- (void) queueWatcherTrigger;

@end
