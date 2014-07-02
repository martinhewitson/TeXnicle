//
//  TPLibraryController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSApplication+Library.h"
#import "TPLibraryController.h"
#import "TPLibraryImageGenerator.h"
#import "TPLibraryEntry.h"
#import "TPLibraryCategory.h"
#import "TPLibraryEntry+NSDictionary.h"
#import "externs.h"
#import "NSTableView+TeXnicle.h"
#import "NSStringUUID.h"
#import "TPLibraryCommandFormatter.h"
#import "TPThemeManager.h"

@interface TPLibraryController ()

@property (copy) NSString *textBeforeEditing;
@property (unsafe_unretained) IBOutlet NSWindow *editSheet;
@property (unsafe_unretained) IBOutlet TeXTextView *editTextView;

@property (unsafe_unretained) IBOutlet NSTextField *categoryLabel;

@property (strong) 	NSImage *unknownImage;


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


@end

@implementation TPLibraryController


- (id) initWithDelegate:(id<TPLibraryControllerDelegate>)aDelegate;
{
  self = [super initWithNibName:@"TPLibraryView" bundle:nil];
  if (self) {
    self.library = [NSApplication sharedLibrary];
    self.delegate = aDelegate;
  }
  return self;
}

- (void) awakeFromNib
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [[self.categoryLabel cell] setBackgroundStyle:NSBackgroundStyleRaised];

  
  [self.selectedEntry performSelector:@selector(setContent:) withObject:nil afterDelay:0];
  
	// Set up the tables
	[self.entriesTable registerForDraggedTypes:@[NSStringPboardType]];
//	[self.entriesTable registerForDraggedTypes:[NSArray arrayWithObjects:kItemsTableViewNodeType,nil]];
  
  // set row height
  [self.entryRowHeightSlider setFloatValue:[[defaults valueForKey:TPLibraryRowHeight] floatValue]];
	[self.entriesTable setRowHeight:[self.entryRowHeightSlider floatValue]];

  // create action menus
	[self createAddMenu];
	[self createCategoryActionMenu];
  
  TPLibraryCommandFormatter *formatter = [[TPLibraryCommandFormatter alloc] init];
  [self.commandTextField setFormatter:formatter];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleLibraryUpdate:)
                                               name:TPLibraryDidUpdateNotification
                                             object:self.library];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleNavigatorFontDidChangeNotification:)
                                               name:TPThemeNavigatorFontChangedNotification
                                             object:nil];
  
  [self updateFont];
  
  [self setNextResponder:self.view];
  [self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) { [subview setNextResponder:self]; }];
}

- (void) handleNavigatorFontDidChangeNotification:(NSNotification*)aNote
{
  [self updateFont];
}

- (void) updateFont
{
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  NSFont *font = theme.navigatorFont;
  NSTableColumn *col = [self.categoriesTable tableColumnWithIdentifier:@"NameColumn"];
  [[col dataCell] setFont:font];
  NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"A Big Test String" attributes:@{NSFontAttributeName : font}];
  NSSize s = [att size];
  [self.categoriesTable setRowHeight:s.height];
  [self.categoriesTable reloadData];
  [self.categoriesTable setNeedsDisplay:YES];
}

- (void) handleLibraryUpdate:(NSNotification*)aNote
{
  if (self.library == [aNote object]) {
    [self.categoriesTable reloadData];
    [self.entriesTable reloadData];
    [self.selectedEntry setContent:[self getSelectedEntry]];
  }
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.selectedEntry setContent:nil];
  self.delegate = nil;
}

#pragma mark -
#pragma mark Control

- (IBAction) insertSelectedItems:(id)sender
{
  NSArray *items = [self selectedEntries];
  NSString *string = [[items valueForKey:@"code"] componentsJoinedByString:@"\n"];			
  [self libraryController:self insertText:string];
}


