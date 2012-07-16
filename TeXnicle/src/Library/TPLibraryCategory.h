//
//  TPLibraryCategory.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TPLibraryEntry;

@interface TPLibraryCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) NSNumber *sortIndex;

@end

@interface TPLibraryCategory (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(TPLibraryEntry *)value;
- (void)removeEntriesObject:(TPLibraryEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;
@end
