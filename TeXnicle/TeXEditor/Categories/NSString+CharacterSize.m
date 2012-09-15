//
//  NSString+CharacterSize.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/12/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSString+CharacterSize.h"
#import "TeXTextView.h"
#import "externs.h"

NSString * const kTestString = @"1234567890abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY1234567890abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY1234567890abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY1234567890abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY1234567890abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY1234567890abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY";


@implementation NSString (CharacterSize)

+ (CGFloat)averageCharacterWidthForCurrentFont
{
	NSFont *font = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:TEDocumentFont]];
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:kTestString attributes:nil];
	[str addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [str length])];
	NSSize strsize = [str size];
	return 1.0*strsize.width/(1.0*[str length]);
}

+ (CGFloat)averageCharacterWidthForFont:(NSFont*)aFont
{
  if (aFont == nil) {
    return [NSString averageCharacterWidthForCurrentFont];
  }
  
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:kTestString
                                                                          attributes:nil];
	[str addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, [str length])];
	NSSize strsize = [str size];
	return 1.0*strsize.width/[str length];
}


@end
