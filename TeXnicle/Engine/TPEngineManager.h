//
//  TPEngineManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 24/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPEngine.h"
#import "MHConsoleManager.h"

extern NSString * const TPEngineCompilingCompletedNotification;

@protocol TPEngineManagerDelegate <NSObject>
-(NSString*)engineName;
-(NSNumber*)doBibtex;
-(NSNumber*)doPS2PDF;
-(NSNumber*)openConsole;
-(NSNumber*)nCompile;
-(NSString*)documentToCompile;
-(NSString*)workingDirectory;
@end

@interface TPEngineManager : NSObject <TPEngineDelegate> {
@private
  MHConsoleManager *consoleManager;
  id<TPEngineManagerDelegate> delegate;
  NSMutableArray *engines;
}

@property (assign) id<TPEngineManagerDelegate> delegate;
@property (retain) NSMutableArray *engines;
@property (retain) MHConsoleManager *consoleManager;

- (id)initWithDelegate:(id<TPEngineManagerDelegate>)aDelegate;
+ (TPEngineManager*)engineManagerWithDelegate:(id<TPEngineManagerDelegate>)aDelegate;
- (void)loadEngines;

- (BOOL)registerConsole:(id<MHConsoleViewer>)aViewer;

+(NSArray*)builtinEngineNames;
+ (NSString*)engineDir;
+ (void) installEngines;

- (TPEngine*)engineNamed:(NSString*)name;
- (NSInteger)indexOfEngineNamed:(NSString*)name;
- (NSArray*)registeredEngineNames;

- (BOOL) isCompiling;
- (void) compile;
- (void) trashAuxFiles;

@end
