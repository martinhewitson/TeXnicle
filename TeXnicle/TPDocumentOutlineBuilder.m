//
//  TPDocumentOutlineBuilder.m
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPDocumentOutlineBuilder.h"
#import "FileEntity.h"
#import "NSArray+DocumentTemplates.h"
#import "NSString+Comparisons.h"
#import "NSString+LaTeX.h"

@implementation TPDocumentOutlineBuilder

@synthesize templates;
@synthesize delegate;

+ (TPDocumentOutlineBuilder*)outlineBuilderWithDelegate:(id<DocumentOutlineBuilderDelegate>)aDelegate
{
  return [[[TPDocumentOutlineBuilder alloc] initWithDelegate:aDelegate] autorelease];
}

- (id)initWithDelegate:(id<DocumentOutlineBuilderDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    
    // make templates
    [self makeTemplates];
  }
  return self;
}

- (void) dealloc
{
  self.delegate = nil;
  self.templates = nil;
  [super dealloc];
}

- (void) makeTemplates
{
  self.templates = [NSMutableArray array];
  
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"document" tag:@"\\begin{document}" order:0]];
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"part" tag:@"\\part" order:1]];
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"chapter" tag:@"\\chapter" order:2]];
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"section" tag:@"\\section" order:3]];
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"subsection" tag:@"\\subsection" order:4]];
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"subsubsection" tag:@"\\subsubsection" order:5]];
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"paragraph" tag:@"\\paragraph" order:6]];
  [self.templates addObject:[TPDocumentSectionTemplate documentSectionTemplateWithName:@"subparagraph" tag:@"\\subparagraph" order:7]];
}

- (TPDocumentSection*) buildDocumentOutline
{
  if ([self project] != nil) {
    return [self generateSectionsForProject];
  } else if ([self fileURL] != nil) {
    return [self generateSectionsForFile];
  } else {
    return nil;
  }
}

- (TPDocumentSection*) generateSectionsForFile
{
  
}

- (TPDocumentSection*) generateSectionsForProject
{
//  NSLog(@"Generating sections for project...");
  TPDocumentSection *documentSection = nil;
  
	ProjectEntity *project = [self.delegate project];
	if (!project)
		return nil;
	
	FileEntity *mainFile = [project valueForKey:@"mainFile"];
	if (!mainFile)
		return nil;
  
  // search for begin document
	NSString *string = mainFile.consolidatedFileContents;
  
  
	if (!string)
		return nil;
	
  NSScanner *aScanner = [NSScanner scannerWithString:string];
	
  TPDocumentSectionTemplate *docTemplate = [self.templates orderedFirstTemplate];
  
	NSString *tag = [docTemplate tag];
	if ([aScanner scanUpToString:tag intoString:NULL]) {
		
		NSInteger loc = [aScanner scanLocation];
		if (loc < 0 || loc >= [string length])
			return nil;
    
    documentSection = [TPDocumentSection sectionWithRange:NSMakeRange(loc, [tag length]-1)
                                             type:docTemplate
                                             name:@"Document"
                                         document:mainFile];
    
    [self parseString:string forSection:documentSection followingSection:nil startingOrder:1];
        
    
  } // end scan for begin document  
  
	
  
  return documentSection;
}

- (void) parseString:(NSString*)string forSection:(TPDocumentSection*)section followingSection:(TPDocumentSection*)nextSection startingOrder:(NSInteger)order
{
//  NSLog(@"Parsing %@ starting order %ld", section.name, order);
  
  while ([section.subsections count] == 0 && order < 10) {
    // template for next order
    NSArray *higherOrderTemplates = [self.templates templatesWithOrder:order];
    for (TPDocumentSectionTemplate *t in higherOrderTemplates) {
      // go through the string and get all these orders
      NSInteger startIndex = NSMaxRange(section.range);
      NSInteger endIndex = [string length]-1;
      if (nextSection) {
        endIndex = nextSection.range.location;
      }
      [self addSectionsToSection:section fromString:string forTemplate:t inRange:NSMakeRange(startIndex, endIndex-startIndex+1)];
    }      
    
    order++;
  }
  
  // do subsections now
  NSInteger nSubsections = [section.subsections count];
  for (NSInteger ssCount = 0; ssCount<nSubsections; ssCount++) {
    TPDocumentSection *subsection = [section.subsections objectAtIndex:ssCount];
    TPDocumentSection *nextSection = nil;
    if (ssCount+1 < nSubsections) {
      nextSection = [section.subsections objectAtIndex:ssCount+1];
    }
    [self parseString:string forSection:subsection followingSection:nextSection startingOrder:order];
  }
  
}

