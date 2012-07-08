//
//  TPSpellingOutlineView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 08/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSpellingOutlineView.h"
#import "TPMisspelledWord.h"

@implementation TPSpellingOutlineView

#pragma mark -
#pragma mark Context Menu

-(NSMenu*)menuForEvent:(NSEvent*)evt 
{
	NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
	NSInteger row=[self rowAtPoint:pt];
	
	// Main tree context menu
	if (row < 0) {
		return [self defaultMenu];
	}
	return [self defaultMenuForRow:row];
}


- (NSMenu*)defaultMenu
{
	
	NSMenu *theMenu = [[[NSMenu alloc] 
											initWithTitle:@"Spelling Context Menu"] 
										 autorelease];
	
	[theMenu setAutoenablesItems:NO];
	
	//------ Add existing file
	NSMenuItem *menuItem;
	
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Check Spelling Now..."
																				action:@selector(forceUpdate:)
																 keyEquivalent:@""];
	[theMenu addItem:menuItem];
	[menuItem release];
		
	return theMenu;
}

#pragma mark -
#pragma mark Menu for item

-(NSMenu*)defaultMenuForRow:(NSInteger)row
{  
	if (row < 0) return nil;
	
	selectedRow = row;
	[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
  //  [treeController setSelectionIndexPath:[NSIndexPath indexPathWithIndex:row]];
  
	// get the object for this row
  //	NSArray *items = [treeController selectedObjects]; //[treeController flattenedContent];
	selectedItem = [self itemAtRow:row];  
  
  if ([selectedItem isMemberOfClass:[TPMisspelledWord class]]) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(correctionMenuForWord:withTarget:)]) {
      
      NSMenu *theMenu = [self.delegate performSelector:@selector(correctionMenuForWord:withTarget:) withObject:selectedItem withObject:self];
      return theMenu;
    }
  }
	
	return nil;        
}

- (IBAction)selectedCorrection:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(selectedCorrection:)]) {
    [self.delegate performSelector:@selector(selectedCorrection:) withObject:sender];
  }
  
}

@end
