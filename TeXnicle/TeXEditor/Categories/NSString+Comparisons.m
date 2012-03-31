//
//  NSString+Comparisons.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
