//
//  LibraryController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "LibraryController.h"
#import "ImageAndTextCell.h"
#import "NSWorkspaceExtended.h"
#import "NSNotificationAdditions.h"
#import "LibraryImageGenerator.h"
#import "externs.h"

@implementation LibraryController

NSString * const kItemsTableViewNodeType = @"ItemsTableViewNodeType";
//static LibraryController *sharedLibraryController = nil;

@synthesize textBeforeEditing;


//- (id)init
//{
//  Class LibraryController = [self class];
//  @synchronized(LibraryController) {
//    if (sharedLibraryController == nil) {
//      if ((self = [super init])) {
//        sharedLibraryController = self;
//        // custom initialization here
//      }
//    }
//  }
//  return sharedLibraryController;
//}


- (id) init
{
//  NSLog(@"Library Controller init");
  self = [super init];
  if (self) {
    unknownImage = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
  }
  return self;
}


- (void) awakeFromNib
{
//  NSLog(@"Library Controller awakeFromNib");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  
  // set row height
  [slider setFloatValue:[[defaults valueForKey:TPLibraryRowHeight] floatValue]];
	[itemsTable setRowHeight:[slider floatValue]];
  
  // set up the library
  [self setupLibrary];
	
	// Set up the tables
	[itemsTable registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];

	[self createAddMenu];
	[self createCategoryActionMenu];
  
  // observe changes to the library in user defaults
  [defaults addObserver:self
             forKeyPath:@"Library"
                options:NSKeyValueObservingOptionNew 
                context:NULL];
  
}

- (void) setupLibrary
{
//  NSLog(@"Setting up library");
  
	// Now make a mutable dictionary for the library
	library = [[NSMutableDictionary alloc] init];
	NSMutableArray *categories = [self categorySetFromDefaults];	
	[library setObject:categories forKey:@"Categories"];
	
	// save this back the user defaults straight away
//  [self saveLibrary];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject:library forKey:@"Library"];
	[defaults synchronize];
	
  //	NSLog(@"Loaded library: %@", library);
  //	NSMutableArray *categories = [NSMutableArray arrayWithArray:[library valueForKey:@"Categories"]];
	[categoryController setContent:categories];
}

- (void) reloadLibrary
{
  // get table selections
  NSInteger catRow = [categoryTable selectedRow];
  NSInteger clipRow = [itemsTable selectedRow];
  
	NSMutableArray *categories = [self categorySetFromDefaults];	
	[library setObject:categories forKey:@"Categories"];
  [categoryController setContent:categories];
  
  [categoryTable selectRowIndexes:[NSIndexSet indexSetWithIndex:catRow] byExtendingSelection:NO];
  [itemsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:clipRow] byExtendingSelection:NO];
  
}

- (NSMutableArray*)categorySetFromDefaults
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  // read library
	NSDictionary *libraryIn = [defaults valueForKey:@"Library"];  
	NSMutableArray *categories = [NSMutableArray array];
	
	// check all images
	for (NSDictionary *category in [libraryIn valueForKey:@"Categories"]) {
		NSMutableDictionary *newCategory = [[NSMutableDictionary alloc] init];
		[newCategory setValue:[category valueForKey:@"Name"] forKey:@"Name"];		
		NSMutableArray *clips = [NSMutableArray array];		
		for (NSMutableDictionary *clip in [category valueForKey:@"Contents"]) {
			
			NSMutableDictionary *newClip = [[NSMutableDictionary alloc] initWithDictionary:clip];
			[newClip setValue:[[clip valueForKey:@"Code"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
								 forKey:@"Code"];
			
			NSData *data = [clip valueForKey:@"Image"];
			NSImage *image = nil;
			if (data) {
				if ([data length] > 0) {
					image = [NSKeyedUnarchiver unarchiveObjectWithData:data];
				}
			}
			
			if (image == nil || ![image isValid]) {
				[newClip setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSImage imageNamed:NSImageNameRefreshTemplate]] forKey:@"Image"];						
				// launch a thread to compute the image
				LibraryImageGenerator *ig = [[[LibraryImageGenerator alloc] initWithSymbol:newClip
																																					mathMode:NO
																																		 andController:self] autorelease];
				
				[NSThread detachNewThreadSelector:@selector(generateImage) toTarget:ig withObject:nil];
			}
			
			[newClip setValue:[NSNumber numberWithBool:YES] forKey:@"validImage"];
			
			// add the new clip to the contents
			[clips addObject:newClip];			
			[newClip release];
		}		
		[newCategory setValue:clips forKey:@"Contents"];		
		// Category is ready, add it to the array
		[categories addObject:newCategory];		
		[newCategory release];
	}
  return categories;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//  NSLog(@"Keypath changed: %@", keyPath);
  if ([keyPath isEqualToString:@"Library"]) {
    [self reloadLibrary];
  }
}

