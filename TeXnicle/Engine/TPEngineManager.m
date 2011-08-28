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

@implementation TPEngineManager

@synthesize delegate;
@synthesize engines;

+(NSArray*)builtinEngineNames
{
  static NSArray *builtInEngineNames;
  
  if (builtInEngineNames == nil) {
    builtInEngineNames = [[NSArray arrayWithObjects:@"latex", @"pdflatex", @"context", nil] retain];  
  }
  return builtInEngineNames;
}

+ (void) installEngines
{
  // path to resources
  NSMutableArray *engines = [NSMutableArray array];
  
  
  for (NSString *name in [self builtinEngineNames]) {
    [engines addObject:[[NSBundle mainBundle] pathForResource:name ofType:@"engine"]];    
  }
  
  
  // application support directory 
//  NSLog(@"Support folder: %@", [sf supportFolder]);
  
  // create engines folder
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *enginesDir = [self engineDir];
  if (![fm fileExistsAtPath:enginesDir]) {
    NSError *error = nil;
    [fm createDirectoryAtPath:enginesDir withIntermediateDirectories:NO attributes:nil error:&error];
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
    [self loadEngines];
  }
  return self;  
}

- (void) dealloc
{
  self.engines = nil;
  [super dealloc];
}

- (void)loadEngines
{
  self.engines = [NSMutableArray array];
  NSString *engineDir = [TPEngineManager engineDir];
  
  // get contents of dir
  NSFileManager *fm = [NSFileManager defaultManager];
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
  for (TPEngine *e in self.engines) {
    if ([e.name isEqualToString:[name lowercaseString]]) {
      return e;
    }
  }
  return nil;
}

- (NSArray*)registeredEngineNames
{
  NSMutableArray *names = [NSMutableArray array];
  for (TPEngine *e in self.engines) {
    [names addObject:e.name];
  }
  return names;
}

- (void) compile
{
  NSString *engineName = [self.delegate engineName];
  TPEngine *e = [self engineNamed:engineName];
  e.delegate = self;
  e.doBibtex = [[self.delegate doBibtex] boolValue];
  e.doPS2PDF = [[self.delegate doPS2PDF] boolValue];
  e.openConsole = [[self.delegate openConsole] boolValue];
  e.nCompile = [[self.delegate nCompile] integerValue];
  
  [e compileDocumentAtPath:[self.delegate documentToCompile] 
          workingDirectory:[self.delegate workingDirectory]
                 isProject:YES];  
}

- (void) trashAuxFiles
{
  NSString *engineName = [self.delegate engineName];
  TPEngine *e = [self engineNamed:engineName];
  // ensure the engine has a document path
  e.documentPath = [self.delegate documentToCompile];
  [e trashAuxFiles];  
}

- (void) compileDidFinish:(BOOL)success
{
  NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:@"success"];
  [[NSNotificationCenter defaultCenter] postNotificationName:TPEngineCompilingCompletedNotification
                                                      object:self
                                                    userInfo:dict];    

}

@end
