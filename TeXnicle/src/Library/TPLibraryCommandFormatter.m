//
//  TPLibraryCommandFormatter.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "TPLibraryCommandFormatter.h"

@implementation TPLibraryCommandFormatter

- (NSString*)stringForObjectValue:(id)obj
{
  if (obj == nil) {
    return @"";
  }
  return obj;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
  *anObject = [string copy];
  return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr 
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr 
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error
{
  NSMutableCharacterSet *letters = [NSMutableCharacterSet letterCharacterSet];
  NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:*partialStringPtr];
  
  if ([letters isSupersetOfSet:inStringSet]) {
    return YES;
  }
  return NO;
}

@end
