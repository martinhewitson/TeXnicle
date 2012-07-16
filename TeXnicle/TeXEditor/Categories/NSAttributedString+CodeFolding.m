//
//  NSAttributedString+CodeFolding.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
    
    if (att && [att respondsToSelector:@selector(object)]) {			
      MHCodeFolder *folder = [att valueForKey:@"object"];
      return folder.lineCount+1;
    }
  }
  return 1;
}

@end
