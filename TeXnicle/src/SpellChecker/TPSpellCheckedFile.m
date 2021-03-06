//
//  TPSpellCheckedFile.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
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

#import "TPSpellCheckedFile.h"
#import "TPMisspelledWord.h"
#import "TPThemeManager.h"

@implementation TPSpellCheckedFile

- (id) initWithFile:(id)aFile
{
  self = [super init];
  if (self) {
    self.file = aFile;
    self.needsUpdate = NO;
    self.words = @[];
  }
  
  return self;
}

- (void) dealloc
{
  self.file = nil;
}


- (NSAttributedString*)selectedDisplayString
{
  return [self stringForDisplayWithColor:[NSColor alternateSelectedControlTextColor] detailsColor:[NSColor alternateSelectedControlTextColor]];
}

- (NSAttributedString*)displayString
{
  return [self stringForDisplayWithColor:[NSColor redColor] detailsColor:[NSColor lightGrayColor]];
}

- (NSAttributedString*)stringForDisplayWithColor:(NSColor*)color detailsColor:(NSColor*)detailsColor
{
  
  
  NSString *filename = nil;
  if ([self.file isKindOfClass:[FileEntity class]]) {
    filename = [self.file name];
  } else {
    filename = [self.file lastPathComponent];
  }
  
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:filename]; 
  
  NSString *wordCountString = nil; 
  if ([self.words count] >= 1000) {
    wordCountString = [NSString stringWithFormat:@" [>%lu] ", [self.words count]];
  } else {
    wordCountString = [NSString stringWithFormat:@" [%lu] ", [self.words count]];
  }
  
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:wordCountString];
  [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [str length])];  
  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
  [att appendAttributedString:str];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
//  NSString *updateString = [NSString stringWithFormat:@"(updated: %@)", [formatter stringFromDate:self.lastCheck]];
//  str = [[NSMutableAttributedString alloc] initWithString:updateString];
//  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
//  [str addAttribute:NSForegroundColorAttributeName value:detailsColor range:NSMakeRange(0, [str length])];
//  [att appendAttributedString:str];
  
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


- (void) updateWithWords:(NSArray*)anArray
{
  if (anArray) {
    self.words = [NSArray arrayWithArray:anArray];
  }
  self.lastCheck = [NSDate date];
  self.needsUpdate = NO;
}


@end
