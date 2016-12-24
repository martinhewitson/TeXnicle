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

#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "MHFileReader.h"
#import "BibliographyEntry.h"
#import "TPRegularExpression.h"
#import "NSArray_Extensions.h"
#import "RegexKitLite.h"

static NSCharacterSet *controlFilterChars = nil;
static NSString *mathModeRegExpr = nil;

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

- (NSArray*) toDos
{
  // scan string for all \label{something} and return the list of 'something's.
  NSArray *toDos = [TPRegularExpression stringsMatching:@"TODO\\s+.*" inText:self];
  
//  NSLog(@"Found ToDos: [%@]", toDos);
  
  NSMutableArray *tags = [NSMutableArray arrayWithCapacity:[toDos count]];
  
  for (NSString *toDo in toDos) {
    NSString *tag = [toDo stringByReplacingOccurrencesOfRegex:@"TODO" withString:@""];
//    NSLog(@"    Got tag %@", tag);
    if (tag != nil) {
      [tags addObject:tag];
    }
  }
  
  return tags;
}


- (NSArray*) referenceLabels
{	
	// scan string for all \label{something} and return the list of 'something's.
	NSArray *labels = [TPRegularExpression stringsMatching:@"\\\\label(\\[.+?\\]|)\\{.*?\\}" inText:self];

	NSMutableArray *tags = [NSMutableArray arrayWithCapacity:[labels count]];
	
	for (NSString *label in labels) {
    NSString *tag = [label argument];
    if (tag != nil) {
      tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      [tags addObject:tag];
		}
	}
	
	return tags;
}


