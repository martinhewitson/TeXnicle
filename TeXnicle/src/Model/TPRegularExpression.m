//
//  TPRegularExpression.m
//  TeXnicle
//
//  Created by Martin Hewitson on 13/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPRegularExpression.h"
#import "RegexKitLite.h"

@implementation TPRegularExpression


+ (NSArray*)rangesMatching:(NSString*)expr inText:(NSString*)text
{
  NSArray *ranges = nil;
//  if (NSClassFromString(@"NSRegularExpression") != nil && 0)  {
//    
//    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expr
//                                                                         options:0
//                                                                           error:NULL];
//    
//    __block NSMutableArray *rangeMatches = [NSMutableArray array];
//    [exp enumerateMatchesInString:text
//                          options:0
//                            range:NSMakeRange(0, [text length])
//                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//                         // search
//                         NSRange matchRange = [result range];
//                         [rangeMatches addObject:[NSValue valueWithRange:matchRange]];
//                       }];
//    ranges = [NSArray arrayWithArray:rangeMatches];
//    
//  } else {
  
    __block NSMutableArray *rangeMatches = [NSMutableArray array];
    [text enumerateStringsMatchedByRegex:expr options:RKLNoOptions inRange:NSMakeRange(0UL, [text length]) error:NULL enumerationOptions:RKLRegexEnumerationCapturedStringsNotRequired usingBlock:^(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
      for (int kk=0; kk<captureCount; kk++) {
        NSRange matchRange = capturedRanges[kk];
        [rangeMatches addObject:[NSValue valueWithRange:matchRange]];
      }
    }];
    ranges = [NSArray arrayWithArray:rangeMatches];
    
//  }
  
  return ranges;
}

+ (NSArray*)stringsMatching:(NSString*)expr inText:(NSString*)text
{
  NSArray *strings = nil;
//  if (NSClassFromString(@"NSRegularExpression") != nil)  {
//
//    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expr
//                                                                         options:0
//                                                                           error:NULL];
//    
//    __block NSMutableArray *strMatches = [NSMutableArray array];
//    [exp enumerateMatchesInString:text
//                          options:0
//                            range:NSMakeRange(0, [text length])
//                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//                         // search
//                         for (NSUInteger kk=0; kk<result.numberOfRanges; kk++) {
//                           [strMatches addObject:[text substringWithRange:[result rangeAtIndex:kk]]];
//                         }
//                       }];
//    
//    strings = [NSArray arrayWithArray:strMatches];
//  } else {
    strings = [text componentsMatchedByRegex:expr];
//  }
  
  return strings;
}

+ (NSString*)stringByReplacingOccurrencesOfRegex:(NSString*)expr inRange:(NSRange)aRange withString:(NSString*)replacement inString:(NSString*)text
{
  if (NSClassFromString(@"NSRegularExpression") != nil)  {
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expr
                                                                         options:0
                                                                           error:NULL];
    
    return [exp stringByReplacingMatchesInString:text options:0 range:aRange withTemplate:replacement];
    
  } else {
    return [text stringByReplacingOccurrencesOfRegex:expr withString:replacement range:aRange];
  }
  
}


+ (NSString*)stringByReplacingOccurrencesOfRegex:(NSString*)expr withString:(NSString*)replacement inString:(NSString*)text
{
  if (NSClassFromString(@"NSRegularExpression") != nil)  {
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expr
                                                                         options:0
                                                                           error:NULL];
    
    return [exp stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:replacement];
    
  } else {
    return [text stringByReplacingOccurrencesOfRegex:expr withString:replacement];
  }
  
}

+ (NSRange)rangeOfExpr:(NSString*)expr inText:(NSString*)text
{
  NSRange range = NSMakeRange(NSNotFound, 0);
  if (NSClassFromString(@"NSRegularExpression") != nil)  {
    
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expr
                                                                         options:0
                                                                           error:NULL];
    
    range = [exp rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    
  } else {
    range = [text rangeOfRegex:expr];
  }
  
  return range;
}


@end
