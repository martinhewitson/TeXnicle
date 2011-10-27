//
//  MHConsoleManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHConsoleManager.h"

@implementation MHConsoleManager

@synthesize consoles;

- (void) dealloc
{
  self.consoles = nil;
  [super dealloc];
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
