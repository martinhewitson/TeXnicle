//
//  TPEngineManager.m
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

#import "TPEngineManager.h"
#import "MABSupportFolder.h"
#import "TPEngine.h"
#import "ConsoleController.h"
#import "externs.h"

NSString * const TPEngineCompilingCompletedNotification = @"TPEngineCompilingCompletedNotification";
NSString * const TPEngineDidTrashFilesNotification = @"TPEngineDidTrashFilesNotification";

@implementation TPEngineManager

@synthesize delegate;
@synthesize engines;
@synthesize consoleManager;

+(NSArray*)builtinEngineNames
{
  return [NSArray arrayWithObjects:@"xelatex", @"latex", @"pdflatex", @"context", @"latexmk", @"Lilypond", nil];
}

+ (void) installEngines
{
//  NSLog(@"Installing engines...");
  // path to resources
  NSMutableArray *engines = [NSMutableArray array];
  
  
  for (NSString *name in [TPEngineManager builtinEngineNames]) {
//    NSLog(@"Adding engine %@", name);
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"engine"];
//    NSLog(@"Adding path %@", path);
    if (path) {
      [engines addObject:path];    
    }
  }
  
  // create engines folder
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *enginesDir = [TPEngineManager engineDir];
  if (![fm fileExistsAtPath:enginesDir]) {
    NSError *error = nil;
    BOOL success = [fm createDirectoryAtPath:enginesDir withIntermediateDirectories:YES attributes:nil error:&error];
    if (success == NO) {
      [NSApp presentError:error];
      NSAlert *alert = [NSAlert alertWithMessageText:@"Engine Installation Failed"
                                       defaultButton:@"OK"
                                     alternateButton:nil
                                         otherButton:nil
                           informativeTextWithFormat:@"No engines have been installed because the engine directory could not be created at %@. This means TeXnicle can not compile any documents.", enginesDir];
      [alert runModal];
      return;
    }
  }
  
  NSError *error = nil;
  for (NSString *engine in engines) {
    error = nil;
    
    NSString *target = [enginesDir stringByAppendingPathComponent:[engine lastPathComponent]];
//    NSLog(@"Installing %@ to %@", engine, target);
    BOOL success = YES;
    if ([fm fileExistsAtPath:target]) {
      error = nil;
      success = [fm removeItemAtPath:target error:&error];
    }
    if (success == NO) {
      [NSApp presentError:error];
    } else {
      success = [fm copyItemAtPath:engine toPath:target error:&error];
      if (success == NO) {
        [NSApp presentError:error];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Engine Installation Failed"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Installation of engine %@ failed.", [[engine lastPathComponent] stringByDeletingPathExtension]];
        [alert runModal];
      }
    } // end if file exists error...
    
    // make executable
    NSDictionary *attributes;
    NSNumber *permissions;
    permissions = [NSNumber numberWithUnsignedLong: 493];
    attributes = [NSDictionary dictionaryWithObject:permissions forKey:NSFilePosixPermissions];
    // This actually sets the permissions
    error = nil;
    success = [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:target error:&error];
    if (success == NO) {
      [NSApp presentError:error];
      NSAlert *alert = [NSAlert alertWithMessageText:@"Engine Installation Failed"
                                       defaultButton:@"OK"
                                     alternateButton:nil
                                         otherButton:nil
                           informativeTextWithFormat:@"Failed to make engine %@ executable. TeXnicle will be unable to compile documents with this engine.", [[engine lastPathComponent] stringByDeletingPathExtension]];
      [alert runModal];
    }
    
  }
}

+ (NSString*)engineDir
{
  MABSupportFolder *sf = [MABSupportFolder sharedController];
//  NSLog(@"Support folder %@", [sf supportFolder]);
  return [[sf supportFolder] stringByAppendingPathComponent:@"engines"];
}

+ (TPEngineManager*)engineManagerWithDelegate:(id<TPEngineManagerDelegate>)aDelegate
{
  return [[TPEngineManager alloc] initWithDelegate:aDelegate];
}


- (id)initWithDelegate:(id<TPEngineManagerDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    self.consoleManager = [[MHConsoleManager alloc] init];

//    [TPEngineManager installEngines];
//    [self loadEngines];
    
    [self.consoleManager registerConsole:[ConsoleController sharedConsoleController]];
    
  }
  return self;  
}

- (void) dealloc
{
  self.delegate = nil;
}

- (BOOL)registerConsole:(id<MHConsoleViewer>)aViewer
{
  return [self.consoleManager registerConsole:aViewer];
}

