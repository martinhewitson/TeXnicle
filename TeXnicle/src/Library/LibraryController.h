//
//  LibraryController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TeXTextView.h"

extern NSString * const kItemsTableViewNodeType;

@interface LibraryController : NSWindowController {

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
	
}

@property (readwrite, assign) NSString *textBeforeEditing;

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

- (void) newClippingWithCode:(NSString*)someCode;
- (void) imageGeneratorTaskEnded:(NSString*)aPath;

#pragma mark -
#pragma mark TableView data source


@end
