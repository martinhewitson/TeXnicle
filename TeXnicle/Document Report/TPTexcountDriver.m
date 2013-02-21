//
//  TPTexcountDriver.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/2/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPTexcountDriver.h"

@implementation TPTexcountDriver


- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.delegate = nil;
}

- (id) initWithDelegate:(id<TexcountDriverDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    texcountTask = nil;
    _taskRunning = NO;
  }
  
  return self;
}

- (void) setupObservers
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  [nc addObserver:self
         selector:@selector(taskOutputAvailable:)
             name:NSFileHandleReadCompletionNotification
           object:outputHandle];
  
  [nc addObserver:self
         selector:@selector(taskFinished:)
             name:NSTaskDidTerminateNotification
           object:texcountTask];
  
}


- (void) countWordsInTexFile:(NSString *)path
{    
  if (texcountTask == nil) {
    texcountTask = [[NSTask alloc] init];
    outpipe = [NSPipe pipe];
    inpipe = [NSPipe pipe];
    inputHandle = [inpipe fileHandleForWriting];
    outputHandle = [outpipe fileHandleForReading];
    [texcountTask setStandardOutput:outpipe];
    [texcountTask setStandardError:outpipe];
    [texcountTask setStandardInput:inpipe];
    [self setupObservers];
  }

  
//  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//  NSString *chktexPath = [defaults valueForKey:TPChkTeXpath];
  NSString *texcountPath = [[NSBundle mainBundle] pathForResource:@"texcount" ofType:@""];
  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:texcountPath]) {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(texcountRunFailed:)]) {
      [self.delegate texcountRunFailed:self];
      return;
    }
  }
  
  self.output = @"";  
  
	[texcountTask setLaunchPath:texcountPath];
  [texcountTask setCurrentDirectoryPath:[path stringByDeletingLastPathComponent]];
  
	NSArray *arguments = [NSArray array];
	arguments = [arguments arrayByAddingObject:@"-html"];
//	arguments = [arguments arrayByAddingObject:@"-utf8"];
  
  if ([self texcountShouldGenerateWordFreq:self]) {
    arguments = [arguments arrayByAddingObject:@"-freq"];
  }
  if ([self texcountShouldGenerateStats:self]) {
    arguments = [arguments arrayByAddingObject:@"-stat"];
  }
  if ([self texcountShouldIncludeAllFiles:self]) {
    arguments = [arguments arrayByAddingObject:@"-inc"];
  }
  
  arguments = [arguments arrayByAddingObject:path];
  
	[texcountTask setArguments:arguments];
  
	[outputHandle readInBackgroundAndNotify];
  
	[texcountTask launch];
  
}

- (void) taskFinished:(NSNotification*)aNote
{
  // NSLog(@"Task finished %@", [aNote object]);
	if ([aNote object] != texcountTask)
		return;
	
  // notify interested parties
  [self texcountRunDidFinish:self];
  
  texcountTask = nil;
}


- (void) taskOutputAvailable:(NSNotification*)aNote
{
  //NSLog(@"Output available %@", [aNote object]);
  
	if( [aNote object] != outputHandle )
		return;
	
	NSData *data = [aNote userInfo][NSFileHandleNotificationDataItem];
  //  NSLog(@"Got data %@", data);
  NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  //NSLog(@"Got string %@", string);
	self.output = [self.output stringByAppendingString:string];
  
	if( [data length] > 0) {
		[outputHandle readInBackgroundAndNotify];
  } else {
    //NSLog(@"output: %@", self.output);
    [self texcountRunDidFinish:self];
    texcountTask = nil;
    _taskRunning = NO;
  }
	
}

- (void) texcountRunDidFinish:(TPTexcountDriver*)texcount
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(texcountRunDidFinish:)]) {
    return [self.delegate texcountRunDidFinish:texcount];
  }
}

- (void) texcountRunFailed:(TPTexcountDriver *)texcount
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(texcountRunFailed:)]) {
    return [self.delegate texcountRunFailed:texcount];
  }
}

- (BOOL)texcountShouldGenerateWordFreq:(TPTexcountDriver*)texcount
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(texcountShouldGenerateWordFreq:)]) {
    return [self.delegate texcountShouldGenerateWordFreq:texcount];
  }
  
  return NO;
}

- (BOOL)texcountShouldGenerateStats:(TPTexcountDriver*)texcount
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(texcountShouldGenerateStats:)]) {
    return [self.delegate texcountShouldGenerateStats:texcount];
  }
  
  return NO;
}

- (BOOL)texcountShouldIncludeAllFiles:(TPTexcountDriver*)texcount
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(texcountShouldIncludeAllFiles:)]) {
    return [self.delegate texcountShouldIncludeAllFiles:texcount];
  }
  
  return YES;
}


@end
