//
//  BashColoringEngine.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "BashColoringEngine.h"

@implementation BashColoringEngine

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
    //    NSLog(@"Checking %c", cc);
    // color comments
    if (cc == '#' && self.colorComments) {
      // comment rest of the line
      lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
      colorRange = NSMakeRange(aRange.location+idx, NSMaxRange(lineRange)-idx);
      unichar c = 0;
			if (idx>0) {
				c = [text characterAtIndex:idx-1];
			}
			if (idx==0 || c != '\\') {
        
        //          [newLineCharacterSet characterIsMember:c] ||
        //          [whitespaceCharacterSet characterIsMember:c]) {
        [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.commentColor forCharacterRange:colorRange];
        idx = NSMaxRange(lineRange)-1;
			}
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
//    } else if ([specialChars characterIsMember:cc] && self.colorSpecialChars) { // (cc == '$' || cc == '{'&& self.colorMath) {
//      
//      colorRange = NSMakeRange(aRange.location+idx, 1);
//      [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.specialCharsColor forCharacterRange:colorRange];
    } else if (cc == '$' && self.colorCommand) {      
      // if we find \ we start a command unless we have \, or whitespace
      if (idx < strLen-1) {
        nextChar = [text characterAtIndex:idx+1];
        if (nextChar == ',' || [whitespaceCharacterSet characterIsMember:nextChar]) {
          // do nothing
        } else {
          // highlight word
          NSRange wordRange = [textStorage doubleClickAtIndex:aRange.location+idx+1];
          colorRange = NSMakeRange(wordRange.location-1, wordRange.length+1);
          [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.commandColor forCharacterRange:colorRange];
          idx += colorRange.length-1;
        }
      }            
      //    } else if ((cc == '[') && self.colorArguments) {      
    } else {
      // do nothing
    }    
  } 
  self.lastHighlight = [NSDate date];
}


@end
