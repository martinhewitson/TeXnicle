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
  
  
	NSSlider *entryRowHeightSlider;
  NSTableView *categoriesTable;
  NSTableView *entriesTable;
  
	NSMenu *addMenu;
	NSMenu *catActionMenu;
    
  HHValidatedButton *addCategoryButton;
  HHValidatedButton *deleteCategoryButton;
  HHValidatedButton *addClipButton;
  HHValidatedButton *deleteClipButton;
  HHValidatedButton *reloadClipButton;
  HHValidatedButton *insertClipButton;
  HHValidatedButton *editClipButton;
  HHValidatedButton *clipCopyButton;
  
  NSObjectController *selectedEntry;
  
  NSTextField *commandTextField;
  NSTextField *commandMessageLabel;
  
  id<TPLibraryControllerDelegate> delegate;

	NSImage *unknownImage;
  
  // Edit sheet
	NSString *textBeforeEditing;
	IBOutlet NSWindow *editSheet;
	IBOutlet TeXTextView *editTextView;
  BOOL didCancelEditSheet;

  TPLibrary *library;
}

@property (copy) NSString *textBeforeEditing;
@property (assign) IBOutlet NSWindow *editSheet;
@property (assign) IBOutlet TeXTextView *editTextView;

@property (retain) 	NSImage *unknownImage;

@property (assign) id<TPLibraryControllerDelegate> delegate;

@property (assign) IBOutlet NSObjectController *selectedEntry;
@property (assign) IBOutlet HHValidatedButton *addCategoryButton;
@property (assign) IBOutlet HHValidatedButton *deleteCategoryButton;
@property (assign) IBOutlet HHValidatedButton *addClipButton;
@property (assign) IBOutlet HHValidatedButton *deleteClipButton;
@property (assign) IBOutlet HHValidatedButton *reloadClipButton;
@property (assign) IBOutlet HHValidatedButton *insertClipButton;
@property (assign) IBOutlet HHValidatedButton *editClipButton;
@property (assign) IBOutlet HHValidatedButton *clipCopyButton;

@property (assign) IBOutlet NSTextField *commandTextField;
@property (assign) IBOutlet NSTextField *commandMessageLabel;

@property (retain) NSMenu *addMenu;
@property (retain) NSMenu *catActionMenu;

@property (assign) IBOutlet NSTableView *categoriesTable;
@property (assign) IBOutlet NSTableView *entriesTable;
@property (assign) IBOutlet NSSlider *entryRowHeightSlider;

@property (assign) TPLibrary *library;

- (id) initWithDelegate:(id<TPLibraryControllerDelegate>)aDelegate;

- (void) addEmptyClipping;
- (void) addClipFromPasteboard;

- (NSString*) codeForCommand:(NSString*)command;
- (NSArray*)commandsBeginningWith:(NSString*)prefix;
+ (NSString*) placeholderRegexp;

@end
