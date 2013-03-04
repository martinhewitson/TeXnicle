//
//  PlaceholderTests.m
//  TeXnicle
//
//  Created by Martin Hewitson on 03/03/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "PlaceholderTests.h"
#import "NSAttributedString+Placeholders.h"
#import "MHPlaceholderAttachment.h"
#import "NSMutableAttributedString+Placeholders.h"

@implementation PlaceholderTests


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

- (void) testStringWithPlaceholdersRestored_01
{
  
  NSString *test = @"@replace@";
  
  NSAttributedString *replaced = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // length should be 1
  STAssertTrue([replaced length] == 1, @"Returned string [%@] should have length 1", replaced);
  
  // it should have an attachment at the first character
  NSRange effRange;
  NSTextAttachment *att = [replaced attribute:NSAttachmentAttributeName
                                      atIndex:0
                               effectiveRange:&effRange];
  
  STAssertTrue(att != nil, @"First character should have an attachment");
  STAssertTrue([att isKindOfClass:[MHPlaceholderAttachment class]], @"Attachement should be an MHPlaceholderAttachment");
  
  // placeholder display text should be 'replace'
  NSTextAttachmentCell *cell = (NSTextAttachmentCell*)[att attachmentCell];
  NSAttributedString *code = [cell attributedStringValue];
  STAssertTrue([[code string] isEqualToString:@"replace"], @"The placeholder should display 'replace'");
}

- (void) testStringWithPlaceholdersRestored_02
{
  
  NSString *test = @"a @replace@ holder";
  
  NSAttributedString *replaced = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // length should be 10
  STAssertTrue([replaced length] == 10, @"Returned string should have length 10");
  
  // it should have an attachment at the 3rd character
  NSRange effRange;
  NSTextAttachment *att = [replaced attribute:NSAttachmentAttributeName
                                      atIndex:2
                               effectiveRange:&effRange];
  
  STAssertTrue(att != nil, @"Third character should have an attachment");
  STAssertTrue([att isKindOfClass:[MHPlaceholderAttachment class]], @"Attachement should be an MHPlaceholderAttachment");
  
  // placeholder display text should be 'replace'
  NSTextAttachmentCell *cell = (NSTextAttachmentCell*)[att attachmentCell];
  NSAttributedString *code = [cell attributedStringValue];
  STAssertTrue([[code string] isEqualToString:@"replace"], @"The placeholder should display 'replace'");
}

- (void) testStringWithPlaceholdersRestored_03
{
  
  NSString *test = @"a @nice@ holder of @places@ to replace";
  
  NSAttributedString *replaced = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // length should be 26
  STAssertTrue([replaced length] == 26, @"Returned string should have length 26");
  
  // it should have an attachment at the 3rd character
  NSRange effRange;
  NSTextAttachment *att = [replaced attribute:NSAttachmentAttributeName
                                      atIndex:2
                               effectiveRange:&effRange];
  
  STAssertTrue(att != nil, @"Third character should have an attachment");
  STAssertTrue([att isKindOfClass:[MHPlaceholderAttachment class]], @"Attachement should be an MHPlaceholderAttachment");
  
  // placeholder display text should be 'replace'
  NSTextAttachmentCell *cell = (NSTextAttachmentCell*)[att attachmentCell];
  NSAttributedString *code = [cell attributedStringValue];
  STAssertTrue([[code string] isEqualToString:@"nice"], @"The placeholder should display 'nice'");
  
  // it should have an attachment at the 3rd character
  att = [replaced attribute:NSAttachmentAttributeName
                    atIndex:14
             effectiveRange:&effRange];
  
  STAssertTrue(att != nil, @"15th character should have an attachment");
  STAssertTrue([att isKindOfClass:[MHPlaceholderAttachment class]], @"Attachement should be an MHPlaceholderAttachment");
  
  // placeholder display text should be 'replace'
  cell = (NSTextAttachmentCell*)[att attachmentCell];
  code = [cell attributedStringValue];
  STAssertTrue([[code string] isEqualToString:@"places"], @"The placeholder should display 'places'");
}


- (void) testStringWithPlaceholdersRestored_04
{
  
  NSString *test = @"\\section{@replace@}";
  
  NSAttributedString *replaced = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // length should be 11
  STAssertTrue([replaced length] == 11, @"Returned string should have length 11");
  
  // it should have an attachment at the 10th character
  NSRange effRange;
  NSTextAttachment *att = [replaced attribute:NSAttachmentAttributeName
                                      atIndex:9
                               effectiveRange:&effRange];
  
  STAssertTrue(att != nil, @"10th character should have an attachment");
  STAssertTrue([att isKindOfClass:[MHPlaceholderAttachment class]], @"Attachement should be an MHPlaceholderAttachment");
  
  // placeholder display text should be 'replace'
  NSTextAttachmentCell *cell = (NSTextAttachmentCell*)[att attachmentCell];
  NSAttributedString *code = [cell attributedStringValue];
  STAssertTrue([[code string] isEqualToString:@"replace"], @"The placeholder should display 'replace'");
}

- (void) testStringWithPlaceholdersRestored_05
{
  
  NSString *test = [NSString stringWithFormat:@"a @string which \n should not be a placeholder@"];
  
  NSAttributedString *replaced = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // length should be 11
  STAssertTrue([replaced length] == [test length], @"Returned string should have same length as original");
  
}

- (void) testStringWithPlaceholdersRestored_06
{
  
  NSString *test = [self stringFromTestFile:@"placeholderTest1"];
  
  NSAttributedString *replaced = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // length should be 11
  STAssertTrue([replaced length] == [test length], @"Returned string should have same length as original");
  
}


- (void) testStringWithPlaceholdersRestored_07
{
  
  NSString *test = @"@replace@";
 
  // replace placeholders
  NSAttributedString *restored = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // restore placeholders
  NSAttributedString *replaced = [restored replacePlaceholders];

  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // string should be same as before
  STAssertTrue([[replaced string] isEqualToString:test], @"Restored/replaced string should be as original");  
}

- (void) testStringWithPlaceholdersRestored_08
{
  
  NSString *test = @"some \\section{@replace@} string";
  
  // replace placeholders
  NSAttributedString *restored = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // restore placeholders
  NSAttributedString *replaced = [restored replacePlaceholders];
  
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // string should be same as before
  STAssertTrue([[replaced string] isEqualToString:test], @"Restored/replaced string should be as original");
}

- (void) testStringWithPlaceholdersRestored_09
{
  
  NSString *test = [self stringFromTestFile:@"placeholderTest1"];
  
  // replace placeholders
  NSAttributedString *restored = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // restore placeholders
  NSAttributedString *replaced = [restored replacePlaceholders];
  
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // string should be same as before
  STAssertTrue([[replaced string] isEqualToString:test], @"Restored/replaced string should be as original");
}

- (void) testStringWithPlaceholdersRestored_10
{
  
  NSString *test = [self stringFromTestFile:@"placeholderTest2"];
  
  // replace placeholders
  NSAttributedString *restored = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // restore placeholders
  NSAttributedString *replaced = [restored replacePlaceholders];
  
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // string should be same as before
  STAssertTrue([[replaced string] isEqualToString:test], @"Restored/replaced string should be as original");
}


- (void) testStringWithPlaceholdersRestored_11
{
  
  NSString *test = @"\\href{mailto:xy@gmail.com}{xy@gmail.com}.";
  
  // replace placeholders
  NSAttributedString *restored = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(restored != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([restored isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // string should be same as before
  STAssertTrue([[restored string] isEqualToString:test], @"Restored string [%@] should be as original", restored);
}

@end
