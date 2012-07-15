//
//  MHControlsTabBarController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>

extern NSString * const TPControlsTabSelectionDidChangeNotification;

@interface MHControlsTabBarController : NSResponder <NSTabViewDelegate> {
@private
  NSArray *buttons;
  NSButton *projectButton;
  NSButton *palletButton;
  NSButton *libraryButton;
  NSButton *outlineButton;
  NSButton *findButton;
  NSButton *bookmarksButton;
  NSButton *spellingButton;
  NSButton *prefsButton;
  NSTabView *tabView;
  NSSplitView *splitview;
  NSView *containerView;
}

@property (assign) IBOutlet NSButton *projectButton;
@property (assign) IBOutlet NSButton *palletButton;
@property (assign) IBOutlet NSButton *libraryButton;
@property (assign) IBOutlet NSButton *outlineButton;
@property (assign) IBOutlet NSButton *findButton;
@property (assign) IBOutlet NSButton *bookmarksButton;
@property (assign) IBOutlet NSButton *spellingButton;
@property (assign) IBOutlet NSButton *prefsButton;
@property (assign) IBOutlet NSSplitView *splitview;
@property (assign) IBOutlet NSView *containerView;
@property (assign) IBOutlet NSTabView *tabView;

- (void) toggleOn:(id)except;
- (NSInteger) indexOfSelectedTab;
- (void) selectTabAtIndex:(NSInteger)index;

- (IBAction)buttonSelected:(id)sender;

- (id) buttonForTabIndex:(NSInteger)index;
- (NSInteger)tabIndexForButton:(id)sender;

#pragma mark -
#pragma mark Control

- (IBAction) showProjectTree:(id)sender;
- (void) showProjectTree;
- (IBAction) showSymbolPalette:(id)sender;
- (void) showSymbolPalette;
- (IBAction) showClippingsLibrary:(id)sender;
- (void) showClippingsLibrary;
- (IBAction) showDocumentOutline:(id)sender;
- (void) showDocumentOutline;
- (IBAction) showProjectSearch:(id)sender;
- (void) showProjectSearch;
- (IBAction) showBookmarks:(id)sender;
- (void) showBookmarks;
- (IBAction) showSpelling:(id)sender;
- (void) showSpelling;
- (IBAction) showProjectSettings:(id)sender;
- (void) showProjectSettings;
- (IBAction) showNavigator:(id)sender;

@end
