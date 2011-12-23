//
//  PaletteController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 14/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HHValidatedButton.h"

@class PaletteController;

@protocol PaletteControllerDelegate <NSObject>

- (BOOL)paletteCanInsertText:(PaletteController*)aPalette;
- (void)palette:(PaletteController*)aPalette insertText:(NSString*)aString;

@end

@interface PaletteController : NSViewController <NSTableViewDelegate, PaletteControllerDelegate, NSUserInterfaceValidations> {

	NSDictionary *palette;
	
	NSArray *palettes;
	IBOutlet NSArrayController *palettesController;
	IBOutlet NSArrayController *symbolsController;
	
//	IBOutlet NSSegmentedControl *tabControl;
//	IBOutlet NSTabView *tabView;
	IBOutlet NSTableView *symbolsTable;
	
	IBOutlet NSSlider *slider;
  
  IBOutlet HHValidatedButton *insertButton;
  
  id<PaletteControllerDelegate> delegate;
}

@property (assign) id<PaletteControllerDelegate> delegate;
@property (retain) NSArray *palettes;

- (id) initWithDelegate:(id<PaletteControllerDelegate>)aDelegate;

- (void) loadPalette;
- (NSArray*) listOfCommands;

- (NSImage*) generateImageForCode:(NSString*)code atPath:(NSString*)aPath inMathMode:(BOOL)mathMode;

- (IBAction) setRowHeight:(id)sender;
- (IBAction) insertSelectedSymbols:(id)sender;
- (void) handleTableDoubleClick;

- (BOOL) hasSelection;

@end
