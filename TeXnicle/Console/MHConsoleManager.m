//
//  MHConsoleManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//
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

#import "MHConsoleManager.h"

@interface MHConsoleManager ()

@property (strong) NSMutableSet *consoles;

@end

@implementation MHConsoleManager

- (void) tearDown
{
//  NSLog(@"Tear down %@", self);
  [self.consoles removeAllObjects];
  self.consoles = nil;
}

- (id) init
{
  self = [super init];
  if (self) {
    self.consoles = [NSMutableSet set];
  }
  return self;
}

- (BOOL)registerConsole:(id<MHConsoleViewer>)aConsole
{
  if (![aConsole conformsToProtocol:@protocol(MHConsoleViewer)]) {
    return NO;
  }
  [self.consoles addObject:aConsole];
  return YES;
}

- (void) clear
{
  for (id<MHConsoleViewer> viewer in self.consoles) {
    if ([viewer respondsToSelector:@selector(clear)]) {
      [viewer clear];
    }
  }
}

- (void) appendText:(NSString*)someText
{
  for (id<MHConsoleViewer> viewer in self.consoles) {
    if ([viewer respondsToSelector:@selector(appendText:)]) {
      [viewer appendText:someText];
    }
  }  
}

- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor
{
  for (id<MHConsoleViewer> viewer in self.consoles) {
    if ([viewer respondsToSelector:@selector(appendText:withColor:)]) {
      [viewer appendText:someText withColor:aColor];
    }
  }  
}

- (void) error:(NSString*)someText
{
  for (id<MHConsoleViewer> viewer in self.consoles) {
    if ([viewer respondsToSelector:@selector(error:)]) {
      [viewer error:someText];
    }
  }
}

- (void) message:(NSString*)someText
{
  for (id<MHConsoleViewer> viewer in self.consoles) {
    if ([viewer respondsToSelector:@selector(message:)]) {
      [viewer message:someText];
    }
  }
}

@end
