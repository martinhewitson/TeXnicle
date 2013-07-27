//
//  TestLogParserTests.m
//  TestLogParserTests
//
//  Created by Martin Hewitson on 23/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TPTeXLogParser.h"
#import "TPLogItem.h"
#import "NSArray+LogParser.h"
#import "NSString+LogParser.h"

@interface TestLogParserTests : SenTestCase

@end

@implementation TestLogParserTests

- (void)setUp
{
  [super setUp];
  
  // Set-up code here.
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}


- (NSString*)stringFromTestFile:(NSString*)name
{
  NSArray *encodings = @[@(NSASCIIStringEncoding),
                         @(NSUTF8StringEncoding),
                         @(NSUTF16StringEncoding),
                         @(NSUTF16LittleEndianStringEncoding),
                         @(NSUTF16BigEndianStringEncoding),
                         @(NSISOLatin1StringEncoding),
                         @(NSISOLatin2StringEncoding),
                         @(NSMacOSRomanStringEncoding),
                         @(NSWindowsCP1251StringEncoding)];
  
  
  NSError *error = nil;
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *path = [bundle pathForResource:name ofType:@"log"];
  NSStringEncoding encoding;
  NSString *string = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] usedEncoding:&encoding error:&error];
  if (string == nil) {
    for (NSNumber *enc in encodings) {
      string = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:[enc integerValue] error:NULL];
      if (string != nil) {
        break;
      }
    }
    if (string == nil) {
      STFail(@"Failed to load %@.log [%@]", name, error);
    }
  }
  return string;
}

- (void)testFilenameParsing
{
  NSString *str = @"(/usr/local/texlive/2013/texmf-dist/tex/generic/oberdiek/ltxcmds.sty";
  NSString *filename = [str filename];
  NSLog(@"[%@]", filename);
  
  STAssertNotNil(filename, @"Filename shouldn't be nil");
  
}

- (void)testEmptyLog
{
  NSString *logtext = @"";
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 0, @"Empty log should produce no log items");
}

- (void)testParseFilename1
{
  NSString *filename = @"./myFile.tex";
  NSString *logtext = [NSString stringWithFormat:@"(%@ (some other thing)\n Info: message", filename];
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 1, @"Info line should produce a single log item");
  
  TPLogItem *item = items[0];
  
  STAssertTrue([item.filepath isEqualToString:filename], @"Filename should be [%@], not [%@]", filename, item.filepath);
  STAssertTrue(item.type == TPLogInfo, @"Item type should be Info, not %@", item.typeName);
  STAssertTrue(item.linenumber == NSNotFound, @"Line number should be NSNotFound, not %ld", item.linenumber);
}

- (void)testParseFilename2
{
  NSString *filename = @"./myFile.tex";
  NSString *logtext = [NSString stringWithFormat:@"(%@\n Some other thing\n Info: message", filename];
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 1, @"Info line should produce a single log item");
  
  TPLogItem *item = items[0];
  
  STAssertTrue([item.filepath isEqualToString:filename], @"Filename should be %@, not %@", filename, item.filepath);
  STAssertTrue(item.type == TPLogInfo, @"Item type should be Info, not %@", item.typeName);
  STAssertTrue(item.linenumber == NSNotFound, @"Line number should be NSNotFound, not %ld", item.linenumber);
}

//(etexcmds)             That can mean that you are not using pdfTeX 1.50 or
- (void)testParseFilename3
{
  NSString *logtext = @"(etexcmds)             That can mean that you are not using pdfTeX 1.50 or";
  NSString *filename = [logtext filename];
  
  STAssertTrue(filename == nil, @"Filename should be nil, not %@", filename);
}


