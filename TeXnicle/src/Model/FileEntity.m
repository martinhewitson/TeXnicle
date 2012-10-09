//
//  FileEntity.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/1/10.
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

#import "FileEntity.h"
#import "NSString+RelativePath.h"
#import "FileDocument.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "externs.h"
#import "ConsoleController.h"
#import "Bookmark.h"
#import "NSString+FileTypes.h"
#import "MHFileReader.h"
#import "NSString+LaTeX.h"
#import "NSDictionary+TeXnicle.h"

@implementation FileEntity

@dynamic content;
@dynamic cursor;
@dynamic extension;
@dynamic fileLoadDate;
@dynamic isText;
@dynamic lastEditDate;
@dynamic visibleRect;
@dynamic wasOpen;
@dynamic bookmarks;
@dynamic mainFileOfProject;

@synthesize document;
@synthesize isActive;
@synthesize metadata;

- (void) awakeFromInsert
{
  self.metadata = [[TPFileEntityMetadata alloc] initWithParent:self];
  
	[self setPrimitiveValue:@"none" forKey:@"name"];
	[self setValue:@NO forKey:@"isText"];
	[self reconfigureDocument];
//	if (!document) {
////		NSLog(@"awakeFromInsert: Created document for %@", [self valueForKey:@"name"]);
//		document = [[FileDocument alloc] initWithFile:self];
//	}
  
  self.isActive = 0;
}

- (void) awakeFromFetch
{
	[super awakeFromFetch];
	
  self.metadata = [[TPFileEntityMetadata alloc] initWithParent:self];
  
	[self reloadFromDisk];
	
	// we should make sure the name is in sync with the filepath
	NSString *newName = [[self filepath] lastPathComponent];
  if (newName) {
    if (![[self name] isEqual:newName]) {
      [self setPrimitiveValue:newName forKey:@"name"];
    }
  }
	
//	if (!document) {
//		NSLog(@"awakeFromFetch: Created document for %@", [self valueForKey:@"name"]);
//		document = [[FileDocument alloc] initWithFile:self];
//	}
  
  self.isActive = 0;
}

- (void)increaseActiveCount
{
  self.isActive++;
//  NSLog(@"++ Active count for %@ = %ld", self.name, self.isActive);
}

- (void)decreaseActiveCount
{
  self.isActive--;
  if (self.isActive<0) {
    self.isActive = 0;
  }
//  NSLog(@"-- Active count for %@ = %ld", self.name, self.isActive);
}


- (void) reloadFromDisk
{
  [self reloadFromDiskWithEncoding:[MHFileReader defaultEncodingName]];
}

- (void) reloadFromDiskWithEncoding:(NSString*)encoding
{  
	// We should load the text from the file
	NSString *filepath = [self pathOnDisk];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filepath]) {
    MHFileReader *fr = [[MHFileReader alloc] initWithEncodingNamed:encoding];
//    NSLog(@"Loading with encoding %@", encoding);
    NSString *str = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:filepath]];
		
		if (!str) {
			str = @"";
		}
//    NSLog(@"%@: %@", self, str);
		NSData *data = [str dataUsingEncoding:[fr encodingUsed]];
//    NSLog(@"Loaded with encoding %@", [fr nameOfEncoding:[fr encodingUsed]]);
		[self setPrimitiveValue:data forKey:@"content"];
    if ([filepath pathIsText]) {
      [self setPrimitiveValue:@YES forKey:@"isText"];
    } else {
      [self setPrimitiveValue:@NO forKey:@"isText"];
    }
    // release file reader
	} 
  
  // Reconfigure the supporting FileDocument
	[self reconfigureDocument];
  
  // Set the time we load. When we save back to file we can 
  // check if the file was modified after this date and prompt
  // the user to overwrite changes or not.
  [self setPrimitiveValue:[NSDate date] forKey:@"fileLoadDate"];
  
}

