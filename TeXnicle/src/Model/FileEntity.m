//
//  FileEntity.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "FileEntity.h"
#import "NSString+RelativePath.h"
#import "FileDocument.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "externs.h"
#import "ConsoleController.h"
#import "Bookmark.h"

@implementation FileEntity

@dynamic fileLoadDate;
@dynamic extension;
@dynamic content;
@dynamic isText;
@dynamic bookmarks;
@synthesize document;


- (void) awakeFromInsert
{
//	NSLog(@"Awake from insert.");
	[self setPrimitiveValue:@"none" forKey:@"name"];
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"isText"];
	[self reconfigureDocument];
//	if (!document) {
////		NSLog(@"awakeFromInsert: Created document for %@", [self valueForKey:@"name"]);
//		document = [[FileDocument alloc] initWithFile:self];
//	}
}

- (void) awakeFromFetch
{
	[super awakeFromFetch];
	
	[self reloadFromDisk];
	
	// we should make sure the name is in sync with the filepath
	NSString *newName = [[self filepath] lastPathComponent];
  if (newName) {
    if (![[self name] isEqual:newName]) {
      [self setValue:newName forKey:@"name"];
    }
  }
	
//	if (!document) {
//		NSLog(@"awakeFromFetch: Created document for %@", [self valueForKey:@"name"]);
//		document = [[FileDocument alloc] initWithFile:self];
//	}
}

- (void) reloadFromDisk
{
	// We should load the text from the file
	NSString *filepath = [self pathOnDisk];
	//	NSLog(@"Loading from %@", filepath);
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filepath]) {
		NSError *error = nil;
		NSString *str = [NSString stringWithContentsOfFile:filepath
																							encoding:NSUTF8StringEncoding
																								 error:&error];
		
		// Set the time we load. When we save back to file we can 
		// check if the file was modified after this date and prompt
		// the user to overwrite changes or not.
		[self setPrimitiveValue:[NSDate date] forKey:@"fileLoadDate"];
		
		//NSLog(@"Loaded string %@", str);
		if (!str) {
			str = @"";
		}
		NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
		[self setPrimitiveValue:data forKey:@"content"];
		
	} else {
    [[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"File doesn't exist at %@", filepath]];
	}

	[self reconfigureDocument];
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
		
		if (extension) {
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
	
	if (newPath && oldPath && ![newPath isEqual:oldPath]) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		// If the old file exists, we can rename it
		if ([fm fileExistsAtPath:oldPath]) {
			[fm moveItemAtPath:oldPath toPath:newPath error:&error];
			if (error) {
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Failed to rename file"
											 forKey:NSLocalizedDescriptionKey];
				NSString *errorDescription = [NSString stringWithFormat:@"Failed to move \u201c%@\u201d to \u201c%@\u201d", oldPath, newPath];
				[errorDetail setValue:errorDescription forKey:NSLocalizedRecoverySuggestionErrorKey];
				error = [NSError errorWithDomain:@"TeXnicle" code:0 userInfo:errorDetail];
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
	if (document) {
		[document release];
	}
	//NSLog(@"Configuring document for %@", [self valueForKey:@"name"]);
	document = [[FileDocument alloc] initWithFile:self];
}

- (FileDocument*)document
{
	if (!document) {
		document = [[FileDocument alloc] initWithFile:self];
	}
	return document;
}

- (void)prepareForDeletion
{
	if (document) {
//		NSLog(@"Clearing document for %@", [self name]);
		[document release];
		document = nil;
	}
  self.content = nil;
  self.fileLoadDate = nil;
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
	if (ext) {
		return [[self valueForKey:@"name"] stringByAppendingPathExtension:ext];
	} else {
		return [self valueForKey:@"name"];
	}
}


- (BOOL) isLeaf
{
	return YES;
}


- (NSString*) projectPath
{
	ProjectEntity *project = [self valueForKey:@"project"];
	// try to make the folder on disk		
	NSString *projectRoot = [project valueForKey:@"folder"];
	
	NSString *relativePath = [self valueForKey:@"name"];
	NSManagedObject *parent = [self valueForKey:@"parent"];
	while (parent != nil) {
		relativePath = [[parent valueForKey:@"name"] stringByAppendingPathComponent:relativePath];
		parent = [parent valueForKey:@"parent"];
	}
	
//	NSLog(@"Project root: %@", projectRoot);
//	NSLog(@"Relative path: %@", relativePath);
	
	NSString *folderRoot = [projectRoot stringByAppendingPathComponent:relativePath];
//	NSString *ext = [self valueForKey:@"extension"];
//	if (ext && [ext length]>0) {
//		return [folderRoot stringByAppendingPathExtension:ext];
//	} else {
		return folderRoot;
//	}
}


- (BOOL) updateFromTextStorage
{
	return [document commitEdits];
}

// A file has edits if the textstorage string is different from that in content
- (BOOL) hasEdits
{
	if ([self document]) {
		if ([[self document] textStorage]) {
			NSString *contentStr = [[[NSString alloc] initWithData:[self valueForKey:@"content"]
																										encoding:NSUTF8StringEncoding] autorelease];
			
			NSTextStorage *ts = [[self document] textStorage];
			NSString *textStr = [ts string];
//			NSAttributedString *aa = [ts attributedSubstringFromRange:NSMakeRange(0, [ts length])];
//			NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithAttributedString:aa];
//			NSString *textStr = [aStr unfoldedString];
//			[aStr release];
			if ([contentStr length] != [textStr length]) {
				return YES;
			}
			
			if (![contentStr isEqual:textStr]) {
				return YES;
			}
		}
	}
	
	return NO;
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
	NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
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
				if (error) {
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
		success = YES;
	}

	return success;
}

- (BOOL) writeContents
{
//	NSLog(@"Writing contents of %@ to disk", [self name]);
	NSString *filepath = [self valueForKey:@"pathOnDisk"];
	NSData *data = [self valueForKey:@"content"];
	if (data && [data length]>0) {
		
		NSString *content = [[NSString alloc] initWithData:data
																							encoding:NSUTF8StringEncoding];
		NSError *error = nil;
		//					[content writeToFile:[file valueForKey:@"pathOnDisk"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
		[content writeToURL:[NSURL fileURLWithPath:filepath]
						 atomically:YES
							 encoding:NSUTF8StringEncoding
									error:&error];
		[content release];
		if (error) {
			[NSApp presentError:error];
			return NO;
		}
		
		// update the save time for this file
		[self setValue:[NSDate date] forKey:@"fileLoadDate"];
		
//		NSLog(@"Done");
	}	
	return YES;
}

- (BOOL) isImage
{
  CFStringRef fileExtension = (CFStringRef) [[self pathOnDisk] pathExtension];
  CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
  if (UTTypeConformsTo(fileUTI, kUTTypeImage) 
      || UTTypeConformsTo(fileUTI, kUTTypePDF)
      || UTTypeConformsTo(fileUTI, kUTTypeBMP)
      || UTTypeConformsTo(fileUTI, kUTTypeGIF)
      || UTTypeConformsTo(fileUTI, kUTTypeJPEG)
      || UTTypeConformsTo(fileUTI, kUTTypeJPEG2000)
      || UTTypeConformsTo(fileUTI, kUTTypePNG)
      || UTTypeConformsTo(fileUTI, kUTTypeTIFF)
      ) {
    return YES;
  }
  return NO;
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

@end
