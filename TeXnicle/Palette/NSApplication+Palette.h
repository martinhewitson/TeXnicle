//
//  NSApplication+Palette.h
//  TeXnicle
//
//  Created by Martin Hewitson on 2/8/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPPalette.h"

@interface NSApplication (Palette)

+ (TPPalette*)sharedPalette;

@end
