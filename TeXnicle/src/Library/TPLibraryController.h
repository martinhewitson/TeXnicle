//
//  TPLibraryController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPLibraryImageGenerator.h"
#import "HHValidatedButton.h"
#import "TeXTextView.h"
#import "TPLibrary.h"

@class TPLibraryController;

@protocol TPLibraryControllerDelegate <NSObject>

- (void) libraryController:(TPLibraryController*)library insertText:(NSString*)text;

@end

@interface TPLibraryController : NSViewController <NSUserInterfaceValidations, NSTextFieldDelegate, TPLibraryImageGeneratorDelegate, NSTableViewDelegate, NSTableViewDataSource> {
  
  
	NSSlider *__unsafe_unretained entryRowHeightSlider;
  NSTableView *__unsafe_unretained categoriesTable;
  NSTableView *__unsafe_unretained entriesTable;
  
	NSMenu *addMenu;
	NSMenu *catActionMenu;
    
  HHValidatedButton *__unsafe_unretained addCategoryButton;
  HHValidatedButton *__unsafe_unretained deleteCategoryButton;
  HHValidatedButton *__unsafe_unretained addClipButton;
  HHValidatedButton *__unsafe_unretained deleteClipButton;
  HHValidatedButton *__unsafe_unretained reloadClipButton;
  HHValidatedButton *__unsafe_unretained insertClipButton;
  HHValidatedButton *__unsafe_unretained editClipButton;
  HHValidatedButton *__unsafe_unretained clipCopyButton;
  
  NSObjectController *__unsafe_unretained selectedEntry;
  
  NSTextField *__unsafe_unretained commandTextField;
  NSTextField *__unsafe_unretained commandMessageLabel;
  
  id<TPLibraryControllerDelegate> __unsafe_unretained delegate;

	NSImage *unknownImage;
  
  // Edit sheet
	NSString *textBeforeEditing;
	IBOutlet NSWindow *__unsafe_unretained editSheet;
	IBOutlet TeXTextView *__unsafe_unretained editTextView;
  BOOL didCancelEditSheet;

  TPLibrary *__unsafe_unretained library;
}

@property (copy) NSString *textBeforeEditing;
@property (unsafe_unretained) IBOutlet NSWindow *editSheet;
@property (unsafe_unretained) IBOutlet TeXTextView *editTextView;

@property (strong) 	NSImage *unknownImage;

@property (unsafe_unretained) id<TPLibraryControllerDelegate> delegate;

@property (unsafe_unretained) IBOutlet NSObjectController *selectedEntry;
@property (unsafe_unretained) IBOutlet HHValidatedButton *addCategoryButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *deleteCategoryButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *addClipButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *deleteClipButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *reloadClipButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *insertClipButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *editClipButton;
@property (unsafe_unretained) IBOutlet HHValidatedButton *clipCopyButton;

@property (unsafe_unretained) IBOutlet NSTextField *commandTextField;
@property (unsafe_unretained) IBOutlet NSTextField *commandMessageLabel;

@property (strong) NSMenu *addMenu;
@property (strong) NSMenu *catActionMenu;

@property (unsafe_unretained) IBOutlet NSTableView *categoriesTable;
@property (unsafe_unretained) IBOutlet NSTableView *entriesTable;
@property (unsafe_unretained) IBOutlet NSSlider *entryRowHeightSlider;

@property (unsafe_unretained) TPLibrary *library;

- (id) initWithDelegate:(id<TPLibraryControllerDelegate>)aDelegate;

- (void) addEmptyClipping;
- (void) addClipFromPasteboard;

- (NSString*) codeForCommand:(NSString*)command;
- (NSArray*)commandsBeginningWith:(NSString*)prefix;
+ (NSString*) placeholderRegexp;

@end
