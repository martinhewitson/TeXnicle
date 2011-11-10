//
//  TPStatusViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/11/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHToolbarBackgroundView.h"


@interface TPStatusViewController : NSViewController {
  NSString *_editorStatusText;
  NSString *_filenameText;
  BOOL _showRevealButton;
}

@property (assign) IBOutlet NSTextField *editorStatusTextField;
@property (assign) IBOutlet NSTextField *filenameTextField;
@property (assign) IBOutlet NSButton *revealButton;
@property (assign) IBOutlet MHToolbarBackgroundView *rightPanel;

@property (copy) NSString *editorStatusText;
@property (copy) NSString *filenameText;
@property (assign) BOOL showRevealButton;

- (void) resizeLabels;
- (void) enable:(BOOL)state;

@end
