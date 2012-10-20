//
//  NSString+Reformatting.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSString+Reformatting.h"
#import "NSString+Reformatting_Private.h"
#import "TPRegularExpression.h"

@implementation NSString (Reformatting)

- (NSString*) reformatStartingAtIndex:(NSInteger)cursorLocation forLinewidth:(NSInteger)linewidth
{
  NSRange r;
  return [self reformatStartingAtIndex:cursorLocation forLinewidth:linewidth formattedRange:&r];
}

- (NSString*) reformatStartingAtIndex:(NSInteger)cursorLocation forLinewidth:(NSInteger)linewidth formattedRange:(NSRange*)aRange;
{
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
  NSCharacterSet *newlineCharacters = [NSCharacterSet newlineCharacterSet];
  NSInteger indentation;
  
  NSInteger startPosition = [self startIndexForReformattingFromIndex:cursorLocation indentation:&indentation];
  NSInteger endPosition = [self endIndexForReformattingFromIndex:cursorLocation];
//  NSLog(@"Start index %ld", startPosition);
//  NSLog(@"End index %ld", endPosition);
//  NSLog(@"Indentation %ld", indentation);
  
  // now make sure we preserve the initial whitespace
  NSInteger count = 0;
  NSInteger pos = 0;
  while (pos < [self length]) {
    unichar c = [self characterAtIndex:pos];
    if ([whitespace characterIsMember:c]) {
      count++;
    } else {
      break;
    }
    pos++;
  }
  
  // now replace repeated whitespace in the range where we will work
  NSString *text = [TPRegularExpression stringByReplacingOccurrencesOfRegex:@"\\s+" inRange:NSMakeRange(startPosition, endPosition-startPosition) withString:@" " inString:self];
  
  // now fix prepadding
  if (count > 0) count--;
  for (int kk=0; kk<count; kk++) {
    text = [@" " stringByAppendingString:text];
  }
  
  NSMutableString *newString = [text mutableCopy];
  
  // recalculate because we replace repeated whitespace
  startPosition = [text startIndexForReformattingFromIndex:cursorLocation indentation:&indentation];
  endPosition = [text endIndexForReformattingFromIndex:cursorLocation];
//  NSLog(@"Start index %ld", startPosition);
//  NSLog(@"End index %ld", endPosition);
//  NSLog(@"Indentation %ld", indentation);
//  NSLog(@"Working on [%@]", newString);
  
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
  pos = startPosition;
  
  // offset on first line
  NSRange lineRange = [self lineRangeForRange:NSMakeRange(pos, 0)];
  count = pos - lineRange.location;
  NSInteger added = 0;
  while (pos < endPosition) {
    
    // replace any newline we hit with a space. We'll put new newlines in as
    // part of the reformatting
    unichar c = [newString characterAtIndex:pos];
    if ([newlineCharacters characterIsMember:c]) {
      [newString replaceCharactersInRange:NSMakeRange(pos, 1) withString:@" "];
    }
    
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
