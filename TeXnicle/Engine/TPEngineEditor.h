//
//  TPEngineEditor.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"

@class TeXEditorViewController;

@interface TPEngineEditor : NSDocument <TeXTextViewDelegate> {
@private
  NSMutableAttributedString *documentData;
  TeXEditorViewController *texEditorViewController;
  NSView *texEditorContainer;
}


@property(readwrite, assign) NSMutableAttributedString *documentData;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (retain) IBOutlet NSView *texEditorContainer;

@end