- (void) addSectionsToSection:(TPDocumentSection*)section fromString:(NSString*)string forTemplate:(TPDocumentSectionTemplate*)aTemplate inRange:(NSRange)aRange
{
  NSLog(@"Scanning in range %@ for template %@", NSStringFromRange(aRange), aTemplate.tag);
  NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];

  NSString *tag = aTemplate.tag;

  
  // ### REPLACE WITH NSSCANNER
  NSString *scanString = [[[string substringWithRange:aRange] stringByTrimmingCharactersInSet:ns] stringByTrimmingCharactersInSet:ws];
  NSLog(@"Scanning %@", scanString);
  NSScanner *scanner = [NSScanner scannerWithString:scanString];
  NSInteger scanLocation = 0;
  while (scanLocation < [scanString length]) {
    
    if ([scanner scanUpToString:tag intoString:NULL]) {
      
      scanLocation = [scanner scanLocation];
      if (scanLocation == [scanString length]) {
        NSLog(@"end of string");
        break;
      }
      
      NSLog(@"Found tag at %ld", scanLocation);
      TPDocumentSection *newSection = [self parseSection:aTemplate fromString:string startingFrom:aRange.location+scanLocation];
      if (newSection) {
        NSLog(@"Added section %@", newSection);
        [section addSubsection:newSection];
        [scanner setScanLocation:scanLocation+[tag length]];
      }                   
      
      
    } else {
      if (scanLocation == 0) {
        // first string?
        NSLog(@"Checking for first string...");
        if ([scanString hasPrefix:tag]) {
          NSLog(@"Tag found at start of string.");
          TPDocumentSection *newSection = [self parseSection:aTemplate fromString:string startingFrom:aRange.location];
          if (newSection) {
            NSLog(@"Added section %@", newSection);
            [section addSubsection:newSection];
            [scanner setScanLocation:scanLocation+[tag length]];
          }                   
        } else {
          NSLog(@"No tag at start of string");
          break;
        }
      } else {
//        NSLog(@"No tag found in string");
        break;
      }
    }
    
    
  }
  

  
//  // scan this file for sections
////  NSLog(@"Scanning for tag '%@'...", tag);
//  NSUInteger loc = aRange.location;
//  NSInteger strLen = [string length];
//  while (loc < NSMaxRange(aRange) && loc < strLen) {
//    NSString *word = [string nextWordStartingAtLocation:&loc];
////    word = [word stringByTrimmingCharactersInSet:ws];
//    word = [word stringByTrimmingCharactersInSet:ns];
//    // check tag
//    if ([word hasPrefix:tag]) {
//      TPDocumentSection *newSection = [self parseSection:aTemplate fromString:string startingFrom:loc-[word length]+1];
//      if (newSection) {
//        [section addSubsection:newSection];
//        //          NSLog(@"   added section %@ to %@", newSection, newSection.document.name);
//      }           
//    }
//    
//    loc++;    
//  }
}




- (TPDocumentSection*) parseSection:(TPDocumentSectionTemplate*)aTemplate fromString:(NSString*)string startingFrom:(NSInteger)loc
{
//  NSLog(@"Parsing %@ starting at %ld", aTemplate.tag, loc);
  NSInteger count = loc;
  NSString *name = [string parseArgumentStartingAt:&count];
  if (name) {
    NSRange tagRange = NSMakeRange(loc, count-loc+1);
//    name = [string substringWithRange:tagRange];
    TPDocumentSection *foundSection = [TPDocumentSection sectionWithRange:tagRange
                                                                     type:aTemplate
                                                                     name:name
                                                                 document:nil];
//    NSLog(@"   made section %@", foundSection);
    return foundSection;
  }      

  return nil;
}

#pragma mark -
#pragma mark Delegate

- (ProjectEntity*)project
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(project)]) {
    return [self.delegate project];
  }
  return nil;
}

- (NSURL*)fileURL
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileURL)]) {
    return [self.delegate fileURL];
  }
  return nil;
}

- (NSAttributedString*)documentString
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(documentString)]) {
    return [self.delegate documentString];
  }
  return nil;
}


@end
