//
//  TPEngineManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 24/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPEngineManager.h"
#import "MABSupportFolder.h"
#import "TPEngine.h"
#import "ConsoleController.h"

NSString * const TPEngineCompilingCompletedNotification = @"TPEngineCompilingCompletedNotification";
NSString * const TPEngineDidTrashFilesNotification = @"TPEngineDidTrashFilesNotification";

@implementation TPEngineManager

@synthesize delegate;
@synthesize engines;
@synthesize consoleManager;

+(NSArray*)builtinEngineNames
{
  static NSArray *builtInEngineNames;
  
  if (builtInEngineNames == nil) {
    builtInEngineNames = [[NSArray arrayWithObjects:@"latex", @"pdflatex", @"context", @"latexmk", nil] retain];  
  }
  return builtInEngineNames;
}

+ (void) installEngines
{
//  NSLog(@"Installing engines...");
  // path to resources
  NSMutableArray *engines = [NSMutableArray array];
  
  
  for (NSString *name in [TPEngineManager builtinEngineNames]) {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"engine"];
//    NSLog(@"Adding path %@", path);
    if (path) {
      [engines addObject:path];    
    }
  }
  
  
  // application support directory 
//  NSLog(@"Support folder: %@", [sf supportFolder]);
  
  // create engines folder
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *enginesDir = [TPEngineManager engineDir];
  if (![fm fileExistsAtPath:enginesDir]) {
    NSError *error = nil;
    [fm createDirectoryAtPath:enginesDir withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
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
    
    if ([fm fileExistsAtPath:target]) {
      error = nil;
      [fm removeItemAtPath:target error:&error];
    }
    if (error) {
      [NSApp presentError:error];
    } else {
      [fm moveItemAtPath:engine toPath:target error:&error];
      if (error) {
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
    [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:target error:&error];
    if (error) {
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
  return [[[TPEngineManager alloc] initWithDelegate:aDelegate] autorelease];
}


- (id)initWithDelegate:(id<TPEngineManagerDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    self.consoleManager = [[[MHConsoleManager alloc] init] autorelease];

//    [TPEngineManager installEngines];
//    [self loadEngines];
    
    [self.consoleManager registerConsole:[ConsoleController sharedConsoleController]];
    
  }
  return self;  
}

- (void) dealloc
{
  self.delegate = nil;
  self.engines = nil;
  self.consoleManager = nil;
  [super dealloc];
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
  if (error) {
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
      [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:filepath error:&error];
      if (error) {
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
        if ([bin isEqualToString:e.name]) {
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
    if ([e.name isEqualToString:[name lowercaseString]]) {
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
  NSString *engineName = [self.delegate engineName];
  TPEngine *e = [self engineNamed:engineName];
  return e.isCompiling;
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
