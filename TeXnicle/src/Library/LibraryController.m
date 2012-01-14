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
#import "TPLibraryCommandFormatter.h"
#import "NSStringUUID.h"

@implementation LibraryController

NSString * const kItemsTableViewNodeType = @"ItemsTableViewNodeType";

@synthesize delegate;
@synthesize textBeforeEditing;
@synthesize addCategoryButton;
@synthesize deleteCategoryButton;
@synthesize addClipButton;
@synthesize deleteClipButton;
@synthesize reloadClipButton;
@synthesize editClipButton;
@synthesize clipCopyButton;
@synthesize insertClipButton;
@synthesize commandTextField;
@synthesize defaultLibrary;
@synthesize commandMessageLabel;
@synthesize knownCommands;

+ (NSString*) placeholderRegexp
{
 return @"\\@[^\\@]*\\@";
}

- (id) initWithDelegate:(id<LibraryControllerDelegate>)aDelegate
{
	self = [super initWithNibName:@"LibraryController" bundle:nil];
  if (self) {
    unknownImage = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
    self.delegate = aDelegate;
  }
  return self;
}


- (void) awakeFromNib
{
//  NSLog(@"Library Controller awakeFromNib");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  
  // load the library plist from the bundle
	NSString *libpath = [[NSBundle mainBundle] pathForResource:@"Library" ofType:@"plist"];
	self.defaultLibrary = [NSMutableDictionary dictionaryWithContentsOfFile:libpath];

  
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
  
  TPLibraryCommandFormatter *formatter = [[[TPLibraryCommandFormatter alloc] init] autorelease];
  [self.commandTextField setFormatter:formatter];
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
  
  [self regenerateKnownCommandCodes];
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
      
      [newClip setValue:[clip valueForKey:@"Command"] forKey:@"Command"];
      [newClip setValue:[clip valueForKey:@"BuiltIn"] forKey:@"BuiltIn"];
			
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
//      NSLog(@"Checking new clip %@", [newClip valueForKey:@"Code"]);
//      NSLog(@"    command: %@", [newClip valueForKey:@"Command"]);
      // apply default command if it is currently empty
      if ([newClip valueForKey:@"Command"] == nil && [[newClip valueForKey:@"BuiltIn"] boolValue]) {
//        [newClip setValue:@"" forKey:@"Command"];
        for (NSDictionary *dcategory in [self.defaultLibrary valueForKey:@"Categories"]) {
          for (NSMutableDictionary *dclip in [dcategory valueForKey:@"Contents"]) {
            NSString *command = [dclip valueForKey:@"Command"];
            if (command != nil) {
//              NSLog(@"Default code: %@", [dclip valueForKey:@"Code"]);
//              NSLog(@"   new clip: %@", [newClip valueForKey:@"Code"]);
              if ([[dclip valueForKey:@"Code"] isEqualToString:[newClip valueForKey:@"Code"]]) {
//                NSLog(@"Assign command %@", command);
                [newClip setValue:command forKey:@"Command"]; 
              }
            }
          }
        }
      }
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

	
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.deleteCategoryButton) {
    return [categoryController canRemove];
  }
  
  if (anItem == self.addClipButton) {
    return [contentsController canAdd];
  }
  
  if (anItem == self.deleteClipButton) {
    return [contentsController canRemove];
  }
  
  if (anItem == self.reloadClipButton) {
    return [contentsController canRemove];
  }
  
  if (anItem == self.insertClipButton) {
    return [contentsController canRemove];
  }
  
  if (anItem == self.editClipButton) {
    return [contentsController canRemove];
  }
  
  if (anItem == self.clipCopyButton) {
    return [contentsController canRemove];
  }
  
  return YES;
}



- (void) dealloc
{
  [self saveLibrary];
  self.delegate = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  [defaults removeObserver:self forKeyPath:@"Library"];
  self.defaultLibrary = nil;
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
	} else {
    return;
  }
	
	NSString *code = [item valueForKey:@"Code"];
  [[editTextView textStorage] beginEditing];
  [[editTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:code] autorelease]];
  [[editTextView textStorage] endEditing];
  [editTextView applyFontAndColor];
  
	if (textBeforeEditing) {
		[textBeforeEditing release];
		textBeforeEditing = nil;
	}
	textBeforeEditing = [[NSString alloc] initWithString:code];
	
	[NSApp beginSheet:editSheet
		 modalForWindow:[[self view] window]
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
	NSNumber *userLibraryVersion = [library valueForKey:@"Version"];
//  NSNumber *defaultLibraryVersion = [self.defaultLibrary valueForKey:@"Version"];
	
  NSString *informativeText;
	if (userLibraryVersion == nil) {
    informativeText = @"Do you really want to restore the default Library? You will lose any changes you've made to the Library.";
  } else {
    informativeText = @"Do you really want to restore the default Library? You will lose any changes you've made to the default categories and clips of the Library.";
  }
  
	NSAlert *alert = [NSAlert alertWithMessageText:@"Restore Default Library?"
																	 defaultButton:@"No" alternateButton:@"Yes"
																		 otherButton:nil 
											 informativeTextWithFormat:informativeText
										]; 
	[alert beginSheetModalForWindow:[[self view ] window] modalDelegate:self
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
    
    // check library version
    NSNumber *userLibraryVersion = [library valueForKey:@"Version"];
//    NSNumber *defaultLibraryVersion = [self.defaultLibrary valueForKey:@"Version"];
    
    if (userLibraryVersion != nil) {
      [self restoreDefaultCategoriesAndCodes];
    } else {
      
      [categoryController removeObjects:[categoryController arrangedObjects]];		
      [self addDefaultCategories];
    }
	}	
}	

