//
//  TPSourceDirectory.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/4/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSourceDirectory.h"
#import "TPSourceFile.h"

@implementation TPSourceDirectory

@synthesize children;
@synthesize didPopulate;
@synthesize delegate;

+ (TPSourceDirectory*)directoryWithParent:(TPSourceItem *)aParent path:(NSURL *)aURL delegate:(id<TPSourceDirectoryDelegate>)aDelegate
{
  return [[[TPSourceDirectory alloc] initWithParent:aParent path:aURL delegate:aDelegate] autorelease];
}

- (id)initWithParent:(TPSourceItem *)aParent path:(NSURL *)aURL delegate:(id<TPSourceDirectoryDelegate>)aDelegate
{
  self = [super initWithParent:aParent path:aURL];
  if (self) {
    self.children = [NSSet set];
    self.delegate = aDelegate;
    [self populateChildren];
  }
  return self;
}

- (void) dealloc
{
  self.children = nil;
  [super dealloc];
}

+ (NSArray *)scanProperties
{
  static NSArray *scanProperties = nil;
  if (!scanProperties) {
    scanProperties = [[NSArray arrayWithObjects:
                       NSURLNameKey, 
                       NSURLIsDirectoryKey, 
                       NSURLIsRegularFileKey, 
                       NSURLIsHiddenKey,
                       NSURLIsPackageKey,
                       nil] retain];
  }
  return scanProperties;
}


- (void) populateChildren
{
  NSError *error = nil;
  NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsHiddenFiles;
	NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.path
																								includingPropertiesForKeys:[TPSourceDirectory scanProperties]
																																	 options:options
																																		 error:&error];
  
  if (urls == nil) {
    [NSApp presentError:error];
    return;
  }
  
  id isDir;
  NSError *localerror = nil;
  NSMutableArray *newChildren = [NSMutableArray array];
  for (NSURL *childURL in urls) {
    
    // check if we should include this file
    if ([self sourceDirectory:self shouldIncludeChildItemAtPath:childURL]) {
      
      [childURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:&localerror];
      id child = nil;
      if ([isDir boolValue]) {
        child = [TPSourceDirectory directoryWithParent:self path:childURL delegate:self.delegate];
      } else {
        child = [TPSourceFile fileWithParent:self path:childURL];
      }
      if (child) {
        [newChildren addObject:child];
      }
    }
  }
  self.children = newChildren;
}

- (BOOL) sourceDirectory:(TPSourceDirectory *)aDirectory shouldIncludeChildItemAtPath:(NSURL *)url
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(sourceDirectory:shouldIncludeChildItemAtPath:)]) {
    return [self.delegate sourceDirectory:aDirectory shouldIncludeChildItemAtPath:url];
  }
  
  return NO;
}

@end
