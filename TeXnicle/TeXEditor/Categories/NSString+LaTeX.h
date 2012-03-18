//
//  NSString+LaTeX.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (LaTeX) 

- (NSInteger) beginsWithElementInArray:(NSArray*)terms;
- (NSArray*) referenceLabels;
- (NSArray*) citations;
- (NSArray*) citationsFromBibliographyIncludedFromPath:(NSString*)sourceFile;
+ (NSString *)stringWithControlsFilteredForString:(NSString *)str ;
- (NSString *)nextWordStartingAtLocation:(NSUInteger*)loc;
- (NSString*)argument;
- (NSString*)parseArgumentStartingAt:(NSInteger*)loc;
- (BOOL)isInArgumentAtIndex:(NSInteger)anIndex;
- (BOOL)isCommentLineBeforeIndex:(NSInteger)anIndex commentChar:(NSString*)commChar;
- (BOOL)isCommandBeforeIndex:(NSInteger)anIndex;
- (NSString*)texString;

@end
