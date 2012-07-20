//
//  FileEntity+Warnings.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
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

#import "FileEntity+Warnings.h"

@implementation FileEntity (Warnings)

- (NSAttributedString*)selectedDisplayString
{
  return [self stringForDisplayWithColor:[NSColor alternateSelectedControlTextColor] detailsColor:[NSColor alternateSelectedControlTextColor]];
}

- (NSAttributedString*)displayString
{
  return [self stringForDisplayWithColor:[NSColor colorWithDeviceRed:220.0/255.0 green:190.0/255.0 blue:100.0/255.0 alpha:1.0] detailsColor:[NSColor lightGrayColor]];
}

- (NSAttributedString*)stringForDisplayWithColor:(NSColor*)color detailsColor:(NSColor*)detailsColor
{
  
  
  NSString *text = [self name];
  
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:text]; 
  
  NSString *warningCountString = nil; 
  if ([self.metadata.syntaxErrors count] >= 1000) {
    warningCountString = [NSString stringWithFormat:@" [>%d] ", [self.metadata.syntaxErrors count]];
  } else {
    warningCountString = [NSString stringWithFormat:@" [%d] ", [self.metadata.syntaxErrors count]];
  }
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:warningCountString];
  [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [str length])];  
  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
  [att appendAttributedString:str];
  [str release];
  
  // apply paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  [ps release];
  
  return [att autorelease];
}


@end
