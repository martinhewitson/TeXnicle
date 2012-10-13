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

+ (NSArray*)stringsMatching:(NSString*)expr inText:(NSString*)text
{
  NSArray *strings = nil;
  if (NSClassFromString(@"NSRegularExpression") != nil)  {

    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expr
                                                                         options:0
                                                                           error:NULL];
    
    __block NSMutableArray *strMatches = [NSMutableArray array];
    [exp enumerateMatchesInString:text
                          options:0
                            range:NSMakeRange(0, [text length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                         // search
                         for (NSUInteger kk=0; kk<result.numberOfRanges; kk++) {
                           [strMatches addObject:[text substringWithRange:[result rangeAtIndex:kk]]];
                         }
                       }];
    
    strings = [NSArray arrayWithArray:strMatches];
  } else {
    strings = [text componentsMatchedByRegex:expr];
  }
  
  return strings;
}

@end
