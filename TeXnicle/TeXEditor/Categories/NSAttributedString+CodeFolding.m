//
//  NSAttributedString+CodeFolding.m
//  TeXEditor
//
//  Created by Martin Hewitson on 16/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "NSAttributedString+CodeFolding.h"
#import "MHCodeFolder.h"

@implementation NSAttributedString (CodeFolding)

// Returns the first attachment in the attributed string.
- (NSTextAttachment*)firstAttachment
{
  int loc = 0;
  NSUInteger strLen = [self length];
  while (loc < strLen) {
    NSRange effRange;
    NSTextAttachment *att = [self attribute:NSAttachmentAttributeName
                                    atIndex:loc
                             effectiveRange:&effRange];
    
    if (att) {			
      return att;
    }
    loc++;
  }
  return nil;
}

// Count the number of lines in the given attributed string. 
// Generally the string represents one line. However, if the string
// contains an attachment then it could contain folded text so we need
// to get out the stored code folder and retrieve the number of folded
// lines.
+ (NSInteger)lineCountForLine:(NSAttributedString*)aLine
{
  BOOL isFolded = [aLine containsAttachments];
  if (isFolded) {
    NSTextAttachment *att = [aLine firstAttachment];
    
    if (att) {			
      MHCodeFolder *folder = [att valueForKey:@"object"];
      return folder.lineCount+1;
    }
  }
  return 1;
}

@end
