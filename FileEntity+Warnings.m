//
//  FileEntity+Warnings.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  NSString *warningCountString = nil; 
  if ([self.metadata.syntaxErrors count] >= 1000) {
    warningCountString = [NSString stringWithFormat:@" [>%d] ", [self.metadata.syntaxErrors count]];
  } else {
    warningCountString = [NSString stringWithFormat:@" [%d] ", [self.metadata.syntaxErrors count]];
  }
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:warningCountString] autorelease];
  [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [str length])];  
  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
  [att appendAttributedString:str];
  
  // apply paragraph
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  return att;
}


@end
