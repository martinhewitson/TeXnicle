//
//  TeXETextViewBraceTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 29/07/14.
//  Copyright (c) 2014 bobsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+LaTeX.h"

@interface TeXETextViewBraceTests : XCTestCase

@end

@implementation TeXETextViewBraceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1
{
  NSString *str = @"just a string";

  BOOL result = [str shouldCloseOpeningBracket:'{' with:'}' atLocation:3];
  
  XCTAssertTrue(result, @"Closing brace required");
  
}

- (void)test2
{
  NSString *str = @"open { close";
  
  BOOL result = [str shouldCloseOpeningBracket:'{' with:'}' atLocation:6];
  
  XCTAssertTrue(result, @"Closing brace required");
  
}

- (void)test3
{
  NSString *str = @"open {} close";
  
  BOOL result = [str shouldCloseOpeningBracket:'{' with:'}' atLocation:6];
  
  XCTAssertTrue(result, @"Closing brace not required");
  
}

- (void)test4
{
  NSString *str = @"open {{} close";
  
  BOOL result = [str shouldCloseOpeningBracket:'{' with:'}' atLocation:5];
  
  XCTAssertTrue(result, @"Closing brace required");
  
}

- (void)test5
{
  NSString *str = @"open {} close";
  
  BOOL result = [str shouldCloseOpeningBracket:'{' with:'}' atLocation:6];
  
  XCTAssertTrue(result, @"Closing brace required");
  
}

- (void)test6
{
  NSString *str = @"open {}} close";
  
  BOOL result = [str shouldCloseOpeningBracket:'{' with:'}' atLocation:6];
  
  XCTAssertFalse(result, @"Closing brace not required");
  
}

- (void)test7
{
  NSString *str = @"open } close";
  
  BOOL result = [str shouldCloseOpeningBracket:'{' with:'}' atLocation:5];
  
  XCTAssertFalse(result, @"Closing brace not required");
  
}


@end
