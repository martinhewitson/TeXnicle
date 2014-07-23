//
//  CiteCommandTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/07/14.
//  Copyright (c) 2014 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "NSString+LaTeX.h"

@interface CiteCommandTests : XCTestCase

@property (strong)  NSArray *commands;

@end

@implementation CiteCommandTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  self.commands = @[@"\\cite", @"\\cites"];
  
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

// check we get a command in
//    \cite{}
- (void) testCiteCommand1
{
  NSString *str = @"\\cite{}";
  BOOL state = [str inCiteCommands:self.commands atIndex:6];
  XCTAssertTrue(state, @"Index 6 is in citation command");
}

- (void) testCiteCommand2
{
  NSString *str = @"\\cite{some cite}";
  BOOL state = [str inCiteCommands:self.commands atIndex:8];
  XCTAssertTrue(state, @"Index 8 is in citation command");
}

- (void) testCiteCommand3
{
  NSString *str = @"\\spite{}";
  BOOL state = [str inCiteCommands:self.commands atIndex:5];
  XCTAssertFalse(state, @"Index 5 is not in citation command");
}

- (void) testCiteCommand4
{
  NSString *str = @"\\spite{some cite}";
  BOOL state = [str inCiteCommands:self.commands atIndex:8];
  XCTAssertFalse(state, @"Index 8 is not in citation command");
}

- (void) testCiteCommand5
{
  NSString *str = @"some text \\cite{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:19];
  XCTAssertTrue(state, @"Index 19 is in citation command");
}

- (void) testCiteCommand6
{
  NSString *str = @"some text \\cite[tag]{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:24];
  XCTAssertTrue(state, @"Index 24 is in citation command");
}

- (void) testCiteCommand7
{
  NSString *str = @"some text \\kite[tag]{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:24];
  XCTAssertFalse(state, @"Index 24 is not in citation command");
}

- (void) testCiteCommand8
{
  NSString *str = @"some text \\kite[tag]{some cite which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:24];
  XCTAssertFalse(state, @"Index 24 is not in citation command");
}

- (void) testCiteCommand9
{
  NSString *str = @"some text \\kite[tag{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:24];
  XCTAssertFalse(state, @"Index 24 is not in citation command");
}

- (void) testCiteCommand10
{
  NSString *str = @"some text \\cites[tag]{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:24];
  XCTAssertTrue(state, @"Index 24 is in citation command");
}

- (void) testCiteCommand11
{
  NSString *str = @"some text \\cites{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:19];
  XCTAssertTrue(state, @"Index 19 is in citation command");
}

- (void) testCiteCommand12
{
  NSString *str = @"some text \\cites{cite one}{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:19];
  XCTAssertTrue(state, @"Index 19 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:29];
  XCTAssertTrue(state, @"Index 29 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:26];
  XCTAssertFalse(state, @"Index 26 is not in citation command");
}

- (void) testCiteCommand13
{
  NSString *str = @"some text \\cites[tag]{cite one}{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:24];
  XCTAssertTrue(state, @"Index 19 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:34];
  XCTAssertTrue(state, @"Index 29 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:31];
  XCTAssertFalse(state, @"Index 26 is not in citation command");
}

- (void) testCiteCommand14
{
  NSString *str = @"some text \\cites{cite one}[tag]{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:19];
  XCTAssertTrue(state, @"Index 19 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:34];
  XCTAssertTrue(state, @"Index 29 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:31];
  XCTAssertFalse(state, @"Index 26 is not in citation command");
}

- (void) testCiteCommand15
{
  NSString *str = @"some text \\cites[23]{cite one}[tag]{some cite} which ends like this";
  BOOL state = [str inCiteCommands:self.commands atIndex:23];
  XCTAssertTrue(state, @"Index 19 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:38];
  XCTAssertTrue(state, @"Index 29 is in citation command");
  
  state = [str inCiteCommands:self.commands atIndex:35];
  XCTAssertFalse(state, @"Index 26 is not in citation command");
}

//    \cites{}{}      // currently doesn't work
//    \cites[]{}[]{}  // currently doesn't work



@end