- (IBAction) refreshImages:(id)sender
{
	NSArray *selected = [self selectedEntries];
	for (TPLibraryEntry *symbol in selected) {
		if (self.unknownImage == nil) {
			self.unknownImage = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
		}
    symbol.image = [NSKeyedArchiver archivedDataWithRootObject:self.unknownImage];
    symbol.imageIsValid = @NO;
	}
  
  [self.entriesTable reloadData];
  [[NSNotificationCenter defaultCenter] postNotificationName:TPLibraryDidUpdateNotification object:self.library];
}

- (void) refreshImageForEntry:(TPLibraryEntry*)entry
{
  if (self.unknownImage == nil) {
    self.unknownImage = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
  }
  entry.image = [NSKeyedArchiver archivedDataWithRootObject:self.unknownImage];
  entry.imageIsValid = @NO;
  [self.entriesTable reloadData];
  [[NSNotificationCenter defaultCenter] postNotificationName:TPLibraryDidUpdateNotification object:self.library];
}


- (IBAction) setRowHeight:(id)sender
{
	CGFloat height = [sender floatValue];
	[self.entriesTable setRowHeight:height];
  
  // write to user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  [defaults setValue:[NSNumber numberWithFloat:height] forKey:TPLibraryRowHeight];
  [defaults synchronize];
}

- (IBAction) copySelectedItemsToPasteboard:(id)sender
{
	NSArray *items = [self selectedEntries];
	NSString *string = [[items valueForKey:@"code"] componentsJoinedByString:@"\n"];
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:@[NSStringPboardType] owner:self];
	[pb setString:string forType:NSStringPboardType];
}


#pragma mark -
#pragma mark Entities




- (NSArray*) entriesForSelectedCategory
{
  TPLibraryCategory *category = [self selectedCategory];
  if (category) {
    return [self.library entriesForCategory:category];
  }
  
  return @[];
}

- (void) selectCategory:(TPLibraryCategory*)category
{
  // get index of this category
  NSInteger index = [self.library indexOfCategory:category];
  [self.categoriesTable performSelector:@selector(selectRowNumber:) withObject:@(index) afterDelay:0];
  [self.entriesTable performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

- (void) selectEntry:(TPLibraryEntry*)entry
{
  // get index of this entry
  NSInteger index = [[self entriesForSelectedCategory] indexOfObject:entry];
  [self.entriesTable performSelector:@selector(selectRowNumber:) withObject:@(index) afterDelay:0];
}


- (TPLibraryCategory*) selectedCategory
{
  NSArray *categories = [self.library categories];
  
  NSInteger row = [self.categoriesTable selectedRow];
  if (row >= 0 && row < [categories count]) {
    return categories[row];
  }

  return nil;
}

- (NSArray*) selectedEntries
{
  NSArray *entries = [self entriesForSelectedCategory];
  if (entries) {
    NSIndexSet *indexes = [self.entriesTable selectedRowIndexes];
    if ([indexes count] == 0) {
      return nil;
    } else {
      return [entries objectsAtIndexes:indexes];
    }
  }
  return nil;
}



- (TPLibraryEntry*) getSelectedEntry
{
  NSArray *entries = [self entriesForSelectedCategory];
  if (entries) {
    NSInteger row = [self.entriesTable selectedRow];
    if (row >= 0 && row < [entries count]) {
      return entries[row];
    }
  }
  return nil;
}

- (void) delete:(id)sender
{
  NSResponder *first = [self.view.window firstResponder];
  
  if (first == self.categoriesTable) {
    [self removeCategories:sender];
  } else {
    [self deleteItems:sender];
  }
}

- (IBAction) deleteItems:(id)sender
{
  
  
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete Clippings?"
																	 defaultButton:@"Delete" alternateButton:@"Cancel"
																		 otherButton:nil 
											 informativeTextWithFormat:@"Do you really want to delete the selected clippings? You can't undo this!"
										]; 
	[alert beginSheetModalForWindow:[[self view] window] modalDelegate:self
									 didEndSelector:@selector(removeItemsAlertEnded:code:context:) 
											contextInfo:NULL];
	
}

- (void)removeItemsAlertEnded:(NSAlert *)alert 
                         code:(int)choice 
                      context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
		
    // delete the selected entries
    NSIndexSet *rows = [self.entriesTable selectedRowIndexes];
    NSArray *entries = [self entriesForSelectedCategory];
    if (entries) {
      NSArray *entriesToDelete = [entries objectsAtIndexes:rows];
      [self.library removeEntries:entriesToDelete];
      [self.entriesTable reloadData];
    }
    
	} else {
		// do nothing
	}
	
}

