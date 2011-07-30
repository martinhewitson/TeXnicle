//
//  TPFileMonitor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPFileMonitor.h"

#define kFileCheckInterval 1.0

@implementation TPFileMonitor

@synthesize timer;
@synthesize delegate;

+ (TPFileMonitor*)monitorWithDelegate:(id<TPFileMonitorDelegate>)aDelegate
{
  return [[[TPFileMonitor alloc] initWithDelegate:aDelegate] autorelease];
}

- (id)initWithDelegate:(id<TPFileMonitorDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kFileCheckInterval
                                                  target:self
                                                selector:@selector(checkFilesTimerFired:)
                                                userInfo:nil
                                                 repeats:YES];
  }
  
  return self;
}

- (void) dealloc
{
  [self.timer invalidate];
  self.timer = nil;
  [super dealloc];
}

- (void)checkFilesTimerFired:(NSTimer*)theTimer
{
  NSArray *files = [self fileMonitorFileList:self]; 
//  NSLog(@"Checking files %@", files);
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  
  for (id file in files) {
    NSDate *loadDate = [file valueForKey:@"fileLoadDate"];
    NSString *path = [self fileMonitor:self pathOnDiskForFile:file];
    if (path) {
      if (![fm fileExistsAtPath:path]) {
        [self fileMonitor:self 
        fileChangedOnDisk:file 
             modifiedDate:loadDate];
      } else {
        //NSLog(@"Checking %@", path);
        //NSLog(@"  loaded: %@", loadDate);
        
        NSDictionary *atts = [fm attributesOfItemAtPath:path error:&error];
        NSDate *modified = [atts objectForKey:NSFileModificationDate];
        //NSLog(@"   modified %@", modified);
        if ([modified compare:loadDate] == NSOrderedDescending) {
          [self fileMonitor:self fileChangedOnDisk:file modifiedDate:modified];
        }
      }
    }    
  }  
}

#pragma mark -
#pragma File Monitor Delegate

- (NSString*)fileMonitor:(TPFileMonitor*)aMonitor pathOnDiskForFile:(id)file
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileMonitor:pathOnDiskForFile:)]) {
    return [self.delegate fileMonitor:self pathOnDiskForFile:file];
  }
  return nil;
}

- (NSArray*) fileMonitorFileList:(TPFileMonitor*)aMonitor
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileMonitorFileList:)]) {
    return [self.delegate fileMonitorFileList:self];
  }
  return [NSArray array];
}

- (void) fileMonitor:(TPFileMonitor*)aMonitor fileChangedOnDisk:(id)file modifiedDate:(NSDate*)modified
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileMonitor:fileChangedOnDisk:modifiedDate:)]) {
    [self.delegate fileMonitor:self fileChangedOnDisk:file modifiedDate:modified];
  }
}




@end
