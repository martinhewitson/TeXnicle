//
//  TPSyntaxError.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSyntaxError : NSObject {
@private
  NSNumber *line;
  NSString* message;
}

@property (retain) NSNumber *line;
@property (copy) NSString* message;


+ (id) errorWithMessageLine:(NSString*)aLine;
- (id) initWithMessageLine:(NSString*)aLine;
- (void) parseMessageLine:(NSString*)aLine;
- (NSAttributedString*)attributedString;

@end
