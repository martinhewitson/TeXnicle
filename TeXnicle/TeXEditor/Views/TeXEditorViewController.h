//
//  TeXEditorViewController.h
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"
#import "TPSectionListController.h"


@class TeXTextView;
@class TPSectionListController;

@interface TeXEditorViewController : NSViewController <TPSectionListControllerDelegate, TeXTextViewDelegate, NSTextStorageDelegate, NSTextViewDelegate> {
@private
  TeXTextView *textView;
  id delegate;
  IBOutlet TPSectionListController *sectionListController;
  IBOutlet NSView *containerView;
  NSPopUpButton *sectionListPopup;
  NSButton *unfoldButton;
  NSButton *markerButton;
  
  IBOutlet NSView *jumpBar;
  IBOutlet NSScrollView *scrollView;
  
  NSWindow *tableConfigureWindow;
  

  
  BOOL isHidden;
}


@property (assign) BOOL isHidden;
@property (assign) IBOutlet NSWindow *tableConfigureWindow;
@property (assign) IBOutlet TeXTextView *textView;
@property (assign) IBOutlet NSPopUpButton *sectionListPopup;
@property (assign) IBOutlet NSButton *markerButton;
@property (assign) IBOutlet NSButton *unfoldButton;
@property (assign) id delegate;

#pragma mark -
#pragma mark Insert Table
- (IBAction)insertTable:(id)sender;

- (void) setString:(NSString*)aString;
- (void) disableEditor;
- (void) enableEditor;
- (void) hide;

- (BOOL) textViewHasSelection;
- (NSString*)selectedText;

- (void) hideJumpBar;
- (void) showJumpBar;
- (void) enableJumpBar;
- (void)disableJumpBar;

@end
