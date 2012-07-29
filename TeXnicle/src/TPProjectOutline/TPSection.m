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

+ (id) sectionWithParent:(TPSection*)aParent start:(NSUInteger)index inFile:(id)aFile type:(TPSectionTemplate*)aType name:(NSString*)aName
{
  return [[TPSection alloc] initWithParent:aParent start:index inFile:aFile type:aType name:aName];
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
    if ([self.file isEqualTo:s.file] == NO) {
      return NO;
    }
  }
  
  if (self.type != s.type) {
    return NO;
  }
  
  if ([self.name isEqualTo:s.name] == NO) {
    return NO;
  }
  
  return YES;
}


- (BOOL)nearlyMatches:(id)object
{
  //  NSLog(@"Checking %@ against %@", self, object);
  
  if ([object isKindOfClass:[TPSection class]] == NO) {
    return NO;
  }
  
  TPSection *s = (TPSection*)object;
  
  if ([self.file isKindOfClass:[FileEntity class]]) {
    if (self.file != s.file) {
      return NO;
    }
  } else {
    if ([self.file isEqualTo:s.file] == NO) {
      return NO;
    }
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
    self.expansionState = TPOutlineExpansionStateUnknown;
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
  NSString *displayName = nil;
  if (self.parent) {
    displayName = self.parent.name;
  }
  NSString *tag = nil;
  if (self.type) {
    tag = self.type.tag;
  }
  return [NSString stringWithFormat:@"{%@, %@, %@, %@}", displayName, [self filename], tag, self.name];
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
  
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:self.name]; 
    
  [att addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [att length])];
  
  if (showDetails) {
    // type, file
    NSAttributedString *blank = [[NSAttributedString alloc] initWithString:@"  "];
    [att appendAttributedString:blank];
    NSString *typeFileStr = [NSString stringWithFormat:@"(%@, %@)", self.type.name, [self filename]];
    NSMutableAttributedString *typeStr = [[NSMutableAttributedString alloc] initWithString:typeFileStr]; 
    [typeStr addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [typeStr length])];
    [typeStr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]] range:NSMakeRange(0, [typeStr length])];    
    [att appendAttributedString:typeStr];
  }
  
  // set paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
    
  return att;
}


@end
