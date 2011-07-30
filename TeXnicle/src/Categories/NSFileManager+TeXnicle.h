//
//  NSFileManager+TeXnicle.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (TeXnicle)

+ (BOOL) directoryExists:(NSString*)path;
+ (NSString*) fileTypeAtPath:(NSString*)path;


@end
