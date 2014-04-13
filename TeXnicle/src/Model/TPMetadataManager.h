//
//  TPMetadataManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 23/3/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPFileMetadata.h"

@class TPMetadataManager;

@protocol MetadataManagerDelegate <NSObject>

// should return an array of TPFileMetadata objects
- (NSArray*) metadataManagerFilesToScan:(TPMetadataManager*)manager;


@end

@interface TPMetadataManager : NSObject <MetadataManagerDelegate, FileMetadataDelegate>

@property (assign) id<MetadataManagerDelegate> delegate;

- (id) initWithDelegate:(id<MetadataManagerDelegate>)aDelegate;

- (void) start;
- (void) stop;
- (void) tearDown;

@end
