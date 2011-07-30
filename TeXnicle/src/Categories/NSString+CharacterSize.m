//
//  NSString+CharacterSize.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/12/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "NSString+CharacterSize.h"
#import "externs.h"

@implementation NSString (CharacterSize)

+ (CGFloat)averageCharacterWidthForCurrentFont
{
	NSFont *font = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:TEDocumentFont]] retain];		
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:@"1234567890abcdefghijklmnopqrstuvwxzy" attributes:nil] autorelease];
	[str addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [str length])];
	NSSize strsize = [str size];
	return 1.0*strsize.width/[str length];
}


@end