- (void) createCategoryActionMenu
{
	
	// Make popup menu with bound actions
	catActionMenu = [[NSMenu alloc] initWithTitle:@"Library Category Action Menu"];	
	[catActionMenu setAutoenablesItems:YES];
	
	// Add default categories
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Add Default Categories"
																								action:@selector(addDefaultCategories)
																				 keyEquivalent:@""];
  [item setTarget:self];
	[catActionMenu addItem:item];
	[item release];		
	
	// Restore default library
	item = [[NSMenuItem alloc] initWithTitle:@"Restore Default Library"
																		action:@selector(restoreDefaultLibrary)
														 keyEquivalent:@""];
  [item setTarget:self];
	[catActionMenu addItem:item];
	[item release];		
	
	
}

- (void) createAddMenu
{
	
	// Make popup menu with bound actions
	addMenu = [[NSMenu alloc] initWithTitle:@"Library Add Context Menu"];	
	[addMenu setAutoenablesItems:YES];
	
	// Add empty clipping
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"New clip"
																								action:@selector(addEmptyClipping)
																				 keyEquivalent:@""];
  [item setTarget:self];
	[addMenu addItem:item];
	[item release];		
	
	
	// Clipping from the pasteboard
	item = [[NSMenuItem alloc] initWithTitle:@"Clip from pasteboard"
																		action:@selector(addClipFromPasteboard)
														 keyEquivalent:@""];
  [item setTarget:self];
	[addMenu addItem:item];
	[item release];		
	
//	// Clipping from selected text
//	item = [[NSMenuItem alloc] initWithTitle:@"Clip from selection"
//																		action:@selector(addClipFromSelection)
//														 keyEquivalent:@""];
//	[addMenu addItem:item];
//	[item release];		
	
	
	
}


- (void) dealloc
{
  [self saveLibrary];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  [defaults removeObserver:self forKeyPath:@"Library"];
  [addMenu release];
	[unknownImage release];
	[library release];
	[super dealloc];
}

#pragma mark -
#pragma mark Edit Sheet

- (IBAction) startEditSheet:(id)sender
{
	[itemsTable abortEditing];
	NSArray *selected = [contentsController selectedObjects];
	
	NSDictionary *item = nil;
	if ([selected count] == 1) {
		item = [selected objectAtIndex:0];
	}
	
	NSString *code = [item valueForKey:@"Code"];
  [[editTextView textStorage] beginEditing];
  [[editTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:code] autorelease]];
  [[editTextView textStorage] endEditing];
  
	if (textBeforeEditing) {
		[textBeforeEditing release];
		textBeforeEditing = nil;
	}
	textBeforeEditing = [[NSString alloc] initWithString:code];
	
	[NSApp beginSheet:editSheet
		 modalForWindow:[self window]
			modalDelegate:self
		 didEndSelector:@selector(editSheetDidEnd:returnCode:contextInfo:)
				contextInfo:NULL];	
	
  
  [editTextView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0.1];
}

- (void)editSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	NSString *newText = nil;
  newText = [editTextView string];
	NSArray *selected = [contentsController selectedObjects];
	if ([selected count] == 1) {
		NSDictionary *item = [selected objectAtIndex:0];
    [item setValue:newText forKey:@"Code"];
	}
  
