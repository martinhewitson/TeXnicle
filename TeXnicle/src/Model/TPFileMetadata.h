//
//  TPFileMetaData.h
//  TeXnicle
//
//  Created by Martin Hewitson on 23/3/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSyntaxChecker.h"

@class TPMetadataOperation;
@class TPFileMetadata;

@protocol FileMetadataDelegate <NSObject>

- (void) fileMetadataDidUpdate:(TPFileMetadata*)file;

@end

@interface TPFileMetadata : NSObject <FileMetadataDelegate, SyntaxCheckerDelegate>


// properties
@property (strong) NSManagedObjectID *objId;
@property (copy) NSString *name;
@property (copy) NSString *extension;
@property (copy) NSString *text;
@property (copy) NSString *pathOnDisk;
@property (copy) NSString *projectPath;

// products
@property (strong) NSArray *userNewCommands;
@property (strong) NSArray *citations;
@property (strong) NSArray *labels;
@property (strong) NSArray *syntaxErrors;
@property (strong) NSArray *sections;

@property (assign) BOOL needsUpdate;
@property (assign) BOOL needsSyntaxCheck;
@property (assign) BOOL wasScannedForSections;
@property (strong) NSDate *lastUpdate;

@property (assign) id<FileMetadataDelegate> delegate;

- (id) initWithParentId:(NSManagedObjectID*)objId extension:(NSString*)ext text:(NSString*)text path:(NSString*)pathOnDisk projectPath:(NSString*)pathRelativeToProject name:(NSString*)aName;
- (void) updateMetadata;
- (void) tearDown;

- (NSArray*) generateSectionsForTypes:(NSArray*)templates files:(NSArray*)otherFiles forceUpdate:(BOOL)force;

@end
