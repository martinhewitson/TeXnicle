//
//  SymbolTableDelegate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 14/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "SymbolTableDelegate.h"


@implementation SymbolTableDelegate

- (void) awakeFromNib
{
	[symbolsTable registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
	[symbolsTable setVerticalMotionCanBeginDrag:YES];
	
	//NSLog(@"Awaking with %@", symbolsTable);
	
}

- (BOOL)tableView:(NSTableView *)aTableView 
writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
		 toPasteboard:(NSPasteboard*)pboard
{
	//NSLog(@"Table delegate ");
	
//	if (aTableView == symbolsTable) {
//		
//		
//		NSUInteger row = [aTableView selectedRow];
//		NSDictionary *symbol = [[symbolsController arrangedObjects] objectAtIndex:row];
//		
//		[pboard setString:[symbol valueForKey:@"Code"] forType:NSStringPboardType];
//		
//		
//		return YES;
//		
//	}
	
	return NO;
}

@end
