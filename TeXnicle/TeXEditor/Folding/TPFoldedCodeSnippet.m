//
//  TPFoldedCodeSnippet.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "TPFoldedCodeSnippet.h"
#import "TPFoldedAttachmentCell.h"

@implementation TPFoldedCodeSnippet

@synthesize code;
@synthesize object;

- (id) initWithCode:(NSAttributedString*)aString
{
	NSData *d = [aString RTFDFromRange:NSMakeRange(0, [aString length])
									documentAttributes:nil];
	NSFileWrapper *fw = [[NSFileWrapper alloc] initRegularFileWithContents:d];
	[fw setPreferredFilename:@"snippet"];
	self = [super initWithFileWrapper:fw];
	[fw release];
	if (self) {
		TPFoldedAttachmentCell *aCell = [[TPFoldedAttachmentCell alloc] initTextCell:@"..."];
		[self setAttachmentCell:aCell];
		[aCell release];
	}
	
	return self;
}

- (void) dealloc
{
  self.object = nil;
  [super dealloc];
}

@end
