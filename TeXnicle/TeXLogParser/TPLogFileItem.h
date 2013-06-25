//
//  TPLogFileItem.h
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPLogItem;

@interface TPLogFileItem : NSObject

@property (copy) NSString *filename;
@property (copy) NSString *fullpath;
@property (strong) NSMutableArray *items;

- (id) initWithLogItem:(TPLogItem*)anItem;

- (void) addLogItem:(TPLogItem*)anItem;

- (NSArray*)infos;
- (NSArray*)warnings;
- (NSArray*)errors;

@end
