//
//  TPMisspelledWord.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  
  NSString *text = self.word;
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  [att addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [att length])];  
  
  if ([self.corrections count]>0) {
    NSString *correctionString = [NSString stringWithFormat:@" ➜ [%@]", [self.corrections componentsJoinedByString:@", "]];
    if ([correctionString length] > 100) {
      correctionString = [NSString stringWithFormat:@"%@ ...", [correctionString substringToIndex:100]];
    }
    NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:correctionString] autorelease];
    [str addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [str length])];  
    [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
    [att appendAttributedString:str];
  }  
  
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  return att;
}


- (NSAttributedString*)displayString
{
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  
  NSString *text = self.word;
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  [att addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [att length])];  
  
  if ([self.corrections count]>0) {
    NSString *correctionString = [NSString stringWithFormat:@" ➜ [%@]", [self.corrections componentsJoinedByString:@", "]];
    if ([correctionString length] > 100) {
      correctionString = [NSString stringWithFormat:@"%@ ...", [correctionString substringToIndex:100]];
    }
    NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:correctionString] autorelease];
    [str addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [str length])];  
    [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
    [att appendAttributedString:str];
  }  
  
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  return att;
}


@end
