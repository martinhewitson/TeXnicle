//
//  MHFoldingTag.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/05/11.
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

#import "MHFoldingTag.h"


@implementation MHFoldingTag

@synthesize tag;
@synthesize index;
@synthesize lineNumber;
@synthesize isStartTag;

+ (MHFoldingTag*) tagWithStartTag:(MHFoldingTagDescription*)aTag index:(NSInteger)anIndex lineNumber:(NSInteger)aLineNumber isStartTag:(BOOL)result
{
  return [[MHFoldingTag alloc] initWithStartTag:aTag index:anIndex lineNumber:aLineNumber isStartTag:result];
}

- (id) initWithStartTag:(MHFoldingTagDescription*)aTag index:(NSInteger)anIndex lineNumber:(NSInteger)aLineNumber isStartTag:(BOOL)result
{
  self = [super init];
  if (self) {
    self.tag = aTag;
    self.index = anIndex;
    self.lineNumber = aLineNumber;
    self.isStartTag = result;
  }
  
  return self;
}


- (NSString*) description
{
  if (self.isStartTag) {
    return [NSString stringWithFormat:@"%ld, %ld: %@, isStartTag=%d", self.lineNumber, self.index, self.tag.startTag, self.isStartTag];
  } else {
    return [NSString stringWithFormat:@"%ld, %ld: %@, isStartTag=%d", self.lineNumber, self.index, self.tag.endTag, self.isStartTag];
  }
}

@end
