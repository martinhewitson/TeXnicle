//
//  Bookmark.m
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "Bookmark.h"
#import "FileEntity.h"
#import "NSAttributedString+LineNumbers.h"
#import "MHLineNumber.h"

@implementation Bookmark
@dynamic linenumber;
@dynamic parentFile;
@dynamic text;
@synthesize selectedDisplayString;
@synthesize displayString;

+ (Bookmark*)bookmarkWithLinenumber:(NSInteger)aLinenumber inFile:(FileEntity*)aFile inManagedObjectContext:(NSManagedObjectContext*)aMOC
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:aMOC];
  Bookmark *bookmark = [[NSManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:aMOC];
  bookmark.linenumber = [NSNumber numberWithInteger:aLinenumber];
  bookmark.parentFile = aFile;
  
  // extract text
  NSMutableAttributedString *aStr = [[[aFile document] textStorage] mutableCopy];
  NSArray *lineNumbers = [aStr lineNumbersForTextRange:NSMakeRange(0, [aStr length])];
  MHLineNumber *matchingLine = nil;
  for (MHLineNumber *line in lineNumbers) {
    if (line.number == aLinenumber) {
      matchingLine = line;
      break;
    }
  }
  
  if (matchingLine) {
    bookmark.text = [[aStr string] substringWithRange:matchingLine.range];
  }
  
  return [bookmark autorelease];
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
  return [NSString stringWithFormat:@"%d: %@", [self.linenumber integerValue], self.text];
}

- (NSString*) lineNumberString
{
  return [NSString stringWithFormat:@"line %d ", [self.linenumber integerValue]];
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

- (NSAttributedString*)displayString
{
  
  NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [ps setLineBreakMode:NSLineBreakByTruncatingTail];  
  
  NSString *text = self.text;
  if ([text length]==0) {
    text = @"<blank>";
  }
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] initWithString:text] autorelease]; 
  
  NSString *lineNumberString = [self lineNumberString];
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:lineNumberString] autorelease];
  [str addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [str length])];
  [str appendAttributedString:att];
  [str addAttribute:NSParagraphStyleAttributeName
              value:ps
              range:NSMakeRange(0, [str length])];
  
  if ([self.text length]==0) {
    [str addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange([lineNumberString length], [str length]-[lineNumberString length])];
  }
  return str;
}

@end
