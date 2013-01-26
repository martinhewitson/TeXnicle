//
//  NSResponder+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/01/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "NSResponder+TeXnicle.h"

@implementation NSResponder (TeXnicle)

+ (void) removeResponder:(NSResponder*)responder fromChainOfResponder:(NSResponder*)parent
{
  NSResponder *current = parent;
  NSResponder *next = parent.nextResponder;
  
  // go looking for the responder
  while (next != responder && next != nil) {
    current = next;
    next = next.nextResponder;
  }
  
  if (current != nil) {
    // now remove responder from the parent
    [current setNextResponder:responder.nextResponder];
    responder.nextResponder = nil;
  }
}

@end