- (void)testInfoLine1
{
  NSString *filename = @"/somepath/myFile.tex";
  NSString *message = @"LuaTeX not detected.";
  NSString *logtext = [NSString stringWithFormat:@"(%@\nPackage ifluatex Info: %@\n)", filename, message];
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 1, @"Info line should produce a single log item");
  
  TPLogItem *item = items[0];
  
  STAssertTrue([item.file isEqualToString:[[filename lastPathComponent] stringByStandardizingPath]], @"Filename should be %@, not %@", filename, item.file);
  STAssertTrue([item.filepath isEqualToString:filename], @"Filepath should be %@, not %@", filename, item.filepath);
  STAssertTrue([item.message isEqualToString:message], @"Message should be [%@], not [%@]", message, item.message);
  STAssertTrue(item.type == TPLogInfo, @"Item type should be Info, not %@", item.typeName);
  STAssertTrue(item.linenumber == NSNotFound, @"Line number should be NSNotFound, not %ld", item.linenumber);
}

// Package hyperref Info: Option `plainpages' set `false' on input line 4319.
- (void)testInfoLine2
{
  NSInteger linenumber = 4319;
  NSString *filename = @"/a/path/to/myFile.tex";
  NSString *message = [NSString stringWithFormat:@"Option `plainpages' set `false' on input line %ld.", linenumber];
  NSString *logtext = [NSString stringWithFormat:@"(%@\nPackage hyperref Info: %@\n)", filename, message];
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 1, @"Info line should produce a single log item");
  
  TPLogItem *item = items[0];
  
  STAssertTrue([item.file isEqualToString:[[filename lastPathComponent] stringByStandardizingPath]], @"Filename should be %@, not %@", filename, item.file);
  STAssertTrue([item.filepath isEqualToString:filename], @"Filepath should be %@, not %@", filename, item.filepath);
  STAssertTrue([item.message isEqualToString:message], @"Message should be [%@], not [%@]", message, item.message);
  STAssertTrue(item.type == TPLogInfo, @"Item type should be Info, not %@", item.typeName);
  STAssertTrue(item.linenumber == linenumber, @"Line number should be NSNotFound, not %ld", item.linenumber);
}

// Package thumbpdf Warning: Compressed PDF objects of PDF 1.5 are not supported.
- (void)testWarningLine1
{
  NSString *filename = @"./myFile.tex";
  NSString *message = @"Compressed PDF objects of PDF 1.5 are not supported.";
  NSString *logtext = [NSString stringWithFormat:@"(%@\nPackage thumbpdf Warning: %@\n)", filename, message];
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 1, @"Warning line should produce a single log item");
  
  TPLogItem *item = items[0];
  
  STAssertTrue([item.filepath isEqualToString:filename], @"Filepath should be %@, not %@", filename, item.filepath);
  STAssertTrue([item.file isEqualToString:[[filename lastPathComponent] stringByStandardizingPath]], @"Filename should be %@, not %@", filename, item.file);
  STAssertTrue([item.message isEqualToString:message], @"Message should be [%@], not [%@]", message, item.message);
  STAssertTrue(item.type == TPLogWarning, @"Item type should be Warning, not %@", item.typeName);
  STAssertTrue(item.linenumber == NSNotFound, @"Line number should be NSNotFound, not %ld", item.linenumber);
}

- (void)testWarningLine2
{
  NSInteger linenumber = 1;
  NSString *filename = @"./myFile.tex";
  NSString *message = @"Compressed PDF objects of PDF 1.5 are not supported.";
  NSString *logtext = [NSString stringWithFormat:@"(%@\nPackage thumbpdf Warning:%ld: %@\n)", filename, linenumber, message];
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 1, @"Warning line should produce a single log item");
  
  TPLogItem *item = items[0];
  
  STAssertTrue([item.filepath isEqualToString:filename], @"Filepath should be %@, not %@", filename, item.filepath);
  STAssertTrue([item.file isEqualToString:[[filename lastPathComponent] stringByStandardizingPath]], @"Filename should be %@, not %@", filename, item.file);
  STAssertTrue([item.message isEqualToString:message], @"Message should be [%@], not [%@]", message, item.message);
  STAssertTrue(item.type == TPLogWarning, @"Item type should be Warning, not %@", item.typeName);
  STAssertTrue(item.linenumber == linenumber, @"Line number should be %ld, not %ld", linenumber, item.linenumber);
}