//  
//  NSLog(@"New text %@", newText);
//  NSLog(@"Old text %@", self.textBeforeEditing);
	
	if (newText && self.textBeforeEditing) {
		if (![newText isEqualToString:self.textBeforeEditing]) {
			// regenerate image
//      NSLog(@"Text is different");
      [self performSelector:@selector(refreshSymbolAtRow:) withObject:[NSNumber numberWithInteger:[itemsTable selectedRow]] afterDelay:0];
//			[self refreshSymbolAtRow:[NSNumber numberWithInteger:[itemsTable selectedRow]]];
		}
	} else {
		[self refreshSymbolAtRow:[NSNumber numberWithInteger:[itemsTable selectedRow]]];		
	}
	
}

- (IBAction) endEditSheet:(id)sender
{	
	[NSApp endSheet:editSheet];
	[editSheet orderOut:self];
	[self saveLibrary];	
}

#pragma mark -
#pragma mark Control 

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
	
	
	[NSMenu popUpContextMenu:catActionMenu withEvent:event forView:(NSButton *)sender];
	
	
}

- (IBAction) restoreDefaultLibrary
{
	// As the user 
	
	
	
	NSAlert *alert = [NSAlert alertWithMessageText:@"Restore Default Library?"
																	 defaultButton:@"No" alternateButton:@"Yes"
																		 otherButton:nil 
											 informativeTextWithFormat:@"Do you really want to restore the default Library? You will lose any changes you've made to the Library."
										]; 
	[alert beginSheetModalForWindow:[self window] modalDelegate:self
									 didEndSelector:@selector(restoreLibraryEnded:code:context:) 
											contextInfo:NULL];
	
}

- (void)restoreLibraryEnded:(NSAlert *)alert 
											 code:(int)choice 
										context:(void *)v
{
	if (choice == NSAlertDefaultReturn) {
		return;		
	} 	
	
	if (choice == NSAlertAlternateReturn) {		
		[categoryController removeObjects:[categoryController arrangedObjects]];		
		// add new 
		[self addDefaultCategories];
	}	
}	

- (void) addDefaultCategories
{
	
	// load the library plist from the bundle
	NSString *libpath = [[NSBundle mainBundle] pathForResource:@"Library" ofType:@"plist"];
	NSDictionary *defaultLibrary = [NSMutableDictionary dictionaryWithContentsOfFile:libpath];

	// Add each category to the current library
	// check all images
	for (NSDictionary *category in [defaultLibrary valueForKey:@"Categories"]) {
		NSMutableDictionary *newCategory = [[NSMutableDictionary alloc] init];
		[newCategory setValue:[category valueForKey:@"Name"] forKey:@"Name"];		
		NSMutableArray *clips = [NSMutableArray array];		
		for (NSMutableDictionary *clip in [category valueForKey:@"Contents"]) {
			
			NSMutableDictionary *newClip = [[NSMutableDictionary alloc] initWithDictionary:clip];
			[newClip setValue:[[clip valueForKey:@"Code"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
								 forKey:@"Code"];
			
			NSData *data = [clip valueForKey:@"Image"];
			NSImage *image = nil;
			if (data) {
				if ([data length] > 0) {
					image = [NSKeyedUnarchiver unarchiveObjectWithData:data];
				}
			}
			
			if (image == nil || ![image isValid]) {
				[newClip setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSImage imageNamed:NSImageNameRefreshTemplate]] forKey:@"Image"];						
				// launch a thread to compute the image
				LibraryImageGenerator *ig = [[[LibraryImageGenerator alloc] initWithSymbol:newClip
																																					mathMode:NO
																																		 andController:self] autorelease];
				
				[NSThread detachNewThreadSelector:@selector(generateImage) toTarget:ig withObject:nil];
			}
			
			[newClip setValue:[NSNumber numberWithBool:YES] forKey:@"validImage"];
			
			// add the new clip to the contents
			[clips addObject:newClip];			
			[newClip release];
		}		
		[newCategory setValue:clips forKey:@"Contents"];		
		// Category is ready, add it to the array
		[categoryController addObject:newCategory];
		[newCategory release];
	}
	
	[self saveLibrary];
	
}



