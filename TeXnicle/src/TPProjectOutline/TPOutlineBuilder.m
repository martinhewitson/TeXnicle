//
//  TPOutlineBuilder.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPOutlineBuilder.h"
#import "TPSectionTemplate.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "FileEntity.h"
#import "externs.h"
#import "TPFileEntityMetadata.h"
#import "NSString+SectionsOutline.h"

@implementation TPOutlineBuilder

@synthesize delegate;
@synthesize templates;
@synthesize sectionCommands;
@synthesize sections;
@synthesize timer;
@synthesize depth;

+ (id) outlineBuilderWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate
{
  return [[[TPOutlineBuilder alloc] initWithDelegate:aDelegate] autorelease];
}

- (id) initWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    [self makeTemplates];
    self.sections = [NSMutableArray array];
    
    // handle updates to all FileEntity metadata
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleFileMetadataSectionsUpdateNotifcation:)
               name:TPFileMetadataSectionsUpdatedNotification
             object:nil];
  }
  
  return self;
}



- (void) stopTimer
{
  [self.timer invalidate];
  self.timer = nil;
}

- (void) startTimer
{
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
  
  self.timer = [NSTimer scheduledTimerWithTimeInterval:2 
                                                target:self
                                              selector:@selector(buildOutline) 
                                              userInfo:nil
                                               repeats:YES];
}


- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.timer invalidate];
  self.timer = nil;
  self.templates = nil;
  self.sectionCommands = nil;
  self.sections = nil;
  [super dealloc];
}

- (void) buildOutline
{
  if ([self.delegate shouldGenerateOutline] == NO && [self.sections count] > 0) {
    return;
  }
  
  // get the main file from the delegate
  id file = [self.delegate mainFile];
  if ([file isKindOfClass:[FileEntity class]]) {    
    [file generateSectionsForTypes:[self.templates subarrayWithRange:NSMakeRange(0, 1+self.depth)] forceUpdate:NO];
  } else {
    // get text
    NSString *text = [self.delegate textForFile:file];

    dispatch_queue_t queue = dispatch_queue_create("com.bobsoft.TeXnicle", NULL);
    dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
    dispatch_set_target_queue(queue,priority);
    
    __block NSArray *newSections;
    dispatch_sync(queue, ^{      
      newSections = [text sectionsInStringForTypes:[self.templates subarrayWithRange:NSMakeRange(0, 1+self.depth)] existingSections:self.sections inFile:file];
    });
        
    dispatch_release(queue);
    
    // send notification of section update
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:file, @"file", newSections, @"sections", nil];
    [nc postNotificationName:TPFileMetadataSectionsUpdatedNotification
                      object:self
                    userInfo:dict];
  }
  
}

- (void) handleFileMetadataSectionsUpdateNotifcation:(NSNotification*)aNote
{
  
  // get the user info
  NSDictionary *dict = [aNote userInfo];
    
  // the file from the dictionary
  id file = [dict valueForKey:@"file"];
  if ([file isKindOfClass:[FileEntity class]]) {
    if (file != [self.delegate mainFile]) {
      return;
    }
  } else {
    if ([file isEqualToString:[self.delegate mainFile]] == NO) {
      return;
    }
  }
  
  // get the sections from the dictionary
  NSArray *newSections = [dict valueForKey:@"sections"];
  
  // remove existing sections for this file
  [self.sections removeAllObjects];
  
  // add new sections
  [self.sections addObjectsFromArray:newSections];
  
  // update parents
  if ([self.sections count] > 0) {
    // set parents
    TPSection *root = [self.sections objectAtIndex:0];
    for (int kk=1; kk<[self.sections count]; kk++) {
      TPSection *s = [self.sections objectAtIndex:kk];
      
      int jj = kk-1;
      TPSection *parent = [self.sections objectAtIndex:jj];
      while (jj>=0) {      
        if ([TPSectionTemplate template:s.type isChildOf:parent.type]) {
          s.parent = parent;
          break;
        } 
        if (jj>=0) {
          parent = [self.sections objectAtIndex:jj];
        }
        jj--;
      }
      
      if (s.parent == nil) {
        s.parent = root;
      }
    }
  }
  
  // inform delegate
  [self.delegate didComputeNewSections];
}