- (void) addEmptyClipping
{	
  TPLibraryCategory *category = [self selectedCategory];
  if (category) {
    [self createClipWithCode:[NSString stringWithFormat:@"New Clip %lu", [category.entries count]] inCategory:category];
  }
}

- (void) addClipFromPasteboard
{
  TPLibraryCategory *category = [self selectedCategory];
  if (category) {
    NSString *code = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
    [self createClipWithCode:code inCategory:category];
  }
}

- (TPLibraryEntry*) createClipWithCode:(NSString*)code inCategory:(TPLibraryCategory *)category
{
  TPLibraryEntry *entry = [self.library clipWithCode:code inCategory:category];
  // now select the new entry
  [self.entriesTable reloadData];
  [self selectEntry:entry];    
  // focus on entries table
  [[self.view window] makeFirstResponder:self.entriesTable];
  return entry;
}

- (IBAction)createCategory:(id)sender
{
  NSString *name = [NSString stringWithFormat:@"New Category %lu", [[self.library categories] count]];
  TPLibraryCategory *category = [self.library createCategoryWithName:name];
  // reload table
  [self.categoriesTable reloadData];
  // select this category
  [self selectCategory:category];
  // focus on categories table
  [[self.view window] makeFirstResponder:self.categoriesTable];

}

- (IBAction) removeCategories:(id)sender
{	
  
  
	// ask the user if they want to delete the selected categories
	// ask the user with a sheet
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete Category?"
																	 defaultButton:@"Delete" alternateButton:@"Cancel"
																		 otherButton:nil 
											 informativeTextWithFormat:@"Do you really want to delete the selected category and its content? You can't undo this!"
										]; 
	[alert beginSheetModalForWindow:[[self view] window] modalDelegate:self
									 didEndSelector:@selector(removeCategoriesAlertEnded:code:context:) 
											contextInfo:NULL];
	
}

- (void)removeCategoriesAlertEnded:(NSAlert *)alert 
                              code:(int)choice 
                           context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
		
    TPLibraryCategory *selectedCategory = [self selectedCategory];
    [self.library removeCategory:selectedCategory];
    [self.categoriesTable reloadData];
    [self.entriesTable reloadData];
    
	} else {
		// do nothing
	}
	
}






#pragma mark -
#pragma mark Image generator delegate

+ (NSString*) placeholderRegexp
{
  return @"(?<=[\\A\\W])(\\@[[ \t][^\\@\n\\W]]{0,30}?[^\\\\]\\@)";
//  return @"[^a-zA-Z]\\@[[ \t][^\\@\n\\W]]{0,30}[^\\\\]\\@";
//  return @"\\@[[ \t][^\\@\n\\W]]{0,30}[^\\\\]\\@";
}

- (NSString*) placeholderRegexp
{
  return [TPLibraryController placeholderRegexp];
}

- (void) imageGeneratorTaskEnded:(NSString *)path
{
  [self.entriesTable reloadData];
  [self.library saveAction:self];
}

#pragma mark -
#pragma mark Action Menus

- (IBAction) categoryAction:(id)sender
{
	
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] 
												convertPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)																		 
												toView:nil];
	
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
																			 location:menuOrigin
																	modifierFlags:NSLeftMouseDownMask // 0x100
																			timestamp:0
																	 windowNumber:[[(NSButton *)sender window] windowNumber]
																				context:[[(NSButton *)sender window] graphicsContext]
																		eventNumber:0
																		 clickCount:1
																			 pressure:1];
	
	
	[NSMenu popUpContextMenu:self.catActionMenu withEvent:event forView:(NSButton *)sender];
	
	
}

