//
//  NSMutableAttributedString+Placeholders.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "NSMutableAttributedString+Placeholders.h"
#import "MHPlaceholderAttachment.h"

@implementation NSMutableAttributedString (Placeholders)

// replace all placeholds in the given range with the given string
- (void) replacePlaceholdersInRange:(NSRange)aRange
{
	int found;
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
			
			if (att != nil && [att isKindOfClass:[MHPlaceholderAttachment class]]) {
        NSTextAttachmentCell *cell = (NSTextAttachmentCell*)[att attachmentCell];
				NSAttributedString *code = [cell attributedStringValue];
        NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@@", [code string]]];
				NSRange attRange = NSMakeRange(loc, 1);
				[self removeAttribute:NSAttachmentAttributeName range:attRange];
				[self replaceCharactersInRange:attRange withAttributedString:placeholder];
				found++;
				break;
			}
			
			loc++;
		}
	}
	while (found > 0);
	
}

@end
