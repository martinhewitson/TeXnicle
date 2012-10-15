//
//  NSStringReformattingPrivateTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSStringReformattingPrivateTests.h"

#import "NSString+Reformatting.h"
#import "NSString+Reformatting_Private.h"


@implementation NSStringReformattingPrivateTests


// TODO - test for end index, test for indentation
//   -endIndexForReformattingFromIndex:
//   -indentationForReformattingFromIndex:

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

- (void) testLineIsEmptyAtIndex
{
  NSString *string = nil;
  BOOL result;
  
  // test 1 - simple string
  string = @"not empty";
  result = [string lineIsEmptyAtIndex:3];
  STAssertFalse(result, @"Test 1: the line is not empty");
  
  // test 2 - empty string
  string = @"";
  result = [string lineIsEmptyAtIndex:0];
  STAssertTrue(result, @"Test 2: the line is empty");
  
  // test 3 - multiple lines
  string = [NSString stringWithFormat:@"some\n\ncommand which has a command"];
  result = [string lineIsEmptyAtIndex:5];
  STAssertTrue(result, @"Test 3: the line is empty");
    
}


- (void) testCommandNameStartingAtIndex
{
  NSString *string = nil;
  NSString *command = nil;
  
  // test 1 - simple string
  string = [NSString stringWithFormat:@"some string which has no command"];
  command = [string commandNameStartingAtIndex:0];
  STAssertNil(command, @"Test 1: the text contains no command");
  
  // test 2 - command
  string = [NSString stringWithFormat:@"some \\command which has a command"];
  command = [string commandNameStartingAtIndex:5];
  STAssertTrue([command isEqualToString:@"\\command"], @"Test 2: the text contains the command [\\command]");

  // test 3 - command with args
  string = [NSString stringWithFormat:@"some \\command{argument} which has a command"];
  command = [string commandNameStartingAtIndex:5];
  STAssertTrue([command isEqualToString:@"\\command"], @"Test 3: the text contains the command [\\command]");
  
  // test 4 - command at beginning
  string = [NSString stringWithFormat:@"\\command{argument} which has a command"];
  command = [string commandNameStartingAtIndex:0];
  STAssertTrue([command isEqualToString:@"\\command"], @"Test 4: the text contains the command [\\command]");
  
}

- (void) testLineContainingIndexIsCommented
{
  
  NSString *string = nil;
  BOOL result;
  
  // test 1 - simple string
  string = [NSString stringWithFormat:@" some string which covers \n more than one line "];
  result = [string lineIsCommentedBeforeIndex:5];
  STAssertFalse(result, @"Test 1: The text is not commented");
  
  // test 2 - commented string
  string = @"% some string which is a comment";
  result = [string lineIsCommentedBeforeIndex:5];
  STAssertTrue(result, @"Test 2: The test is commented");
  
  // test 3 - multiple lines, not commented
  string = [NSString stringWithFormat:@" some string \n more than one line "];
  result = [string lineIsCommentedBeforeIndex:20];
  STAssertFalse(result, @"Test 3: The text is not commented");
  
  // test 4 - multiple lines, 2nd line commented
  string = [NSString stringWithFormat:@" some string \n%% more than one line "];
  result = [string lineIsCommentedBeforeIndex:20];
  STAssertTrue(result, @"Test 4: The text is commented");
  
  // test 5 - comment within line
  string = [NSString stringWithFormat:@" some string %% more than one line "];
  result = [string lineIsCommentedBeforeIndex:20];
  STAssertTrue(result, @"Test 5: The text is commented");
  
  // test 6 - escaped comment within line
  string = [NSString stringWithFormat:@" some string \\%% more than one line "];
  result = [string lineIsCommentedBeforeIndex:20];
  STAssertFalse(result, @"Test 6: The text is not commented");
  
  
}

- (void)testStartEndIndexForReformattingFromIndex_blankLinesTests
{
  NSInteger startIndex, endIndex;
  NSString *string = nil;
  
  //-----------------------------------------------------------------------
  // Test 1 - some multiline text which has a blank line before
  //          and after
  //          start from index 139
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 1", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile4"];
  // the startIndex should be 2, end index 218
  startIndex = [string startIndexForReformattingFromIndex:139];
  endIndex = [string endIndexForReformattingFromIndex:139];
  STAssertEquals(startIndex, 2l, @"Start index should be 2");
  STAssertEquals(endIndex, 218l, @"End index should be 218");
  
  //-----------------------------------------------------------------------
  // Test 2 - a single line of text
  //          start from index 139
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 2", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = @"just some text to reformat";
  // the startIndex should be 0, end should be 26
  startIndex = [string startIndexForReformattingFromIndex:13];
  endIndex   = [string endIndexForReformattingFromIndex:13];
  STAssertEquals(startIndex, 0l, @"Start index should be 0");
  STAssertEquals(endIndex, 26l, @"End index should be 26");
  
  //-----------------------------------------------------------------------
  // Test 3 - some lines of text
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 3", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [NSString stringWithFormat:@"test\n\njust some text to reformat\n\nmore text"];
  // the startIndex should be 6, end should be 32
  startIndex = [string startIndexForReformattingFromIndex:15];
  endIndex   = [string endIndexForReformattingFromIndex:15];
  STAssertEquals(startIndex, 6l, @"Start index should be 6");
  STAssertEquals(endIndex, 32l, @"End index should be 32");
  
  
  
}

