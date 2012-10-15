//
//  NSString+Reformatting_Private.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Reformatting_Private)

// returns the name of the command (including the \) for the command starting at the given index
- (NSString*) commandNameStartingAtIndex:(NSInteger)index;

// determine if the line containing 'index' is empty
- (BOOL) lineIsEmptyAtIndex:(NSInteger)index;

// determine if the line containing 'location' is a commented line
- (BOOL) lineIsCommentedBeforeIndex:(NSInteger)location;

// get the start index for reformatting
- (NSInteger) startIndexForReformattingFromIndex:(NSInteger)cursorLocation;

// get the end index for reformatting
- (NSInteger) endIndexForReformattingFromIndex:(NSInteger)cursorLocation;


@end
