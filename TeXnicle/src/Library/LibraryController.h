//
//  LibraryController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"
#import "HHValidatedButton.h"

extern NSString * const kItemsTableViewNodeType;

@class LibraryController;

@protocol LibraryControllerDelegate <NSObject>

- (void) libraryController:(LibraryController*)library insertText:(NSString*)text;

@end

@interface LibraryController : NSViewController <NSUserInterfaceValidations, NSTextFieldDelegate, LibraryControllerDelegate> {

	NSMutableDictionary *library;
	
	IBOutlet NSArrayController *categoryController;
	IBOutlet NSArrayController *contentsController;
	
	IBOutlet NSTableView *categoryTable;
	IBOutlet NSTableView *itemsTable;
	
	IBOutlet NSImageView *imageView;
  
	IBOutlet NSSlider *slider;
	
	NSImage *unknownImage;
	
	// Edit sheet
	NSString *textBeforeEditing;
	IBOutlet NSWindow *editSheet;
	IBOutlet TeXTextView *editTextView;
	
	// Add menu
	NSMenu *addMenu;
	NSMenu *catActionMenu;
	
  id<LibraryControllerDelegate> delegate;
  
  HHValidatedButton *addCategoryButton;
  HHValidatedButton *deleteCategoryButton;
  HHValidatedButton *addClipButton;
  HHValidatedButton *deleteClipButton;
  HHValidatedButton *reloadClipButton;
  HHValidatedButton *insertClipButton;
  HHValidatedButton *editClipButton;
  HHValidatedButton *clipCopyButton;
  
  NSTextField *commandTextField;
  
  NSDictionary *defaultLibrary;
  NSTextField *commandMessageLabel;
  NSArray *knownCommands;
}

@property (assign) id<LibraryControllerDelegate> delegate;

@property (readwrite, assign) NSString *textBeforeEditing;
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
@property (retain) NSArray *knownCommands;
@property (retain) NSDictionary *defaultLibrary;

+ (NSString*) placeholderRegexp;

- (id) initWithDelegate:(id<LibraryControllerDelegate>)aDelegate;

- (void) setupLibrary;
- (void) reloadLibrary;
- (NSMutableArray*)categorySetFromDefaults;

- (void) createAddMenu;
- (void) createCategoryActionMenu;

- (IBAction) startEditSheet:(id)sender;
- (IBAction) endEditSheet:(id)sender;

//+ (LibraryController*)sharedLibraryController;

- (void) addDefaultCategories;
- (IBAction) categoryAction:(id)sender;

- (IBAction) setRowHeight:(id)sender;

- (IBAction) insertSelectedItems:(id)sender;
- (IBAction) copySelectedItemsToPasteboard:(id)sender;

- (IBAction) deleteItems:(id)sender;
- (void)removeItemsAlertEnded:(NSAlert *)alert 
												 code:(int)choice 
											context:(void *)v;

- (IBAction) removeCategories:(id)sender;
- (void)removeCategoriesAlertEnded:(NSAlert *)alert 
															code:(int)choice 
													 context:(void *)v;

- (IBAction) refreshSymbolAtRow:(NSNumber*)rowVal;
- (IBAction) refreshImages:(id)sender;
- (IBAction) addCategory:(id)sender;
- (IBAction) addClipping:(id)sender;
- (void) saveLibrary;

- (NSDictionary*)copyOfClip:(NSDictionary*)clip;
- (void) newClippingWithCode:(NSString*)someCode;
- (void) imageGeneratorTaskEnded:(NSString*)aPath;
- (void) regenerateKnownCommandCodes;
- (void) restoreDefaultCategoriesAndCodes;

- (NSArray*) commandsBeginningWith:(NSString*)prefix;
-(NSString*)codeForCommand:(NSString*)command;

#pragma mark -
#pragma mark TableView data source


@end
