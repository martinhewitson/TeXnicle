//
//  TPSpellCheckerListingViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

@end

@interface TPSpellCheckerListingViewController : NSViewController <NSUserInterfaceValidations, TPSpellCheckerListingDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
  
  id<TPSpellCheckerListingDelegate> delegate;
  NSMutableArray *checkedFiles;
  NSTimer *spellCheckTimer;
  NSOutlineView *outlineView;
	dispatch_queue_t queue;
  
  NSInteger checkingFiles;
  
  HHValidatedButton *correctButton;
  HHValidatedButton *revealButton;
  HHValidatedButton *learnButton;
  
  NSProgressIndicator *progressIndicator;
}

@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet HHValidatedButton *correctButton;
@property (assign) IBOutlet HHValidatedButton *revealButton;
@property (assign) IBOutlet HHValidatedButton *learnButton;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) id<TPSpellCheckerListingDelegate> delegate;
@property (retain) NSTimer *spellCheckTimer;
@property (retain) NSMutableArray *checkedFiles;

- (id) initWithDelegate:(id<TPSpellCheckerListingDelegate>)aDelegate;
- (void) updateFile:(FileEntity*)aFile;
- (void) updateAllFilesWithExtension:(NSString*)ext;
- (void) updateAllLists;
- (void) performSpellCheck;
@end
