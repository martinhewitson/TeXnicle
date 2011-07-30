//
//  NSString+CharacterSize.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/12/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (CharacterSize)

+ (CGFloat)averageCharacterWidthForFont:(NSFont*)aFont;

@end
