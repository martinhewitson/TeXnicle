//
//  TPLogFileItem.m
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPLogFileItem.h"
#import "TPLogItem.h"
#import "NSArray+LogParser.h"

@implementation TPLogFileItem

- (id) initWithLogItem:(TPLogItem*)anItem
{
  self = [super init];
  if (self) {
    self.filename = anItem.file;
    self.fullpath = anItem.filepath;
    self.items = [NSMutableArray array];
    [self addLogItem:anItem];
  }
  return self;
}

- (void) addLogItem:(TPLogItem*)anItem
{
  BOOL exists = NO;
  for (TPLogItem *item in self.items) {
    if ([item.line isEqualToString:anItem.line] == YES) {
      exists = YES;
      break;
    }
  }
  
  if (exists == NO) {
    [self.items addObject:anItem];
    anItem.parent = self;
  }
}

- (NSArray*)infos
{
  return [self.items infoItems];
}

- (NSArray*)warnings
{
  return [self.items warningItems];
}

- (NSArray*)errors
{
  return [self.items errorItems];
}

- (NSAttributedString*)selectedAttributedString
{
  return [self attributedStringWithColor:[NSColor alternateSelectedControlTextColor]];
}

- (NSAttributedString*)attributedString
{
  return [self attributedStringWithColor:[NSColor blackColor]];
}


- (NSAttributedString*)attributedStringWithColor:(NSColor*)aColor
{
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@""];
  
  NSMutableAttributedString *comma = [[NSMutableAttributedString alloc] initWithString:@","];
  [comma addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0,1)];
  
  NSMutableAttributedString *closeBracket = [[NSMutableAttributedString alloc] initWithString:@"]"];
  [closeBracket addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0,1)];
  
  // filename
  NSMutableAttributedString *fileStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   [", self.filename]];
  [fileStr addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0, [fileStr length])];
  [str appendAttributedString:fileStr];
    
  // (i, w, e)
  NSInteger infoCount = [[self.items infoItems] count];
  NSInteger warningCount = [[self.items warningItems] count];
  NSInteger errorCount = [[self.items errorItems] count];
  
  NSMutableAttributedString *infoStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", infoCount]];
  [infoStr addAttribute:NSForegroundColorAttributeName value:[TPLogItem infoColor] range:NSMakeRange(0, [infoStr length])];
  
  NSMutableAttributedString *warnStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", warningCount]];
  [warnStr addAttribute:NSForegroundColorAttributeName value:[TPLogItem warningColor] range:NSMakeRange(0, [warnStr length])];

  NSMutableAttributedString *errStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", errorCount]];
  [errStr addAttribute:NSForegroundColorAttributeName value:[TPLogItem errorColor] range:NSMakeRange(0, [errStr length])];
  
  [str appendAttributedString:infoStr];
  [str appendAttributedString:comma];
  [str appendAttributedString:warnStr];
  [str appendAttributedString:comma];
  [str appendAttributedString:errStr];
  [str appendAttributedString:closeBracket];
  
  // apply paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];
  [str addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [str length])];
  
  return str;
}


- (NSString*)description
{
  NSString *str = [NSString stringWithFormat:@"\r[%@]\r", self.filename];
  for (TPLogItem *item in self.items) {
    str = [str stringByAppendingFormat:@"\t\t%@\r", item];
  }
  return str;
}





@end
