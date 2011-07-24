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
}

@property (copy) NSString *editorStatusText;
@property (copy) NSString *projectStatusText;

- (void) setProjectStatus:(NSString*)text;
- (void) setEditorStatus:(NSString*)text;

@end