- (void) restoreDefaultCategoriesAndCodes
{
//  NSLog(@"Restoring library defaults...");
  NSArray *clipKeys = [NSArray arrayWithObjects:@"Code", @"BuiltIn", @"Command", @"Image", @"validImage", nil];
  
  // go through each default category
	for (NSDictionary *defaultCategory in [self.defaultLibrary valueForKey:@"Categories"]) {
    // go through each user category looking for a match
    for (NSDictionary *userCategory in [library valueForKey:@"Categories"]) {
      if ([[userCategory valueForKey:@"Name"] isEqualToString:[defaultCategory valueForKey:@"Name"]]) {
//        NSLog(@"Working on default category %@", [defaultCategory valueForKey:@"Name"]);
        // check each clip
        for (NSMutableDictionary *defaultClip in [defaultCategory valueForKey:@"Contents"]) {

          //          NSLog(@"  Checking for default clip %@", [defaultClip valueForKey:@"UUID"]);
          NSInteger clipIndex = 0;
          
          for (NSMutableDictionary *userClip in [userCategory valueForKey:@"Contents"]) {
//            NSLog(@"    Checking user clip %@", [userClip valueForKey:@"UUID"]);
            NSString *defaultUUID = [defaultClip valueForKey:@"UUID"];
            NSString *userUUID = [userClip valueForKey:@"UUID"];
            
            if ([defaultUUID isEqualToString:userUUID]) {
              
              for (NSString *key in clipKeys) {
                [userClip setValue:[defaultClip valueForKey:key] forKey:key];
              }
              
            } // end if user clip is built-in
            clipIndex++;
          } // end loop over user clips
          
          
          
        } // end loop over default clips
      } // end if category names the same
    } // end loop over user categories
  } // end loop over default categories
  
//  NSNumber *userLibraryVersion = [library valueForKey:@"Version"];
  NSNumber *defaultLibraryVersion = [self.defaultLibrary valueForKey:@"Version"];
  
  [library setValue:defaultLibraryVersion forKey:@"Version"];
  
  [self saveLibrary];
  [categoryTable reloadData];
  [itemsTable reloadData];
}

