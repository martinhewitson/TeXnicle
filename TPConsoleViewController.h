//
//  TPConsoleViewControllerViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 10/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHConsoleViewer.h"
#import "MHStrokedFiledView.h"

@interface TPConsoleViewController : NSViewController <MHConsoleViewer> {
@private
  IBOutlet NSTextView *textView;
	IBOutlet NSPopUpButton *displayLevel;
  IBOutlet MHStrokedFiledView *toolbarView;
  
}

- (void) handleUserDefaultsChanged:(NSNotification*)aNote;
- (IBAction) clear:(id)sender;
- (void) appendText:(NSString*)someText;
- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor;
- (void) error:(NSString*)someText;
- (void) message:(NSString*)someText;

- (IBAction) displayLevelChanged:(id)sender;

@end