- (void) setName:(NSString *)newName
{
	[self willChangeValueForKey:@"name"];
//	NSLog(@"Setting name of %@", self);
//	NSLog(@"... to %@", newName);
	
	// what extension should the new file get?
	NSString *extension = [newName pathExtension];
	if (!extension) {
		extension = [self extension];
		if (!extension) {
			extension = [[self filepath] pathExtension];
		}
		if (!extension) {
			extension = [[self pathOnDisk] pathExtension];
		}
		
		if (extension != nil && newName != nil) {
			newName = [newName stringByAppendingPathExtension:extension];
		}
	}
	
	
//	NSLog(@"Set extension: %@", self);
	
	// rename the file on disk
	
	NSString *oldPath = [self pathOnDisk];
	NSString *newPath = nil;
  
	if (oldPath) {
		newPath = [oldPath stringByDeletingLastPathComponent];
		newPath = [newPath stringByAppendingPathComponent:newName];		
	} else {
		// fall back to project folder
		newPath = [[[self project] folder] stringByAppendingPathExtension:newName];
	}
	
	
//	NSLog(@"Renaming %@\nto %@", oldPath, newPath);
	
	if (   newPath != nil 
      && oldPath != nil 
      && ![newPath isEqual:oldPath]) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		// If the old file exists, we can move it
		if ([fm fileExistsAtPath:oldPath]) {
      
      // if a file exists at the new path, ask the user if they want to overwrite
      // - if we are just changing the case of the filename, then this check doesn't make sense due to the
      //   case insensitive file system
      if (![newPath isCaseInsensitiveLike:oldPath] && [fm fileExistsAtPath:newPath]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Overwrite?"
                                         defaultButton:@"Overwrite"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@"A file already exists at %@. Do you want to overwrite it? (The file will be moved to the Trash.)", newPath
                          ];
        
        NSInteger result = [alert runModal];
        if (result == NSAlertDefaultReturn) {
          
          NSError *error = nil;
          BOOL success = [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                                      source:[newPath stringByDeletingLastPathComponent]
                                                                 destination:@""
                                                                       files:@[[newPath lastPathComponent]]
                                                                         tag:nil];
          
//          BOOL success = [fm removeItemAtPath:newPath error:&error];
          if (success == NO) {
            [NSApp presentError:error];
            return;
          }
        } else {
          return;
        }
      }

      // move to a tmp file, then to the new file
      NSDateFormatter *formatter = [[NSDateFormatter alloc] initWithDateFormat:@"yyyymmdd_HHMM" allowNaturalLanguage:YES];
      NSString *append = [formatter stringFromDate:[NSDate date]];
      NSString *tmpFile = [oldPath stringByAppendingPathExtension:append];
			BOOL success = [fm moveItemAtPath:oldPath toPath:tmpFile error:&error];
      if (success) {
        BOOL success = [fm moveItemAtPath:tmpFile toPath:newPath error:&error];
        if (success == NO) {
          NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
          [errorDetail setValue:@"Failed to rename file"
                         forKey:NSLocalizedDescriptionKey];
          NSString *errorDescription = [NSString stringWithFormat:@"Failed to move \u201c%@\u201d to \u201c%@\u201d", oldPath, newPath];
          [errorDetail setValue:errorDescription forKey:NSLocalizedRecoverySuggestionErrorKey];
          error = [NSError errorWithDomain:@"TeXnicle" code:0 userInfo:errorDetail];
          [NSApp presentError:error];
          return;
        }
      } else {
        [NSApp presentError:error];
        return;
      }
		}
		
		// set the new filepath
		[self setValue:newPath forKey:@"filepath"];
	}
	
	if (extension) {
		[self setValue:extension forKey:@"extension"];
	}
	
	// now go ahead and rename the item
	[self setPrimitiveValue:newName forKey:@"name"];
	[self didChangeValueForKey:@"name"];
}

- (void) reconfigureDocument
{
//  NSLog(@"Reconfiguring %@", [self name]);
	if (document) {
//    NSLog(@"    already have document...");
    // set the new text to the textstorage
    MHFileReader *fr = [[MHFileReader alloc] init];
    NSStringEncoding encoding = [fr encodingForFileAtPath:[self pathOnDisk]];
		NSString *str = [[NSString alloc] initWithData:[self valueForKey:@"content"]
                                           encoding:encoding];
		NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
		[attStr addAttributes:[NSDictionary currentTypingAttributes] range:NSMakeRange(0, [str length])];
    
    [[document textStorage] beginEditing];
    [[document textStorage] setAttributedString:attStr];
    [[document textStorage] endEditing];
    
    
    // release file reader
    
//		[document release];
	} else {
//    NSLog(@"    create new document");
    document = [[FileDocument alloc] initWithFile:self];
  }
}