- (void)loadEngines
{
  self.engines = [NSMutableArray array];
  NSString *engineDir = [TPEngineManager engineDir];

  // get contents of dir
  NSFileManager *fm = [NSFileManager defaultManager];
  
  BOOL isDir;
  BOOL dirExists = [fm fileExistsAtPath:engineDir isDirectory:&isDir];
  if (!isDir || !dirExists) {
    [TPEngineManager installEngines];
  }
  
  NSError *error = nil;
  NSArray *contents = [fm contentsOfDirectoryAtPath:engineDir error:&error];
  if (contents == nil) {
    [NSApp presentError:error];
    return;
  }  
  
  // go over the contents looking for .engine files
  for (NSString *path in contents) {   
    NSString *filepath = [engineDir stringByAppendingPathComponent:path];
    if ([fm fileExistsAtPath:filepath] && [[filepath pathExtension] isEqualToString:@"engine"]) {     
      
      // ensure the engine is executable
      NSNumber *permissions = [NSNumber numberWithUnsignedLong: 493];
      NSDictionary *attributes = [NSDictionary dictionaryWithObject:permissions forKey:NSFilePosixPermissions];
      // This actually sets the permissions
      error = nil;
      BOOL success = [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:filepath error:&error];
      if (success == NO) {
        [NSApp presentError:error];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Engine Installation Failed"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Failed to make engine %@ executable. TeXnicle will be unable to compile documents with this engine.", [[filepath lastPathComponent] stringByDeletingPathExtension]];
        [alert runModal];
      }
            
      TPEngine *e = [TPEngine engineWithPath:filepath];
      [self.engines addObject:e];      
      for (NSString *bin in [TPEngineManager builtinEngineNames]) {
        if ([[bin lowercaseString] isEqualToString:[e.name lowercaseString]]) {
          e.builtIn = YES;
        }
      }
    }    
  }
//  NSLog(@"Loaded engines");
}

- (NSInteger)indexOfEngineNamed:(NSString*)name
{
  NSInteger index = 0;
  for (TPEngine *e in self.engines) {
    if ([[e.name lowercaseString] isEqualToString:[name lowercaseString]]) {
      return index;
    }
    index++;
  }
  return NSNotFound;
}

- (TPEngine*)engineNamed:(NSString*)name
{
  if (self.engines == nil) {
    [self loadEngines];
  }
  for (TPEngine *e in self.engines) {
    if ([[e.name lowercaseString] isEqualToString:[name lowercaseString]]) {
      return e;
    }
  }
  return nil;
}

- (NSArray*)registeredEngineNames
{
  [self loadEngines];
  
  NSMutableArray *names = [NSMutableArray array];
  for (TPEngine *e in self.engines) {
    [names addObject:e.name];
  }
  return names;
}

- (BOOL) isCompiling
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(engineName)]) {
    NSString *engineName = [self.delegate engineName];
    TPEngine *e = [self engineNamed:engineName];
    if (e) {
      return e.isCompiling;
    } else {
      return NO;
    }
  }
  return NO;
}

- (void) compile
{
  // ensure the engines have been installed and loaded
  [self loadEngines];
  
  NSString *engineName = [self.delegate engineName];
  TPEngine *e = [self engineNamed:engineName];
  e.delegate = self;
  e.doBibtex = [[self.delegate doBibtex] boolValue];
  e.doPS2PDF = [[self.delegate doPS2PDF] boolValue];
  e.openConsole = [[self.delegate openConsole] boolValue];
  e.nCompile = [[self.delegate nCompile] integerValue];
  
  if (e) {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:TPClearConsoleOnCompile] boolValue]) {
      [self.consoleManager clear];
    }
  
    [e compileDocumentAtPath:[self.delegate documentToCompile] 
            workingDirectory:[self.delegate workingDirectory]
                   isProject:YES];  
  } else {
    [self compileDidFinish:NO];
  }
  
}

- (void) trashAuxFiles
{
  NSString *engineName = [self.delegate engineName];
  TPEngine *e = [self engineNamed:engineName];
  // ensure the engine has a document path
  e.documentPath = [self.delegate documentToCompile];
  [e trashAuxFiles];  
  [[NSNotificationCenter defaultCenter] postNotificationName:TPEngineDidTrashFilesNotification object:self];
}

#pragma mark -
#pragma mark Engine delegate

- (void) compileDidFinish:(BOOL)success
{
  NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:@"success"];
  [[NSNotificationCenter defaultCenter] postNotificationName:TPEngineCompilingCompletedNotification
                                                      object:self
                                                    userInfo:dict];    

}

- (void)enginePostMessage:(NSString*)someText
{
  [self.consoleManager message:someText];
}

- (void)enginePostError:(NSString*)someText
{
  [self.consoleManager error:someText];
}

- (void)enginePostTextForAppending:(NSString*)someText
{
  [self.consoleManager appendText:someText];
}


@end
