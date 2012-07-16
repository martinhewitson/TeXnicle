//
//  TPLibraryEntry+NSDictionary.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPLibraryEntry+NSDictionary.h"
#import "TPLibraryCategory.h"

@implementation TPLibraryEntry (NSDictionary)

+ (TPLibraryEntry*)entryWithDictionary:(NSDictionary*)dictionary inCategory:(TPLibraryCategory*)category inManagedObjectContext:(NSManagedObjectContext*)aMoc
{
  
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:aMoc];
  TPLibraryEntry *entry = [[TPLibraryEntry alloc] initWithEntity:desc insertIntoManagedObjectContext:aMoc];
 
  // set values
  entry.command = [dictionary valueForKey:@"Command"];
  entry.imageIsValid = [dictionary valueForKey:@"validImage"];
  entry.isBuiltIn = [dictionary valueForKey:@"BuiltIn"];
  entry.uuid = [dictionary valueForKey:@"UUID"];
  entry.code = [dictionary valueForKey:@"Code"];
  entry.image = [dictionary valueForKey:@"Image"];
  
  // add to category
  [category addEntriesObject:entry];
  
  return [entry autorelease];
}

@end
