//
//  TPFileMonitor.h
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

// Monitor a set of files. 
// 1) Get the list of files from the delegate. 
// 2) Check the fileLoadDate of each file against the modified time on disk
//    Check the originalContents against the current contents?
// 3) If the modified time is newer, tell the delegate

#import <Foundation/Foundation.h>

@class TPFileMonitor;

@protocol TPFileMonitorDelegate <NSObject>

- (NSArray*) fileMonitorFileList:(TPFileMonitor*)aMonitor;
- (void) fileMonitor:(TPFileMonitor*)aMonitor fileChangedOnDisk:(id)file modifiedDate:(NSDate*)modified;
- (NSString*)fileMonitor:(TPFileMonitor*)aMonitor pathOnDiskForFile:(id)file;

@end

@interface TPFileMonitor : NSObject <TPFileMonitorDelegate> {
@private
  NSTimer *timer;
  id<TPFileMonitorDelegate> delegate;
}

@property (retain) NSTimer *timer;
@property (assign) id<TPFileMonitorDelegate> delegate;

- (id)initWithDelegate:(id<TPFileMonitorDelegate>)aDelegate;
+ (TPFileMonitor*)monitorWithDelegate:(id<TPFileMonitorDelegate>)aDelegate;

- (void)checkFilesTimerFired:(NSTimer*)theTimer;

@end
