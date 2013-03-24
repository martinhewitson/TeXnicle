//
//  TPOutlineBuilder.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSection.h"

@protocol TPOutlineBuilderDelegate <NSObject>

- (id) mainFile;
- (NSArray*) allMetadataFiles;
- (NSString*) textForFile:(id)aFile;
- (void) didComputeNewSections;
- (BOOL) shouldGenerateOutline;

@end

@interface TPOutlineBuilder : NSObject {
@private
  dispatch_queue_t queue;
}

@property (assign) NSInteger depth;
@property (strong) NSTimer *timer;
@property (unsafe_unretained) id<TPOutlineBuilderDelegate> delegate;
@property (strong) NSArray *templates;
@property (strong) NSArray *sectionCommands;
@property (strong) NSMutableArray *sections;

+ (id) outlineBuilderWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate;
- (id) initWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate;

- (void) buildOutline;
- (void) startTimer;
- (void) stopTimer;
- (void) tearDown;

//- (NSArray*) childrenOfSection:(id)parent;
@end
