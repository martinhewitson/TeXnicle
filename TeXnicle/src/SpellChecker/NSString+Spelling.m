//
//  NSString+Spelling.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "NSString+Spelling.h"
#import "TPMisspelledWord.h"

@implementation NSString (Spelling)


- (NSArray*) listOfMisspelledWords
{
  NSString *aString = [self retain];
  if ([aString length] == 0) {
    return [NSArray array];
  }
  
  NSSpellChecker *checker = [NSSpellChecker sharedSpellChecker];
  NSMutableArray *words = [NSMutableArray array];
  NSRange range = NSMakeRange(0, 0);
  NSRange lastRange = NSMakeRange(0, 0);
  
  NSInteger misspelledWordCount = 0;
  
  while (range.location < [aString length] && misspelledWordCount <= 1000) {
    
    range = [checker checkSpellingOfString:aString startingAt:range.location];
    
    // there seems to be a bug here in checkSpellingOfString:startingAt: where it gets
    // the same word again. So we check for that.
    if (NSEqualRanges(range, lastRange)) {
      //      NSLog(@"Got same range %@", NSStringFromRange(range));
      range = NSMakeRange(NSMaxRange(range), 0);
      //      NSLog(@"Jumping to %@", NSStringFromRange(range));
    }
    
    if (range.location == NSNotFound) {
      break;
    }
    
    // check if we wrapped
    if (range.location < lastRange.location) {
      break;
    }
    
    // store last range
    lastRange = range;
    
    // did we get a word?
    if (NSMaxRange(range) < [aString length] && range.length > 0) {
      NSString *misspelledWord = [aString substringWithRange:range];
      //      NSLog(@"Found misspelled word [%@] at %@", misspelledWord, NSStringFromRange(range));
      NSArray *corrections = [checker guessesForWordRange:range inString:aString language:nil inSpellDocumentWithTag:0];
      TPMisspelledWord *word = [TPMisspelledWord wordWithWord:misspelledWord corrections:corrections range:range parent:nil];
      [words addObject:word];
      misspelledWordCount++;
      // move on
      range = NSMakeRange(NSMaxRange(range), 0);
      //      NSLog(@"  moving on to %@", NSStringFromRange(range));
    } else {
      break;
    }
    
    
  } // end while loop
  [aString release];
  
  return words;
}


@end
