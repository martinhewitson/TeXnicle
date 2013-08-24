//
//  LaTeXStringTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSString+LaTeX.h"

@interface LaTeXStringTests : SenTestCase

@end

@implementation LaTeXStringTests

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

- (void)testCommentLine
{
  NSString *str = [NSString stringWithFormat:@"%% This is a commented out line"];

  BOOL commented = [str isCommentLineBeforeIndex:10 commentChar:@"%"];
  STAssertTrue(commented, @"The string is commented");
  
}

- (void)testNonCommentLine
{
  NSString *str = [NSString stringWithFormat:@"This is a non-commented out line"];
  
  BOOL commented = [str isCommentLineBeforeIndex:10 commentChar:@"%"];
  STAssertTrue(commented==NO, @"The string is not commented");
  
}

- (void)testNonCommentLine2
{
  NSString *str = [NSString stringWithFormat:@"This \\%% is a non-commented out line"];
  
  BOOL commented = [str isCommentLineBeforeIndex:10 commentChar:@"%"];
  STAssertTrue(commented==NO, @"The string is not commented");
  
}

- (void)testOptionParse
{
  NSString *tag = @"one";
  NSString *str = [NSString stringWithFormat:@"a \\bibitem[option]{%@} with an option", tag];
  NSString *option = [str parseOptionStartingAtIndex:0];
  STAssertNotNil(option, @"The option should be [option] and not nil");
  STAssertTrue([option isEqualToString:@"option"], @"The option should be [option] and not [%@]", option);
  
}

- (void)testCharacterIsEscapedAtIndex1
{
  NSString *s = @"my \\{ char";
  BOOL result = [s characterIsEscapedAtIndex:4];
  STAssertTrue(result, @"Character is escaped");
}

- (void)testCharacterIsEscapedAtIndex2
{
  NSString *s = @"my { char";
  BOOL result = [s characterIsEscapedAtIndex:4];
  STAssertFalse(result, @"Character is not escaped");
}

- (void)testIsInArgumentAtIndex
{
  NSString *s = @"my { char }";
  BOOL result = [s isInArgumentAtIndex:7];
  STAssertFalse(result, @"Is not in argument at index 7");
}

- (void)testIsInArgumentAtIndex2
{
  NSString *s = @"my \\{ char \\}";
  BOOL result = [s isInArgumentAtIndex:7];
  STAssertFalse(result, @"Is not in argument at index 7");
}

- (void)testIsInArgumentAtIndex3
{
  NSString *s = @"{\\command{one} some}";
  BOOL result = [s isInArgumentAtIndex:17];
  STAssertFalse(result, @"We are not in an argument at index 17");
}

// \usepackage[pdftex]{graphicx}
- (void)testIsInArgumentAtIndex4
{
  NSString *s = @"\\usepackage[pdftex]{graphicx}";
  BOOL result = [s isInArgumentAtIndex:24];
  STAssertTrue(result, @"We are in an argument at index 24");
}

- (void)testIsCommandBeforeIndex
{
  NSString *s = @"my \\{ char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  STAssertFalse(result, @"There is no command before index 7");
}

- (void)testIsCommandBeforeIndex2
{
  NSString *s = @"my \\{char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  STAssertFalse(result, @"There is no command before index 7");
}

- (void)testIsCommandBeforeIndex3
{
  NSString *s = @"my \\command{char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  STAssertTrue(result, @"There is a command before index 7");
}

- (void)testIsCommandBeforeIndex4
{
  NSString *s = @"my \\command{char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  STAssertTrue(result, @"There is a command before index 7");
}

- (void)testIsCommandBeforeIndex5
{
  NSString *s = @"my string with no command in it";
  BOOL result = [s isCommandBeforeIndex:14];
  STAssertFalse(result, @"There is no command before index 14");
}

- (void)testIsCommandBeforeIndex6
{
  NSString *s = @"\\command{one}";
  BOOL result = [s isCommandBeforeIndex:0];
  STAssertFalse(result, @"There is a command before index 0");
}

- (void)testIsCommandBeforeIndex7
{
  NSString *s = @"my nice \\command{one}";
  BOOL result = [s isCommandBeforeIndex:0];
  STAssertFalse(result, @"There is no command before index 0");
}


- (void)testIsCommandBeforeIndex8
{
  NSString *s = @"{\\command{one}]";
  BOOL result = [s isCommandBeforeIndex:12];
  STAssertTrue(result, @"There is a command before index 12");
}

- (void)testIsCommandBeforeIndex9
{
  NSString *s = @"{\\command{one} some}";
  BOOL result = [s isCommandBeforeIndex:17];
  STAssertFalse(result, @"There is no command before index 17");
}

- (void)testIsCommandBeforeIndex10
{
  NSString *s = @"\\usepackage[pdftex]{graphicx}";
  BOOL result = [s isCommandBeforeIndex:24];
  STAssertTrue(result, @"There is a command before index 24");
}

@end
