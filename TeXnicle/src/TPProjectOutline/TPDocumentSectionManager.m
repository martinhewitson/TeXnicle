//
//  TPDocumentSectionManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPDocumentSectionManager.h"
#import "TPSectionTemplate.h"
#import "NSArray+Color.h"
#import "externs.h"


@implementation TPDocumentSectionManager

+ (TPDocumentSectionManager*)sharedSectionManager
{
  static TPDocumentSectionManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[TPDocumentSectionManager alloc] init];
    // Do any other initialisation stuff here
    [sharedInstance makeTemplates];
    [sharedInstance observePreferences];
  });
  return sharedInstance;
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

- (void) saveTemplates
{
  NSMutableDictionary *sectionTags = [NSMutableDictionary dictionary];
  
  for (TPSectionTemplate *sec in self.templates) {
    sectionTags[sec.name] = sec.tags;
  }
  
  [[NSUserDefaults standardUserDefaults] setValue:sectionTags forKey:TPOutlineSectionTags];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) makeTemplates
{
  NSMutableArray *tmp = [NSMutableArray array];
  
  NSColor *color;
  NSString *tagName = nil;
  
  NSDictionary *sectionTags = [[NSUserDefaults standardUserDefaults] dictionaryForKey:TPOutlineSectionTags];
  
  color = [NSColor colorWithDeviceWhite:0.0 alpha:1.0];
  tagName = @"begin";
  TPSectionTemplate *document = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                            parent:nil color:color mnemonic:@"D"
                                                                              icon:[NSImage imageNamed:@"TeXnicle_Doc"]];
  document.defaultTitle = @"Document";
  [tmp addObject:document];
  
  color = [NSColor darkGrayColor];
  tagName = @"part";
  TPSectionTemplate *part = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                        parent:document color:color mnemonic:@"P"
                                                                          icon:[NSImage imageNamed:@"outline_part"]];
  [tmp addObject:part];
  
  color = [NSColor darkGrayColor];
  tagName = @"chapter";
  TPSectionTemplate *chapter = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                           parent:part color:color mnemonic:@"C"
                                                                             icon:[NSImage imageNamed:@"outline_chapter"]];
  [tmp addObject:chapter];
  
  color = [NSColor colorWithDeviceRed:0.8 green:0.2 blue:0.2 alpha:1.0];
  tagName = @"section";
  TPSectionTemplate *section = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                           parent:chapter color:color mnemonic:@"S"
                                                                             icon:[NSImage imageNamed:@"outline_section"]];
  [tmp addObject:section];
  
  color = [NSColor colorWithDeviceRed:0.6 green:0.3 blue:0.3 alpha:1.0];
  tagName = @"subsection";
  TPSectionTemplate *subsection = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                              parent:section color:color mnemonic:@"ss"
                                                                                icon:[NSImage imageNamed:@"outline_subsection"]];
  [tmp addObject:subsection];
  
  color = [NSColor colorWithDeviceRed:0.6 green:0.5 blue:0.5 alpha:1.0];
  tagName = @"subsubsection";
  TPSectionTemplate *subsubsection = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                                 parent:subsection color:color mnemonic:@"sss"
                                                                                   icon:[NSImage imageNamed:@"outline_subsubsection"]];
  [tmp addObject:subsubsection];
  
  color = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
  tagName = @"paragraph";
  TPSectionTemplate *paragraph = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                             parent:subsubsection color:color mnemonic:@"p"
                                                                               icon:[NSImage imageNamed:@"outline_paragraph"]];
  [tmp addObject:paragraph];
  
  color = [NSColor colorWithDeviceWhite:0.7 alpha:1.0];
  tagName = @"subparagraph";
  TPSectionTemplate *subparagraph = [TPSectionTemplate documentSectionTemplateWithName:tagName tags:sectionTags[tagName]
                                                                                parent:paragraph color:color mnemonic:@"sp"
                                                                                  icon:[NSImage imageNamed:@"outline_subparagraph"]];
  [tmp addObject:subparagraph];
  
  self.templates = [NSArray arrayWithArray:tmp];
  
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

- (NSString*)preferenceNameForSection:(NSString*)name
{
  if ([name isEqualToString:@"begin"]) {
    return TPOutlineDocumentColor;
  } else if ([name isEqualToString:@"part"]) {
    return TPOutlinePartColor;
  } else if ([name isEqualToString:@"chapter"]) {
    return TPOutlineChapterColor;
  } else if ([name isEqualToString:@"section"]) {
    return TPOutlineSectionColor;
  } else if ([name isEqualToString:@"subsection"]) {
    return TPOutlineSubsectionColor;
  } else if ([name isEqualToString:@"subsubsection"]) {
    return TPOutlineSubsubsectionColor;
  } else if ([name isEqualToString:@"paragraph"]) {
    return TPOutlineParagraphColor;
  } else if ([name isEqualToString:@"subparagraph"]) {
    return TPOutlineSubparagraphColor;
  } else {
    return nil;
  }
    
}

- (NSColor*) colorForSectionName:(NSString*)name
{
  for (TPSectionTemplate *s in self.templates) {
    if ([s.name isEqualToString:name]) {
      NSString *prefName = [self preferenceNameForSection:name];
      if (prefName) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *colorVals = [defaults valueForKey:prefName];
        if (colorVals) {
          return [colorVals colorValue];
        }
      }
    }
  }
  
  return [NSColor blackColor];
}

- (void) setColor:(NSColor*)color forName:(NSString*)name
{
  NSString *prefName = [self preferenceNameForSection:name];
  if (prefName) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *colorVals = [NSArray arrayWithColor:color];
    [defaults setValue:colorVals forKey:prefName];
    [self setColorForName:name withPreferenceName:prefName];
  }
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

- (NSArray*) tagsForSection:(NSString*)section
{
  for (TPSectionTemplate *sec in self.templates) {
    if ([sec.name isEqualToString:section]) {
      return sec.tags;
    }
  }
  return nil;
}

- (void) setTags:(NSArray*)tags forSection:(NSString*)section
{
  for (TPSectionTemplate *sec in self.templates) {
    if ([sec.name isEqualToString:section]) {
      sec.tags = tags;
      [self saveTemplates];
    }
  }
}

- (NSArray*) sectionCommands
{
  NSMutableArray *cmds = [NSMutableArray array];
  for (TPSectionTemplate *sec in self.templates) {
    [cmds addObjectsFromArray:sec.tags];
  }
  
  return [NSArray arrayWithArray:cmds];
}

- (NSArray*) sectionNames
{
  NSMutableArray *cmds = [NSMutableArray array];
  for (TPSectionTemplate *sec in self.templates) {
    [cmds addObject:sec.name];
  }
  
  return [NSArray arrayWithArray:cmds];
}


@end
