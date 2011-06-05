//
//  TeXEditorViewController.h
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"


@class TeXTextView;
@class TPSectionListController;

@interface TeXEditorViewController : NSViewController <TeXTextViewDelegate, NSTextStorageDelegate, NSTextViewDelegate> {
@private
  TeXTextView *textView;
  id delegate;
  IBOutlet TPSectionListController *sectionListController;
}

@property (assign) IBOutlet TeXTextView *textView;
@property (assign) IBOutlet NSPopUpButton *sectionListPopup;
@property (assign) IBOutlet NSButton *markerButton;
@property (assign) IBOutlet NSButton *unfoldButton;
@property (assign) id delegate;

- (void) setString:(NSString*)aString;
- (void) disableEditor;
- (void) enableEditor;

@end
