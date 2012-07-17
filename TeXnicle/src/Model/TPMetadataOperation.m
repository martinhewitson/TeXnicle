//
//  TPMetadataOperation.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPMetadataOperation.h"
#import "RegexKitLite.h"
#import "NSString+LaTeX.h"
#import "NSString+SectionsOutline.h"
#import "FileDocument.h"
#import "BibliographyEntry.h"
#import "TPNewCommand.h"

@implementation TPMetadataOperation

@synthesize text;

// inputs
@synthesize file;

// metadata
@synthesize commands;
@synthesize citations;
@synthesize syntaxErrors;
@synthesize labels;

- (id) initWithFile:(FileEntity*)aFile
{
  self = [super init];
  if (self) {
    self.text = [aFile workingContentString];
    self.file = aFile;
  }
  return self;
}

- (void) dealloc
{
  self.file = nil;
  self.commands = nil;
  self.citations = nil;
  self.syntaxErrors = nil;
  self.labels = nil;
  
  [super dealloc];
}


-(void)main {
  @try {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
//    NSLog(@"Generating meta data for %@", self.file.name);
    
    //-------------- get commands
    if ([self isCancelled]) return;
    NSMutableArray *newCommands = [NSMutableArray array];
    NSArray *parsedCommands = [self.text componentsMatchedByRegex:@"\\\\newcommand\\{\\\\[a-zA-Z]*\\}"];
    for (NSString *newCommand in parsedCommands) {
      [newCommands addObject:[TPNewCommand commandWithSource:newCommand]];
    }
    self.commands = [NSArray arrayWithArray:newCommands];
    
    //-------------- get citatations
    if ([self isCancelled]) return;
    NSMutableArray *newCitations = [NSMutableArray array];
    NSArray *citationsFound = [self.text citations];		
    [newCitations addObjectsFromArray:citationsFound];			
    
    // add any citations from a bibliography entries
    if ([self isCancelled]) return;
    NSArray *entries = [BibliographyEntry bibtexEntriesFromString:self.text];
    [newCitations addObjectsFromArray:entries];
    
    self.citations = [NSArray arrayWithArray:newCitations];
        
    //--------------- Labels    
    if ([self isCancelled]) return;
    self.labels = [self.text referenceLabels];			
    
    
    [pool release];
  }
  @catch(...) {
    // Do not rethrow exceptions.
  }
}



@end
