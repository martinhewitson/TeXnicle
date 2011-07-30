//
//  MHLineNumber.h
//  TeXEditor
//
//  Created by Martin Hewitson on 03/04/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MHLineNumber : NSObject {
@private
  NSUInteger number;
  NSUInteger index;
  NSRange range;
}

@property (assign) NSUInteger number;
@property (assign) NSUInteger index;
@property (assign) NSRange range;

+ (MHLineNumber*) lineNumberWithValue:(NSUInteger)lineNumber index:(NSUInteger)anIndex range:(NSRange)aRange;
- (id) initWithLineNumberWithValue:(NSUInteger)lineNumber index:(NSUInteger)anIndex range:(NSRange)aRange;

@end
