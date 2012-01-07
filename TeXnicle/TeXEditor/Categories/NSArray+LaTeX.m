//
//  NSArray+LaTeX.m
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSArray+LaTeX.h"
#import "TPSupportedFilesManager.h"

@implementation NSArray (LaTeX)

+ (NSArray*)latexFileTypes
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  return [sfm supportedExtensions];
}

@end
