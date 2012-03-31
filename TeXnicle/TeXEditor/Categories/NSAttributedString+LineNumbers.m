//
//  NSAttributedString+LineNumbers.m
//  TeXnicle
//
//  Created by Martin Hewitson on 5/8/11.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSAttributedString+LineNumbers.h"
#import "MHLineNumber.h"
#import "NSAttributedString+CodeFolding.h"

@implementation NSAttributedString (LineNumbers)


- (NSInteger) indexForLineNumber:(NSInteger)aLinenumber
{
  NSAttributedString *attStr = self;
  
  NSUInteger stop = [self length];
  NSString *text = [attStr string];
  
  // go forwards from the start until we reach the start of the visible range
  NSUInteger idx;
  NSUInteger lineNumber = 1;
  NSRange lineRange;
  for (idx = 0; idx < stop;) {
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    lineNumber += [NSAttributedString lineCountForLine:[attStr attributedSubstringFromRange:lineRange]];
		idx = NSMaxRange(lineRange);
    if (lineNumber == aLinenumber) {
      return idx;
    }
	}
  
  return NSNotFound;
}

- (NSArray*) lineNumbersForTextRange:(NSRange)aRange
{
  return [self lineNumbersForTextRange:aRange startIndex:0 startLine:1];
}

// Build an array of line number objects for the given text range.
- (NSArray*) lineNumbersForTextRange:(NSRange)aRange startIndex:(NSInteger)aStartIndex startLine:(NSInteger)aStartLine
{
  NSAttributedString *attStr = self;
  NSMutableArray *lines = [NSMutableArray array];
  
  NSUInteger start = aRange.location;
  NSUInteger stop = start + aRange.length;
  NSString *text = [attStr string];
  
  // go forwards from the start until we reach the start of the visible range
  NSUInteger idx = aStartIndex;
  NSUInteger lineNumber = aStartLine;
  NSRange lineRange;
  for (; idx < start;) {
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    lineNumber += [NSAttributedString lineCountForLine:[attStr attributedSubstringFromRange:lineRange]];
		idx = NSMaxRange(lineRange);
	}
  
  // now loop over the visible range and collect line numbers
  MHLineNumber *line;
  while (idx < stop)
  {
    // get the range of the current line
    lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
    if (NSMaxRange(lineRange) > [text length]) {
      idx = NSMaxRange(lineRange);
      continue;
    }
    // make a line object with the given number and starting index
    line = [MHLineNumber lineNumberWithValue:lineNumber index:lineRange.location range:lineRange];    
    [lines addObject:line];
    
    // Get an attributed version of this line
    NSAttributedString *attLine = [attStr attributedSubstringFromRange:lineRange];    
    // Get a line count for this line of text.
    lineNumber+=[NSAttributedString lineCountForLine:attLine];
    
    // move on to the next line
		idx = NSMaxRange(lineRange);
  }
  
//  NSLog(@"idx=%ld, text length = %ld", idx, [text length]);
  
  //  if ([text length]>0) {
  //    NSLog(@"Last char %c", [text characterAtIndex:[text length]-1]);
  //  }
  
  // check if we have a newline right at the end
  if (idx>0 && idx <= [text length] && [text length]>0) {
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[text characterAtIndex:idx-1]]) {
      //      NSLog(@"Last character is newline");
      line = [MHLineNumber lineNumberWithValue:lineNumber index:idx range:[text lineRangeForRange:NSMakeRange(idx, 0)]];    
      [lines addObject:line];
    }
  }
  
  //  NSLog(@"%@ Made lines %@", self, lines);
  return [NSArray arrayWithArray:lines];
}


@end
