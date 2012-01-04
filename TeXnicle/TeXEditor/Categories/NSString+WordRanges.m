//
//  NSString+WordRanges.m
//  TeXnicle
//
//  Created by Martin Hewitson on 5/9/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "NSString+WordRanges.h"

@implementation NSString (WordRanges)

- (NSArray*) rangesOfString: (NSString *)subString 
{
  NSMutableArray *matches = [NSMutableArray array];
  NSUInteger myLength = [self length];
  NSRange uncheckedRange = NSMakeRange(0, myLength);
  for(;;) {
    NSRange foundAtRange = [self rangeOfString:subString
                                       options:NSCaseInsensitiveSearch
                                         range:uncheckedRange];
    if (foundAtRange.location != NSNotFound) {
      
      [matches addObject:[NSValue valueWithRange:foundAtRange]];
      NSUInteger newLocation = NSMaxRange(foundAtRange); 
      uncheckedRange = NSMakeRange(newLocation, myLength-newLocation);
    } else {
      break;
    }
  }
  return matches;
}



@end
