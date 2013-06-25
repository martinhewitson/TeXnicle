//
//  NSArray+LogParser.m
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "NSArray+LogParser.h"
#import "TPLogItem.h"

@implementation NSArray (LogParser)

- (NSArray*)infoItems
{
  return [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == %ld", TPLogInfo]];
}

- (NSArray*)warningItems
{
  return [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == %ld", TPLogWarning]];
}

- (NSArray*)errorItems
{
  return [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == %ld", TPLogError]];
}


@end
