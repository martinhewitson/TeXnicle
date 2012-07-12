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
- (NSString*) textForFile:(id)aFile;
- (id) fileWithPath:(NSString*)path;
- (void) didComputeNewSections;

@end

@interface TPOutlineBuilder : NSObject {
  id<TPOutlineBuilderDelegate> delegate;
  TPSection *outline;
  NSArray *templates;
  NSArray *sectionCommands;
  NSMutableArray *sections;
  NSTimer *timer;
  NSInteger depth;
}

@property (assign) NSInteger depth;
@property (retain) NSTimer *timer;
@property (assign) id<TPOutlineBuilderDelegate> delegate;
@property (retain) NSArray *templates;
@property (retain) NSArray *sectionCommands;
@property (retain) NSMutableArray *sections;

+ (id) outlineBuilderWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate;
- (id) initWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate;

- (void) buildOutline;
- (void) startTimer;
- (void) stopTimer;

- (NSArray*) childrenOfSection:(id)parent;
@end
