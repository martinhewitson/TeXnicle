//
//  TeXFileEntity.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "TeXFileEntity.h"

@implementation TeXFileEntity


- (void) awakeFromInsert
{
	[super awakeFromInsert];
	[self setValue:@"tex" forKey:@"extension"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"isText"];
}

- (BOOL) isLeaf
{
	return YES;
}


- (BOOL) isMainFile
{
	if ([[self valueForKey:@"project"] valueForKey:@"mainFile"] == self) {
		return YES;
	}
	
	return NO;
}

@end
