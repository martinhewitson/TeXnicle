//
//  MHCodeFolder.h
//  TeXEditor
//
//  Created by Martin Hewitson on 01/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  MHCodeFolderReverseSearch,
  MHCodeFolderForwardSearch
};

@class MHFoldingTagDescription;

@interface MHCodeFolder : NSObject {
@private

  BOOL folded;
  NSInteger startLine;
  NSInteger endLine;
  NSInteger startIndex;
  NSInteger endIndex;
  NSInteger lineCount;
  NSString *foldedText;
  NSString *startRect;
  NSString *endRect;
  NSTrackingRectTag startTrackingRect;
  NSTrackingRectTag endTrackingRect;
  MHFoldingTagDescription *tag;
}

@property (retain) MHFoldingTagDescription *tag;
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
