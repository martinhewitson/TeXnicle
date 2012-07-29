//
//  TeXEditorViewController.h
//  TeXnicle
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"
#import "TPSectionListController.h"
#import "TPSyntaxChecker.h"

@class TeXTextView;
@class TPSectionListController;

@interface TeXEditorViewController : NSViewController <SyntaxCheckerDelegate, TPSectionListControllerDelegate, TeXTextViewDelegate, NSTextStorageDelegate, NSTextViewDelegate> {
@private
  TeXTextView *__unsafe_unretained textView;
  id __unsafe_unretained delegate;
  IBOutlet TPSectionListController *sectionListController;
  IBOutlet NSView *containerView;
  NSPopUpButton *__unsafe_unretained sectionListPopup;
  NSButton *__unsafe_unretained unfoldButton;
  NSButton *__unsafe_unretained markerButton;
  
  NSString *fileBeingSyntaxChecked;
  
  IBOutlet NSView *jumpBar;
  IBOutlet NSScrollView *scrollView;
  
  NSWindow *__unsafe_unretained tableConfigureWindow;
  
  NSButton *__unsafe_unretained errorPopup;
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

@property (copy) NSString *fileBeingSyntaxChecked;
@property (strong) NSImage *errorImage;
@property (strong) NSImage *noErrorImage;
@property (strong) NSImage *checkFailedImage;
@property (assign) BOOL performSyntaxCheck;
@property (strong) NSTimer *syntaxCheckTimer;
@property (strong) TPSyntaxChecker *checker;
@property (strong) NSArray *errors;
@property (assign) BOOL isHidden;
@property (unsafe_unretained) IBOutlet NSWindow *tableConfigureWindow;
@property (unsafe_unretained) IBOutlet TeXTextView *textView;
@property (unsafe_unretained) IBOutlet NSPopUpButton *sectionListPopup;
@property (unsafe_unretained) IBOutlet NSButton *markerButton;
@property (unsafe_unretained) IBOutlet NSButton *errorPopup;
@property (unsafe_unretained) IBOutlet NSButton *unfoldButton;
@property (unsafe_unretained) id delegate;

- (void) handleDocumentChanged:(NSNotification*)aNote;
- (void) setupSyntaxChecker;
- (void) stopSyntaxChecker;

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