- (void) makeTemplates
{
  NSMutableArray *tmp = [NSMutableArray array];
  
  NSColor *color;
  
  color = [NSColor colorWithDeviceWhite:0.0 alpha:1.0];
  TPSectionTemplate *document = [TPSectionTemplate documentSectionTemplateWithName:@"begin" 
                                                                               tag:@"\\begin{document}" 
                                                                            parent:nil 
                                                                             color:color
                                                                          mnemonic:@"D"];
  [tmp addObject:document];
  
  color = [NSColor darkGrayColor];
  TPSectionTemplate *part = [TPSectionTemplate documentSectionTemplateWithName:@"part" 
                                                                           tag:@"\\part" 
                                                                        parent:document 
                                                                         color:color
                                                                      mnemonic:@"P"];
  [tmp addObject:part];
  
  color = [NSColor darkGrayColor];
  TPSectionTemplate *chapter = [TPSectionTemplate documentSectionTemplateWithName:@"chapter" 
                                                                              tag:@"\\chapter" 
                                                                           parent:part 
                                                                            color:color
                                                                         mnemonic:@"C"];
  [tmp addObject:chapter];
  
  color = [NSColor colorWithDeviceRed:0.8 green:0.2 blue:0.2 alpha:1.0];
  TPSectionTemplate *section = [TPSectionTemplate documentSectionTemplateWithName:@"section" 
                                                                              tag:@"\\section" 
                                                                           parent:chapter 
                                                                            color:color
                                                                         mnemonic:@"S"];
  [tmp addObject:section];
  
  color = [NSColor colorWithDeviceRed:0.6 green:0.3 blue:0.3 alpha:1.0];
  TPSectionTemplate *subsection = [TPSectionTemplate documentSectionTemplateWithName:@"subsection" 
                                                                                 tag:@"\\subsection"
                                                                              parent:section 
                                                                               color:color
                                                                            mnemonic:@"ss"];
  [tmp addObject:subsection];
  
  color = [NSColor colorWithDeviceRed:0.6 green:0.5 blue:0.5 alpha:1.0];
  TPSectionTemplate *subsubsection = [TPSectionTemplate documentSectionTemplateWithName:@"subsubsection" 
                                                                                    tag:@"\\subsubsection" 
                                                                                 parent:subsection 
                                                                                  color:color
                                                                               mnemonic:@"sss"];
  [tmp addObject:subsubsection];
  
  color = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
  TPSectionTemplate *paragraph = [TPSectionTemplate documentSectionTemplateWithName:@"paragraph" 
                                                                                tag:@"\\paragraph" 
                                                                             parent:subsubsection 
                                                                              color:color
                                                                           mnemonic:@"p"];
  [tmp addObject:paragraph];
  
  color = [NSColor colorWithDeviceWhite:0.7 alpha:1.0];
  TPSectionTemplate *subparagraph = [TPSectionTemplate documentSectionTemplateWithName:@"subparagraph" 
                                                                                   tag:@"\\subparagraph" 
                                                                                parent:paragraph
                                                                                 color:color
                                                                              mnemonic:@"sp"];
  [tmp addObject:subparagraph];
 
  self.templates = [NSArray arrayWithArray:tmp];
  
  NSMutableArray *cmds = [NSMutableArray array];
  for (TPSectionTemplate *template in self.templates) {
    [cmds addObject:template.tag];
  }
  self.sectionCommands = [NSArray arrayWithArray:cmds];
  
  self.depth = [self.templates count]-1;
  
}

- (NSArray*) childrenOfSection:(id)parent
{
  NSMutableArray *parents = [NSMutableArray array];
  for (TPSection *s in self.sections) {
    if (s.parent == parent) {
      [parents addObject:s];
    }
  }
  return [NSArray arrayWithArray:parents];
}



@end
