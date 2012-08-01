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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
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
@property (nonatomic, strong) NSData * content;
@property (nonatomic, copy) NSString * cursor;
@property (nonatomic, copy) NSString * extension;
@property (nonatomic, strong) NSDate * fileLoadDate;
@property (nonatomic, strong) NSNumber * isText;
@property (nonatomic, strong) NSDate * lastEditDate;
@property (nonatomic, copy) NSString * visibleRect;
@property (nonatomic, strong) NSNumber * wasOpen;
@property (nonatomic, strong) NSSet *bookmarks;
@property (nonatomic, unsafe_unretained) ProjectEntity *mainFileOfProject;

// other properties
@property (readonly) BOOL isImage;
@property (readonly) FileDocument *document;
@property (unsafe_unretained, readonly) NSString *consolidatedFileContents;
@property (strong) TPFileEntityMetadata *metadata;
@property (assign) NSInteger isActive;

- (void)increaseActiveCount;
- (void)decreaseActiveCount;

- (Bookmark*)bookmarkForLinenumber:(NSInteger)aLinenumber;

- (NSString*) contentString;
- (NSString*) workingContentString;
- (BOOL) updateFromTextStorage;
- (void) reconfigureDocument;

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
