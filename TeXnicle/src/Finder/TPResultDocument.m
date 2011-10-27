//
//  TPResultDocument.m
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPResultDocument.h"
#import "FileEntity.h"

@implementation TPResultDocument

@synthesize document;
@synthesize matches;

+ (TPResultDocument*)resultWithDocument:(FileEntity*)aDocument
{
  return [[[TPResultDocument alloc] initWithDocument:aDocument] autorelease];
}

- (id)initWithDocument:(FileEntity*)aDocument
{
  self = [super init];
  if (self) {
    self.document = aDocument;
    self.matches = [NSMutableArray array];
  }
  
  return self;
}

- (void) dealloc
{
  self.document = nil;
  self.matches = nil;
  [super dealloc];
}

- (void) addMatch:(TPDocumentMatch *)aMatch
{
  [self.matches addObject:aMatch];
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%@: %@", [self.document valueForKey:@"name"], self.matches];
}

- (NSAttributedString*)selectedDisplayString
{
  return [self displayString];
}

- (NSAttributedString*)displayString
{
  NSString *str = [NSString stringWithFormat:@"%@: %d Matches", [self.document valueForKey:@"name"], [self.matches count]];
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:str] autorelease]; 
  return att;
}


@end
