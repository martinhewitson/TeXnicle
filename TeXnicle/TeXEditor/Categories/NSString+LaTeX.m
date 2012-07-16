//
//  NSString+LaTeX.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/2/10.
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

#import "RegexKitLite.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "MHFileReader.h"
#import "BibliographyEntry.h"

@implementation NSString (LaTeX) 


+ (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
  NSString *  result;
  CFUUIDRef   uuid;
  CFStringRef uuidStr;
  
  uuid = CFUUIDCreate(NULL);
  assert(uuid != NULL);
  
  uuidStr = CFUUIDCreateString(NULL, uuid);
  assert(uuidStr != NULL);
  
  result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
  assert(result != nil);
  
  CFRelease(uuidStr);
  CFRelease(uuid);
  
  return result;
}

- (NSInteger) beginsWithElementInArray:(NSArray*)terms
{
//    NSLog(@"Checking %@", self);
//    NSLog(@"against: %@", terms);
  NSInteger idx = 0;
  for (NSString *term in terms) {
//    NSString *searchTerm = [NSString stringWithFormat:@"%@", term];
//    NSLog(@"   checking %@ [%@]", searchTerm, term);
    if ([self beginsWith:term]) {
      return idx;
    }
    idx++;
  }
  
  return NSNotFound;
}

- (NSArray*) referenceLabels
{	
	// scan string for all \label{something} and return the list of 'something's.
	NSArray *labels = [self componentsMatchedByRegex:@"\\\\label\\{.*?\\}"];
	
  //	NSLog(@"Scanning %@", self);
  //	NSLog(@"Found: %@",labels);
	NSMutableArray *tags = [NSMutableArray arrayWithCapacity:[labels count]];
	
	for (NSString *label in labels) {
		
		NSString *tag = [label stringByReplacingOccurrencesOfString:@"\\label{" withString:@""];
		tag = [tag stringByReplacingOccurrencesOfString:@"}" withString:@""];
		tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[tags addObject:tag];
		
	}
	
	return tags;
}


- (NSArray*) citations
{
	NSMutableArray *cites = [NSMutableArray array];
	
  // 1) look for lines starting with \bibitem
  NSScanner *scanner = [NSScanner scannerWithString:self];
  NSInteger scanLocation = 0;
  while(scanLocation < [self length]) {
    if ([scanner scanUpToString:@"\\bibitem" intoString:NULL]) {
      scanLocation = [scanner scanLocation];
//      NSLog(@"Found bibitem at %d", scanLocation);
      
      if (scanLocation == [self length]) {
        break;
      }
      scanLocation += 8;

      // 2) check if \bibitem is followed by [, if yes, scan forward to ]
      if ([self characterAtIndex:scanLocation] == '[') {
//        NSLog(@"  cite has option");
        BOOL foundClosingBracket = NO;
        NSInteger bracketCount = 1;
        scanLocation++;
        while (scanLocation < [self length]) {
          if ([self characterAtIndex:scanLocation] == '[') {
            bracketCount++;
          }
          if ([self characterAtIndex:scanLocation] == ']') {
            bracketCount--;
            if (bracketCount == 0) {
              foundClosingBracket = YES;
              break;
            }
          }
          scanLocation++;
        }
        
        // we didn't find a closing ] so bail out
        if (foundClosingBracket == NO) {
//          NSLog(@"    option is not closed properly");
          break;
        }
        
        scanLocation++;
      }
      
      // we should now go forward until we find a {
      NSInteger start = NSNotFound;
      NSInteger end   = NSNotFound;
      while (scanLocation < [self length]) {        
        if ([self characterAtIndex:scanLocation] == '{') {
          start = scanLocation+1;
          break;
        }        
        scanLocation++;
      }
      
      if (start == NSNotFound) {
        break; // bail out
      }
//      NSLog(@"  found start of tag at %d", start);
      
      // now go forwards and look for a }
      scanLocation = start;
      NSInteger bracketCount = 1;
      while (scanLocation < [self length]) {
        if ([self characterAtIndex:scanLocation] == '{') {
          bracketCount++;
        }
        if ([self characterAtIndex:scanLocation] == '}') {
          bracketCount--;
          if (bracketCount == 0) {
            end = scanLocation-1;
            break;
          }
        }
        scanLocation++;
      }
//      NSLog(@"  found end of tag at %d", end);
      
      if (start != NSNotFound && end != NSNotFound && start < end) {
        NSString *tag = [self substringWithRange:NSMakeRange(start, end-start+1)];
        NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:tag] autorelease];
        [str addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, [str length])];  
        [cites addObject:str];    
      }
      
      [scanner setScanLocation:scanLocation];
    } else {
      break;
    }
  }
  
  return cites;
  
