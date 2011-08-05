//
//  TPDocumentMatch.h
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPResultDocument;

@interface TPDocumentMatch : NSObject {
@private
  NSRange range;
  NSRange subrange;
  NSString *match;
  NSInteger lineNumber;
  TPResultDocument *parent;
}

@property (assign) NSInteger lineNumber;
@property (assign) TPResultDocument *parent;
@property (assign) NSRange range;
@property (assign) NSRange subrange;
@property (copy) NSString *match;
@property (readonly) NSAttributedString *displayString;
@property (readonly) NSAttributedString *selectedDisplayString;

- (id)initWithLine:(NSInteger)aLineNumber withRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString inDocument:(TPResultDocument*)aParent;
+ (TPDocumentMatch*)documentMatchInLine:(NSInteger)aLineNumber withRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString inDocument:(TPResultDocument*)aParent;
- (NSString*) lineNumberString;

@end
