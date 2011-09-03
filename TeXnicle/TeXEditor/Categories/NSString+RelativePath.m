//
//  NSString+RelativePath.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
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
