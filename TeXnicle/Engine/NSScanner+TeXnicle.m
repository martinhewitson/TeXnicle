//
//  NSScanner+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSScanner+TeXnicle.h"

@implementation NSScanner (TeXnicle)

- (NSString*)stringForTag:(NSString*)tag
{
  NSString *tagStart = [NSString stringWithFormat:@"<%@>", tag];
  NSString *tagEnd   = [NSString stringWithFormat:@"</%@>", tag];
  [self setScanLocation:0];
  [self scanUpToString:tagStart intoString:NULL];
  NSInteger start = [self scanLocation];
  if (start<[[self string] length]) {
    start += [tagStart length];
  }
  [self scanUpToString:tagEnd intoString:NULL];
  NSInteger stop = [self scanLocation];
  if (stop > start) {
    NSString *template = [[[self string] substringWithRange:NSMakeRange(start, stop-start)] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSArray *lines = [template componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *processedLines = [NSMutableArray array];
    for (NSString *line in lines) {
      [processedLines addObject:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    return [processedLines componentsJoinedByString:@"\n"];
  }
  
  return nil;
}

@end
