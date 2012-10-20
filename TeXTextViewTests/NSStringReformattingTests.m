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
  
  
}



@end
