//
//  NSString+RelativePath.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/2/10.
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
//
// Adapted from code found here: http://forum.soft32.com/mac/Relative-path-NSURL-ftopict45712.html
//


#import "NSString+RelativePath.h"


@implementation NSString (RelativePath)


// Assumes that self and endPath are absolute file paths. 
// Example: [ @"/a/b/c/d" relativePathTo: @"/a/e/f/g/h"] => @"../../e/f/g/h". 
- (NSString*) relativePathTo: (NSString*) endPath 
{ 
//	NSLog(@"Computing %@ relative to %@", endPath, self);
	NSAssert( ! [self isEqual: endPath], @"illegal link to self"); 
	NSArray* startComponents = [self pathComponents]; 
	NSArray* endComponents = [endPath pathComponents]; 
	NSMutableArray* resultComponents = nil; 
	int prefixCount = 0; 
	if( ! [self isEqual: endPath] ){ 
		NSInteger iLen = MIN([startComponents count], [endComponents count]); 
		for(prefixCount = 0; prefixCount < iLen && [[startComponents objectAtIndex: prefixCount] isEqual: [endComponents objectAtIndex: prefixCount]]; ++prefixCount){} 
	} 
	if(0 == prefixCount){ 
		resultComponents = [NSMutableArray arrayWithArray: endComponents]; 
	}else{ 
		resultComponents = [NSMutableArray arrayWithArray: [endComponents subarrayWithRange: NSMakeRange(prefixCount, [endComponents count] - prefixCount)]]; 
		NSInteger lifterCount = [startComponents count] - prefixCount; 
		if(1 == lifterCount){ 
			[resultComponents insertObject: @"." atIndex: 0]; 
		}else{ 
			--lifterCount; 
			for(int i = 0; i < lifterCount; ++i){ 
				[resultComponents insertObject: @".." atIndex: 0]; 
			} 
		} 
	} 
	//NSLog(@"Computed: %@", [NSString pathWithComponents: resultComponents]);
	return [NSString pathWithComponents: resultComponents]; 
} 

@end
