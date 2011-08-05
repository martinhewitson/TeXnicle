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

+ (TPDocumentMatch*)documentMatchWithRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString inDocument:(TPResultDocument*)aParent
{
  return [[[TPDocumentMatch alloc] initWithRange:aRange subrange:(NSRange)aSubrange matchingString:aString inDocument:(TPResultDocument*)aParent] autorelease];
}

- (id)initWithRange:(NSRange)aRange subrange:(NSRange)aSubrange matchingString:(NSString*)aString inDocument:(TPResultDocument*)aParent
{
  self = [super init];
  if (self) {
    self.parent = aParent;
    self.range = aRange;
    self.subrange = aSubrange;
    self.match = aString;
  }
  
  return self;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%@, %@", NSStringFromRange(self.range), self.match];
}

- (NSAttributedString*)selectedDisplayString
{
  //  NSLog(@"String: %@", self.match);
  //  NSLog(@"String length %d", [self.match length]);
  //  NSLog(@"Subrange %@", NSStringFromRange(self.subrange));
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:self.match] autorelease]; 
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor lightGrayColor] range:self.subrange];
  return att;
}
- (NSAttributedString*)displayString
{
//  NSLog(@"String: %@", self.match);
//  NSLog(@"String length %d", [self.match length]);
//  NSLog(@"Subrange %@", NSStringFromRange(self.subrange));
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:self.match] autorelease]; 
  [att addAttribute:NSBackgroundColorAttributeName value:[NSColor colorWithDeviceRed:240.0/255.0 green:240.0/255.0 blue:180.0/255.0 alpha:1.0] range:self.subrange];
  return att;
}

@end
