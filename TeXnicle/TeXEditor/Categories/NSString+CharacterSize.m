//
//  NSString+CharacterSize.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/12/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "NSString+CharacterSize.h"
#import "TeXTextView.h"

@implementation NSString (CharacterSize)

+ (CGFloat)averageCharacterWidthForFont:(NSFont*)aFont
{
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:@"1234567890abcdefghijklmnopqrstuvwxzy" attributes:nil] autorelease];
	[str addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, [str length])];
	NSSize strsize = [str size];
	return 1.0*strsize.width/[str length];
}


@end
