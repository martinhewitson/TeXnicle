//
//  TPMisspelledWord.m
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPMisspelledWord.h"

@implementation TPMisspelledWord

@synthesize word;
@synthesize corrections;
@synthesize range;
@synthesize parent;

+ (TPMisspelledWord*) wordWithWord:(NSString*)aWord corrections:(NSArray*)correctionList range:(NSRange)aRange parent:(TPSpellCheckedFile*)aParent
{
  return [[[TPMisspelledWord alloc] initWithWord:aWord corrections:correctionList range:aRange parent:aParent] autorelease];
}

- (id) initWithWord:(NSString*)aWord corrections:(NSArray*)correctionList range:(NSRange)aRange parent:(TPSpellCheckedFile*)aParent
{
  self = [super init];
  if (self) {
    self.word = aWord;
    self.corrections = correctionList;
    self.range = aRange;
    self.parent = aParent;
  }
  return self;
}

- (void) dealloc
{
  self.corrections = nil;
  [super dealloc];
}

- (NSAttributedString*)selectedDisplayString
{
  return [self stringForDisplayWithColor:[NSColor alternateSelectedControlTextColor] detailsColor:[NSColor alternateSelectedControlTextColor]];
}


- (NSAttributedString*)displayString
{
  return [self stringForDisplayWithColor:[NSColor redColor] detailsColor:[NSColor darkGrayColor]];
}

- (NSAttributedString*)stringForDisplayWithColor:(NSColor*)color detailsColor:(NSColor*)detailsColor
{
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  
  NSString *text = self.word;
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  [att addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [att length])];  
  
  if ([self.corrections count]>0) {
    NSString *correctionString = [NSString stringWithFormat:@" ➜ [%@]", [self.corrections componentsJoinedByString:@", "]];
    if ([correctionString length] > 100) {
      correctionString = [NSString stringWithFormat:@"%@ ...", [correctionString substringToIndex:100]];
    }
    NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:correctionString] autorelease];
    [str addAttribute:NSForegroundColorAttributeName value:detailsColor range:NSMakeRange(0, [str length])];  
    [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
    [att appendAttributedString:str];
  }  
  
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  return att;
}


@end
