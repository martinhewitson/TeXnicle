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

- (NSString*) reformatStartingAtIndex:(NSInteger)cursorLocation forLinewidth:(NSInteger)linewidth;
{
  
  //---------------------------------------------------------
  // find the start of our reformatting
  //
  // The start is defined by:
  //   1) the start of an argument
  //   2) a \item command
  //   3) a blank line
  //
  
  // first check if we are in an argument
  NSInteger startPosition = [self startIndexForReformattingFromIndex:cursorLocation];
  
  NSLog(@"Start index %ld", startPosition);
  
  //  NSLog(@"Argument [%@]", arg);
  
  
  
  //---------------------------------------------------------
  // determine the indent level
  
  
  //---------------------------------------------------------
  // work forward putting in \n and indents, then stop where
  // appropriate
  
  
  
  return @"";
}



@end
