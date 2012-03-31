//
//  TPResultDocument.m
//  TeXnicle
//
//  Created by Martin Hewitson on 4/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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
