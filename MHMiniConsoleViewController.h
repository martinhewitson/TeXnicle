//
//  MHMiniConsoleViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHConsoleViewer.h"

@interface MHMiniConsoleViewController : NSViewController <MHConsoleViewer> {
@private
  NSTextField *textField;
}

@property (assign) IBOutlet NSTextField *textField;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;

- (void) setAnimating:(BOOL)state;

@end
