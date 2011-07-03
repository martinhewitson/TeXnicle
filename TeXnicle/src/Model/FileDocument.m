//
//  OpenDocument.m
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "FileDocument.h"
#import "externs.h"
#import "NSMutableAttributedString+CodeFolding.h"

@implementation FileDocument

@synthesize file;
@synthesize textStorage;
@synthesize undoManager;

- (id) initWithFile:(NSManagedObject*)aFile
{
	self = [super init];
	
	if (self) {
		
//		NSLog(@"Creating document for %@", aFile);
		file = aFile;
		
		// Get the string from the File entity
		NSError *error = nil;
		NSString *str = [[NSString alloc] initWithData:[file valueForKey:@"content"]
																					encoding:NSUTF8StringEncoding];
		if (error) {
			[NSApp presentError:error];
			return nil;
		}
		
		// Setup undo manager for this file
		undoManager = [[NSUndoManager alloc] init];
		
		// Setup a text storage to hold this string
		NSMutableAttributedString *attStr = [[[NSMutableAttributedString alloc] initWithString:str] autorelease];
		
		textStorage = [[NSTextStorage alloc] initWithAttributedString:attStr];
									 		
		// Add a main layout manager
		NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
		[layoutManager setAllowsNonContiguousLayout:NO];
		[textStorage addLayoutManager:layoutManager];
				
		// Now add the container to the layout manager
		NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
		[textContainer setWidthTracksTextView:NO];
		[textContainer setHeightTracksTextView:NO];	
		[layoutManager addTextContainer:textContainer];
						
		// Clean up
		[textContainer release];
		[layoutManager release];
		[str release];
		
		
		// Now watch for changes to the text so that we can 
		// update the managed object
		[[NSNotificationCenter defaultCenter] addObserver:self
																						 selector:@selector(handleEdits:)
																								 name:NSTextStorageDidProcessEditingNotification
																							 object:textStorage];
		
		//
//		if (empty) {			
//			NSLog(@"Emptying text storage");
//			[textStorage beginEditing];
//			[textStorage deleteCharactersInRange:NSMakeRange(0, [[textStorage string] length])]; 
//			[textStorage endEditing];
//		}
//		
		
	}
	
	return self;
}

- (void) dealloc
{
	[undoManager release];
	[textStorage release];
	[super dealloc];
}

- (NSTextContainer*)textContainer
{
	// An ugly quick hack to return the 'main' text container for this document
	return [[[[textStorage layoutManagers] objectAtIndex:0] textContainers] objectAtIndex:0];
}

- (BOOL) commitEdits
{
	
	NSDate *lastEdit = [file valueForKey:@"lastEditDate"];
//	NSDate *loadDate = [file valueForKey:@"fileLoadDate"];
//	
//	NSLog(@"Last edit: %@", lastEdit);
//	NSLog(@"Loaded: %@", loadDate);
	
	if (lastEdit) {
//		NSComparisonResult res = [loadDate compare:lastEdit];
//		NSLog(@"Res: %d", res);
//		if (res == NSOrderedDescending) {
			//	NSAttributedString *attStr = [textStorage attributedString];
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:textStorage];
		[string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
		
		NSString *str = [string unfoldedString];
		[string release];
		
		//	NSString *str = [textStorage string];
		NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
		
		if (![[file valueForKey:@"content"] isEqual:data]) {
			[file setValue:data forKey:@"content"];
//			[string release];
			return YES;
		}	else {
//			NSLog(@"Nothing to commit for %@", [file valueForKey:@"name"]);
		}
	}	else {
//		NSLog(@"Nothing to commit for %@", [file valueForKey:@"name"]);
	}
	return NO;
}

- (void) handleEdits:(NSNotification*)aNote
{
//	NSLog(@"Handling edits for %@...", [file valueForKey:@"name"]);
  
  // check if the text really changed
//  NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:textStorage];
//  [string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];  
//  NSString *str = [string unfoldedString];
//  [string release];
//  
//  NSString *cachedString = [file valueForKey:@"contentString"];
//  if (![cachedString isEqualToString:str]) {
    [file setValue:[NSNumber numberWithBool:YES] forKey:@"hasEdits"];
    [file setValue:[NSDate date] forKey:@"lastEditDate"];
//  }  
  	
	// update all views
	for (NSLayoutManager *layout in [textStorage layoutManagers]) {
		for (NSTextContainer *tc in [layout textContainers]) {
			[[tc textView] setNeedsDisplay:YES];
		}
	}
	
	// notify anyone interested that there were edits
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *dict = nil;
	dict = [NSDictionary dictionaryWithObject:file forKey:@"File"];
	[nc postNotificationName:TPFileItemTextStorageChangedNotification object:self userInfo:dict];
	
	
}


@end
