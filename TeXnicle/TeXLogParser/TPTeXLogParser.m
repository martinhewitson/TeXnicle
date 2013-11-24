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
           @"BEWARE:" : @(TPLogWarning),
           @"Missing character:" : @(TPLogWarning),
           @"Underfull \\hbox" : @(TPLogWarning),
           @"Overfull \\hbox" : @(TPLogWarning),
           @"Error:"   : @(TPLogError),
           @"Undefined control sequence" : @(TPLogError), 
           @"Emergency stop."   : @(TPLogError),
           @"Missing $ inserted" : @(TPLogError),
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
  NSInteger lineCount = 0;
  for (NSString *line in lines) {
    lineCount++;
    if ([line length] == 0) {
      continue;
    }
    
#if TP_LOG_PARSE_DEBUG
    NSLog(@"LINE: [%@]", line);
#endif
    
    // scan for a (./ or (/ and )
    for (NSInteger kk=0; kk<[line length]; kk++) {
      if ([line characterAtIndex:kk] == ')') {
        // pop off stack
        if ([stack count] > 0) {
#if TP_LOG_PARSE_DEBUG
          NSLog(@"-- [%ld] %@%@", lineCount, [NSString paddingLength:braceCount], [stack lastObject]);
#endif
          [stack removeLastObject];
        }
        braceCount -= 2;
      }
      
      if ([line characterAtIndex:kk] == '(') {
        // pop filename on stack
        braceCount += 2;
        NSString *filename = [line filename];
        if (filename != nil) {
#if TP_LOG_PARSE_DEBUG
          NSLog(@"++ [%ld] %@%@", lineCount, [NSString paddingLength:braceCount], filename);
#endif
          [stack addObject:filename];
          
          // we can move on now
          kk += [filename length]-1;
        } else {
#if TP_LOG_PARSE_DEBUG
          NSLog(@"++ [%ld] %@DUMMY", lineCount, [NSString paddingLength:braceCount]);
#endif
          [stack addObject:@"DUMMY"];
        }
      }
    }
    
    // check for phrases
    TPLogItemType type = TPLogUnknown;
    NSRange r = NSMakeRange(NSNotFound, 0);
    NSString *phraseMatched = nil;
    // check for any of the error phrases
    for (NSString *phrase in [phrases allKeys]) {
      //NSLog(@"  checking for [%@] in [%@]", phrase, line);
      r = [line rangeOfString:phrase options:NSCaseInsensitiveSearch];
      //NSLog(@"Range %@", NSStringFromRange(r));
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
#if TP_LOG_PARSE_DEBUG
      NSLog(@"LOGITEM: %@", item);
#endif
      
      item.line = line;
      [items addObject:item];
    }    
  }
  
  return items;
}

@end
