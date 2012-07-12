//
//  TPFileEntityMetadata.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPFileEntityMetadata;

@protocol TPFileEntityMetadataDelegate <NSObject>

- (NSString*) text;

@end

@interface TPFileEntityMetadata : NSObject {
  NSArray *sections;
  NSDate *lastUpdateOfSections;
  id parent;
  dispatch_queue_t queue;
}

@property (assign) id parent;
@property (retain) NSArray *sections;
@property (retain) NSDate *lastUpdateOfSections;

- (id) initWithParent:(id)aFile;
- (NSArray*)updateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force;
- (void) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force;

@end
