//
//  BibliographyEntry.m
//  TeXnicle
//
//  Created by Martin Hewitson on 1/4/10.
//  Copyright 2010 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "BibliographyEntry.h"
#import "NSMutableAttributedString+BibFieldDisplay.h"

@implementation BibliographyEntry


@synthesize tag;
@synthesize author;
@synthesize title;
@synthesize publishedDate;
@synthesize sourceString;

- (id)init
{
	self = [super init];
	
	if (self) {
	
		[self setTag:@""];
		[self setAuthor:@""];
		[self setTitle:@""];
		[self setPublishedDate:@""];
		
		
	}
	
	return self;
}

- (id) initWithString:(NSString*)content
{
  self = [self init];
  if (self) {
    self.sourceString = content;
    [self parseContentFromString:content];
    
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary*)entryData
{
	self = [super init];
	
	if (self) {
		
		[self setTag:@""];
		[self setAuthor:@""];
		[self setTitle:@""];
		[self setPublishedDate:@""];
		
		NSString *str = [entryData valueForKey:@"Tag"];
		if (str)	
			[self setTag:str];
		
		str = [entryData valueForKey:@"Author"];
		if (str)
			[self setAuthor:str];

		str = [entryData valueForKey:@"Title"];
		if (str) 
			[self setTitle:str];
		
		str = [entryData valueForKey:@"Year"];
		if (str) 
			[self setPublishedDate:str];
		
	}
	
	return self;
}

+ (NSArray*)bibtexEntriesFromString:(NSString*)aString
{
  NSMutableArray *entries = [NSMutableArray array];
  NSInteger idx = 0;
  NSInteger strLen = [aString length];
  NSCharacterSet *wsnl = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  while( idx < strLen ) {
    
    if ([aString characterAtIndex:idx] == '@') {
      
      // parse out an entry
      
      NSInteger start = NSNotFound;
      // scan forward until we find a {
      idx++;
      while (idx < strLen) {
        unichar c = [aString characterAtIndex:idx];
        if ([wsnl characterIsMember:c]) {
          break;
        }
        if (c == '{') {
          start = idx;
          break;
        }
        idx++;
      }
      NSInteger bracketCount = 1;
      idx++;
      while( idx < strLen) {
        if ([aString characterAtIndex:idx] == '{') {
          bracketCount++;
        }
        if ([aString characterAtIndex:idx] == '}') {
          bracketCount--;
        }
        if (bracketCount == 0) {
          break;
        }
        idx++;
      }
      
      if (start != NSNotFound) {
        NSString *entryString = [[aString substringWithRange:NSMakeRange(start, idx-start+1)] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        BibliographyEntry *entry = [[BibliographyEntry alloc] initWithString:entryString];
        [entries addObject:entry];
        [entry release];
        
      }
    } // end found a @
    
    idx++;
  }
  
  return entries;
}

- (void) parseContentFromString:(NSString*)content
{
//  NSLog(@"Parsing from %@", content);
  
  // get tag 
  NSInteger idx = 0;
  NSInteger strLen = [content length];
  NSInteger start = 0;
  NSInteger end   = 0;
  while (idx < strLen) {
    if ([content characterAtIndex:idx] == '{'){
      start = idx+1;
      break;
    }
    idx++;
  }
  while (idx < strLen) {
    if ([content characterAtIndex:idx] == ','){
      end = idx;
      break;
    }
    idx++;
  }
  
  if (start < end && start > 0) {
    self.tag = [content substringWithRange:NSMakeRange(start, end-start)];
  }
  
  // get author
  self.author = [self parseBibtexField:@"author" fromString:content];
  
  // get title
  self.title = [self parseBibtexField:@"title" fromString:content];  
}

- (NSAttributedString*)attributedString
{
  NSAttributedString *comma = [[NSAttributedString alloc] initWithString:@", "];
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@""];
  
  NSMutableAttributedString *tagString = [[NSMutableAttributedString alloc] initWithString:self.tag];
  [tagString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, [self.tag length])];  
  [att appendAttributedString:tagString];
  [tagString release];
  
  if ([self.title length] > 0) {
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.title];
    [titleString addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0, [self.title length])];
    [att appendAttributedString:comma];
    [att appendAttributedString:titleString];
    [titleString release];
  }
  
  if ([self.author length] > 0) {
    if ([att length]>0){
      [att appendAttributedString:comma];    
    }
    NSMutableAttributedString *authorString = [[NSMutableAttributedString alloc] initWithString:self.author];
    [authorString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [self.author length])];
    [att appendAttributedString:comma];
    [att appendAttributedString:authorString];
    [authorString release];
  }
  
  [comma release];
  
  return [att autorelease];
}


