//
//  TPDocumentMatch.m
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
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
  NSString *lineNumberString = [self lineNumberString];
  
  NSMutableAttributedString *att = [[self displayString] mutableCopy]; 
  NSRange matchRange = NSMakeRange(self.subrange.location+[lineNumberString length], self.subrange.length);
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor lightGrayColor] range:matchRange];
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [lineNumberString length])];
  return att;
}

- (NSAttributedString*)displayString
{
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:[self.match stringByReplacingOccurrencesOfString:@"\n" withString:@" "]] autorelease]; 
  NSString *lineNumberString = [self lineNumberString];
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:lineNumberString] autorelease];
  [str addAttribute:NSBackgroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, [str length])];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [str length])];
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor colorWithDeviceRed:240.0/255.0 green:240.0/255.0 blue:180.0/255.0 alpha:1.0] range:self.subrange];
  [str appendAttributedString:att];
  return str;
}

@end
