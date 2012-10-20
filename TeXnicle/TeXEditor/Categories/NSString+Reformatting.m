//
//  NSString+Reformatting.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSString+Reformatting.h"
#import "NSString+Reformatting_Private.h"

@implementation NSString (Reformatting)

- (NSString*) reformatStartingAtIndex:(NSInteger)cursorLocation forLinewidth:(NSInteger)linewidth
{
  NSRange r;
  return [self reformatStartingAtIndex:cursorLocation forLinewidth:linewidth formattedRange:&r];
}

- (NSString*) reformatStartingAtIndex:(NSInteger)cursorLocation forLinewidth:(NSInteger)linewidth formattedRange:(NSRange*)aRange;
{
  NSMutableString *newString = [self mutableCopy];
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
  NSCharacterSet *newlineCharacters = [NSCharacterSet newlineCharacterSet];
  NSInteger indentation;
  NSInteger startPosition = [self startIndexForReformattingFromIndex:cursorLocation indentation:&indentation];
  NSInteger endPosition = [self endIndexForReformattingFromIndex:cursorLocation];
//  NSLog(@"Start index %ld", startPosition);
//  NSLog(@"End index %ld", endPosition);
//  NSLog(@"Indentation %ld", indentation);
  
  
  // check for sensible values
  if (startPosition == NSNotFound || endPosition == NSNotFound || indentation == NSNotFound ||
      endPosition > [self length]) {
    return nil;
  }
  
  // prepare indent string
  NSString *indentString = @"";
  for (int kk=0; kk<indentation; kk++) {
    indentString = [indentString stringByAppendingString:@" "];
  }
  
  //---------------------------------------------------------
  // work forward putting in \n and indents, then stop where
  // appropriate
  NSInteger pos = startPosition;
  
  // offset on first line
  NSRange lineRange = [self lineRangeForRange:NSMakeRange(pos, 0)];
  NSInteger count = pos - lineRange.location;
  NSInteger added = 0;
  while (pos < endPosition) {
    
//    NSLog(@"Count %ld, pos %ld, [%c]", count, pos, [newString characterAtIndex:pos]);
    // if we are past the limit, go back looking for a white space
    // stop when we hit a new line, in which case return to this position
    // and carry on the search
    if (count >= linewidth) {
//      NSLog(@"---------------- Line length exceeded");
      NSInteger searchStart = pos;
      while (pos >= 0) {
        unichar c = [newString characterAtIndex:pos];
//        NSLog(@"Checking char [%c]", c);
        // if this is a whitespace, we can insert a newline
        if ([whitespace characterIsMember:c]) {
          // insert newline here
          NSString *insert = [NSString stringWithFormat:@"\n%@", indentString];
          [newString replaceCharactersInRange:NSMakeRange(pos, 1) withString:insert];
          added = [indentString length];
          pos += added;
          endPosition += added;
          // reset count and move on
          pos++;
          count = added;
          break;
        }
        
        // if this is a newline, we stop
        if ([newlineCharacters characterIsMember:c]) {
          // stop and continue search from where we left off
          pos = searchStart+1;
          count++;
          break;
        }
        
        pos--;
      }
      
      // if we got to pos == 0, continue from where we left off
      if (pos == 0) {
        pos = searchStart+1;
        count++;
      }
      
    } else {
      count++;
      pos++;
    }
  }
  
  // fill the range we reformatted - this can be used downstream to replace the text being formatted
  *aRange = NSMakeRange(startPosition, endPosition-startPosition);
  
  
  return [newString copy];
}



@end
