//
//  TPParsedLog.m
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPParsedLog.h"
#import "TPTexLogParser.h"
#import "TPLogFileItem.h"
#import "TPLogItem.h"
#import "MHFileReader.h"

@interface TPParsedLog ()

@property (copy) NSString *logtext;

@end

@implementation TPParsedLog

- (id) initWithLogFileAtPath:(NSString*)aPath
{
  self = [super init];
  if (self) {
    self.logfiles = [NSMutableArray array];
    [self setLogFile:aPath];
  }
  return self;
}

- (id) initWithLogFileAtURL:(NSURL*)aURL
{
  self = [self initWithLogFileAtPath:[aURL path]];
  if (self) {
  }
  return self;
}

- (void) setLogFile:(NSString*)aPath
{
  MHFileReader *fr = [[MHFileReader alloc] init];
  self.logtext = [fr silentlyReadStringFromFileAtURL:[NSURL fileURLWithPath:aPath]];
  [self generateLogTree];
}


- (TPLogFileItem*)logfileForItem:(TPLogItem*)item
{
  for (TPLogFileItem *logfile in self.logfiles) {
    if ([logfile.fullpath isEqualToString:item.filepath]) {
      return logfile;
    }
  }
  
  return nil;
}

- (void) generateLogTree
{
  NSArray *items = [TPTeXLogParser parseLogText:self.logtext];
 
  for (TPLogItem *item in items) {
    TPLogFileItem *logfile = [self logfileForItem:item];
    if (logfile == nil) {
      logfile = [[TPLogFileItem alloc] initWithLogItem:item];
      [self.logfiles addObject:logfile];
    } else {
      [logfile addLogItem:item];
    }
  }  
}


@end