- (IBAction) refreshSymbolAtRow:(NSNumber*)rowVal
{
	NSInteger row = [rowVal integerValue];
	if (row >= 0) {
		NSMutableDictionary *symbol = [[contentsController arrangedObjects] objectAtIndex:row];
		if (!unknownImage) {
			unknownImage = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
		}
		[symbol setObject:[NSKeyedArchiver archivedDataWithRootObject:unknownImage] forKey:@"Image"];
		[symbol setValue:[NSNumber numberWithBool:NO] forKey:@"validImage"];
	}
}

- (IBAction) refreshImages:(id)sender
{
	NSArray *selected = [contentsController selectedObjects];
	for (NSMutableDictionary *symbol in selected) {
		if (!unknownImage) {
			unknownImage = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
		}
		[symbol setObject:[NSKeyedArchiver archivedDataWithRootObject:unknownImage] forKey:@"Image"];
		[symbol setValue:[NSNumber numberWithBool:NO] forKey:@"validImage"];
	}
}

- (IBAction) copySelectedItemsToPasteboard:(id)sender
{
	NSArray *items = [contentsController selectedObjects];
	NSString *string = [[items valueForKey:@"Code"] componentsJoinedByString:@"\n"];
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pb setString:string forType:NSStringPboardType];
}

- (IBAction) insertSelectedItems:(id)sender
{
	// get the selected text
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if (doc) {		
		if ([doc respondsToSelector:@selector(insertTextToCurrentDocument:)]) {
			NSArray *items = [contentsController selectedObjects];
			NSString *string = [[items valueForKey:@"Code"] componentsJoinedByString:@"\n"];			
			[doc performSelector:@selector(insertTextToCurrentDocument:) withObject:string];
		}		
	}
}

- (IBAction) addCategory:(id)sender
{
	NSInteger N = [[categoryController arrangedObjects] count];
	NSMutableDictionary *newCategory = [NSMutableDictionary dictionary];
	[newCategory setObject:[NSString stringWithFormat:@"New Category %d", N] forKey:@"Name"];
	[newCategory setObject:[NSMutableArray array] forKey:@"Contents"];
	[categoryController addObject:newCategory];
	[self saveLibrary];
}

- (IBAction) deleteItems:(id)sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete Clippings?"
																	 defaultButton:@"Delete" alternateButton:@"Cancel"
																		 otherButton:nil 
											 informativeTextWithFormat:@"Do you really want to delete the selected clippings? You can't undo this!"
										]; 
	[alert beginSheetModalForWindow:[self window] modalDelegate:self
									 didEndSelector:@selector(removeItemsAlertEnded:code:context:) 
											contextInfo:NULL];
	
}

- (void)removeItemsAlertEnded:(NSAlert *)alert 
															code:(int)choice 
													 context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
		
		// delete the selected categories
		NSArray *items = [contentsController selectedObjects];
		[contentsController removeObjects:items];
		[self saveLibrary];
		
	} else {
		// do nothing
	}
	
}


- (IBAction) removeCategories:(id)sender
{
	
//	NSArray *categories = [categoryController selectedObjects];
//	NSLog(@"Removing: %@", categories);
//	
//	return;
	
	// ask the user if they want to delete the selected categories
	// ask the user with a sheet
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete Category?"
																	 defaultButton:@"Delete" alternateButton:@"Cancel"
																		 otherButton:nil 
											 informativeTextWithFormat:@"Do you really want to delete the selected category and its content? You can't undo this!"
										]; 
	[alert beginSheetModalForWindow:[self window] modalDelegate:self
									 didEndSelector:@selector(removeCategoriesAlertEnded:code:context:) 
											contextInfo:NULL];
	
}

- (void)removeCategoriesAlertEnded:(NSAlert *)alert 
														code:(int)choice 
												 context:(void *)v
{
	
	if (choice == NSAlertDefaultReturn) {
		
		// delete the selected categories
		NSIndexSet *indices = [categoryTable selectedRowIndexes];
		[categoryController removeObjectsAtArrangedObjectIndexes:indices];
		[self saveLibrary];
		
	} else {
		// do nothing
	}
	
}



