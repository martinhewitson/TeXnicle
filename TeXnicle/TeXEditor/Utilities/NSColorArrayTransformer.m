//
//  NSColorArrayTransformer.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "NSColorArrayTransformer.h"
#import "NSArray+Color.h"

@implementation NSColorArrayTransformer

+ (Class)transformedValueClass
{
	return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)aValue
{
	NSArray *colorArray = aValue;
	return [colorArray colorValue];
}

- (id)reverseTransformedValue:(id)value
{
	return [NSArray arrayWithColor:value]; 
}

@end
