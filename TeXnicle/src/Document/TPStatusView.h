//
//  TPStatusView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 03/07/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPStatusView : NSView {
@private
  NSTextFieldCell *editorStatusCell;
  NSTextFieldCell *filenameCell;
  NSButton *revealButton;
  
  NSString *editorStatusText;
  NSString *filenameText;
  BOOL showRevealButton;
}

@property (copy) NSString *editorStatusText;
@property (copy) NSString *filenameText;
@property (assign) BOOL showRevealButton;

- (void) revealButtonClicked:(id)sender;
- (void) setFilename:(NSString*)text;
- (void) setEditorStatus:(NSString*)text;

@end
