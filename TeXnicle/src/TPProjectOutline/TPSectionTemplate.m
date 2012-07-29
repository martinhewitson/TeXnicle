//
//  TPSectionTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSectionTemplate.h"

@implementation TPSectionTemplate

@synthesize name;
@synthesize tag;
@synthesize parent;
@synthesize color;
@synthesize mnemonic;

+ (id)documentSectionTemplateWithName:(NSString*)aName tag:(NSString*)aTag parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName
{
  return [[TPSectionTemplate alloc] initWithName:aName tag:aTag parent:aParent color:aColor mnemonic:shortName];
}

- (id) initWithName:(NSString*)aName tag:(NSString*)aTag parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName
{
  self = [super init];
  if (self) {
    self.parent = aParent;
    self.name = aName;
    self.tag = aTag;
    self.color = aColor;
    self.mnemonic = shortName;
  }
  return self;
}


+ (BOOL) template:(TPSectionTemplate*)t1 isChildOf:(TPSectionTemplate*)t2 
{
  TPSectionTemplate *template = t1;
  while (template.parent != nil) {
    if (template.parent == t2) {
      return YES;
    }
    template = template.parent;
  }
  return NO;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"{%@, %@, %@}", self.parent.name, self.name, self.tag];
}

- (NSInteger) depth
{
  TPSectionTemplate *myparent = self.parent;
  NSInteger count = 0;
  while (myparent != nil) {
    myparent = myparent.parent;
    count++;
  }
  
  return count;
}

@end
