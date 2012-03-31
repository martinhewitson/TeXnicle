//
//  ConsoleWindow.m
//  TeXnicle
//
//  Created by Martin Hewitson on 03/06/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "ConsoleWindow.h"


@implementation ConsoleWindow

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL) acceptsFirstResponder
{
  return NO;
}

@end
