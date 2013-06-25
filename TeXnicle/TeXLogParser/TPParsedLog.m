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

@interface TPParsedLog ()

@property (copy) NSString *logtext;

@end

@implementation TPParsedLog

- (id) initWithLogFileAtPath:(NSString*)aPath
{
  self = [super init];
  if (self) {
    self.logtext = [self stringFromLogFile:aPath];
    self.logfiles = [NSMutableArray array];
    [self generateLogTree];
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
  self.logtext = [self stringFromLogFile:aPath];
  self.logfiles = [NSMutableArray array];
  [self generateLogTree];
}

- (NSString*)stringFromLogFile:(NSString*)path
{
  NSArray *encodings = @[@(NSASCIIStringEncoding),
                         @(NSUTF8StringEncoding),
                         @(NSUTF16StringEncoding),
                         @(NSUTF16LittleEndianStringEncoding),
                         @(NSUTF16BigEndianStringEncoding),
                         @(NSISOLatin1StringEncoding),
                         @(NSISOLatin2StringEncoding),
                         @(NSMacOSRomanStringEncoding),
                         @(NSWindowsCP1251StringEncoding)];
  
  
  NSError *error = nil;
  NSStringEncoding encoding;
  NSString *string = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] usedEncoding:&encoding error:&error];
  if (string == nil) {
    for (NSNumber *enc in encodings) {
      string = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:[enc integerValue] error:NULL];
      if (string != nil) {
        break;
      }
    }
    if (string == nil) {
      NSLog(@"Failed to load %@ [%@]", path, error);
    }
  }
  return string;
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
