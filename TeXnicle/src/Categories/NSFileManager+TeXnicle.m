//
//  NSFileManager+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "NSFileManager+TeXnicle.h"


@implementation NSFileManager (TeXnicle)

+ (BOOL) directoryExists:(NSString*)path
{
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
		if (isDir) {
			return YES;
		}
	}
	return NO;
}


+ (NSString*)fileTypeAtPath:(NSString*)path
{
	NSError *error = nil;
	NSDictionary *atts = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
	if (error) {
		[NSApp presentError:error];
		return nil;
	}
	
	return [atts fileType];	
}

@end