- (NSArray*) citations
{
	NSMutableArray *cites = [NSMutableArray array];
	NSInteger sourceStart;
  // 1) look for lines starting with \bibitem
  NSScanner *scanner = [NSScanner scannerWithString:self];
  NSInteger scanLocation = 0;
  while(scanLocation < [self length]) {
    if ([scanner scanUpToString:@"\\bibitem" intoString:NULL]) {
      scanLocation = [scanner scanLocation];
      //NSLog(@"Found bibitem at %ld", scanLocation);
      sourceStart = scanLocation;
      
      if (scanLocation == [self length]) {
        //NSLog(@" scan location at end: bailing out");
        break;
      }
      scanLocation += 8;

      // check if the line is commented out
      //NSRange lr = [self lineRangeForRange:NSMakeRange(scanLocation, 0)];
      //NSLog(@"Checking string [%@]", [self substringWithRange:lr]);
      if ([self isCommentLineBeforeIndex:scanLocation commentChar:@"%"] == YES) {
        //NSLog(@"COMMENTED");
        [scanner setScanLocation:scanLocation];
        continue;
      }
      
      // 2) check if \bibitem has an option []
      if (scanLocation < [self length] && [self characterAtIndex:scanLocation] == '[') {
        NSString *option = [self parseOptionStartingAtIndex:scanLocation];
        //NSLog(@"  cite has option %@", option);
        
        // we didn't find a closing ] so bail out
        if (option == nil) {
          //NSLog(@"    option is not closed properly");
          break;
        }
        scanLocation += [option length];
      }
      
      // The character at the scan location is now a { or we bail out
      NSInteger argStart = scanLocation;
      NSString *tag = [self parseArgumentStartingAt:&argStart];
      //NSLog(@"Got tag %@", tag);
      
      if (tag != nil) {
        BibliographyEntry *bib = [[BibliographyEntry alloc] init];
        bib.tag = [tag stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        bib.sourceString = [self substringWithRange:NSMakeRange(sourceStart, argStart-sourceStart+1)];
        [cites addObject:bib];
      }
      
      [scanner setScanLocation:scanLocation];
      //NSLog(@"Scan location %ld / %ld", scanLocation, [self length]);
    } else {
      break;
    }
  }
  
  return cites;
}

- (NSString*)parseOptionStartingAtIndex:(NSInteger)startAt
{
  BOOL foundClosingBracket = NO;
  NSInteger bracketCount = 0;
  NSInteger loc = startAt;
  NSInteger start = NSNotFound;
  NSInteger end = NSNotFound;
  while (loc < [self length]) {
    if ([self characterAtIndex:loc] == '[') {
      if (start == NSNotFound) {
        start = loc;
      }
      bracketCount++;
    }
    if ([self characterAtIndex:loc] == ']') {
      bracketCount--;
      if (bracketCount == 0) {
        foundClosingBracket = YES;
        start++; // it must be safe to take the character after [ as the start now
        end = loc-1;
        break;
      }
    }
    loc++;
  }
  
  // we didn't find a closing ] so bail out
  if (foundClosingBracket == NO) {
    return nil;
  }
  
  return [self substringWithRange:NSMakeRange(start, end-start+1)];
}

- (NSArray*) citationsFromBibliographyIncludedFromPath:(NSString*)sourceFile
{
  //NSLog(@"Checking for bib files included in %@", sourceFile);
  NSMutableArray *citations = [NSMutableArray array];
  
	// search for \\bibliography{
  [citations addObjectsFromArray:[self citationsFromIncludeBibiliographyInSourceFile:sourceFile]];
  
  // bib resource
  [citations addObjectsFromArray:[self citationsFromBibResourceInSourceFile:sourceFile]];
  
  return citations;
}

- (NSArray*)citationsFromIncludeBibiliographyInSourceFile:(NSString*)sourceFile
{
  NSMutableArray *citations = [NSMutableArray array];
  
  NSScanner *scanner = [NSScanner scannerWithString:self];
  //NSLog(@"Scanning %@/%@", sourceFile, self);
  
  // scan for \bibliography
  NSInteger idx = NSNotFound;
  if ([scanner scanUpToString:@"\\bibliography{" intoString:NULL]) {
    idx = [scanner scanLocation];
  } else {
    // try regexp
    NSString *expr = @"\\\\bibliography\\{";
    NSArray *ranges = [TPRegularExpression rangesMatching:expr inText:self];
    //NSLog(@"Ranges %@", ranges);
    if ([ranges count] > 0) {
      NSRange r = [ranges[0] rangeValue];
      idx = r.location;
    }
  }
  
  //NSLog(@" file included at index %ld", idx);
  // check if this line is commented
  if ([self isCommentLineBeforeIndex:idx commentChar:@"%"] == YES) {
    //NSLog(@"COMMENTED");
    return @[];
  }
  
  NSInteger sourceStart = idx;
  if (idx < [self length]) {
    NSString *argString = [self parseArgumentStartingAt:&idx];
    NSInteger sourceEnd = idx;
    NSArray *args = [argString componentsSeparatedByString:@","];
    for (__strong NSString *arg in args) {
      if (arg && [arg length]>0) {
        if ([[arg pathExtension] length] == 0) {
          arg = [arg stringByAppendingPathExtension:@"bib"];
        }
      }
      
      //NSLog(@"Found \\bibliography with argument %@", arg);
      NSString *bibpath = nil;
      if ([arg isAbsolutePath]) {
        //NSLog(@"   path is absolute");
        bibpath = arg;
      } else {
        //NSLog(@"   path is relative to project");
        bibpath = [[sourceFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:arg];
      }
      //NSLog(@"Bib file is %@", bibpath);
      
      MHFileReader *fr = [[MHFileReader alloc] init];
      NSString *bibcontents = [fr silentlyReadStringFromFileAtURL:[NSURL fileURLWithPath:bibpath]];
      if (bibcontents && [bibcontents length]>0) {
        NSArray *entries = [BibliographyEntry bibtexEntriesFromString:bibcontents];
        //NSLog(@"Got %ld entries ", [entries count]);
        NSString *sourceString = nil;
        if (sourceStart>=0 && sourceEnd < [self length] && sourceStart < sourceEnd) {
          sourceString = [self substringWithRange:NSMakeRange(sourceStart, sourceEnd-sourceStart+1)];
        }
        //NSLog(@"   source string [%@]", sourceString);
        for (BibliographyEntry *entry in entries) {
          if (sourceString) {
            [entry setSourceString:sourceString];
          }
          [citations addObject:entry];
        }
      }
      // clean up
    }
  }
  
  
  return citations;
}


- (NSArray*)citationsFromBibResourceInSourceFile:(NSString*)sourceFile
{
  NSMutableArray *citations = [NSMutableArray array];
  
  NSScanner *scanner = [NSScanner scannerWithString:self];
  
  // scan for \bibliography
  if ([scanner scanUpToString:@"\\addbibresource{" intoString:NULL]) {
    NSInteger idx = [scanner scanLocation];
    NSInteger sourceStart = idx;
    if (idx < [self length]) {
      NSString *argString = [self parseArgumentStartingAt:&idx];
      NSInteger sourceEnd = idx;
      NSArray *args = [argString componentsSeparatedByString:@","];
      for (__strong NSString *arg in args) {
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
        
        MHFileReader *fr = [[MHFileReader alloc] init];
        NSString *bibcontents = [fr silentlyReadStringFromFileAtURL:[NSURL fileURLWithPath:bibpath]];
        if (bibcontents && [bibcontents length]>0) {
          NSArray *entries = [BibliographyEntry bibtexEntriesFromString:bibcontents];
          for (BibliographyEntry *entry in entries) {
            if (sourceStart>=0 && sourceEnd < [self length] && sourceStart < sourceEnd) {
              [entry setSourceString:[self substringWithRange:NSMakeRange(sourceStart, sourceEnd-sourceStart+1)]];
            }
            [citations addObject:entry];
          }
        }
        // clean up
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
  
  // if we got to the end of the string, return the remaining text
  if (*loc == [self length]) {
    NSString *s = [self substringWithRange:NSMakeRange(start, *loc-start)];
    return s;
  }
  
	return nil;
}

+ (NSString *)stringWithControlsFilteredForString:(NSString *)str 
{  
  if (str == nil) return nil;
  
  if (controlFilterChars == nil) {
    
    // make a character set of control characters (but not whitespace/newline
    // characters), and keep a static immutable copy to use for filtering
    // strings
    NSCharacterSet *newLineChars = [NSCharacterSet newlineCharacterSet];
    NSMutableCharacterSet *mutableChars = [newLineChars mutableCopy];
    [mutableChars addCharactersInRange:NSMakeRange(0x2028, 2)]; // filter vt, ff
                                                                //	[mutableChars addCharactersInRange:NSMakeRange(0x000b, 2)];
    
    controlFilterChars = [mutableChars copy];    
  }
  
  // look for any invalid characters
  NSRange range = [str rangeOfCharacterFromSet:controlFilterChars]; 
  if (range.location != NSNotFound) {
    
    // copy the string to a mutable, and remove null and non-whitespace 
    // control characters
    NSMutableString *mutableStr = [NSMutableString stringWithString:str];
    while (range.location != NSNotFound) {
      [mutableStr deleteCharactersInRange:range];
      range = [mutableStr rangeOfCharacterFromSet:controlFilterChars];
//      range = [mutableStr rangeOfCharacterFromSet:controlFilterChars options:0 range:NSMakeRange(range.location, [mutableStr length] - range.location - range.length)];
    }
    
    return mutableStr;
  }
  
  return [str copy];
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
        c == '[' ||
        [[NSCharacterSet whitespaceCharacterSet] characterIsMember:c] ||
        [[NSCharacterSet newlineCharacterSet] characterIsMember:c]) {
      return [self substringWithRange:NSMakeRange(0, start)];
    }
    start++;
  }
  return self;
}

- (NSString*)argument
{
  NSInteger start = 0;
  
  NSInteger argStart = -1;
  NSInteger argEnd = -1;
  NSInteger argCount = 0;
  while (start < [self length]) {
    //						NSLog(@"Checking '%C'", [self characterAtIndex:start]);
    if ([self characterAtIndex:start] == '{') {      
      argCount++;
      if (argStart<0) {
        argStart = start+1;
      }
    }
    
    if ([self characterAtIndex:start] == '}') {
      argCount--;
      if (argStart > 0 && argCount == 0 && argEnd<0) {
        argEnd = start;
        break;
      }
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
  if (NSMaxRange(lineRange) > [self length]) {
    return NO;
  }
  
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

- (BOOL)characterIsEscapedAtIndex:(NSInteger)anIndex
{
  //NSLog(@"Checking if character at index %ld [%c] is escaped in [%@]", anIndex, [self characterAtIndex:anIndex], self);
  if (anIndex > 0) {
    //NSLog(@"Char = %c", [self characterAtIndex:anIndex-1]);
    if ([self characterAtIndex:anIndex-1] == '\\') {
      return YES;
    }
  }
  
  return NO;
}

// check if there is a $ somewhere on this line and a $ somewhere after the index on the same line
- (BOOL)isInMathAtIndex:(NSInteger)anIndex
{
  //NSLog(@"Checking math at index %ld in [%@]", anIndex, self);
  
  //NSRange lr = [self lineRangeForRange:NSMakeRange(anIndex, 0)];
  //NSString *lineText = [self substringWithRange:lr];
  //NSLog(@"   line: %@", lineText);
  
  if (mathModeRegExpr == nil) {
    NSArray *mathEnvironmentsForRegExp = @[@"equation", @"eqnarray", @"matrix", @"pmatrix", @"array", @"bmatrix"];
    mathModeRegExpr = @"(\\$.*?\\$)";
    
    for (NSString *env in mathEnvironmentsForRegExp) {
      mathModeRegExpr = [mathModeRegExpr stringByAppendingFormat:@"|(?s:\\\\begin\\{%@\\}.*?\\\\end\\{%@\\})", env, env];
    }
  }
  
  NSArray *ranges = [TPRegularExpression rangesMatching:mathModeRegExpr inText:self];
  
  //NSLog(@"Found %@", ranges);
  for (NSValue *rv in ranges) {
    NSRange r = [rv rangeValue];
    if (NSLocationInRange(anIndex, r)) {
      return YES;
    }
  }
  
  return NO;
}

- (BOOL)isInArgumentAtIndex:(NSInteger)anIndex
{
  NSInteger idx = 0;
  NSInteger bcount = 0;
  
  // check for {}
  //NSLog(@"---- loop 1");
  while (idx < anIndex && idx < [self length]) {
    unichar c = [self characterAtIndex:idx];
    if (c == '{' && [self characterIsEscapedAtIndex:idx] == NO && [self isArgumentOfCommandAtIndex:idx]) {
      bcount++;
    } else if (c == '}' && [self characterIsEscapedAtIndex:idx] == NO) {
      bcount--;
    } else {
      // do nothing
    }
    
    //NSLog(@"Checked char [%c]", c);
    //NSLog(@"  is command before? %d", [self isCommandBeforeIndex:idx]);
    //NSLog(@"   count: %ld ", bcount);
    idx++;
  }
  
  if (bcount > 0) {
    return YES;
  }
  
  //NSLog(@"---- loop 2");
  // but this could be a wrapped argument so check to the end of the line for a closing }
  while (idx < [self length]) {
    unichar c = [self characterAtIndex:idx];
    if (c == '{' && [self characterIsEscapedAtIndex:idx] == NO && [self isArgumentOfCommandAtIndex:idx]) {
      bcount++;
    } else if (c == '}' && [self characterIsEscapedAtIndex:idx] == NO && [self isArgumentOfCommandAtIndex:idx]) {
      bcount--;
    } else if (c == '\\') {
      return NO;
    } else {
      // do nothing
    }
    
    //NSLog(@"Checked char [%c]", c);
    //NSLog(@"  is command before? %d", [self isCommandBeforeIndex:idx]);
    //NSLog(@"   count: %ld ", bcount);
    idx++;
  }
  
  if (bcount < 0) {
    return YES;
  }
  
  
  // check for []
  bcount = 0;
  idx = 0;
  while (idx < anIndex && idx < [self length]) {
    if ([self characterAtIndex:idx] == '[' && [self characterIsEscapedAtIndex:idx] == NO && [self isArgumentOfCommandAtIndex:idx]) {
      bcount++;
    } else if ([self characterAtIndex:idx] == ']' && [self characterIsEscapedAtIndex:idx] == NO) {
      bcount--;
    } else {
      // do nothing
    }
    idx++;
  }
  if (bcount>0) {
    return YES;
  }

  
  // check for ()
  bcount = 0;
  idx = 0;
  while (idx < anIndex && idx < [self length]) {
    if ([self characterAtIndex:idx] == '(' && [self characterIsEscapedAtIndex:idx] == NO && [self isArgumentOfCommandAtIndex:idx]) {
      bcount++;
    } else if ([self characterAtIndex:idx] == ')' && [self characterIsEscapedAtIndex:idx] == NO) {
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
  //NSLog(@"Checking if command is before %ld in [%@]", anIndex, self);
  NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
  if (anIndex > 0) {
    NSInteger idx = anIndex-1;
    while (idx >= 0 && idx < [self length]) {
      unichar c = [self characterAtIndex:idx];
      //NSLog(@"Checking char at index %ld [%c]", idx, c);
      if ([ns characterIsMember:c]) {
        return NO;
      }
                  
      if (c == '\\') {
        if (idx+1 < [self length]) {
          unichar next = [self characterAtIndex:idx+1];
          // the next character should be a alpha for this to be a command
          if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:next]) {
            return YES;
          }
        }
      }
      idx--;
    }
  }
  return NO;
}

- (BOOL)isInCommandAtIndex:(NSInteger)anIndex
{
  NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
  NSCharacterSet *an = [NSCharacterSet alphanumericCharacterSet];
  
  if (anIndex > 0) {
    NSInteger idx = anIndex-1;
    while (idx >= 0 && idx < [self length]) {
      unichar c = [self characterAtIndex:idx];
      //NSLog(@"Checking char at index %ld [%c]", idx, c);
      if ([ws characterIsMember:c]) {
        return NO;
      }
      
      if ([an characterIsMember:c] == NO) {
        return NO;
      }
      
      if (c == '\\') {
        if (idx+1 < [self length]) {
          unichar next = [self characterAtIndex:idx+1];
          // the next character should be a alpha for this to be a command
          if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:next]) {
            return YES;
          }
        }
      }
      idx--;
    }
  }
  return NO;
}

- (BOOL)isArgumentOfCommandAtIndex:(NSInteger)anIndex
{
  NSArray *ranges = [self commandRanges];
  return [NSString isArgumentAtIndex:anIndex forCommandsAtRanges:ranges];
}

- (NSArray*)commandRanges
{
  NSString *expr = @"(\\\\[a-zA-Z]+)(\\s|(\\[.*?\\])*(\\*?\\{.*?\\})*)";
  NSArray *ranges = [TPRegularExpression rangesMatching:expr inText:self];
  return ranges;
}

+ (BOOL)isArgumentAtIndex:(NSInteger)index forCommandsAtRanges:(NSArray*)ranges
{
  //NSLog(@"Found %@", ranges);
  for (NSValue *rv in ranges) {
    NSRange r = [rv rangeValue];
    if (NSLocationInRange(index, r)) {
      //NSLog(@"Got command [%@]", cmd);
      return YES;
    }
  }
  
  return NO;
}

// try to do better command matching with reg expressions
- (NSString*)commandAtIndex:(NSInteger)index
{
  NSArray *ranges = [self commandRanges];
  
  //NSLog(@"Found %@", ranges);
  for (NSValue *rv in ranges) {
    NSRange r = [rv rangeValue];
    if (NSLocationInRange(index, r)) {
      NSString *cmd = [self substringWithRange:r];
      //NSLog(@"Got command [%@]", cmd);
      return cmd;
    }
  }
  
  return nil;
}




- (NSString*)texString
{
  return [self stringByReplacingOccurrencesOfString:@"_" withString:@"\\_"];
}

- (NSString*)parseArgumentStartingAt:(NSInteger*)loc
{
  NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
  NSInteger count = *loc;
  NSInteger nameStart = -1;
  NSInteger nameEnd   = -1;
  NSInteger braceCount = 0;
  while (count < [self length]) {
    unichar c = [self characterAtIndex:count];
    
    // if we get to a newline without finding an opening brace, stop.
    if ([newLineSet characterIsMember:c] && braceCount == 0) {
      break;
    }
    
    if (c == '{') {
      braceCount++;
      if (nameStart < 0) {
        nameStart = count+1;
      }
    }
    if (c == '}') {
      braceCount--;
      if (braceCount == 0) {
        nameEnd = count;
        break;
      }
    }
    count++;
  }
  
  if (nameEnd > nameStart && nameEnd >= 0 && nameStart >= 0) {
    *loc = nameEnd;
    return [self substringWithRange:NSMakeRange(nameStart, nameEnd-nameStart)];
  }
  
  return nil;
}

- (NSString*)parseConTeXtTitleStartingAt:(NSInteger*)loc
{
  NSInteger count = *loc;
  NSInteger nameStart = -1;
  NSInteger nameEnd   = -1;
  NSInteger braceCount = 0;
  
  while (count < [self length]) {
    unichar c = [self characterAtIndex:count];
    
    // stop if we hit the next \start* command
    if (c == '\\') {
      if (count+4 < [self length]) {
        NSString *coming = [self substringWithRange:NSMakeRange(count, 6)];
        if ([coming isEqualToString:@"\\start"]) {
          break;
        }
      }
    }
    
    if (c == '[') {
      braceCount++;
      if (nameStart < 0) {
        nameStart = count+1;
      }
    }
    if (c == ']') {
      braceCount--;
      if (braceCount == 0) {
        nameEnd = count;
        break;
      }
    }
    count++;
  }
  
  // should we parse the argument?
  if (nameEnd > nameStart && nameEnd >= 0 && nameStart >= 0) {
    NSString *argString = [self substringWithRange:NSMakeRange(nameStart, nameEnd-nameStart)];
    
    NSArray *matches = [argString captureComponentsMatchedByRegex:@"title=[\\{]?([^,\\}]*)"];
    if ([matches count] == 2) {
      return matches[1];
    }
  }
  
  return nil;
}

- (NSString*)parseArgumentAroundIndex:(NSInteger*)loc
{
  NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
  NSInteger count = (*loc) - 1; // start one character before
  NSInteger nameStart = -1;
  NSInteger nameEnd   = -1;
  
  if ([self isCommandBeforeIndex:*loc] == NO) {
    return nil;
  }
  
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
    if ([newLineSet characterIsMember:c]
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
    if ([newLineSet characterIsMember:c]) {
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


- (BOOL)wordIsIncludeCommand
{
  NSArray *inputCmds = [NSArray texIncludeCommandsSearchStrings];
  BOOL wordIsCommand = NO;
  for (NSString *cmd in inputCmds) {
    if ([self hasPrefix:cmd]) {
      wordIsCommand = YES;
      break;
    }
  }

  return wordIsCommand;
}

- (BOOL) inCiteCommands:(NSArray*)commands atIndex:(NSInteger)startLoc
{
  NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
  NSInteger loc = startLoc;
  unichar c;
  
  // NSLog(@"Checking if index %ld is in command [%@]", startLoc, self);
  
  NSInteger startIndex = NSNotFound;
  NSInteger stopIndex = NSNotFound;
  
  while (loc >= 0) {
    c = [self characterAtIndex:loc];
    
    if ([newline characterIsMember:c]) {
      break;
    }
    
    if (c=='\\') {
      startIndex = loc;
      //NSLog(@"   Command starts at index %ld", loc);
      break;
    }
    
    loc--;
  }
  
  // did we get a start location?
  if (startIndex == NSNotFound) {
    return NO;
  }
  
  // roll forward now until we have both even brace count and (whitespace or newline)
  loc++;
  NSInteger squareBraceCount = 0;
  NSInteger curlyBraceCount = 0;
  NSInteger braceCountAtStart = 0;
  while (loc < [self length])
  {
    c = [self characterAtIndex:loc];
    
    if ([newline characterIsMember:c]) {
      break;
    }
    
    if (loc == startLoc) {
      //NSLog(@"   Brace count at start loc %ld", curlyBraceCount);
      braceCountAtStart = curlyBraceCount;
    }
    
    if (c == '[') {
      if (stopIndex == NSNotFound) {
        stopIndex = loc-1;
      }
      squareBraceCount ++;
    }
    
    if (c == ']') {
      squareBraceCount --;
    }
    
    if (c == '{') {
      if (stopIndex == NSNotFound) {
        stopIndex = loc-1;
      }
      curlyBraceCount ++;
    }
    
    if (c == '}') {
      curlyBraceCount --;
    }
    
    
    if (curlyBraceCount == 0 && squareBraceCount == 0 && [whitespace characterIsMember:c]) {
      //NSLog(@"   char at stop loc %ld = [%c]", loc, c);
      break;
    }
    
    loc++;
  }
  
  //NSLog(@"   ended at loc %ld, []count=%ld, {}count=%ld", loc, squareBraceCount, curlyBraceCount);
  
  if (stopIndex == NSNotFound) {
    return NO;
  }
  
  if (braceCountAtStart == 0) {
    return NO;
  }
  
  // check the command now
  NSString *command = [self substringWithRange:NSMakeRange(startIndex, stopIndex-startIndex+1)];
  //NSLog(@"   Command: %@", command);
  
  BOOL citeCommand = [command beginsWithElementInArray:commands] != NSNotFound;
  if (citeCommand == NO) {
    //    NSLog(@"   no");
    return NO;
  }
  
  return YES;
}

#pragma mark - Brace handling

- (BOOL) shouldCloseOpeningBracket:(unichar)o with:(unichar)c atLocation:(NSInteger)startloc
{
  // count opening brackets back to beginning of string
  NSInteger loc = startloc;
  NSString *string = self;
  NSInteger opening = 0;
  
  NSInteger closing = 0;
  loc = 0;
  while (loc < [string length]) {
    if ([string characterAtIndex:loc] == o) {
      opening++;
    }
    if ([string characterAtIndex:loc] == c) {
      closing++;
    }
    loc++;
  }
    
  if (opening - closing >= 0) {
    return YES;
  }
  
  
  return NO;
}

@end













