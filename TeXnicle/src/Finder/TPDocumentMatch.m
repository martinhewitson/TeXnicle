//
//  TPDocumentMatch.m
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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

#import "TPDocumentMatch.h"

@implementation TPDocumentMatch

@synthesize parent;
@synthesize match;
@synthesize range;
@synthesize subrange;
@synthesize lineNumber;

+ (TPDocumentMatch*)documentMatchInLine:(NSInteger)aLineNumber withRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString inDocument:(TPResultDocument*)aParent
{
  return [[[TPDocumentMatch alloc] initWithLine:aLineNumber withRange:aRange subrange:(NSRange)aSubrange matchingString:aString inDocument:(TPResultDocument*)aParent] autorelease];
}

- (id)initWithLine:(NSInteger)aLineNumber withRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString inDocument:(TPResultDocument*)aParent
{
  self = [super init];
  if (self) {
    self.parent = aParent;
    self.range = aRange;
    self.subrange = aSubrange;
    self.match = aString;
    self.lineNumber = aLineNumber;
  }
  
  return self;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%@, %@", NSStringFromRange(self.range), self.match];
}

- (NSString*) lineNumberString
{
  return [NSString stringWithFormat:@" %d ", self.lineNumber];
}

- (NSAttributedString*)selectedDisplayString
{
  NSString *lineNumberString = @""; //[self lineNumberString];
  
  NSMutableAttributedString *att = [[[self displayString] mutableCopy] autorelease]; 
  NSRange matchRange = NSMakeRange(self.subrange.location+[lineNumberString length], self.subrange.length);
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor lightGrayColor] range:matchRange];
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [lineNumberString length])];
  return att;
}

- (NSAttributedString*)displayString
{
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:[self.match stringByReplacingOccurrencesOfString:@"\n" withString:@" "]] autorelease]; 
  NSString *lineNumberString = @""; //[self lineNumberString];
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:lineNumberString] autorelease];
  [str addAttribute:NSBackgroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, [str length])];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [str length])];
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor colorWithDeviceRed:240.0/255.0 green:240.0/255.0 blue:180.0/255.0 alpha:1.0] range:self.subrange];
  [str appendAttributedString:att];
  return str;
}

@end
