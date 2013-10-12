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
#import "NSString+LaTeX.h"
#import "TPThemeManager.h"

@implementation BibliographyEntry


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

- (BOOL)like:(BibliographyEntry*)entry
{
  return [self.tag isEqualToString:entry.tag] & [self.author isEqualToString:entry.author] & [self.title isEqualToString:entry.title];
}

// two bib entries are equal for the purposes of sorting if they have the same tag
- (BOOL) isEqual:(BibliographyEntry*)entry
{
//  NSLog(@"%@ == %@ ? %d", self.tag, entry.tag, [self.tag isEqualToString:entry.tag]);
  
  return [self.tag isEqualToString:entry.tag];
}

- (NSUInteger)hash
{
  return [self.tag hash];
}

+ (NSArray*)bibtexEntriesFromString:(NSString*)aString
{
  //NSLog(@"Getting bibtex entries from [%@]", aString);
  NSMutableArray *entries = [NSMutableArray array];
  NSInteger idx = 0;
  NSInteger strLen = [aString length];
  NSInteger count = 0;
  while( idx < strLen ) {
    
    // check if the line is commented out
    NSRange lr = [aString lineRangeForRange:NSMakeRange(idx, 0)];
//    //NSLog(@"Checking string [%@]", [aString substringWithRange:lr]);
    if ([aString isCommentLineBeforeIndex:idx commentChar:@"%"] == YES) {
      //NSLog(@"COMMENTED");
      idx = NSMaxRange(lr);
      continue;
    }
    
    if ([aString characterAtIndex:idx] == '@') {
      count++;
      // parse out an entry
      NSInteger argStart = idx;
      NSString *arg = [aString parseArgumentStartingAt:&argStart];
      
      if (arg) {
        BibliographyEntry *entry = [[BibliographyEntry alloc] initWithString:arg];
        [entries addObject:entry];
        idx = argStart;
      }
    } // end found a @
    
    idx++;
  }
  
  //NSLog(@"Found %ld @", count);
  
  return entries;
}

- (void) parseContentFromString:(NSString*)content
{
  //NSLog(@"Parsing from %@", content);
  
  // get tag 
  NSInteger idx = 0;
  NSInteger strLen = [content length];
  NSInteger start = 0;
  NSInteger end   = 0;
  
  while (idx < strLen) {
    if ([content characterAtIndex:idx] == ','){
      end = idx-1;
      break;
    }
    idx++;
  }
  
  if (start < end && start >= 0) {
    self.tag = [content substringWithRange:NSMakeRange(start, end-start+1)];
  }
  
  // get author
  self.author = [self parseBibtexField:@"author" fromString:content];
  
  // get title
  self.title = [self parseBibtexField:@"title" fromString:content];
  
}

- (NSAttributedString*)attributedString
{
  if (_attributedString == nil) {
//    NSLog(@"Creating attributed string for [%p: %@]", self, self.tag);
    _attributedString = [self stringWithColor:[NSColor blackColor]];
  }
  return _attributedString;
}


- (NSAttributedString*)alternativeAttributedString
{
  return [self stringWithColor:[NSColor whiteColor]];
}

- (NSAttributedString*)stringWithColor:(NSColor*)aColor
{
  NSAttributedString *comma = [[NSAttributedString alloc] initWithString:@", "];
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@""];
  
  // set font
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  NSFont *font = theme.navigatorFont;
  [att addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [att length])];

  NSMutableAttributedString *tagString = [[NSMutableAttributedString alloc] initWithString:self.tag];
  
  NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:[font familyName]
                                            traits:NSBoldFontMask
                                            weight:0
                                              size:[font pointSize]];
  
  [tagString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [self.tag length])];
  
  [tagString addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0, [self.tag length])];
  [att appendAttributedString:tagString];
  
  if ([self.title length] > 0) {
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.title];
    [titleString addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0, [self.title length])];
    [titleString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [self.title length])];
    [att appendAttributedString:comma];
    [att appendAttributedString:titleString];
  }
  
  if ([self.author length] > 0) {
    if ([att length]>0){
      [att appendAttributedString:comma];
    }
    NSMutableAttributedString *authorString = [[NSMutableAttributedString alloc] initWithString:self.author];
    [authorString addAttribute:NSForegroundColorAttributeName value:aColor range:NSMakeRange(0, [self.author length])];
    [authorString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [self.author length])];
    [att appendAttributedString:comma];
    [att appendAttributedString:authorString];
  }
  
  // apply paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];
  [att addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [att length])];
  
  
  return att;
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


- (void) setPropertiesFromEntry:(BibliographyEntry*)anEntry
{
	[self setTag:[anEntry tag]];
	[self setAuthor:[anEntry author]];
	[self setTitle:[anEntry title]];
	[self setPublishedDate:[anEntry publishedDate]];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"[%@], [%@], [%@], [%@]", self.tag, self.author, self.title, self.publishedDate];
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
	
	return str;
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
