//
//  NSAttributedString+Placeholders.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "NSAttributedString+Placeholders.h"
#import "TPLibraryController.h"
#import "TPRegularExpression.h"
#import "MHPlaceholderAttachment.h"

@implementation NSAttributedString (Placeholders)

+ (NSAttributedString*) stringWithPlaceholdersRestored:(NSString*)string attributes:(NSDictionary*)attributes
{
  NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString stringWithPlaceholdersRestored:string]];
  
  [mstr addAttributes:attributes range:NSMakeRange(0, [mstr length])];
  return [[NSAttributedString alloc] initWithAttributedString:mstr];
}

+ (NSAttributedString*) stringWithPlaceholdersRestored:(NSString*)string
{
  // Replace placeholders
  NSString *regexp = [TPLibraryController placeholderRegexp];
  NSArray *ranges = nil;
  NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:string];
  NSInteger maxCount = 1000;
  NSInteger count = 0;
  do
  {
    ranges = [TPRegularExpression rangesMatching:regexp inText:[atr string]];
    for (NSValue *rv in ranges) {
      NSRange r = [rv rangeValue];
      if (r.length >= 3) {
        NSRange repRange = NSMakeRange(r.location+1, r.length-1);
        NSRange textRange = NSMakeRange(r.location+2, r.length-3);
        NSString *text = [[atr string] substringWithRange:textRange];
        MHPlaceholderAttachment *placeholderAttachment = [[MHPlaceholderAttachment alloc] initWithName:text];
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:placeholderAttachment];
        [atr replaceCharactersInRange:repRange withAttributedString:attachment];
        break;
      }
    }
    count++;
  } while (ranges != nil && [ranges count] > 0 && count < maxCount);
  
  return atr;
}

@end
