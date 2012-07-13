//
//  TPFileEntityMetadata.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