//  //  \bibitem[{Ahn(2011)}]{ahn11}
//  NSString *regexp = @"\\\\bibitem(.*)";
//  NSLog(@"regexp: %@", regexp);
//  
//	NSArray *terms = [self arrayOfCaptureComponentsMatchedByRegex:regexp];
//  NSLog(@"Terms %@", terms);
//  for (NSArray *term in terms) {
//    NSString *tag = [term objectAtIndex:1];
//    NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:tag] autorelease];
//    [str addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, [str length])];  
//    [cites addObject:str];    
//  }
  
	return cites;
}

- (NSArray*) citationsFromBibliographyIncludedFromPath:(NSString*)sourceFile
{
  //  NSLog(@"Checking for bib files included in %@", sourceFile);
  NSMutableArray *citations = [NSMutableArray array];
  
	// search for \\bibliography{
  NSScanner *scanner = [NSScanner scannerWithString:self];
  
  if ([scanner scanUpToString:@"\\bibliography{" intoString:NULL]) {
    NSInteger idx = [scanner scanLocation];
    if (idx < [self length]) {
      NSString *argString = [self parseArgumentStartingAt:&idx];
      NSArray *args = [argString componentsSeparatedByString:@","];
      for (NSString *arg in args) {
        if (arg && [arg length]>0) {
          if ([[arg pathExtension] length] == 0) {
            arg = [arg stringByAppendingPathExtension:@"bib"];
          }
        }
        
        //        NSLog(@"Found \\bibliography with argument %@", arg);
        NSString *bibpath = nil;
        if ([arg isAbsolutePath]) {
          //          NSLog(@"   path is absolute");
          bibpath = arg;
        } else {        
          //          NSLog(@"   path is relative to project");
          bibpath = [[sourceFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:arg];
        }
        //        NSLog(@"Bib file is %@", bibpath);
        
        MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];      
        NSString *bibcontents = [fr silentlyReadStringFromFileAtURL:[NSURL fileURLWithPath:bibpath]];
        if (bibcontents && [bibcontents length]>0) {
          NSArray *entries = [BibliographyEntry bibtexEntriesFromString:bibcontents];
          for (BibliographyEntry *entry in entries) {
            [citations addObject:entry];
          }
        }    
      }
    }  
  }  
  
  return citations;
}

- (NSString *)nextWordStartingAtLocation:(NSUInteger*)loc
{
	NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
	
	NSUInteger start = (*loc)++;
	while (*loc < [self length]) {
		
		if ([ws characterIsMember:[self characterAtIndex:*loc]] ||
				[ns characterIsMember:[self characterAtIndex:*loc]] || loc == 0) {
			NSString *s = [self substringWithRange:NSMakeRange(start, *loc-start)];
			(*loc)--;
			return s;
		}
		
		(*loc)++;
	}
	return nil;
}

