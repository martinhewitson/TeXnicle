//
//  ProjectEntity.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileEntity;
@class Settings;

@interface ProjectEntity : NSManagedObject {

}

@property (assign) NSString *name;
@property (assign) NSString *folder;
@property (assign) NSSet *items;
@property (copy) NSString *type;
@property (assign) Settings *settings;


- (FileEntity*)fileWithPath:(NSString*)aPath;
- (FileEntity*)fileWithPathOnDisk:(NSString*)aPath;

- (NSArray*)folders;

@end
