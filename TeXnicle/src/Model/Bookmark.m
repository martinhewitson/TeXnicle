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
  return [NSString stringWithFormat:@"Line %d: %@", [self.linenumber integerValue], self.text];
}

@end
