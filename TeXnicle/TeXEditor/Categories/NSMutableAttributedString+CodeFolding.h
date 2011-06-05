//
//  NSAttributedString+CodeFolding.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableAttributedString (CodeFolding)

- (NSInteger) unfoldAllInRange:(NSRange)aRange max:(NSInteger)max;
- (void) unfoldAll;
- (NSString*)unfoldedString;

@end
