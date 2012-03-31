//
//  TPDocumentSection.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