- (void) textChanged
{
	// notify anyone interested that there were edits
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:TPFileItemTextStorageChangedNotification object:self userInfo:nil];
}

- (FileDocument*)document
{
	if (!document) {
		document = [[FileDocument alloc] initWithFile:self];
	}
	return document;
}

- (void) willTurnIntoFault
{  
//  NSLog(@"Will fault %@ [%@]", self.name, self.metadata);
}

- (void) didTurnIntoFault
{
  self.mainFileOfProject = nil;
  self.metadata.parent = nil;
  self.metadata = nil;
  
	if (document) {
//		NSLog(@"Clearing document for %@", [self name]);
		document = nil;
	}
  self.content = nil;
}

- (NSString*) extension
{
	return [[self valueForKey:@"filepath"] pathExtension];
}

- (NSString*) shortName
{
	if ([self valueForKey:@"filepath"]) {
		NSString *shortname = [[self valueForKey:@"filepath"] lastPathComponent];
//		NSLog(@"Short name extension %@ for %@", [shortname pathExtension], shortname); 
		if ([[shortname pathExtension] length] > 0) {
			return shortname;
		} else {
			return [shortname stringByDeletingPathExtension];
		}
	}
	NSString *ext = [self valueForKey:@"extension"];
	if (ext != nil) {
		return [[self valueForKey:@"name"] stringByAppendingPathExtension:ext];
	} else {
		return [self valueForKey:@"name"];
	}
}


- (BOOL) isLeaf
{
	return YES;
}


- (BOOL) updateFromTextStorage
{
	return [document commitEdits];
}

// A file has edits if the textstorage string is different from that in content
- (BOOL) hasEdits
{
  BOOL success = NO;
  
  if (![[self valueForKey:@"isText"] boolValue]) {
    return success;
  }
  
  if (_hasEdits) {
//    NSLog(@"We know it has edits %d", _hasEdits);
    return YES;
  }

  if (self.isActive == 0) {
    return _hasEdits;
  }
  
  // otherwise we check  
//  NSLog(@"Checking for edits");
	if ([self document]) {
    NSTextStorage *ts = [[self document] textStorage];
		if (ts) {
      MHFileReader *fr = [[MHFileReader alloc] init];
      NSStringEncoding encoding = [fr encodingForFileAtPath:[self pathOnDisk]];
			NSString *contentStr = [[NSString alloc] initWithData:[self valueForKey:@"content"]
																										encoding:encoding];
			
      
      NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:ts];
      [string unfoldAllInRange:NSMakeRange(0, [string length]) max:100000];
      NSString *textStr = [string unfoldedString];
      
			if ([contentStr length] != [textStr length]) {
//        NSLog(@"File %@ has diffent length", self.name);
        _hasEdits = YES;
				success = YES;
			}
			
			if (![contentStr isEqual:textStr]) {
//        NSLog(@"File %@ has diffent string", self.name);
        _hasEdits = YES;
				success = YES;
			}
      
      // clean up
      
      // release file reader
		}
	}
	
	return success;
}


+ (NSSet *)keyPathsForValuesAffectingHasEdits
{
	return [NSSet setWithObject:@"content"];
}

- (NSString*) contentString
{
	if (!document) {
		document = [[FileDocument alloc] initWithFile:self];		
	}
	
	NSData *data = [self valueForKey:@"content"];
  MHFileReader *fr = [[MHFileReader alloc] init];
  NSStringEncoding encoding = [fr encodingForFileAtPath:[self pathOnDisk]];
	NSString *str = [[NSString alloc] initWithData:data encoding:encoding];
  
	return str;
}

- (NSString*) workingContentString
{
	
	if (!document) {
		document = [[FileDocument alloc] initWithFile:self];		
	}
	
	NSString *textStr = [[[self document] textStorage] string];	
	return textStr;
}