- (NSAttributedString*)alternativeAttributedString
{
  NSAttributedString *comma = [[NSAttributedString alloc] initWithString:@", "];
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@""];
  
  NSMutableAttributedString *tagString = [[NSMutableAttributedString alloc] initWithString:self.tag];
  [tagString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, [self.tag length])];
  [tagString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [self.tag length])];
  [att appendAttributedString:tagString];
  [tagString release];
  
  if ([self.title length] > 0) {
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.title];
    [titleString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [self.title length])];
    [att appendAttributedString:comma];
    [att appendAttributedString:titleString];
    [titleString release];
  }
  
  if ([self.author length] > 0) {
    if ([att length]>0){
      [att appendAttributedString:comma];
    }
    NSMutableAttributedString *authorString = [[NSMutableAttributedString alloc] initWithString:self.author];
    [authorString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [self.author length])];
    [att appendAttributedString:comma];
    [att appendAttributedString:authorString];
    [authorString release];
  }
  
  [comma release];
  
  return [att autorelease];
}

- (NSString*)parseBibtexField:(NSString*)field fromString:(NSString*)content
{
  NSInteger idx = 0;
  NSInteger start = 0;
  NSInteger end = 0;
  NSInteger strLen = [content length];
  NSScanner *scanner = [NSScanner scannerWithString:content];
  [scanner setCaseSensitive:NO];
  if([scanner scanUpToString:field intoString:NULL]) {
    if ([scanner scanLocation]<strLen){
      idx = [scanner scanLocation];
      while (idx < strLen) {
        if ([content characterAtIndex:idx] == '{') {
          start = idx+1;
          break;
        }
        idx++;
      }
      
      idx = start;
      NSInteger bracketCount = 1;
      while (idx < strLen) {
        unichar c = [content characterAtIndex:idx];
        
        if (c == '{') {
          bracketCount++;
        }

        if (c == '}') {
          bracketCount--;
          if (bracketCount == 0) {
            end = idx;
            break;
          }
        }
        idx++;
      }      
      
      
      return [content substringWithRange:NSMakeRange(start, end-start)];
      
    }
  }
  
  return @"";
}

- (void) dealloc
{
	[super dealloc];
}

- (void) setPropertiesFromEntry:(BibliographyEntry*)anEntry
{
	[self setTag:[anEntry tag]];
	[self setAuthor:[anEntry author]];
	[self setTitle:[anEntry title]];
	[self setPublishedDate:[anEntry publishedDate]];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"[%@], [%@], [%@], [%@]", tag, author, title, publishedDate];
}

- (NSString*) string
{
  return [[self attributedString] string];
}

- (NSAttributedString*) displayString
{
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
	// TAG
	NSString *vstr = [self tag];
	if (!vstr)
		vstr = @"";
	[str addString:vstr withTag:@"Tag:"];
	
	// Author
	vstr = [self author];
	if (!vstr)
		vstr = @"";
	[str addString:vstr withTag:@"Author:"];
	
	// Title
	vstr = [self title];
	if (!vstr)
		vstr = @"";
	[str addString:vstr withTag:@"Title:"];
	
	// Published Date
	vstr = [self publishedDate];
	if (!vstr)
		vstr = @"";
	[str addString:vstr withTag:@"Published:"];
	
	return [str autorelease];
}

#pragma mark -
#pragma mark Control 


- (NSString*) bibtexEntry
{
	NSMutableString *str = [NSMutableString stringWithString:@"@unpublished{"];
	
	// add tag
	[str appendFormat:@"%@,\n", [self tag]];
	
	// add author
	[str appendFormat:@"\tAuthor={%@},\n", [self author]];
	
	// add title 
	NSString *vstr = [self title];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tTitle={%@},\n", vstr];
	
	// add published
	vstr = [self publishedDate];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tYear={%@}", vstr];
	
	[str appendFormat:@"}"];
	
	return [NSString stringWithString:str];
}

@end
