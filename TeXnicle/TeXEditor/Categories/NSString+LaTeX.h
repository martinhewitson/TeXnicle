//
//  NSString+LaTeX.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (LaTeX) 

- (NSArray*) referenceLabels;
- (NSArray*) citations;
+ (NSString *)stringWithControlsFilteredForString:(NSString *)str ;
- (NSString *)nextWordStartingAtLocation:(NSUInteger*)loc;
- (NSString*)argument;
- (BOOL)isInArgumentAtIndex:(NSInteger)anIndex;
- (BOOL)isCommentLineBeforeIndex:(NSInteger)anIndex;
- (BOOL)isCommandBeforeIndex:(NSInteger)anIndex;

@end
