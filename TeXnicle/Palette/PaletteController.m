//
//  PaletteController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 14/2/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "PaletteController.h"
#import "NSWorkspaceExtended.h"
#import "externs.h"

@implementation PaletteController


//static PaletteController *sharedPaletteController = nil;


//- (id)init
//{
//  Class PaletteController = [self class];
//  @synchronized(PaletteController) {
//    if (sharedPaletteController == nil) {
//      if ((self = [super init])) {
//        sharedPaletteController = self;
//        // custom initialization here
//      }
//    }
//  }
//  return sharedPaletteController;
//}

- (void) dealloc
{
	[palettes release];
	
	[super dealloc];
}

- (void) awakeFromNib
{
  
  // set row height
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [slider setFloatValue:[[defaults valueForKey:TPPaletteRowHeight] floatValue]];
	[symbolsTable setRowHeight:[slider floatValue]];
  
	[self loadPalette];
	[palettesController setContent:palettes];
	
//	NSLog(@"Loaded palette: %@", [palettesController arrangedObjects]);
	
	// Register the symbols table for dragging strings
	[symbolsTable registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];	
  
  [symbolsTable setTarget:self];
  [symbolsTable setDoubleAction:@selector(handleTableDoubleClick)];
}

- (void) loadPalette
{
	// Load the dictionary
	NSString *path = [[NSBundle mainBundle] pathForResource:@"palette" ofType:@"plist"];
	palette = [NSDictionary dictionaryWithContentsOfFile:path];
	
	palettes = [palette valueForKey:@"Palettes"];
//	palettes = [[palette valueForKey:@"Palettes"] retain];
	
	// load all images
	for (NSDictionary *p in palettes) {
		
		NSArray *symbols = [p valueForKey:@"Symbols"];
		for (NSMutableDictionary *symbol in symbols) {
			
			NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[symbol valueForKey:@"Image"]];
//			NSLog(@"Loading image: %@", imagePath);			
			NSImage *image = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
//      NSLog(@" ... %@", image);
			if (!image) {
//        NSLog(@"... Generating image");
				image = [self generateImageForCode:[symbol valueForKey:@"Code"] 
																		atPath:imagePath 
																inMathMode:[[symbol valueForKey:@"mathMode"] boolValue]];
				if (!image) {
					image = [[[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]] autorelease];				
				}
			}
			[symbol setObject:image forKey:@"ImageData"];
			//[image release];
			//			[image release];
			//			NSLog(@"Loaded image data %@", [symbol valueForKey:@"ImageData"]);
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
	if (palettes) {
		// load all images
		for (NSDictionary *p in palettes) {		
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
  [self insertSelectedSymbols:self];
}

- (IBAction) insertSelectedSymbols:(id)sender
{
	// get the selected text
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if (doc) {
		
		if ([doc respondsToSelector:@selector(insertTextToCurrentDocument:)]) {
			NSArray *items = [symbolsController selectedObjects];
			NSMutableArray *strings = [NSMutableArray array];
			for (id symbol in items) {
				[strings addObject:[symbol valueForKey:@"Code"]];
			}
			
			NSString *string = [strings componentsJoinedByString:@" "];
			[doc performSelector:@selector(insertTextToCurrentDocument:) withObject:string];
		}		
	}
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
	[doc writeToFile:filepath atomically:YES
					encoding:NSUTF8StringEncoding
						 error:&error];
	if (error) {
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
	[fm copyItemAtPath:croppedPDF toPath:aPath error:&error];
	if (error) {
		//NSLog(@"Failed to copy %@ to %@", croppedPDF, aPath);
		[NSApp presentError:error];
		return nil;
	}
	
	// read pdf data in
//	NSData *data = [NSData dataWithContentsOfFile:croppedPDF];
	NSImage *pdfimage = [[[NSImage alloc] initWithContentsOfFile:croppedPDF] autorelease];
	//NSLog(@"made image at: %@", aPath);
	return pdfimage;
}

//+ (PaletteController*)sharedPaletteController
//{
//	@synchronized(self) {
//		if (sharedPaletteController == nil) {
//			[[self alloc] init]; // assignment not done here
//		}
//	}
//	//NSLog(@"Someone got me %@", sharedPaletteController);
//	return sharedPaletteController;
//}
//
//+ (id)allocWithZone:(NSZone *)zone
//{
//	@synchronized(self) {
//		if (sharedPaletteController == nil) {
//			sharedPaletteController = [super allocWithZone:zone];
//			return sharedPaletteController;  // assignment and return on first allocation
//		}
//	}
//	return nil; //on subsequent allocation attempts return nil
//}
//
//- (id)copyWithZone:(NSZone *)zone
//{
//	return self;
//}
//
//- (id)retain
//{
//	return self;
//}
//
//- (NSUInteger)retainCount
//{
//	return UINT_MAX;  //denotes an object that cannot be released
//}
//
//- (void)release
//{
//	//do nothing
//}
//
//- (id)autorelease
//{
//	return self;
//}

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

@end
