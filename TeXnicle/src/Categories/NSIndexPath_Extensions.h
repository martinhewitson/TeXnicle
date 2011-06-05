//
//  NSIndexPath_Extensions.h
//  SortedTree
//
//  Created by Jonathan Dann on 14/05/2008.
//
// Copyright (c) 2008 Jonathan Dann

#import <Cocoa/Cocoa.h>


@interface NSIndexPath (ESExtensions)
- (NSUInteger)firstIndex;
- (NSUInteger)lastIndex;
- (NSIndexPath *)indexPathByIncrementingLastIndex;
- (NSIndexPath *)indexPathByReplacingIndexAtPosition:(NSUInteger)position withIndex:(NSUInteger)index;
@end
