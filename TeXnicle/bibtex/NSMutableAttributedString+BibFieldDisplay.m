//
//  NSMutableAttributedString+BibFieldDisplay.m
//  TeXnicle
//
//  Created by Martin Hewitson on 1/4/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "NSMutableAttributedString+BibFieldDisplay.h"


@implementation NSMutableAttributedString (BibFieldDisplay)

- (void) addString:(NSString*)aString withTag:(NSString*)aTag
{
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:
																			 [NSString stringWithFormat:@"%@ %@\n\n", aTag, aString]];
	[str addAttribute:NSFontAttributeName 
							value:[NSFont systemFontOfSize:14.0]
							range:NSMakeRange(0, [str length])];
	[str addAttribute:NSFontAttributeName 
							value:[NSFont boldSystemFontOfSize:14.0]
							range:NSMakeRange(0, [aTag length])];
	[str addAttribute:NSForegroundColorAttributeName
							value:[NSColor grayColor]
							range:NSMakeRange(0, [aTag length])];
	[self appendAttributedString:str];
	[str release];
}


@end
