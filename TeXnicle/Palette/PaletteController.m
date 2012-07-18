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

@implementation PaletteController

@synthesize delegate;
@synthesize palettes;

- (id) initWithDelegate:(id<PaletteControllerDelegate>)aDelegate
{
  self = [super initWithNibName:@"PaletteController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
  }
  return self;
}

- (void) dealloc
{
  symbolsTable.delegate = nil;
  symbolsTable.dataSource = nil;
  [palettesController setContent:nil];
  self.delegate = nil;
  self.palettes = nil;
	[super dealloc];
}

- (void) awakeFromNib
{
  
  // set row height
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [slider setFloatValue:[[defaults valueForKey:TPPaletteRowHeight] floatValue]];
	[symbolsTable setRowHeight:[slider floatValue]];
	
  
	[self loadPalette];
	[palettesController setContent:self.palettes];
	
//	NSLog(@"Loaded palette: %@", [palettesController arrangedObjects]);
	
	// Register the symbols table for dragging strings
	[symbolsTable registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];	
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

- (void) loadPalette
{
	// Load the dictionary
	NSString *path = [[NSBundle mainBundle] pathForResource:@"palette" ofType:@"plist"];
	palette = [NSDictionary dictionaryWithContentsOfFile:path];
	
	self.palettes = [palette valueForKey:@"Palettes"];
	
	// load all images
	for (NSDictionary *p in self.palettes) {
		
		NSArray *symbols = [p valueForKey:@"Symbols"];
		for (NSMutableDictionary *symbol in symbols) {
			
			NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[symbol valueForKey:@"Image"]];
//			NSLog(@"Loading image: %@", imagePath);			
			NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
//      NSLog(@" ... %@", image);
			if (!image) {
//        NSLog(@"... Generating image");
				image = [[self generateImageForCode:[symbol valueForKey:@"Code"]
																		atPath:imagePath 
																inMathMode:[[symbol valueForKey:@"mathMode"] boolValue]] retain];
				if (!image) {
					image = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
				}
			}
			[symbol setObject:image forKey:@"ImageData"];
			[image release];
		}
	}
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
	if (self.palettes) {
		// load all images
		for (NSDictionary *p in self.palettes) {		
			NSArray *symbols = [p valueForKey:@"Symbols"];
			for (NSMutableDictionary *symbol in symbols) {
				[commands addObject:[symbol valueForKey:@"Code"]];
			}
		}
	}	
	return [commands autorelease];
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
  
//	// get the selected text
//	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
//	if (doc) {
//		
//		if ([doc respondsToSelector:@selector(insertTextToCurrentDocument:)]) {
//			NSArray *items = [symbolsController selectedObjects];
//			NSMutableArray *strings = [NSMutableArray array];
//			for (id symbol in items) {
//				[strings addObject:[symbol valueForKey:@"Code"]];
//			}
//			
//			NSString *string = [strings componentsJoinedByString:@" "];
//			[doc performSelector:@selector(insertTextToCurrentDocument:) withObject:string];
//		}		
//	}
}

- (NSImage*) generateImageForCode:(NSString*)code atPath:(NSString*)aPath inMathMode:(BOOL)mathMode
{
	// create doc string
	NSMutableString *doc = [[NSMutableString alloc] init];
	
	[doc appendString:@"\\documentclass[136pt]{article}\n"];
	[doc appendString:@"\\usepackage[usenames]{color}\\color[rgb]{0,0,0} %used for font color\n"];
	[doc appendString:@"\\usepackage{amssymb} %maths\n"];
	[doc appendString:@"\\usepackage{amsmath} %maths\n"];
	[doc appendString:@"\\usepackage[utf8]{inputenc} %useful to type directly diacritic characters\n"];
	if (mathMode) {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}{$%@$\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	} else {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}%@\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	}
	
	
	// write tmp file
	NSString* workingDirectory =  [[NSWorkspace sharedWorkspace] temporaryDirectory];
	NSString *filepath = [workingDirectory stringByAppendingPathComponent:@"texnicle.tex"];
	
	//NSLog(@"Tmp dir: %@", filepath);
	NSError *error = nil;
  BOOL success;
	success = [doc writeToFile:filepath atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:&error];
	if (success == NO) {
		[doc release];
		[NSApp presentError:error];
		return nil;
	}
	
	[doc release];
	
  // file://localhost/private/var/folders/V3/V3+QAXE-HIi9y796X1o4Q++++TI/-Tmp-/TeXnicle-1/
	
	// pdflatex it
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *gspath = [[defaults valueForKey:TPGSPath] stringByDeletingLastPathComponent];
	NSString *texpath = [[defaults valueForKey:TPPDFLatexPath] stringByDeletingLastPathComponent]; 
	NSString *croppedPDF = [workingDirectory stringByAppendingPathComponent:@"cropped.pdf"];
	NSString* script = [NSString stringWithFormat:@"%@/makePDFimage.sh",[[NSBundle mainBundle] resourcePath]];
	
	NSString *cmd = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", script, workingDirectory, filepath, croppedPDF, texpath, gspath] ;
	//NSLog(@"Executing '%@'", cmd);
	system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// Copy cropped pdf to the right path
	NSFileManager *fm = [NSFileManager defaultManager];
	success = [fm copyItemAtPath:croppedPDF toPath:aPath error:&error];
	if (success == NO) {
		//NSLog(@"Failed to copy %@ to %@", croppedPDF, aPath);
		[NSApp presentError:error];
		return nil;
	}
	
	// read pdf data in
//	NSData *data = [NSData dataWithContentsOfFile:croppedPDF];
	NSImage *pdfimage = [[NSImage alloc] initWithContentsOfFile:croppedPDF];
	//NSLog(@"made image at: %@", aPath);
	return [pdfimage autorelease];
}



#pragma mark -
#pragma mark Symbol table data source

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{
	if (aTableView == symbolsTable) {
		NSDictionary *symbol = [[symbolsController arrangedObjects] objectAtIndex:row];
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
			NSDictionary *symbol = [items objectAtIndex:buf[idx]];
			[strings addObject:[symbol valueForKey:@"Code"]];
		}
		[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];

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
