//
//  OpenDocument.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "FileDocument.h"
#import "externs.h"
#import "FileEntity.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "NSMutableAttributedString+Placeholders.h"
#import "NSDictionary+TeXnicle.h"
#import "NSArray+Color.h"
#import "MHFileReader.h"

@implementation FileDocument

- (id) initWithFile:(FileEntity*)aFile
{
	self = [super init];
	
	if (self) {
		
//		NSLog(@"Creating document for %@", [aFile name]);
		self.file = aFile;
		
		// Get the string from the File entity
    MHFileReader *fr = [[MHFileReader alloc] init];
    NSStringEncoding encoding = [fr encodingForFileAtPath:[self.file pathOnDisk]];
		NSString *str = [[NSString alloc] initWithData:[self.file valueForKey:@"content"]
																					encoding:encoding];
    
		// Setup undo manager for this file
		self.undoManager = [[NSUndoManager alloc] init];
		
		// Setup a text storage to hold this string
		NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
		[attStr addAttributes:[NSDictionary currentTypingAttributes] range:NSMakeRange(0, [str length])];
		self.textStorage = [[NSTextStorage alloc] initWithAttributedString:attStr];
    
		// Add a main layout manager
//		NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
//		[layoutManager setAllowsNonContiguousLayout:YES];
//		[self.textStorage addLayoutManager:layoutManager];
				
		// Now add the container to the layout manager
//		NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(LargeTextWidth, LargeTextHeight)];
//		[textContainer setWidthTracksTextView:NO];
//		[textContainer setHeightTracksTextView:NO];	
//		[layoutManager addTextContainer:textContainer];
				
		// Clean up
		
		// Now watch for changes to the text so that we can 
		// update the managed object
		[[NSNotificationCenter defaultCenter] addObserver:self
																						 selector:@selector(handleEdits:)
																								 name:NSTextStorageDidProcessEditingNotification
																							 object:self.textStorage];
	}
	
	return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSTextContainer*)textContainer
{
	// An ugly quick hack to return the 'main' text container for this document
	return nil; // [[self.textStorage layoutManagers][0] textContainers][0];
}

- (BOOL) commitEdits
{
	
	NSDate *lastEdit = [self.file valueForKey:@"lastEditDate"];
	
	if (lastEdit) {
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.textStorage];
		[string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
		
    // replace placeholders
    [string replacePlaceholdersInRange:NSMakeRange(0, [string length])];
    
		NSString *str = [string unfoldedString];
		
		//	NSString *str = [textStorage string];
    MHFileReader *fr = [[MHFileReader alloc] init];
    NSStringEncoding encoding = [fr encodingForFileAtPath:[self.file pathOnDisk]];
		NSData *data = [str dataUsingEncoding:encoding];
		
		if (![[self.file valueForKey:@"content"] isEqual:data]) {
			[self.file setValue:data forKey:@"content"];
    }
    return YES;
    
	}	else {
	}
	return NO;
}

- (void) handleEdits:(NSNotification*)aNote
{
  NSDate *loaded = [self.file valueForKey:@"fileLoadDate"];
  NSDate *lastEdit = [self.file valueForKey:@"lastEditDate"];
  
  // if the last edit is prior to the load, then we didn't edit so far
  if (self.file != nil) {
    if ([loaded compare:lastEdit] == NSOrderedAscending) {
      //    NSLog(@"Edit date later than loaded date");
      [self.file setValue:@YES forKey:@"hasEdits"];
      [self.file setValue:[NSDate date] forKey:@"lastEditDate"];
    } else {
      //    NSLog(@"Edit date earlier than loaded date");
      [self.file setValue:@NO forKey:@"hasEdits"];
      [self.file setPrimitiveValue:[NSDate date] forKey:@"lastEditDate"];
    }
  }
  
	// update all views
	for (NSLayoutManager *layout in [self.textStorage layoutManagers]) {
		for (NSTextContainer *tc in [layout textContainers]) {
			[[tc textView] setNeedsDisplay:YES];
		}
	}
	
	// tell the parent file the text changed
  [self.file textChanged];
}


@end
