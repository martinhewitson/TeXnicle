//
//  TPLibraryEntry.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPLibraryEntry.h"
#import "TPLibraryCategory.h"
#import "NSStringUUID.h"

@implementation TPLibraryEntry

@dynamic sortIndex;
@dynamic command;
@dynamic imageIsValid;
@dynamic isBuiltIn;
@dynamic uuid;
@dynamic code;
@dynamic image;
@dynamic category;

- (void) awakeFromInsert
{
  self.uuid = [NSString stringWithUUID];
}

- (NSDictionary*)dictionary
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"uuid" : self.uuid,
                                                                              @"command" : @"",
                                                                              @"code" : @"",
                                                                              @"categoryName" : self.category.name}];
  
  if (self.command) {
    [dict setObject:self.command forKey:@"command"];
  }
  
  if (self.code) {
    [dict setObject:self.code forKey:@"code"];
  }
  
  return dict;
}

@end
