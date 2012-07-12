//
//  TPFileEntityMetadata.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileEntity.h"

@interface TPFileEntityMetadata : NSObject {
  NSArray *sections;
  NSDate *lastUpdateOfSections;
  FileEntity *parent;
  dispatch_queue_t queue;
}

@property (assign) FileEntity *parent;
@property (retain) NSArray *sections;
@property (retain) NSDate *lastUpdateOfSections;

- (id) initWithParent:(FileEntity*)aFile;
- (NSArray*)updateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force;
- (void) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force;

@end
