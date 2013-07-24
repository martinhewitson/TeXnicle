//
//  TPFileMonitor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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

#import "TPFileMonitor.h"
#import "NSDate+GMT.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define kFileCheckInterval 1.0

@interface TPFileMonitor ()

@property (strong) NSTimer *timer;

@end

@implementation TPFileMonitor

@synthesize timer;
@synthesize delegate;

+ (TPFileMonitor*)monitorWithDelegate:(id<TPFileMonitorDelegate>)aDelegate
{
  return [[TPFileMonitor alloc] initWithDelegate:aDelegate];
}

- (id)initWithDelegate:(id<TPFileMonitorDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkFiles:)
                                                 name:NSApplicationDidBecomeActiveNotification
                                               object:nil];
    
  }
  
  return self;
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  self.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) stopTimer
{
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}

- (void)checkFiles:(NSNotification*)aNote
{
  
  NSArray *files = [self fileMonitorFileList:self];
  //  NSLog(@"Checking files %@", files);
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  
  for (id file in files) {
    NSDate *loadDate = [file valueForKey:@"fileLoadDate"];
    //    NSInteger load = (NSInteger)floor([loadDate timeIntervalSinceReferenceDate]);
    
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
        NSDictionary *vals = [url resourceValuesForKeys:@[NSURLContentModificationDateKey, NSURLContentAccessDateKey] error:&error];
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
  return @[];
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
