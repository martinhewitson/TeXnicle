//
//  TPTemplateEditorView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"


@interface TPTemplateEditorView : NSViewController <NSTextViewDelegate, NSTableViewDelegate, NSTableViewDataSource> {
@private
  TeXTextView *templateCodeView;
  NSTableView *templateTable; 
  NSArrayController *templateArrayController;
}


@property (assign) IBOutlet TeXTextView *templateCodeView;
@property (assign) IBOutlet NSTableView *templateTable;
@property (assign) IBOutlet NSArrayController *templateArrayController;

- (NSDictionary*)selectedTemplate;

@end
