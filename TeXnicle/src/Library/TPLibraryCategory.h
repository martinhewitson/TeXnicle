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

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet *entries;
@property (nonatomic, strong) NSNumber *sortIndex;

@end

@interface TPLibraryCategory (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(TPLibraryEntry *)value;
- (void)removeEntriesObject:(TPLibraryEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;
@end
