//
//  TPDocumentMatch.h
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPDocumentMatch : NSObject {
@private
  NSRange range;
  NSRange subrange;
  NSString *match;
  
}

@property (assign) NSRange range;
@property (assign) NSRange subrange;
@property (copy) NSString *match;
@property (readonly) NSAttributedString *displayString;

- (id)initWithRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString;
+ (TPDocumentMatch*)documentMatchWithRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString
;

@end