- (IBAction) setRowHeight:(id)sender
{
	CGFloat height = [sender floatValue];
	[itemsTable setRowHeight:height];
  
  // write to user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  [defaults setValue:[NSNumber numberWithFloat:height] forKey:TPLibraryRowHeight];
  [defaults synchronize];
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
	
	
	[NSMenu popUpContextMenu:addMenu withEvent:event forView:(NSButton *)sender];
		
}

- (void) addEmptyClipping
{	
	[self newClippingWithCode:[NSString stringWithFormat:@"New Clipping %d", [[contentsController arrangedObjects] count]]];
}

- (void) addClipFromPasteboard
{
	NSString *code = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
	[self newClippingWithCode:code];
}

- (void) addClipFromSelection
{
	//id window = [NSApp keyWindow];
	
//	NSLog(@"Key window: %@", window);
	

}

- (void) newClippingWithCode:(NSString*)someCode
{
	NSMutableDictionary *newClipping = [NSMutableDictionary dictionary];
	[newClipping setObject:someCode forKey:@"Code"];
	[contentsController addObject:newClipping];
	[self saveLibrary];
}

- (void) saveLibrary
{
	[library setObject:[categoryController arrangedObjects] forKey:@"Categories"];
	//NSLog(@"Saving library...");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject:library forKey:@"Library"];
	[defaults synchronize];
	[defaults didChangeValueForKey:@"Library"];
}

//+ (LibraryController*)sharedLibraryController
//{
//	@synchronized(self) {
//		if (sharedLibraryController == nil) {
//			[[self alloc] init]; // assignment not done here			
//		}
//	}
//	return sharedLibraryController;
//}

- (void) setupTables
{
	[itemsTable registerForDraggedTypes:[NSArray arrayWithObjects:kItemsTableViewNodeType,nil]];
}

//+ (id)allocWithZone:(NSZone *)zone
//{
//	@synchronized(self) {
//		if (sharedLibraryController == nil) {
//			sharedLibraryController = [super allocWithZone:zone];
//			[sharedLibraryController setupTables];
//			return sharedLibraryController;  // assignment and return on first allocation
//		}
//	}
//	return nil; //on subsequent allocation attempts return nil
//}
//
//- (id)copyWithZone:(NSZone *)zone
//{
//	return self;
//}
//
//- (id)retain
//{
//	return self;
//}
//
//- (NSUInteger)retainCount
//{
//  return NSUIntegerMax; // This is sooo not zero
//}
//
//- (void)release
//{
//	//do nothing
//}
//
//- (id)autorelease
//{
//	return self;
//}



#pragma mark -
#pragma mark TableView data source


#pragma mark -
#pragma mark Items Table Drag-n-drop

