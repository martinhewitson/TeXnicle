//
//  NSStringReformattingTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSStringReformattingTests.h"
#import "NSString+Reformatting.h"

@implementation NSStringReformattingTests

- (NSString*)stringFromTestFile:(NSString*)name
{
  NSError *error = nil;
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *path = [bundle pathForResource:name ofType:@"tex"];
  NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  if (string == nil) {
    STFail(@"Failed to load %@.tex [%@]", name, error);
  }
  return string;
}

- (void) testReformatStartingAtIndexForLinewidth
{
  
  NSString *string = nil;
  NSString *newString = nil;
  NSString *testString = nil;
  
  //-----------------------------------------------------------------------
  // Test 1 - simple paragraph containing no arguments; start from char 140
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 1", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile1"];
  testString = [self stringFromTestFile:@"reformatTextTestFile1_reformatted"];
  newString = [string reformatStartingAtIndex:140 forLinewidth:20];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Reconsituted text should be as the original");
  
  //-----------------------------------------------------------------------
  // Test 2 - simple string
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 2", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = @"some text which will be formatted and then unformatted to test against each other";
  newString = [string reformatStartingAtIndex:10 forLinewidth:40];
  testString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
  // check test string is the same as the original
  STAssertTrue([testString isEqualToString:string], @"Reconsituted text should be as the original");
  
  //-----------------------------------------------------------------------
  // Test 3 - reformat text within an argument
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 3", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile3"];
  testString = [self stringFromTestFile:@"reformatTextTestFile3_reformatted"];
  newString = [string reformatStartingAtIndex:90 forLinewidth:40];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 4 - reformat \item
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 4", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile5"];
  testString = [self stringFromTestFile:@"reformatTextTestFile5_reformatted"];
  newString = [string reformatStartingAtIndex:64 forLinewidth:20];
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 5 - reformat \item with indent
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 5", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile6"];
  testString = [self stringFromTestFile:@"reformatTextTestFile6_reformatted"];
  newString = [string reformatStartingAtIndex:37 forLinewidth:30];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 6 - reformat \item with indent
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 6", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile7"];
  testString = [self stringFromTestFile:@"reformatTextTestFile7_reformatted"];
  newString = [string reformatStartingAtIndex:93 forLinewidth:45];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");

  //-----------------------------------------------------------------------
  // Test 7 - reformat \item which contains a command. Start before the command
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 7", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile8"];
  testString = [self stringFromTestFile:@"reformatTextTestFile8_reformatted"];
  newString = [string reformatStartingAtIndex:96 forLinewidth:45];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 8 - reformat \item which contains a command. Start after the command
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 8", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile8"];
  testString = [self stringFromTestFile:@"reformatTextTestFile8_reformatted"];
  newString = [string reformatStartingAtIndex:178 forLinewidth:45];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 9 - reformat \caption of a figure
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 9", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile9"];
  testString = [self stringFromTestFile:@"reformatTextTestFile9_reformatted"];
  newString = [string reformatStartingAtIndex:109 forLinewidth:80];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 10 - reformat a beamer \item set
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 10", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile10"];
  testString = [self stringFromTestFile:@"reformatTextTestFile10_reformatted"];
  newString = [string reformatStartingAtIndex:236 forLinewidth:45];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 11 - reformat an \item[xxx] set with blank lines between items
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 11", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile11"];
  testString = [self stringFromTestFile:@"reformatTextTestFile11_reformatted"];
  newString = [string reformatStartingAtIndex:113 forLinewidth:55];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
  //-----------------------------------------------------------------------
  // Test 12 - reformat an \item[xxx] set
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 12", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile12"];
  testString = [self stringFromTestFile:@"reformatTextTestFile12_reformatted"];
  newString = [string reformatStartingAtIndex:113 forLinewidth:55];
  NSLog(@"%@", newString);
  // check new string is the same as the hand formatted string
  STAssertTrue([newString isEqualToString:testString], @"Text should match result file");
  
}



@end
