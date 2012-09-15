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
#import "NSArray+Color.h"

@interface TPOutlineBuilder ()

@property (assign) BOOL isUpdating;

@end

@implementation TPOutlineBuilder

+ (id) outlineBuilderWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate
{
  return [[TPOutlineBuilder alloc] initWithDelegate:aDelegate];
}

- (id) initWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    [self makeTemplates];
    self.sections = [NSMutableArray array];
    self.isUpdating = NO;
    queue = dispatch_queue_create("com.bobsoft.TeXnicle.outlineArray", DISPATCH_QUEUE_SERIAL);
        
    [self observePreferences];
  }
  
  return self;
}

- (NSArray*)keysToObserve
{
  return @[TPOutlineDocumentColor, TPOutlinePartColor, TPOutlineChapterColor, TPOutlineSectionColor, TPOutlineSubsectionColor, TPOutlineSubsubsectionColor, TPOutlineParagraphColor, TPOutlineSubparagraphColor];
}

- (void) stopObserving
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  for (NSString *key in [self keysToObserve]) {
    [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", key]];
  }
}

- (void) observePreferences
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  for (NSString *key in [self keysToObserve]) {
    [defaults addObserver:self
               forKeyPath:[NSString stringWithFormat:@"values.%@", key]
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  for (NSString *key in [self keysToObserve]) {
    if ([keyPath isEqualToString:[NSString stringWithFormat:@"values.%@", key]]) {
      [self setTemplateColors];
    }
  }
}



- (void) stopTimer
{
  if (self.timer) {
//    NSLog(@"Invalidate timer...");
    [self.sections removeAllObjects];
    [self.timer invalidate];
    self.timer = nil;
  }
}

- (void) startTimer
{
  [self stopTimer];
  
  self.timer = [NSTimer scheduledTimerWithTimeInterval:2 
                                                target:self
                                              selector:@selector(buildOutline) 
                                              userInfo:nil
                                               repeats:YES];
}


- (void) dealloc
{
  NSLog(@"Dealloc %@", self);
}

- (void) tearDown
{
  NSLog(@"Tear down %@", self);
  [self stopObserving];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self stopTimer];
  self.delegate = nil;
  dispatch_release(queue);
  [self.sections removeAllObjects];
}

- (void) buildOutline
{
//  NSLog(@"Build outline...");
  
  if ([self.delegate shouldGenerateOutline] == NO && [self.sections count] > 0) {
//    NSLog(@"   NO: Delegate says no, and I have sections already");
    return;
  }
  
  __block TPOutlineBuilder *blockSelf = self;
  
  NSArray *templatesToScanFor = [blockSelf.templates subarrayWithRange:NSMakeRange(0, 1+blockSelf.depth)];
  
  // get the main file from the delegate
  id file = [self.delegate mainFile];
//  NSLog(@"  main file %@", [file valueForKey:@"name"]);
  
  if ([file isKindOfClass:[FileEntity class]]) {
    
    __block TPOutlineBuilder *blockSelf = self;
    
    dispatch_async(queue, ^{
      
//      NSLog(@"   computing sections...");
      NSArray *newSections = [file generateSectionsForTypes:templatesToScanFor
                                                forceUpdate:NO];
//      NSLog(@"  got %ld", [newSections count]);
//      NSLog(@"   processing sections...");
      [blockSelf processNewSections:newSections forFile:file templates:templatesToScanFor];
//      NSLog(@"      done");
    });
    
    

  } else {
    // get text
    NSString *text = [self.delegate textForFile:file];
        
    dispatch_async(queue, ^{
      NSArray *newSections = [text sectionsInStringForTypes:templatesToScanFor
                                           existingSections:blockSelf.sections
                                                     inFile:file];
      
      [blockSelf processNewSections:newSections forFile:file templates:templatesToScanFor];
    });
            
  }
  
}

