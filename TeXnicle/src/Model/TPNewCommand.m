//
//  TPNewCommand.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPNewCommand.h"
#import "NSString+LaTeX.h"

@implementation TPNewCommand

@synthesize source;
@synthesize argument;
@synthesize file;

+ (id) commandWithFile:(id)aFile source:(NSString*)text
{
  return [[TPNewCommand alloc] initWithFile:aFile source:text];
}

- (id) initWithFile:(id)aFile source:(NSString*)text
{
  self = [self initWithSource:text];
  if (self) {
    self.file = aFile;
  }
  return self;
}

+ (id) commandWithSource:(NSString*)text
{
  return [[TPNewCommand alloc] initWithSource:text];
}

- (id) initWithSource:(NSString*)text
{
  self = [super init];
  if (self) {
    self.source = text;
    self.argument = [text argument];
  }
  return self;
}


- (NSString*)string
{
  return self.argument;
}


@end
