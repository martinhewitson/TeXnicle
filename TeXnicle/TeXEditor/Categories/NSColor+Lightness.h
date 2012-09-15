//
//  NSColor+Lightness.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/09/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Lightness)

- (BOOL)isDarkerThan:(float)lightness;

@end
