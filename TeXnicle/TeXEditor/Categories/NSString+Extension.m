//
//  NSString+Extension.m
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
