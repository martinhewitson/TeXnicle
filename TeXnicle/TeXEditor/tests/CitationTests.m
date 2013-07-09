//
//  CitationTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 8/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "NSString+LaTeX.h"
#import "BibliographyEntry.h"

@interface CitationTests : SenTestCase

@end

@implementation CitationTests


- (NSString*)stringFromTestFile:(NSString*)name extension:(NSString*)ext
{
  NSError *error = nil;
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *path = [bundle pathForResource:name ofType:ext];
  NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  if (string == nil) {
    STFail(@"Failed to load %@.tex [%@]", name, error);
  }
  return string;
}

- (void)setUp
{
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
  // Put teardown code here; it will be run once, after the last test case.
  [super tearDown];
}

- (void)testNoCitations
{
  NSString *str = @"my string with no citation";
  NSArray *citations = [str citations];
  STAssertTrue([citations count] == 0, @"The string contains no citations");
}

- (void)testNoCitations2
{
  NSString *str = @"my string with no citation \\bibitemstuff";
  NSArray *citations = [str citations];
  STAssertTrue([citations count] == 0, @"The string contains no citations");
}

- (void)testCitation1
{
  NSString *tag = @"one";
  NSString *str = [NSString stringWithFormat:@"Here is a \\bibitem{%@}", tag];
  NSArray *citations = [str citations];
  NSLog(@"Got %ld citations:", [citations count]);
  NSLog(@"%@", citations);
  STAssertTrue([citations count] == 1, @"The string should contain one citation, but it contains %ld", [citations count]);
  
}

- (void)testCitationOption
{
  NSString *tag = @"one";
  NSString *str = [NSString stringWithFormat:@"Here is a \\bibitem[option]{%@} with an option", tag];
  NSArray *citations = [str citations];
  NSLog(@"Got %ld citations:", [citations count]);
  NSLog(@"%@", citations);
  STAssertTrue([citations count] == 1, @"The string should contain one citation, but it contains %ld", [citations count]);
  
  BibliographyEntry *e = citations[0];
  STAssertTrue([e.tag isEqualToString:tag], @"The tag should be [%@] not [%@]", tag, e.tag);
  
}


- (void)testCitationCommented
{
  NSString *tag = @"one";
  NSString *str = [NSString stringWithFormat:@"%%Here is a \\bibitem[option]{%@} with an option", tag];
  NSArray *citations = [str citations];
  NSLog(@"Got %ld citations:", [citations count]);
  NSLog(@"%@", citations);
  STAssertTrue([citations count] == 0, @"The string should contain no citations, but it contains %ld", [citations count]);
}

- (void)testCitationCommented2
{
  NSString *tag = @"one";
  NSString *str = [NSString stringWithFormat:@"Here is a %% comment \\bibitem[option]{%@} with an option", tag];
  NSArray *citations = [str citations];
  NSLog(@"Got %ld citations:", [citations count]);
  NSLog(@"%@", citations);
  STAssertTrue([citations count] == 0, @"The string should contain no citations, but it contains %ld", [citations count]);
}

- (void)testCitationFile1
{
  NSString *str = [self stringFromTestFile:@"citation_test1" extension:@"tex"];
  NSArray *citations = [str citations];
  NSLog(@"Got %ld citations:", [citations count]);
  NSLog(@"%@", citations);
  STAssertTrue([citations count] == 3, @"The string should contain 3 citations, but it contains %ld", [citations count]);
}

- (void)testCitationFile2
{
  NSString *str = [self stringFromTestFile:@"citation_test2" extension:@"tex"];
  NSArray *citations = [str citations];
  NSLog(@"Got %ld citations:", [citations count]);
  NSLog(@"%@", citations);
  STAssertTrue([citations count] == 2, @"The string should contain 2 citations, but it contains %ld", [citations count]);
}


- (void)testBibTeXEntriesFromString1
{
  NSString *str = [self stringFromTestFile:@"citations1" extension:@"bib"];
  NSArray *entries = [BibliographyEntry bibtexEntriesFromString:str];
  NSLog(@"Entries %@", entries);
  
  STAssertTrue([entries count] == 34, @"The string should contain 34 entries, but it contains %ld", [entries count]);
}

- (void)testBibTeXEntriesFromString2
{
  NSString *str = [self stringFromTestFile:@"citations2" extension:@"bib"];
  NSArray *entries = [BibliographyEntry bibtexEntriesFromString:str];
  NSLog(@"Entries %@", entries);
  
  STAssertTrue([entries count] == 3, @"The string should contain 3 entries, but it contains %ld", [entries count]);
  
  // First should be Bender00
  BibliographyEntry *e1 = entries[0];
  STAssertTrue([e1.tag isEqualToString:@"Bender00"], @"The first entry should have the tag [Bender00], not [%@]", e1.tag);
  
  // Second should be numrec
  BibliographyEntry *e2 = entries[1];
  STAssertTrue([e2.tag isEqualToString:@"numrec"], @"The second entry should have the tag [numrec], not [%@]", e2.tag);
  
  // Third should be numrec
  BibliographyEntry *e3 = entries[2];
  STAssertTrue([e3.tag isEqualToString:@"ST7"], @"The third entry should have the tag [ST7], not [%@]", e3.tag);
}

@end
