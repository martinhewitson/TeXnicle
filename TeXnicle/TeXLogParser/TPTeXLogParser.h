//
//  TPTeXLogParser.h
//  TeXnicle
//
//  Created by Martin Hewitson on 23/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "MHFileReader.h"

@interface TPTeXLogParser : NSObject

+ (NSDictionary*)errorPhrases;
+ (NSArray*) parseLogFileAtPath:(NSString*)aPath;
+ (NSArray*) parseLogFileAtURL:(NSURL*)aURL;
+ (NSArray*) parseLogText:(NSString*)logText;


@end
