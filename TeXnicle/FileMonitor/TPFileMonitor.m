//
//  TPFileMonitor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPFileMonitor.h"
#import "NSDate+GMT.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

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
    NSInteger load = (NSInteger)floor([loadDate timeIntervalSinceReferenceDate]);
    
    NSString *path = [self fileMonitor:self pathOnDiskForFile:file];
//    NSLog(@"Checking %@", path);
    if (path) {
      if (![fm fileExistsAtPath:path]) {
        [self fileMonitor:self 
        fileChangedOnDisk:file 
             modifiedDate:loadDate];
      } else {
        
//        NSDictionary *atts = [fm attributesOfItemAtPath:path error:&error];
//        NSDate *modified = [atts objectForKey:NSFileModificationDate];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSDictionary *vals = [url resourceValuesForKeys:[NSArray arrayWithObjects:NSURLContentModificationDateKey, NSURLContentAccessDateKey, nil] error:&error];
        NSDate *access = [vals valueForKey:NSURLContentAccessDateKey];
        NSDate *modified = [vals valueForKey:NSURLContentModificationDateKey];
        
//        NSString *testpath = @"/Users/hewitson/working/ltp/papers/lpf_amaldi_2011/tex/operations.tex";
//        if ([path isEqualToString:testpath]) {
//          
//          struct stat    buffer;												 // store results of stat
//          
//          stat ([path cStringUsingEncoding:NSASCIIStringEncoding], &buffer);
          // compare the last modified time to the one stored
//          NSLog(@"-------------------------");
//          NSLog(@"  loaded: %@", loadDate);
//          NSLog(@"  stat %ld, load %ld", buffer.st_mtimespec.tv_sec, load);
//          NSLog(@"   modified %@", modified);
//          NSLog(@"   access %@", access);
//          NSLog(@"access greater? %d", [access compare:loadDate]==NSOrderedDescending);
//        }
        
        if ([modified compare:loadDate] == NSOrderedDescending) {
          [self fileMonitor:self fileChangedOnDisk:file modifiedDate:modified];
        } else if ([access compare:loadDate]==NSOrderedDescending) {
//          [self fileMonitor:self fileWasAccessedOnDisk:file accessDate:access];
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

- (void) fileMonitor:(TPFileMonitor*)aMonitor fileWasAccessedOnDisk:(id)file accessDate:(NSDate*)access
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileMonitor:fileWasAccessedOnDisk:accessDate:)]) {
    [self.delegate fileMonitor:self fileWasAccessedOnDisk:file accessDate:access];
  }
}


@end