- (NSDragOperation)tableView:(NSTableView*)aTableView 
								validateDrop:(id <NSDraggingInfo>)info 
								 proposedRow:(int)row 
			 proposedDropOperation:(NSTableViewDropOperation)op
{
//	NSTableView *sourceTable = [info draggingSource];
	
	if (aTableView == itemsTable) {
		/** Items Table **/
//		if (op == NSTableViewDropAbove) {
//			return NSDragOperationMove;
//		} else {
			return NSDragOperationCopy;
//		}
	}
	
//	// Copy from items table to category table
//	if (aTableView == categoryTable && sourceTable == itemsTable) {
//		if (op == NSTableViewDropOn) {
//			return NSDragOperationMove;
//		} else {
//			return NSDragOperationNone;
//		}		
//	}
	
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView 
			 acceptDrop:(id <NSDraggingInfo>)info
							row:(int)row 
		dropOperation:(NSTableViewDropOperation)operation
{
	//id source = [info draggingSource];
	//NSLog(@"Source %@", source);
	
	if (aTableView == itemsTable) {
		
		/** Items Table **/
		
		NSPasteboard* pboard = [info draggingPasteboard];
		NSString *string = [pboard stringForType:NSStringPboardType];
		//NSLog(@"Receiving %@", string);
		
		// get the first selected category
		NSMutableDictionary *category = [[categoryController selectedObjects] objectAtIndex:0];
		if (category) {
			// make a new entry in the category
			[self newClippingWithCode:string];			
		} else {
			// tell the user to select a category
		}

	} 
	
	// TODO: this is a bit harder. If we want to move items between categories 
	// then it isn't enough to paste the strings to the pasteboard. We should paste
	// the indices instead. But then the nstextview in the main document has to be 
	// registered for this type. So we do the usual thing and make a new pasteboard
	// type and go ahead with that.
	//
	// Alternatively, perhaps we can write two data types to the pasteboard at the 
	// same time, then the source can choose.
	
//	if (aTableView == categoryTable && source == itemsTable) {
//		
//		// get the symbol being moved
//		NSPasteboard* pboard = [info draggingPasteboard];
//		NSString *string = [pboard stringForType:NSPasteboardTypeString];
//		
//		// get the item being dropped
//		NSArray *items = [string componentsSeparatedByString:@" "];
//		
//
//		// get the category we are dopping on
//		NSArray *categories = [categoryController arrangedObjects];
//		NSManagedObject *category = [categories objectAtIndex:row];
//		
//																		
//		// remove it from its current category
//		[contentsController removeObjects:items];
//		
//		// add it to the proposed category
//		[categoryController setSelectionIndex:row];
//		[categoryController addObjects:items];
//		
//	}
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView 
writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
		 toPasteboard:(NSPasteboard*)pboard
{	
	if (aTableView == itemsTable) {
				
		NSArray *items = [[contentsController arrangedObjects] objectsAtIndexes:rowIndexes];			
		NSMutableArray *strings = [NSMutableArray array];
		for (NSDictionary *item in items) {
			[strings addObject:[item valueForKey:@"Code"]];
		}
//		id str = [[strings componentsJoinedByString:@"\n"] retain];
		id str = [strings componentsJoinedByString:@"\n"];
//		NSLog(@"Writing to pboard: %@", str);
		[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
		return [pboard setString:str forType:NSStringPboardType];
	}
	
	return NO;
}

#pragma mark -
#pragma mark TableView Delegate messages


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{	
}


- (NSString *)tableView:(NSTableView *)aTableView 
				 toolTipForCell:(NSCell *)aCell 
									 rect:(NSRectPointer)rect 
						tableColumn:(NSTableColumn *)aTableColumn 
										row:(NSInteger)row 
					mouseLocation:(NSPoint)mouseLocation
{
	if (aTableView == itemsTable) {
		NSDictionary *item = [[contentsController arrangedObjects] objectAtIndex:row];
		return [item valueForKey:@"Code"];		
	}
	
	return nil;
}


- (void)tableView:(NSTableView *)aTableView 
	willDisplayCell:(id)aCell 
	 forTableColumn:(NSTableColumn *)aTableColumn 
							row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqual:@"ImageColumn"]) {
		NSMutableDictionary *symbol = [[contentsController arrangedObjects] objectAtIndex:rowIndex];
		NSData *data = [symbol valueForKey:@"Image"];
		BOOL validImage = [[symbol valueForKey:@"validImage"] boolValue];
		
		NSImage *image = nil;
		if (data) {
			if ([data length] > 0) {
//				NSLog(@"Data %d", [data length]);
				image = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			}
		}
		
		if (image == nil || !validImage) {
			[symbol setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSImage imageNamed:NSImageNameRefreshTemplate]] forKey:@"Image"];		
			
			// launch a thread to compute the image
			LibraryImageGenerator *ig = [[[LibraryImageGenerator alloc] initWithSymbol:symbol
																																				mathMode:NO
																																	 andController:self] autorelease];
			
			[NSThread detachNewThreadSelector:@selector(generateImage) 
															 toTarget:ig
														 withObject:nil];
		}
	}
}


- (void) imageGeneratorTaskEnded:(NSString*)aPath
{
//	NSLog(@"Task ended %@", aPath);
//	NSTask *task = [aNote object];
//	NSLog(@"A Task ended: saving library %@", [task arguments]);
	// save the library
	[self saveLibrary];
	
}




@end
