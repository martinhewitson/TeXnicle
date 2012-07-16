//
//  TPLibraryEntry+NSDictionary.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPLibraryEntry.h"

@interface TPLibraryEntry (NSDictionary)

+ (TPLibraryEntry*)entryWithDictionary:(NSDictionary*)dictionary inCategory:(TPLibraryCategory*)category inManagedObjectContext:(NSManagedObjectContext*)aMoc;

@end