- (BOOL) saveContentsToDisk
{
//	NSLog(@"Saving contents of %@ to disk", [self valueForKey:@"name"]);
	BOOL success = NO;

	if ([self existsOnDisk]) {		
		if ([self updateFromTextStorage]) {
			
//			NSLog(@"Writing %@ to %@", [self valueForKey:@"name"], [self valueForKey:@"pathOnDisk"]);
			// Check the file on disk
			NSFileManager *fm = [NSFileManager defaultManager];
			NSString *filepath = [self valueForKey:@"pathOnDisk"];
			
			if ([fm fileExistsAtPath:filepath]) {
//				NSLog(@"File exists at %@", filepath);
				// get last modified time of the file
				NSError *error = nil;
				NSDictionary *atts = [fm attributesOfItemAtPath:filepath
																									error:&error];				
				if (atts == nil) {
					[NSApp presentError:error];
				}
				NSDate *lastModified = [atts valueForKey:NSFileModificationDate];
				
				NSDate *fileLoaded = [self valueForKey:@"fileLoadDate"];
				
				NSComparisonResult res = [fileLoaded compare:lastModified];
				if (res == NSOrderedAscending) {
					// then the file was modified on disk 
					NSAlert *alert = [NSAlert alertWithMessageText:@"Overwrite changes?"
																					 defaultButton:@"No" 
																				 alternateButton:@"Yes"
																						 otherButton:nil 
															 informativeTextWithFormat:@"The file '%@' was modified on disk by another program. Do you want to overwrite those modifications?", [self valueForKey:@"name"]
														]; 
					
					if ([alert runModal] == NSAlertAlternateReturn) {
						// OK clicked, save file
						success = [self writeContents];
					} else {
						success = NO;
					}
					
				} else {
					// then we are safe to save
					success = [self writeContents];
				}
			} else {
				// write contents to the file
				success = [self writeContents];
			}					
		} // end if update from text storage was successful
		else {
//			NSLog(@"No update from textstorage");
			success = YES;
		}
	} // end if item exists on disk
	else {
//		NSLog(@"Item doesn't exist on disk");
    
    // if there is nothing at that location, we could try to write the file
    
		success = YES;
	}

	return success;
}

- (BOOL) writeContents
{
//	NSLog(@"Writing contents of %@ to disk", [self name]);
	NSString *filepath = [self valueForKey:@"pathOnDisk"];
	NSData *data = [self valueForKey:@"content"];
	if (data) {
    
    MHFileReader *fr = [[MHFileReader alloc] init];
    [fr writeDataToFileAsString:data toURL:[NSURL fileURLWithPath:filepath]];
    
		// update the save time for this file
		[self setValue:[NSDate date] forKey:@"fileLoadDate"];
		_hasEdits = NO;
//		NSLog(@"Done");
	}	
	return YES;
}

- (BOOL) isImage
{
  return [[[self pathOnDisk] pathExtension] isImage];
}

- (Bookmark*)bookmarkForLinenumber:(NSInteger)aLinenumber
{
  for (Bookmark *b in self.bookmarks) {
    if ([b.linenumber integerValue] == aLinenumber) {
      return b;
    }
  }
  return nil;
}

- (NSString*)consolidatedFileContents
{  
  NSString *string = [self workingContentString];
  
  NSUInteger loc = 0;
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
  
  while (loc < [string length]) {
    NSString *word = [string nextWordStartingAtLocation:&loc];
    word = [word stringByTrimmingCharactersInSet:ns];
    if ([word characterAtIndex:0] == '\\') {
      // check file links
      if ([word hasPrefix:@"\\input{"] || [word hasPrefix:@"\\include{"]) {
        NSInteger start = loc-[word length]+1;
        NSInteger end   = start;
        NSString *filePath = [string parseArgumentStartingAt:&end];
        if (filePath != nil && ![filePath isEqualToString:[self projectPath]]) {
          FileEntity *nextFile = [self.project fileWithPath:filePath];
          if (nextFile) {
            NSRange repRange = NSMakeRange(start, end-start+1);
            NSString *repString = [nextFile consolidatedFileContents];
            string = [string stringByReplacingCharactersInRange:repRange withString:repString];
          }
        }
      }
    }
    loc++;    
  }
  
  return string;
}

#pragma mark -
#pragma mark Metadata

- (void) updateMetadata
{
  if (self.metadata) {
    [self.metadata updateMetadata];
  }
}

- (NSArray*) listOfNewCommands
{
  if (self.metadata == nil) {
    return @[];
  }
  
  return [self.metadata listOfNewCommands];
}

- (NSArray*) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  if (self.metadata) {
    return [self.metadata generateSectionsForTypes:templates forceUpdate:force];
  }
  return @[];
}

- (NSString*) text
{
  return [self workingContentString];
}

- (TPFileEntityMetadata*) metadataForFileWithName:(NSString *)file
{
  return [[self.project fileWithPath:file] metadata];
}

@end
