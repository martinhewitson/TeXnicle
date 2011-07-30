//
//  PaletteController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 14/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PaletteController : NSWindowController <NSTableViewDelegate> {

	NSDictionary *palette;
	
	NSArray *palettes;
	IBOutlet NSArrayController *palettesController;
	IBOutlet NSArrayController *symbolsController;
	
	IBOutlet NSSegmentedControl *tabControl;
	IBOutlet NSTabView *tabView;
	IBOutlet NSTableView *symbolsTable;
	
	IBOutlet NSSlider *slider;
}

//+ (PaletteController*)sharedPaletteController;
- (void) loadPalette;
- (NSArray*) listOfCommands;

- (NSImage*) generateImageForCode:(NSString*)code atPath:(NSString*)aPath inMathMode:(BOOL)mathMode;

- (IBAction) setRowHeight:(id)sender;
- (IBAction) insertSelectedSymbols:(id)sender;
- (void) handleTableDoubleClick;

@end
