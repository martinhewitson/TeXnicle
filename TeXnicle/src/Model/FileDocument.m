//
//  OpenDocument.m
//  CDMultiTextView
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "FileDocument.h"
#import "externs.h"
#import "FileEntity.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "NSDictionary+TeXnicle.h"
#import "NSArray+Color.h"
#import "MHFileReader.h"

@implementation FileDocument

@synthesize file;
@synthesize textStorage;
@synthesize undoManager;

- (id) initWithFile:(FileEntity*)aFile
{
	self = [super init];
	
	if (self) {
		
//		NSLog(@"Creating document for %@", aFile);
		file = aFile;
		
		// Get the string from the File entity
		NSError *error = nil;
    MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
    NSStringEncoding encoding = [fr encodingForFileAtPath:[file pathOnDisk]];
		NSString *str = [[[NSString alloc] initWithData:[file valueForKey:@"content"]
																					encoding:encoding] autorelease];
		if (error) {
			[NSApp presentError:error];
			return nil;
		}
		
		// Setup undo manager for this file
		undoManager = [[NSUndoManager alloc] init];
		
		// Setup a text storage to hold this string
		NSMutableAttributedString *attStr = [[[NSMutableAttributedString alloc] initWithString:str] autorelease];
		[attStr addAttributes:[NSDictionary currentTypingAttributes] range:NSMakeRange(0, [str length])];
		textStorage = [[NSTextStorage alloc] initWithAttributedString:attStr];
									 		
		// Add a main layout manager
		NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
		[layoutManager setAllowsNonContiguousLayout:YES];
		[textStorage addLayoutManager:layoutManager];
				
		// Now add the container to the layout manager
		NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
		[textContainer setWidthTracksTextView:NO];
		[textContainer setHeightTracksTextView:NO];	
		[layoutManager addTextContainer:textContainer];
						
		// Clean up
		[textContainer release];
		[layoutManager release];
		
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
	
	if (lastEdit) {
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:textStorage];
		[string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
		
		NSString *str = [string unfoldedString];
		[string release];
		
		//	NSString *str = [textStorage string];
    MHFileReader *fr = [[MHFileReader alloc] init];
    NSStringEncoding encoding = [fr encodingForFileAtPath:[file pathOnDisk]];
    [fr release];
		NSData *data = [str dataUsingEncoding:encoding];
		
		if (![[file valueForKey:@"content"] isEqual:data]) {
			[file setValue:data forKey:@"content"];
			return YES;
		}	else {
		}
	}	else {
	}
	return NO;
}

- (void) handleEdits:(NSNotification*)aNote
{
  NSDate *loaded = [file valueForKey:@"fileLoadDate"];
  NSDate *lastEdit = [file valueForKey:@"lastEditDate"];
  
  // if the last edit is prior to the load, then we didn't edit so far
  if ([loaded compare:lastEdit] == NSOrderedAscending) {
//    NSLog(@"Edit date later than loaded date");
    [file setValue:[NSNumber numberWithBool:YES] forKey:@"hasEdits"];
    [file setValue:[NSDate date] forKey:@"lastEditDate"];
  } else {
//    NSLog(@"Edit date earlier than loaded date");
    [file setValue:[NSNumber numberWithBool:NO] forKey:@"hasEdits"];
    [file setPrimitiveValue:[NSDate date] forKey:@"lastEditDate"];
  }
  	
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
