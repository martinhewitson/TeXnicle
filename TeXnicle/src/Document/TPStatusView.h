//
//  TPStatusView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 03/07/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPStatusView : NSView {
@private
  NSTextFieldCell *editorStatusCell;
  NSTextFieldCell *projectStatusCell;
  NSButton *revealButton;
}

@property (copy) NSString *editorStatusText;
@property (copy) NSString *projectStatusText;
@property (assign) BOOL showRevealButton;

- (void) revealButtonClicked:(id)sender;
- (void) setProjectStatus:(NSString*)text;
- (void) setEditorStatus:(NSString*)text;

@end
