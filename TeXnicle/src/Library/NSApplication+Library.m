//
//  NSApplication+Library.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "NSApplication+Library.h"
#import "TeXnicleAppController.h"

@implementation NSApplication (Library)

+ (TPLibrary*)sharedLibrary
{
  id delegate = [[NSApplication sharedApplication] delegate];
  if (delegate) {
    return [(TeXnicleAppController*)delegate library];
  }
  return nil;
}

@end
