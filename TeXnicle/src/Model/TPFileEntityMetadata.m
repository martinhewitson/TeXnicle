//
//  TPFileEntityMetadata.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPFileEntityMetadata.h"
#import "TPSectionTemplate.h"
#import "TPSection.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "FileEntity.h"
#import "ExternalTeXDoc.h"
#import "NSString+SectionsOutline.h"

NSString * const TPFileMetadataSectionsUpdatedNotification = @"TPFileMetadataSectionsUpdatedNotification";

@implementation TPFileEntityMetadata

@synthesize sections;
@synthesize lastUpdateOfSections;
@synthesize parent;

- (id) initWithParent:(id)aFile
{
  self = [super init];
  if (self != nil) {
    self.parent = aFile;
    queue = dispatch_queue_create("com.bobsoft.TeXnicle", NULL);
    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
    dispatch_set_target_queue(queue,priority);
  }
  return self;
}

- (void) dealloc
{
  self.lastUpdateOfSections = nil;
  self.sections = nil;
	dispatch_release(queue);
  [super dealloc];
}

- (void) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  dispatch_async(queue, ^{						
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];               
    self.sections = [self updateSectionsForTypes:templates forceUpdate:force];
    self.lastUpdateOfSections = [NSDate date];
    [pool drain];      
    
  });
  
  dispatch_sync(queue, ^{						
    // both blocks have completed
  });
  
  // send notification of section update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.parent, @"file", self.sections, @"sections", nil];
  [nc postNotificationName:TPFileMetadataSectionsUpdatedNotification
                    object:self
                  userInfo:dict];
  
}


- (NSArray*)updateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  // prepare sections found array
  NSArray *sectionsFound = nil;
    
  // get the parent file and the text to search
  id file = self.parent;
  NSString *text = [self.parent text];

  sectionsFound = [text sectionsInStringForTypes:templates existingSections:self.sections inFile:file];
  
  return sectionsFound;
}

@end
