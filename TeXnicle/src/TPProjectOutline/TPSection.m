//
//  TPSection.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSection.h"
#import "TPSectionTemplate.h"
#import "FileEntity.h"

@implementation TPSection

@synthesize file;
@synthesize parent;
@synthesize subsections;
@synthesize startIndex;
@synthesize type;
@synthesize name;

+ (id) sectionWithParent:(TPSection*)aParent start:(NSUInteger)index inFile:(id)aFile type:(TPSectionTemplate*)aType name:(NSString*)aName
{
  return [[[TPSection alloc] initWithParent:aParent start:index inFile:aFile type:aType name:aName] autorelease];
}

- (BOOL)matches:(id)object
{
//  NSLog(@"Checking %@ against %@", self, object);
  
  if ([object isKindOfClass:[TPSection class]] == NO) {
    return NO;
  }
  TPSection *s = (TPSection*)object;
  
  if (self.startIndex != s.startIndex) {
    return NO;
  }
  
  if ([self.file isKindOfClass:[FileEntity class]]) {
    if (self.file != s.file) {
      return NO;
    }
  } else {
    return [self.file isEqualToString:s.file];
  }
  
  if (self.type != s.type) {
    return NO;
  }
  
  if ([self.name isEqualTo:s.name] == NO) {
    return NO;
  }
  
  return YES;
}

- (id) initWithParent:(TPSection*)aParent start:(NSUInteger)index inFile:(id)aFile type:(TPSectionTemplate*)aType name:(NSString*)aName
{
  self = [super init];
  if (self != nil) {
    self.parent = aParent;
    self.startIndex = index;
    self.file = aFile;
    self.type = aType;
    self.name = aName;
  }
  return self;
}

- (NSString*)filename
{
  if ([self.file isKindOfClass:[FileEntity class]]) {
    return [self.file valueForKey:@"name"];
  }
  return [self.file lastPathComponent];
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"{%@, %@, %@, %@}", self.parent.name, [self filename], self.type.tag, self.name];
}

- (NSAttributedString*)selectedDisplayName
{
  return [self textForDisplayWithColor:[NSColor alternateSelectedControlTextColor] details:NO];
}

- (NSAttributedString*)displayName
{
  return [self textForDisplayWithColor:self.type.color details:NO];
}

- (NSAttributedString*)selectedDisplayNameWithDetails
{
  return [self textForDisplayWithColor:[NSColor alternateSelectedControlTextColor] details:YES];
}

- (NSAttributedString*)displayNameWithDetails
{
  return [self textForDisplayWithColor:self.type.color details:YES];
}


- (NSAttributedString*)textForDisplayWithColor:(NSColor*)color details:(BOOL)showDetails
{
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  
  NSString *text = [[self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  if ([text length]==0) {
    text = @"<blank>";
  }
  if ([text length]>50) {
    text = [[text substringToIndex:50] stringByAppendingString:@"..."];
  }
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  [att addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [att length])];
  
  if (showDetails) {
    // type, file
    [att appendAttributedString:[[[NSAttributedString alloc] initWithString:@"  "] autorelease]];
    NSString *typeFileStr = [NSString stringWithFormat:@"(%@, %@)", self.type.name, [self filename]];
    NSMutableAttributedString *typeStr = [[[NSMutableAttributedString alloc] initWithString:typeFileStr] autorelease]; 
    [typeStr addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [typeStr length])];
    [typeStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]] range:NSMakeRange(0, [typeStr length])];
    
    [att appendAttributedString:typeStr];
  }
  // set paragraph
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  return att;  
}


@end
