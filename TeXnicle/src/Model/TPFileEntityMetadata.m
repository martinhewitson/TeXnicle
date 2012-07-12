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


NSString * const TPFileMetadataSectionsUpdatedNotification = @"TPFileMetadataSectionsUpdatedNotification";

@implementation TPFileEntityMetadata

@synthesize sections;
@synthesize lastUpdateOfSections;
@synthesize parent;

- (id) initWithParent:(FileEntity*)aFile
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
    [pool drain];      
    
  });
  
  dispatch_sync(queue, ^{						
    // both blocks have completed
  });
  
  // send notification of section update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:TPFileMetadataSectionsUpdatedNotification
                    object:self
                  userInfo:nil];
  
}

- (NSArray*)updateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force
{
  // prepare sections found array
  NSMutableArray *sectionsFound = [NSMutableArray array];
    
  // get the parent file and the text to search
  FileEntity *file = self.parent;
  NSString *text = file.workingContentString;
  
  // scan for sections
  NSInteger index = 0;
  
  // Gather section commands
  NSMutableArray *sectionCommands = [NSMutableArray array];
  for (TPSectionTemplate *template in templates) {
    [sectionCommands addObject:template.tag];
  }

  // scan text for section commands
  while (index < [text length]) {
    
    // look for section
    if ([text characterAtIndex:index] == '\\') {
      
      if ([text isCommentLineBeforeIndex:index commentChar:@"%"]) {
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange(lineRange);
        continue;
      }
      
      NSUInteger loc = index;
      NSString *word = [text nextWordStartingAtLocation:&loc];
      //      NSLog(@"Word: %@", word);
      if ([word beginsWithElementInArray:sectionCommands] != NSNotFound) {
        NSString *command = [word command];
        
        if (command != nil) {
        TPSectionTemplate *template = nil;
          for (TPSectionTemplate *t in templates) {
            if ([t.tag beginsWith:command]) {
              template = t;
            }
          }
          
          if (template != nil) {
            NSInteger loc = index+1;
            NSString *arg = [text parseArgumentStartingAt:&loc];
            if (arg == nil) {
              arg = @"<unknown>";
            }
            TPSection *section = [TPSection sectionWithParent:nil start:index inFile:file type:template name:arg];
            
            // if we don't already have this section, we add it
            //          NSLog(@"Checking for section %@....", section);
            for (TPSection *s in self.sections) {
              if ([s matches:section] == YES) {
                //              NSLog(@"   section exists");
                section = s; 
              }
            }
            [sectionsFound addObject:section];
          } // end if template is not nil
        } // end if command is not nil        
      } else if ([word beginsWith:@"\\input{"] || [word beginsWith:@"\\include{"]) {
        
        //        NSLog(@"Got include %@", word);
        
        // get argument
        NSString *arg = [word argument];
        FileEntity *subfile = [file.project fileWithPath:arg];
        NSArray *subsections = [subfile.metadata updateSectionsForTypes:templates forceUpdate:force]; 
        // check if we already have any of these sections
        for (TPSection *ss in subsections) {
          for (TPSection *s in self.sections) {
            if ([s matches:ss] == YES) {
              ss = s; 
            }
          }
          [sectionsFound addObject:ss];
        }
      }
      index += [word length];
    } else {
      index++;
    }
  }
  self.sections = [NSArray arrayWithArray:sectionsFound];
  self.lastUpdateOfSections = [NSDate date];
  return self.sections;
}

@end
