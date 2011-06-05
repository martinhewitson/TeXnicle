//
//  ConsoleController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConsoleController : NSWindowController {

	IBOutlet NSTextView *textView;
	IBOutlet NSPopUpButton *displayLevel;
	
}

+ (ConsoleController*)sharedConsoleController;
- (IBAction) clear:(id)sender;
- (void) appendText:(NSString*)someText;
- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor;
- (void) error:(NSString*)someText;
- (void) message:(NSString*)someText;

- (IBAction) displayLevelChanged:(id)sender;

@end
