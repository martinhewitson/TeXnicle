//
//  TPDocumentSection.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPDocumentSection.h"
#import "FileEntity.h"
#import "ProjectEntity.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "NSMutableAttributedString+CodeFolding.h"
#import "RegexKitLite.h"

@implementation TPDocumentSection

@synthesize type;
@synthesize name;
@synthesize range;
@synthesize document;
@synthesize subsections;

+ (TPDocumentSection*)sectionWithRange:(NSRange)aRange type:(TPDocumentSectionTemplate*)aTemplate name:(NSString*)aName document:(id)aDocument;
{
  return [[[TPDocumentSection alloc] initWithRange:aRange type:aTemplate name:aName document:aDocument] autorelease];
}

- (void) dealloc
{
  self.subsections = nil;
  
  [super dealloc];
}

- (id)initWithRange:(NSRange)aRange type:(TPDocumentSectionTemplate*)aTemplate name:(NSString*)aName document:(id)aDocument;
{
  self = [super init];
  if (self) {
    self.type = aTemplate;
    self.name = aName;
    self.range = aRange;
    self.document = aDocument;
    self.subsections = [NSMutableArray array];    
  }
  
  return self;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%@: %@, %@", self.name, NSStringFromRange(self.range), self.subsections];
}

- (void)addSubsection:(TPDocumentSection*)aSubsection
{
  if (aSubsection != nil) {
    [self.subsections addObject:aSubsection];
    aSubsection.document = self;
  }
}


@end
