//
//  LaTeXStringTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+LaTeX.h"

@interface LaTeXStringTests : XCTestCase

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
  XCTAssertTrue(commented, @"The string is commented");
  
}

- (void)testNonCommentLine
{
  NSString *str = [NSString stringWithFormat:@"This is a non-commented out line"];
  
  BOOL commented = [str isCommentLineBeforeIndex:10 commentChar:@"%"];
  XCTAssertTrue(commented==NO, @"The string is not commented");
  
}

- (void)testNonCommentLine2
{
  NSString *str = [NSString stringWithFormat:@"This \\%% is a non-commented out line"];
  
  BOOL commented = [str isCommentLineBeforeIndex:10 commentChar:@"%"];
  XCTAssertTrue(commented==NO, @"The string is not commented");
  
}

- (void)testOptionParse
{
  NSString *tag = @"one";
  NSString *str = [NSString stringWithFormat:@"a \\bibitem[option]{%@} with an option", tag];
  NSString *option = [str parseOptionStartingAtIndex:0];
  XCTAssertNotNil(option, @"The option should be [option] and not nil");
  XCTAssertTrue([option isEqualToString:@"option"], @"The option should be [option] and not [%@]", option);
  
}

- (void)testCharacterIsEscapedAtIndex1
{
  NSString *s = @"my \\{ char";
  BOOL result = [s characterIsEscapedAtIndex:4];
  XCTAssertTrue(result, @"Character is escaped");
}

- (void)testCharacterIsEscapedAtIndex2
{
  NSString *s = @"my { char";
  BOOL result = [s characterIsEscapedAtIndex:4];
  XCTAssertFalse(result, @"Character is not escaped");
}

- (void)testIsInArgumentAtIndex
{
  NSString *s = @"my { char }";
  BOOL result = [s isInArgumentAtIndex:7];
  XCTAssertFalse(result, @"Is not in argument at index 7");
}

- (void)testIsInArgumentAtIndex2
{
  NSString *s = @"my \\{ char \\}";
  BOOL result = [s isInArgumentAtIndex:7];
  XCTAssertFalse(result, @"Is not in argument at index 7");
}

- (void)testIsInArgumentAtIndex3
{
  NSString *s = @"{\\command{one} some}";
  BOOL result = [s isInArgumentAtIndex:17];
  XCTAssertFalse(result, @"We are not in an argument at index 17");
}

// \usepackage[pdftex]{graphicx}
- (void)testIsInArgumentAtIndex4
{
  NSString *s = @"\\usepackage[pdftex]{graphicx}";
  BOOL result = [s isInArgumentAtIndex:24];
  XCTAssertTrue(result, @"We are in an argument at index 24");
}

- (void)testIsCommandBeforeIndex
{
  NSString *s = @"my \\{ char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  XCTAssertFalse(result, @"There is no command before index 7");
}

- (void)testIsCommandBeforeIndex2
{
  NSString *s = @"my \\{char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  XCTAssertFalse(result, @"There is no command before index 7");
}

- (void)testIsCommandBeforeIndex3
{
  NSString *s = @"my \\command{char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  XCTAssertTrue(result, @"There is a command before index 7");
}

- (void)testIsCommandBeforeIndex4
{
  NSString *s = @"my \\command{char \\}";
  BOOL result = [s isCommandBeforeIndex:7];
  XCTAssertTrue(result, @"There is a command before index 7");
}

- (void)testIsCommandBeforeIndex5
{
  NSString *s = @"my string with no command in it";
  BOOL result = [s isCommandBeforeIndex:14];
  XCTAssertFalse(result, @"There is no command before index 14");
}

- (void)testIsCommandBeforeIndex6
{
  NSString *s = @"\\command{one}";
  BOOL result = [s isCommandBeforeIndex:0];
  XCTAssertFalse(result, @"There is a command before index 0");
}

- (void)testIsCommandBeforeIndex7
{
  NSString *s = @"my nice \\command{one}";
  BOOL result = [s isCommandBeforeIndex:0];
  XCTAssertFalse(result, @"There is no command before index 0");
}


- (void)testIsCommandBeforeIndex8
{
  NSString *s = @"{\\command{one}]";
  BOOL result = [s isCommandBeforeIndex:12];
  XCTAssertTrue(result, @"There is a command before index 12");
}

- (void)testIsCommandBeforeIndex9
{
  NSString *s = @"{\\command{one} some}";
  BOOL result = [s isCommandBeforeIndex:17];
  XCTAssertTrue(result, @"There is a command before index 17");
}

