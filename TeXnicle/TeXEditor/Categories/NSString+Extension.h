//
//  NSString+Extension.h
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Extension)

- (NSInteger) indexOfFirstMatch:(NSString*)tag withExceptions:(NSArray*)exceptionList;
- (NSInteger) indexOfFirstMatch:(NSString*)tag;
- (BOOL) containsCommentCharBeforeIndex:(NSInteger)anIndex;

@end
