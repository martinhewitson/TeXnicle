//
//  MHCodeFolder.m
//  TeXnicle
//
//  Created by Martin Hewitson on 01/05/11.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MHCodeFolder.h"
#import "MHFoldingTagDescription.h"
#import "NSString+Extension.h"
#import "NSAttributedString+LineNumbers.h"
#import "MHLineNumber.h"
#import "NSString+LaTeX.h"
#import "RegexKitLite.h"

@implementation MHCodeFolder

+ (MHCodeFolder*) codeFolderWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex startLine:(NSInteger)startLine endLine:(NSInteger)endLine tag:(MHFoldingTagDescription*)aTag
{
  return [[MHCodeFolder alloc] initWithStartIndex:startIndex endIndex:endIndex startLine:startLine endLine:endLine tag:(MHFoldingTagDescription*)aTag];
}

- (id) initWithStartIndex:(NSInteger)aStartIndex endIndex:(NSInteger)anEndIndex startLine:(NSInteger)aStartLine endLine:(NSInteger)anEndLine tag:(MHFoldingTagDescription*)aTag
{
  self = [self init];
  if (self) {
    self.startLine  = aStartLine;
    self.endLine    = anEndLine;
    self.startIndex = aStartIndex;
    self.endIndex   = anEndIndex;
    self.tag        = aTag;
  }
  return self;
}




- (BOOL) isValid
{
  if (self.startLine==NSNotFound || self.startIndex==NSNotFound || self.endLine==NSNotFound || self.endIndex==NSNotFound || self.endIndex < self.startIndex) {
    return NO;
  }
  return YES;
}

+ (MHCodeFolder*) codeFolderStartingAtIndex:(NSInteger)index inFolders:(NSArray*)codeFolders
{
//  NSLog(@"Getting folder for line %ld in %@", index, codeFolders);
  for (MHCodeFolder *folder in codeFolders) {
    if (index == folder.startLine) {
      return folder;
    }
  }
  return nil;
}

+ (MHCodeFolder*) codeFolderEndingAtIndex:(NSInteger)index inFolders:(NSArray*)codeFolders
{
  for (MHCodeFolder *folder in codeFolders) {
    if (index == folder.endLine) {
      return folder;
    }
  }
  return nil;
}

- (NSString*) description
{
  return [NSString stringWithFormat:@"%d: lines: %ld:%ld (%ld), range: %ld,%ld", self.folded, self.startLine, self.endLine, self.lineCount, self.startIndex, self.endIndex];
}

// Try to complete the folder. This means, first check we have and end and start. 
// Then get the text that should be folded. And finally set the line count.
- (void) completeFolderWithText:(NSString*)someText forTags:(NSArray*)tags
{
  // if we have no end and no start, return
  if (self.startIndex == NSNotFound && self.endLine == NSNotFound) {
    return;
  }
  
  // if we have a start but not end...
  if (self.startIndex != NSNotFound && self.endIndex == NSNotFound) {
    // then look for the corresponding end tag
    [self findEndTagInText:someText fromFoldingTags:tags];
  }
  
  // if we have an end but no start...
  if (self.startIndex == NSNotFound && self.endIndex != NSNotFound) {
    [self findStartTagInText:someText fromFoldingTags:tags];
  }
  
  // get the text
  if (self.startIndex != NSNotFound && self.endIndex != NSNotFound && self.endIndex>self.startIndex) {
    self.foldedText = [someText substringWithRange:NSMakeRange(self.startIndex, self.endIndex-self.startIndex)];
  }
  
  if (self.startLine != NSNotFound && self.endLine != NSNotFound && self.endLine >= self.startLine) {
    self.lineCount = self.endLine-self.startLine;
  }
    
  
}


- (NSArray*)dictionaryOfTagsForText:(NSString*)someText
{
  __block NSMutableArray *tags = [NSMutableArray array];
  if (NSClassFromString(@"NSRegularExpression")) {
    
  } else {
    [someText enumerateStringsMatchedByRegex:@"\\\\begin" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
      NSRange range = capturedRanges[0];
      [tags addObject:@{@"start" : @YES, @"range" : @(range.location)}];
    }];
    
    [someText enumerateStringsMatchedByRegex:@"\\\\end" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
      NSRange range = capturedRanges[0];
      [tags addObject:@{@"start" : @NO, @"range" : @(range.location)}];
    }];
  }
  
  NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES];
  [tags sortUsingDescriptors:@[descriptor]];
  
  return [NSArray arrayWithArray:tags];
}

// Find the next closing start tag in the given text. Here 'closing' means that we ignore
// start/end pairs until we come to the next stand-alone start tag.
- (void) findEndTagInText:(NSString*)someText fromFoldingTags:(NSArray*)foldingTags
{
//  NSLog(@"Finding end tag for %@", self);
//  NSLog(@"%@", foldingTags);
//  NSLog(@"%@", someText);

  NSArray *tags = [self dictionaryOfTagsForText:someText];
  
  // process start/end arrays
  NSInteger count = 0;
  for (NSDictionary *tag in tags) {
    if ([tag[@"start"] boolValue] == YES) {
      count++;
    } else {
      count--;
    }
    if (count == 0) {
      self.endIndex = [tag[@"range"] integerValue];
      NSAttributedString *astr = [[NSAttributedString alloc] initWithString:someText];
      NSArray *lineNumbers = [astr lineNumbersForTextRange:NSMakeRange(self.endIndex, 0) startIndex:self.startIndex startLine:self.startLine];
      if ([lineNumbers count] == 0) {
        self.endLine = self.startLine;
      } else {
        MHLineNumber *lineNumber = lineNumbers[0];
        self.endLine = lineNumber.number;
      }
      break;
    }
  }

}

// Find the next closing end tag in the given text. Here 'closing' means that we ignore
// start/end pairs until we come to the next stand-alone end tag.
- (void) findStartTagInText:(NSString*)someText fromFoldingTags:(NSArray*)foldingTags
{
  //  NSLog(@"Finding end tag for %@", self);
  
  NSArray *tags = [self dictionaryOfTagsForText:someText];
  
//  NSLog(@"Tags: %@", tags);
  
  // process start/end arrays
  NSInteger count = 0;
  for (NSDictionary *tag in tags) {
    if ([tag[@"start"] boolValue] == YES) {
      count--;
    } else {
      count++;
    }
//    NSLog(@"   count %ld", count);
    if (count == 0) {
      self.startIndex = [tag[@"range"] integerValue];

      // get line number
      NSAttributedString *astr = [[NSAttributedString alloc] initWithString:someText];
      // get the line number for this tag
      NSArray *lineNumbers = [astr lineNumbersForTextRange:NSMakeRange(self.startIndex, 0) startIndex:0 startLine:1];
      if ([lineNumbers count] == 0) {
        self.startLine = self.endLine;
      } else {
        MHLineNumber *lineNumber = lineNumbers[0];
        self.startLine = lineNumber.number;
      }
      
      // move start index to end of the \begin{} phrase
      NSRange lineRange = [someText lineRangeForRange:NSMakeRange(self.startIndex, 0)];
      NSString *line = [someText substringWithRange:lineRange];
      NSInteger loc = 0;
      NSString *arg = [line parseArgumentStartingAt:&loc];
      if (arg == nil) {
        // this shouldn't happen, this means a bad tag
        self.startIndex = NSNotFound;
        return;
      }
      
      self.startIndex += loc+1;
      
      break;
    }
  }
}

@end
