//
//  TPSupportedFilesManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 06/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSupportedFile.h"

extern NSString * const TPSupportedFileAddedNotification;
extern NSString * const TPSupportedFileRemovedNotification;

@interface TPSupportedFilesManager : NSObject {
@private
  NSMutableArray *supportedFileTypes;
}


@property (retain) NSMutableArray *supportedFileTypes;

+ (TPSupportedFilesManager*)sharedSupportedFilesManager;
- (void) saveTypes;

- (BOOL) removeSupportedFileType:(TPSupportedFile*)aDict;
- (TPSupportedFile*) addSupportedFileType:(TPSupportedFile*)aDict;

- (BOOL) replaceSupportedFileAtIndex:(NSInteger)index withSupportedFile:(TPSupportedFile*)aFile;
- (TPSupportedFile*)fileAtIndex:(NSInteger)index;
- (NSInteger)fileCount;
- (NSInteger)indexOfFileType:(TPSupportedFile*)fileType;

- (NSArray*)supportedExtensionsForHighlighting;
- (NSArray*)supportedExtensions;
- (NSArray*)supportedTypes;

- (NSString*)extensionForType:(NSString*)aType;
- (NSString*)typeForExtension:(NSString*)ext;

@end

