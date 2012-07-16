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

@implementation TPMetadataOperation

@synthesize text;

// inputs
@synthesize file;

// metadata
@synthesize commands;
@synthesize citations;
@synthesize syntaxErrors;

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
  
  [super dealloc];
}


-(void)main {
  @try {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableArray *newCommands = [NSMutableArray array];
    
    //-------------- get commands
    NSArray *parsedCommands = [self.text componentsMatchedByRegex:@"\\\\newcommand\\{\\\\[a-zA-Z]*\\}"];
    for (NSString *newCommand in parsedCommands) {
      [newCommands addObject:[newCommand argument]];
    }
    
    //-------------- get citatations
    NSMutableArray *newCitations = [NSMutableArray array];
    NSArray *docTags = [self.text citations];			
    [newCitations addObjectsFromArray:docTags];			
    
    // add any citations from a \bibliography{} command
    [newCitations addObjectsFromArray:[self.text citationsFromBibliographyIncludedFromPath:self.file.pathOnDisk]];
        
    
    // update metadata        
    self.commands = newCommands;
    self.citations = newCitations;
    
    [pool release];
  }
  @catch(...) {
    // Do not rethrow exceptions.
  }
}



@end
