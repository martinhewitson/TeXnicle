//
//  TPFoldedCell.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "TPFoldedAttachmentCell.h"
#import "externs.h"

@implementation TPFoldedAttachmentCell

- (id) initTextCell:(NSString *)aString
{
	//NSLog(@"Init text cell");
	self = [super initTextCell:aString];
	if (self) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSFont *f = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];									
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:f forKey:NSFontAttributeName];
		NSAttributedString *str = [[NSAttributedString alloc] initWithString:aString
																															attributes:dict];
		[self setAttributedStringValue:str];
		
		[str release];
		
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView
{
	
	[[NSColor colorWithDeviceRed:246.0/255.0 green:246.0/255.0 blue:172.0/255.0 alpha:1.0] set];
//	NSRectFill(cellFrame);
	NSBezierPath *bp = [[NSBezierPath alloc] init];
	NSRect irect = NSInsetRect(cellFrame, 3, 0);
	[bp appendBezierPathWithRoundedRect:NSMakeRect(irect.origin.x, 
																								 irect.origin.y, 
																								 irect.size.width, 
																								 irect.size.height) 
															xRadius:0.5*irect.size.height
															yRadius:0.5*irect.size.height];
	
	[bp fill];
	[bp release];
	NSSize strSize = [[self attributedStringValue] size];
	NSRect r = NSMakeRect(irect.origin.x+(irect.size.width-strSize.width)/2.0, 
												irect.origin.y-strSize.height/3.0, 
												strSize.width, strSize.height);
	[[self attributedStringValue] drawInRect:r];
	
}

- (NSSize) cellSize
{
	NSAttributedString *str = [self attributedStringValue];
	NSSize strSize = [str size];
	return NSMakeSize(2.0*strSize.width, 0.7*strSize.height);
}




@end