- (void) testStartIndexForReformattingFromIndex_itemTests
{
  NSInteger startIndex, endIndex;
  NSString *string = nil;
  
  //-----------------------------------------------------------------------
  // Test 1 - some text which is part of a \item list
  //          start from index 70
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 1", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile5"];
  // the startIndex should be 51, end should be 100
  startIndex = [string startIndexForReformattingFromIndex:70];
  endIndex   = [string endIndexForReformattingFromIndex:70];
  STAssertEquals(startIndex, 51l, @"Start index should be 51");
  STAssertEquals(endIndex, 100l, @"Start index should be 100");
  
  //-----------------------------------------------------------------------
  // Test 2 - a single \item command
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 2", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = @"\\item one";
  // the startIndex should be 0, end should be 9
  startIndex = [string startIndexForReformattingFromIndex:5];
  endIndex   = [string endIndexForReformattingFromIndex:5];
  STAssertEquals(startIndex, 0l, @"Start index should be 0");
  STAssertEquals(endIndex, 9l, @"Start index should be 9");
  
  //-----------------------------------------------------------------------
  // Test 3 - a single \item command preceded by some text
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 3", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = @"some text \\item one";
  // the startIndex should be 10, end should be 19
  startIndex = [string startIndexForReformattingFromIndex:15];
  endIndex   = [string endIndexForReformattingFromIndex:15];
  STAssertEquals(startIndex, 10l, @"Start index should be 10");
  STAssertEquals(endIndex, 19l, @"Start index should be 19");

  //-----------------------------------------------------------------------
  // Test 4 - a single \item command preceded by some text followed by blank line
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 4", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [NSString stringWithFormat:@"some text \\item one\n\nsome more text"];
  // the startIndex should be 10, end should be 19
  startIndex = [string startIndexForReformattingFromIndex:15];
  endIndex   = [string endIndexForReformattingFromIndex:15];
  STAssertEquals(startIndex, 10l, @"Start index should be 10");
  STAssertEquals(endIndex, 19l, @"Start index should be 19");

  //-----------------------------------------------------------------------
  // Test 5 - a single \item command preceded and followed by blank lines
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 5", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [NSString stringWithFormat:@"\n\n\\item one\n\nsome more text"];
  // the startIndex should be 2, end should be 11
  startIndex = [string startIndexForReformattingFromIndex:6];
  endIndex   = [string endIndexForReformattingFromIndex:6];
  STAssertEquals(startIndex, 2l, @"Start index should be 2");
  STAssertEquals(endIndex, 11l, @"Start index should be 11");
  
}

- (void)testStartIndexForReformattingFromIndex_argumentTests
{
  NSInteger startIndex, endIndex;
  NSString *string = nil;
  
  //-----------------------------------------------------------------------
  // Test 1 - simple paragraph containing no arguments; start from char 140
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 1", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile1"];
  // the startIndex should be 75, end is 406
  startIndex = [string startIndexForReformattingFromIndex:140];
  endIndex = [string endIndexForReformattingFromIndex:140];
  STAssertEquals(startIndex, 75l, @"Start index should be 75");
  STAssertEquals(endIndex, 406l, @"Start index should be 406");
  
  //-----------------------------------------------------------------------
  // Test 2 - simple paragraph containing an argument before the point where
  //          we start; start from char 180
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 2", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile2"];
  // the startIndex should be 105, end at 443
  startIndex = [string startIndexForReformattingFromIndex:180];
  endIndex = [string endIndexForReformattingFromIndex:180];
  STAssertEquals(startIndex, 105l, @"Start index should be 105");
  STAssertEquals(endIndex, 443l, @"End index should be 443");
  
  //-----------------------------------------------------------------------
  // Test 3 - simple paragraph containing an argument and we start within
  //          the argument; start from char 155
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 3", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile2"];
  // the startIndex should be 146, end 166
  startIndex = [string startIndexForReformattingFromIndex:155];
  endIndex = [string endIndexForReformattingFromIndex:155];
  STAssertEquals(startIndex, 146l, @"Start index should be 146");
  STAssertEquals(endIndex, 166l, @"End index should be 166");
  
  //-----------------------------------------------------------------------
  // Test 4 - a paragraph containing an argument within an argument and we
  //          start within the outer argument but after the inner argument;
  //          start from char 120
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 4", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile3"];
  // the startIndex should be 68, end at 157
  startIndex = [string startIndexForReformattingFromIndex:120];
  endIndex = [string endIndexForReformattingFromIndex:120];
  STAssertEquals(startIndex, 68l, @"Start index should be 68");
  STAssertEquals(endIndex, 157l, @"End index should be 157");
  
  //-----------------------------------------------------------------------
  // Test 5 - a paragraph containing an argument within an argument and we
  //          start within the inner argument;
  //          start from char 109
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 5", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile3"];
  // the startIndex should be 108, end at 110
  startIndex = [string startIndexForReformattingFromIndex:109];
  endIndex = [string endIndexForReformattingFromIndex:109];
  STAssertEquals(startIndex, 108l, @"Start index should be 108");
  STAssertEquals(endIndex, 110l, @"End index should be 110");
  
  //-----------------------------------------------------------------------
  // Test 6 - a paragraph containing an argument within an argument and we
  //          start before the inner argument;
  //          start from char 109
  NSLog(@"=============================================================================");
  NSLog(@" %@/%@ - TEST 6", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"=============================================================================");
  string = [self stringFromTestFile:@"reformatTextTestFile3"];
  // the startIndex should be 68, end at 157
  startIndex = [string startIndexForReformattingFromIndex:94];
  endIndex = [string endIndexForReformattingFromIndex:94];
  STAssertEquals(startIndex, 68l, @"Start index should be 68");
  STAssertEquals(endIndex, 157l, @"End index should be 157");
  
  
  
}


@end
