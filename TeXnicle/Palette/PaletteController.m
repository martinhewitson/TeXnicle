//
//  PaletteController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 14/2/10.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "PaletteController.h"
#import "NSWorkspaceExtended.h"
#import "externs.h"
#import "NSApplication+Palette.h"

@implementation PaletteController

- (id) initWithDelegate:(id<PaletteControllerDelegate>)aDelegate
{
  self = [super initWithNibName:@"PaletteController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
  }
  return self;
}

- (void) tearDown
{
  NSLog(@"Tear down %@", self);
  symbolsTable.delegate = nil;
  symbolsTable.dataSource = nil;
  [palettesController setContent:nil];
  self.delegate = nil;
  self.palette = nil;
}

- (void) awakeFromNib
{
  
  // set row height
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [slider setFloatValue:[[defaults valueForKey:TPPaletteRowHeight] floatValue]];
	[symbolsTable setRowHeight:[slider floatValue]];
	
  self.palette = [NSApplication sharedPalette];
  
	[palettesController setContent:self.palette.palettes];
	
//	NSLog(@"Loaded palette: %@", [palettesController arrangedObjects]);
	
	// Register the symbols table for dragging strings
	[symbolsTable registerForDraggedTypes:@[NSStringPboardType]];	
	[symbolsTable setVerticalMotionCanBeginDrag:YES];
  
  [symbolsTable setTarget:self];
  [symbolsTable setDoubleAction:@selector(handleTableDoubleClick)];
}


- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == insertButton) {
    return [self hasSelection] && [self paletteCanInsertText:self];
  }
  return YES;
}

- (IBAction) setRowHeight:(id)sender
{
	CGFloat height = [sender floatValue];
	[symbolsTable setRowHeight:height];
  // write to user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  [defaults setValue:[NSNumber numberWithFloat:height] forKey:TPPaletteRowHeight];
  [defaults synchronize];
}

- (NSArray*) listOfCommands
{
	NSMutableArray *commands = [[NSMutableArray alloc] init];
	if (self.palette.palettes) {
		// load all images
		for (NSDictionary *p in self.palette.palettes) {
			NSArray *symbols = [p valueForKey:@"Symbols"];
			for (NSMutableDictionary *symbol in symbols) {
				[commands addObject:[symbol valueForKey:@"Code"]];
			}
		}
	}	
	return commands;
}

- (void) handleTableDoubleClick
{
  if ([self paletteCanInsertText:self]) {
    [self insertSelectedSymbols:self];
  }
}

- (IBAction) insertSelectedSymbols:(id)sender
{
  
  NSArray *items = [symbolsController selectedObjects];
  NSMutableArray *strings = [NSMutableArray array];
  for (id symbol in items) {
    [strings addObject:[symbol valueForKey:@"Code"]];
  }
  
  NSString *string = [strings componentsJoinedByString:@" "];
  
  [self palette:self insertText:string];
}


#pragma mark -
#pragma mark Symbol table data source

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{
	if (aTableView == symbolsTable) {
		NSDictionary *symbol = [symbolsController arrangedObjects][row];
		return [symbol valueForKey:@"Code"];
	}
	
	return @"";
}


- (BOOL)tableView:(NSTableView *)aTableView 
writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
		 toPasteboard:(NSPasteboard*)pboard
{
	//NSLog(@"Table delegate ");
	
	if (aTableView == symbolsTable) {
		
	
		NSArray *items = [symbolsController arrangedObjects];			
		NSUInteger bufSize = [rowIndexes count];
		NSUInteger buf[bufSize];
		[rowIndexes getIndexes:buf maxCount:bufSize inIndexRange:nil];		
		NSUInteger idx;		
		NSMutableArray *strings = [NSMutableArray array];
		for (idx = 0; idx < bufSize; idx++) {
			NSDictionary *symbol = items[buf[idx]];
			[strings addObject:[symbol valueForKey:@"Code"]];
		}
		[pboard declareTypes:@[NSStringPboardType] owner:self];

		return [pboard setString:[strings componentsJoinedByString:@" "] forType:NSStringPboardType];
	}
	
	return NO;
}

- (BOOL) hasSelection
{
  return [[symbolsTable selectedRowIndexes] count] > 0;
}


#pragma mark -
#pragma mark PaletteController Delegate

- (BOOL)paletteCanInsertText:(PaletteController*)aPalette
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(paletteCanInsertText:)]) {
    return [self.delegate paletteCanInsertText:self];
  }
  return NO;
}

- (void)palette:(PaletteController*)aPalette insertText:(NSString*)aString
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(palette:insertText:)]) {
    [self.delegate palette:self insertText:aString];
  }
}



@end
