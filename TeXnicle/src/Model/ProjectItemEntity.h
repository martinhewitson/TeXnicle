//
//  ProjectItemEntity.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectEntity.h"

@interface ProjectItemEntity : NSManagedObject {

	BOOL isLeaf;
	BOOL isManaged;
	BOOL isUnderProject;
	BOOL hasEdits;
  BOOL _isSelected;
}

@property (assign) BOOL isExpanded;
@property (assign) BOOL isSelected;
@property (assign) NSString *name;
@property (assign) NSString *filepath;
@property (assign) NSNumber *sortIndex;

@property (assign) NSSet *children;
@property (assign) ProjectItemEntity *parent;
@property (assign) ProjectEntity *project;

@property (readonly) NSString *pathRelativeToProject;
@property (readonly) NSString *projectPath;
@property (readonly) NSString *pathOnDisk;
@property (readonly) NSString *shortName;
@property (readonly) BOOL existsOnDisk;
@property (readonly) BOOL isLeaf;
@property (readonly) BOOL isManaged;
@property (readonly) BOOL isUnderProject;
@property (readwrite) BOOL hasEdits;

- (BOOL) isUnderPath:(NSString*)aPath;
//- (BOOL) hasEdits;

@end
