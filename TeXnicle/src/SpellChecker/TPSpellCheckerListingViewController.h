//
//  TPSpellCheckerListingViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
#import "TPMisspelledWord.h"
#import "TPSpellCheckedFile.h"
#import "HHValidatedButton.h"

@protocol TPSpellCheckerListingDelegate <NSObject>

- (BOOL)shouldPerformSpellCheck;
- (void)highlightMisspelledWord:(NSString*)word atRange:(NSRange)aRange inFile:(FileEntity*)aFile;
- (void)replaceMisspelledWord:(NSString*)word atRange:(NSRange)aRange withCorrection:(NSString*)correction inFile:(FileEntity*)aFile;
- (void)dictionaryDidLearnNewWord;
- (NSArray*)filesToSpellCheck;

- (BOOL) performSimpleSpellCheck;
- (NSString*)stringToCheck;
- (NSString*)fileToCheck;
- (NSDate*)lastEdit;

@end

@interface TPSpellCheckerListingViewController : NSViewController <NSUserInterfaceValidations, TPSpellCheckerListingDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
  
  id<TPSpellCheckerListingDelegate> delegate;
  NSMutableArray *checkedFiles;
  NSTimer *spellCheckTimer;
  NSOutlineView *outlineView;
  
  NSInteger checkingFiles;
  
  HHValidatedButton *correctButton;
  HHValidatedButton *revealButton;
  HHValidatedButton *learnButton;
  HHValidatedButton *forceCheckButton;
    
  NSOperationQueue* aQueue;
  NSProgressIndicator *progressIndicator;
}

@property (retain) NSOperationQueue* aQueue;

@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet HHValidatedButton *correctButton;
@property (assign) IBOutlet HHValidatedButton *revealButton;
@property (assign) IBOutlet HHValidatedButton *learnButton;
@property (assign) IBOutlet HHValidatedButton *forceCheckButton;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) id<TPSpellCheckerListingDelegate> delegate;
@property (retain) NSTimer *spellCheckTimer;
@property (retain) NSMutableArray *checkedFiles;

- (id) initWithDelegate:(id<TPSpellCheckerListingDelegate>)aDelegate;
- (void) updateFile:(FileEntity*)aFile;
- (void) updateAllFilesWithExtension:(NSString*)ext;
- (void) updateAllLists;
- (void) performSpellCheck;
- (void) stop;
@end
