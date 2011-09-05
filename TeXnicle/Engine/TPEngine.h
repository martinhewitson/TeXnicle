//
//  TPEngine.h
//  TeXnicle
//
//  Created by Martin Hewitson on 24/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TPEngineDelegate <NSObject>

-(void)compileDidFinish:(BOOL)success;

@end

@interface TPEngine : NSObject {
@private
  // Typesetting
	NSTask *typesetTask;
	NSFileHandle *typesetFileHandle;
	int compilationsDone;
	BOOL abortCompile;
  BOOL compiling;
}

@property (assign) id<TPEngineDelegate> delegate;

@property (copy) NSString *path;
@property (copy) NSString *script;
@property (copy) NSString *name;
@property (copy) NSString *documentPath;
@property (readonly) NSString *compiledDocumentPath;
@property (assign) BOOL doBibtex;
@property (assign) BOOL doPS2PDF;
@property (assign) BOOL openConsole;
@property (assign) NSInteger nCompile;
@property (assign, getter = isBuiltIn) BOOL builtIn;
@property (assign, getter = isCompiling) BOOL compiling;

- (id)initWithPath:(NSString*)aPath;
+ (TPEngine*)engineWithPath:(NSString*)aPath;
- (void) setupObservers;



- (BOOL) compileDocumentAtPath:(NSString*)documentPath workingDirectory:(NSString*)workingDir isProject:(BOOL)isProject;
- (void) texOutputAvailable:(NSNotification*)aNote;
- (void) taskFinished:(NSNotification*)aNote;
- (void) reset;
- (void) trashAuxFiles;

@end
