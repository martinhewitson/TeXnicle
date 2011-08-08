//
//  Bookmark.h
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FileEntity;

@interface Bookmark : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * linenumber;
@property (nonatomic, retain) FileEntity *parentFile;
@property (nonatomic, copy) NSString * text;


+ (Bookmark*)bookmarkWithLinenumber:(NSInteger)aLinenumber inFile:(FileEntity*)aFile inManagedObjectContext:(NSManagedObjectContext*)aMOC;
+ (Bookmark*)bookmarkWithLinenumber:(NSInteger)aLinenumber inArray:(NSArray*)bookmarks;

@end
