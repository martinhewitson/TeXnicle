//
//  NSString+Comparisons.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "NSString+Comparisons.h"


@implementation NSString (Comparisons)

- (BOOL) endsWith:(NSString*)aString
{
	NSComparisonResult res;
	
	//	NSLog(@"Checking if '%@' begins with '%@'", self, aString);
	
	NSInteger slen = [aString length];
	if ([aString length] <= [self length]) {
		res = [self compare:aString options:NSLiteralSearch range:NSMakeRange([self length]-slen, slen)];
	} else {
		return NO;
//		res = [self compare:aString options:NSLiteralSearch range:NSMakeRange(0, [self length])];
	}
	
	if (res == NSOrderedSame)
		return YES;
	
	return NO;
}


- (BOOL) beginsWith:(NSString*)aString
{
	return [self hasPrefix:aString];
	
	NSComparisonResult res;
	
//	NSLog(@"Checking if '%@' begins with '%@'", self, aString);
	
	if ([aString length] <= [self length]) {
		res = [self compare:aString options:NSLiteralSearch range:NSMakeRange(0, [aString length])];
	} else {
		res = [self compare:aString options:NSLiteralSearch range:NSMakeRange(0, [self length])];
	}

	if (res == NSOrderedSame)
		return YES;
	
	return NO;
}

- (BOOL) isTextFile
{
	// Create an array of strings specifying valid extensions and HFS file types.
	NSArray *fileTypes = [NSArray arrayWithObjects:
												@"txt",
												@"text",
												NSFileTypeForHFSTypeCode('TEXT'),
												nil];
	
	// Try to get the HFS file type as a string.
	NSString *fileType = NSHFSTypeOfFile(self);
	
	if ([fileType isEqualToString:@"''"])
	{
		// No HFS type; get the extension instead.
		fileType = [self pathExtension];
	}
	
	return [fileTypes containsObject:fileType];
}

@end
