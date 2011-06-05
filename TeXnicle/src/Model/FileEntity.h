//
//  FileEntity.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/1/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectItemEntity.h"

@class FileDocument;

@interface FileEntity : ProjectItemEntity {

	FileDocument *document;
	
}

@property (assign) NSDate *fileLoadDate;
@property (assign) NSString *extension;
@property (assign) NSData *content;
@property (assign) BOOL isText;
@property (readonly) FileDocument *document;

- (NSString*) contentString;
- (NSString*) workingContentString;
- (BOOL) updateFromTextStorage;
- (void) reconfigureDocument;
- (void)prepareForDeletion;

- (void) reloadFromDisk;
- (BOOL) saveContentsToDisk;
- (BOOL) writeContents;

@end
