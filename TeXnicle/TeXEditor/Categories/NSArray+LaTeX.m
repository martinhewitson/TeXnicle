//
//  NSArray+LaTeX.m
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSArray+LaTeX.h"

@implementation NSArray (LaTeX)

+ (NSArray*)latexFileTypes
{
  return [NSArray arrayWithObjects:@"tex", @"bib", @"sty", @"cls", @"bst", nil];
}

@end
