//
//  NSAttributedString+LineNumbers.h
//  TeXnicle
//
//  Created by Martin Hewitson on 5/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (LineNumbers)


- (NSArray*) lineNumbersForTextRange:(NSRange)aRange;
- (NSInteger) indexForLineNumber:(NSInteger)aLinenumber;

@end
