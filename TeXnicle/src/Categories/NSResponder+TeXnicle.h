//
//  NSResponder+TeXnicle.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/01/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSResponder (TeXnicle)

+ (void) removeResponder:(NSResponder*)responder fromChainOfResponder:(NSResponder*)parent;

@end
