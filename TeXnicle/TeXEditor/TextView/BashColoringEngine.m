//
//  BashColoringEngine.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
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

#import "BashColoringEngine.h"
#import "RegexKitLite.h"
#import "NSString+Comparisons.h"

@implementation BashColoringEngine

@synthesize keywords;

- (id) initWithTextView:(NSTextView*)aTextView
{
  self = [super initWithTextView:aTextView];
  if (self) {
    self.keywords = [NSArray arrayWithObjects:@"if", @"then", @"fi", @"done", @"do", @"while", @"echo", @"exit", @"export", nil];
  }
  
  return self;
}

- (void) dealloc
{
  self.keywords = nil;
  [super dealloc];
}

- (void) colorTextView:(NSTextView*)aTextView textStorage:(NSTextStorage*)textStorage layoutManager:(NSLayoutManager*)layoutManager inRange:(NSRange)aRange
{
  if (self.lastHighlight) {
    if ([[NSDate date] timeIntervalSinceDate:self.lastHighlight] < kHighlightInterval) {
      return;
    }
  }
  
  //  NSLog(@"Coloring %@", NSStringFromRange(aRange));
  
  NSString *text = [[textStorage string] substringWithRange:aRange];
  NSInteger strLen = [text length];
  if (strLen == 0) {
    return;
  }
  
  // make sure the glyphs are present otherwise colouring gives errors
  [layoutManager ensureGlyphsForCharacterRange:aRange];
  
  // remove existing temporary attributes
	[layoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:aRange];
  
  // scan each character in the string
  NSUInteger idx;
  unichar cc;
  unichar nextChar;
  NSRange lineRange;
  NSRange colorRange;
  NSInteger start;
  for (idx = 0; idx < strLen; idx++) {
    
    cc  = [text characterAtIndex:idx];
    if ([whitespaceCharacterSet characterIsMember:cc]) {
      continue;
    }
    if ([newLineCharacterSet characterIsMember:cc]) {
      continue;
    }
    
    //    NSLog(@"Checking %c", cc);
    // color comments
    if (cc == '#' && self.colorComments) {
      // comment rest of the line
      lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
      colorRange = NSMakeRange(aRange.location+idx, NSMaxRange(lineRange)-idx);
      [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.commentColor forCharacterRange:colorRange];
      idx = NSMaxRange(lineRange)-1;
    } else if ((cc == '{') && self.colorArguments) {      
      start = idx;
      // look for the closing bracket
      idx++;
      NSInteger argCount = 1;
      while(idx < strLen) {
        nextChar = [text characterAtIndex:idx];
        if (nextChar == '{') {
          argCount++;
        }
        if (nextChar == '}') {
          argCount--;
        }
        if (argCount == 0) {
          NSRange argRange = NSMakeRange(aRange.location+start,idx-start+1);
          [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.argumentsColor forCharacterRange:argRange];
          break;
        }
        idx++;
      }
    } else if ((cc == '[') && self.colorArguments) {      
      start = idx;
      // look for the closing bracket
      idx++;
      NSInteger argCount = 1;
      while(idx < strLen) {
        nextChar = [text characterAtIndex:idx];
        if (nextChar == '[') {
          argCount++;
        }
        if (nextChar == ']') {
          argCount--;
        }
        if (argCount == 0) {
          NSRange argRange = NSMakeRange(aRange.location+start,idx-start+1);
          [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.argumentsColor forCharacterRange:argRange];
          break;
        }
        idx++;
      }
    } else {
      
      // check for keywords
      for (NSString *keyword in self.keywords) {
        NSString *remaining = [text substringFromIndex:idx];
        if ([remaining beginsWith:keyword]) {
          NSRange colorRange = NSMakeRange(idx, [keyword length]);
          NSInteger endIndex = idx+[keyword length];
          if ([whitespaceCharacterSet characterIsMember:[text characterAtIndex:endIndex]]
              || [newLineCharacterSet characterIsMember:[text characterAtIndex:endIndex]]) {
            [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName
                                           value:self.commandColor
                               forCharacterRange:colorRange];
            idx+=[keyword length];
            break;
          }
        }
      }
      
      // do nothing
    }    
  } 
  
  // color key words
  
  self.lastHighlight = [NSDate date];
}


@end
