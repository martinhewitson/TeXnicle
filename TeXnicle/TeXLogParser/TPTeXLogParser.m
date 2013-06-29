//
//  TPTeXLogParser.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPTeXLogParser.h"
#import "NSString+Comparisons.h"
#import "TPLogItem.h"
#import "RegexKitLite.h"
#import "NSArray+LogParser.h"
#import "NSString+LogParser.h"

#define TP_LOG_PARSE_DEBUG 0

// Scan for:
//
//  (afile
//   Info:
//   Error:
//   Warning:
//  )

@implementation TPTeXLogParser

+ (NSDictionary*)lineExpressions
{
  return @{ @"(\\d+):" : @YES,
            @"line (\\d+)" : @NO,
            @"lines (\\d+)--(\\d+)" : @NO
          };
}

+ (NSString*)lineExp1
{
  return @"(\\d+):";
}

+ (NSString*)lineExp2
{
  return @"line (\\d+)";
}

//lines 57--64

+ (NSDictionary*)errorPhrases
{
  return @{@"Info:"    : @(TPLogInfo),
           @"Warning:" : @(TPLogWarning),
           @"Missing character:" : @(TPLogWarning),
           @"Underfull \\hbox" : @(TPLogWarning),
           @"Error:"   : @(TPLogError),
           @"Emergency stop."   : @(TPLogError),
           @"! TeX capacity exceeded" : @(TPLogError)
           };
}

- (id) init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

+ (NSArray*) parseLogFileAtURL:(NSURL*)aURL
{
  NSString *logText = [NSString stringWithContentsOfURL:aURL encoding:NSUTF8StringEncoding error:nil];
  
  return [TPTeXLogParser parseLogText:logText];
}

+ (NSArray*) parseLogFileAtPath:(NSString*)aPath
{
  return [TPTeXLogParser parseLogFileAtURL:[NSURL fileURLWithPath:aPath]];
}



+ (NSArray*) parseLogText:(NSString*)logText
{
  NSMutableArray *stack = [NSMutableArray array];
  NSMutableArray *items = [NSMutableArray array];
  
  NSDictionary *lineExpressions = [TPTeXLogParser lineExpressions];
  NSDictionary *phrases = [TPTeXLogParser errorPhrases];
  
  NSArray *lines = [logText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  
  // go through each line
  NSInteger braceCount = 0;
  for (NSString *line in lines) {
#if TP_LOG_PARSE_DEBUG
    NSLog(@"LINE: [%@]", line);
#endif
    
    // scan for a (./ or (/ and )
    for (NSInteger kk=0; kk<[line length]; kk++) {
      if ([line characterAtIndex:kk] == ')') {
        // pop off stack
        if ([stack count] > 0) {
          NSLog(@"-- %@%@", [NSString paddingLength:braceCount], [stack lastObject]);
          [stack removeLastObject];
        }
        braceCount -= 2;
      }
      
      if ([line characterAtIndex:kk] == '(') {
        // pop filename on stack
        braceCount += 2;
        NSString *filename = [line  filename];
        if (filename != nil) {
          NSLog(@"++ %@%@", [NSString paddingLength:braceCount], filename);
          [stack addObject:filename];
          
          // we can move on now
          kk += [filename length]-1;
        } else {
          NSLog(@"++ %@DUMMY", [NSString paddingLength:braceCount]);
          [stack addObject:@"DUMMY"];
        }
      }
    }
    
//    if ([line beginsWith:@"("]) {
//      // parse rest of the line up to ( into filename
//      // I think for this to be a filename, the rest of the line shouldn't close the (
//      NSInteger count = 1;
//      for (NSInteger kk=1; kk<[line length]; kk++) {
//        if ([line characterAtIndex:kk] == ')') {
//          count--;
//        }
//        if ([line characterAtIndex:kk] == '(') {
//          count++;
//        }
//      }
//      if (count == 1) {
//        NSString *filename = nil;
//        
//        // decide on range: find range of file extension
//        NSRange extr = [line rangeOfRegex:@"\.\\w+\\s"];
//        
//        if (extr.location == NSNotFound) {
//          filename = [line substringFromIndex:1];
//        } else {
//          filename = [line substringWithRange:NSMakeRange(1, NSMaxRange(extr)-2)];
//        }
//        
//#if TP_LOG_PARSE_DEBUG
//        NSLog(@"+++ stack: %@", filename);
//#endif
//        [stack addObject:filename];
//      }
//    }
    
    // check for phrases
    TPLogItemType type = TPLogUnknown;
    NSRange r = NSMakeRange(NSNotFound, 0);
    NSString *phraseMatched = nil;
    // check for any of the error phrases
    for (NSString *phrase in [phrases allKeys]) {
      r = [line rangeOfString:phrase options:NSCaseInsensitiveSearch];
      if (r.location != NSNotFound) {
        type = (TPLogItemType)[phrases[phrase] integerValue];
        phraseMatched = phrase;
        break;
      }
    }
    
#if TP_LOG_PARSE_DEBUG
    if (r.location == NSNotFound) {
      NSLog(@"## No tag in line [%@]", line);
    }
#endif
    
    if ([stack count] > 0 && r.location != NSNotFound) {
      
      NSString *message = [[line substringFromIndex:NSMaxRange(r)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      
      // try to get the line number
      NSInteger linenumber = NSNotFound;
      for (NSString *expr in [lineExpressions allKeys]) {
        NSArray *numberStrings = [line captureComponentsMatchedByRegex:expr];
        if ([numberStrings count] >= 2) {
          linenumber = [numberStrings[1] integerValue];
          // trim the message
          if ([lineExpressions[expr] boolValue] == YES) {
            message = [[message stringByReplacingOccurrencesOfRegex:[TPTeXLogParser lineExp1] withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
          }
        }
      }
      
      TPLogItem *item = [[TPLogItem alloc] initWithFileName:[stack lastObject]
                                                       type:type
                                                    message:message
                                                       line:linenumber
                                              matchedPhrase:phraseMatched];
      NSLog(@"LOGITEM: %@", item);
      
      item.line = line;
      [items addObject:item];
    }
    
//    if ([line beginsWith:@")"] && [line length] == 1) {
//#if TP_LOG_PARSE_DEBUG
//      NSLog(@"Close file? stack length: %ld", [stack count]);
//#endif
//      // we've finished a line now, so pop it off the stack
//      if ([stack count] > 0) {
//#if TP_LOG_PARSE_DEBUG
//        NSLog(@"--- stack: %@", [stack lastObject]);
//#endif
//        [stack removeLastObject];
//      }
//    }
  }
  
  return items;
}

@end
