//
//  PaletteController.h
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
