//
//  TPMetadataItem.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPMetadataItem.h"
#import "TPThemeManager.h"

@implementation TPMetadataItem

- (NSString*)sortKey
{
  return @"value";
}

- (NSAttributedString*)selectedDisplayString
{
  return [self stringForDisplayWithColor:[NSColor alternateSelectedControlTextColor]];
}

- (NSAttributedString*)displayString
{
  return [self stringForDisplayWithColor:[NSColor darkGrayColor]];
}

- (NSAttributedString*)stringForDisplayWithColor:(NSColor*)color
{
  NSMutableAttributedString *att = nil;
  
  if ([self.value isKindOfClass:[NSAttributedString class]]) {
    return self.value;
  } else if ([self.value isKindOfClass:[NSString class]]) {
    att = [[NSMutableAttributedString alloc] initWithString:self.value];
  } else {
    att = [[NSMutableAttributedString alloc] initWithString:self.string];
  }
  
  // apply paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  // set font
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  NSFont *font = theme.navigatorFont;
  [att addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [att length])];
  
  return att;
}


@end