- (void)testIsCommandBeforeIndex10
{
  NSString *s = @"\\usepackage[pdftex]{graphicx}";
  BOOL result = [s isCommandBeforeIndex:24];
  XCTAssertTrue(result, @"There is a command before index 24");
}

- (void)testCommandAtIndex1
{
  NSString *s = @"\\usepackage[pdftex]{graphicx}";
  NSString *cmd = [s commandAtIndex:24];
  XCTAssertTrue(cmd != nil, @"There is a command at index 24");
}

- (void)testCommandAtIndex2
{
  NSString *s = @"\\command{\\command{some}}";
  NSString *cmd = [s commandAtIndex:5];
  XCTAssertTrue(cmd != nil, @"There is a command at index 5");
}

- (void)testCommandAtIndex3
{
  NSString *s = @"\\command{\\command{some}}";
  NSString *cmd = [s commandAtIndex:20];
  XCTAssertTrue(cmd != nil, @"There is a command at index 20");
}

- (void)testCommandAtIndex4
{
  NSString *s = @"command{\\command{some}}";
  NSString *cmd = [s commandAtIndex:3];
  XCTAssertFalse(cmd != nil, @"There is no command at index 3");
  cmd = [s commandAtIndex:12];
  XCTAssertTrue(cmd != nil, @"There is a command at index 12");
}

- (void)testCommandAtIndex5
{
  NSString *s = @"\\command";
  NSString *cmd = [s commandAtIndex:3];
  XCTAssertTrue(cmd != nil, @"There is a command at index 3");
}

- (void)testCommandAtIndex6
{
  NSString *s = @"\\command[opt1][option two]{argument1}{argument two}";
  NSString *cmd = [s commandAtIndex:11];
  XCTAssertTrue(cmd != nil, @"There is a command at index 11");
  cmd = [s commandAtIndex:19];
  XCTAssertTrue(cmd != nil, @"There is a command at index 19");
  cmd = [s commandAtIndex:31];
  XCTAssertTrue(cmd != nil, @"There is a command at index 31");
  cmd = [s commandAtIndex:43];
  XCTAssertTrue(cmd != nil, @"There is a command at index 43");
}


- (void)testIsArgumentOfCommandAtIndex
{
  NSString *s = @"command{\\command{some}}";
  BOOL result = [s isArgumentOfCommandAtIndex:3];
  XCTAssertFalse(result, @"There is no command at index 3");
  result = [s isArgumentOfCommandAtIndex:12];
  XCTAssertTrue(result, @"There is a command at index 12");
}

- (void)testIsArgumentOfCommandAtIndex2
{
  NSString *s = @"\\command[opt]{some}";
  BOOL result = [s isArgumentOfCommandAtIndex:17];
  XCTAssertTrue(result, @"There is a command at index 17");
}


- (void)testIsInMathAtIndex1
{
  NSString *s = @"some text with no math";
  BOOL result = [s isInMathAtIndex:10];
  XCTAssertFalse(result, @"There is no math mode here!");
}

- (void)testIsInMathAtIndex2
{
  NSString *s = @"some $x<<<y$ and $y>>>z$.";
  BOOL result = [s isInMathAtIndex:9];
  XCTAssertTrue(result, @"We are in math mode at index 9.");
}

- (void)testIsInMathAtIndex3
{
  NSString *s = @"some $x<<<y$ and $y>>>z$.";
  BOOL result = [s isInMathAtIndex:21];
  XCTAssertTrue(result, @"We are in math mode at index 21.");
}

- (void)testIsInMathAtIndex4
{
  NSString *s = @"\\begin{equation} x<y & y>z \\end{equation}";
  BOOL result = [s isInMathAtIndex:21];
  XCTAssertTrue(result, @"We are in math mode at index 21.");
}

- (void)testIsInMathAtIndex5
{
  NSString *s = @"\\begin{eqnarray} x<y & y>z \\end{eqnarray}";
  BOOL result = [s isInMathAtIndex:21];
  XCTAssertTrue(result, @"We are in math mode at index 21.");
}

- (void)testIsInMathAtIndex6
{
  NSString *s = @"\\begin{matrix} \
  x<y & y>z \
  \\end{matrix}";
  BOOL result = [s isInMathAtIndex:21];
  XCTAssertTrue(result, @"We are in math mode at index 21.");
}


@end
