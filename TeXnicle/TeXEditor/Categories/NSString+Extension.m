//
//  NSString+Extension.m
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "NSString+Extension.h"


@implementation NSString (Extension)

// Returns the index of the first match of the tag in the string. If the string is prefixed by
// one the exceptions, then NSNotFound is returned.
- (NSInteger) indexOfFirstMatch:(NSString*)tag withExceptions:(NSArray*)exceptionList
{
  for (NSString *exception in exceptionList) {
    if ([self hasPrefix:exception]) 
      return NSNotFound;
  }
  
  return [self indexOfFirstMatch:tag];
}

// Returns the index of the first match of the tag in the string. The index 
// corresponds to the start of the tag in the string.
- (NSInteger) indexOfFirstMatch:(NSString*)tag
{
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner scanUpToString:tag intoString:NULL];
	if ([scanner isAtEnd])
		return NSNotFound;
	
	return [scanner scanLocation];
}

- (BOOL) containsCommentCharBeforeIndex:(NSInteger)anIndex
{
  NSInteger len = [self length];
  if (len == 0) {
    return NO;
  }
  
  BOOL commentFound = NO;
  NSInteger charIdx = 0;
  while ((charIdx < anIndex) && (charIdx < len)) {
    if ([self characterAtIndex:charIdx] == '%') {
      commentFound = YES;
      break;
    }
    charIdx++;
  }

  return commentFound;
}

@end
