//
//  TPProjectBuilder.h
//  TeXnicle
//
//  Created by Martin Hewitson on 30/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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

#import <Foundation/Foundation.h>
#import "TeXProjectDocument.h"

@class FolderEntity;
@class FileEntity;
@class ProjectEntity;

@interface TPProjectBuilder : NSObject {
@private
  NSString *projectName;
  NSString *projectDir;
  NSString *mainfile;
  NSMutableArray *filesOnDiskList;
  NSMutableAttributedString *reportString;
}

@property (copy) NSString *projectName;
@property (copy) NSString *projectDir;
@property (copy) NSString *mainfile;
@property (unsafe_unretained, readonly) NSURL *projectFileURL;
@property (strong) NSMutableArray *filesOnDiskList;
@property (strong) NSMutableAttributedString *reportString;


+ (TeXProjectDocument*) buildProjectInDirectory:(NSString*)path;

+ (TPProjectBuilder*)builderWithDirectory:(NSString*)aPath;
- (id) initWithDirectory:(NSString*)aPath;
+ (TPProjectBuilder*)builderWithMainfile:(NSString*)aFile;
- (id) initWithMainfile:(NSString*)aFile;

- (void)generateFileList;
- (void)gatherFilesRelativeTo:(NSString*)aPath;
- (NSString*)fileForArgument:(NSString*)arg;

+ (NSString*) mainfileForDirectory:(NSString*)aPath;

- (void)populateDocument:(TeXProjectDocument*)aDocument;
- (void)document:(TeXProjectDocument*)aDocument addProjectItemsFromFile:(NSString*)aFile;
- (FolderEntity*) makeFoldersForComponents:(NSArray*)pathComps inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc;
- (FileEntity*) addFileAtPath:(NSString*)fullpath toFolder:(FolderEntity*)folder inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc;

@end
