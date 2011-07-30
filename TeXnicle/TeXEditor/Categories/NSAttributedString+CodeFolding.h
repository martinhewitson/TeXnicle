//
//  NSAttributedString+CodeFolding.h
//  TeXEditor
//
//  Created by Martin Hewitson on 16/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSAttributedString (CodeFolding)

- (NSTextAttachment*)firstAttachment;
+ (NSInteger)lineCountForLine:(NSAttributedString*)aLine;

@end
