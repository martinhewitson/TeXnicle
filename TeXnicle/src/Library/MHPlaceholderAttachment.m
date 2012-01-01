//
//  MHPlaceholderAttachment.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHPlaceholderAttachment.h"
#import "MHPlaceholderAttachmentCell.h"

@implementation MHPlaceholderAttachment

- (id) initWithName:(NSString*)aString
{
	NSFileWrapper *fw = [[NSFileWrapper alloc] init];
	[fw setPreferredFilename:@"placeholder"];
	self = [super initWithFileWrapper:fw];
	[fw release];
	if (self) {
		MHPlaceholderAttachmentCell *aCell = [[MHPlaceholderAttachmentCell alloc] initTextCell:aString];
		[self setAttachmentCell:aCell];
		[aCell release];
	}
	
	return self;
}


@end
