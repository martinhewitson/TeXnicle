//
//  NSArray+LogParser.h
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (LogParser)

- (NSArray*)infoItems;
- (NSArray*)warningItems;
- (NSArray*)errorItems;

@end
