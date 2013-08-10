//
//  Bookmark.m
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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

#import "Bookmark.h"
#import "FileEntity.h"
#import "NSAttributedString+LineNumbers.h"
#import "MHLineNumber.h"
#import "externs.h"
#import "FileDocument.h"
#import "TPThemeManager.h"

@implementation Bookmark
@dynamic linenumber;
@dynamic parentFile;
@dynamic text;

- (void) awakeFromFetch
{
  [self observeTextStorage];
}

+ (Bookmark*)bookmarkWithLinenumber:(NSInteger)aLinenumber inFile:(FileEntity*)aFile inManagedObjectContext:(NSManagedObjectContext*)aMOC
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:aMOC];
  Bookmark *bookmark = [[Bookmark alloc] initWithEntity:desc insertIntoManagedObjectContext:aMOC];
  bookmark.linenumber = @(aLinenumber);
  bookmark.parentFile = aFile;
  
  // extract text
  [bookmark updateText];
  
  // look for changes
  [bookmark observeTextStorage];
  
  return bookmark;
}
        
        
- (void) observeTextStorage
{
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(handleTextChanged:) 
                                               name:TPFileItemTextStorageChangedNotification 
                                             object:self.parentFile];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) handleTextChanged:(NSNotification*)aNote
{
  [self updateText];
}

- (void) updateText
{
  NSMutableAttributedString *aStr = [[[self.parentFile document] textStorage] mutableCopy];
  NSArray *lineNumbers = [aStr lineNumbersForTextRange:NSMakeRange(0, [aStr length])];
  MHLineNumber *matchingLine = nil;
  for (MHLineNumber *line in lineNumbers) {
    if (line.number == [self.linenumber integerValue]) {
      matchingLine = line;
      break;
    }
  }
  
  if (matchingLine) {
    self.text = [[aStr string] substringWithRange:matchingLine.range];
    // notify anyone interested that there were edits
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TPBookmarkDidUpdateNotification object:self userInfo:nil];
  }
  
}

+ (Bookmark*)bookmarkWithLinenumber:(NSInteger)aLinenumber inArray:(NSArray*)bookmarks
{
  for (Bookmark *b in bookmarks) {
    if ([b.linenumber integerValue] == aLinenumber) {
      return b;
    }
  }
  return nil;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%ld: %@", [self.linenumber integerValue], self.text];
}

- (NSString*) lineNumberString
{
  return [NSString stringWithFormat:@"line %ld ", [self.linenumber integerValue]];
}

- (NSAttributedString*)selectedDisplayString
{
  NSString *lineNumberString = [self lineNumberString];  
  NSMutableAttributedString *att = [[self displayString] mutableCopy]; 
  [att addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [lineNumberString length])];
  [att addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange([lineNumberString length], [att length]-[lineNumberString length])];
  if ([self.text length]==0) {
    [att addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange([lineNumberString length], [att length]-[lineNumberString length])];
  }
  return att;
}

- (NSAttributedString*)simpleDisplayString
{
  
  
  NSString *text = [[self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  if ([text length]==0) {
    text = @"<blank>";
  }
  if ([text length]>50) {
    text = [[text substringToIndex:50] stringByAppendingString:@"..."];
  }
  
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:text];
  
  // set paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];
  [att addAttribute:NSParagraphStyleAttributeName
              value:ps
              range:NSMakeRange(0, [att length])];
  
  // set font
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  NSFont *font = theme.navigatorFont;
  [att addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [att length])];
  
  return att;
}

- (NSAttributedString*)displayString
{
  
  
  NSString *text = [[self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  if ([text length]==0) {
    text = @"<blank>";
  }
  if ([text length]>50) {
    text = [[text substringToIndex:50] stringByAppendingString:@"..."];
  }
  
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:text]; 
  
  NSString *lineNumberString = [self lineNumberString];
  NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:lineNumberString];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [str length])];
  [str appendAttributedString:att];
  
  // set paragraph
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];
  [str addAttribute:NSParagraphStyleAttributeName
              value:ps
              range:NSMakeRange(0, [str length])];
  
  if ([self.text length]==0) {
    [str addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange([lineNumberString length], [str length]-[lineNumberString length])];
  }
  
  // set font
  TPThemeManager *tm = [TPThemeManager sharedManager];
  TPTheme *theme = tm.currentTheme;
  NSFont *font = theme.navigatorFont;
  [str addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [str length])];
  
  return str;
}



@end
