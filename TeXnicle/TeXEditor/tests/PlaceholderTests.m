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

@implementation PlaceholderTests

- (void) testStringWithPlaceholdersRestored_1
{
  
  NSString *test = @"@replace@";
  
  NSAttributedString *replaced = [NSAttributedString stringWithPlaceholdersRestored:test];
  
  // check that we get an nsattributed string
  STAssertTrue(replaced != nil, @"Returned NSAttributedString should not be nil");
  STAssertTrue([replaced isKindOfClass:[NSAttributedString class]], @"Returned object should be an NSAttributedString");
  
  // length should be 1
  STAssertTrue([replaced length] == 1, @"Returned string should have length 1");
  
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

- (void) testStringWithPlaceholdersRestored_2
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

@end
