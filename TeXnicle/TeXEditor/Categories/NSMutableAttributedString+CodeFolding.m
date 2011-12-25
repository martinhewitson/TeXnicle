//
//  NSAttributedString+CodeFolding.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "NSMutableAttributedString+CodeFolding.h"


@implementation NSMutableAttributedString (CodeFolding)

// returns an unfolded string by unfolding all code-folding attachments.
- (NSString*)unfoldedString
{
	[self unfoldAll];
	return [[[self string] mutableCopy] autorelease];
}

// unfolds all attachments in the attributed string.
- (void) unfoldAll 
{
	[self unfoldAllInRange:NSMakeRange(0, [self length]) max:10000];
}

// unfolds all attachments in the given range.
- (NSInteger) unfoldAllInRange:(NSRange)aRange max:(NSInteger)max
{
	int found;
	int done = 0;
	do {
		found = 0;
		// get location of the attachment
		int loc = 0;
		NSUInteger strLen = [self length];
		while (loc < strLen) {
			
			// get attribute at the start of the fold range
			NSRange effRange;
			NSTextAttachment *att = [self attribute:NSAttachmentAttributeName
																			atIndex:loc
															 effectiveRange:&effRange];
			
			if (att) {			
				NSData *data = [[att fileWrapper] regularFileContents];
				NSAttributedString *code = [[NSAttributedString alloc] initWithRTFD:data documentAttributes:nil];
				NSRange attRange = NSMakeRange(loc, 1);
				[self removeAttribute:NSAttachmentAttributeName range:attRange];
				[self replaceCharactersInRange:attRange withAttributedString:code];
				[code release];
				found++;
				done++;
				break;
			}
			
			loc++;
		}
		
		if (done>=max)
			break;
		
	} 
	while (found > 0);
	
	return done;
}




@end
