//
//  NSDictionary+Theme.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "NSDictionary+Theme.h"

@implementation NSDictionary (Theme)

- (NSColor*)colorForKey:(NSString*)aKey
{
  NSString *val = [self valueForKey:aKey];
  if (val == nil) {
    return nil;
  }
  NSArray *parts = [val componentsSeparatedByString:@" "];
  CGFloat r = [parts[0] doubleValue];
  CGFloat g = [parts[1] doubleValue];
  CGFloat b = [parts[2] doubleValue];
  CGFloat a = 1.0;
  if ([parts count] > 3) {
    a = [parts[3] doubleValue];
  }
  NSColor *c = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
  return c;
}

- (NSArray*)sortedKeys
{
  NSArray *allKeys = [self allKeys];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (self contains[c] 'active') AND NOT (self contains[c] 'bold')"];
  allKeys = [allKeys filteredArrayUsingPredicate:predicate];
  return [allKeys sortedArrayUsingSelector:@selector(compare:)];
}

@end
