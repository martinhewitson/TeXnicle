//
//  MHLineNumber.m
//  TeXnicle
//
//  Created by Martin Hewitson on 03/04/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import "MHLineNumber.h"


@implementation MHLineNumber

@synthesize number;
@synthesize index;
@synthesize range;
@synthesize rect;

+ (MHLineNumber*) lineNumberWithValue:(NSUInteger)lineNumber index:(NSUInteger)anIndex range:(NSRange)aRange
{
  return [[MHLineNumber alloc] initWithLineNumberWithValue:lineNumber index:anIndex range:aRange];
}

- (id) initWithLineNumberWithValue:(NSUInteger)lineNumber index:(NSUInteger)anIndex range:(NSRange)aRange
{
  self = [super init];
  if (self) {
    self.number = lineNumber;
    self.index = anIndex;
    self.range = aRange;
  }
  return self;
}


- (NSString*)description
{
  return [NSString stringWithFormat:@"%d (%d) : %@", self.number, self.index, NSStringFromRange(self.range)];
}

+ (MHLineNumber*)lineNumberContainingIndex:(NSInteger)anIndex inArray:(NSArray*)lineNumbers
{
  for (MHLineNumber *line in lineNumbers) {
    if (anIndex >= line.range.location && anIndex < NSMaxRange(line.range)) {
      return line;
    }
  }
  return nil;
}

@end
