//
//  MHFoldingTag.h
//  TeXEditor
//
//  Created by Martin Hewitson on 07/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHFoldingTagDescription.h"

@interface MHFoldingTag : NSObject {
@private
  BOOL isStartTag;
  MHFoldingTagDescription *tag;
  NSInteger index;
  NSInteger lineNumber;
}

@property (assign) BOOL isStartTag;
@property (retain) MHFoldingTagDescription *tag;
@property (assign) NSInteger index;
@property (assign) NSInteger lineNumber;


- (id) initWithStartTag:(MHFoldingTagDescription*)aTag index:(NSInteger)anIndex lineNumber:(NSInteger)aLineNumber isStartTag:(BOOL)result;
+ (MHFoldingTag*) tagWithStartTag:(MHFoldingTagDescription*)aTag index:(NSInteger)anIndex lineNumber:(NSInteger)aLineNumber isStartTag:(BOOL)result;

@end
