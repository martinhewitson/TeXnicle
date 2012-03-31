//
//  TPEngine.h
//  TeXnicle
//
//  Created by Martin Hewitson on 24/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TPEngineDelegate <NSObject>

- (void)compileDidFinish:(BOOL)success;
- (void)enginePostMessage:(NSString*)someText;
- (void)enginePostError:(NSString*)someText;
- (void)enginePostTextForAppending:(NSString*)someText;

@end

@interface TPEngine : NSObject <TPEngineDelegate> {
@private
  // Typesetting
	NSTask *typesetTask;
	NSFileHandle *typesetFileHandle;
  NSPipe *pipe;
	int compilationsDone;
	BOOL abortCompile;
  BOOL compiling;
  NSString *path;
  NSString *script;
  NSString *name;
  NSString *documentPath;
  BOOL doBibtex;
  BOOL doPS2PDF;
  BOOL openConsole;
  NSInteger nCompile;
  BOOL supportsDoBibtex;
  BOOL supportsDoPS2PDF;
  NSInteger supportsNCompile;
  BOOL builtIn;
  id<TPEngineDelegate> delegate;
  NSString *imageIncludeString;
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
@property (assign) BOOL supportsDoBibtex;
@property (assign) BOOL supportsDoPS2PDF;
@property (assign) NSInteger supportsNCompile;
@property (assign, getter = isBuiltIn) BOOL builtIn;
@property (assign, getter = isCompiling) BOOL compiling;
@property (copy) NSString *imageIncludeString;

- (id)initWithPath:(NSString*)aPath;
+ (TPEngine*)engineWithPath:(NSString*)aPath;
+ (NSString*)defaultImageIncludeString;
- (void) setupObservers;



- (BOOL) compileDocumentAtPath:(NSString*)documentPath workingDirectory:(NSString*)workingDir isProject:(BOOL)isProject;
- (void) texOutputAvailable:(NSNotification*)aNote;
- (void) taskFinished:(NSNotification*)aNote;
- (void) reset;
- (void) trashAuxFiles;
- (void) parseEngineFile;

@end
