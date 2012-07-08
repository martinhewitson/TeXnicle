//
//  TPSpellCheckedFile.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSpellCheckedFile.h"

@implementation TPSpellCheckedFile

@synthesize file;
@synthesize lastCheck;
@synthesize words;
@synthesize needsUpdate;

- (id) initWithFile:(FileEntity*)aFile
{
  self = [super init];
  if (self) {
    self.file = aFile;
    self.needsUpdate = NO;
  }
  
  return self;
}

- (void) dealloc
{
  self.file = nil;
  self.words = nil;
  self.lastCheck = nil;
  [super dealloc];
}


//- (NSString*)displayString
//{
//  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
//  [formatter setDateStyle:NSDateFormatterNoStyle];
//  [formatter setTimeStyle:NSDateFormatterShortStyle];  
//  return [NSString stringWithFormat:@"%@ | %d (last checked %@)", [self.file name], [self.words count], [formatter stringFromDate:self.lastCheck]];
//}

- (NSAttributedString*)selectedDisplayString
{
  
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  
  NSString *text = [self.file name];
  if ([text length]==0) {
    text = @"<blank>";
  }
  if ([text length]>50) {
    text = [[text substringToIndex:50] stringByAppendingString:@"..."];
  }
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  NSString *wordCountString = [NSString stringWithFormat:@" [%d] ", [self.words count]];
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:wordCountString] autorelease];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [str length])];  
  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
  [att appendAttributedString:str];
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];  
  NSString *updateString = [NSString stringWithFormat:@"(updated: %@)", [formatter stringFromDate:self.lastCheck]];
  str = [[[NSMutableAttributedString alloc] initWithString:updateString] autorelease];
  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [str length])];
  [att appendAttributedString:str];
  
  // apply paragraph
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  return att;
}

- (NSAttributedString*)displayString
{
  
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  
  NSString *text = [self.file name];
  if ([text length]==0) {
    text = @"<blank>";
  }
  if ([text length]>50) {
    text = [[text substringToIndex:50] stringByAppendingString:@"..."];
  }
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  NSString *wordCountString = [NSString stringWithFormat:@" [%d] ", [self.words count]];
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:wordCountString] autorelease];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [str length])];  
  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
  [att appendAttributedString:str];
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];  
  NSString *updateString = [NSString stringWithFormat:@"(updated: %@)", [formatter stringFromDate:self.lastCheck]];
  str = [[[NSMutableAttributedString alloc] initWithString:updateString] autorelease];
  [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:NSMakeRange(0, [str length])];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [str length])];
  [att appendAttributedString:str];
  
  // apply paragraph
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  return att;
}


@end
