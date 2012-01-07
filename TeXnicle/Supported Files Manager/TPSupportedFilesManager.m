//
//  TPSupportedFilesManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 06/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSupportedFilesManager.h"
#import "externs.h"

NSString * const TPSupportedFileAddedNotification = @"TPSupportedFileAddedNotification";
NSString * const TPSupportedFileRemovedNotification = @"TPSupportedFileRemovedNotification";

@implementation TPSupportedFilesManager

@synthesize supportedFileTypes;

static TPSupportedFilesManager *sharedSupportedFilesManager = nil;


- (id)init
{
  self = [super init];
	if (self){
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // supported types
    self.supportedFileTypes = [NSMutableArray array];
    NSArray *defaultTypes = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults valueForKey:TPSupportedFileTypes]];
    [self.supportedFileTypes addObjectsFromArray:defaultTypes];
    
  }  
	return self;
}

- (void) dealloc
{
  [self saveTypes];
  self.supportedFileTypes = nil;
  [super dealloc];
}

- (void) saveTypes
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:self.supportedFileTypes] forKey:TPSupportedFileTypes];
  [defaults synchronize];
}

+ (TPSupportedFilesManager*)sharedSupportedFilesManager
{
	@synchronized(self) {
		if (sharedSupportedFilesManager == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedSupportedFilesManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedSupportedFilesManager == nil) {
			sharedSupportedFilesManager = [super allocWithZone:zone];
			return sharedSupportedFilesManager;  // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
	//do nothing
}

- (id)autorelease
{
	return self;
}

- (NSArray*)supportedTypes
{
  NSMutableArray *array = [NSMutableArray array];
  for (TPSupportedFile *file in self.supportedFileTypes) {
    [array addObject:file.name];
  }
  return array;
}

- (NSString*)typeForExtension:(NSString*)ext
{
  for (TPSupportedFile *file in self.supportedFileTypes) {
    if ([file.ext isEqualToString:ext]) {
      return file.name;
    }
  }
  
  return nil;
}

- (NSString*)extensionForType:(NSString*)aType
{
  for (TPSupportedFile *file in self.supportedFileTypes) {
    if ([file.name isEqualToString:aType]) {
      return file.ext;
    }
  }
  
  return nil;
}

- (NSArray*)supportedExtensions
{
  NSMutableArray *array = [NSMutableArray array];
  for (TPSupportedFile *file in self.supportedFileTypes) {
    [array addObject:file.ext];
  }
  return array;
}

- (NSArray*)supportedExtensionsForHighlighting
{
  NSMutableArray *array = [NSMutableArray array];
  for (TPSupportedFile *file in self.supportedFileTypes) {
    if (file.syntaxHighlight) {
      [array addObject:file.ext];
    }
  }
  return array;
}



- (BOOL) removeSupportedFileType:(NSDictionary*)aDict
{
  if ([self.supportedFileTypes containsObject:aDict]) {
    [self.supportedFileTypes removeObject:aDict];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TPSupportedFileRemovedNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:aDict forKey:@"fileType"]];
    return YES;
  }
  
  return NO;
}

- (TPSupportedFile*) addSupportedFileType:(TPSupportedFile*)aFile
{
  [self.supportedFileTypes addObject:aFile];
  [self saveTypes];
  // post notification
  [[NSNotificationCenter defaultCenter] postNotificationName:TPSupportedFileAddedNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:aFile forKey:@"fileType"]];
  return aFile;
}


- (void) replaceSupportedFileAtIndex:(NSInteger)index withSupportedFile:(TPSupportedFile*)aFile
{
  [self.supportedFileTypes replaceObjectAtIndex:index withObject:aFile];
  [self saveTypes];
}

- (TPSupportedFile*)fileAtIndex:(NSInteger)index
{
  return [self.supportedFileTypes objectAtIndex:index];
}

- (NSInteger)fileCount
{
  return [self.supportedFileTypes count];
}

- (NSInteger)indexOfFileType:(TPSupportedFile*)fileType
{
  return [self.supportedFileTypes indexOfObject:fileType];
}

@end
