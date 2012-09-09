//
//  TPLibrary.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPLibraryCategory.h"
#import "TPLibraryEntry.h"

@interface TPLibrary : NSObject



- (IBAction)saveAction:(id)sender;

- (void) updateSortIndices;

- (NSArray*) categories;
- (NSArray*) entriesForCategory:(TPLibraryCategory*)category;
- (TPLibraryCategory*) categoryAtIndex:(NSInteger)index;
- (NSInteger)indexOfCategory:(TPLibraryCategory*)category;
- (TPLibraryCategory*) categoryNamed:(NSString*)name;
- (TPLibraryCategory*) getOrCreateCategoryWithName:(NSString*)name;
- (TPLibraryCategory*) createCategoryWithName:(NSString*)name;
- (void) removeCategory:(TPLibraryCategory*)category;
- (TPLibraryEntry*) clipWithCode:(NSString*)someCode inCategory:(TPLibraryCategory*)category;
- (void) removeEntries:(NSArray*)entriesToDelete;
- (NSArray*) entriesWithDefinedCommands;
- (NSString*) codeForCommand:(NSString*)command;
- (NSArray*)commandsBeginningWith:(NSString*)prefix;
- (void) restoreDefaultLibrary;
- (void) addDefaultCategories;

@end
