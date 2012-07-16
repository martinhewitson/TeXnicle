//
//  NSApplication+Library.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPLibrary.h"

@interface NSApplication (Library)

+ (TPLibrary*)sharedLibrary;

@end
