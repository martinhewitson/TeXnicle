//
//  ConsoleController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHConsoleViewer.h"

@interface ConsoleController : NSWindowController <MHConsoleViewer> {

	IBOutlet NSTextView *textView;
	IBOutlet NSPopUpButton *displayLevel;
	
}

+ (ConsoleController*)sharedConsoleController;
- (void) handleUserDefaultsChanged:(NSNotification*)aNote;

- (IBAction) clear:(id)sender;
- (void) appendText:(NSString*)someText;
- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor;
- (void) error:(NSString*)someText;
- (void) message:(NSString*)someText;

- (IBAction) displayLevelChanged:(id)sender;

@end
