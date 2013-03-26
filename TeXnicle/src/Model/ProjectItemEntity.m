//
//  ProjectItemEntity.m
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


- (void) awakeFromInsert
{
	[self setValue:@NO forKey:@"isLeaf"];
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
//	NSURL *fileURL = [NSURL fileURLWithPath:path];
  if (!path) {
    return nil;
  }
	return [path stringByStandardizingPath];
}

- (BOOL) existsOnDisk
{
	NSFileManager *fm = [NSFileManager defaultManager];
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
//  NSLog(@"Resetting file path to %@", [self pathRelativeToProject]);
  self.filepath = [self pathRelativeToProject];
  
  // handle children
  for (ProjectItemEntity *child in self.children) {
    [child resetFilePath];
  }
}

- (void) setFilepath:(NSString *)aPath
{
	[self willChangeValueForKey:@"filepath"];
		
	// make sure that this path is always relative to the project
	NSString *projectFolder = [[[self project] valueForKey:@"folder"] stringByAppendingPathComponent:@"."];
	NSString *relativePath = [projectFolder relativePathTo:[aPath stringByStandardizingPath]];
	
	[self setPrimitiveValue:relativePath forKey:@"filepath"];
	[self didChangeValueForKey:@"filepath"];
//	NSLog(@"Set filepath: %@", self.filepath);
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
