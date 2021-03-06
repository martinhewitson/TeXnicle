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

- (void)compileWasCancelled;
- (void)compileDidFinish:(BOOL)success;
- (void)enginePostMessage:(NSString*)someText;
- (void)enginePostError:(NSString*)someText;
- (void)enginePostTextForAppending:(NSString*)someText;

@end

@interface TPEngine : NSObject <TPEngineDelegate> {
@private
  // Typesetting
	NSFileHandle *typesetFileHandle;
  NSPipe *pipe;
	BOOL abortCompile;
  int procId;
}

@property (unsafe_unretained) id<TPEngineDelegate> delegate;

@property (copy) NSString *path;
@property (copy) NSString *script;
@property (copy) NSString *name;
@property (copy) NSString *documentPath;
@property (unsafe_unretained, readonly) NSString *compiledDocumentPath;
@property (copy) NSString *bibtexCommand;
@property (copy) NSString *outputDirectory;
@property (assign) BOOL stopOnError;
@property (assign) BOOL doBibtex;
@property (assign) BOOL doPS2PDF;
@property (assign) BOOL openConsole;
@property (assign) NSInteger nCompile;
@property (assign) BOOL supportsDoBibtex;
@property (assign) BOOL supportsDoPS2PDF;
@property (assign) BOOL supportsOutputDirectory;
@property (assign) NSInteger supportsNCompile;
@property (assign, getter = isBuiltIn) BOOL builtIn;
@property (assign, getter = isCompiling) BOOL compiling;
@property (copy) NSString *imageIncludeString;

- (id)initWithPath:(NSString*)aPath;
+ (TPEngine*)engineWithPath:(NSString*)aPath;
+ (NSArray *)scanProperties;
+ (NSString*)defaultImageIncludeString;
- (void) setupObservers;

- (void) tearDown;

- (BOOL) compileDocumentAtPath:(NSString*)documentPath workingDirectory:(NSString*)workingDir isProject:(BOOL)isProject;
- (void) texOutputAvailable:(NSNotification*)aNote;
- (void) taskFinished:(NSNotification*)aNote;
- (void) reset;
- (void) cancelCompile;
- (void) trashAuxFiles:(BOOL)keepDocument;
- (void) parseEngineFile;

@end
