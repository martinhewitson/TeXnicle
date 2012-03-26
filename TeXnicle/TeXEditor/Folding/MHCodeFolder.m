//
//  MHCodeFolder.m
//  TeXEditor
//
//  Created by Martin Hewitson on 01/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHCodeFolder.h"
#import "MHFoldingTagDescription.h"
#import "NSString+Extension.h"

@implementation MHCodeFolder

@synthesize startLine;
@synthesize endLine;
@synthesize startIndex;
@synthesize endIndex;
@synthesize folded;
@synthesize foldedText;
@synthesize startRect;
@synthesize endRect;
@synthesize startTrackingRect;
@synthesize endTrackingRect;
@synthesize tag;
@synthesize lineCount;


+ (MHCodeFolder*) codeFolderWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex startLine:(NSInteger)startLine endLine:(NSInteger)endLine tag:(MHFoldingTagDescription*)aTag
{
  return [[[MHCodeFolder alloc] initWithStartIndex:startIndex endIndex:endIndex startLine:startLine endLine:endLine tag:(MHFoldingTagDescription*)aTag] autorelease];
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


- (void)dealloc
{
  self.tag = nil;
  [super dealloc];
}


- (BOOL) isValid
{
  if (self.startLine==NSNotFound || self.startIndex==NSNotFound || self.endLine==NSNotFound || self.endIndex==NSNotFound) {
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
  return [NSString stringWithFormat:@"%d: lines: %d:%d (%d), range: %d,%d (%@ -> %@)", self.folded, self.startLine, self.endLine, self.lineCount, self.startIndex, self.endIndex, self.startRect, self.endRect];
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

// Find the next closing start tag in the given text. Here 'closing' means that we ignore
// start/end pairs until we come to the next stand-alone start tag.
- (void) findEndTagInText:(NSString*)someText fromFoldingTags:(NSArray*)foldingTags
{
//  NSLog(@"Finding end tag for %@", self);
  
  MHFoldingTagDescription *tagFound = nil;
  NSString *line = nil;
  NSRange lineRange;
  NSInteger idx = NSMaxRange([someText lineRangeForRange:NSMakeRange(self.startIndex, 0)]);
  NSInteger matched;
  NSInteger tagCount = 1;
  NSInteger lineNumber = self.startLine+1;
  NSInteger tagIndex;
//  NSLog(@"Starting search from index %ld", idx);
  while (idx < [someText length]) {
    lineRange = [someText lineRangeForRange:NSMakeRange(idx, 0)];
    line = [someText substringWithRange:lineRange];
//    NSLog(@"Checking line %@", line);
    // check for tag
    tagIndex = 0;
    tagFound = [MHFoldingTagDescription foldingTagInLine:line atIndex:&tagIndex fromTags:foldingTags matched:&matched];
    if (tagFound) {
      if (![line containsCommentCharBeforeIndex:tagIndex]) {
        if (matched == MHFoldingTagStartMatched) {
          tagCount++;
          //        NSLog(@"  Found start tag");
        } else {
          tagCount--;
          //        NSLog(@"  Found end tag");
        }
        if (tagCount==0) {
          //        NSLog(@"  Found matching end tag");
          self.endIndex = lineRange.location+tagFound.index;
          self.endLine = lineNumber;
          break;
        }
      }
    }
    
    idx = NSMaxRange(lineRange);
    lineNumber++;
  }
}

// Find the next closing end tag in the given text. Here 'closing' means that we ignore
// start/end pairs until we come to the next stand-alone end tag.
- (void) findStartTagInText:(NSString*)someText fromFoldingTags:(NSArray*)foldingTags
{
  //  NSLog(@"Finding end tag for %@", self);
  
  MHFoldingTagDescription *tagFound = nil;
  NSString *line = nil;
  NSRange lineRange = [someText lineRangeForRange:NSMakeRange(self.endIndex, 0)];
  NSInteger idx = lineRange.location-1;
  NSInteger matched;
  NSInteger tagCount = 1;
  NSInteger lineNumber = self.endLine-1;
  NSInteger tagIndex;
  while (idx >= 0) {
    lineRange = [someText lineRangeForRange:NSMakeRange(idx, 0)];
    line = [someText substringWithRange:lineRange];
    //    NSLog(@"Checking line %@", line);
    // check for tag
    tagIndex = 0;
    tagFound = [MHFoldingTagDescription foldingTagInLine:line atIndex:&tagIndex fromTags:foldingTags matched:&matched];
    if (tagFound) {
      if (![line containsCommentCharBeforeIndex:tagIndex]) {
        if (matched == MHFoldingTagStartMatched) {
          tagCount--;
          //        NSLog(@"  Found start tag");
        } else {
          tagCount++;
          //        NSLog(@"  Found end tag");
        }
        if (tagCount==0) {
          //        NSLog(@"  Found matching end tag");
          self.startIndex = lineRange.location+tagIndex;
          self.startLine = lineNumber;
          break;
        }
      }
    }
    
    idx = lineRange.location-1;
    lineNumber--;
  }
}

@end