//./MyArticle_main.tex:24: LaTeX Error: \bibitemsep undefined.
- (void)testError1
{
  NSInteger linenumber = 24;
  NSString *filename = @"/a/myFile.tex";
  NSString *message = @"\bibitemsep undefined.";
  NSString *logtext = [NSString stringWithFormat:@"(%@\n:%ld: LaTeX Error: %@\n)", filename, linenumber, message];
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 1, @"Warning line should produce a single log item");
  
  TPLogItem *item = items[0];
  
  STAssertTrue([item.filepath isEqualToString:filename], @"Filepath should be %@, not %@", filename, item.filepath);
  STAssertTrue([item.file isEqualToString:[[filename lastPathComponent] stringByStandardizingPath]], @"Filename should be %@, not %@", filename, item.file);
  STAssertTrue([item.message isEqualToString:message], @"Message should be [%@], not [%@]", message, item.message);
  STAssertTrue(item.type == TPLogError, @"Item type should be Error, not %@", item.typeName);
  STAssertTrue(item.linenumber == linenumber, @"Line number should be %ld, not %ld", linenumber, item.linenumber);
}

// contains 14 Info, 0 error, 0 warning
- (void)testLog1
{
  NSString *logtext = [self stringFromTestFile:@"log1"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 14, @"log1.log should produce 14 items, not %ld items", [items count]);
  
  
  for (TPLogItem *item in items) {
    STAssertTrue(item.type == TPLogInfo, @"The item [%@] should be an INFO", item);
  }  
}

// contains Emergency stop in introduction.tex
- (void)testLog2
{
  NSString *logtext = [self stringFromTestFile:@"log2"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 2, @"log2.log should produce 2 items, not %ld items", [items count]);

  TPLogItem *item = items[0];

  NSString *filename = @"introduction.tex";
  STAssertTrue([item.file isEqualToString:filename], @"Filename should be %@, not %@", filename, item.file);
  STAssertTrue(item.type == TPLogError, @"Item should be an Error, not %@", item.typeName);
}

// contains TeX memory error phrase and many warnings and info
- (void)testLog3
{
  NSString *logtext = [self stringFromTestFile:@"log3"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 149, @"log3.log should produce 149 items, not %ld items", [items count]);

  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 117, @"The log file should contain 117 info itmes, not %ld", [info count]);
  
  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 31, @"The log file should contain 31 warning itmes, not %ld", [warnings count]);

  NSArray *errors = [items errorItems];
  STAssertTrue([errors count] == 1, @"The log file should contain 1 error, not %ld", [errors count]);
}

// contains successful run with various warnings and info
- (void)testLog4
{
  NSString *logtext = [self stringFromTestFile:@"log4"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 216, @"log4.log should produce 216 items, not %ld items", [items count]);
  
  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 45, @"The log file should contain 45 info itmes, not %ld", [info count]);

  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 171, @"The log file should contain 171 warning itmes, not %ld", [warnings count]);

  NSArray *errors = [items errorItems];
  STAssertTrue([errors count] == 0, @"The log file should contain 0 errors, not %ld", [errors count]);
}