- (void) processNewSections:(NSArray*)sections forFile:(id)file templates:(NSArray*)templates
{
  NSMutableArray *newSections = [NSMutableArray arrayWithArray:sections];
  
  NSArray *existingSections = self.sections;
  
  // check if we have a root section, otherwise insert it, or reuse it
  if ([newSections count] > 0) {
    TPSection *firstSection = newSections[0];
//    NSLog(@"First section %@", firstSection);
    
    if ([firstSection.type.name isEqualToString:@"begin"] == NO) {
      
      TPSection *root = [TPSection sectionWithParent:nil start:0 inFile:file type:templates[0] name:@"Root"];
      
      // see if we have an existing root which matches what we would anyway insert
      TPSection *firstExistingSection = nil;
      if ([existingSections count] > 0) {
        firstExistingSection = existingSections[0];
      }
      
      if (firstExistingSection != nil && [firstExistingSection matches:root]) {
        
        [newSections insertObject:firstExistingSection atIndex:0];
        
      } else {
        
//        NSLog(@"Inserting root");
        root.needsReload = YES;
        [newSections insertObject:root atIndex:0];
        
        // set all other parents to nil because they are invalid now
        for (TPSection *s in newSections) {
          s.parent = nil;
        }
      }
    }
    
    // get new root
    if ([existingSections count] > 0) {
      TPSection *root = newSections[0];
      TPSection *existingRoot = existingSections[0];
      
      // if the new root doesn't match the old root, reset all parents
      if ([root matches:existingRoot] == NO) {
        // set all other parents to nil because they are invalid now
        for (TPSection *s in newSections) {
          s.parent = nil;
        }
      }
    }
  }
  
//  NSLog(@"Got sections %@", newSections);
  
//  NSLog(@"Updating sections...");
  NSArray *updatedSections = [self getUpdatedSections:newSections];
  
  if (updatedSections) {
//    NSLog(@"Updated sections %@", updatedSections);
    
    [self.sections removeAllObjects];
    [self.sections addObjectsFromArray:updatedSections];
    
    self.isUpdating = NO;
    
    // inform delegate
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.delegate) {
        [self.delegate didComputeNewSections];
      }
    });
  }
//  NSLog(@"--------------------------------------------  update done");
}

- (NSArray*) getUpdatedSections:(NSArray*)newSections
{
  NSInteger existingSectionsCount = [self.sections count];
  NSInteger newSectionsCount = [newSections count];
  
  // update parents
  if ([newSections count] > 0) {
    // set parents
    TPSection *root = newSections[0];
    
    if (newSectionsCount != existingSectionsCount) {
      // reload
      root.needsReload = YES;
    }
    
    for (int kk=1; kk<[newSections count]; kk++) {
      TPSection *s = newSections[kk];
      
      int jj = kk-1;
      TPSection *parent = newSections[jj];
      while (jj>=0) {
        if ([TPSectionTemplate template:s.type isChildOf:parent.type]) {
          if (s.parent != parent) {
            s.parent = parent;
            parent.needsReload = YES;
          }
          break;
        }
        if (jj>=0) {
          parent = newSections[jj];
        }
        jj--;
      }
      
      if (s.parent == nil) {
        s.parent = root;
      }
    }
  }
  
  
  return newSections;  
}

