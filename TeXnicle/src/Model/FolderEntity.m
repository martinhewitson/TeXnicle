//
//  FolderEntity.m
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

// MOVED TO SUPERCLASS 16-02-2012
//
//- (NSString*) projectPath
//{
//	ProjectEntity *project = [self valueForKey:@"project"];
//	// try to make the folder on disk		
//	NSString *projectRoot = [project valueForKey:@"folder"];
////	NSLog(@"Got project root: %@", projectRoot);
//	
//	NSString *relativePath = [self valueForKey:@"name"];
//	NSManagedObject *parent = [self valueForKey:@"parent"];
////	NSLog(@"Starting from parent %@", parent);
//	while (parent != nil) {
//		relativePath = [[parent valueForKey:@"name"] stringByAppendingPathComponent:relativePath];
//		parent = [parent valueForKey:@"parent"];
//	}
//	
//	NSString *folderRoot = [projectRoot stringByAppendingPathComponent:relativePath];
//	return folderRoot;
//}



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
