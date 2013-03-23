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
#import "TPLabel.h"
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
    NSMutableArray *newCitations = [[NSMutableArray alloc] init];
    NSMutableArray *newLabels = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
    
    
      NSString *ext = self.file.extension;
      
      //-------------- get commands
      if ([self isCancelled]) return;
      NSArray *parsedCommands = [TPRegularExpression stringsMatching:@"\\\\newcommand\\{\\\\[a-zA-Z]*\\}" inText:self.file.text];
      for (NSString *str in parsedCommands) {
        TPNewCommand *c = [[TPNewCommand alloc] initWithSource:str];
        [newCommands addObject:c];
      }
      
      parsedCommands = [TPRegularExpression stringsMatching:@"\\\\renewcommand\\{\\\\[a-zA-Z]*\\}" inText:self.file.text];
      for (NSString *str in parsedCommands) {
        TPNewCommand *c = [[TPNewCommand alloc] initWithSource:str];
        [newCommands addObject:c];
      }
      
      parsedCommands = [TPRegularExpression stringsMatching:@"\\\\providecommand\\{\\\\[a-zA-Z]*\\}" inText:self.file.text];
      for (NSString *str in parsedCommands) {
        TPNewCommand *c = [[TPNewCommand alloc] initWithSource:str];
        [newCommands addObject:c];
      }
      
      //-------------- get citatations
      if ([self isCancelled]) return;
      
      // don't check bst files.
      if ([ext isEqualToString:@"bst"] == NO) {
        // get \bibitem entries
        NSArray *citationsFound = [self.file.text citations];
        [newCitations addObjectsFromArray:citationsFound];
        
        // citations from any bib files included in this file but not in the project
        if ([self isCancelled]) return;
        NSArray *entries = [self.file.text citationsFromBibliographyIncludedFromPath:self.file.pathOnDisk];
        [newCitations addObjectsFromArray:entries];
      }
      
      // add any citations from any bib files
      if ([self isCancelled]) return;
      if ([ext isEqualToString:@"bib"]) {
        NSArray *entries = [BibliographyEntry bibtexEntriesFromString:self.file.text];
        // only add these if we don't already have entries for these
        for (BibliographyEntry *entry in entries) {
          // check against existing
          for (BibliographyEntry *e in newCitations) {
            if (![[e string] isEqualToString:[entry string]]) {
              [newCitations addObject:entry];
            }
          }
        }
//        [newCitations addObjectsFromArray:entries];
      }
      
      //--------------- Labels    
      if ([self isCancelled]) return;
      
      NSArray *parsedLabels = [self.file.text referenceLabels];
      for (NSString *str in parsedLabels) {
        TPLabel *l = [[TPLabel alloc] initWithFile:self.file text:str];
        [newLabels addObject:l];
      }
    
    }
    
    self.commands = newCommands;
    self.citations = newCitations;
    self.labels = newLabels;
    
  }
  @catch(...) {
    // Do not rethrow exceptions.
  }
}



@end
