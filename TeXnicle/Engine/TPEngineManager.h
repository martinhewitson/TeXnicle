//
//  TPEngineManager.h
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
#import "TPEngine.h"
#import "MHConsoleManager.h"

extern NSString * const TPEngineCompilingCompletedNotification;
extern NSString * const TPEngineDidTrashFilesNotification;

@protocol TPEngineManagerDelegate <NSObject>
@optional
-(NSString*)engineName;
-(NSString*)bibtexCommand;
-(NSNumber*)doBibtex;
-(NSNumber*)doPS2PDF;
-(NSNumber*)openConsole;
-(NSNumber*)nCompile;
-(NSString*)documentToCompile;
-(NSString*)workingDirectory;
-(void)documentCompileDidFinish:(BOOL)success;
@end

@interface TPEngineManager : NSObject <TPEngineDelegate>

@property (unsafe_unretained) id<TPEngineManagerDelegate> delegate;
@property (strong) NSMutableArray *engines;
@property (strong) MHConsoleManager *consoleManager;

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
- (void) liveCompile;
- (void) cancelCompilation;
- (void) trashAuxFiles:(BOOL)keepDocument;
- (void) tearDown;

@end
