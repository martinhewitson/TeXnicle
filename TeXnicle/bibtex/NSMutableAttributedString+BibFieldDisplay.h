//
//  NSMutableAttributedString+BibFieldDisplay.h
//  TeXnicle
//
//  Created by Martin Hewitson on 1/4/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableAttributedString (BibFieldDisplay)

- (void) addString:(NSString*)aString withTag:(NSString*)aTag;

@end