+ (NSString *)stringWithControlsFilteredForString:(NSString *)str 
{  
  if (str == nil) return nil;
  
  NSCharacterSet *filterChars = nil;
	
	// make a character set of control characters (but not whitespace/newline
	// characters), and keep a static immutable copy to use for filtering
	// strings
  //	NSCharacterSet *ctrlChars = [NSCharacterSet controlCharacterSet];
	NSCharacterSet *newLineChars = [NSCharacterSet newlineCharacterSet];
  //	NSCharacterSet *newlineWsChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  //	NSCharacterSet *nonNewlineWsChars = [newlineWsChars invertedSet];
	
	NSMutableCharacterSet *mutableChars = [[newLineChars mutableCopy] autorelease];
  //	[mutableChars formIntersectionWithCharacterSet:nonNewlineWsChars];
  //	[mutableChars formUnionWithCharacterSet:ctrlChars];
  //	[mutableChars addCharactersInRange:NSMakeRange(0x0B, 2)]; // filter vt, ff
	[mutableChars addCharactersInRange:NSMakeRange(0x2028, 2)]; // filter vt, ff
  //	[mutableChars addCharactersInRange:NSMakeRange(0x000b, 2)]; 
	
	filterChars = [mutableChars copy];
  
  // look for any invalid characters
  NSRange range = [str rangeOfCharacterFromSet:filterChars]; 
  if (range.location != NSNotFound) {
    
    // copy the string to a mutable, and remove null and non-whitespace 
    // control characters
    NSMutableString *mutableStr = [NSMutableString stringWithString:str];  
    while (range.location != NSNotFound) {
      
      [mutableStr deleteCharactersInRange:range];
      //			[mutableStr replaceCharactersInRange:range withString:@" "];
      
      range = [mutableStr rangeOfCharacterFromSet:filterChars]; 
    }
    
		[filterChars release];
    return mutableStr;
  }
  
	[filterChars release];
  return [[str copy] autorelease];
}

- (NSString*)command
{
  if ([self characterAtIndex:0] != '\\') {
    return nil;
  }
  
  NSInteger start = 0;
  while (start < [self length]) {
    unichar c = [self characterAtIndex:start];
    if (c == '{' || 
        [[NSCharacterSet whitespaceCharacterSet] characterIsMember:c] ||
        [[NSCharacterSet newlineCharacterSet] characterIsMember:c]) {
      return [self substringWithRange:NSMakeRange(0, start)];
    }
    start++;
  }
  return nil;
}

- (NSString*)argument
{
  NSInteger start = 0;
  
  NSInteger argStart = -1;
  NSInteger argEnd = -1;
  while (start < [self length]) {
    //						NSLog(@"Checking '%C'", [string characterAtIndex:start]);
    if (argStart<0 && [self characterAtIndex:start] == '{') {
      argStart = start+1;
    }
    if (argEnd<0 && [self characterAtIndex:start] == '}') {
      argEnd = start;
      break;
    }
    start++;
  }
  
  if (argStart>=0 && argEnd>=0 && argEnd>=argStart) {
    NSRange argRange = NSMakeRange(argStart, argEnd-argStart);
    return [self substringWithRange:argRange];
  }  
  return nil;
}

- (BOOL)isCommentLineBeforeIndex:(NSInteger)anIndex commentChar:(NSString*)commChar
{
//  NSLog(@"Checking for comment before index %d", anIndex);
  
  if ([self length] == 0) {
    return NO;
  }
  
  if (anIndex < 0 || anIndex >= [self length]) {
    return NO;
  }
  
  NSRange lineRange = [self lineRangeForRange:NSMakeRange(anIndex, 0)];
//  NSLog(@"Got line range %@", NSStringFromRange(lineRange));
  
  NSString *line = [self substringWithRange:lineRange];
  
  NSRange commRange = [line rangeOfString:commChar];
  if (commRange.location != NSNotFound) {
    if (commRange.location < anIndex-lineRange.location) {
      if (commRange.location > 0) {
        if ([line characterAtIndex:commRange.location-1] != '\\') {
          return YES;
        }
      }
      if (commRange.location == 0) {
        return YES;
      }
    }
  }  
  
  return NO;
}

