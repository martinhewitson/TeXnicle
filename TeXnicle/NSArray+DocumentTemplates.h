//
//  NSArray+DocumentTemplates.h
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPDocumentSectionTemplate.h"

@interface NSArray (DocumentTemplates)

- (TPDocumentSectionTemplate*)orderedFirstTemplate;
- (NSArray*)nextTemplatesAfter:(TPDocumentSectionTemplate*)template;
- (NSArray*)previousTemplatesBefore:(TPDocumentSectionTemplate*)template;
- (NSArray*)templatesWithOrder:(NSInteger)order;

@end
