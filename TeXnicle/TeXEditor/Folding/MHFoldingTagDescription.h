//
//  MHFoldingTag.h
//  TeXEditor
//
//  Created by Martin Hewitson on 01/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  MHFoldingTagStartMatched,
  MHFoldingTagEndMatched
};

@interface MHFoldingTagDescription : NSObject {
@private
  NSString *startTag;
  NSString *endTag;
  BOOL hasFollowingArgument;
  NSInteger index;
}

@property (assign) NSInteger index;
@property (retain) NSString *startTag;
@property (retain) NSString *endTag;
@property (assign) BOOL hasFollowingArgument;

+ (MHFoldingTagDescription*) deepCopyOfTag:(MHFoldingTagDescription*)aTag;
- (id) initWithStartTag:(NSString*)aStartTag endTag:(NSString*)anEndTag followingArgument:(BOOL)hasArgument;
+ (MHFoldingTagDescription*) foldingTagWithStartTag:(NSString*)aStartTag endTag:(NSString*)anEndTag followingArgument:(BOOL)hasArgument;
+ (MHFoldingTagDescription*) foldingTagInLine:(NSString*)line atIndex:(NSInteger*)index fromTags:(NSArray*)tags matched:(NSInteger*)matchingTag;


@end
