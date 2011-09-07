//
//  TPClippingsTable.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "TPClippingsTable.h"


@implementation TPClippingsTable

- (void) textDidEndEditing: (NSNotification *) notification
{
	//NSLog(@"Text did end editing %@", notification);
	
	NSInteger idx = [self editedRow];
	if (idx >= 0) {
		if ([[self delegate] respondsToSelector:@selector(refreshSymbolAtRow:)]) {
			[[self delegate] performSelector:@selector(refreshSymbolAtRow:) withObject:[NSNumber numberWithInteger:idx]];
		}
	}
	[super textDidEndEditing:notification];
}

@end
