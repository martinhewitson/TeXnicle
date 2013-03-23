//
//  TPFileMetaData.h
//  TeXnicle
//
//  Created by Martin Hewitson on 23/3/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPMetadataOperation;
@class TPFileMetadata;

@protocol FileMetadataDelegate <NSObject>

- (void) fileMetadataDidUpdate:(TPFileMetadata*)file;

@end

@interface TPFileMetadata : NSObject <FileMetadataDelegate>

@property (strong) NSOperationQueue* aQueue;
@property (strong) TPMetadataOperation *currentOperation;

// properties
@property (strong) NSManagedObjectID *objId;
@property (copy) NSString *name;
@property (copy) NSString *extension;
@property (copy) NSString *text;
@property (copy) NSString *pathOnDisk;

// products
@property (strong) NSArray *userNewCommands;
@property (strong) NSArray *citations;
@property (strong) NSArray *labels;

@property (assign) BOOL needsUpdate;
@property (strong) NSDate *lastUpdate;

@property (assign) id<FileMetadataDelegate> delegate;

- (id) initWithParentId:(NSManagedObjectID*)objId extension:(NSString*)ext text:(NSString*)text path:(NSString*)pathOnDisk;
- (void) updateMetadata;

@end
