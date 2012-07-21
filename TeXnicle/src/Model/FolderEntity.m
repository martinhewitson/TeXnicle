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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
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

- (void) setName:(NSString *)newName
{
	[self willChangeValueForKey:@"name"];
  
	// rename the file on disk, if necessary	
	NSString *oldPath = [self pathOnDisk];
  if (oldPath != nil && self.name != nil && [self existsOnDisk]) {
    
    NSString *newPath = nil;
    
    newPath = [oldPath stringByDeletingLastPathComponent];
    newPath = [newPath stringByAppendingPathComponent:newName];
    
    //	NSLog(@"Renaming %@\nto %@", oldPath, newPath);
    
    if (newPath != nil && ![newPath isEqual:oldPath]) {
      
      // gather a list of children which will need to be updated
      NSMutableArray *childrenToUpdate = [NSMutableArray array];
      for (ProjectItemEntity *item in self.children) {
        if ([item isUnderPath:self.pathOnDisk]) {
          [childrenToUpdate addObject:item];
        }
      }
      
      NSFileManager *fm = [NSFileManager defaultManager];
      NSError *error = nil;
      // If the old file exists, we can move it
      if ([fm fileExistsAtPath:oldPath]) {
        BOOL success = [fm moveItemAtPath:oldPath toPath:newPath error:&error];
        if (success == NO) {
          NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
          [errorDetail setValue:@"Failed to rename folder"
                         forKey:NSLocalizedDescriptionKey];
          NSString *errorDescription = [NSString stringWithFormat:@"Failed to move \u201c%@\u201d to \u201c%@\u201d", oldPath, newPath];
          [errorDetail setValue:errorDescription forKey:NSLocalizedRecoverySuggestionErrorKey];
          error = [NSError errorWithDomain:@"TeXnicle" code:0 userInfo:errorDetail];
          [NSApp presentError:error];
          return;
        }
      }
      
      // set the new filepath
      [self setValue:newPath forKey:@"filepath"];
      
      // update filepaths of all children
      for (ProjectItemEntity *item in childrenToUpdate) {
        [item resetFilePath];
      }
    }    
  }
  
	// now go ahead and rename the item
	[self setPrimitiveValue:newName forKey:@"name"];
	[self didChangeValueForKey:@"name"];
}

@end
