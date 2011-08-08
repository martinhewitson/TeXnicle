//
//  Bookmark.m
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "Bookmark.h"
#import "FileEntity.h"


@implementation Bookmark
@dynamic linenumber;
@dynamic parentFile;

+ (Bookmark*)bookmarkWithLinenumber:(NSInteger)aLinenumber inFile:(FileEntity*)aFile inManagedObjectContext:(NSManagedObjectContext*)aMOC
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:aMOC];
  Bookmark *bookmark = [[NSManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:aMOC];
  bookmark.linenumber = [NSNumber numberWithInteger:aLinenumber];
  bookmark.parentFile = aFile;
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

@end
