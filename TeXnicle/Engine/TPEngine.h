//
//  TPEngine.h
//  TeXnicle
//
//  Created by Martin Hewitson on 24/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
