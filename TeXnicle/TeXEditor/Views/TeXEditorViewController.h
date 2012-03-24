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
#import "TPSyntaxChecker.h"

@class TeXTextView;
@class TPSectionListController;

@interface TeXEditorViewController : NSViewController <SyntaxCheckerDelegate, TPSectionListControllerDelegate, TeXTextViewDelegate, NSTextStorageDelegate, NSTextViewDelegate> {
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
  
  NSButton *errorPopup;
	NSMenu *errorMenu;
  NSArray *errors;
  
  BOOL isHidden;
  
  TPSyntaxChecker *checker;
  BOOL _shouldCheckSyntax;
  BOOL _checkingSyntax;
  BOOL performSyntaxCheck;
  NSTimer *syntaxCheckTimer;
  
  NSImage *errorImage;
  NSImage *noErrorImage;
  NSImage *checkFailedImage;
}

@property (retain) NSImage *errorImage;
@property (retain) NSImage *noErrorImage;
@property (retain) NSImage *checkFailedImage;
@property (assign) BOOL performSyntaxCheck;
@property (retain) NSTimer *syntaxCheckTimer;
@property (retain) TPSyntaxChecker *checker;
@property (retain) NSArray *errors;
@property (assign) BOOL isHidden;
@property (assign) IBOutlet NSWindow *tableConfigureWindow;
@property (assign) IBOutlet TeXTextView *textView;
@property (assign) IBOutlet NSPopUpButton *sectionListPopup;
@property (assign) IBOutlet NSButton *markerButton;
@property (assign) IBOutlet NSButton *errorPopup;
@property (assign) IBOutlet NSButton *unfoldButton;
@property (assign) id delegate;

- (void) handleDocumentChanged:(NSNotification*)aNote;

#pragma mark -
#pragma mark Insert Table
- (IBAction)insertTable:(id)sender;

- (IBAction)showErrorMenu:(id)sender;
- (void) setHasErrors:(BOOL)state;
- (void) setCheckFailed;
- (void)jumpToLine:(NSMenuItem*)anItem;

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
