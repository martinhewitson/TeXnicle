//
//  FileEntity.h
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import "ProjectItemEntity.h"
#import "TPFileEntityMetadata.h"

@class FileDocument;
@class Bookmark;

@interface FileEntity : ProjectItemEntity <TPFileEntityMetadataDelegate> {

	FileDocument *document;
	BOOL _hasEdits;
  NSInteger isActive;
  
  TPFileEntityMetadata *metadata;
}

// core data properties
@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSString * cursor;
@property (nonatomic, retain) NSString * extension;
@property (nonatomic, retain) NSDate * fileLoadDate;
@property (nonatomic, retain) NSNumber * isText;
@property (nonatomic, retain) NSDate * lastEditDate;
@property (nonatomic, retain) NSString * visibleRect;
@property (nonatomic, retain) NSNumber * wasOpen;
@property (nonatomic, retain) NSSet *bookmarks;
@property (nonatomic, retain) ProjectEntity *mainFileOfProject;

// other properties
@property (readonly) BOOL isImage;
@property (readonly) FileDocument *document;
@property (readonly) NSString *consolidatedFileContents;
@property (retain) TPFileEntityMetadata *metadata;
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

- (void) textChanged;

#pragma mark -
#pragma mark Metadata

- (NSArray*) listOfNewCommands;
- (void) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force;

@end