- (IBAction) addClipping:(id)sender
{
	
	NSRect frame = [(NSButton *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] 
												convertPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)																		 
												toView:nil];
	
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
																			 location:menuOrigin
																	modifierFlags:NSLeftMouseDownMask // 0x100
																			timestamp:0
																	 windowNumber:[[(NSButton *)sender window] windowNumber]
																				context:[[(NSButton *)sender window] graphicsContext]
																		eventNumber:0
																		 clickCount:1
																			 pressure:1];
	
	
	[NSMenu popUpContextMenu:self.addMenu withEvent:event forView:(NSButton *)sender];
  
}

- (void) createCategoryActionMenu
{
	
	// Make popup menu with bound actions
	self.catActionMenu = [[NSMenu alloc] initWithTitle:@"Library Category Action Menu"];
	[self.catActionMenu setAutoenablesItems:YES];
	
	// Add default categories
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add Default Categories"
																								action:@selector(addDefaultCategories)
																				 keyEquivalent:@""];
  [item setTarget:self];
	[self.catActionMenu addItem:item];
	
	// Restore default library
	item = [[NSMenuItem alloc] initWithTitle:@"Restore Default Library"
																		action:@selector(restoreDefaultLibrary)
														 keyEquivalent:@""];
  [item setTarget:self];
	[self.catActionMenu addItem:item];
	
	
}

- (void) addDefaultCategories
{
  [self.library addDefaultCategories];
}

- (void) restoreDefaultLibrary
{
  NSAlert *alert = [NSAlert alertWithMessageText:@"Restore Defaults?"
                                   defaultButton:@"Restore"
                                 alternateButton:@"Cancel"
                                     otherButton:nil
                       informativeTextWithFormat:@"Are you sure you want to restore the default library?"
                    ];
  
  NSInteger result = [alert runModal];
  if (result == NSAlertDefaultReturn) {
    [self.library restoreDefaultLibrary];
  }
}

- (void) createAddMenu
{
	
	// Make popup menu with bound actions
	self.addMenu = [[NSMenu alloc] initWithTitle:@"Library Add Context Menu"];	
	[self.addMenu setAutoenablesItems:YES];
	
	// Add empty clipping
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"New clip"
																								action:@selector(addEmptyClipping)
																				 keyEquivalent:@""];
  [item setTarget:self];
	[self.addMenu addItem:item];
	
	
	// Clipping from the pasteboard
	item = [[NSMenuItem alloc] initWithTitle:@"Clip from pasteboard"
																		action:@selector(addClipFromPasteboard)
														 keyEquivalent:@""];
  [item setTarget:self];
	[self.addMenu addItem:item];
  
	
}


#pragma mark -
#pragma mark TableView data source

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
  if (tableView == self.categoriesTable) {
    return [[self.library categories] count];
  }
  
  if (tableView == self.entriesTable) {
    return [[self entriesForSelectedCategory] count];
  }
  
  return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.categoriesTable) {
    NSArray *categories = [self.library categories];
    if (row >= 0 && row < [categories count]) {
      return [categories[row] name];
    }
  }
  
  if (tableView == self.entriesTable) {
    NSArray *entries = [self entriesForSelectedCategory];
    if (row >=0 && row < [entries count]) {
      TPLibraryEntry *entry = entries[row];
      if ([[tableColumn identifier] isEqualToString:@"ImageColumn"]) {
        NSData *imageData = entry.image;   
        NSImage *image = nil;
        if (imageData == nil || [entry.imageIsValid boolValue] == NO) {
          image = [NSImage imageNamed:NSImageNameRefreshTemplate];
          
          // launch a thread to compute the image
          TPLibraryImageGenerator *ig = [[TPLibraryImageGenerator alloc] initWithSymbol:entry
                                                                                mathMode:NO
                                                                           andController:self];
          
          [NSThread detachNewThreadSelector:@selector(generateImage) 
                                   toTarget:ig
                                 withObject:nil];
          
        } else {
          image = [NSKeyedUnarchiver unarchiveObjectWithData:imageData];
        }
        return image;
      } else if ([[tableColumn identifier] isEqualToString:@"CodeColumn"]) {
        return entry.code;
      }
    }
  }
  
  return nil;
}


- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == self.categoriesTable) {
    TPLibraryCategory *category = [self.library categoryAtIndex:row];
    if (category) {
      if ([object isKindOfClass:[NSString class]]) {
        category.name = object;
        [[NSNotificationCenter defaultCenter] postNotificationName:TPLibraryDidUpdateNotification object:self.library];
      }
    }
  }
  
  if (tableView == self.entriesTable && [[tableColumn identifier] isEqualToString:@"CodeColumn"]) {
    
    NSArray *entries = [self entriesForSelectedCategory];
    if (row >= 0 && row < [entries count]) {
      TPLibraryEntry *entry = entries[row];
      entry.code = object;
      entry.imageIsValid = @NO;
      [tableView reloadData];
      [[NSNotificationCenter defaultCenter] postNotificationName:TPLibraryDidUpdateNotification object:self.library];
    }
  }
  
}

#pragma mark -
#pragma mark Items Table Drag-n-drop

- (NSDragOperation)tableView:(NSTableView*)aTableView 
								validateDrop:(id <NSDraggingInfo>)info 
								 proposedRow:(NSInteger)row 
			 proposedDropOperation:(NSTableViewDropOperation)op
{
	NSTableView *sourceTable = [info draggingSource];
	if (sourceTable != aTableView && aTableView == self.entriesTable && [self selectedCategory]) {
    return NSDragOperationCopy;
	}
	
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView 
			 acceptDrop:(id <NSDraggingInfo>)info
							row:(NSInteger)row 
		dropOperation:(NSTableViewDropOperation)operation
{
	
	if (aTableView == self.entriesTable) {
		
		/** Items Table **/
		
		NSPasteboard* pboard = [info draggingPasteboard];
		NSString *string = [pboard stringForType:NSStringPboardType];
		
		// get the first selected category
		TPLibraryCategory *category = [self selectedCategory];
		if (category) {
			// make a new entry in the category
			[self createClipWithCode:string inCategory:category];			
		} else {
			// tell the user to select a category
		}
    
	} 
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView 
writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
		 toPasteboard:(NSPasteboard*)pboard
{	
	if (aTableView == self.entriesTable) {
    
    NSArray *allEntries = [self entriesForSelectedCategory];
    NSArray *items = [allEntries objectsAtIndexes:rowIndexes];			
		NSMutableArray *strings = [NSMutableArray array];
		for (NSDictionary *item in items) {
			[strings addObject:[item valueForKey:@"Code"]];
		}
    //		id str = [[strings componentsJoinedByString:@"\n"] retain];
		id str = [strings componentsJoinedByString:@"\n"];
    //		NSLog(@"Writing to pboard: %@", str);
		[pboard declareTypes:@[NSStringPboardType] owner:self];
		return [pboard setString:str forType:NSStringPboardType];
	}
	
	return NO;
}

#pragma mark -
#pragma mark TableView Delegate messages

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  NSTableView *table = [notification object];
  
  if (table == self.categoriesTable) {
    [self.entriesTable reloadData];
  }
  
  // update selected entry
  [self.selectedEntry setContent:[self getSelectedEntry]];
  
}


- (NSString *)tableView:(NSTableView *)aTableView 
				 toolTipForCell:(NSCell *)aCell 
									 rect:(NSRectPointer)rect 
						tableColumn:(NSTableColumn *)aTableColumn 
										row:(NSInteger)row 
					mouseLocation:(NSPoint)mouseLocation
{
	if (aTableView == self.entriesTable) {
    TPLibraryEntry *entry = [[[self selectedCategory] entries] allObjects][row];
		return entry.code;		
	}
	
	return nil;
}




#pragma mark -
#pragma mark LibraryController Delegate

-(void)libraryController:(TPLibraryController *)library insertText:(NSString *)text
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(libraryController:insertText:)]) {
    [self.delegate libraryController:self insertText:text];
  }
}