- (BOOL)isInArgumentAtIndex:(NSInteger)anIndex
{
  NSInteger idx = 0;
  NSInteger bcount = 0;
  
  // check for {}
  while (idx < anIndex && idx < [self length]) {
    if ([self characterAtIndex:idx] == '{') {
      bcount++;
    } else if ([self characterAtIndex:idx] == '}') {
      bcount--;
    } else {
      // do nothing
    }
    idx++;
  }
  if (bcount>0) {
    return YES;
  }
  // but this could be a wrapped argument so check to the end of the line for a closing }
  while (idx < [self length]) {
    if ([self characterAtIndex:idx] == '{') {
      bcount++;
    } else if ([self characterAtIndex:idx] == '}') {
      bcount--;
    } else {
      // do nothing
    }
    idx++;
  }
  if (bcount<0) {
    return YES;
  }
  
  
  // check for []
  bcount = 0;
  idx = 0;
  while (idx < anIndex && idx < [self length]) {
    if ([self characterAtIndex:idx] == '[') {
      bcount++;
    } else if ([self characterAtIndex:idx] == ']') {
      bcount--;
    } else {
      // do nothing
    }
    idx++;
  }
  if (bcount>0) {
    return YES;
  }
  
  return NO;
}

- (BOOL)isCommandBeforeIndex:(NSInteger)anIndex
{
  NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
  NSInteger idx = anIndex;
  while (idx >= 0 && idx < [self length]) {
    if ([ws characterIsMember:[self characterAtIndex:idx]]) {
      return NO;
    }
    if ([self characterAtIndex:idx] == '\\') {
      return YES;
    }
    idx--;
  }
  return NO;
}

- (NSString*)texString
{
  return [self stringByReplacingOccurrencesOfString:@"_" withString:@"\\_"];
}

- (NSString*)parseArgumentStartingAt:(NSInteger*)loc
{
  NSInteger count = *loc;
  NSInteger nameStart = -1;
  NSInteger nameEnd   = -1;
  while (count < [self length]) {
    if ([self characterAtIndex:count] == '{') {
      nameStart = count+1;
    }
    if ([self characterAtIndex:count] == '}') {
      nameEnd = count;
      break;
    }
    count++;
  }
  
  if (nameEnd > nameStart && nameEnd >= 0 && nameStart >= 0) {
    *loc = nameEnd;
    return [self substringWithRange:NSMakeRange(nameStart, nameEnd-nameStart)];
  }
  
  return nil;
}

- (NSString*)parseArgumentAroundIndex:(NSInteger*)loc
{
  NSInteger count = (*loc) - 1; // start one character before
  NSInteger nameStart = -1;
  NSInteger nameEnd   = -1;
  
  
  // edge case, we could be in between {}
  if (*loc > 0 && *loc < [self length]-1) {
    if ([self characterAtIndex:*loc-1] == '{' &&
        [self characterAtIndex:*loc] == '}') {
      return @"";
    }
  }
  
  // go back to look for { or ,
  // stop if we hit a newline or a }
  while (count >= 0) {
    unichar c = [self characterAtIndex:count];
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:c] 
        || c == '}' ){
      break;
    }
    
    if (c == '{' || c == ',') {
      nameStart = count+1;
      break;
    }
    count--;
  }
  
  if (nameStart < 0) {
    return nil;
  }

  // go forwards looking for a } or a ,
  // stop if we hit a newline
  count = nameStart;  
  while (count < [self length]) {
    unichar c = [self characterAtIndex:count];
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:c]) {
      break;
    }
    if (c == '}' || c == ',') {
      nameEnd = count;
      break;
    }
    count++;
  }
  
//  NSLog(@"end %d, start %d", nameEnd, nameStart);
  
  if (nameEnd >= nameStart && nameEnd >= 0 && nameStart >= 0) {
    *loc = nameEnd;
    return [[self substringWithRange:NSMakeRange(nameStart, nameEnd-nameStart)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  }
  
  return nil;
}

@end













