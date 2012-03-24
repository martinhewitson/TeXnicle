//
//  NSString+LaTeX.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
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
//  NSLog(@"Checking %@", self);
//  NSLog(@"against: %@", terms);
  NSInteger idx = 0;
  for (NSString *term in terms) {
    NSString *searchTerm = [NSString stringWithFormat:@"%@{", term];
//    NSLog(@"   checking %@", searchTerm);
    if ([self beginsWith:searchTerm]) {
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
	
	// First standard \bibitem commands
	NSArray *labels = [self componentsMatchedByRegex:@"\\\\bibitem[\\[[0-9]+\\]]*\\{.*\\}"];
	for (NSString *label in labels) {
		
		// get the range between { and }
		int start = -1;
		int end   = -1;
		for (int kk=0; kk<[label length]; kk++) {
			if ([label characterAtIndex:kk]=='{') {
				start = kk+1;
			}
			if ([label characterAtIndex:kk]=='}' && start >= 0) {				
				end = kk-1;
				break;
			}
		}
		if (start>=0 && end>start) {
			NSString *tag = [label substringWithRange:NSMakeRange(start, end-start+1)];
      NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:tag] autorelease];
      [str addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, [str length])];  
			[cites addObject:str];
		}
	}
  
	return cites;
}

- (NSArray*) citationsFromBibliographyIncludedFromPath:(NSString*)sourceFile
{
  NSLog(@"Checking for bib files included in %@", sourceFile);
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
        
        NSLog(@"Found \\bibliography with argument %@", arg);
        NSString *bibpath = nil;
        if ([arg isAbsolutePath]) {
          NSLog(@"   path is absolute");
          bibpath = arg;
        } else {        
          NSLog(@"   path is relative to project");
          bibpath = [[sourceFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:arg];
        }
        NSLog(@"Bib file is %@", bibpath);
        
        MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];      
        NSString *bibcontents = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:bibpath]];
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
  if ([self length] == 0) {
    return NO;
  }
  
  NSRange commRange = [self rangeOfString:commChar];
  if (commRange.location != NSNotFound) {
    if (commRange.location < anIndex) {
      if (commRange.location > 0) {
        if ([self characterAtIndex:commRange.location-1] != '\\') {
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


@end













