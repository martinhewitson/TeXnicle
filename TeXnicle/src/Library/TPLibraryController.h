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

@interface TPLibraryController : NSViewController <NSUserInterfaceValidations, NSTextFieldDelegate, TPLibraryImageGeneratorDelegate, NSTableViewDelegate, NSTableViewDataSource, NSOutlineViewDataSource, NSOutlineViewDelegate, NSPopoverDelegate> {
  
@private
  // Edit sheet
  BOOL didCancelEditSheet;

}

@property (unsafe_unretained) id<TPLibraryControllerDelegate> delegate;

- (id) initWithDelegate:(id<TPLibraryControllerDelegate>)aDelegate;

- (void) addEmptyClipping;
- (void) addClipFromPasteboard;

- (NSString*) codeForCommand:(NSString*)command;
- (NSArray*)commandsBeginningWith:(NSString*)prefix;
+ (NSString*) placeholderRegexp;
- (void) tearDown;

@end
