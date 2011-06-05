//
//  NSString+Comparisons.h
//  TeXnicle
//
//  Created by Martin Hewitson on 17/2/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (Comparisons)

- (BOOL) beginsWith:(NSString*)aString;
- (BOOL) endsWith:(NSString*)aString;

- (BOOL) isTextFile;

@end
