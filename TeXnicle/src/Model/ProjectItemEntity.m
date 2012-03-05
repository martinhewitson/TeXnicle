//
//  ProjectItemEntity.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "ProjectItemEntity.h"
#import "NSString+RelativePath.h"

@implementation ProjectItemEntity

@synthesize isSelected = _isSelected;

@dynamic isExpanded;
@dynamic name;
@dynamic filepath;
@dynamic sortIndex;

@dynamic children;
@dynamic parent;
@dynamic project;

@dynamic shortName;
@dynamic projectPath;
@dynamic pathOnDisk;

@synthesize hasEdits;


//- (NSSet *)children;
//{
//  [self willAccessValueForKey:@"children"];
//  NSMutableSet *filteredItems = [self primitiveValueForKey:@"children"]; // they should be mutable already
//  [filteredItems filterUsingPredicate:[NSPredicate predicateWithFormat:@"parent == nil"]];
//  [self didAccessValueForKey:@"children"];
//  return filteredItems;
//}

- (void) awakeFromInsert
{
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"isLeaf"];
	[self setValue:[self project] forKey:@"project"];
}

- (NSString*) shortName
{
	if ([self valueForKey:@"filepath"]) {
		return [[self valueForKey:@"filepath"] lastPathComponent];
	}
	
	return [self valueForKey:@"name"];
//	return [[self valueForKey:@"name"] stringByAppendingPathExtension:[self valueForKey:@"extension"]];
}

- (NSString*) projectPath
{
	ProjectEntity *project = [self valueForKey:@"project"];
	NSString *projectRoot = [project valueForKey:@"folder"];
	NSString *folderRoot = [projectRoot stringByAppendingPathComponent:[self pathRelativeToProject]];
  return folderRoot;
}

- (NSString*)pathRelativeToProject
{
  NSString *relativePath = [self valueForKey:@"name"];
	NSManagedObject *parent = [self valueForKey:@"parent"];
  //	NSLog(@"Starting from parent %@", parent);
	while (parent != nil) {
		relativePath = [[parent valueForKey:@"name"] stringByAppendingPathComponent:relativePath];
		parent = [parent valueForKey:@"parent"];
	}
  return relativePath;
}

- (NSManagedObject *)project
{
	[self willAccessValueForKey:@"project"];
	id proj = [self primitiveValueForKey:@"project"];
	[self didAccessValueForKey:@"project"];
	
	if (proj)
		return proj;
	
	// otherwise we need to pull the project from the managed object context
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *fetchError = nil;
	NSArray *fetchResults;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project"
																						inManagedObjectContext:moc];
	
	[fetchRequest setEntity:entity];
	fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
	
	if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil)) {
		ProjectEntity *mocproject = [fetchResults objectAtIndex:0];
		[fetchRequest release];
		return mocproject;
	}
	
	if (fetchError != nil) {
		[NSApp presentError:fetchError];
	} else {
		// should present custom error message...
	}
	[fetchRequest release];	

	return proj;
}



- (NSString*)pathOnDisk
{
	ProjectEntity *project = [self project];
	NSString *projectFolder = [project valueForKey:@"folder"];
  if (!projectFolder) {
    return nil;
  }
	NSString *fpath = [self valueForKey:@"filepath"];
	if (!fpath) {
		return nil; 
	}
	NSString *path =  [projectFolder stringByAppendingPathComponent:fpath];
	NSURL *fileURL = [NSURL fileURLWithPath:path];
  if (!fileURL) {
    return nil;
  }
	return [[fileURL standardizedURL] path];
}

- (BOOL) existsOnDisk
{
//	NSString *projectFolder = [[self project] valueForKey:@"folder"];
//	NSString *projectFolder = [[self projectPath] stringByDeletingLastPathComponent];
	NSFileManager *fm = [NSFileManager defaultManager];
//	if ([fm fileExistsAtPath:[projectFolder stringByAppendingPathComponent:[self valueForKey:@"filepath"]]]) {
	if ([fm fileExistsAtPath:[self valueForKey:@"pathOnDisk"]]) {
		return YES;
	}
	return NO;
}

- (BOOL) hasEdits
{
	return NO;
}


- (void) resetFilePath
{
}

- (void) setFilepath:(NSString *)aPath
{
	[self willChangeValueForKey:@"filepath"];
		
	// make sure that this path is always relative to the project
	NSString *projectFolder = [[[self project] valueForKey:@"folder"] stringByAppendingPathComponent:@"."];
	NSString *relativePath = [projectFolder relativePathTo:aPath];
	
	[self setPrimitiveValue:relativePath forKey:@"filepath"];
	[self didChangeValueForKey:@"filepath"];
	//NSLog(@"Set filepath: %@", self.filepath);
}

- (BOOL) isLeaf
{
	return NO;
}

- (BOOL) isManaged
{	
	return NO;
}


- (BOOL) isUnderProject
{
	NSString *ppath = [[self project] valueForKey:@"folder"];
	return [self isUnderPath:ppath];
}

- (BOOL) isUnderPath:(NSString*)aPath
{
	NSString *tpath = [aPath stringByStandardizingPath];
	NSString *fpath = [self valueForKey:@"pathOnDisk"];
	// standardize this url
//	NSURL *fileURL = [NSURL fileURLWithPath:fpath];
	//NSLog(@"Checking if %@ \n\tis under %@", fpath, tpath);
	if ([fpath compare:tpath options:NSLiteralSearch range:NSMakeRange(0, [tpath length])] == NSOrderedSame) {
		//NSLog(@"  YES!!");
		return YES;
	}
	//NSLog(@"  NO!!");
	
	return NO;
}

- (void) setIsSelected:(BOOL)isSelected
{
  _isSelected = isSelected;
  
  // if deselecting, deselect children
  if (!_isSelected) {
    for (ProjectItemEntity *child in self.children) {
      child.isSelected = _isSelected;
    }
  }
  
  // if selecting, select parent
  if (_isSelected) {
    self.parent.isSelected = _isSelected;
  }
  
}


@end
