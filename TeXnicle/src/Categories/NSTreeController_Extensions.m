//
//  NSTreeController_Extensions.m
//  SortedTree
//
//  Created by Jonathan Dann on 14/05/2008.
//
// Copyright (c) 2008 Jonathan Dann
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "Sorted Tree" by Jonathan Dann" will do.

#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"
#import "NSArray_Extensions.h"

@implementation NSTreeController (ESExtensions)



- (NSIndexPath *)indexPathToObject:(id)object
{
	return [[self treeNodeForObject:object] indexPath];
}


// will create an NSIndexPath after the selection, or as for the top of the children of a group node
- (NSIndexPath *)indexPathForInsertion;
{
	NSUInteger rootTreeNodesCount = [[self rootNodes] count];
	NSArray *selectedNodes = [self selectedNodes];
	NSTreeNode *selectedNode = [selectedNodes firstObject];
	NSIndexPath *indexPath;
	
	if ([selectedNodes count] == 0) {
//		NSLog(@"rootTreeNodesCount = %d", rootTreeNodesCount);
		indexPath = [NSIndexPath indexPathWithIndex:rootTreeNodesCount];
	} else if ([selectedNodes count] == 1) {
		if (![selectedNode isLeaf]) {
//			NSLog(@"Not a leaf - adding at index 0");
			indexPath = [[selectedNode indexPath] indexPathByAddingIndex:0];
		} else {
//			NSLog(@"Leaf node");
			if ([selectedNode parentNode]) {
//				NSLog(@"is Parent node");
				indexPath = [selectedNode adjacentIndexPath];
			} else {
//				NSLog(@"is not Parent node - returning %d", rootTreeNodesCount);
				indexPath = [NSIndexPath indexPathWithIndex:rootTreeNodesCount];
			}
		}
	} else
		indexPath = [[selectedNodes lastObject] adjacentIndexPath];
	return indexPath;
}

// makes a blank selection in the outline view
- (void)selectNone;
{
	[self removeSelectionIndexPaths:[self selectionIndexPaths]];
}

- (NSArray *)rootNodes;
{
	return [[self arrangedObjects] childNodes];
}

- (NSTreeNode *)nodeAtIndexPath:(NSIndexPath *)indexPath;
{
	return [[self arrangedObjects] descendantNodeAtIndexPath:indexPath];
}

// all the real objects in the tree, depth-first searching
- (NSArray *)flattenedContent;
{
	return [[self flattenedNodes] valueForKey:@"representedObject"];
}

// all the NSTreeNodes in the tree, depth-first searching
- (NSArray *)flattenedNodes
{
	NSMutableArray *mutableArray = [NSMutableArray array];
	for (NSTreeNode *node in [self rootNodes]) {
		[mutableArray addObject:node];		
		NSArray *decs = [node descendants];
		[mutableArray addObjectsFromArray:decs];
	}
	return [mutableArray copy];	
}

- (NSTreeNode *)treeNodeForObject:(id)object;
{
	NSTreeNode *treeNode = nil;
	for (NSTreeNode *node in [self flattenedNodes]) {
		if ([node representedObject] == object) {
			treeNode = node;
			break;
		}
	}
	return treeNode;
}

- (void)selectParentFromSelection;
{
	if ([[self selectedNodes] count] == 0)
		return;
	
	NSTreeNode *parentNode = [[[self selectedNodes] firstObject] parentNode];
	if (parentNode)
		[self setSelectionIndexPath:[parentNode indexPath]];
	else
		// no parent exists (we are at the top of tree), so make no selection in our outline
		[self selectNone];
}

- (NSTreeNode *)nextSiblingOfNodeAtIndexPath:(NSIndexPath *)indexPath;
{
	return [[self arrangedObjects] descendantNodeAtIndexPath:[indexPath indexPathByIncrementingLastIndex]];
}

- (NSTreeNode *)nextSiblingOfNode:(NSTreeNode *)node;
{
	return [self nextSiblingOfNodeAtIndexPath:[node indexPath]];
}
@end
