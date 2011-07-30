//
//  FolderEntity.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "FolderEntity.h"


@implementation FolderEntity

- (BOOL) isLeaf
{
	return NO;
}

- (NSString*) pathOnDisk
{
	// If the projectpath maps to a folder on disk, we can return
	// that path, otherwise nil.
	NSString *projectPath = [self projectPath];	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir = NO;
	if ([fm fileExistsAtPath:projectPath isDirectory:&isDir]) {
		if (isDir) {
			return projectPath;
		}
	}
	
	return nil;
}

- (NSString*) projectPath
{
	ProjectEntity *project = [self valueForKey:@"project"];
	// try to make the folder on disk		
	NSString *projectRoot = [project valueForKey:@"folder"];
//	NSLog(@"Got project root: %@", projectRoot);
	
	NSString *relativePath = [self valueForKey:@"name"];
	NSManagedObject *parent = [self valueForKey:@"parent"];
//	NSLog(@"Starting from parent %@", parent);
	while (parent != nil) {
		relativePath = [[parent valueForKey:@"name"] stringByAppendingPathComponent:relativePath];
		parent = [parent valueForKey:@"parent"];
	}
	
	NSString *folderRoot = [projectRoot stringByAppendingPathComponent:relativePath];
	return folderRoot;
}
//
//- (void) setFilepath:(NSString *)aPath
//{
//	[self willChangeValueForKey:@"filepath"];
//	
//	// make sure that this path is always relative to the project
//	NSString *projectFolder = [[self project] valueForKey:@"folder"];
//	NSString *relativePath = [projectFolder relativePathTo:aPath];
//	
//	[self setPrimitiveValue:relativePath forKey:@"filepath"];
//	[self didChangeValueForKey:@"filepath"];
//	NSLog(@"Set filepath: %@", self.filepath);
//}

@end
