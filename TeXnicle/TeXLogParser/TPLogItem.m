//
//  TPLogItem.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPLogItem.h"

@implementation TPLogItem

- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType message:(NSString*)aMessage line:(NSInteger)number matchedPhrase:(NSString *)aPhrase
{
  self = [self initWithFileName:aFile type:itemType message:aMessage line:number];
  if (self) {
    self.matchedPhrase = aPhrase;
  }
  return self;
}

- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType message:(NSString*)aMessage line:(NSInteger)number
{
  self = [self initWithFileName:aFile type:itemType message:aMessage];
  if (self) {
    self.linenumber = number;
  }
  return self;
}

- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType message:(NSString*)aMessage
{
  self = [self initWithFileName:aFile type:itemType];
  if (self) {
    self.message = aMessage;
  }
  return self;
}


- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType
{
  self = [self initWithFileName:aFile];
  if (self) {
    self.type = itemType;
  }
  
  return self;
}


- (id) initWithFileName:(NSString*)aFile
{
  self = [super init];
  if (self) {
    self.file = [[aFile lastPathComponent] stringByStandardizingPath];
    self.filepath = aFile;
  }
  
  return self;
}

- (id) init
{
  self = [super init];
  if (self) {
    self.file = nil;
    self.message = nil;
    self.matchedPhrase = nil;
    self.type = TPLogUnknown;
    self.linenumber = NSNotFound;
  }
  return self;
}

- (NSString*)typeName
{
  if (self.type == TPLogUnknown) {
    return @"Unknown";
  } else if (self.type == TPLogInfo) {
    return @"Info";
  } else if (self.type == TPLogWarning) {
    return @"Warning";
  } else if (self.type == TPLogError) {
    return @"Error";
  } else {
    return @"";
  }
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
  
  NSString *lineStr = @"-";
  if (self.linenumber != NSNotFound) {
    lineStr = [NSString stringWithFormat:@"%ld", self.linenumber];
  }
  
  // line number
  NSMutableAttributedString *lineNumber = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] ", lineStr]];
  [lineNumber addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [lineNumber length])];
  [str appendAttributedString:lineNumber];
  
  // message
  NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:self.message];
  [messageString addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0, [messageString length])];
  [str appendAttributedString:messageString];

  // phrase
  NSMutableAttributedString *phraseString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" [%@]", self.matchedPhrase]];
  if (self.type == TPLogInfo) {
    [phraseString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, [phraseString length])];
  } else if (self.type == TPLogWarning) {
    [phraseString addAttribute:NSForegroundColorAttributeName value:[NSColor yellowColor] range:NSMakeRange(0, [phraseString length])];
  } else if (self.type == TPLogError) {
    [phraseString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [phraseString length])];
  }
  [str appendAttributedString:phraseString];
  
  
  // apply paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];
  [str addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [str length])];
  
  return str;
}

- (NSString*)description
{
  NSString *lineStr = @"-";
  if (self.linenumber != NSNotFound) {
    lineStr = [NSString stringWithFormat:@"%ld", self.linenumber];
  }
  
  NSString *desc = [NSString stringWithFormat:@"[%@][%@] %@: %@ (%@)", self.typeName, lineStr, self.file, self.message, self.matchedPhrase];
      
  return desc;
}

@end
