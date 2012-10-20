//
//  NSString+Reformatting_Private.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSString+Reformatting_Private.h"

@implementation NSString (Reformatting_Private)

- (BOOL) lineIsEmptyAtIndex:(NSInteger)index
{
  NSCharacterSet *newlineCharacters = [NSCharacterSet newlineCharacterSet];
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
  NSRange lineRange = [self lineRangeForRange:NSMakeRange(index, 0)];
  NSString *line = [self substringWithRange:lineRange];
  line = [[line stringByTrimmingCharactersInSet:whitespace] stringByTrimmingCharactersInSet:newlineCharacters];
  return [line length] == 0;
}

- (BOOL) lineIsCommentedBeforeIndex:(NSInteger)location
{
  BOOL isCommentLine = NO;
  NSCharacterSet *newlineCharacters = [NSCharacterSet newlineCharacterSet];
  NSInteger pos = location;
  while (pos >= 0) {
    unichar cc = [self characterAtIndex:pos];
    if (cc == '%') {
      // check if the preceding character is a '\'
      if (pos > 0) {
        unichar pc = [self characterAtIndex:pos-1];
        if (pc != '\\') {
          // then we stop
          isCommentLine = YES;
          break;
        }
      } else {
        isCommentLine = YES;
        break;
      }
    } else if ([newlineCharacters characterIsMember:cc]) {
      // this line wasn't commented
      break;
    }
    pos--;
  }
  
  return isCommentLine;
}

- (NSString*) commandNameStartingAtIndex:(NSInteger)index
{
  if ([self characterAtIndex:index] != '\\')
    return nil;
  
  NSCharacterSet *newlineCharacters = [NSCharacterSet newlineCharacterSet];
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
  NSInteger pos = index;
  while (pos < [self length]) {    
    unichar c = [self characterAtIndex:pos];
    if ([whitespace characterIsMember:c] || [newlineCharacters characterIsMember:c] || c == '{') {
      // check what the command is
      return [self substringWithRange:NSMakeRange(index, pos-index)];
    }
    pos ++;
  } // end wind forward while loop
  
  return nil;
}

- (NSInteger) startIndexForReformattingFromIndex:(NSInteger)cursorLocation
{
  NSInteger dummy;
  return [self startIndexForReformattingFromIndex:cursorLocation indentation:&dummy];
}

- (NSInteger) startIndexForReformattingFromIndex:(NSInteger)cursorLocation indentation:(NSInteger*)indent
{
  NSCharacterSet *newlineCharacters = [NSCharacterSet newlineCharacterSet];
  
  // first check if we are in an argument
  NSInteger startPosition = NSNotFound;
  NSInteger pos = cursorLocation;
  NSInteger braceCount = -1; // assume there is a closing brace after the starting position
  unichar previousCharacter = 0;
  while (pos >= 0) {
    
    unichar c = [self characterAtIndex:pos];
    
    // if this is a blank line, stop.
    if ([newlineCharacters characterIsMember:c]) {
      if ([self lineIsEmptyAtIndex:pos]) {
        // we stop here
        startPosition = pos+1;
        *indent = 0;
        break;
      }
      
      // if this line is commented, stop
      if (pos > 0) {
        BOOL isCommentLine = [self lineIsCommentedBeforeIndex:pos-1];
        // if this is a commented line, stop
        if (isCommentLine == YES) {
          startPosition = pos+1;
          *indent = 0;
          break;
        }
      }
    }
    
    // check if we are in an argument
    if (c == '{') {
      braceCount++;
    } else if (c == '}') {
      braceCount--;
    }
    
    if (braceCount == 0) {
      // then this signifies the start of an argument which ends after the
      // the starting cursor location. If there is no closing brace before
      // we hit a blank line, then this could be a TeX syntax error, but
      // we don't care here, we would just reformat the text up to the blank
      // line and let the user handle any errors.
      startPosition = pos+1;
      *indent = 0;
      break;
    }
    
    // if we find an \item command
    if (c == '\\') {
      // get the command name
      NSString *command = [self commandNameStartingAtIndex:pos];
      if ([command isEqualToString:@"\\item"]) {
        NSLog(@"Found start item at %ld", pos);
        startPosition = pos;
        NSRange lineRange = [self lineRangeForRange:NSMakeRange(pos, 0)];
        *indent = pos - lineRange.location + 6;
        break;
      }
    }
    
    pos--;
    previousCharacter = c;
  }
  
  // if we got to the start of the file, then start there
  if (pos < 0) {
    startPosition = 0;
    *indent = 0;
  }
  
  return startPosition;
}

- (NSInteger) endIndexForReformattingFromIndex:(NSInteger)cursorLocation
{
  NSCharacterSet *newlineCharacters = [NSCharacterSet newlineCharacterSet];
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
  
  // first check if we are in an argument
  NSInteger endPosition = NSNotFound;
  NSInteger pos = cursorLocation;
  NSInteger braceCount = 1; // assume there is a starting brace before the starting position
  unichar previousCharacter = 0;
  NSInteger strLength = [self length];
  while (pos < strLength) {
    
    unichar c = [self characterAtIndex:pos];
    
    // if this is a blank line, stop.
    if ([newlineCharacters characterIsMember:c] && pos < strLength-1) {
      if ([self lineIsEmptyAtIndex:pos+1]) {
        // we stop here
        endPosition = pos;
        break;
      }
      
      // if this line is commented, stop
      if (pos < strLength-1) {
        BOOL isCommentLine = [self lineIsCommentedBeforeIndex:pos+1];
        // if this is a commented line, stop
        if (isCommentLine == YES) {
          endPosition = pos;
          break;
        }
      }
    }
    
    // check if we are in an argument
    if (c == '{') {
      braceCount++;
    } else if (c == '}') {
      braceCount--;
    }
    
    if (braceCount == 0) {
      // then this signifies the end of an argument which starts before the
      // the starting cursor location. If there is no starting brace before
      // we hit a blank line, then this could be a TeX syntax error, but
      // we don't care here, we would just reformat the text up to the blank
      // line and let the user handle any errors.
      endPosition = pos;
      break;
    }
    
    // if we find an \item command
    if (c == '\\') {
      // get the command name
      NSString *command = [self commandNameStartingAtIndex:pos];
      if ([command isEqualToString:@"\\item"]) {
        // go back to first non-whitespace/newline character
        NSLog(@"Found end item at %ld", pos);
        if (pos > 0) {
          pos--;
          while (pos >= 0) {
            unichar tc = [self characterAtIndex:pos];
            NSLog(@"  checking [%c]", tc);
            if (![whitespace characterIsMember:tc] && ![newlineCharacters characterIsMember:tc]) {
              pos++;
              break;
            }
            pos--;
          }
          endPosition = pos;
          break;
        }
      }
    }
    
    pos++;
    previousCharacter = c;
  }
  
  // if we got to the end of the file, then end there
  if (pos == strLength) {
    // wind back to the first non-whitespace, non-newline character
    pos--;
    while (pos >= 0) {
      unichar c = [self characterAtIndex:pos];
      if (![newlineCharacters characterIsMember:c] && ![whitespace characterIsMember:c]) {
        endPosition = pos+1;
        break;
      }
      pos--;
    }
  }  
  
  return endPosition;
}

@end
