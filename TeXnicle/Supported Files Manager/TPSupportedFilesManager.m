//
//  TPSupportedFilesManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 06/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
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


#import "TPSupportedFilesManager.h"
#import "externs.h"

NSString * const TPSupportedFileAddedNotification = @"TPSupportedFileAddedNotification";
NSString * const TPSupportedFileRemovedNotification = @"TPSupportedFileRemovedNotification";
NSString * const TPSupportedFileSpellCheckFlagChangedNotification = @"TPSupportedFileSpellCheckFlagChangedNotification";

@implementation TPSupportedFilesManager

@synthesize supportedFileTypes;

static TPSupportedFilesManager *sharedSupportedFilesManager = nil;

// Initialise the supported files manager
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

// dealloc 
// also save the file types here
- (void) dealloc
{
  [self saveTypes];
}

// save supported file types back to the standard user defaults
- (void) saveTypes
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:self.supportedFileTypes] forKey:TPSupportedFileTypes];
  [defaults synchronize];
}

// convenience constructor

+ (TPSupportedFilesManager*)sharedSupportedFilesManager
{
  static TPSupportedFilesManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[TPSupportedFilesManager alloc] init];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}


// Returns an array of supported file type names
- (NSArray*)supportedTypes
{
  NSMutableArray *array = [NSMutableArray array];
  for (TPSupportedFile *file in self.supportedFileTypes) {
    [array addObject:file.name];
  }
  return array;
}

// Returns the type for a given file extension, or nil
- (NSString*)typeForExtension:(NSString*)ext
{
  for (TPSupportedFile *file in self.supportedFileTypes) {
    if ([file.ext isEqualToString:ext]) {
      return file.name;
    }
  }
  
  return nil;
}

// Returns the extension for a given file type, or nil
- (NSString*)extensionForType:(NSString*)aType
{
  for (TPSupportedFile *file in self.supportedFileTypes) {
    if ([file.name isEqualToString:aType]) {
      return file.ext;
    }
  }
  
  return nil;
}

// Returns an array of supported file extensions
- (NSArray*)supportedExtensions
{
  NSMutableArray *array = [NSMutableArray array];
  for (TPSupportedFile *file in self.supportedFileTypes) {
    [array addObject:file.ext];
  }
  return array;
}

// Returns an array of supported file extensions which should be syntax highlighted
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

// Returns an array of supported file extensions which should be spell checked
- (NSArray*)supportedExtensionsForSpellChecking
{
  NSMutableArray *array = [NSMutableArray array];
  for (TPSupportedFile *file in self.supportedFileTypes) {
    if (file.spellcheck) {
      [array addObject:file.ext];
    }
  }
  return array;
}


// Remove the given supported file type object. Returns YES if successful, otherwise NO.
- (BOOL) removeSupportedFileType:(TPSupportedFile*)aFile
{
  if ([self.supportedFileTypes containsObject:aFile]) {
    [self.supportedFileTypes removeObject:aFile];
    [self saveTypes];
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:TPSupportedFileRemovedNotification
                                                        object:self
                                                      userInfo:@{@"fileType": aFile}];
    return YES;
  }
  
  return NO;
}

// Adds the given supported file type to the list of supported files
- (TPSupportedFile*) addSupportedFileType:(TPSupportedFile*)aFile
{
  [self.supportedFileTypes addObject:aFile];
  [self saveTypes];
  // post notification
  [[NSNotificationCenter defaultCenter] postNotificationName:TPSupportedFileAddedNotification
                                                      object:self
                                                    userInfo:@{@"fileType": aFile}];
  return aFile;
}

// Replace the file at the given index with the given supported file. Returns YES if the file is successfully replaced; NO otherwise.
- (BOOL) replaceSupportedFileAtIndex:(NSInteger)index withSupportedFile:(TPSupportedFile*)aFile
{
  if (index >=0 && index < [self.supportedFileTypes count]) {
    (self.supportedFileTypes)[index] = aFile;
    [self saveTypes];
    return YES;
  }
  return NO;
}

// Returns the file at the given index. If the index is out of bounds, nil is returned.
- (TPSupportedFile*)fileAtIndex:(NSInteger)index
{
  if (index >=0 && index < [self.supportedFileTypes count]) { 
    return (self.supportedFileTypes)[index];
  }
  return nil;
}

// Returns the number of supported file types.
- (NSInteger)fileCount
{
  return [self.supportedFileTypes count];
}


// Returns the index of the given file.
- (NSInteger)indexOfFileType:(TPSupportedFile*)fileType
{
  return [self.supportedFileTypes indexOfObject:fileType];
}

@end
