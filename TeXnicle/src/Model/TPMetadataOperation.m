//
//  TPMetadataOperation.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPMetadataOperation.h"
#import "NSString+LaTeX.h"
#import "NSString+SectionsOutline.h"
#import "FileDocument.h"
#import "BibliographyEntry.h"
#import "TPNewCommand.h"
#import "TPNewEnvironment.h"
#import "TPLabel.h"
#import "TPToDo.h"
#import "TPRegularExpression.h"

@interface TPMetadataOperation ()

@end

@implementation TPMetadataOperation

- (id) initWithFile:(TPFileMetadata*)aFile
{
  self = [super init];
  if (self) {
    self.file = aFile;
  }
  return self;
}



-(void)main {
  @try {
    
    // NSLog(@"Scanning metadata on thread %@", [NSThread currentThread]);
    
    if (self.file.text == nil || [self.file.text length] ==0)
      return;
    
    NSMutableArray *newCommands = [[NSMutableArray alloc] init];
    NSMutableArray *newEnvironments = [[NSMutableArray alloc] init];
    NSMutableArray *newCitations = [[NSMutableArray alloc] init];
    NSMutableArray *newLabels = [[NSMutableArray alloc] init];
    NSMutableArray *newToDos = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
    
    
      NSString *ext = self.file.extension;
      
      //-------------- get commands
      if ([self isCancelled]) return;
      NSArray *parsedCommands = [TPRegularExpression stringsMatching:@"\\\\newcommand\\{\\\\[a-zA-Z]*\\}" inText:self.file.text];
      for (NSString *str in parsedCommands) {
        TPNewCommand *c = [[TPNewCommand alloc] initWithSource:str];
        [newCommands addObject:c];
        if ([self isCancelled]) return;
      }
      
      parsedCommands = [TPRegularExpression stringsMatching:@"\\\\renewcommand\\{\\\\[a-zA-Z]*\\}" inText:self.file.text];
      if ([self isCancelled]) return;
      for (NSString *str in parsedCommands) {
        TPNewCommand *c = [[TPNewCommand alloc] initWithSource:str];
        [newCommands addObject:c];
        if ([self isCancelled]) return;
      }
      
      parsedCommands = [TPRegularExpression stringsMatching:@"\\\\providecommand\\{\\\\[a-zA-Z]*\\}" inText:self.file.text];
      if ([self isCancelled]) return;
      for (NSString *str in parsedCommands) {
        TPNewCommand *c = [[TPNewCommand alloc] initWithSource:str];
        [newCommands addObject:c];
        if ([self isCancelled]) return;
      }
      
      //-------------- get environments
      if ([self isCancelled]) return;
      NSArray *parsedEnvironments = [TPRegularExpression stringsMatching:@"\\\\newenvironment\\{[a-zA-Z]*\\}" inText:self.file.text];
      for (NSString *str in parsedEnvironments) {
        TPNewEnvironment *c = [[TPNewEnvironment alloc] initWithSource:str];
        [newEnvironments addObject:c];
        if ([self isCancelled]) return;
      }
      
      //-------------- get citatations
      if ([self isCancelled]) return;
      
      // don't check bst files.
      if ([ext isEqualToString:@"bst"] == NO) {
        // get \bibitem entries
        NSArray *citationsFound = [self.file.text citations];
        if ([self isCancelled]) return;
        [newCitations addObjectsFromArray:citationsFound];
        
        // citations from any bib files included in this file but not in the project
        if ([self isCancelled]) return;
        NSArray *entries = [self.file.text citationsFromBibliographyIncludedFromPath:self.file.pathOnDisk];
        //NSLog(@"Collected %ld entries from included bib file", [entries count]);
        [newCitations addObjectsFromArray:entries];
      }
      
      // add any citations from any bib files
      if ([self isCancelled]) return;
      if ([ext isEqualToString:@"bib"]) {
        NSArray *entries = [BibliographyEntry bibtexEntriesFromString:self.file.text];
        //NSLog(@"Collected %ld entries from project bib file", [entries count]);
        if ([self isCancelled]) return;
        // only add these if we don't already have entries for these
        for (BibliographyEntry *entry in entries) {
          // check against existing
          BOOL foundIt = NO;
          for (BibliographyEntry *e in newCitations) {
            if ([e isEqual:entry]) {
              foundIt = YES;
              break;
            }
            if ([self isCancelled]) return;
          }
          
          // if we didn't find it, add it
          if (foundIt == NO) {
            [newCitations addObject:entry];
          }          
        }
      }
      
      //--------------- Labels    
      if ([self isCancelled]) return;
      
      NSArray *parsedLabels = [self.file.text referenceLabels];
      for (NSString *str in parsedLabels) {
        TPLabel *l = [[TPLabel alloc] initWithFile:self.file text:str];
        [newLabels addObject:l];
        if ([self isCancelled]) return;
      }
    
      //--------------- ToDos
      if ([self isCancelled]) return;
      
      NSArray *parsedToDos = [self.file.text toDos];
      for (NSString *str in parsedToDos) {
        TPToDo *td = [[TPToDo alloc] initWithFile:self.file text:str];
        [newToDos addObject:td];
        if ([self isCancelled]) return;
      }
    }
    
    if ([self isCancelled]) return;
    self.commands = newCommands;
    self.environments = newEnvironments;
    self.citations = newCitations;
    self.labels = newLabels;
    self.toDos = newToDos;
    
  }
  @catch(...) {
    // Do not rethrow exceptions.
  }
}



@end