- (void) makeTemplates
{
  NSMutableArray *tmp = [NSMutableArray array];
  
  NSColor *color;
  
  color = [NSColor colorWithDeviceWhite:0.0 alpha:1.0];
  TPSectionTemplate *document = [TPSectionTemplate documentSectionTemplateWithName:@"begin" 
                                                                              tags:@[@"\\begin{document}", @"\\starttext"]
                                                                            parent:nil
                                                                             color:color
                                                                          mnemonic:@"D"];
  document.defaultTitle = @"Document";
  [tmp addObject:document];
  
  color = [NSColor darkGrayColor];
  TPSectionTemplate *part = [TPSectionTemplate documentSectionTemplateWithName:@"part" 
                                                                          tags:@[@"\\part", @"\\part*"]
                                                                        parent:document
                                                                         color:color
                                                                      mnemonic:@"P"];
  [tmp addObject:part];
  
  color = [NSColor darkGrayColor];
  TPSectionTemplate *chapter = [TPSectionTemplate documentSectionTemplateWithName:@"chapter" 
                                                                             tags:@[@"\\chapter", @"\\chapter*"]
                                                                           parent:part 
                                                                            color:color
                                                                         mnemonic:@"C"];
  [tmp addObject:chapter];
  
  color = [NSColor colorWithDeviceRed:0.8 green:0.2 blue:0.2 alpha:1.0];
  TPSectionTemplate *section = [TPSectionTemplate documentSectionTemplateWithName:@"section" 
                                                                             tags:@[@"\\section", @"\\section*", @"\\subject"]
                                                                           parent:chapter 
                                                                            color:color
                                                                         mnemonic:@"S"];
  [tmp addObject:section];
  
  color = [NSColor colorWithDeviceRed:0.6 green:0.3 blue:0.3 alpha:1.0];
  TPSectionTemplate *subsection = [TPSectionTemplate documentSectionTemplateWithName:@"subsection" 
                                                                                tags:@[@"\\subsection", @"\\subsection*", @"\\subsubject"]
                                                                              parent:section 
                                                                               color:color
                                                                            mnemonic:@"ss"];
  [tmp addObject:subsection];
  
  color = [NSColor colorWithDeviceRed:0.6 green:0.5 blue:0.5 alpha:1.0];
  TPSectionTemplate *subsubsection = [TPSectionTemplate documentSectionTemplateWithName:@"subsubsection" 
                                                                                   tags:@[@"\\subsubsection", @"\\subsubsection*", @"\\subsubsubject"]
                                                                                 parent:subsection
                                                                                  color:color
                                                                               mnemonic:@"sss"];
  [tmp addObject:subsubsection];
  
  color = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
  TPSectionTemplate *paragraph = [TPSectionTemplate documentSectionTemplateWithName:@"paragraph" 
                                                                               tags:@[@"\\paragraph", @"\\paragraph*"]
                                                                             parent:subsubsection
                                                                              color:color
                                                                           mnemonic:@"p"];
  [tmp addObject:paragraph];
  
  color = [NSColor colorWithDeviceWhite:0.7 alpha:1.0];
  TPSectionTemplate *subparagraph = [TPSectionTemplate documentSectionTemplateWithName:@"subparagraph" 
                                                                                  tags:@[@"\\subparagraph", @"\\subparagraph*"]
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
  
  [self setTemplateColors];
  
}

- (void) setTemplateColors
{
  [self setColorForName:@"begin" withPreferenceName:TPOutlineDocumentColor];
  [self setColorForName:@"part" withPreferenceName:TPOutlinePartColor];
  [self setColorForName:@"chapter" withPreferenceName:TPOutlineChapterColor];
  [self setColorForName:@"section" withPreferenceName:TPOutlineSectionColor];
  [self setColorForName:@"subsection" withPreferenceName:TPOutlineSubsectionColor];
  [self setColorForName:@"subsubsection" withPreferenceName:TPOutlineSubsubsectionColor];
  [self setColorForName:@"paragraph" withPreferenceName:TPOutlineParagraphColor];
  [self setColorForName:@"subparagraph" withPreferenceName:TPOutlineSubparagraphColor];  
}

- (void) setColorForName:(NSString*)name withPreferenceName:(NSString*)prefName
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *colorVals = nil;
  
  for (TPSectionTemplate *s in self.templates) {
    if ([s.name isEqualToString:name]) {
      
      colorVals = [defaults valueForKey:prefName];
      if (colorVals) {
        [s setColor:[colorVals colorValue]];
      } else {
        [s setColor:[NSColor blackColor]];
      }
      
      break;
    }
  }
}





@end
