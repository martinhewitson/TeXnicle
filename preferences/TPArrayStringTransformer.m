//
//  TPArrayStringTransformer.m
//  TeXnicle
//
//  Created by Martin Hewitson on 19/12/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "TPArrayStringTransformer.h"
#import "RegexKitLite.h"

@implementation TPArrayStringTransformer

+ (Class)transformedValueClass
{
	return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)aValue
{
//	NSLog(@"Transforming %@ [%@]", aValue, [aValue class]);
	NSArray *array = aValue;
	NSString *res = [array componentsJoinedByString:@", "];
	return res;
}

- (id)reverseTransformedValue:(id)aValue
{
	NSString *string = aValue;
//	NSLog(@"Reverse Transforming %@ [%@]", aValue, [aValue class]);
	NSArray *results = [string componentsSeparatedByString:@","];
	NSMutableArray *words = [NSMutableArray array];
	for (NSString *r in results) {
		if (![r isEqual:@""]) {
			[words addObject:[r stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		}
	}
//	NSLog(@"Got words: %@", words);
	return words;
}

@end
