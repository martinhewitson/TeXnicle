//
//  TPParsedLog.h
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPParsedLog : NSObject


- (id) initWithLogFileAtPath:(NSString*)aPath;
- (id) initWithLogFileAtURL:(NSURL*)aURL;

@property (strong) NSMutableArray *logfiles;

- (void) setLogFile:(NSString*)aPath;

@end
