//
//  TPWarningSet.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPWarningSet.h"
#import "FileEntity.h"
#import "TPSyntaxError.h"

@implementation TPWarningSet

@synthesize file;
@synthesize errors;

- (id) initWithFile:(FileEntity*)aFile errors:(NSArray *)someErrors
{
  self = [super init];
  if (self) {
    self.file = aFile;
    NSMutableArray *newErrors = [NSMutableArray array];
    for (TPSyntaxError *error in someErrors) {
      TPSyntaxError *copyError = [TPSyntaxError errorWithMessage:error.message line:error.line];
      [newErrors addObject:copyError];
    }
    self.errors = [NSArray arrayWithArray:newErrors];
  }
  return self;
}

- (void) dealloc
{
  self.errors = nil;
  [super dealloc];
}

- (NSString*) name
{
  return [self.file valueForKey:@"name"];
}

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
  NSString *text = nil;
  if ([self.file isKindOfClass:[FileEntity class]]) {
    text = [self.file valueForKey:@"name"];
  } else {
    text = [self.file lastPathComponent];
  }
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  NSString *warningCountString = nil; 
  if ([self.errors count] >= 1000) {
    warningCountString = [NSString stringWithFormat:@" [>%d] ", [self.errors count]];
  } else {
    warningCountString = [NSString stringWithFormat:@" [%d] ", [self.errors count]];
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
