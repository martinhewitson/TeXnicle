//
//  NSArray+DocumentTemplates.m
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSArray+DocumentTemplates.h"

@implementation NSArray (DocumentTemplates)

- (TPDocumentSectionTemplate*)orderedFirstTemplate
{
  TPDocumentSectionTemplate *returnTemplate = nil;
  NSInteger count = NSIntegerMax;
  for (TPDocumentSectionTemplate *t in self) {
    if (t.order < count) {
      count = t.order;
      returnTemplate = t;
    }
  }
  return returnTemplate;
}

- (NSArray*)templatesWithOrder:(NSInteger)order
{
  NSMutableArray *templates = [NSMutableArray array];
  for (TPDocumentSectionTemplate *t in self) {
    if (t.order == order) {
      [templates addObject:t];
    }
  }
  return templates;
}

- (NSArray*)nextTemplatesAfter:(TPDocumentSectionTemplate*)template
{
  NSMutableArray *templates = [NSMutableArray array];
  NSInteger current = [template order];
  for (TPDocumentSectionTemplate *t in self) {
    if (t.order == current+1) {
      [templates addObject:t];
    }
  }
  return templates;
}

- (NSArray*)previousTemplatesBefore:(TPDocumentSectionTemplate*)template
{
  NSMutableArray *templates = [NSMutableArray array];
  NSInteger current = [template order];
  for (TPDocumentSectionTemplate *t in self) {
    if (t.order == current-1) {
      [templates addObject:t];
    }
  }
  return templates;
}


@end
