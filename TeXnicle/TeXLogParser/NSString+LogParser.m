//
//  NSString+LogParser.m
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "NSString+LogParser.h"
#import "RegexKitLite.h"

@implementation NSString (LogParser)

// tries to get a filename from the string. Look for a file extension and stop there
//- (NSString*)filename
//{
//  NSString *str = nil;
//  NSString *expr = @"[/\\.\\w]+\\.[^.]+[\\s]*";
////  NSString *expr = @".+.[^.]+\\s"; // @"\\.\\w+\\s"
//  
//  // decide on range: find range of file extension
//  NSRange extr = [self rangeOfRegex:expr];
//  
//  if (extr.location == NSNotFound) {
//    //str = [self substringFromIndex:0];
//  } else {
//    NSLog(@" Found filename %@", [self substringWithRange:extr]);
//    str = [self substringWithRange:NSMakeRange(0, NSMaxRange(extr)-1)];
//  }
//
//  return str;
//}

+ (NSString*)paddingLength:(NSInteger)pad
{
  NSString *str = @"";
  for (NSInteger kk=0; kk<pad; kk++) {
    str = [str stringByAppendingString:@" "];
  }
  return str;
}

- (NSString*)filename
{
  NSString *str = nil;
  //NSString *expr = @"\\.[^.]+[\\s]*";
//  NSString *expr = @"\\([/|\\.|\\w].*?\\.[^.\\W]+[\\s]*";
  NSString *expr = @"\\([/|\\.].*?\\.[^.\\W]+[\\s]*";
  
//  NSLog(@"Expr: [%@]", expr);
  
  // decide on range: find range of file extension
  NSRange extr = [self rangeOfRegex:expr];
//  NSLog(@"   range %@", NSStringFromRange(extr));
  
  if (extr.location == NSNotFound) {
    //str = [self substringFromIndex:0];
  } else {
    extr.location ++;
    extr.length --;
//    NSLog(@" Found filename %@", [self substringWithRange:extr]);
    str = [self substringWithRange:extr];
    NSURL *url = [NSURL fileURLWithPath:str];
    if (url == nil) {
      return nil;
    }
  }
  
  return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