// contains
- (void)testLog5
{
  NSString *logtext = [self stringFromTestFile:@"log5"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  NSLog(@"%@", items);
  
  STAssertTrue([items count] == 2, @"log5.log should produce 2 items, not %ld items", [items count]);
  
  TPLogItem *item = items[0];
  
  NSString *filename = @"glossary.tex";
  STAssertTrue([item.file isEqualToString:filename], @"Filename should be %@, not %@", filename, item.file);
  STAssertTrue(item.type == TPLogError, @"Item should be an Error, not %@", item.typeName);
}

// contains successful run with various warnings and info
- (void)testLog6
{
  NSString *logtext = [self stringFromTestFile:@"log6"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 310, @"log6.log should produce 310 items, not %ld items", [items count]);
  
  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 143, @"The log file should contain 143 info itmes, not %ld", [info count]);
  
  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 167, @"The log file should contain 167 warning itmes, not %ld", [warnings count]);
  
  NSArray *errors = [items errorItems];
  STAssertTrue([errors count] == 0, @"The log file should contain 0 errors, not %ld", [errors count]);
}

// contains successful run with various warnings and info
- (void)testLog7
{
  NSString *logtext = [self stringFromTestFile:@"log7"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  NSLog(@"%@", items);
  
  STAssertTrue([items count] == 290, @"log7.log should produce 290 items, not %ld items", [items count]);
  
  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 288, @"The log file should contain 288 info itmes, not %ld", [info count]);
  
  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 2, @"The log file should contain 2 warning itmes, not %ld", [warnings count]);
  
  NSArray *errors = [items errorItems];
  STAssertTrue([errors count] == 0, @"The log file should contain 0 errors, not %ld", [errors count]);
}

// contains successful run with various warnings and info
- (void)testLog8
{
  NSString *logtext = [self stringFromTestFile:@"log8"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  NSLog(@"%@", items);
  
  STAssertTrue([items count] == 87, @"log8.log should produce 87 items, not %ld items", [items count]);
  
  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 87, @"The log file should contain 87 info itmes, not %ld", [info count]);
  
  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 0, @"The log file should contain 0 warning itmes, not %ld", [warnings count]);
  
  NSArray *errors = [items errorItems];
  STAssertTrue([errors count] == 0, @"The log file should contain 0 errors, not %ld", [errors count]);
}

// contains 2 errors with various warnings and info
- (void)testLog9
{
  NSString *logtext = [self stringFromTestFile:@"log9"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  NSLog(@"%@", items);
  
  STAssertTrue([items count] == 3, @"log9.log should produce 3 items, not %ld items", [items count]);
  
  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 1, @"The log file should contain 1 info itmes, not %ld", [info count]);
  
  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 0, @"The log file should contain 0 warning itmes, not %ld", [warnings count]);
  
  NSArray *errors = [items errorItems];
  STAssertTrue([errors count] == 2, @"The log file should contain 2 errors, not %ld", [errors count]);
}

// contains successful run with various warnings and info
- (void)testLog10
{
  NSString *logtext = [self stringFromTestFile:@"log10"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  NSLog(@"%@", items);
  
  STAssertTrue([items count] == 41, @"log10.log should produce 41 items, not %ld items", [items count]);
  
  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 41, @"The log file should contain 41 info itmes, not %ld", [info count]);
  
  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 0, @"The log file should contain 0 warning itmes, not %ld", [warnings count]);
  
  NSArray *errors = [items errorItems];
  STAssertTrue([errors count] == 0, @"The log file should contain 0 errors, not %ld", [errors count]);
}

// contains broken run with various warnings and info
- (void)testLog11
{
  NSString *logtext = [self stringFromTestFile:@"log11"];
  
  NSArray *items = [TPTeXLogParser parseLogText:logtext];
  
  STAssertTrue([items count] == 202, @"log11.log should produce 202 items, not %ld items", [items count]);
  
  NSArray *info = [items infoItems];
  STAssertTrue([info count] == 0, @"The log file should contain 0 info itmes, not %ld", [info count]);
  
  NSArray *warnings = [items warningItems];
  STAssertTrue([warnings count] == 189, @"The log file should contain 189 warning itmes, not %ld", [warnings count]);
  
  NSArray *errors = [items errorItems];
  NSLog(@"%@", errors);
  STAssertTrue([errors count] == 13, @"The log file should contain 9 errors, not %ld", [errors count]);
}

@end
