//
//  TPSectionTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSectionTemplate.h"
#import "NSImage+Resize.h"

@interface TPSectionTemplate ()


@end

@implementation TPSectionTemplate

+ (id)documentSectionTemplateWithName:(NSString*)aName tags:(NSArray*)someTags parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName icon:(NSImage*)anIcon
{
  return [[TPSectionTemplate alloc] initWithName:aName tags:someTags parent:aParent color:aColor mnemonic:shortName icon:anIcon];
}


+ (id)documentSectionTemplateWithName:(NSString*)aName tags:(NSArray*)someTags parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName
{
  return [[TPSectionTemplate alloc] initWithName:aName tags:someTags parent:aParent color:aColor mnemonic:shortName];
}


+ (id)documentSectionTemplateWithName:(NSString*)aName tag:(NSString*)aTag parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName
{
  return [[TPSectionTemplate alloc] initWithName:aName tag:aTag parent:aParent color:aColor mnemonic:shortName];
}

- (id) initWithName:(NSString*)aName tags:(NSArray*)someTags parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName icon:(NSImage*)anIcon
{
  self = [self initWithName:aName tags:someTags parent:aParent color:aColor mnemonic:shortName];
  if (self) {
    self.icon = [anIcon copy];
  }
  return self;
}


- (id) initWithName:(NSString*)aName tags:(NSArray*)someTags parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName
{
  self = [super init];
  if (self) {
    self.parent = aParent;
    self.name = aName;
    self.tags = someTags;
    self.color = aColor;
    self.mnemonic = shortName;
    self.icon = [[NSImage imageNamed:NSImageNamePathTemplate] resizeToSize:NSMakeSize(17.0, 17.0)];
  }
  return self;
}

- (id) initWithName:(NSString*)aName tag:(NSString*)aTag parent:(TPSectionTemplate *)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName
{
  self = [super init];
  if (self) {
    self.parent = aParent;
    self.name = aName;
    self.tags = @[aTag];
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

- (NSString*)tag
{
  return self.tags[0];
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
