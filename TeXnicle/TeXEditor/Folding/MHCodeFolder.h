//
//  MHCodeFolder.h
//  TeXnicle
//
//  Created by Martin Hewitson on 01/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import <Foundation/Foundation.h>

enum {
  MHCodeFolderReverseSearch,
  MHCodeFolderForwardSearch
};

@class MHFoldingTagDescription;

@interface MHCodeFolder : NSObject

@property (strong) MHFoldingTagDescription *tag;
@property (assign) NSInteger startLine;
@property (assign) NSInteger endLine;
@property (assign) NSInteger startIndex;
@property (assign) NSInteger endIndex;
@property (assign) NSInteger lineCount;
@property (assign) BOOL folded;
@property (assign) NSTrackingRectTag startTrackingRect;
@property (assign) NSTrackingRectTag endTrackingRect;
@property (copy) NSString *startRect;
@property (copy) NSString *endRect;
@property (copy) NSString *foldedText;
@property (readonly) BOOL isValid;


+ (MHCodeFolder*) codeFolderWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex startLine:(NSInteger)startLine endLine:(NSInteger)endLine tag:(MHFoldingTagDescription*)aTag;
- (id) initWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex startLine:(NSInteger)startLine endLine:(NSInteger)endLine tag:(MHFoldingTagDescription*)aTag;


+ (MHCodeFolder*) codeFolderStartingAtIndex:(NSInteger)index inFolders:(NSArray*)codeFolders;
+ (MHCodeFolder*) codeFolderEndingAtIndex:(NSInteger)index inFolders:(NSArray*)codeFolders;

- (void) completeFolderWithText:(NSString*)someText forTags:(NSArray*)tags;
- (void) findEndTagInText:(NSString*)someText fromFoldingTags:(NSArray*)tags;
- (void) findStartTagInText:(NSString*)someText fromFoldingTags:(NSArray*)foldingTags;

@end
