//
//  MHLineNumber.m
//  TeXEditor
//
//  Created by Martin Hewitson on 03/04/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHLineNumber.h"


@implementation MHLineNumber

@synthesize number;
@synthesize index;
@synthesize range;

+ (MHLineNumber*) lineNumberWithValue:(NSUInteger)lineNumber index:(NSUInteger)anIndex range:(NSRange)aRange
{
  return [[[MHLineNumber alloc] initWithLineNumberWithValue:lineNumber index:anIndex range:aRange] autorelease];
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

- (void)dealloc
{
  [super dealloc];
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
