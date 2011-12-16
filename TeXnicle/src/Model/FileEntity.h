//
//  FileEntity.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectItemEntity.h"

@class FileDocument;
@class Bookmark;

@interface FileEntity : ProjectItemEntity {

	FileDocument *document;
	BOOL _hasEdits;
  NSInteger isActive;
}

@property (assign) NSSet *bookmarks;
@property (retain) NSDate *fileLoadDate;
@property (copy) NSString *extension;
@property (retain) NSData *content;
@property (assign) NSNumber *isText;
@property (readonly) BOOL isImage;
@property (readonly) FileDocument *document;

@property (assign) NSInteger isActive;

- (void)increaseActiveCount;
- (void)decreaseActiveCount;

- (Bookmark*)bookmarkForLinenumber:(NSInteger)aLinenumber;

- (NSString*) contentString;
- (NSString*) workingContentString;
- (BOOL) updateFromTextStorage;
- (void) reconfigureDocument;
- (void)prepareForDeletion;

- (void) reloadFromDisk;
- (void) reloadFromDiskWithEncoding:(NSString*)encoding;
- (BOOL) saveContentsToDisk;
- (BOOL) writeContents;

@end
