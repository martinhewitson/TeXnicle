//
//  ProjectEntity.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import "ProjectEntity.h"
#import "FileEntity.h"
#import "Settings.h"
#import "UISettings.h"
#import "NSString+Comparisons.h"

@implementation ProjectEntity

@dynamic name;
@dynamic folder;
@dynamic items;
@dynamic type;
@dynamic settings;
@dynamic selected;
@dynamic mainFile;
@dynamic uiSettings;

- (void) awakeFromInsert
{
//	NSLog(@"Inserted project");
  self.type = @"PDFLaTeX";
  [self createSettings];
}

- (void) createSettings
{
  if (self.settings == nil) {
    // make new settings
    NSEntityDescription *settingsDescription = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    Settings *newSettings = [[Settings alloc] initWithEntity:settingsDescription insertIntoManagedObjectContext:self.managedObjectContext];
    self.settings = newSettings;
//    NSLog(@"Made settings %@", self.settings);
  }
  
  if (self.uiSettings == nil) {
    // make new UI settings
    NSEntityDescription *uiSettingsDescription = [NSEntityDescription entityForName:@"UISettings" inManagedObjectContext:self.managedObjectContext];
    UISettings *newUISettings = [[UISettings alloc] initWithEntity:uiSettingsDescription insertIntoManagedObjectContext:self.managedObjectContext];
    self.uiSettings = newUISettings;
//    NSLog(@"Made UI settings %@", self.uiSettings);
  }
}

- (void) awakeFromFetch
{
//  NSLog(@"Awake from fetch %@", self);
  [self performSelector:@selector(createSettings) withObject:nil afterDelay:0.1];
}


- (NSSet*)items
{
	NSManagedObjectContext *moc = [self managedObjectContext];
  if (moc == nil) {
    return nil;
  }
  
	[self willAccessValueForKey:@"items"];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *fetchError = nil;
	NSArray *fetchResults;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProjectItem"
																						inManagedObjectContext:moc];
		
	[fetchRequest setEntity:entity];
	fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];	
	
	[self didAccessValueForKey:@"items"];
	return [NSSet setWithArray:fetchResults];
}

- (FileEntity*)fileWithPath:(NSString*)aPath
{
  if (aPath == nil || [aPath length] == 0)
    return nil;
  
	NSString *pathToTest = aPath;
	if (![[aPath pathExtension] isEqual:@"tex"]) {
		pathToTest = [aPath stringByAppendingPathExtension:@"tex"];
	}
  pathToTest = [pathToTest stringByStandardizingPath];
  
	for (id item in [self valueForKey:@"items"]) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			FileEntity *file = (FileEntity*)item;
			NSString *fstr = [file valueForKey:@"filepath"];
      if ([fstr isEqualToString:pathToTest]) {
        return file;
      }
		}
	}
	return nil;
}

- (FileEntity*)fileWithPathOnDisk:(NSString*)aPath
{
  if (aPath == nil || [aPath length] == 0)
    return nil;
  
	NSString *pathToTest = aPath;
	if (![aPath pathExtension]) {
		pathToTest = [aPath stringByAppendingPathExtension:@"tex"];
	}
  pathToTest = [pathToTest stringByStandardizingPath];
	
	for (id item in [self valueForKey:@"items"]) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			FileEntity *file = (FileEntity*)item;
			NSString *fstr = [[file pathOnDisk] stringByStandardizingPath];
      if ([fstr isEqualToString:pathToTest]) {
        return file;
      }
		}
	}
	return nil;
}

- (NSArray*)folders
{
  NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *fetchError = nil;
	NSArray *fetchResults;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder"
																						inManagedObjectContext:moc];
	
	[fetchRequest setEntity:entity];
	fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
  
	if (fetchError != nil) {
		[NSApp presentError:fetchError];
    return nil;
	}
  return fetchResults;
}

- (BOOL) hasEdits
{
  for (FileEntity *file in self.items) {
    if ([file hasEdits]) {
      return YES;
    }
  }
  return NO;
}

@end
