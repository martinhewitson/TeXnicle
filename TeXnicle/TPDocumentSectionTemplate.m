//
//  TPDocumentSectionTemplate.m
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPDocumentSectionTemplate.h"

@implementation TPDocumentSectionTemplate

@synthesize name;
@synthesize tag;
@synthesize order;

+ (TPDocumentSectionTemplate*)documentSectionTemplateWithName:(NSString*)aName tag:(NSString*)aTag order:(NSInteger)anOrder
{
  return [[[TPDocumentSectionTemplate alloc] initWithName:aName tag:aTag order:anOrder] autorelease];
}

- (id) initWithName:(NSString*)aName tag:(NSString*)aTag order:(NSInteger)anOrder
{
  self = [super init];
  if (self) {
    self.order = anOrder;
    self.name = aName;
    self.tag = aTag;
  }
  return self;
}


@end
