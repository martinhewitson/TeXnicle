//
//  TPSpellingOutlineView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 08/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
	
	NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Spelling Context Menu"];
	
	[theMenu setAutoenablesItems:NO];
	
	//------ Add existing file
	NSMenuItem *menuItem;
	
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Check Spelling Now..."
																				action:@selector(forceUpdate:)
																 keyEquivalent:@""];
	[theMenu addItem:menuItem];
	[menuItem release];
		
	return [theMenu autorelease];
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
