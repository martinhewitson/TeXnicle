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

@end