#pragma mark -
#pragma mark Text field delegate



- (BOOL) control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
  if (control == self.entriesTable) {
    
    return YES;
    
  } else if (control == self.commandTextField) {
    NSString *proposed = [fieldEditor string];
    TPLibraryEntry *selected = [self getSelectedEntry];
    for (TPLibraryEntry* entry in [self.library entriesWithDefinedCommands]) {
      if (entry != nil) {
       if (entry.uuid != selected.uuid && [entry.command isEqualToString:proposed]) {
        [self.commandMessageLabel setStringValue:@"Command exists."];
        return NO;
       }
      }
    }
    [self.commandMessageLabel setStringValue:@""];
  }
  
  return YES;
}

- (NSString*) codeForCommand:(NSString*)command
{
  return [self.library codeForCommand:command];
}

- (NSArray*)commandsBeginningWith:(NSString*)prefix
{
  return [self.library commandsBeginningWith:prefix];
}

#pragma mark -
#pragma mark Edit Sheet

- (IBAction) startEditSheet:(id)sender
{
	[self.entriesTable abortEditing];
	NSArray *selected = [self selectedEntries];
	
	TPLibraryEntry *item = nil;
	if ([selected count] == 1) {
		item = selected[0];
	} else {
    return;
  }
	
	NSString *code = item.code;
  [[self.editTextView textStorage] beginEditing];
  [[self.editTextView textStorage] setAttributedString:[[NSAttributedString alloc] initWithString:code]];
  [[self.editTextView textStorage] endEditing];
  [self.editTextView applyFontAndColor:YES];
  
  // cache text
	self.textBeforeEditing = code;
	
	[NSApp beginSheet:self.editSheet
		 modalForWindow:[[self view] window]
			modalDelegate:self
		 didEndSelector:@selector(editSheetDidEnd:returnCode:contextInfo:)
				contextInfo:NULL];	
	
  
  [self.editTextView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0.1];
}

- (void)editSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
  if (didCancelEditSheet)
    return;
  
	NSString *newText = nil;
  newText = [self.editTextView string];
  TPLibraryEntry *item = [self getSelectedEntry];
	if (item) {
    item.code = newText;    
    if (newText != nil && self.textBeforeEditing != nil) {
      if ([newText isEqualToString:self.textBeforeEditing] == NO) {
        // regenerate image
        [self refreshImageForEntry:item];
      }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TPLibraryDidUpdateNotification object:self.library];
  }
}

- (IBAction) endEditSheet:(id)sender
{	
  didCancelEditSheet = NO;
	[NSApp endSheet:self.editSheet];
	[self.editSheet orderOut:self];
}

- (IBAction) cancelEditSheet:(id)sender
{	
  didCancelEditSheet = YES;
	[NSApp endSheet:self.editSheet];
	[self.editSheet orderOut:self];
}


#pragma mark -
#pragma mark Validation

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.deleteCategoryButton) {
    if ([self selectedCategory] == nil) {
      return NO;
    }
  }
  
  if (anItem == self.addClipButton) {
    if ([self selectedCategory] == nil) {
      return NO;
    }
  }

  if (anItem == self.deleteClipButton) {
    if ([self selectedEntries] == nil) {
      return NO;
    }
  }
  
  NSArray *selectedEntries = [self selectedEntries];
  
  if (anItem == self.reloadClipButton) {
    if (selectedEntries == nil) {
      return NO;
    }
  }
  
  if (anItem == self.editClipButton) {
    if (selectedEntries == nil || [selectedEntries count] != 1) {
      return NO;
    }
  }
  
  if (anItem == self.clipCopyButton) {
    if (selectedEntries == nil) {
      return NO;
    }
  }
  
  if (anItem == self.insertClipButton) {
    if (selectedEntries == nil ) {
      return NO;
    }
  }

  return YES;
}

@end
