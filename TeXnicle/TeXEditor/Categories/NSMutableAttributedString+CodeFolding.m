//
//  NSAttributedString+CodeFolding.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSMutableAttributedString+CodeFolding.h"
#import "NSAttributedString+Placeholders.h"

@implementation NSMutableAttributedString (CodeFolding)

// returns an unfolded string by unfolding all code-folding attachments.
- (NSString*)unfoldedString
{
	[self unfoldAll];
	return [self string];
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
			
			if (att && [att respondsToSelector:@selector(object)]) {			
				NSData *data = [[att fileWrapper] regularFileContents];
				NSAttributedString *code = [[NSAttributedString alloc] initWithRTFD:data documentAttributes:nil];
        code = [NSAttributedString stringWithPlaceholdersRestored:[code string]];
				NSRange attRange = NSMakeRange(loc, 1);
				[self removeAttribute:NSAttachmentAttributeName range:attRange];
				[self replaceCharactersInRange:attRange withAttributedString:code];
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
