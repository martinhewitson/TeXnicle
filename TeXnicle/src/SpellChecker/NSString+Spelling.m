//
//  NSString+Spelling.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSString+Spelling.h"
#import "TPMisspelledWord.h"

@implementation NSString (Spelling)


- (NSArray*) listOfMisspelledWords
{
  NSString *aString = self;
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
  
  return words;
}


@end
