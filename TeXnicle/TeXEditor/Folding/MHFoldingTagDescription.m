//
//  MHFoldingTag.m
//  TeXEditor
//
//  Created by Martin Hewitson on 01/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "MHFoldingTagDescription.h"
#import "NSString+Extension.h"

@implementation MHFoldingTagDescription

@synthesize startTag;
@synthesize endTag;
@synthesize hasFollowingArgument;
@synthesize index;

+ (MHFoldingTagDescription*)deepCopyOfTag:(MHFoldingTagDescription*)aTag
{
  MHFoldingTagDescription *tag = [MHFoldingTagDescription foldingTagWithStartTag:aTag.startTag endTag:aTag.endTag followingArgument:aTag.hasFollowingArgument];
  tag.index = aTag.index;
  return tag;
}

+ (MHFoldingTagDescription*)foldingTagWithStartTag:(NSString*)aStartTag endTag:(NSString*)anEndTag followingArgument:(BOOL)hasArgument
{
  return [[[MHFoldingTagDescription alloc] initWithStartTag:aStartTag endTag:anEndTag followingArgument:hasArgument] autorelease];
}

- (id)initWithStartTag:(NSString*)aStartTag endTag:(NSString*)anEndTag followingArgument:(BOOL)hasArgument
{
  self = [super init];
  if (self) {
    // Initialization code here.
    self.startTag = aStartTag;
    self.endTag = anEndTag;
    self.hasFollowingArgument = hasArgument;
  }
  
  return self;
}

- (void)dealloc
{
  self.startTag = nil;
  self.endTag = nil;
  [super dealloc];
}

+ (MHFoldingTagDescription*) foldingTagInLine:(NSString*)line atIndex:(NSInteger*)index fromTags:(NSArray*)tags matched:(NSInteger*)matchingTag
{
  NSInteger idx = *index;
  
//	NSString *testline = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//  NSLog(@"Looking for folder in line %ld, %@", idx, line);
  
  if (idx >= [line length]) {
    *index = NSNotFound;
    return nil;
  }
  NSInteger lineStart = idx;
  line = [line substringFromIndex:lineStart];
  NSInteger tagStart;
	
	for (MHFoldingTagDescription *tag in tags) {		
		// check for start tag first
    tagStart = [line indexOfFirstMatch:tag.startTag];
		if (tagStart != NSNotFound) {
      *matchingTag = MHFoldingTagStartMatched;
//      NSLog(@"Matching tag at index %ld", idx);
      idx = tagStart + [tag.startTag length];
      if (tag.hasFollowingArgument) {
        while (idx<[line length]) {
          if ([line characterAtIndex:idx] == '}') {
            idx++;
            break;
          }
          idx++;
        }
      }
      //      NSLog(@"Matched start tag: %@", tag.startTag);
      *index += idx;
      MHFoldingTagDescription *returnTag = [MHFoldingTagDescription deepCopyOfTag:tag];
      returnTag.index = tagStart;
			return returnTag;
		}
    
    // check for end tag
    tagStart = [line indexOfFirstMatch:tag.endTag];
		if (tagStart != NSNotFound) {
      *matchingTag = MHFoldingTagEndMatched;
      idx = tagStart+ [tag.endTag length];
      if (tag.hasFollowingArgument) {
        while (idx<[line length]) {
          if ([line characterAtIndex:idx] == '}') {
            idx++;
            break;
          }
          idx++;
        }
      }
      *index += idx;
      MHFoldingTagDescription *returnTag = [MHFoldingTagDescription deepCopyOfTag:tag];
      returnTag.index = tagStart;
			return tag;
		}    
    
	}
//  NSLog(@"Not found");
  *index = NSNotFound;
	return nil;
}


@end