- (NSDictionary*)createCopyOfClip:(NSDictionary*)clip
{
  NSMutableDictionary *newClip = [[NSMutableDictionary alloc] initWithDictionary:clip];
  [newClip setValue:[[clip valueForKey:@"Code"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
             forKey:@"Code"];
  
  [newClip setValue:[clip valueForKey:@"Command"] forKey:@"Command"];
  [newClip setValue:[clip valueForKey:@"BuiltIn"] forKey:@"BuiltIn"];
  if ([clip valueForKey:@"UUID"]) {
    [newClip setValue:[clip valueForKey:@"UUID"] forKey:@"UUID"];
  } else {
    [newClip setValue:[NSString stringWithUUID]  forKey:@"UUID"];  
  }
  
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
  
  return [newClip autorelease];
}

- (void) addDefaultCategories
{
	
	// Add each category to the current library
	// check all images
	for (NSDictionary *category in [self.defaultLibrary valueForKey:@"Categories"]) {
		NSMutableDictionary *newCategory = [[NSMutableDictionary alloc] init];
		[newCategory setValue:[category valueForKey:@"Name"] forKey:@"Name"];		
		NSMutableArray *clips = [NSMutableArray array];		
		for (NSMutableDictionary *clip in [category valueForKey:@"Contents"]) {			
			// add the new clip to the contents
			[clips addObject:[self createCopyOfClip:clip]];			
		}		
		[newCategory setValue:clips forKey:@"Contents"];		
		// Category is ready, add it to the array
		[categoryController addObject:newCategory];
		[newCategory release];
	}
	
  NSNumber *defaultLibraryVersion = [self.defaultLibrary valueForKey:@"Version"];
  
  [library setValue:defaultLibraryVersion forKey:@"Version"];
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
  NSArray *items = [contentsController selectedObjects];
  NSString *string = [[items valueForKey:@"Code"] componentsJoinedByString:@"\n"];			
  [self libraryController:self insertText:string];
  
  
	// get the selected text
//	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
//	if (doc) {		
//		if ([doc respondsToSelector:@selector(insertTextToCurrentDocument:)]) {
//			NSArray *items = [contentsController selectedObjects];
//			NSString *string = [[items valueForKey:@"Code"] componentsJoinedByString:@"\n"];			
//			[doc performSelector:@selector(insertTextToCurrentDocument:) withObject:string];
//		}		
//	}
}

- (IBAction) addCategory:(id)sender
{
	NSInteger N = [[categoryController arrangedObjects] count];
	NSMutableDictionary *newCategory = [NSMutableDictionary dictionary];
	[newCategory setObject:[NSString stringWithFormat:@"New Category %d", N] forKey:@"Name"];
	[newCategory setObject:[NSMutableArray array] forKey:@"Contents"];
  [newCategory setValue:[NSNumber numberWithBool:NO] forKey:@"BuiltIn"];
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
	[alert beginSheetModalForWindow:[[self view] window] modalDelegate:self
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
	[alert beginSheetModalForWindow:[[self view] window] modalDelegate:self
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
}

- (void) newClippingWithCode:(NSString*)someCode
{
	NSMutableDictionary *newClipping = [NSMutableDictionary dictionary];
	[newClipping setObject:someCode forKey:@"Code"];
  [newClipping setValue:[NSNumber numberWithBool:NO] forKey:@"BuiltIn"];  
  [newClipping setValue:[NSString stringWithUUID] forKey:@"UUID"];
	[contentsController addObject:newClipping];
  NSInteger idx = [[contentsController arrangedObjects] indexOfObject:newClipping];
  if (idx != NSNotFound) {
    [itemsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
    [itemsTable scrollRowToVisible:idx];
  }
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


- (void) setupTables
{
	[itemsTable registerForDraggedTypes:[NSArray arrayWithObjects:kItemsTableViewNodeType,nil]];
}


- (void)regenerateKnownCommandCodes
{
  NSMutableArray *codes = [NSMutableArray array];
  for (NSDictionary *dcategory in [self.defaultLibrary valueForKey:@"Categories"]) {
    for (NSMutableDictionary *dclip in [dcategory valueForKey:@"Contents"]) {
      NSString *cmd = [dclip valueForKey:@"Command"];
      if (cmd != nil) {
        [codes addObject:cmd];
      }
    }
  }
  self.knownCommands = codes;
}



-(NSString*)codeForCommand:(NSString*)command
{
  for (NSDictionary *category in [library valueForKey:@"Categories"]) {
    for (NSMutableDictionary *clip in [category valueForKey:@"Contents"]) {
      NSString *clipCommand = [clip valueForKey:@"Command"];
      if (clipCommand) {
        if ([clipCommand isEqualToString:command]) {
          return [clip valueForKey:@"Code"];
        }
      }
    }
  }
  return nil;
}

- (NSArray*)commandsBeginningWith:(NSString*)prefix
{
  NSMutableArray *commands = [NSMutableArray array];
  if (prefix == nil || [prefix length] == 0) {
    return commands;    
  }
  
  if ([prefix characterAtIndex:0] != '#') {
    return commands;
  }
    
  NSString *cmdPrefix = [prefix substringFromIndex:1];
//  NSLog(@"Checking command %@", cmdPrefix);
  BOOL zeroLengthCommand = ([cmdPrefix length] == 0);
  for (NSString *cmd in self.knownCommands) {
    if ([cmd hasPrefix:cmdPrefix] || zeroLengthCommand) {
      [commands addObject:[@"#" stringByAppendingString:cmd]];
    }
  }
  return commands;
}

#pragma mark -
#pragma mark TableView data source


#pragma mark -
#pragma mark Items Table Drag-n-drop

- (NSDragOperation)tableView:(NSTableView*)aTableView 
								validateDrop:(id <NSDraggingInfo>)info 
								 proposedRow:(NSInteger)row 
			 proposedDropOperation:(NSTableViewDropOperation)op
{
	NSTableView *sourceTable = [info draggingSource];
//	NSLog(@"Dragging from %@", sourceTable);
	if (sourceTable != aTableView && aTableView == itemsTable) {
//    NSLog(@"To items table");
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
							row:(NSInteger)row 
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

#pragma mark -
#pragma mark LibraryController Delegate

-(void)libraryController:(LibraryController *)library insertText:(NSString *)text
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(libraryController:insertText:)]) {
    [self.delegate libraryController:self insertText:text];
  }
}


#pragma mark -
#pragma mark Text field delegate

- (BOOL) control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
  if (control == itemsTable) {

    return YES;
    
  } else if (control == commandTextField) {
    NSString *proposed = [fieldEditor string];
    
    for (NSString* cmd in self.knownCommands) {
      if ([cmd isEqualToString:proposed]) {
        [self.commandMessageLabel setStringValue:@"Command exists."];
        return NO;
      }
    }
    [self.commandMessageLabel setStringValue:@""];
    
//    NSLog(@"Set %@", [[contentsController selectedObjects] objectAtIndex:0]);
    [self saveLibrary];
    [self regenerateKnownCommandCodes];
    
  }
  
  return YES;
}


@end
