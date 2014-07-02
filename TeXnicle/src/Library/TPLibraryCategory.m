//
//  TPLibraryCategory.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPLibraryCategory.h"
#import "TPLibraryEntry.h"


@implementation TPLibraryCategory

@dynamic name;
@dynamic entries;
@dynamic sortIndex;

- (NSDictionary*)dictionary
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : self.name}];
  NSMutableArray *entries = [NSMutableArray array];
  for (TPLibraryEntry *entry in self.entries) {
    [entries addObject:[entry dictionary]];
  }
  
  [dict setObject:entries forKey:@"entries"];
  
  return dict;
}


@end
