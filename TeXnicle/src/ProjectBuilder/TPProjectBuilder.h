//
//  TPProjectBuilder.h
//  TeXnicle
//
//  Created by Martin Hewitson on 30/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
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
  NSURL *projectFileURL;
}

@property (copy) NSString *projectName;
@property (copy) NSString *projectDir;
@property (copy) NSString *mainfile;
@property (readonly) NSURL *projectFileURL;

+ (TPProjectBuilder*)builderWithDirectory:(NSString*)aPath;
- (id) initWithDirectory:(NSString*)aPath;
+ (TPProjectBuilder*)builderWithMainfile:(NSString*)aFile;
- (id) initWithMainfile:(NSString*)aFile;

+ (NSString*) mainfileForDirectory:(NSString*)aPath;

- (void)populateDocument:(TeXProjectDocument*)aDocument;
- (void)document:(TeXProjectDocument*)aDocument addProjectItemsFromFile:(NSString*)aFile;
- (FolderEntity*) makeFoldersForComponents:(NSArray*)pathComps inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc;
- (FileEntity*) addFileAtPath:(NSString*)fullpath toFolder:(FolderEntity*)folder inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc;

@end
